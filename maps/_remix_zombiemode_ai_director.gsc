director_zombie_spawn()
{
	self.script_moveoverride = true;

	if( !isDefined( level.num_director_zombies ) )
	{
		level.num_director_zombies = 0;
	}
	level.num_director_zombies++;

	director_zombie = self maps\_zombiemode_net::network_safe_stalingrad_spawn( "boss_zombie_spawn", 1 );
	director_zombie Hide();

	//Sound - Shawn J - adding boss spawn sound - note: sound is played in 2d so it doesn't matter what it's played off of.
	//iprintlnbold( "Boss_Spawning!" );
	//self playsound( "zmb_engineer_spawn" );

	self.count = 666;

	self.last_spawn_time = GetTime();

	if( !spawn_failed( director_zombie ) )
	{
		director_zombie.script_noteworthy = self.script_noteworthy;
		director_zombie.targetname = self.targetname;
		director_zombie.target = self.target;
		director_zombie.deathFunction = maps\_zombiemode_ai_director::director_zombie_die;
		director_zombie.animname = "director_zombie";

		director_zombie thread director_zombie_think();
		flag_set("director_alive");	// Runs only for 1st spawn
	}
	else
	{
		level.num_director_zombies--;
	}
}

director_watch_damage()
{
	self endon( "death" );
	self endon( "humangun_leave" );

	self.dmg_taken = 0;
	level.director_damage = 0;
	flag_set( "director_alive" );

	/#
	self thread director_display_damage();
	#/

	//self thread show_damage();
	self director_reset_health( false );

	self.health_state = "pristine";

	while ( 1 )
	{
		self waittill( "damage", amount, attacker, direction, point, method );

		if ( !is_true( self.start_zombies ) )
		{
			self.start_zombies = true;
			self notify( "director_spawn_zombies" );
		}

		if ( is_true( self.leaving_level ) )
		{
			return;
		}

		self.dmg_taken += amount;
		level.director_damage += amount;		// Send to level var

		if ( self.health_state == "pristine" )
		{
			self.health_state = "full";
			self director_flip_light_flag();
		}
		else if ( self.health_state == "full" && self.dmg_taken >= self.damage_one )
		{
			self.health_state = "damage_one";
			self director_flip_light_flag();

			if( IsDefined( level._audio_director_vox_play ) )
	        {
	            rand = RandomIntRange( 0, 5 );
	            self thread [[ level._audio_director_vox_play ]]( "vox_romero_weaken_" + rand, .25 );
	        }

			if( IsDefined( attacker ) && IsPlayer( attacker ) )
			{
			    attacker thread maps\_zombiemode_audio::create_and_play_dialog( "director", "weaken" );
			}
		}
		else if ( self.health_state == "damage_one" && self.dmg_taken >= self.damage_two )
		{
			self.health_state = "damage_two";
			self.light StopLoopSound(2);
			self director_flip_light_flag();

			if( IsDefined( level._audio_director_vox_play ) )
	        {
	            rand = RandomIntRange( 0, 5 );
	            self thread [[ level._audio_director_vox_play ]]( "vox_romero_weaken_" + rand, .25 );
	        }

			if( IsDefined( attacker ) && IsPlayer( attacker ) )
			{
			    attacker thread maps\_zombiemode_audio::create_and_play_dialog( "director", "weaken" );
			}
		}

		if ( self.dmg_taken >= self.max_damage_taken )
		{
			self director_flip_light_flag();
			break;
		}

		if ( is_true( self.in_water ) )
		{
			wait_network_frame();
			if ( !is_true( self.leaving_level ) && !is_true( self.entering_level ) && !is_true( self.sprint2walk ) )
			{
				self thread director_scream_in_water();
			}
		}
	}

	self setclientflag( level._ZOMBIE_ACTOR_FLAG_DIRECTOR_DEATH );

	if ( is_true( self.is_sliding ) )
	{
		self.skip_stumble = true;
		self waittill( "zombie_end_traverse" );
	}

	self notify( "director_exit" );

	self.defeated = true;
	self.solo_last_stand = false;

	self notify( "disable_activation" );
	self notify( "disable_buff" );

	self notify( "stop_find_flesh" );
	self notify( "zombie_acquire_enemy" );

	self.ignoreall = true;

	if ( is_true( self.is_traversing ) )
	{
		self.skip_stumble = true;
		self waittill( "zombie_end_traverse" );
	}

	level notify( "director_submerging_audio" );

	if( IsDefined( level._audio_director_vox_play ) )
	{
	    self thread [[ level._audio_director_vox_play ]]( "vox_director_die", .25, true );
	}

	if ( is_true( self.skip_stumble ) )
	{
		self.skip_stumble = undefined;
	}
	else
	{
		self animcustom( ::director_custom_stumble );
		self waittill_notify_or_timeout( "stumble_done", 7.2 );
	}

	if ( isdefined( level.director_should_drop_special_powerup ) && [[level.director_should_drop_special_powerup]]() )
	{
		level thread maps\_zombiemode_powerups::specific_powerup_drop( "tesla", self.origin );
	}
	else
	{
		level thread maps\_zombiemode_powerups::specific_powerup_drop( "tesla", self.origin );
	}

	forward = VectorNormalize( AnglesToForward( self.angles ) );
	end_pos = self.origin - vector_scale( forward, 32 );

	level thread maps\_zombiemode_powerups::specific_powerup_drop( "free_perk", end_pos );

	level notify( "quiet_on_the_set_achieved" );

	exit = self thread [[ level.director_find_exit ]]();
	self thread director_leave_map( exit, self.in_water );
}

