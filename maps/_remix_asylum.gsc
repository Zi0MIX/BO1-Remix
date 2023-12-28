remix_main()
{
    level endon("end_game");

    level.uses_tesla_powerup = true; // for waffe

	maps\_zombiemode_weap_tesla::init();

    while (!isDefined(level.has_pack_a_punch))
        wait 0.05;

    level thread fix_zombie_pathing();

	spawn_mp5k_wallbuy();
}

fix_zombie_pathing()
{
	speed_machine = getent("vending_sleight", "targetname");

	angles_right = AnglesToForward(speed_machine.angles);
	angles_forward = AnglesToRight(speed_machine.angles);
	bad_spot = (-635.308, 726.692, 226.125);
	good_spot = bad_spot - (angles_right * 32) - (angles_forward * 64);

	while(1)
	{
		zombs = GetAiSpeciesArray( "axis", "all" );
		for(i = 0; i < zombs.size; i++)
		{
			if(IsDefined(zombs[i].recalculating) && zombs[i].recalculating)
			{
				continue;
			}
			if(int(DistanceSquared(bad_spot, zombs[i].origin)) < 24*24)
			{
				zombs[i].recalculating = true;
				zombs[i] thread recalculate_pathing(good_spot);
			}
		}
		wait .05;
	}
}

recalculate_pathing(good_spot)
{
	self SetGoalPos(good_spot);
	wait .2;
	self.recalculating = false;
}


spawn_mp5k_wallbuy()
{	
    //PreCacheModel( "weapon_upgrade_mp5" );
    model = Spawn( "script_model", ( -567.0, 745.3, 285.1 ) );
    model.angles = ( 0, 0, 0 );
    model SetModel( GetWeaponModel( "mp5k_zm" ) );
    model.targetname = "weapon_upgrade_mp5";
    trigger = Spawn( "trigger_radius_use", model.origin, 0, 20, 20 );
    // trigger.targetname = "weapon_upgrade";
    // trigger.target = "weapon_upgrade_mp5";
    // trigger.zombie_weapon_upgrade = "mp5k_zm";
	trigger UseTriggerRequireLookAt();
    trigger sethintstring( "Hold ^3[{+activate}]^7 to buy mp5k" );
	trigger SetCursorHint( "HINT_NOICON" );
    // chalk = Spawn( "script_model", model.origin );
    // chalk.angles = ( 0, 180, 0 );
    // chalk SetModel( "t5_weapon_mp5_world" );
	// chalk.target = "mp5_chalk";

	cost = 1000;
	ammo_cost = 500;
	zombie_weapon_upgrade = "mp5k_zm";

	while (1)
	{
		wait(0.5);

		trigger waittill( "trigger", player);

		if( !player maps\_zombiemode_weapons::can_buy_weapon() )
		{
			wait( 0.1 );
			continue;
		}

		// Allow people to get ammo off the wall for upgraded weapons
		player_has_weapon = player maps\_zombiemode_weapons::has_weapon_or_upgrade( zombie_weapon_upgrade );

		if( !player_has_weapon )
		{
			// else make the weapon show and give it
			if( player.score >= cost )
			{
				player maps\_zombiemode_score::minus_to_player_score( cost );
				player maps\_zombiemode_weapons::weapon_give( zombie_weapon_upgrade );
				//playsoundatposition("mus_wonder_weapon_stinger", (0,0,0));
			}
			else
			{
				trigger play_sound_on_ent( "no_purchase" );
				player maps\_zombiemode_audio::create_and_play_dialog( "general", "no_money", undefined, 1 );
			}
		}
		else
		{
			// if the player does have this then give him ammo.
			if( player.score >= ammo_cost )
			{
				ammo_given = player maps\_zombiemode_weapons::ammo_give( zombie_weapon_upgrade );
				if( ammo_given )
				{
						player maps\_zombiemode_score::minus_to_player_score( ammo_cost ); // this give him ammo to early
				}
			}
			else
			{
				trigger play_sound_on_ent( "no_purchase" );
				player maps\_zombiemode_audio::create_and_play_dialog( "general", "no_money", undefined, 0 );
			}
		}
	}
}

