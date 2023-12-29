remix_main()
{
    while (!isDefined(level.ai_astro_explode))
        wait 0.05;
	level thread launch_rockets();
}

launch_rockets()
{
	flag_wait("power_on");

	wait(5);

	level notify("rl");

	wait(2);

	level notify("rl");

	wait(2);

	level notify("rl");

	wait(10);

	level notify("rl");

	wait(30);
	wait(30);

	play_sound_2d( "evt_earth_explode" );

	clientnotify("dte");
	wait_network_frame();
	wait_network_frame();
	exploder( 2012 );
	wait(2);
	level clientnotify("SDE");

	play_sound_2d( "vox_xcomp_quest_laugh" );
}

moon_round_think_func()
{
	for( ;; )
	{
		if (isdefined(level.left_nomans_land))
		{
			level.zombie_move_speed = 105;
		}

		maxreward = 50 * level.round_number;
		if ( maxreward > 500 )
		maxreward = 500;
		level.zombie_vars["rebuild_barrier_cap_per_round"] = maxreward;

		level.pro_tips_start_time = GetTime();
		level.zombie_last_run_time = GetTime();	// Resets the last time a zombie ran

		level thread maps\_zombiemode_audio::change_zombie_music( "round_start" );

		if(level.moon_startmap == true)
		{
			level.moon_startmap = false;
			level thread maps\_zombiemode::play_level_start_vox_delayed();
			wait(3); // time that would have been for round text and init spawning.
		}
		else
		{
			maps\_zombiemode::chalk_one_up();
		}

		maps\_zombiemode_powerups::powerup_round_start();

		players = get_players();
		array_thread( players, maps\_zombiemode_blockers::rebuild_barrier_reward_reset );

		// only give grenades when not returning from NML.
		if(!flag("teleporter_used") || level.first_round == true)
		{
			level thread maps\_zombiemode::award_grenades_for_survivors();
		}

		bbPrint( "zombie_rounds: round %d player_count %d", level.round_number, players.size );

		level.round_start_time = GetTime();
		level thread [[level.round_spawn_func]]();

		level notify( "start_of_round" );

		// returning from earth: restore the zombie total if there were zombies remaining when you left
		if(flag("teleporter_used"))
		{
			flag_clear("teleporter_used");
			if ( level.prev_round_zombies != 0)
			{
				level.zombie_total = level.prev_round_zombies;
			}
		}

		[[level.round_wait_func]]();

		level.first_round = false;
		level notify( "end_of_round" );
		flag_set("between_rounds");

		UploadStats();

		if(!flag("teleporter_used"))
		{
			level thread maps\_zombiemode_audio::change_zombie_music( "round_end" );

			if ( 1 != players.size )
			{
				level thread maps\_zombiemode::spectators_respawn();
			}
		}

		level maps\_zombiemode::chalk_round_over();

		// here's the difficulty increase over time area
		timer = level.zombie_vars["zombie_spawn_delay"];
		if ( timer > 0.08 )
		{
			level.zombie_vars["zombie_spawn_delay"] = timer * 0.95;
		}
		else if ( timer < 0.08 )
		{
			level.zombie_vars["zombie_spawn_delay"] = 0.08;
		}

		// level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier"];

		// DCS 062811: if used teleporter to advance round stay at old round number.
		if(flag("teleporter_used"))
		{
			// restore the zombie total if there were zombies remaining when you left
			if ( level.prev_round_zombies != 0 && !flag("enter_nml") )
			{
				level.round_number = level.nml_last_round;
			}
		}
		else
		{
			level.round_number++;
		}

		level notify( "between_round_over" );
		flag_clear("between_rounds");

	}
}

