do_zombie_fall()
{
	self endon("death");

	self thread setup_deathfunc();

	// don't drop powerups until we are on the ground
	self.no_powerups = true;
	self.in_the_ceiling = true;

	if ( !IsDefined( self.zone_name ) )
	{
		self.zone_name = self get_current_zone();
	}

	spots = get_available_fall_locations();

	if( spots.size < 1 )
	{
		//IPrintLnBold("deleting zombie faller - no available fall locations");
		//can't delete if we're in the middle of spawning, so wait a frame
		self Hide();//hide so we're not visible for one frame while waiting to delete
		self delayThread( 0.1, ::zombie_faller_delete );
		return;
	}
	else if ( GetDvarInt(#"zombie_fall_test") )
	{
		// use the spot closest to the first player always
		player = GetPlayers()[0];
		spot = undefined;
		bestDist = 0.0;
		for ( i = 0; i < spots.size; i++ )
		{
			checkDist = DistanceSquared(spots[i].origin, player.origin);
			if ( !IsDefined(spot) || checkDist < bestDist )
			{
				spot = spots[i];
				bestDist = checkDist;
			}
		}
	}
	else
	{
		spot = random(spots);
	}
	self.zombie_faller_location = spot;
	//NOTE: multiple zombie fallers could be waiting in the same spot now, need to have spawners detect this
	//		and not use the spot again until the previous zombie has died or dropped down
	self.zombie_faller_location.is_enabled = false;
	self.zombie_faller_location parse_script_parameters();

	if( !isDefined( spot.angles ) )
	{
		spot.angles = (0, 0, 0);
	}

	anim_org = spot.origin;
	anim_ang = spot.angles;

	level thread zombie_fall_death(self, spot);
	self thread zombie_faller_death_wait();

	self Hide();
	self.anchor = spawn("script_origin", self.origin);
	self.anchor.angles = self.angles;
	self linkto(self.anchor);
	self.anchor.origin = anim_org;
	// face goal
	target_org = maps\_zombiemode_spawner::get_desired_origin();
	if (IsDefined(target_org))
	{
		anim_ang = VectorToAngles(target_org - self.origin);
		self.anchor.angles = (0, anim_ang[1], 0);
	}
	wait_network_frame();
	self unlink();
	self.anchor delete();
	self thread maps\_zombiemode_spawner::hide_pop();

	spot thread zombie_fall_fx(self);

	//need to thread off the rest because we're apparently still in the middle of our init!
	self thread zombie_faller_do_fall();
}

parse_script_parameters()
{
	if ( IsDefined( self.script_parameters ) )
	{
		parms = strtok( self.script_parameters, ";" );
		if ( IsDefined( parms ) && parms.size > 0 )
		{
			for ( i = 0; i < parms.size; i++ )
			{
				if ( parms[i] == "drop_now" )
				{
					self.drop_now = true;
				}
				//Drop if zone is not occupied
				if ( parms[i] == "drop_not_occupied" )
				{
					self.drop_not_occupied = true;
				}
			}
		}
	}
}

zombie_faller_do_fall()
{
	self endon("death");

	emerge_anim = self get_fall_emerge_anim();
	// first play the emerge, then the fall anim
	self AnimScripted("fall_emerge", self.zombie_faller_location.origin, self.zombie_faller_location.angles, emerge_anim);
	self animscripts\zombie_shared::DoNoteTracks("fall_emerge", ::handle_fall_notetracks, undefined, self.zombie_faller_location);

	//NOTE: now we don't fall until we've attacked at least once from the ceiling
	self.zombie_faller_wait_start = GetTime();
	self.zombie_faller_should_drop = false;
	self.attacked_times = 0;
	//self thread zombie_fall_wait();
	self thread zombie_faller_watch_all_players();
	while ( !self.zombie_faller_should_drop )
	{
		if(self.attacked_times >= 3)
		{
			self.zombie_faller_should_drop = true;
			break;
		}
		if ( self zombie_fall_should_attack(self.zombie_faller_location) )
		{
			self.attacked_times++;
			attack_anim = self get_attack_anim(self.zombie_faller_location);
			self AnimScripted("attack", self.origin, self.zombie_faller_location.angles, attack_anim);
			self animscripts\zombie_shared::DoNoteTracks("attack", ::handle_fall_notetracks, undefined, self.zombie_faller_location);
			//50/50 chance that we'll stay up here and attack again or drop down
			if ( !(self zombie_faller_always_drop()) && randomfloat(1) > 0.5 )
			{
				//NOTE: if we *can* attack, should we actually stay up here until we can't anymore?
				self.zombie_faller_should_drop = true;
			}
		}
		else
		{
			if ( (self zombie_faller_always_drop()) )
			{
				//drop as soon as we have nobody to attack!
				self.zombie_faller_should_drop = true;
				break;
			}
			//otherwise, wait to attack
			else if ( GetTime() >= self.zombie_faller_wait_start + 20000 )
			{
				//we've been hanging here for 20 seconds, go ahead and drop
				//IPrintLnBold("zombie faller waited too long, dropping");
				self.zombie_faller_should_drop = true;
				break;
			}
			else if ( self zombie_faller_drop_not_occupied() )
			{
				self.zombie_faller_should_drop = true;
				break;
			}
			else
			{
				self.attacked_times++;
				//NOTE: instead of playing a looping idle, they just flail and attack over and over
				attack_anim = self get_attack_anim(self.zombie_faller_location);
				self AnimScripted("attack", self.origin, self.zombie_faller_location.angles, attack_anim);
				self animscripts\zombie_shared::DoNoteTracks("attack", ::handle_fall_notetracks, undefined, self.zombie_faller_location);
				if ( !(self zombie_faller_always_drop()) && randomfloat(1) > 0.5 )
				{
					//NOTE: if we *can* attack, should we actually stay up here until we can't anymore?
					self.zombie_faller_should_drop = true;
				}
			}
		}
	}

	self notify("falling");
	//now the fall location (spot) can be used by another zombie faller again
	spot  = self.zombie_faller_location;
	self zombie_faller_enable_location();

	fall_anim = self get_fall_anim(spot);
	self AnimScripted("fall", self.origin, spot.angles, fall_anim);
	self animscripts\zombie_shared::DoNoteTracks("fall", ::handle_fall_notetracks, undefined, spot);

	// rsh040711 - set the death func back to normal
	self.deathFunction = maps\_zombiemode_spawner::zombie_death_animscript;

	self notify("fall_anim_finished");
	spot notify("stop_zombie_fall_fx");

	//play fall loop
	self StopAnimScripted();
	landAnim = random(level._zombie_fall_anims["zombie"]["land"]);
	// Get Z distance
	landAnimDelta = 15; //GetMoveDelta( landAnim, 0, 1 )[2];//delta in the anim doesn't seem to reflect actual distance to ground correctly
	ground_pos = groundpos_ignore_water_new( self.origin );
	//draw_arrow_time( self.origin, ground_pos, (1, 1, 0), 10 );
	physDist = self.origin[2] - ground_pos[2] + landAnimDelta;

	if ( physDist > 0 )
	{
		//high enough above the ground to play some of the falling loop before we can play the land
		ground_pos = groundpos_ignore_water_new( self.origin );
		if( self.origin[2] - ground_pos[2] >= 20)
		{
			fallAnim = level._zombie_fall_anims["zombie"]["fall_loop"];
			if ( IsDefined( fallAnim ) )
			{
				self.fall_anim = fallAnim;
				self animcustom(::zombie_fall_loop);
				self waittill("faller_on_ground");
			}
		}

		//play land
		self.landAnim = landAnim;
		self animcustom(::zombie_land);
		wait( GetAnimLength( landAnim ) );
	}

	self.in_the_ceiling = false;
	self traverseMode( "gravity" );
	//looks like I have to start this manually?
	self SetAnimKnobAllRestart( animscripts\zombie_run::GetRunAnim(), %body, 1, 0.2, 1 );

	self.no_powerups = false;

	// let the default spawn logic know we are done
	self notify("zombie_custom_think_done", spot.script_noteworthy );

	self notify("land_anim_finished");
}

zombie_fall_loop()
{
	self endon("death");

	self setFlaggedAnimKnobRestart( "fall_loop", self.fall_anim, 1, 0.20, 1.0 );

	while(1)
	{
		ground_pos = groundpos_ignore_water_new( self.origin );
		if( self.origin[2] - ground_pos[2] < 20)
		{
			self notify("faller_on_ground");
			break;
		}
		wait .05;
	}
}

zombie_land()
{
	self setFlaggedAnimKnobRestart( "land", self.landAnim, 1, 0.20, 1.0 );
	wait( GetAnimLength( self.landAnim ) );
}

zombie_faller_drop_not_occupied()
{
	if ( is_true(self.zombie_faller_location.drop_not_occupied) )
	{
		if( isDefined(self.zone_name) && isDefined(level.zones[ self.zone_name ]) )
		{
			return !level.zones[ self.zone_name ].is_occupied;
		}
	}
	return false;
}

faller_death_ragdoll()
{
	self StartRagdoll();
	self launchragdoll((0, 0, -1));

	return self maps\_zombiemode_spawner::zombie_death_animscript();
}

potentially_visible( how_close )
{
	if ( !IsDefined( how_close ) )
	{
		how_close = 1000;
	}
	potentiallyVisible = false;

	players = getplayers();
	for ( i = 0; i < players.size; i++ )
	{
		dist = Distance(self.origin, players[i].origin);
		if(dist < how_close)
		{
			inPlayerFov = self in_player_fov(players[i]);
			if(inPlayerFov)
			{
				potentiallyVisible = true;
				//no need to check rest of players
				break;
			}
		}
	}

	return potentiallyVisible;
}