include_weapons()
{
	include_weapon("m1911_zm", false );						// colt
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
	include_weapon("crossbow_explosive_zm", false);
	include_weapon("knife_ballistic_zm");

	// Wall weapons
	include_weapon( "zombie_kar98k", false, true );
	include_weapon( "stielhandgranate", false, true );
	include_weapon( "zombie_gewehr43", false, true );
	include_weapon( "zombie_m1garand", false, true );
	include_weapon( "zombie_thompson", false, true );
	include_weapon( "zombie_shotgun", false, true );
	include_weapon( "mp40_zm", false, true );
	include_weapon( "zombie_bar_bipod", false, true );
	include_weapon( "zombie_stg44", false, true );
	include_weapon( "zombie_doublebarrel", false, true );
	include_weapon( "zombie_doublebarrel_sawed", false, true );

	// Special weapons
	include_weapon( "ray_gun_zm", true, false, maps\_zombiemode_weapons::default_ray_gun_weighting_func );
	include_weapon( "zombie_cymbal_monkey", true, false, maps\_zombiemode_weapons::default_cymbal_monkey_weighting_func );

	// Custom weapons
	include_weapon( "tesla_gun_zm", true, false, maps\_zombiemode_weapons::default_wonder_weapon_weighting_func );
	include_weapon( "ppsh_zm" );
	include_weapon( "ppsh_upgraded_zm", false );
	include_weapon( "stoner63_zm" );
	include_weapon( "stoner63_upgraded_zm",false );
	include_weapon( "ak47_zm" );
 	include_weapon( "ak47_upgraded_zm", false);
 	include_weapon( "mp5k_zm", false, true );

	// Special
	include_weapon( "freezegun_zm" );
	include_weapon( "m1911_upgraded_zm", false );

	//bouncing betties
	include_weapon("mine_bouncing_betty", false, true);

	// limited weapons
	maps\_zombiemode_weapons::add_limited_weapon( "m1911_zm", 0 );
	//maps\_zombiemode_weapons::add_limited_weapon( "crossbow_explosive_zm", 1 );
	maps\_zombiemode_weapons::add_limited_weapon( "knife_ballistic_zm", 1 );
	maps\_zombiemode_weapons::add_limited_weapon( "tesla_gun_zm", 1 );

	level._uses_retrievable_ballisitic_knives = true;

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

toilet_useage()
{

	toilet_counter = 0;
	toilet_trig = getent("toilet", "targetname");
	toilet_trig SetCursorHint( "HINT_NOICON" );
	toilet_trig UseTriggerRequireLookAt();

	players = getplayers();
	if (!IsDefined (level.music_override))
	{
		level.music_override = false;
	}

	while (1)
	{
		wait(0.5);

		toilet_trig waittill( "trigger", player);

		if(player HasWeapon("zombie_stg44"))
		{
			player TakeWeapon( "zombie_stg44" );
		}

		toilet_trig playsound ("toilet_flush", "sound_done");
		toilet_trig waittill ("sound_done");
		toilet_counter++;

		if(toilet_counter == 2)
		{
			playsoundatposition ("zmb_cha_ching", toilet_trig.origin);
			level thread play_music_easter_egg();
			toilet_counter = 0;
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
		shocktime = 1.25; //2.5;
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
		self playsound("zmb_ignite");
		self thread animscripts\zombie_death::flame_death_fx();
		wait(randomfloat(0.5)); //1.25
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
		if(randomint(100) > 40 )
		{
			self thread electroctute_death_fx();
			self thread play_elec_vocals();
		}
		wait(randomfloat(0.5)); //1.25
		self playsound("zmb_zombie_arc");
	}

	self dodamage(self.health + 666, self.origin);
}

master_electric_switch()
{

	trig = getent("use_master_switch","targetname");
	master_switch = getent("master_switch","targetname");
	master_switch notsolid();
	//master_switch rotatepitch(90,1);
	trig sethintstring(&"WAW_ZOMBIE_ELECTRIC_SWITCH");
	trig SetCursorHint( "HINT_NOICON" );

	//turn off the buyable door triggers downstairs
	fx_org = spawn("script_model", (-674.922, -300.473, 284.125));
	fx_org setmodel("tag_origin");
	fx_org.angles = (0, 90, 0);
	playfxontag(level._effect["electric_power_gen_idle"], fx_org, "tag_origin");



	cheat = false;

/#
	if( GetDvarInt( "zombie_cheat" ) >= 3 )
	{
		wait( 5 );
		cheat = true;
	}
#/

	if ( cheat != true )
	{
		trig waittill("trigger",user);
	}

	master_switch rotateroll(-90,.3);

	//TO DO (TUEY) - kick off a 'switch' on client script here that operates similiarly to Berlin2 subway.
	master_switch playsound("zmb_switch_flip");

	//level thread electric_current_open_middle_door();
	//level thread electric_current_revive_machine();
	//level thread electric_current_reload_machine();
	//level thread electric_current_doubletap_machine();
	//level thread electric_current_juggernog_machine();


	flag_set("power_on");

	//clientnotify("revive_on");
	//clientnotify("middle_door_open");
	//clientnotify("fast_reload_on");
	//clientnotify("doubletap_on");
	//clientnotify("jugger_on");

	clientnotify("ZPO");	 // Zombie Power On.


	level notify("switch_flipped");
	disable_bump_trigger("switch_door_trig");
	level thread play_the_numbers();
	left_org = getent("audio_swtch_left", "targetname");
	right_org = getent("audio_swtch_right", "targetname");
	left_org_b = getent("audio_swtch_b_left", "targetname");
	right_org_b = getent("audio_swtch_b_right", "targetname");

	if( isdefined (left_org))
	{
		left_org playsound("amb_sparks_l");
	}
	if( isdefined (left_org_b))
	{
		left_org playsound("amb_sparks_l_b");
	}
	if( isdefined (right_org))
	{
		right_org playsound("amb_sparks_r");
	}
	if( isdefined (right_org_b))
	{
		right_org playsound("amb_sparks_r_b");
	}
	// TUEY - Sets the "ON" state for all electrical systems via client scripts
	SetClientSysState("levelNotify","start_lights");
	level thread play_pa_system();

	flag_set("electric_switch_used");
	trig delete();

	//enable the electric traps
	traps = getentarray("gas_access","targetname");
	for(i=0;i<traps.size;i++)
	{
		traps[i] sethintstring(&"WAW_ZOMBIE_BUTTON_NORTH_FLAMES");
		traps[i] SetCursorHint( "HINT_NOICON" );

		traps[i].is_available = true;
	}

	master_switch waittill("rotatedone");
	playfx(level._effect["switch_sparks"] ,getstruct("switch_fx","targetname").origin);

	//activate perks-a-cola
	level notify( "master_switch_activated" );
	fx_org delete();

	fx_org = spawn("script_model", (-675.021, -300.906, 283.724));
	fx_org setmodel("tag_origin");
	fx_org.angles = (0, 90, 0);
	playfxontag(level._effect["electric_power_gen_on"], fx_org, "tag_origin");
	fx_org playloopsound("zmb_elec_current_loop");


	//elec room fx on
	//playfx(level._effect["elec_room_on"], (-440, -208, 8));

	//turn on green lights above the zapper trap doors
	level thread north_zapper_light_green();
	level thread south_zapper_light_green();

	level notify ("sleight_on");
	level notify ("revive_on");
	level notify ("doubletap_on");
	level notify ("juggernog_on");

	wait(6);
	fx_org stoploopsound();

	exploder(101);
	//exploder(201);

	//This wait is to time out the SFX properly
	wait(8);
	playsoundatposition ("amb_sparks_l_end", left_org.origin);
	playsoundatposition ("amb_sparks_r_end", right_org.origin);
}