include_weapons()
{
	include_weapon( "frag_grenade_zm", false );
	include_weapon( "sticky_grenade_zm", false );
	include_weapon( "claymore_zm", false );


	//	Weapons - Pistols
	include_weapon( "m1911_zm", false );						// colt
	include_weapon( "m1911_upgraded_zm", false );
	include_weapon( "python_zm", false );						// 357
	include_weapon( "python_upgraded_zm", false );
  	include_weapon( "cz75_zm" );
  	include_weapon( "cz75_upgraded_zm", false );

	//	Weapons - Semi-Auto Rifles
	include_weapon( "m14_zm", false, true );							// gewehr43
	include_weapon( "m14_upgraded_zm", false );

	//	Weapons - Burst Rifles
	include_weapon( "m16_zm", false, true );
	include_weapon( "m16_gl_upgraded_zm", false );
	include_weapon( "g11_lps_zm" );
	include_weapon( "g11_lps_upgraded_zm", false );
	include_weapon( "famas_zm" );
	include_weapon( "famas_upgraded_zm", false );

	//	Weapons - SMGs
	include_weapon( "ak74u_zm", false, true );						// thompson, mp40, bar
	include_weapon( "ak74u_upgraded_zm", false );
	include_weapon( "mp5k_zm", false, true );
	include_weapon( "mp5k_upgraded_zm", false );
	include_weapon( "mp40_zm", false );
	include_weapon( "mp40_upgraded_zm", false );
	include_weapon( "mpl_zm", false, true );
	include_weapon( "mpl_upgraded_zm", false );
	include_weapon( "pm63_zm", false, true );
	include_weapon( "pm63_upgraded_zm", false );
	include_weapon( "spectre_zm" );
	include_weapon( "spectre_upgraded_zm", false );

	//	Weapons - Dual Wield
  	include_weapon( "cz75dw_zm" );
  	include_weapon( "cz75dw_upgraded_zm", false );

	//	Weapons - Shotguns
	include_weapon( "ithaca_zm", false, true );						// shotgun
	include_weapon( "ithaca_upgraded_zm", false );
	include_weapon( "rottweil72_zm", false, true );
	include_weapon( "rottweil72_upgraded_zm", false );
	include_weapon( "spas_zm", false );						//
	include_weapon( "spas_upgraded_zm", false );
	include_weapon( "hs10_zm", false );
	include_weapon( "hs10_upgraded_zm", false );

	//	Weapons - Assault Rifles
	include_weapon( "aug_acog_zm" );
	include_weapon( "aug_acog_mk_upgraded_zm", false );
	include_weapon( "galil_zm" );
	include_weapon( "galil_upgraded_zm", false );
	include_weapon( "commando_zm" );
	include_weapon( "commando_upgraded_zm", false );
	include_weapon( "fnfal_zm", false );
	include_weapon( "fnfal_upgraded_zm", false );

	//	Weapons - Sniper Rifles
	include_weapon( "dragunov_zm", false );					// ptrs41
	include_weapon( "dragunov_upgraded_zm", false );
	include_weapon( "l96a1_zm", false );
	include_weapon( "l96a1_upgraded_zm", false );

	//	Weapons - Machineguns
	include_weapon( "rpk_zm" );							// mg42, 30 cal, ppsh
	include_weapon( "rpk_upgraded_zm", false );
	include_weapon( "hk21_zm" );
	include_weapon( "hk21_upgraded_zm", false );

	//	Weapons - Misc
	include_weapon( "m72_law_zm" );
	include_weapon( "m72_law_upgraded_zm", false );
	include_weapon( "china_lake_zm", false );
	include_weapon( "china_lake_upgraded_zm", false );

	//	Weapons - Special
	include_weapon( "knife_ballistic_zm", true );
	include_weapon( "knife_ballistic_upgraded_zm", false );
	include_weapon( "knife_ballistic_bowie_zm", false );
	include_weapon( "knife_ballistic_bowie_upgraded_zm", false );
	level._uses_retrievable_ballisitic_knives = true;

	//	Weapons - Special
	include_weapon( "zombie_black_hole_bomb", true, false, maps\_zombiemode_weapons::default_zombie_black_hole_bomb_weighting_func );
	include_weapon( "ray_gun_zm", true, false, maps\_zombiemode_weapons::default_ray_gun_weighting_func );
	include_weapon( "ray_gun_upgraded_zm", false );
	include_weapon( "zombie_quantum_bomb" );
	include_weapon( "microwavegundw_zm", true, false, maps\_zombiemode_weapons::default_wonder_weapon_weighting_func );
	include_weapon( "microwavegundw_upgraded_zm", false );

	// Custom Weapons
	include_weapon( "stoner63_zm" );
 	include_weapon( "ppsh_zm" );
 	include_weapon("stoner63_upgraded_zm", false);
	include_weapon("ppsh_upgraded_zm", false);
	include_weapon( "ak47_zm" );
 	include_weapon( "ak47_upgraded_zm", false);

	// limited weapons
	maps\_zombiemode_weapons::add_limited_weapon( "m1911_zm", 0 );
	maps\_zombiemode_weapons::add_limited_weapon( "knife_ballistic_zm", 1 );
	maps\_zombiemode_weapons::add_limited_weapon( "microwavegundw_zm", 1 );

	// get the bowie into the collector achievement list
	level.collector_achievement_weapons = array_add( level.collector_achievement_weapons, "bowie_knife_zm" );

}

include_powerups()
{
	include_powerup( "nuke" );
	include_powerup( "insta_kill" );
	include_powerup( "double_points" );
	include_powerup( "full_ammo" );
	// include_powerup( "carpenter" );
	include_powerup( "fire_sale" );

	// WW (02-04-11): Added minigun
	PreCacheItem( "minigun_zm" );
	include_powerup( "minigun" );

	include_powerup( "free_perk" );

	// for quantum bomb
	include_powerup( "random_weapon" );
	include_powerup( "bonus_points_player" );
	include_powerup( "bonus_points_team" );
	include_powerup( "lose_points_team" );
	include_powerup( "lose_perk" );
	include_powerup( "empty_clip" );
}
