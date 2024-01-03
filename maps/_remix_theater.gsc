remix_main()
{
    level thread maps\_remix_zombiemode_utility::special_round_watcher();
	level thread maps\_custom_hud::box_notifier();

	level.shrink_zones = ::shrink_zone;
	level.spawners_to_remove = remove_spawners();
	level.random_spawners = true;

}

disable_doors()
{
	zombie_doors = GetEntArray( "zombie_door", "targetname" );
	for( i = 0; i < zombie_doors.size; i++ )
    {
    	if(zombie_doors[i].target == "foyer_top_door")
    	{
    		zombie_doors[i] trigger_off();
    	}

    	if(zombie_doors[i].target == "alley_door2")
    	{
    		zombie_doors[i] trigger_off();
    	}

    	if(zombie_doors[i].target == "backstage_door")
    	{
    		zombie_doors[i] trigger_off();
    	}

    	if(zombie_doors[i].target == "vip_top_door")
    	{
    		zombie_doors[i] trigger_off();
    	}
    }
}

shrink_zone( zone_name )
{
	// zone = level.zones[zone_name];
	// iPrintLn(zone_name);

	// Disable double tap window while in hell room
	if (isdefined(zone_name) && zone_name == "alleyway_zone")
	{
		if (level.zones["crematorium_zone"].is_occupied || level.zones["alleyway_zone"].is_occupied)
		{
			// iPrintLn("OCCUPIED");
			return level.zones[zone_name].num_spawners;
		}
		// iPrintLn("2");
		return 2;
	}
	else
	{
		// iPrintLn("PASS");
		return level.zones[zone_name].num_spawners;
	}
}

remove_spawners()
{
	// Double tap window
	return array(1);
}

wait_for_power()
{
	master_switch = getent("elec_switch","targetname");
	master_switch notsolid();

	flag_wait( "power_on" );

	trig = getent("use_elec_switch","targetname");
	trig delete();

	master_switch rotateroll(-90,.3);
	master_switch playsound("zmb_switch_flip");

	clientnotify( "ZPO" );		// Zombie power on.

	master_switch waittill("rotatedone");
	playfx(level._effect["switch_sparks"] ,getstruct("elec_switch_fx","targetname").origin);

	//Sound - Shawn J  - adding temp sound to looping sparks & turning on power sources
	master_switch playsound("zmb_turn_on");

	//get the teleporter ready
	maps\zombie_theater_teleporter::teleporter_init();
	wait_network_frame();
	// Set Perk Machine Notifys
	level notify("revive_on");
	wait_network_frame();
	level notify("juggernog_on");
	wait_network_frame();
	level notify("sleight_on");
	wait_network_frame();
	level notify("doubletap_on");
	wait_network_frame();
	level notify("Pack_A_Punch_on" );
	wait_network_frame();

	// start quad round
	// Set number of quads per round
	players = get_players();
	level.quads_per_round = 4 * players.size;	// initial setting

	level notify("quad_round_can_end");
	level.delay_spawners = undefined;

	//maps\zombie_theater_quad::begin_quad_introduction("theater_round");
	//level.round_spawn_func = maps\zombie_theater_quad::Intro_Quad_Spawn;;
	//maps\zombie_theater_quad::Theater_Quad_Round();

	// DCS: start check for potential quad waves after power turns on.
    // Disable redundant check for quad wave
	// level thread quad_wave_init();
}

include_weapons()
{
	include_weapon( "frag_grenade_zm", false, true );
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
	include_weapon( "mp40_zm", false, true );
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
	include_weapon( "zombie_cymbal_monkey", true, false, maps\_zombiemode_weapons::default_cymbal_monkey_weighting_func );
	include_weapon( "ray_gun_zm", true, false, maps\_zombiemode_weapons::default_ray_gun_weighting_func );
	include_weapon( "ray_gun_upgraded_zm", false );
	include_weapon( "thundergun_zm", true, false, maps\_remix_zombiemode_weapons::default_wonder_weapon_weighting_func );
	include_weapon( "thundergun_upgraded_zm", false );
	include_weapon( "crossbow_explosive_zm" );
	include_weapon( "crossbow_explosive_upgraded_zm", false );

	//include_weapon( "tesla_gun_zm", true, false, maps\_zombiemode_weapons::default_tesla_weighting_func );
	//include_weapon( "tesla_gun_upgraded_zm", false );

	include_weapon( "knife_ballistic_zm", true );
	include_weapon( "knife_ballistic_upgraded_zm", false );
	include_weapon( "knife_ballistic_bowie_zm", false );
	include_weapon( "knife_ballistic_bowie_upgraded_zm", false );
	level._uses_retrievable_ballisitic_knives = true;

	// Custom Weapons
	include_weapon( "stoner63_zm" );
 	include_weapon( "ppsh_zm" );
 	include_weapon("stoner63_upgraded_zm", false);
	include_weapon("ppsh_upgraded_zm", false);
	include_weapon( "ak47_zm" );
 	include_weapon( "ak47_upgraded_zm", false);

	// limited weapons
	maps\_zombiemode_weapons::add_limited_weapon( "m1911_zm", 0 );
	maps\_zombiemode_weapons::add_limited_weapon( "thundergun_zm", 1 );
	maps\_zombiemode_weapons::add_limited_weapon( "crossbow_explosive_zm", 1 );
	maps\_zombiemode_weapons::add_limited_weapon( "knife_ballistic_zm", 1 );

	precacheItem( "explosive_bolt_zm" );
	precacheItem( "explosive_bolt_upgraded_zm" );


	// get the bowie into the collector achievement list
	level.collector_achievement_weapons = array_add( level.collector_achievement_weapons, "bowie_knife_zm" );
}

//*****************************************************************************
// POWERUP FUNCTIONS
//*****************************************************************************

include_powerups()
{
	include_powerup( "nuke" );
	include_powerup( "insta_kill" );
	include_powerup( "double_points" );
	include_powerup( "full_ammo" );
	include_powerup( "fire_sale" );

	//PreCacheItem( "minigun_zm" );
	//include_powerup( "minigun" );
}

theater_zone_init()
{
	flag_init( "always_on" );
	flag_set( "always_on" );

	// foyer_zone
	add_adjacent_zone( "foyer_zone", "foyer2_zone", "always_on" );

	add_adjacent_zone( "foyer_zone", "vip_zone", "magic_box_foyer1" );
	add_adjacent_zone( "foyer2_zone", "crematorium_zone", "magic_box_crematorium1" );
	add_adjacent_zone( "crematorium_zone",	"foyer_zone",  "magic_box_crematorium1", true );

	// vip_zone
	add_adjacent_zone( "vip_zone", "dining_zone", "vip_to_dining" );

	// crematorium_zone
	add_adjacent_zone( "crematorium_zone", "alleyway_zone", "magic_box_alleyway1" );

	// dining_zone
	add_adjacent_zone( "dining_zone", "dressing_zone", "dining_to_dressing" );

	// dressing_zone
	add_adjacent_zone( "dressing_zone", "stage_zone", "magic_box_dressing1" );

	// stage_zone
	add_adjacent_zone( "stage_zone", "west_balcony_zone", "magic_box_west_balcony2" );

	// theater_zone
	add_adjacent_zone( "theater_zone", "foyer2_zone", "power_on" );
	add_adjacent_zone( "theater_zone", "stage_zone", "power_on" );

	// west_balcony_zone
	add_adjacent_zone( "west_balcony_zone", "alleyway_zone", "magic_box_west_balcony1" );
}
