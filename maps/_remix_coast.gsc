remix_main()
{
    level endon("end_game");

	level thread override_radius();
	level thread override_max_damage_taken();

	level thread possible_director_watcher();
	level thread just_spawned_exception();

    // Change to disable or enable knifing while having waffe
    level.fix_wunderwaffe = true;
	// Director manager for coop pause
	level.additional_coop_pause_func = maps\_remix_zombiemode_ai_director::director_coop_pause;
	flag_init("director_alive");
	flag_init("potential_director");
}

override_radius()
{
	while (!isDefined(level.director_zombie_scream_a_radius_sq))
		wait 0.05;
	level.director_zombie_scream_a_radius_sq = 512*512; //1024*1024 old
}

override_max_damage_taken()
{
	while (!isDefined(level.director_max_damage_taken_easy))
		wait 0.05;
	level.director_max_damage_taken_easy = 2500;	// 1000 old
}

possible_director_watcher()
{
	while (true)
	{
		level waittill("end_of_round");

		if (isDefined(level.last_director_round) && level.last_director_round > 0)
		{
			if (level.round_number > (level.last_director_round + 1))
				flag_set("potential_director");

			wait 15;
			flag_clear("potential_director");
		}
		wait 0.1;
	}
}

just_spawned_exception()
{
	level waittill ("all_players_connected");
	flag_set ("spawn_init");
	wait 15;
	flag_clear ("spawn_init");
}

check_to_set_play_outro_movie()
{
	flag_wait("all_players_connected");

	if ( !level.onlineGame && !level.systemlink )
		SetDvar("ui_playCoastOutroMovie", 0);
}

include_weapons()
{
    include_weapon( "frag_grenade_zm", false );
	include_weapon( "sticky_grenade_zm", false, true );
	include_weapon( "claymore_zm", false, true );

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
	include_weapon( "mpl_zm", false, true );
	include_weapon( "mpl_upgraded_zm", false );
	include_weapon( "pm63_zm", false, true );
	include_weapon( "pm63_upgraded_zm", false );
	include_weapon( "spectre_zm" );
	include_weapon( "spectre_upgraded_zm", false );
	include_weapon( "mp40_zm", false );
	include_weapon( "mp40_upgraded_zm", false );

	//	Weapons - Dual Wield
  	include_weapon( "cz75dw_zm" );
  	include_weapon( "cz75dw_upgraded_zm", false );

	//	Weapons - Shotguns
	include_weapon( "ithaca_zm", false );						// shotgun
	include_weapon( "ithaca_upgraded_zm", false );
	include_weapon( "rottweil72_zm", false);
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
	include_weapon( "ray_gun_zm", true, false, maps\_zombiemode_weapons::default_ray_gun_weighting_func );
	include_weapon( "ray_gun_upgraded_zm", false );
	include_weapon( "crossbow_explosive_zm" );
	include_weapon( "crossbow_explosive_upgraded_zm", false );

	// these are not available yet until their functionality is more complete
	include_weapon( "humangun_zm", true, false, maps\_remix_zombiemode_weapons::default_wonder_weapon_weighting_func );
	include_weapon( "humangun_upgraded_zm", false );
	include_weapon( "sniper_explosive_zm", true, false, maps\_remix_zombiemode_weapons::default_wonder_weapon_weighting_func );
	include_weapon( "sniper_explosive_upgraded_zm", false );
	//include_weapon( "tesla_gun_zm", false );
	//include_weapon( "tesla_gun_upgraded_zm", false );
	include_weapon( "zombie_nesting_dolls", true, false, maps\_zombiemode_weapons::default_cymbal_monkey_weighting_func );

	include_weapon( "knife_ballistic_zm", true );
	include_weapon( "knife_ballistic_upgraded_zm", false );
	include_weapon( "knife_ballistic_sickle_zm", false );
	include_weapon( "knife_ballistic_sickle_upgraded_zm", false );
	level._uses_retrievable_ballisitic_knives = true;

	// Custom weapons
	include_weapon( "ppsh_zm" );
	include_weapon( "ppsh_upgraded_zm", false );
	include_weapon( "stoner63_zm" );
	include_weapon( "stoner63_upgraded_zm", false );
	include_weapon( "ak47_zm" );
 	include_weapon( "ak47_ft_upgraded_zm", false);


	// limited weapons
	maps\_zombiemode_weapons::add_limited_weapon( "m1911_zm", 0 );
//	maps\_zombiemode_weapons::add_limited_weapon( "tesla_gun_zm", 1 );
	maps\_zombiemode_weapons::add_limited_weapon( "humangun_zm", 1 );
	maps\_zombiemode_weapons::add_limited_weapon( "sniper_explosive_zm", 1 );
	maps\_zombiemode_weapons::add_limited_weapon( "crossbow_explosive_zm", 1 );
	maps\_zombiemode_weapons::add_limited_weapon( "knife_ballistic_zm", 1 );
//	maps\_zombiemode_weapons::add_limited_weapon( "zombie_nesting_dolls", 1 );

	precacheItem( "explosive_bolt_zm" );
	precacheItem( "explosive_bolt_upgraded_zm" );
	precacheItem( "sniper_explosive_bolt_zm" );
	precacheItem( "sniper_explosive_bolt_upgraded_zm" );

	// get the sickle into the collector achievement list
	level.collector_achievement_weapons = array_add( level.collector_achievement_weapons, "sickle_knife_zm" );
}

include_powerups()
{
    include_powerup( "nuke" );
	include_powerup( "insta_kill" );
	include_powerup( "double_points" );
	include_powerup( "full_ammo" );
	include_powerup( "fire_sale" );

	// WW (02-04-11): Added minigun
	PreCacheItem( "minigun_zm" );
	include_powerup( "minigun" );

	// WW (03-14-11): Added Tesla
	PreCacheItem( "tesla_gun_zm" );
	include_powerup( "tesla" );

	include_powerup( "free_perk" );
}