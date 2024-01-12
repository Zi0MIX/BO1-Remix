#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;

place_perk_machines()
{	
	if(level.script == "zombie_cosmodrome")
	{
		level.zombie_doubletap_machine_origin = (-567, 1401.5, 29);
		level.zombie_doubletap_machine_angles = (0, 270, 0);
		level.zombie_doubletap_machine_clip_origin = level.zombie_doubletap_machine_origin + (0, 5, 30);
		level.zombie_doubletap_machine_clip_angles = (0, 0, 0);

		level.zombie_doubletap_machine_monkey_angles = (0, 0, 0);
		level.zombie_doubletap_machine_monkey_origins = [];
		level.zombie_doubletap_machine_monkey_origins[0] = level.zombie_doubletap_machine_origin + (-36, 12, 5);
		level.zombie_doubletap_machine_monkey_origins[1] = level.zombie_doubletap_machine_origin + (-36, 0, 5);
		level.zombie_doubletap_machine_monkey_origins[2] = level.zombie_doubletap_machine_origin + (-38, -12, 5);

		//Remove stam
		machine_remove = getent( "vending_marathon", "targetname");
		machine_remove Delete();
		trigger_remove = getEnt( "vending_marathon", "target");
		trigger_remove Delete();


		machine = Spawn( "script_model", level.zombie_doubletap_machine_origin );
		machine.angles = level.zombie_doubletap_machine_angles;
		machine setModel( "zombie_vending_marathon" );
		machine.targetname = "vending_marathon";

		machine_trigger = Spawn( "trigger_radius_use", level.zombie_doubletap_machine_origin + (0, 0, 30), 0, 20, 70 );
		machine_trigger.targetname = "zombie_vending";
		machine_trigger.target = "vending_marathon";
		machine_trigger.script_noteworthy = "specialty_longersprint";

		machine_trigger.script_sound = "mus_perks_marathon_jingle";
		machine_trigger.script_label = "mus_perks_marathon_sting";

		machine_clip = spawn( "script_model", level.zombie_doubletap_machine_clip_origin );
		machine_clip.angles = level.zombie_doubletap_machine_clip_angles;
		machine_clip setmodel( "collision_geo_64x64x64" );
		machine_clip Hide();

		machine.target = "vending_marathon_monkey_structs";
		for ( i = 0; i < level.zombie_doubletap_machine_monkey_origins.size; i++ )
		{
			machine_monkey_struct = SpawnStruct();
			machine_monkey_struct.origin = level.zombie_doubletap_machine_monkey_origins[i];
			machine_monkey_struct.angles = level.zombie_doubletap_machine_monkey_angles;
			machine_monkey_struct.script_int = i + 1;
			machine_monkey_struct.script_notetworthy = "cosmo_monkey_marathon";
			machine_monkey_struct.targetname = "vending_marathon_monkey_structs";

			if ( !IsDefined( level.struct_class_names["targetname"][machine_monkey_struct.targetname] ) )
			{
				level.struct_class_names["targetname"][machine_monkey_struct.targetname] = [];
			}

			size = level.struct_class_names["targetname"][machine_monkey_struct.targetname].size;
			level.struct_class_names["targetname"][machine_monkey_struct.targetname][size] = machine_monkey_struct;
		}
	}

	if(level.script == "zombie_theater")
	{
		level.zombie_doubletap_machine_origin = (633, 1239, -15);
		level.zombie_doubletap_machine_angles = (0, 180, 0);
		level.zombie_doubletap_machine_clip_origin = level.zombie_doubletap_machine_origin + (0, -10, 0);
		level.zombie_doubletap_machine_clip_angles = (0, 0, 0);

		//Remove dt
		machine_remove1 = getent("vending_doubletap", "targetname");
		machine_remove1 Delete();
		trigger_remove1 = getEnt( "vending_doubletap", "target");
		trigger_remove1 Delete();

		machine = Spawn( "script_model", level.zombie_doubletap_machine_origin );
		machine.angles = level.zombie_doubletap_machine_angles;
		machine setModel( "zombie_vending_doubletap" );
		machine.targetname = "vending_doubletap";

		machine_trigger = Spawn( "trigger_radius_use", level.zombie_doubletap_machine_origin + (0, 0, 30), 0, 20, 70 );
		machine_trigger.targetname = "zombie_vending";
		machine_trigger.target = "vending_doubletap";
		machine_trigger.script_noteworthy = "specialty_rof";

		machine_trigger.script_sound = "mus_perks_doubletap_jingle";
		machine_trigger.script_label = "mus_perks_doubletap_sting";

		machine_clip = spawn( "script_model", level.zombie_doubletap_machine_clip_origin );
		machine_clip.angles = level.zombie_doubletap_machine_clip_angles;
		machine_clip setmodel( "collision_geo_64x64x256" );
		machine_clip Hide();

	}

/*	if(level.script == "zombie_cod5_sumpf")
	{
		level.zombie_doubletap_machine_origin = (8329, 2706, -708);
		level.zombie_doubletap_machine_angles = (0, 180, 0);
		level.zombie_doubletap_machine_clip_origin = level.zombie_doubletap_machine_origin + (0, 0, 0);
		level.zombie_doubletap_machine_clip_angles = (0, 0, 0);

		//Remove dt
		// machine_remove = getent("vending_doubletap", "targetname");
		// machine_remove Delete();
		// trigger_remove = getEnt( "vending_doubletap", "target");
		// trigger_remove Delete();

		machine = Spawn( "script_model", level.zombie_doubletap_machine_origin );
		machine.angles = level.zombie_doubletap_machine_angles;
		machine setModel( "zombie_vending_doubletap" );
		machine.targetname = "vending_doubletap";

		machine_trigger = Spawn( "trigger_radius_use", level.zombie_doubletap_machine_origin + (0, 0, 30), (50, 20, 50) );
		machine_trigger.targetname = "zombie_vending";
		machine_trigger.target = "vending_doubletap";
		machine_trigger.script_noteworthy = "specialty_rof";

		machine_trigger.script_sound = "mus_perks_doubletap_jingle";
		machine_trigger.script_label = "mus_perks_doubletap_sting";

		machine_clip = spawn( "script_model", level.zombie_doubletap_machine_clip_origin );
		machine_clip.angles = level.zombie_doubletap_machine_clip_angles;
		machine_clip setmodel( "collision_geo_64x64x256" );
		machine_clip Hide();

		//turn on double tap
		level notify( "master_switch_activated" );
		level notify("doubletap_sumpf_on");
	    level notify( "specialty_rof_power_on" );
	    clientnotify("doubletap_on");
		machine maps\_zombiemode_perks::perk_fx("doubletap_light");
	}*/

	if(level.script == "zombie_cod5_factory")
	{
		level.zombie_doubletap_machine_origin = (1352, 367, 64);
		level.zombie_doubletap_machine_angles = (0, 180, 0);
		level.zombie_doubletap_machine_clip_origin = level.zombie_doubletap_machine_origin + (0, -10, 0);
		level.zombie_doubletap_machine_clip_angles = (0, 0, 0);

        //Remove revive
		// machine_remove2 = getEnt( "vending_revive", "targetname" );
		// machine_remove2 Delete();
		// trigger_remove2 = getEnt( "vending_revive", "target");
		// trigger_remove2 Delete();

		machine = Spawn( "script_model", level.zombie_doubletap_machine_origin );
		machine.angles = level.zombie_doubletap_machine_angles;
		machine setModel( "zombie_vending_revive" );
		machine.targetname = "vending_revive";

		machine_trigger = Spawn( "trigger_radius_use", level.zombie_doubletap_machine_origin + (0, 0, 30), 0, 20, 70 );
		machine_trigger.targetname = "zombie_vending";
		machine_trigger.target = "vending_revive";
		machine_trigger.script_noteworthy = "specialty_quickrevive";

		machine_trigger.script_sound = "mus_perks_revive_jingle";
		machine_trigger.script_label = "mus_perks_revive_sting";

		machine_clip = spawn( "script_model", level.zombie_doubletap_machine_clip_origin );
		machine_clip.angles = level.zombie_doubletap_machine_clip_angles;
		machine_clip setmodel( "collision_geo_64x64x256" );
		machine_clip Hide();
	}

	if(level.script == "zombie_cod5_prototype")
	{
		// speed
		level.zombie_doubletap_machine_origin = (-160, -528, 1);
		level.zombie_doubletap_machine_angles = (0, 0, 0);
		level.zombie_doubletap_machine_clip_origin = (-162, -517, 17);
		level.zombie_doubletap_machine_clip_angles = (0, 0, 0);

		machine = Spawn( "script_model", level.zombie_doubletap_machine_origin );
		machine.angles = level.zombie_doubletap_machine_angles;
		machine setModel( "zombie_vending_sleight" );
		machine.targetname = "vending_sleight";

		machine_trigger = Spawn( "trigger_radius_use", level.zombie_doubletap_machine_origin + (0, 0, 30), 0, 20, 70 );
		machine_trigger.targetname = "zombie_vending";
		machine_trigger.target = "vending_sleight";
		machine_trigger.script_noteworthy = "specialty_fastreload";

		machine_trigger.script_sound = "mus_perks_sleight_jingle";
		machine_trigger.script_label = "mus_perks_sleight_sting";

		machine_clip = spawn( "script_model", level.zombie_doubletap_machine_clip_origin );
		machine_clip.angles = level.zombie_doubletap_machine_clip_angles;
		machine_clip setmodel( "collision_geo_64x64x256" );
		machine_clip Hide();

		level thread turn_sleight_on();
		level notify("sleight_on");
	}
}

