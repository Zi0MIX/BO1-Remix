#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include animscripts\zombie_Utility;

#using_animtree( "zombie_cymbal_monkey" ); // WW: A new animtree or should we just use generic human's throw?
player_handle_black_hole_bomb()
{
	//self notify( "starting_black_hole_bomb" );
	self endon( "disconnect" );
	//self endon( "starting_black_hole_bomb" );

	// Min distance to attract positions
	attract_dist_diff = level.black_hole_attract_dist_diff;
	if( !isDefined( attract_dist_diff ) )
	{
		attract_dist_diff = 10;
	}

	num_attractors = level.num_black_hole_bomb_attractors;
	if( !isDefined( num_attractors ) )
	{
		num_attractors = 15; // WW: not using attractors!
	}

	max_attract_dist = level.black_hole_bomb_attract_dist;
	if( !isDefined( max_attract_dist ) )
	{
		max_attract_dist = 2056; // WW: controls the pull distance
	}

	grenade = get_thrown_black_hole_bomb();

	self thread player_handle_black_hole_bomb();

	if( IsDefined( grenade ) )
	{
		if( self maps\_laststand::player_is_in_laststand() || is_true( self.intermission ) )
		{
			grenade delete();
			return;
		}

		grenade hide();
		grenade.angles = (0, grenade.angles[1], 0);

		model = spawn( "script_model", grenade.origin );
		model.angles = grenade.angles;
		model SetModel( "t5_bh_bomb_world" );
		model linkTo( grenade );

		info = spawnStruct();
		info.sound_attractors = [];
		grenade thread maps\_zombiemode_weap_black_hole_bomb::monitor_zombie_groans( info ); // WW: this might need to change
		velocitySq = 10000*10000;
		oldPos = grenade.origin;

		while( velocitySq != 0 )
		{
			wait( 0.05 );

			if( !isDefined( grenade ) )
			{
				return;
			}

			velocitySq = distanceSquared( grenade.origin, oldPos );
			oldPos = grenade.origin;
			grenade.angles = (grenade.angles[0], grenade.angles[1], 0);
		}

		if( isDefined( grenade ) )
		{
			model._black_hole_bomb_player = self; // saves who threw the grenade, used to assign the damage when zombies die
			model.targetname = "zm_bhb";
			model._new_ground_trace = true;

			grenade resetmissiledetonationtime();

			if ( IsDefined( level.black_hole_bomb_loc_check_func ) )
			{
				if ( [[ level.black_hole_bomb_loc_check_func ]]( grenade, model, info ) )
				{
					return;
				}
			}

			if ( IsDefined( level._blackhole_bomb_valid_area_check ) )
			{
				if ( [[ level._blackhole_bomb_valid_area_check ]]( grenade, model, self ) )
				{
					return;
				}
			}

			valid_poi = check_point_in_active_zone( grenade.origin );
			// ww: There used to be a second check here for check_point_in_playable_area which was from the cymbal monkey.
			// This second check was removed because the black hole bomb has a reaction if it is tossed somewhere that can't
			// be accessed. Something similar could be done for the cymbal monkey as well.


			if(valid_poi)
			{
				self thread black_hole_bomb_kill_counter( model );
				level thread black_hole_bomb_cleanup( grenade, model );

				if( IsDefined( level._black_hole_bomb_poi_override ) ) // allows pois to be ignored immediately by ai
				{
					model thread [[level._black_hole_bomb_poi_override]]();
				}

				model create_zombie_point_of_interest( max_attract_dist, num_attractors, 0, true, level.black_hole_bomb_poi_initial_attract_func, level.black_hole_bomb_poi_arrival_attract_func );
				model SetClientFlag( level._SCRIPTMOVER_CLIENT_FLAG_BLACKHOLE );
				grenade thread do_black_hole_bomb_sound( model, info ); // WW: This might not work if it is based on the model
				level thread black_hole_bomb_teleport_init( grenade );
				grenade.is_valid = true;
				level notify("attractor_positions_generated");
			}
			else
			{
				self.script_noteworthy = undefined;
				level thread black_hole_bomb_stolen_by_sam( self, model );
			}
		}
		else
		{
			self.script_noteworthy = undefined;
			level thread black_hole_bomb_stolen_by_sam( self, model );
		}
	}
}

