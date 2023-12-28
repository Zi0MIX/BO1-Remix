remix_main()
{
	// curb fixs
	PreCacheModel("collision_geo_512x512x512");
	PreCacheModel("collision_geo_128x128x128");

    level thread maps\_zombiemode_utility::special_round_watcher();

    while (!isDefined(level.meteor_counter))
        wait 0.05;

    level thread curbs_fix();
}

curbs_fix()
{
	collision = spawn("script_model", (-65.359, -1215.74, -192.5));
	collision setmodel("collision_geo_512x512x512");
	collision.angles = (0, 0, 0);
	collision Hide();

	collision2 = spawn("script_model", (393.273, -2099.36, -192.5));
	collision2 setmodel("collision_geo_512x512x512");
	collision2.angles = (0, 0, 0);
	collision2 Hide();

	collision3 = spawn("script_model", (-120, -1129.359, -192.5));
	collision3 setmodel("collision_geo_512x512x512");
	collision3.angles = (0, 0, 0);
	collision3 Hide();

	collision4 = spawn("script_model", (117.604, -1588.69, -1.5));
	collision4 setmodel("collision_geo_128x128x128");
	collision4.angles = (0, 46.5, 0);
	collision4 Hide();

	collision5 = spawn("script_model", (435.5, -1502.5, -0.25));
	collision5 setmodel("collision_geo_128x128x128");
	collision5.angles = (0, 0, 0);
	collision5 Hide();

	collision6 = spawn("script_model", (627.5, -1184.359, -192.5));
	collision6 setmodel("collision_geo_512x512x512");
	collision6.angles = (0, 0, 0);
	collision6 Hide();

	disable_doors();
}

disable_doors()
{
	zombie_doors = GetEntArray( "zombie_door", "targetname" );
	for( i = 0; i < zombie_doors.size; i++ )
    {
    	if(zombie_doors[i].target == "south_courtyard_door")
    	{
    		zombie_doors[i] trigger_off();
    	}
    }
}

give_bowie_knife()
{
	players = get_players();
	for(i=0; i < players.size; i++)
	{
		gun = players[i] maps\_zombiemode_bowie::do_bowie_flourish_begin();
		players[i] maps\_zombiemode_audio::create_and_play_dialog( "weapon_pickup", "bowie" );
		players[i] waittill_any( "fake_death", "death", "player_downed", "weapon_change_complete" );
		players[i] maps\_zombiemode_bowie::do_bowie_flourish_end( gun );
	}
}

factory_zone_init()
{
	// Note this setup is based on a flag-centric view of setting up your zones.  A brief
	//	zone-centric example exists below in comments

	// Outside East Door
	add_adjacent_zone( "receiver_zone",		"outside_east_zone",	"enter_outside_east" );

	// Outside West Door
	add_adjacent_zone( "receiver_zone",		"outside_west_zone",	"enter_outside_west" );

	// Wnuen building ground floor
	add_adjacent_zone( "wnuen_zone",
	//problem
			"outside_east_zone",	"enter_wnuen_building" );

	// Wnuen stairway
	add_adjacent_zone( "wnuen_zone",		"wnuen_bridge_zone",	"enter_wnuen_loading_dock" );

	// Warehouse bottom
	add_adjacent_zone( "warehouse_bottom_zone", "outside_west_zone",	"enter_warehouse_building" );

	// Warehosue top
	add_adjacent_zone( "warehouse_bottom_zone", "warehouse_top_zone",	"enter_warehouse_second_floor" );
	add_adjacent_zone( "bridge_zone",	"warehouse_bottom_zone",			"enter_warehouse_second_floor" );
	add_adjacent_zone( "warehouse_top_zone",	"bridge_zone",			"enter_warehouse_second_floor" );
	//add_adjacent_zone( "warehouse_top_zone",	"bridge_zone",			"enter_south_zone", true );
	//add_adjacent_zone( "warehouse_top_zone",	"wnuen_bridge_zone",			"enter_south_zone" );

	// TP East
	add_adjacent_zone( "tp_east_zone",			"wnuen_zone",			"enter_tp_east" );

	//add_adjacent_zone( "tp_east_zone",			"outside_east_zone",	"enter_tp_east",			true );
	add_zone_flags(	"enter_tp_east",										"enter_wnuen_building" );

	// TP South
	add_adjacent_zone( "tp_south_zone",			"outside_south_zone",	"enter_tp_south" );
	//add_adjacent_zone( "outside_south_zone",			"tp_south_zone",	"enter_tp_south" );

	// TP West
	add_adjacent_zone( "tp_west_zone",			"warehouse_top_zone",	"enter_tp_west" );

	//add_adjacent_zone( "tp_west_zone",			"warehouse_bottom_zone", "enter_tp_west",		true );
	//add_zone_flags(	"enter_tp_west",										"enter_warehouse_second_floor" );


	//add_zone_flags(	"enter_warehouse_second_floor", "enter_south_zone" );
	//add_adjacent_zone( "tp_south_zone", "bridge_zone", "enter_tp_south", true );
}

