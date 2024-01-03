remix_main()
{
    while (!isDefined(level.has_pack_a_punch))
        wait 0.05;
    level.has_pack_a_punch = true;
    level thread spawn_pap_machine();
}

spawn_pap_machine()
{
	zombie_packapunch_machine_origin = (-146, 906, 0);
	zombie_packapunch_machine_angles = (0, 90, 0);
	zombie_packapunch_machine_clip_origin = zombie_packapunch_machine_origin;
	zombie_packapunch_machine_clip_angles = (0, 90, 0);

	machine = Spawn( "script_model", zombie_packapunch_machine_origin );
	machine.angles = zombie_packapunch_machine_angles;
	machine setmodel("zombie_vending_packapunch_on");
	machine.targetname = "vending_packapunch";

	machine_clip = spawn( "script_model", zombie_packapunch_machine_clip_origin );
	machine_clip.angles = zombie_packapunch_machine_clip_angles;
	machine_clip setmodel( "collision_geo_64x64x256" );
	machine_clip Hide();

	machine_trigger = Spawn( "trigger_radius_use", zombie_packapunch_machine_origin + (0, 0, 40), 100, 100, 100);
	machine_trigger UseTriggerRequireLookAt();
	machine_trigger sethintstring( "Hold ^3[{+activate}]^7 to Pack A Punch [Cost: 5000]" );
	machine_trigger SetCursorHint( "HINT_NOICON" );

	cost = 5000;
	weapons = array("m1911_zm", "ray_gun_zm", "crossbow_explosive_zm", "thundergun_zm");
	weapons_upgraded = array("m1911_upgraded_zm", "ray_gun_upgraded_zm", "crossbow_explosive_upgraded_zm", "thundergun_upgraded_zm");

	while( 1 )
	{
		machine_trigger waittill( "trigger", player );

		for(i=0; i < weapons.size; i++)
		{
			if( player.score >= cost && player GetCurrentWeapon() == weapons[i])
			{
				player maps\_zombiemode_score::minus_to_player_score( cost );

				if(player HasWeapon(weapons[i]))
				{
					player TakeWeapon( weapons[i] );
					player GiveWeapon( weapons_upgraded[i], 0, player maps\_zombiemode_weapons::get_pack_a_punch_weapon_options( weapons_upgraded[i] ) );
					player GiveStartAmmo( weapons_upgraded[i] );
					player SwitchToWeapon( weapons_upgraded[i] );
					player PlaySound( "mus_wonder_weapon_stinger" );
				}
			}
			else // not enough money
			{
				player PlaySound( "no_purchase" );
			}
		}
	}
}