black_hole_bomb_cleanup( parent, model )
{
	model endon( "sam_stole_it" );

	// pass this in to the corpse collector for corpse deleting
	grenade_org = parent.origin;

	while( true )
	{
		if( !IsDefined( parent ) )
		{
			if( IsDefined( model ) )
			{
				model Delete();

				level notify("attractor_positions_generated");

				//level thread anims_test();

				wait_network_frame();
			}
			break;
		}

		wait( 0.05 );
	}

	level thread black_hole_bomb_corpse_collect( grenade_org );
}

anims_test()
{
	wait 1;

	zombs = GetAiSpeciesArray("axis");
	for(i=0;i<zombs.size;i++)
	{
		if(IsSubStr(zombs[i] black_hole_bomb_store_movement_anim(), "fast_pull"))
		{
			iprintln("anim didnt switch");
		}
	}
}

// -- causes the zombie to react to the black hole, controls walk cycles, marks zombie for black hole death
black_hole_bomb_initial_attract_func( ent_poi )
{
	self endon( "death" );
	//self endon( "zombie_acquire_enemy" );
	//self endon( "bad_path" );
	//self endon( "path_timer_done" );

	if( IsDefined( self.pre_black_hole_bomb_run_combatanim ) )
	{
		return;
	}

	if(self.animname == "astro_zombie")
	{
		return;
	}

	if( IsDefined( self.script_string ) && self.script_string == "riser" )
	{
		while( is_true( self.in_the_ground ) )
		{
			wait( 0.05 );
		}
	}

	soul_spark_end = ent_poi.origin;

	soul_burst_range = 50*50;
	pulled_in_range = 128*128;
	inner_range = 1024*1024;
	outer_edge = 2056*2056;
	distance_to_black_hole = 100000*100000;

	self._distance_to_black_hole = 100000*100000; // set default dist
	self._black_hole_bomb_collapse_death = 0; // am i supposed to die when the bhb collapses
	self._black_hole_attract_walk = 0; // have I been given a random walk yet?
	self._black_hole_attract_run = 0; // have I been given a random run yet?
	self._current_black_hole_bomb_origin = ent_poi.origin; // where is the black hole i'm going to?
	self._normal_run_blend_time = 0.2; // hard coded in the zombie_run.gsc, need to store it for resetting
	self._black_hole_bomb_tosser = ent_poi._black_hole_bomb_player; // the player who threw the weapon, damage awards points properly
	self._black_hole_bomb_being_pulled_in_fx = 0;
	self.deathanim = self black_hole_bomb_death_while_attracted(); // the special death anim for when being pulled backwards
	if( !IsDefined( self._bhb_ent_flag_init ) )
	{
		self ent_flag_init( "bhb_anim_change" ); // have i been told to change my movement anim?
		self._bhb_ent_flag_init = 1;
	}

	// save original movement animation
	if( !IsDefined( self.pre_black_hole_bomb_run_combatanim ) )
	{
		self.pre_black_hole_bomb_run_combatanim = self black_hole_bomb_store_movement_anim();
	}

	if( IsDefined( level._black_hole_attract_override ) )
	{
		level [ [ level._black_hole_attract_override ] ]();
	}

	while( IsDefined( ent_poi ) )
	{
		self._distance_to_black_hole = DistanceSquared( self.origin, self._current_black_hole_bomb_origin );

		// on the ouside of the pull go slow -- walk
		if( self._black_hole_attract_walk == 0 && ( self._distance_to_black_hole < outer_edge && self._distance_to_black_hole > inner_range ) )
		{
			if( IsDefined( self._bhb_walk_attract ) )
			{
				self [[ self._bhb_walk_attract ]]();
			}
			else
			{
				self black_hole_bomb_attract_walk();
			}

		}

		// inside the inner range cause the pull the be greater -- run
		if( self._black_hole_attract_run == 0 && ( self._distance_to_black_hole < inner_range && self._distance_to_black_hole > pulled_in_range ) )
		{
			if( IsDefined( self._bhb_run_attract ) )
			{
				self [[ self._bhb_run_attract ]]();
			}
			else
			{
				self black_hole_bomb_attract_run();
			}

		}

		if( ( self._distance_to_black_hole < pulled_in_range ) && ( self._distance_to_black_hole > soul_burst_range ) ) // middle point, change to no feet on ground pull
		{
			self._black_hole_bomb_collapse_death = 1;
			if( IsDefined( self._bhb_horizon_death ) )
			{
				self [[ self._bhb_horizon_death ]]( self._current_black_hole_bomb_origin, ent_poi );
			}
			else
			{
				self black_hole_bomb_event_horizon_death( self._current_black_hole_bomb_origin, ent_poi );
			}

		}

		if( self._distance_to_black_hole < soul_burst_range ) // too close, time to die
		{
			self._black_hole_bomb_collapse_death = 1;
			if( IsDefined( self._bhb_horizon_death ) )
			{
				self [[ self._bhb_horizon_death ]]( self._current_black_hole_bomb_origin, ent_poi );
			}
			else
			{
				self black_hole_bomb_event_horizon_death( self._current_black_hole_bomb_origin, ent_poi );
			}
		}

		wait( 0.05 );
	}

	// zombie wasn't sucked in to the hole before it collapsed, put him back to normal.
	self thread black_hole_bomb_escaped_zombie_reset();
}

