#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;
#include maps\_zombiemode_utility_raven;
#include maps\_zombiemode_zone_manager;
#include maps\zombie_temple_elevators;
#include maps\zombie_temple_traps;
#include maps\zombie_temple_power;
#include maps\zombie_temple_spawning;
#include maps\zombie_temple_pack_a_punch;

remix_main()
{
    level thread night_mode_watcher();
}

activate_night()
{
	flag_wait("all_players_spawned");
	SetDvar( "night_mode", 1);

    wait 1.8;

    while(1)
    {
	    if( getDvarInt( "night_mode" ) == 1)
		{
			if(getDvarInt( "r_skyTransition") != 1)
			{
				SetSunlight( 0.5426, 0.6538, 0.7657);
				SetSavedDvar("r_lightTweakSunLight", 11);
				SetSavedDvar("r_skyTransition", 1);
			}
		}
		else
		{
			if(getDvarInt( "r_skyTransition") != 0)
			{
				ResetSunlight();
				SetSavedDvar("r_lightTweakSunLight", 13);
				SetSavedDvar("r_skyTransition", 0);
			}
		}
		wait 0.1;
    }
}

night_mode_watcher()
{
	flag_wait("all_players_spawned");
    wait 1.8;

	while(1)
	{
		while(0 == GetDvarInt("night_mode"))
		{
			wait(0.1);
		}
		clientnotify("eclipse");		// Eclipse.

		while(1 == GetDvarInt("night_mode"))
		{
			wait(0.1);
		}
		clientnotify("daybreak");		// Daybreak.
	}
}

include_weapons()
{
	include_weapon( "frag_grenade_zm", false );
	include_weapon( "sticky_grenade_zm", false, true );
	include_weapon( "spikemore_zm", false, true );

	//	Weapons - Pistols
	include_weapon( "m1911_zm", false );						// colt
	include_weapon( "m1911_upgraded_zm", false );
	include_weapon( "python_zm", false );								// 357
	include_weapon( "python_upgraded_zm", false );
	include_weapon( "cz75_zm" );
    include_weapon( "cz75_upgraded_zm", false );

	//	Weapons - Semi-Auto Rifles
	include_weapon( "m14_zm", false, true );					// gewehr43
	include_weapon( "m14_upgraded_zm", false );

	//	Weapons - Burst Rifles
	include_weapon( "m16_zm", false, true );
	include_weapon( "m16_gl_upgraded_zm", false );
	include_weapon( "g11_lps_zm" );
	include_weapon( "g11_lps_upgraded_zm", false );
	include_weapon( "famas_zm" );
	include_weapon( "famas_upgraded_zm", false );

	//	Weapons - SMGs
	include_weapon( "ak74u_zm", false, true );					// thompson, mp40, bar
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
	include_weapon( "ithaca_zm", false, true );					// shotgun
	include_weapon( "ithaca_upgraded_zm", false );
	include_weapon( "rottweil72_zm", false, true );
	include_weapon( "rottweil72_upgraded_zm", false );
	include_weapon( "spas_zm", false );
	include_weapon( "spas_upgraded_zm", false );
	include_weapon( "hs10_zm", false );
	include_weapon( "hs10_upgraded_zm", false );

	//	Weapons - Assault Rifles
	include_weapon( "aug_acog_zm", true );
	include_weapon( "aug_acog_mk_upgraded_zm", false );
	include_weapon( "galil_zm" );
	include_weapon( "galil_upgraded_zm", false );
	include_weapon( "commando_zm" );
	include_weapon( "commando_upgraded_zm", false );
	include_weapon( "fnfal_zm", false );
	include_weapon( "fnfal_upgraded_zm", false );

	//	Weapons - Sniper Rifles
	include_weapon( "dragunov_zm", false );							// ptrs41
	include_weapon( "dragunov_upgraded_zm", false );
	include_weapon( "l96a1_zm", false );
	include_weapon( "l96a1_upgraded_zm", false );

	//	Weapons - Machineguns
	include_weapon( "rpk_zm" );									// mg42, 30 cal, ppsh
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
	include_weapon( "shrink_ray_zm", true, false, maps\_remix_zombiemode_weapons::default_wonder_weapon_weighting_func );
	include_weapon( "shrink_ray_upgraded_zm", false );

	include_weapon( "crossbow_explosive_zm" );
	include_weapon( "crossbow_explosive_upgraded_zm", false );
	include_weapon( "knife_ballistic_zm", true );
	include_weapon( "knife_ballistic_upgraded_zm", false );
	include_weapon( "knife_ballistic_bowie_zm", false );
	include_weapon( "knife_ballistic_bowie_upgraded_zm", false );

	// Custom weapons
	include_weapon( "ppsh_zm" );
	include_weapon( "ppsh_upgraded_zm", false );
	include_weapon( "stoner63_zm" );
	include_weapon( "stoner63_upgraded_zm",false );
	include_weapon( "ak47_zm" );
 	include_weapon( "ak47_upgraded_zm", false);

	level._uses_retrievable_ballisitic_knives = true;

	// limited weapons
	maps\_zombiemode_weapons::add_limited_weapon( "m1911_zm", 0 );
	maps\_zombiemode_weapons::add_limited_weapon( "crossbow_explosive_zm", 1 );
	maps\_zombiemode_weapons::add_limited_weapon( "knife_ballistic_zm", 1 );
	maps\_zombiemode_weapons::add_limited_weapon( "shrink_ray_zm", 1 );

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
	include_powerup( "carpenter" );
	include_powerup( "fire_sale" );
	include_powerup( "free_perk" );
}

add_powerups_after_round_1()
{
/#
	// allow powerups when cheating
	if ( GetDvarInt("zombie_cheat") > 0 )
	{
		return;
	}
#/

	//want to precache all the stuff for these powerups, but we don't want them to be available in the first round
	level.zombie_powerup_array = array_remove (level.zombie_powerup_array, "nuke");
	level.zombie_powerup_array = array_remove (level.zombie_powerup_array, "fire_sale");
	level.zombie_powerup_array = array_remove (level.zombie_powerup_array, "insta_kill");
	level.zombie_powerup_array = array_remove (level.zombie_powerup_array, "double_points");

	while (1)
	{
		if (level.round_number > 1)
		{
			level.zombie_powerup_array = array_add(level.zombie_powerup_array, "nuke");
			level.zombie_powerup_array = array_add(level.zombie_powerup_array, "fire_sale");
			level.zombie_powerup_array = array_add(level.zombie_powerup_array, "insta_kill");
			level.zombie_powerup_array = array_add(level.zombie_powerup_array, "double_points");
			break;
		}
		wait (1);
	}
}
