post_init()
{
	level.elec_trap_cooldown_time = 25;
}

//move trap handle based on its current position so it ends up at the correct spot
move_trap_handle(end_angle)
{
	angle = self.angles[0];

	if(angle < -180)
	{
		angle += 360;
	}
	else if(angle > 180)
	{
		angle -= 360;
	}

	percent = (angle + 180) / 180;
	time = .5 * percent;
	if(time < .05)
	{
		time = .05;
	}
	extra_time = .5 - time;

	self rotatepitch(end_angle - angle, time);

	return extra_time;
}

//*****************************************************************************
//	This controls the electric traps in the level
//		self = use trigger associated with the trap
//		trap = trap trigger entity
//*****************************************************************************
trap_use_think( trap )
{
	while(1)
	{
		//wait until someone uses the valve
		self waittill("trigger",who);

		if( who in_revive_trigger() )
		{
			continue;
		}

		if( is_player_valid( who ) && !trap._trap_in_use )
		{
			// See if they can afford it
			players = get_players();
			if ( players.size == 1 && who.score >= trap.zombie_cost )
			{
				// Solo buy
				who maps\_zombiemode_score::minus_to_player_score( trap.zombie_cost );
			}
			else if( level.team_pool[who.team_num].score >= trap.zombie_cost )
			{
				// Team buy
				who maps\_zombiemode_score::minus_to_team_score( trap.zombie_cost );
			}
			else if( level.team_pool[ who.team_num ].score + who.score >= trap.zombie_cost )
			{
				// team funds + player funds
				team_points = level.team_pool[ who.team_num ].score;
				who maps\_zombiemode_score::minus_to_player_score( trap.zombie_cost - team_points );
				who maps\_zombiemode_score::minus_to_team_score( team_points );
			}
			else
			{
				continue;
			}

			trap._trap_in_use = 1;
			trap trap_set_string( &"ZOMBIE_TRAP_ACTIVE" );

			play_sound_at_pos( "purchase", who.origin );

			if ( trap._trap_switches.size )
			{
				trap thread trap_move_switches(who);

				//need to play a 'woosh' sound here, like a gas furnace starting up
				trap waittill("switch_activated");
			}

			//this trigger detects zombies who need to be smacked
			trap trigger_on();

			//start the movement
			trap thread [[ trap._trap_activate_func ]]();
			//wait until done and then clean up and cool down
			trap waittill("trap_done");

			//turn the damage detection trigger off until the trap is used again
			trap trigger_off();

			trap._trap_cooling_down = 1;
			trap trap_set_string( &"ZOMBIE_TRAP_COOLDOWN" );
/#
			if ( GetDvarInt( #"zombie_cheat" ) >= 1 )
			{
				trap._trap_cooldown_time = 5;
			}
#/
			wait( trap._trap_cooldown_time );
			trap._trap_cooling_down = 0;

			//COLLIN: Play the 'alarm' sound to alert players that the traps are available again (playing on a temp ent in case the PA is already in use.
			//speakerA = getstruct("loudspeaker", "targetname");
			//playsoundatposition("warning", speakera.origin);
			trap notify("available");

			trap._trap_in_use = 0;
			trap trap_set_string( &"ZOMBIE_BUTTON_BUY_TRAP", trap.zombie_cost );
		}
	}
}

//*****************************************************************************
// It's a throw switch
//	self should be the trap entity
//*****************************************************************************
trap_move_switches(activator)
{
	if( level.mutators["mutator_noTraps"] )
	{
		return;
	}

	self trap_lights_red();

	/*for ( i=0; i<self._trap_switches.size; i++ )
	{
		// Rotate switch model "on"
		self._trap_switches[i] rotatepitch( 180, .5 );
		self._trap_switches[i] playsound( "amb_sparks_l_b" );
	}*/
	closest = GetClosest(activator.origin, self._trap_switches);
	extra_time = closest move_trap_handle(180);
	closest playsound( "amb_sparks_l_b" );

	closest waittill( "rotatedone" );
	if(extra_time > 0)
	{
		wait(extra_time);
	}

	// When "available" notify hit, bring back the level
	self notify( "switch_activated" );

	self waittill( "available" );
	/*for ( i=0; i<self._trap_switches.size; i++ )
	{
		// Rotate switch model "off"
		self._trap_switches[i] rotatepitch( -180, .5 );
	}*/
	self trap_lights_green();
	closest rotatepitch( -180, .5 );
	closest waittill( "rotatedone" );
}

//#############################################################################
// Generic Trap-specific functions
//	Level-specific traps should be defined in the level.gsc
//*****************************************************************************


//*****************************************************************************
//
//*****************************************************************************

trap_activate_electric(activator)
{
	self._trap_duration = 40;
	if(level.script == "zombie_pentagon")
	{
		self._trap_cooldown_time = 60;
	}
	else
	{
		self._trap_cooldown_time = 25;
	}

	self notify("trap_activate");

	// Kick off the client side FX structs
	if ( IsDefined( self.script_string ) )
	{
		number = Int( self.script_string );
		if ( number != 0 )
		{
			Exploder( number );
		}
		else
		{
			clientnotify( self.script_string+"1" );
		}
	}

	// Kick off audio
	fx_points = getstructarray( self.target,"targetname" );
	for( i=0; i<fx_points.size; i++ )
	{
		wait_network_frame();
		fx_points[i] thread trap_audio_fx(self);
	}

	// Do the damage
	self thread trap_damage(activator);
	wait( self._trap_duration );

	// Shut down
	self notify ("trap_done");

	if ( IsDefined( self.script_string ) )
	{
		clientnotify(self.script_string +"0");	// turn off FX
	}
}

trap_activate_fire(activator)
{
	self._trap_duration = 40;
	self._trap_cooldown_time = 50;

	// Kick off the client side FX structs
	clientnotify( self.script_string+"1" );
	clientnotify( self.script_parameters );

	// Kick off audio
	fx_points = getstructarray( self.target,"targetname" );
	for( i=0; i<fx_points.size; i++ )
	{
		wait_network_frame();
		fx_points[i] thread trap_audio_fx(self);
	}

	// Do the damage
	self thread trap_damage(activator);
	wait( self._trap_duration );

	// Shut down
	self notify ("trap_done");
	clientnotify(self.script_string +"0");	// turn off FX
	clientnotify( self.script_parameters );
}


//*****************************************************************************
// Any traps that spin and cause damage from colliding
//*****************************************************************************

trap_activate_rotating(activator)
{
	self endon( "trap_done" );	// used to end the trap early

	self._trap_duration = 30;
	self._trap_cooldown_time = 60;

	// Kick off the client side FX structs
//	clientnotify( self.script_string+"1" );

	// Kick off audio
// 	fx_points = getstructarray( self.target,"targetname" );
// 	for( i=0; i<fx_points.size; i++ )
// 	{
// 		wait_network_frame();
// 		fx_points[i] thread trap_audio_fx(self);
// 	}

	// Do the damage
	self thread trap_damage(activator);
	self thread trig_update( self._trap_movers[0] );
	old_angles = self._trap_movers[0].angles;

	//Shawn J Sound - power up sound for centrifuge
//	self playsound ("evt_centrifuge_rise");

	for ( i=0; i<self._trap_movers.size; i++ )
	{
		self._trap_movers[i] RotateYaw( 360, 5.0, 4.5 );
	}
	wait( 5.0 );
	step = 1.5;

	//Shawn J Sound - loop sound for centrifuge
//	self playloopsound ("evt_centrifuge_loop", .6);

	for (t=0; t<self._trap_duration; t=t+step )
	{
		for ( i=0; i<self._trap_movers.size; i++ )
		{
			self._trap_movers[i] RotateYaw( 360, step );
		}
		wait( step );
	}

	//Shawn J Sound - power down sound for centrifuge
//	self stoploopsound (2);
//	self playsound ("evt_centrifuge_fall");

	for ( i=0; i<self._trap_movers.size; i++ )
	{
		self._trap_movers[i] RotateYaw( 360, 5.0, 0.0, 4.5 );
	}
	wait( 5.0 );
	for ( i=0; i<self._trap_movers.size; i++ )
	{
		self._trap_movers[i].angles = old_angles;
	}

	// Shut down
	self notify ("trap_done");
//	clientnotify(self.script_string +"0");	// turn off FX3/16/2010 3:44:13 PM
}

trap_damage(activator)
{
	self endon( "trap_done" );

	while(1)
	{
		self waittill( "trigger", ent );

		// Is player standing in the electricity?
		if( isplayer(ent) )
		{
			switch ( self._trap_type )
			{
			case "electric":
				ent thread player_elec_damage();
				break;
			case "fire":
			case "rocket":
				ent thread player_fire_damage();
				break;
			case "rotating":
				if ( ent GetStance() == "stand" )
				{
					ent dodamage( 50, ent.origin+(0,0,20) );
					ent SetStance( "crouch" );
				}
				break;
			}
		}
		else
		{
			if(!isDefined(ent.marked_for_death))
			{
				switch ( self._trap_type )
				{
				case "rocket":
					ent thread zombie_trap_death( self, 100, activator );
					break;
				case "rotating":
					ent thread zombie_trap_death( self, 200, activator );
					break;
				case "electric":
				case "fire":
				default:
					ent thread zombie_trap_death( self, randomint(100), activator );
					break;
				}
			}
		}
	}
}

player_elec_damage()
{
	self endon("death");
	self endon("disconnect");

	if(!IsDefined (level.elec_loop))
	{
		level.elec_loop = 0;
	}

	if( !isDefined(self.is_burning) && !self maps\_laststand::player_is_in_laststand() )
	{
		self.is_burning = 1;
		self setelectrified(1.25);
		shocktime = 1.25;
		//Changed Shellshock to Electrocution so we can have different bus volumes.
		self shellshock("electrocution", shocktime);

		if(level.elec_loop == 0)
		{
			elec_loop = 1;
			//self playloopsound ("electrocution");
			//self playsound("zmb_zombie_arc");
		}
		if(!self hasperk("specialty_armorvest") || self.health - 100 < 1)
		{

			radiusdamage(self.origin,10,self.health + 100,self.health + 100);
			self.is_burning = undefined;

		}
		else
		{
			self dodamage(50, self.origin);
			wait(.1);
			//self playsound("zombie_arc");
			self.is_burning = undefined;
		}

	}

}

//*****************************************************************************
//
//*****************************************************************************

player_fire_damage()
{
	self endon("death");
	self endon("disconnect");

	if( !isDefined(self.is_burning) && !self maps\_laststand::player_is_in_laststand() )
	{
		self.is_burning = 1;
		self setburn(0.75);

		if(!self hasperk("specialty_armorvest") /*|| !self hasperk("specialty_armorvest_upgrade")*/ || self.health - 100 < 1)
		{
			radiusdamage(self.origin,10,self.health + 100,self.health + 100);
			self.is_burning = undefined;
		}
		else
		{
			self dodamage(50, self.origin);
			wait(.1);
			self playsound("zmb_zombie_arc");
			self.is_burning = undefined;
		}
	}
}


//*****************************************************************************
//	trap is the parent trap entity
//	param is a multi-purpose paramater.  The exact use is described by trap type
//*****************************************************************************
zombie_trap_death( trap, param, activator )
{
	if( level.mutators["mutator_noTraps"] )
	{
		return;
	}
	self endon("death");

	self.marked_for_death = true;
	self.trap_death = true;

	switch (trap._trap_type)
	{
	case "fire":
	case "electric":
	case "rocket":
		// Param is used as a random chance number

		if ( IsDefined( self.animname ) && self.animname != "zombie_dog" )
		{
			// 10% chance the zombie will burn, a max of 6 burning zombs can be going at once
			// otherwise the zombie just gibs and dies
			if( (param > 90) && (level.burning_zombies.size < 6) )
			{
				level.burning_zombies[level.burning_zombies.size] = self;
				self thread zombie_flame_watch();
				self playsound("ignite");
				self thread animscripts\zombie_death::flame_death_fx();
				wait( randomfloat(0.5) );
			}
			else
			{
				refs[0] = "guts";
				refs[1] = "right_arm";
				refs[2] = "left_arm";
				refs[3] = "right_leg";
				refs[4] = "left_leg";
				refs[5] = "no_legs";
				refs[6] = "head";
				self.a.gib_ref = refs[randomint(refs.size)];

				playsoundatposition("zmb_zombie_arc", self.origin);

				if( trap._trap_type == "electric" )
				{
					if(randomint(100) > 50 )
					{
						self thread electroctute_death_fx();
						self thread play_elec_vocals();
					}
				}

				wait(randomfloat(0.5));
				self playsound("zmb_zombie_arc");
			}
		}

		// custom damage
		if ( IsDefined( self.fire_damage_func ) )
		{
			self [[ self.fire_damage_func ]]( trap );
		}
		else
		{
			level notify( "trap_kill", self, trap );

			self.no_powerups = true;
			self dodamage(self.health + 666, self.origin, activator);
		}

//		iprintlnbold("should be damaged");
		break;

	case "rotating":
	case "centrifuge":
		// Param is used as a magnitude for the physics push

		// Get a vector for the force to be applied.  It needs to be perpendicular to the
		//	bar
		ang = VectorToAngles( trap.origin - self.origin );
		// eliminate height difference factors
		//	calculate the right angle and increase intensity
		direction_vec = vector_scale( AnglesToRight( ang ), param);

		// custom reaction
		if ( IsDefined( self.trap_reaction_func ) )
		{
			self [[ self.trap_reaction_func ]]( trap );
		}

		level notify( "trap_kill", self, trap );
		self StartRagdoll();
		self launchragdoll(direction_vec);
		wait_network_frame();

		// Make sure they're dead...physics launch didn't kill them.
		self.a.gib_ref = "head";

		self.no_powerups = true;
		self dodamage(self.health + 666, self.origin, activator);

		break;
	}
}