// -- decides which pulled in anim should be played
black_hole_bomb_attract_walk()
{
	self endon( "death" );

	//flag_wait( "bhb_anim_change_allowed" );  // permission for adding to the array
	//level._black_hole_bomb_zombies_anim_change = add_to_array( level._black_hole_bomb_zombies_anim_change, self, false ); // no dupes allowed

	// wait for permission to change anim
	//self ent_flag_wait( "bhb_anim_change" );

	self.a.runBlendTime = 0.9;
	self clear_run_anim();

	if( self.has_legs )
	{
		rand =  RandomIntRange( 1, 4 );

		self.needs_run_update = true;
		self._had_legs = true;

		self set_run_anim( "slow_pull_"+rand );
		self.run_combatanim = level.scr_anim["zombie"]["slow_pull_"+rand];
		self.crouchRunAnim = level.scr_anim["zombie"]["slow_pull_"+rand];
		self.crouchrun_combatanim = level.scr_anim["zombie"]["slow_pull_"+rand];
	}
	else // if they have no legs then they are a crawler
	{
		rand = RandomIntRange( 1, 3 );

		self.needs_run_update = true;
		self._had_legs = false;

		self set_run_anim( "crawler_slow_pull_"+rand );
		self.run_combatanim = level.scr_anim["zombie"]["crawler_slow_pull_"+rand];
		self.crouchRunAnim = level.scr_anim["zombie"]["crawler_slow_pull_"+rand];
		self.crouchrun_combatanim = level.scr_anim["zombie"]["crawler_slow_pull_"+rand];
	}

	if ( is_true( self.nogravity ) )
	{
		self AnimMode( "none" );
		self.nogravity = undefined;
	}

	self._black_hole_attract_walk = 1;
	self._bhb_change_anim_notified = 1;
	self.a.runBlendTime = self._normal_run_blend_time;
}