bridge_init()
{
	flag_init( "bridge_down" );
	// raise bridge
	wnuen_bridge = getent( "wnuen_bridge", "targetname" );
	wnuen_bridge_coils = GetEntArray( "wnuen_bridge_coils", "targetname" );
	for ( i=0; i<wnuen_bridge_coils.size; i++ )
	{
		wnuen_bridge_coils[i] LinkTo( wnuen_bridge );
	}
	wnuen_bridge rotatepitch( 90, 1, .5, .5 );

	warehouse_bridge = getent( "warehouse_bridge", "targetname" );
	warehouse_bridge_coils = GetEntArray( "warehouse_bridge_coils", "targetname" );
	for ( i=0; i<warehouse_bridge_coils.size; i++ )
	{
		warehouse_bridge_coils[i] LinkTo( warehouse_bridge );
	}
	warehouse_bridge rotatepitch( -90, 1, .5, .5 );

	bridge_audio = getstruct( "bridge_audio", "targetname" );

	// wait for power
	flag_wait( "power_on" );

	// lower bridge
	wnuen_bridge rotatepitch( -90, 4, .5, 1.5 );
	warehouse_bridge rotatepitch( 90, 4, .5, 1.5 );

	if(isdefined( bridge_audio ) )
		playsoundatposition( "bridge_lower", bridge_audio.origin );

	wnuen_bridge connectpaths();
	warehouse_bridge connectpaths();

	exploder( 500 );

	// wait until the bridges are down.
	wnuen_bridge waittill( "rotatedone" );

	flag_set( "bridge_down" );
	if(isdefined( bridge_audio ) )
		playsoundatposition( "bridge_hit", bridge_audio.origin );

	wnuen_bridge_clip = getent( "wnuen_bridge_clip", "targetname" );
	wnuen_bridge_clip delete();

	warehouse_bridge_clip = getent( "warehouse_bridge_clip", "targetname" );
	warehouse_bridge_clip delete();

	maps\_zombiemode_zone_manager::connect_zones( "wnuen_bridge_zone", "bridge_zone" );
	maps\_zombiemode_zone_manager::connect_zones( "bridge_zone", "warehouse_top_zone" );
}

jump_from_bridge()
{
	trig = GetEnt( "trig_outside_south_zone", "targetname" );
	trig waittill( "trigger" );

	maps\_zombiemode_zone_manager::connect_zones( "outside_south_zone", "bridge_zone", true );
	//maps\_zombiemode_zone_manager::connect_zones( "outside_south_zone", "wnuen_bridge_zone", true );
}