include_weapons()
{
	include_weapon( "m1911_zm", false );						// colt
	include_weapon("python_zm", false);
	include_weapon("cz75_zm");
	include_weapon("g11_lps_zm", false);
	include_weapon("famas_zm");
	include_weapon("spectre_zm");
	include_weapon("cz75dw_zm");
	include_weapon("spas_zm", false);
	include_weapon("hs10_zm", false);
	include_weapon("aug_acog_zm");
	include_weapon("galil_zm");
	include_weapon("commando_zm");
	include_weapon("fnfal_zm", false);
	include_weapon("dragunov_zm", false);
	include_weapon("l96a1_zm", false);
	include_weapon("rpk_zm");
	include_weapon("hk21_zm");
	include_weapon("m72_law_zm");
	include_weapon("china_lake_zm", false);

	include_weapon("crossbow_explosive_zm", false);
	include_weapon("knife_ballistic_zm");

	include_weapon( "zombie_m1carbine", false, true );
	include_weapon( "zombie_thompson", false, true );
	include_weapon( "zombie_kar98k", false, true );
	include_weapon( "kar98k_scoped_zombie", false, true );
	include_weapon( "stielhandgranate", false, true );
	include_weapon( "zombie_doublebarrel", false, true );
	include_weapon( "zombie_doublebarrel_sawed", false, true );
	include_weapon( "zombie_shotgun", false, true );
	include_weapon( "zombie_bar", false, true );

	include_weapon( "zombie_cymbal_monkey", true, false, maps\_zombiemode_weapons::default_cymbal_monkey_weighting_func );

	include_weapon( "ray_gun_zm", true, false, maps\_zombiemode_weapons::default_ray_gun_weighting_func );
	include_weapon( "ray_gun_upgraded_zm", false);
	include_weapon( "thundergun_zm", true, false, maps\_remix_zombiemode_weapons::default_wonder_weapon_weighting_func );
	include_weapon( "thundergun_upgraded_zm", false );
	include_weapon( "m1911_upgraded_zm", false );

	// Custom weapons
	include_weapon( "ppsh_zm" );
	include_weapon( "stoner63_zm" );
	include_weapon( "ak47_zm" );


	level._uses_retrievable_ballisitic_knives = true;

	// limited weapons
	maps\_zombiemode_weapons::add_limited_weapon( "m1911_zm", 0 );
	maps\_zombiemode_weapons::add_limited_weapon( "thundergun_zm", 1 );
	//maps\_zombiemode_weapons::add_limited_weapon( "crossbow_explosive_zm", 1 );
	maps\_zombiemode_weapons::add_limited_weapon( "knife_ballistic_zm", 1 );

	//precacheItem( "explosive_bolt_zm" );
	//precacheItem( "explosive_bolt_upgraded_zm" );



	maps\_zombiemode_weapons::add_zombie_weapon( "zombie_kar98k", "zombie_kar98k_upgraded", 						&"WAW_ZOMBIE_WEAPON_KAR98K_200", 				200,	"rifle");
	maps\_zombiemode_weapons::add_zombie_weapon( "zombie_type99_rifle", "",					&"WAW_ZOMBIE_WEAPON_TYPE99_200", 			    200,	"rifle" );

	// Semi Auto
	maps\_zombiemode_weapons::add_zombie_weapon( "zombie_gewehr43", "zombie_gewehr43_upgraded",						&"WAW_ZOMBIE_WEAPON_GEWEHR43_600", 				600,	"rifle" );
	maps\_zombiemode_weapons::add_zombie_weapon( "zombie_m1carbine","zombie_m1carbine_upgraded",						&"WAW_ZOMBIE_WEAPON_M1CARBINE_600",				600,	"rifle" );
	maps\_zombiemode_weapons::add_zombie_weapon( "zombie_m1garand", "zombie_m1garand_upgraded" ,						&"WAW_ZOMBIE_WEAPON_M1GARAND_600", 				600,	"rifle" );

	maps\_zombiemode_weapons::add_zombie_weapon( "stielhandgranate", "", 						&"WAW_ZOMBIE_WEAPON_STIELHANDGRANATE_250", 		250,	"grenade", "", 250 );
	maps\_zombiemode_weapons::add_zombie_weapon( "mine_bouncing_betty", "", &"WAW_ZOMBIE_WEAPON_SATCHEL_2000", 2000 );
	// Scoped
	maps\_zombiemode_weapons::add_zombie_weapon( "kar98k_scoped_zombie", "", 					&"WAW_ZOMBIE_WEAPON_KAR98K_S_750", 				750,	"sniper");

	// Full Auto
	maps\_zombiemode_weapons::add_zombie_weapon( "zombie_stg44", "zombie_stg44_upgraded", 							    &"WAW_ZOMBIE_WEAPON_STG44_1200", 				1200, "mg" );
	maps\_zombiemode_weapons::add_zombie_weapon( "zombie_thompson", "zombie_thompson_upgraded", 							&"WAW_ZOMBIE_WEAPON_THOMPSON_1200", 			1200, "mg" );
	maps\_zombiemode_weapons::add_zombie_weapon( "zombie_type100_smg", "zombie_type100_smg_upgraded", 						&"WAW_ZOMBIE_WEAPON_TYPE100_1000", 				1000, "mg" );

	maps\_zombiemode_weapons::add_zombie_weapon( "zombie_fg42", "zombie_fg42_upgraded", 							&"WAW_ZOMBIE_WEAPON_FG42_1500", 				1500,	"mg" );


	// Shotguns
	maps\_zombiemode_weapons::add_zombie_weapon( "zombie_doublebarrel", "zombie_doublebarrel_upgraded", 						&"WAW_ZOMBIE_WEAPON_DOUBLEBARREL_1200", 		1200, "shotgun");
	maps\_zombiemode_weapons::add_zombie_weapon( "zombie_doublebarrel_sawed", "", 			    &"WAW_ZOMBIE_WEAPON_DOUBLEBARREL_SAWED_1200", 	1200, "shotgun");
	maps\_zombiemode_weapons::add_zombie_weapon( "zombie_shotgun", "zombie_shotgun_upgraded",							&"WAW_ZOMBIE_WEAPON_SHOTGUN_1500", 				1500, "shotgun");

	maps\_zombiemode_weapons::add_zombie_weapon( "zombie_bar", "zombie_bar_upgraded", 						&"WAW_ZOMBIE_WEAPON_BAR_1800", 					1800,	"mg" );

	// Bipods
	maps\_zombiemode_weapons::add_zombie_weapon( "zombie_bar_bipod", 	"",					&"WAW_ZOMBIE_WEAPON_BAR_BIPOD_2500", 			2500,	"mg" );
}

include_powerups()
{
	include_powerup( "nuke" );
	include_powerup( "insta_kill" );
	include_powerup( "double_points" );
	include_powerup( "full_ammo" );
}