// chance that zombies will suddenly be pulled in faster, that way they aren't all going the same speed
black_hole_bomb_attract_run()
{
	self endon( "death" );

	// there are three fast pulls for zombies and legless so this random can happen here
	rand = RandomIntRange( 1, 4 );

	//flag_wait( "bhb_anim_change_allowed" ); // permission for adding to the array
	//level._black_hole_bomb_zombies_anim_change = add_to_array( level._black_hole_bomb_zombies_anim_change, self, false ); // no dupes allowed

	// wait for permission to change anim
	//self ent_flag_wait( "bhb_anim_change" );

	self.a.runBlendTime = 0.9;
	self clear_run_anim();

	if( self.has_legs )
	{
		self.needs_run_update = true;

		self set_run_anim( "fast_pull_" + rand );
		self.run_combatanim = level.scr_anim["zombie"]["fast_pull_" + rand];
		self.crouchRunAnim = level.scr_anim["zombie"]["fast_pull_" + rand];
		self.crouchrun_combatanim = level.scr_anim["zombie"]["fast_pull_" + rand];
	}
	else
	{
		self.needs_run_update = true;

		self set_run_anim( "crawler_fast_pull_" + rand );
		self.run_combatanim = level.scr_anim["zombie"]["crawler_fast_pull_" + rand];
		self.crouchRunAnim = level.scr_anim["zombie"]["crawler_fast_pull_" + rand];
		self.crouchrun_combatanim = level.scr_anim["zombie"]["crawler_fast_pull_" + rand];
	}

	if ( is_true( self.nogravity ) )
	{
		self AnimMode( "none" );
		self.nogravity = undefined;
	}

	self._black_hole_attract_run = 1;
	self._bhb_change_anim_notified = 1;
	self.a.runBlendTime = self._normal_run_blend_time;
}

// -- causes death once the ai reaches goal
black_hole_bomb_arrival_attract_func( ent_poi )
{
	self endon( "death" );
	self endon( "zombie_acquire_enemy" );
	//self endon( "bad_path" );
	self endon( "path_timer_done" );

	if(self.animname == "astro_zombie")
	{
		return;
	}

	soul_spark_end = ent_poi.origin;

	// once goal hits the ai is at their poi and should die
	self waittill( "goal" );

	/*if(!IsDefined(ent_poi))
	{
		return;
	}*/

	self._black_hole_bomb_collapse_death = 1;
	if( IsDefined( self._bhb_horizon_death ) )
	{
		self [[ self._bhb_horizon_death ]]( self._current_black_hole_bomb_origin, ent_poi );
	}
	else
	{
		self black_hole_bomb_event_horizon_death( self._current_black_hole_bomb_origin, ent_poi );
	}

}

// -- special marked for event horizon collapse death
black_hole_bomb_event_horizon_death( vec_black_hole_org, grenade )
{
	self endon( "death" );

	if(!IsDefined(grenade))
	{
		level notify("attractor_positions_generated");
		return;
	}

	self maps\_zombiemode_spawner::zombie_eye_glow_stop();
	self playsound ("wpn_gersh_device_kill");

	//self ClearClientFlag( level._ACTOR_CLIENT_FLAG_BLACKHOLE );
	//wait_network_frame();

	pulled_in_anim = black_hole_bomb_death_anim();

	// self.deathanim = black_hole_bomb_death_anim();
	self AnimScripted( "pulled_in_complete", self.origin, self.angles, pulled_in_anim );
	self waittill_either( "bhb_burst", "pulled_in_complete" );

	// soul destroy fx
	PlayFXOnTag( level._effect[ "black_hole_bomb_zombie_destroy" ], self, "tag_origin" );

	grenade notify( "black_hole_bomb_kill" );

	self DoDamage( self.health + 50, self.origin + ( 0, 0, 50 ), self._black_hole_bomb_tosser, undefined, "crush" );
}

