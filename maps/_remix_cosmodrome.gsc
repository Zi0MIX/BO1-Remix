remix_main()
{
    level thread maps\_remix_zombiemode_utility::special_round_watcher();
	level.machine_damage_max = 10;
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
	include_weapon( "zombie_black_hole_bomb", true, false, maps\_zombiemode_weapons::default_zombie_black_hole_bomb_weighting_func );
	include_weapon( "zombie_nesting_dolls", true, false );
	include_weapon( "ray_gun_zm", true, false, maps\_zombiemode_weapons::default_ray_gun_weighting_func );
	include_weapon( "ray_gun_upgraded_zm", false );
	include_weapon( "thundergun_zm", true, false, maps\_remix_zombiemode_weapons::default_wonder_weapon_weighting_func );
	include_weapon( "thundergun_upgraded_zm", false );
	include_weapon( "crossbow_explosive_zm" );
	include_weapon( "crossbow_explosive_upgraded_zm", false );

	// Custom Weapons
	include_weapon( "ppsh_zm" );
	include_weapon( "ppsh_upgraded_zm", false );
	include_weapon( "stoner63_zm" );
	include_weapon( "stoner63_upgraded_zm",false );
	include_weapon( "ak47_zm" );
 	include_weapon( "ak47_upgraded_zm", false);

	include_weapon( "knife_ballistic_zm", true );
	include_weapon( "knife_ballistic_upgraded_zm", false );
	include_weapon( "knife_ballistic_sickle_zm", false );
	include_weapon( "knife_ballistic_sickle_upgraded_zm", false );
	level._uses_retrievable_ballisitic_knives = true;

	// limited weapons
	maps\_zombiemode_weapons::add_limited_weapon( "m1911_zm", 0 );
	maps\_zombiemode_weapons::add_limited_weapon( "thundergun_zm", 1 );
	maps\_zombiemode_weapons::add_limited_weapon( "crossbow_explosive_zm", 1 );
	maps\_zombiemode_weapons::add_limited_weapon( "knife_ballistic_zm", 1 );
	maps\_zombiemode_weapons::add_limited_weapon( "zombie_nesting_dolls", 1 );

	precacheItem( "explosive_bolt_zm" );
	precacheItem( "explosive_bolt_upgraded_zm" );

	// get the sickle into the collector achievement list
	level.collector_achievement_weapons = array_add( level.collector_achievement_weapons, "sickle_knife_zm" );
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
	//include_powerup( "carpenter" );
	include_powerup( "fire_sale" );

	// minigun
	PreCacheItem( "minigun_zm" );

	include_powerup( "minigun" );
	include_powerup( "free_perk" );
}

cosmodrome_zone_init()
{
	// Set flags here for your starting zone if there are any zones that need to be connected from the beginning.
	// For instance, if your
	flag_init( "centrifuge" );
	flag_set( "centrifuge" );

	// Special init for the graveyard
	//add_adjacent_zone( "graveyard_zone",	"graveyard_lander",	"no_mans_land" );


	//############################################
	// GROUPS: Defining self-contained areas that will always connect when activated
	//	Do not put zones that connect through doorways here.
	//	YOU SHOULD NOT BE CALLING add_zone_flags in this section.
	//############################################

	// Base entrance lander
	add_adjacent_zone( "access_tunnel_zone",	"base_entry_zone",			"base_entry_group" );

	// Storage area
	add_adjacent_zone( "storage_zone2",			"storage_zone",			"storage_group", true );

	// Power Building
	add_adjacent_zone( "power_building",		"base_entry_zone2",			"power_group" );

	// Drop-off connection - top of stairs in north path (one way drop)
	add_adjacent_zone( "roof_connector_zone",		"north_path_zone",  	"roof_connector_dropoff", true );

	// open blast doors.
	add_adjacent_zone( "north_path_zone",		"under_rocket_zone",		"rocket_group" );
	add_adjacent_zone( "control_room_zone",		"under_rocket_zone",		"rocket_group" );

	//############################################
	//	Now set the connections that need to be made based on doors being open
	//	Use add_zone_flags to connect any zones defined above.
	//############################################
	add_adjacent_zone( "centrifuge_zone",	"centrifuge_zone2",		"centrifuge");

	// Centrifuge door 1st floor towards power
	add_adjacent_zone( "centrifuge_zone",	"centrifuge2power_zone",		"centrifuge2power" );
	add_adjacent_zone( "centrifuge_zone2",	"centrifuge2power_zone",		"centrifuge2power" );


	// Door at 1st floor of power building
	add_adjacent_zone( "base_entry_zone2",	"centrifuge2power_zone",		"power2centrifuge" );
	add_zone_flags(	"power2centrifuge",										"power_group" );

	// Side Tunnel to Centrifuge
	add_adjacent_zone( "access_tunnel_zone",	"centrifuge_zone",			"tunnel_centrifuge_entry" );
	add_zone_flags(	"tunnel_centrifuge_entry",								"base_entry_group" );

	// Base Entrance
	add_adjacent_zone( "base_entry_zone",		"base_entry_zone2",			"base_entry_2_power" );
	add_zone_flags(	"base_entry_2_power",									"base_entry_group" );
	add_zone_flags(	"base_entry_2_power",									"power_group" );

	// Power Building
 	add_adjacent_zone( "power_building",		"power_building_roof",		"power_interior_2_roof" );
	add_zone_flags(	"power_interior_2_roof",								"power_group" );

	// Door from catwalks to connector zone
	add_adjacent_zone( "north_catwalk_zone3",	"north_catwalk_zone3",		"catwalks_2_shed" );//"roof_connector_zone"
	add_zone_flags(	"catwalks_2_shed",										"roof_connector_dropoff" );

	// Tunnel to Storage
	add_adjacent_zone( "access_tunnel_zone",	"storage_zone",				"base_entry_2_storage" );
	//add_adjacent_zone( "access_tunnel_zone",	"storage_zone2",			"base_entry_2_storage" );
	add_zone_flags(	"base_entry_2_storage",									"storage_group" );
	add_zone_flags(	"base_entry_2_storage",									"base_entry_group" );

	// Storage Lander
	//add_adjacent_zone( "storage_lander_zone",	"storage_zone",				"storage_lander_area" );
	add_adjacent_zone( "storage_lander_zone",	"storage_zone2",	"storage_lander_area"	, true );
	//add_adjacent_zone( "storage_lander_zone",	"access_tunnel_zone",		"storage_lander_area" );

	// Northern passageway to rocket
	add_adjacent_zone( "north_path_zone",		"base_entry_zone2",			"base_entry_2_north_path");
	add_zone_flags(	"base_entry_2_north_path",								"power_group" );
	add_zone_flags(	"base_entry_2_north_path",								"roof_connector_dropoff" );
	//add_zone_flags(	"base_entry_2_north_path",								"control_room" );

	// Power Building to Catwalks
	add_adjacent_zone( "power_building_roof",	"roof_connector_zone",		"power_catwalk_access" );
	add_zone_flags(	"power_catwalk_access",									"roof_connector_dropoff" );

}