wait_for_player_to_take( player, weapon, packa_timer )
{
	AssertEx( IsDefined( level.zombie_weapons[weapon] ), "wait_for_player_to_take: weapon does not exist" );
	AssertEx( IsDefined( level.zombie_weapons[weapon].upgrade_name ), "wait_for_player_to_take: upgrade_weapon does not exist" );

	upgrade_weapon = level.zombie_weapons[weapon].upgrade_name;

	self endon( "pap_timeout" );
	while( true )
	{
		packa_timer playloopsound( "zmb_perks_packa_ticktock" );
		self waittill( "trigger", trigger_player );
		packa_timer stoploopsound(.05);
		if( trigger_player == player )
		{
			current_weapon = player GetCurrentWeapon();
/#
if ( "none" == current_weapon )
{
	iprintlnbold( "WEAPON IS NONE, PACKAPUNCH RETRIEVAL DENIED" );
}
#/
			if( is_player_valid( player ) && !player is_drinking() && !is_placeable_mine( current_weapon ) && !is_equipment( current_weapon ) && "syrette_sp" != current_weapon && "none" != current_weapon && !player hacker_active())
			{
				self notify( "pap_taken" );
				player notify( "pap_taken" );
				player.pap_used = true;

				weapon_limit = 3;
				// if ( player HasPerk( "specialty_additionalprimaryweapon" ) )
				// {
				// 	weapon_limit = 3;
				// }

				primaries = player GetWeaponsListPrimaries();
				if( isDefined( primaries ) && primaries.size >= weapon_limit )
				{
					player maps\_zombiemode_weapons::weapon_give( upgrade_weapon );
				}
				else
				{
					player GiveWeapon( upgrade_weapon, 0, player maps\_zombiemode_weapons::get_pack_a_punch_weapon_options( upgrade_weapon ) );
					player GiveStartAmmo( upgrade_weapon );
				}

				player SwitchToWeapon( upgrade_weapon );
				player maps\_zombiemode_weapons::play_weapon_vo(upgrade_weapon);
				return;
			}
		}
		wait( 0.05 );
	}
}