// -- zombies that don't get caught in the event horizon go back to normal
black_hole_bomb_escaped_zombie_reset()
{
	self endon( "death" );

	//flag_wait( "bhb_anim_change_allowed" );  // permission for adding to the array
	//level._black_hole_bomb_zombies_anim_change = add_to_array( level._black_hole_bomb_zombies_anim_change, self, false ); // no dupes allowed

	// wait for permission to change anim
	//self ent_flag_wait( "bhb_anim_change" );

	// need the new fx before running these functions again
	// clear the flag that causes the back sparks
	//self ClearClientFlag( level._ACTOR_CLIENT_FLAG_BLACKHOLE );
	//wait_network_frame();

	// set a high blend time to switch back to the right run cycle
	self.a.runBlendTime = 0.9;
	self clear_run_anim();

	self.needs_run_update = true;

	// reset the right run anim
	// Zombies can turn in to crawlers while being pulled in, the variable on the zombie "._had_legs" will tell you if they had them when the
	// pull in started and the animation changed. In this situation if they get away from the bomb they need to take on a new crawler animation
	if( !self.has_legs ) // if the zombie had legs then lost them during pull in but still escaped
	{
		// WW (01/17/11): Issue 75171 - Legless zombies play quad animations after black hole bomb. Due to the different legless animation
		// naming I grabbed anims that should play on quads or should no longer be called in game. JZ has shown me which anims are correct and
		// their proper speeds, now each movement speed will create a quick array of acceptable animations.
		// pick a new random crawler movement for the legless zombie

		// walk - there are four legless walk animations
		legless_walk_anims = [];
		legless_walk_anims = add_to_array( legless_walk_anims, "crawl1", false );
		legless_walk_anims = add_to_array( legless_walk_anims, "crawl5", false );
		legless_walk_anims = add_to_array( legless_walk_anims, "crawl_hand_1", false );
		legless_walk_anims = add_to_array( legless_walk_anims, "crawl_hand_2", false );
		rand_walk_anim = RandomInt( legless_walk_anims.size );

		// run
		// there is only one legless run animations, so there is no point in randomizing an array

		// sprint
		// there are three legless sprint animations
		legless_sprint_anims = [];
		legless_sprint_anims = add_to_array( legless_sprint_anims, "crawl2", false );
		legless_sprint_anims = add_to_array( legless_sprint_anims, "crawl3", false );
		legless_sprint_anims = add_to_array( legless_sprint_anims, "crawl_sprint1", false );
		rand_sprint_anim = RandomInt( legless_sprint_anims.size );

		if( self.zombie_move_speed == "walk" )
		{
			self set_run_anim( legless_walk_anims[ rand_walk_anim ] );
			self.run_combatanim = level.scr_anim[ self.animname ][ legless_walk_anims[ rand_walk_anim ] ];
			self.crouchRunAnim = level.scr_anim[ self.animname ][ legless_walk_anims[ rand_walk_anim ] ];
			self.crouchrun_combatanim = level.scr_anim[ self.animname ][ legless_walk_anims[ rand_walk_anim ] ];
		}
		else if( self.zombie_move_speed == "run" )
		{
			// run
			// there is only one legless zombie run
			self set_run_anim( "crawl4" );
			self.run_combatanim = level.scr_anim[ self.animname ][ "crawl4" ];
			self.crouchRunAnim = level.scr_anim[ self.animname ][ "crawl4" ];
			self.crouchrun_combatanim = level.scr_anim[ self.animname ][ "crawl4" ];
		}
		else if( self.zombie_move_speed == "sprint" )
		{
			self set_run_anim( legless_sprint_anims[ rand_sprint_anim ] );
			self.run_combatanim = level.scr_anim[ self.animname ][ legless_sprint_anims[ rand_sprint_anim ] ];
			self.crouchRunAnim = level.scr_anim[ self.animname ][ legless_sprint_anims[ rand_sprint_anim ] ];
			self.crouchrun_combatanim = level.scr_anim[ self.animname ][ legless_sprint_anims[ rand_sprint_anim ] ];
		}
		else // in this case the self.zombie_move_speed was not working for some reason
		{
			// run - default in case there is an issue figuring out the movement speed
			self set_run_anim( "crawl4" );
			self.run_combatanim = level.scr_anim[ self.animname ][ "crawl4" ];
			self.crouchRunAnim = level.scr_anim[ self.animname ][ "crawl4" ];
			self.crouchrun_combatanim = level.scr_anim[ self.animname ][ "crawl4" ];
		}
	}
	else // the zombie was either a crawler or a walker before the pull in animation change, the anim stored on them should still be valid
	{
		self set_run_anim( self.pre_black_hole_bomb_run_combatanim );
		self.run_combatanim = level.scr_anim[ self.animname ][ self.pre_black_hole_bomb_run_combatanim ];
		self.crouchRunAnim = level.scr_anim[ self.animname ][ self.pre_black_hole_bomb_run_combatanim ];
		self.crouchrun_combatanim = level.scr_anim[ self.animname ][ self.pre_black_hole_bomb_run_combatanim ];
	}

	// reset all variables for the black hole in case this zombie gets attracted again
	self.pre_black_hole_bomb_run_combatanim = undefined;
	self._black_hole_attract_walk = 0;
	self._black_hole_attract_run = 0;
	self._bhb_change_anim_notified = 1;
	self._black_hole_bomb_being_pulled_in_fx = 0;
	self.a.runBlendTime = self._normal_run_blend_time;

	which_anim = RandomInt( 10 ); // random number for choosing which death anim to use
	if( self.has_legs ) // if the zombie has legs apply one of the two leg deaths
	{
		if( which_anim > 5 ) // greater than 5 means this anim
		{
			self.deathanim = level.scr_anim[self.animname]["death1"];
		}
		else // less than 5
		{
			self.deathanim = level.scr_anim[self.animname]["death2"];
		}
	}
	else // legless zombies will use these anims for death after escaping
	{
		if( which_anim > 5 ) // great than 5 means first anim
		{
			self.deathanim = level.scr_anim[self.animname]["death3"];
		}
		else // less than 5 means second anim
		{
			self.deathanim = level.scr_anim[self.animname]["death4"];
		}
	}

	self._had_legs = undefined;
	self._bhb_ent_flag_init = 0;

	// run anim doesn't always switch for some reason, if we keep setting self.needs_run_update to true it will eventually change
	for(i=0;i<30;i++)
	{
		wait_network_frame();
		self.needs_run_update = true;
	}
}