include_weapons()
{
	include_weapon("m1911_zm", false);
	include_weapon("python_zm", false);
	include_weapon("cz75_zm");
	include_weapon("g11_lps_zm");
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
	include_weapon("crossbow_explosive_zm");
	include_weapon("knife_ballistic_zm");
	include_weapon("knife_ballistic_bowie_zm", false);

	include_weapon("m1911_upgraded_zm", false);
	include_weapon("python_upgraded_zm", false);
	include_weapon("cz75_upgraded_zm", false);
	include_weapon("g11_lps_upgraded_zm", false);
	include_weapon("famas_upgraded_zm", false);
	include_weapon("spectre_upgraded_zm", false);
	include_weapon("cz75dw_upgraded_zm", false);
	include_weapon("spas_upgraded_zm", false);
	include_weapon("hs10_upgraded_zm", false);
	include_weapon("aug_acog_mk_upgraded_zm", false);
	include_weapon("galil_upgraded_zm", false);
	include_weapon("commando_upgraded_zm", false);
	include_weapon("fnfal_upgraded_zm", false);
	include_weapon("dragunov_upgraded_zm", false);
	include_weapon("l96a1_upgraded_zm", false);
	include_weapon("rpk_upgraded_zm", false);
	include_weapon("hk21_upgraded_zm", false);
	include_weapon("m72_law_upgraded_zm", false);
	include_weapon("china_lake_upgraded_zm", false);
	include_weapon("crossbow_explosive_upgraded_zm", false);
	include_weapon("knife_ballistic_upgraded_zm", false);
	include_weapon("knife_ballistic_bowie_upgraded_zm", false);


	// Bolt Action
	include_weapon( "zombie_kar98k", false, true );
	include_weapon( "zombie_kar98k_upgraded", false );

	// Semi Auto
	include_weapon( "zombie_m1carbine", false, true );
	include_weapon( "zombie_m1carbine_upgraded", false );
	include_weapon( "zombie_gewehr43", false, true );
	include_weapon( "zombie_gewehr43_upgraded", false );

	// Full Auto
	include_weapon( "zombie_stg44", false, true );
	include_weapon( "zombie_stg44_upgraded", false );
	include_weapon( "zombie_thompson", false, true );
	include_weapon( "zombie_thompson_upgraded", false );
	include_weapon( "mp40_zm", false, true );
	include_weapon( "mp40_upgraded_zm", false );
	include_weapon( "zombie_type100_smg", false, true );
	include_weapon( "zombie_type100_smg_upgraded", false );

	// Grenade
	include_weapon( "stielhandgranate", false, true );

	// Shotgun
	include_weapon( "zombie_doublebarrel", false, true );
	include_weapon( "zombie_doublebarrel_upgraded", false );
	include_weapon( "zombie_shotgun", false, true );
	include_weapon( "zombie_shotgun_upgraded", false );

	include_weapon( "zombie_fg42", false, true );
	include_weapon( "zombie_fg42_upgraded", false );

	// Special
	include_weapon( "ray_gun_zm", true, false, ::factory_ray_gun_weighting_func );
	include_weapon( "ray_gun_upgraded_zm", false );
	include_weapon( "tesla_gun_zm", true, false, maps\_zombiemode_weapons::default_wonder_weapon_weighting_func );
	include_weapon( "tesla_gun_upgraded_zm", false );
	include_weapon( "zombie_cymbal_monkey", true, false, maps\_zombiemode_weapons::default_cymbal_monkey_weighting_func );

	// Custom weapons
	include_weapon( "ppsh_zm" );
	include_weapon( "ppsh_upgraded_zm", false );
	include_weapon( "stoner63_zm" );
	include_weapon( "stoner63_upgraded_zm",false );
	include_weapon( "ak47_zm" );
 	include_weapon( "ak47_upgraded_zm", false);

	//bouncing betties
	include_weapon("mine_bouncing_betty", false, true);

	// limited weapons
	maps\_zombiemode_weapons::add_limited_weapon( "m1911_zm", 0 );
	maps\_zombiemode_weapons::add_limited_weapon( "tesla_gun_zm", 1 );
	maps\_zombiemode_weapons::add_limited_weapon( "crossbow_explosive_zm", 1 );
	maps\_zombiemode_weapons::add_limited_weapon( "knife_ballistic_zm", 1 );

	level._uses_retrievable_ballisitic_knives = true;

	precacheItem( "explosive_bolt_zm" );
	precacheItem( "explosive_bolt_upgraded_zm" );

	// get the bowie into the collector achievement list
	level.collector_achievement_weapons = array_add( level.collector_achievement_weapons, "bowie_knife_zm" );



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

power_electric_switch()
{
	trig = getent("use_power_switch","targetname");
	master_switch = getent("power_switch","targetname");
	master_switch notsolid();
	//master_switch rotatepitch(90,1);
	trig sethintstring(&"WAW_ZOMBIE_ELECTRIC_SWITCH");
	trig SetCursorHint( "HINT_NOICON" );

	//turn off the buyable door triggers for electric doors
// 	door_trigs = getentarray("electric_door","script_noteworthy");
// 	array_thread(door_trigs,::set_door_unusable);
// 	array_thread(door_trigs,::play_door_dialog);

	cheat = false;

/#
	if( GetDvarInt( "zombie_cheat" ) >= 3 )
	{
		wait( 5 );
		cheat = true;
	}
#/

	user = undefined;
	if ( cheat != true )
	{
		trig waittill("trigger",user);
	}
	
	// MM - turning on the power powers the entire map
// 	if ( IsDefined(user) )	// only send a notify if we weren't originally triggered through script
// 	{
// 		other_trig = getent("use_warehouse_switch","targetname");
// 		other_trig notify( "trigger", undefined );
//
// 		wuen_trig = getent("use_wuen_switch", "targetname" );
// 		wuen_trig notify( "trigger", undefined );
// 	}

	master_switch rotateroll(-90,.3);

	// give players bowie knife
	players = get_players();
	for(i=0; i < players.size; i++)
	{
		players[i] giveweapon("bowie_knife_zm");
	}

	//TO DO (TUEY) - kick off a 'switch' on client script here that operates similiarly to Berlin2 subway.
	master_switch playsound("zmb_switch_flip");
	flag_set( "power_on" );
	wait_network_frame();
	level notify( "sleight_on" );
	wait_network_frame();
	level notify( "revive_on" );
	wait_network_frame();
	level notify( "doubletap_on" );
	wait_network_frame();
	level notify( "juggernog_on" );
	wait_network_frame();
	level notify( "Pack_A_Punch_on" );
	wait_network_frame();
	level notify( "specialty_armorvest_power_on" );
	wait_network_frame();
	level notify( "specialty_rof_power_on" );
	wait_network_frame();
	level notify( "specialty_quickrevive_power_on" );
	wait_network_frame();
	level notify( "specialty_fastreload_power_on" );
	wait_network_frame();

//	clientnotify( "power_on" );
	clientnotify("ZPO");	// Zombie Power On!
	wait_network_frame();
	exploder(600);

	trig delete();

	playfx(level._effect["switch_sparks"] ,getstruct("power_switch_fx","targetname").origin);

	// Don't want east or west to spawn when in south zone, but vice versa is okay
	maps\_zombiemode_zone_manager::connect_zones( "outside_east_zone", "outside_south_zone", true );
	maps\_zombiemode_zone_manager::connect_zones( "outside_west_zone", "outside_south_zone", true );
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
		shocktime = 1.5;
		//Changed Shellshock to Electrocution so we can have different bus volumes.
		self shellshock("electrocution", shocktime);

		if(level.elec_loop == 0)
		{
			elec_loop = 1;
			//self playloopsound ("electrocution");
			self playsound("zmb_zombie_arc");
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

zombie_elec_death(flame_chance)
{
	self endon("death");

	//10% chance the zombie will burn, a max of 6 burning zombs can be goign at once
	//otherwise the zombie just gibs and dies
	if(flame_chance > 90 && level.burning_zombies.size < 6)
	{
		level.burning_zombies[level.burning_zombies.size] = self;
		self thread zombie_flame_watch();
		self playsound("ignite");
		self thread animscripts\zombie_death::flame_death_fx();
		wait(randomfloat(0.75));
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
		if( !self.isdog && randomint(100) > 40 )
		{
			self thread electroctute_death_fx();
			self thread play_elec_vocals();
		}
		wait(randomfloat(1.25));
		self playsound("zmb_zombie_arc");
	}

	self.trap_death = true;
	self.no_powerups = true;
	self dodamage(self.health + 666, self.origin);
	//iprintlnbold("should be damaged");
}

zapper_light_red( lightname )
{
	zapper_lights = getentarray( lightname, "targetname");
	for(i=0;i<zapper_lights.size;i++)
	{
		zapper_lights[i] setmodel("zombie_zapper_cagelight_red");

		if(isDefined(zapper_lights[i].fx))
		{
			zapper_lights[i].fx delete();
		}

		//zapper_lights[i].fx = maps\_zombiemode_net::network_safe_spawn( "trap_light_red", 2, "script_model", zapper_lights[i].origin );
		zapper_lights[i].fx = Spawn("script_model", zapper_lights[i].origin);
		zapper_lights[i].fx setmodel("tag_origin");
		zapper_lights[i].fx.angles = zapper_lights[i].angles+(-90,0,0);
		playfxontag(level._effect["zapper_light_notready"],zapper_lights[i].fx,"tag_origin");
	}
}


//
//	Swaps a cage light model to the green one.
zapper_light_green( lightname )
{
	zapper_lights = getentarray( lightname, "targetname");
	for(i=0;i<zapper_lights.size;i++)
	{
		zapper_lights[i] setmodel("zombie_zapper_cagelight_green");

		if(isDefined(zapper_lights[i].fx))
		{
			zapper_lights[i].fx delete();
		}

		//zapper_lights[i].fx = maps\_zombiemode_net::network_safe_spawn( "trap_light_green", 2, "script_model", zapper_lights[i].origin );
		zapper_lights[i].fx = Spawn("script_model", zapper_lights[i].origin);
		zapper_lights[i].fx setmodel("tag_origin");
		zapper_lights[i].fx.angles = zapper_lights[i].angles+(-90,0,0);
		playfxontag(level._effect["zapper_light_ready"],zapper_lights[i].fx,"tag_origin");
	}
}