director_scream_in_water()
{
	self endon( "death" );

	if ( !isDefined( self.water_scream ) )
	{
		if ( is_true( self.is_melee ) )
		{
			return;
		}

		self.water_scream = true;

		/*if ( is_true( self.is_melee ) )
		{
			while ( 1 )
			{
				if ( !is_true( self.is_melee ) )
				{
					break;
				}
				wait_network_frame();
			}
		}*/

        if( IsDefined( level._audio_director_vox_play ) )
	    {
	        self thread [[ level._audio_director_vox_play ]]( "vox_director_pain_yell", .25, true );
	    }

		//scream_anim = %ai_zombie_boss_enrage_start_scream_coast;
		scream_anim = %ai_zombie_boss_nuke_react_coast;

		self thread director_scream_delay();
		//self thread scream_a_watcher( "scream_anim" );

		self thread director_zombie_sprint_watcher( "scream_anim" );
		self director_animscripted( scream_anim, "scream_anim" );

		wait( 3 );

		self.water_scream = undefined;
	}
}

director_scream_delay()
{
	self endon( "director_exit" );

	wait( 2.6 );
	clientnotify( "ZDA" );
	self thread director_blur();
}

director_blur()
{
	self endon( "death" );

	players = getplayers();

	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];
		player ShellShock( "electrocution", 1, true );
	}
}

player_electrify()
{
	self endon( "death" );
	self endon( "disconnect" );

	SHOCK_TIME = 0.25;

	if ( !IsDefined( self.electrified ) )
	{
		self.electrified = true;
		//self setelectrified( SHOCK_TIME );
		//self ShellShock( "electrocution", 0.5, true );
		//self PlaySound("zmb_director_damage_zort");
		self setclientflag( level._CF_PLAYER_ELECTRIFIED );
		wait( SHOCK_TIME );
		self clearclientflag( level._CF_PLAYER_ELECTRIFIED );
		self.electrified = undefined;
	}
}

director_max_ammo_watcher()
{
	level.director_max_ammo_available = false;
	level.director_max_ammo_chance = level.director_max_ammo_chance_default;

	flag_wait( "power_on" );

	level.director_max_ammo_round = level.round_number + randomintrange( 1, 4 );

	director_print( "next max ammo round " + level.director_max_ammo_round );

	while ( 1 )
	{
		level waittill( "between_round_over" );

		if ( level.round_number >= level.director_max_ammo_round )
		{
			level.director_max_ammo_available = true;
			level waittill( "director_max_ammo_drop" );
			level.director_max_ammo_round = level.round_number + randomintrange( 4, 5 ); //(4, 6) old

			director_print( "next max ammo round " + level.director_max_ammo_round );
		}
	}
}

director_leave_map( exit, calm )
{
	self endon( "death" );

	self.leaving_level = true;
	flag_clear("director_alive");
	if (flag("potential_director"))
		flag_clear("potential_director");
	level.last_director_round = level.round_number;
	self [[ level.director_exit_level ]]( exit, calm );
	self.leaving_level = undefined;

	if ( !is_true( self.defeated ) )
	{
		self thread director_reset_light_flag();
	}

	self thread director_reenter_map();

}