// if the player throws it to an unplayable area samantha steals it
black_hole_bomb_stolen_by_sam( ent_grenade, ent_model )
{
	if( !IsDefined( ent_model ) )
	{
		return;
	}

	//ent_grenade notify( "sam_stole_it" );

	ent_model UnLink();

	if(IsDefined(ent_grenade))
	{
		ent_grenade resetmissiledetonationtime();
	}

	direction = ent_model.origin;
	direction = (direction[1], direction[0], 0);

	if(direction[1] < 0 || (direction[0] > 0 && direction[1] > 0))
	{
		direction = (direction[0], direction[1] * -1, 0);
	}
	else if(direction[0] < 0)
	{
		direction = (direction[0] * -1, direction[1], 0);
	}

	if( is_true( level.player_4_vox_override ) )
	{
		ent_model playsound( "zmb_laugh_rich" );
	}
	else
	{
		ent_model playsound( "zmb_laugh_child" );
	}

	// play the fx on the model
	PlayFXOnTag( level._effect[ "black_hole_samantha_steal" ], ent_model, "tag_origin" );

	// raise the model
	ent_model MoveZ( 60, 1.0, 0.25, 0.25 );

	// spin it
	ent_model Vibrate( direction, 1.5,  2.5, 1.0 );
	ent_model waittill( "movedone" );

	// delete it
	ent_model Delete();

}