upgrade_knuckle_crack_begin()
{
	self increment_is_drinking();

	self AllowLean( false );
	self AllowAds( false );
	self AllowSprint( true );
	self AllowCrouch( true );
	self AllowProne( false );
	self AllowMelee( false );

	if ( self GetStance() == "prone" )
	{
		self SetStance( "crouch" );
	}

	primaries = self GetWeaponsListPrimaries();

	gun = self GetCurrentWeapon();
	weapon = "zombie_knuckle_crack";

	if ( gun != "none" && !is_placeable_mine( gun ) && !is_equipment( gun ) )
	{
		self notify( "zmb_lost_knife" );
		self TakeWeapon( gun );
	}
	else
	{
		return;
	}

	self GiveWeapon( weapon );
	self SwitchToWeapon( weapon );

	return gun;
}

vending_trigger_think()
{
	//self thread turn_cola_off();
	perk = self.script_noteworthy;
	solo = false;
	flag_init( "_start_zm_pistol_rank" );

	//TODO  TEMP Disable Revive in Solo games
	if ( IsDefined(perk) &&
		(perk == "specialty_quickrevive" || perk == "specialty_quickrevive_upgrade") )
	{
		flag_wait( "all_players_connected" );
		players = GetPlayers();
		if ( players.size == 1 )
		{
			solo = true;
			flag_set( "solo_game" );
			level.solo_lives_given = 0;
			players[0].lives = 0;
			level maps\_zombiemode::zombiemode_solo_last_stand_pistol();
		}
	}

	flag_set( "_start_zm_pistol_rank" );

	if ( !solo )
	{
		self SetHintString( &"ZOMBIE_NEED_POWER" );
	}

	self SetCursorHint( "HINT_NOICON" );
	self UseTriggerRequireLookAt();

	cost = level.zombie_vars["zombie_perk_cost"];
	switch( perk )
	{
	case "specialty_armorvest_upgrade":
	case "specialty_armorvest":
		cost = 2500;
		break;

	case "specialty_quickrevive_upgrade":
	case "specialty_quickrevive":
		if( solo )
		{
			cost = 500;
		}
		else
		{
			cost = 1500;
		}
		break;

	case "specialty_fastreload_upgrade":
	case "specialty_fastreload":
		cost = 3000;
		break;

	case "specialty_rof_upgrade":
	case "specialty_rof":
		cost = 2000;
		break;

	case "specialty_longersprint_upgrade":
	case "specialty_longersprint":
		cost = 2000;
		break;

	case "specialty_flakjacket_upgrade":
	case "specialty_flakjacket":
		cost = 2000;
		break;

	case "specialty_deadshot_upgrade":
	case "specialty_deadshot":
		cost = 1000; // WW (02-03-11): Setting this low at first so more people buy it and try it (TEMP)
		break;

	case "specialty_additionalprimaryweapon_upgrade":
	case "specialty_additionalprimaryweapon":
		cost = 4000;
		break;

	}

	self.cost = cost;

	if ( !solo )
	{
		notify_name = perk + "_power_on";
		level waittill( notify_name );
	}

	if(!IsDefined(level._perkmachinenetworkchoke))
	{
		level._perkmachinenetworkchoke = 0;
	}
	else
	{
		level._perkmachinenetworkchoke ++;
	}

	for(i = 0; i < level._perkmachinenetworkchoke; i ++)
	{
		wait_network_frame();
	}

	//Turn on music timer
	self thread maps\_zombiemode_audio::perks_a_cola_jingle_timer();

	perk_hum = spawn("script_origin", self.origin);
	perk_hum playloopsound("zmb_perks_machine_loop");

	self thread check_player_has_perk(perk);

	switch( perk )
	{
	case "specialty_armorvest_upgrade":
	case "specialty_armorvest":
		self SetHintString( &"ZOMBIE_PERK_JUGGERNAUT", cost );
		break;

	case "specialty_quickrevive_upgrade":
	case "specialty_quickrevive":
		if( solo )
		{
			self SetHintString( &"ZOMBIE_PERK_QUICKREVIVE_SOLO", cost );
		}
		else
		{
			self SetHintString( &"ZOMBIE_PERK_QUICKREVIVE", cost );
		}
		break;

	case "specialty_fastreload_upgrade":
	case "specialty_fastreload":
		self SetHintString( &"ZOMBIE_PERK_FASTRELOAD", cost );
		break;

	case "specialty_rof_upgrade":
	case "specialty_rof":
		self SetHintString( &"ZOMBIE_PERK_DOUBLETAP", cost );
		break;

	case "specialty_longersprint_upgrade":
	case "specialty_longersprint":
		self SetHintString( &"ZOMBIE_PERK_MARATHON", cost );
		break;

	case "specialty_flakjacket_upgrade":
	case "specialty_flakjacket":
		self SetHintString( &"ZOMBIE_PERK_DIVETONUKE", cost );
		break;

	case "specialty_deadshot_upgrade":
	case "specialty_deadshot":
		self SetHintString( &"ZOMBIE_PERK_DEADSHOT", cost );
		break;

	case "specialty_additionalprimaryweapon_upgrade":
	case "specialty_additionalprimaryweapon":
		self SetHintString( &"ZOMBIE_PERK_ADDITIONALPRIMARYWEAPON", cost );
		break;

	default:
		self SetHintString( perk + " Cost: " + level.zombie_vars["zombie_perk_cost"] );
	}

	for( ;; )
	{
		self waittill( "trigger", player );

		index = maps\_zombiemode_weapons::get_player_index(player);

		if (player maps\_laststand::player_is_in_laststand() || is_true( player.intermission ) )
		{
			continue;
		}

		if(player in_revive_trigger())
		{
			continue;
		}

		if( player isThrowingGrenade() )
		{
			wait( 0.1 );
			continue;
		}

 		if( player isSwitchingWeapons() )
 		{
 			wait(0.1);
 			continue;
 		}

		if( player is_drinking() )
		{
			wait( 0.1 );
			continue;
		}

		if ( player HasPerk( perk ) )
		{
			cheat = false;

			/#
			if ( GetDvarInt( #"zombie_cheat" ) >= 5 )
			{
				cheat = true;
			}
			#/

			if ( cheat != true )
			{
				//player iprintln( "Already using Perk: " + perk );
				self playsound("deny");
				player maps\_zombiemode_audio::create_and_play_dialog( "general", "perk_deny", undefined, 1 );


				continue;
			}
		}

		if ( player.score < cost )
		{
			//player iprintln( "Not enough points to buy Perk: " + perk );
			self playsound("evt_perk_deny");
			player maps\_zombiemode_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
			continue;
		}

		perk_max = 4;
		if (level.script == "zombie_ww")
		{
			perk_max = 7;
		}

		if ( player.num_perks >= perk_max )
		{
			//player iprintln( "Too many perks already to buy Perk: " + perk );
			self playsound("evt_perk_deny");
			// COLLIN: do we have a VO that would work for this? if not we'll leave it at just the deny sound
			player maps\_zombiemode_audio::create_and_play_dialog( "general", "sigh" );
			continue;
		}

		sound = "evt_bottle_dispense";
		playsoundatposition(sound, self.origin);
		player maps\_zombiemode_score::minus_to_player_score( cost );

		player.perk_purchased = perk;

		//if( player unlocked_perk_upgrade( perk ) )
		//{
		//	perk += "_upgrade";
		//}

		///bottle_dispense
		switch( perk )
		{
		case "specialty_armorvest_upgrade":
		case "specialty_armorvest":
			sound = "mus_perks_jugger_sting";
			break;

		case "specialty_quickrevive_upgrade":
		case "specialty_quickrevive":
			sound = "mus_perks_revive_sting";
			break;

		case "specialty_fastreload_upgrade":
		case "specialty_fastreload":
			sound = "mus_perks_speed_sting";
			break;

		case "specialty_rof_upgrade":
		case "specialty_rof":
			sound = "mus_perks_doubletap_sting";
			break;

		case "specialty_longersprint_upgrade":
		case "specialty_longersprint":
			sound = "mus_perks_phd_sting";
			break;

		case "specialty_flakjacket_upgrade":
		case "specialty_flakjacket":
			sound = "mus_perks_stamin_sting";
			break;

		case "specialty_deadshot_upgrade":
		case "specialty_deadshot":
			sound = "mus_perks_jugger_sting"; // WW TODO: Place new deadshot stinger
			break;

		case "specialty_additionalprimaryweapon_upgrade":
		case "specialty_additionalprimaryweapon":
			sound = "mus_perks_mulekick_sting";
			break;

		default:
			sound = "mus_perks_jugger_sting";
			break;
		}

		self thread maps\_zombiemode_audio::play_jingle_or_stinger (self.script_label);

		//		self waittill("sound_done");


		// do the drink animation
		gun = player perk_give_bottle_begin( perk );
		//player waittill_any( "fake_death", "death", "player_downed", "weapon_change_complete" );
		self thread give_perk_think(player, gun, perk, cost);
	}
}

give_perk_think(player, gun, perk, cost)
{
	player waittill_any( "fake_death", "death", "player_downed", "weapon_change_complete" );

	// restore player controls and movement
	player perk_give_bottle_end( gun, perk );

	// TODO: race condition?
	if ( player maps\_laststand::player_is_in_laststand() || is_true( player.intermission ) )
	{
		return;
	}

	if ( isDefined( level.perk_bought_func ) )
	{
		player [[ level.perk_bought_func ]]( perk );
	}

	player.perk_purchased = undefined;

	player give_perk( perk, true );

	//player iprintln( "Bought Perk: " + perk );
	bbPrint( "zombie_uses: playername %s playerscore %d teamscore %d round %d cost %d name %s x %f y %f z %f type perk",
		player.playername, player.score, level.team_pool[ player.team_num ].score, level.round_number, cost, perk, self.origin );
}

perk_give_bottle_begin( perk )
{
	self increment_is_drinking();

	self AllowLean( false );
	self AllowAds( false );
	self AllowSprint( true );
	self AllowCrouch( true );
	self AllowProne( false );
	self AllowMelee( false );

	wait( 0.05 );

	if ( self GetStance() == "prone" )
	{
		self SetStance( "crouch" );
	}

	gun = self GetCurrentWeapon();
	weapon = "";

	switch( perk )
	{
	case " _upgrade":
	case "specialty_armorvest":
		weapon = "zombie_perk_bottle_jugg";
		break;

	case "specialty_quickrevive_upgrade":
	case "specialty_quickrevive":
		weapon = "zombie_perk_bottle_revive";
		break;

	case "specialty_fastreload_upgrade":
	case "specialty_fastreload":
		weapon = "zombie_perk_bottle_sleight";
		break;

	case "specialty_rof_upgrade":
	case "specialty_rof":
		weapon = "zombie_perk_bottle_doubletap";
		break;

	case "specialty_longersprint_upgrade":
	case "specialty_longersprint":
		weapon = "zombie_perk_bottle_marathon";
		break;

	case "specialty_flakjacket_upgrade":
	case "specialty_flakjacket":
		weapon = "zombie_perk_bottle_nuke";
		break;

	case "specialty_deadshot_upgrade":
	case "specialty_deadshot":
		weapon = "zombie_perk_bottle_deadshot";
		break;

	case "specialty_additionalprimaryweapon_upgrade":
	case "specialty_additionalprimaryweapon":
		weapon = "zombie_perk_bottle_additionalprimaryweapon";
		break;
	}

	self GiveWeapon( weapon );
	self SwitchToWeapon( weapon );

	return gun;
}

give_random_perk()
{
	// allows give jug if player does not have it
	if ( !self HasPerk( "specialty_armorvest" ) )
	{
		jug = "specialty_armorvest";
		self give_perk( jug );
		return;
	}

	vending_triggers = GetEntArray( "zombie_vending", "targetname" );

	perks = [];
	for ( i = 0; i < vending_triggers.size; i++ )
	{
		perk = vending_triggers[i].script_noteworthy;

		if ( isdefined( self.perk_purchased ) && self.perk_purchased == perk )
		{
			continue;
		}

		if ( !self HasPerk( perk ) )
		{
			perks[ perks.size ] = perk;
		}
	}

	if ( perks.size > 0 )
	{
		perks = array_randomize( perks );
		self give_perk( perks[0] );
	}
}
