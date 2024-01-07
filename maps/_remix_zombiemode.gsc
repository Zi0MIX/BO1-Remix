remix_main()
{
	precachemenu("clientdvar");

	// limited betties/claymores on the map
	level.max_mines = 10;

	// added win con
	level.win_game = false;

	//level.start_time = GetTime();

    level.global_print_hud_color = (1, 1, 1);

	/* Initialize level var tracking amount of time spent in coop pause */
	level.time_paused = 0;

	level.last_special_round = -1;	// Set to negative to not mess with hud

    init_hud_dvars();

	//isClientPluto("com_useConfig", "");

	level thread remix_post_all_players_connected();
	level thread set_initial_blackscreen_passed();	// Allow for bo2 style hud initialization

	/* Remix main loop */
	while (true)
	{
		level waittill("start_of_round");
		level.round_timer setTimer(0);
		level.round_timer.beginning = int(getTime() / 1000);

		/* Stop the game if coop pause has been initiated, otherwise do nothing */
		level.time_paused += server_coop_pause();

		level waittill("end_of_round");

		// TODO need additional logic for nml
		level.round_timer thread maps\_remix_hud::freeze_timer(int(getTime() / 1000) - level.round_timer.beginning, "start_of_round");
	}
}

remix_post_all_players_connected()
{
	flag_wait("all_players_connected");

	level thread maps\_remix_hud::remix_hud_initialize();

	players = get_players();

	for (p = 0; p < players.size; p++)
	{
		players[p] thread override_score();
		players[p] thread remix_on_player_spawned();
		players[p] thread client_remix_coop_pause_watcher();
		players[p] thread maps\_remix_hud::remix_player_hud_initialize();
	}
}

remix_on_player_spawned()
{
	while (true)
	{
		self waittill("spawned_player");
	}
}

override_score()
{
	wait 0.05;
	self.score = 555;
	self.score_total = 555;
	self.old_score = 555;
}

set_initial_blackscreen_passed()
{
	level waittill("fade_in_complete");
	flag_set("initial_blackscreen_passed");
}

server_coop_pause()
{
	// TODO notify player if coop pause has been denied
	if (!maps\_remix_zombiemode_utility::is_coop_pause_allowed() || !maps\_remix_zombiemode_utility::num_of_players_with_coop_pause())
	{
		return 0;
	}

	flag_set("coop_pause");
	level notify("coop_pause_enabled");
	pause_begun = int(getTime() / 1000);

	level thread maps\_remix_hud::coop_pause_hud();
	setDvar("ai_disableSpawn", "1");
	if (isDefined(level.additional_coop_pause_func))
		level thread [[level.additional_coop_pause_func]]();
	level.timer thread maps\_remix_hud::freeze_timer(maps\_remix_zombiemode_utility::retrieve_actual_gametime(), "coop_pause_disabled");
	level.round_timer thread maps\_remix_hud::freeze_timer(0, "coop_pause_disabled");

	while (true)
	{
		wait_network_frame();
		if (!maps\_remix_zombiemode_utility::num_of_players_with_coop_pause())
			break;
	}

	flag_clear("coop_pause");
	level notify("coop_pause_disabled");
	setDvar("ai_disableSpawn", "0");

	return int(getTime() / 1000) - pause_begun;
}

client_remix_coop_pause_watcher()
{
	while (true)
	{
		if (!is_true(self.coop_pause) && self maps\_remix_zombiemode_utility::get_client_dvar("coop_pause") == "1")
			self.coop_pause = true;
		else if (is_true(self.coop_pause) && self maps\_remix_zombiemode_utility::get_client_dvar("coop_pause") != "1")
			self.coop_pause = false;

		wait 0.05;
	}
}

init_dvars()
{
	setSavedDvar( "fire_world_damage", "0" );
	setSavedDvar( "fire_world_damage_rate", "0" );
	setSavedDvar( "fire_world_damage_duration", "0" );

	if( GetDvar( #"zombie_debug" ) == "" )
	{
		SetDvar( "zombie_debug", "0" );
	}

	if( GetDvar( #"zombie_cheat" ) == "" )
	{
		SetDvar( "zombie_cheat", "0" );
	}

	if ( level.script != "zombie_cod5_prototype" )
	{
		SetDvar( "magic_chest_movable", "1" );
	}

	if(GetDvar( #"magic_box_explore_only") == "")
	{
		SetDvar( "magic_box_explore_only", "1" );
	}

	SetDvar( "revive_trigger_radius", "75" );
	SetDvar( "player_lastStandBleedoutTime", "45" );

	SetDvar( "scr_deleteexplosivesonspawn", "0" );

    // Disable player quotes
    maps\_remix_zombiemode_utility::init_dvar("player_quotes", 0);

	// HACK: To avoid IK crash in zombiemode: MikeA 9/18/2009
	//setDvar( "ik_enable", "0" );
}

init_strings()
{
	PrecacheString( &"ZOMBIE_WEAPONCOSTAMMO" );
	PrecacheString( &"ZOMBIE_ROUND" );
	PrecacheString( &"SCRIPT_PLUS" );
	PrecacheString( &"ZOMBIE_GAME_OVER" );
	PrecacheString( &"ZOMBIE_SURVIVED_ROUND" );
	PrecacheString( &"ZOMBIE_SURVIVED_ROUNDS" );
	PrecacheString( &"ZOMBIE_SURVIVED_NOMANS" );
	PrecacheString( &"ZOMBIE_EXTRA_LIFE" );

	// Remix strings
	PrecacheString(&"HUD_HUD_ZOMBIES_COOP_PAUSE");
	PrecacheString(&"HUD_HUD_ZOMBIES_ROUNDTIME");
	PrecacheString(&"HUD_HUD_ZOMBIES_SPH");
	PrecacheString(&"HUD_HUD_ZOMBIES_TOTALTIME");
	PrecacheString(&"HUD_HUD_ZOMBIES_PREDICTED");
	PrecacheString(&"MOD_YOU_WIN");
	PrecacheString(&"MOD_NML_END_KILLS");
	PrecacheString(&"MOD_NML_END_TIME");

	add_zombie_hint( "undefined", &"ZOMBIE_UNDEFINED" );

	// Random Treasure Chest
	add_zombie_hint( "default_treasure_chest_950", &"ZOMBIE_RANDOM_WEAPON_950" );

	// Barrier Pieces
	add_zombie_hint( "default_buy_barrier_piece_10", &"ZOMBIE_BUTTON_BUY_BACK_BARRIER_10" );
	add_zombie_hint( "default_buy_barrier_piece_20", &"ZOMBIE_BUTTON_BUY_BACK_BARRIER_20" );
	add_zombie_hint( "default_buy_barrier_piece_50", &"ZOMBIE_BUTTON_BUY_BACK_BARRIER_50" );
	add_zombie_hint( "default_buy_barrier_piece_100", &"ZOMBIE_BUTTON_BUY_BACK_BARRIER_100" );

	// REWARD Barrier Pieces
	add_zombie_hint( "default_reward_barrier_piece", &"ZOMBIE_BUTTON_REWARD_BARRIER" );
	add_zombie_hint( "default_reward_barrier_piece_10", &"ZOMBIE_BUTTON_REWARD_BARRIER_10" );
	add_zombie_hint( "default_reward_barrier_piece_20", &"ZOMBIE_BUTTON_REWARD_BARRIER_20" );
	add_zombie_hint( "default_reward_barrier_piece_30", &"ZOMBIE_BUTTON_REWARD_BARRIER_30" );
	add_zombie_hint( "default_reward_barrier_piece_40", &"ZOMBIE_BUTTON_REWARD_BARRIER_40" );
	add_zombie_hint( "default_reward_barrier_piece_50", &"ZOMBIE_BUTTON_REWARD_BARRIER_50" );

	// Debris
	add_zombie_hint( "default_buy_debris_100", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_100" );
	add_zombie_hint( "default_buy_debris_200", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_200" );
	add_zombie_hint( "default_buy_debris_250", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_250" );
	add_zombie_hint( "default_buy_debris_500", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_500" );
	add_zombie_hint( "default_buy_debris_750", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_750" );
	add_zombie_hint( "default_buy_debris_1000", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_1000" );
	add_zombie_hint( "default_buy_debris_1250", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_1250" );
	add_zombie_hint( "default_buy_debris_1500", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_1500" );
	add_zombie_hint( "default_buy_debris_1750", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_1750" );
	add_zombie_hint( "default_buy_debris_2000", &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_2000" );

	// Doors
	add_zombie_hint( "default_buy_door_100", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_100" );
	add_zombie_hint( "default_buy_door_200", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_200" );
	add_zombie_hint( "default_buy_door_250", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_250" );
	add_zombie_hint( "default_buy_door_500", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_500" );
	add_zombie_hint( "default_buy_door_750", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_750" );
	add_zombie_hint( "default_buy_door_1000", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_1000" );
	add_zombie_hint( "default_buy_door_1250", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_1250" );
	add_zombie_hint( "default_buy_door_1500", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_1500" );
	add_zombie_hint( "default_buy_door_1750", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_1750" );
	add_zombie_hint( "default_buy_door_2000", &"ZOMBIE_BUTTON_BUY_OPEN_DOOR_2000" );

	// Areas
	add_zombie_hint( "default_buy_area_100", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_100" );
	add_zombie_hint( "default_buy_area_200", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_200" );
	add_zombie_hint( "default_buy_area_250", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_250" );
	add_zombie_hint( "default_buy_area_500", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_500" );
	add_zombie_hint( "default_buy_area_750", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_750" );
	add_zombie_hint( "default_buy_area_1000", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_1000" );
	add_zombie_hint( "default_buy_area_1250", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_1250" );
	add_zombie_hint( "default_buy_area_1500", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_1500" );
	add_zombie_hint( "default_buy_area_1750", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_1750" );
	add_zombie_hint( "default_buy_area_2000", &"ZOMBIE_BUTTON_BUY_OPEN_AREA_2000" );

	// POWER UPS
	add_zombie_hint( "powerup_fire_sale_cost", &"ZOMBIE_FIRE_SALE_COST" );
}

init_levelvars()
{
	// Variables
	// used to a check in last stand for players to become zombies
	level.is_zombie_level			= true;
	level.laststandpistol			= "m1911_zm";		// so we dont get the uber colt when we're knocked out
	level.first_round				= true;
	level.round_number				= 1;
	level.round_start_time			= 0;
	level.pro_tips_start_time		= 0;
	level.intermission				= false;
	level.dog_intermission			= false;
	level.zombie_total				= 0;
	level.total_zombies_killed		= 0;
	level.no_laststandmissionfail	= true;
	level.hudelem_count				= 0;
	level.zombie_move_speed			= 1;
	level.enemy_spawns				= [];				// List of normal zombie spawners
	level.zombie_rise_spawners		= [];				// List of zombie riser locations
//	level.crawlers_enabled			= 1;

	// Used for kill counters
	level.counter_model[0] = "p_zom_counter_0";
	level.counter_model[1] = "p_zom_counter_1";
	level.counter_model[2] = "p_zom_counter_2";
	level.counter_model[3] = "p_zom_counter_3";
	level.counter_model[4] = "p_zom_counter_4";
	level.counter_model[5] = "p_zom_counter_5";
	level.counter_model[6] = "p_zom_counter_6";
	level.counter_model[7] = "p_zom_counter_7";
	level.counter_model[8] = "p_zom_counter_8";
	level.counter_model[9] = "p_zom_counter_9";

	level.zombie_vars = [];

	difficulty = 1;
	column = int(difficulty) + 1;

	//#######################################################################
	// NOTE:  These values are in mp/zombiemode.csv and will override
	//	whatever you put in as a value below.  However, if they don't exist
	//	in the file, then the values below will be used.
	//#######################################################################
	//	set_zombie_var( identifier, 					value,	float,	column );

	// AI
	set_zombie_var( "zombie_health_increase", 			100,	false,	column );	//	cumulatively add this to the zombies' starting health each round (up to round 10)
	set_zombie_var( "zombie_health_increase_multiplier",0.1, 	true,	column );	//	after round 10 multiply the zombies' starting health by this amount
	set_zombie_var( "zombie_health_start", 				150,	false,	column );	//	starting health of a zombie at round 1
	set_zombie_var( "zombie_spawn_delay", 				1.0,	true,	column );	// Base time to wait between spawning zombies.  This is modified based on the round number.
	set_zombie_var( "zombie_new_runner_interval", 		 10,	false,	column );	//	Interval between changing walkers who are too far away into runners
	set_zombie_var( "zombie_move_speed_multiplier", 	  8,	false,	column );	//	Multiply by the round number to give the base speed value.  0-40 = walk, 41-70 = run, 71+ = sprint

	set_zombie_var( "zombie_max_ai", 					24,		false,	column );	//	Base number of zombies per player (modified by round #)
	set_zombie_var( "zombie_ai_per_player", 			6,		false,	column );	//	additional zombie modifier for each player in the game
	set_zombie_var( "below_world_check", 				-1000 );					//	Check height to see if a zombie has fallen through the world.

	// Round
	set_zombie_var( "spectators_respawn", 				true );		// Respawn in the spectators in between rounds
	set_zombie_var( "zombie_use_failsafe", 				true );		// Will slowly kill zombies who are stuck
	set_zombie_var( "zombie_between_round_time", 		10 );		// How long to pause after the round ends
	set_zombie_var( "zombie_intermission_time", 		15 );		// Length of time to show the end of game stats
	set_zombie_var( "game_start_delay", 				0,		false,	column );	// How much time to give people a break before starting spawning

	// Life and death
	set_zombie_var( "penalty_no_revive", 				0.10, 	true,	column );	// Percentage of money you lose if you let a teammate die
	set_zombie_var( "penalty_died",						0.0, 	true,	column );	// Percentage of money lost if you die
	set_zombie_var( "penalty_downed", 					0.05, 	true,	column );	// Percentage of money lost if you go down // ww: told to remove downed point loss
	set_zombie_var( "starting_lives", 					1, 		false,	column );	// How many lives a solo player starts out with

	players = get_players();
	points = set_zombie_var( ("zombie_score_start_"+players.size+"p"), 3000, false, column );
	points = set_zombie_var( ("zombie_score_start_"+players.size+"p"), 3000, false, column );


	set_zombie_var( "zombie_score_kill_4player", 		50 );		// Individual Points for a zombie kill in a 4 player game
	set_zombie_var( "zombie_score_kill_3player",		50 );		// Individual Points for a zombie kill in a 3 player game
	set_zombie_var( "zombie_score_kill_2player",		50 );		// Individual Points for a zombie kill in a 2 player game
	set_zombie_var( "zombie_score_kill_1player",		50 );		// Individual Points for a zombie kill in a 1 player game

	set_zombie_var( "zombie_score_kill_4p_team", 		30 );		// Team Points for a zombie kill in a 4 player game
	set_zombie_var( "zombie_score_kill_3p_team",		35 );		// Team Points for a zombie kill in a 3 player game
	set_zombie_var( "zombie_score_kill_2p_team",		45 );		// Team Points for a zombie kill in a 2 player game
	set_zombie_var( "zombie_score_kill_1p_team",		 0 );		// Team Points for a zombie kill in a 1 player game

	set_zombie_var( "zombie_score_damage_normal",		10 );		// points gained for a hit with a non-automatic weapon
	set_zombie_var( "zombie_score_damage_light",		10 );		// points gained for a hit with an automatic weapon

	set_zombie_var( "zombie_score_bonus_melee", 		80 );		// Bonus points for a melee kill
	set_zombie_var( "zombie_score_bonus_head", 			50 );		// Bonus points for a head shot kill
	set_zombie_var( "zombie_score_bonus_neck", 			20 );		// Bonus points for a neck shot kill
	set_zombie_var( "zombie_score_bonus_torso", 		10 );		// Bonus points for a torso shot kill
	set_zombie_var( "zombie_score_bonus_burn", 			10 );		// Bonus points for a burn kill

	set_zombie_var( "zombie_flame_dmg_point_delay",		500 );

	set_zombie_var( "zombify_player", 					false );	// Default to not zombify the player till further support

	if ( IsSplitScreen() )
	{
		set_zombie_var( "zombie_timer_offset", 			280 );	// hud offsets
	}
}

init_flags()
{
	flag_init( "spawn_point_override" );
	flag_init( "power_on" );
	flag_init( "crawler_round" );
	flag_init( "spawn_zombies", true );
	flag_init( "dog_round" );
	flag_init( "begin_spawning" );
	flag_init( "end_round_wait" );
	flag_init( "wait_and_revive" );
	flag_init( "instant_revive" );
	// flag_init( "spawn_init" );
	flag_init( "game_paused" );
	flag_init( "hud_pressed" );
}

onPlayerConnect_clientDvars()
{
	self SetClientDvars( 
		/* Game stuff */
		"cg_deadChatWithDead", "1",
		"cg_deadChatWithTeam", "1",
		"cg_deadHearTeamLiving", "1",
		"cg_deadHearAllLiving", "1",
		"cg_everyoneHearsEveryone", "1",
		"compass", "0",
		"hud_showStance", "0",
		"cg_thirdPerson", "0",
		"cg_thirdPersonAngle", "0",
		"ammoCounterHide", "1",
		"miniscoreboardhide", "1",
		"cg_drawSpectatorMessages", "0",
		"ui_hud_hardcore", "0",
		"playerPushAmount", "1",

		/* Remix stuff */
		"cg_friendlyNameFadeOut", "1",
		"player_backSpeedScale", "1",
		"player_strafeSpeedScale", "1",
		"player_sprintStrafeSpeedScale", "1"
	);

	self SetDepthOfField( 0, 0, 512, 4000, 4, 0 );

	// Health Bar	
	if(getDvarInt("hud_health_bar") == 1)
		self setClientDvar("hud_health_bar", 1);
	else
		self setClientDvar("hud_health_bar", 0);

	// Drops counter
	if(getDvarInt("hud_drops") == 1)
		self setClientDvar("hud_drops", 1);
	else
		self setClientDvar("hud_drops", 0);

	// Zombie counter
	if(getDvarInt("hud_remaining") == 1)
		self setClientDvar("hud_remaining", 1);
	else
		self setClientDvar("hud_remaining", 0);

	// George Health Bar
	if(getDvarInt("hud_george_bar") == 1)
		self setClientDvar("hud_george_bar", 1);
	else
		self setClientDvar("hud_george_bar", 0);

	// Static round timer
	if(getDvarInt("hud_round_timer") == 1)
		self setClientDvar("hud_round_timer", 1);
	else
		self setClientDvar("hud_round_timer", 0);

	// Moon oxygen timer
	if(getDvarInt("hud_oxygen_timer") == 1)
		self setClientDvar("hud_oxygen_timer", 1);
	else
		self setClientDvar("hud_oxygen_timer", 0);

	// Moon excavator timer
	if(getDvarInt("hud_excavator_timer") == 1)
		self setClientDvar("hud_excavator_timer", 1);
	else
		self setClientDvar("hud_excavator_timer", 0);

	// Zone HUD
	if(getDvarInt("hud_zone_name_on") == 1)
		self setClientDvar("hud_zone_name_on", 1);
	else
		self setClientDvar("hud_zone_name_on", 0);

	self setClientDvar("cg_drawFriendlyFireCrosshair", "1");

	self setClientDvar("aim_lockon_pitch_strength", 0.0 );

	// makes FPS area in corner smaller
	self SetClientDvar("cg_drawFPSLabels", 0);

	// allows shooting while looking at players
	self SetClientDvar("g_friendlyFireDist", 0);

	// disable melee lunge
	self setClientDvar("aim_automelee_enabled", 0 );

	// ammo on HUD never fades away
	self SetClientDvar("hud_fade_ammodisplay", 0);

	// dtp buffs
	self SetClientDvars("dtp_post_move_pause", 0,
		"dtp_exhaustion_window", 100,
		"dtp_startup_delay", 100);

	// make sure zombies are spawning
	self SetClientDvar( "ai_disableSpawn", "0");

	// double tap 2.0
	self SetClientDvar( "perk_weapRateEnhanced", 1 );
}

round_think()
{
	for( ;; )
	{
		//////////////////////////////////////////
		//designed by prod DT#36173
		maxreward = 50 * level.round_number;
		if ( maxreward > 500 )
			maxreward = 500;
		level.zombie_vars["rebuild_barrier_cap_per_round"] = maxreward;
		//////////////////////////////////////////

		level.pro_tips_start_time = GetTime();
		level.zombie_last_run_time = GetTime();	// Resets the last time a zombie ran

        level thread maps\_zombiemode_audio::change_zombie_music( "round_start" );
		chalk_one_up();
		//		round_text( &"ZOMBIE_ROUND_BEGIN" );

		maps\_zombiemode_powerups::powerup_round_start();

		players = get_players();
		array_thread( players, maps\_zombiemode_blockers::rebuild_barrier_reward_reset );

		//array_thread( players, maps\_zombiemode_ability::giveHardpointItems );

		level thread award_grenades_for_survivors();

		bbPrint( "zombie_rounds: round %d player_count %d", level.round_number, players.size );

		level.round_start_time = GetTime();
		level thread [[level.round_spawn_func]]();

		level notify( "start_of_round" );

		[[level.round_wait_func]]();

		level.first_round = false;
		level notify( "end_of_round" );

		level thread maps\_zombiemode_audio::change_zombie_music( "round_end" );

		UploadStats();

		if ( 1 != players.size )
		{
			level thread spectators_respawn();
			//level thread last_stand_revive();
		}

		//		round_text( &"ZOMBIE_ROUND_END" );
		level chalk_round_over();

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

		//
		// Increase the zombie move speed
		//level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier"];

// 		iPrintlnBold( "End of Round " + level.round_number );
// 		for ( i=0; i<level.team_pool.size; i++ )
// 		{
// 			iPrintlnBold( "Team Pool "+(i+1)+" score: ", level.team_pool[i].score_total );
// 		}
//
// 		players = get_players();
// 		for ( p=0; p<players.size; p++ )
// 		{
// 			iPrintlnBold( "Total Player "+(p+1)+" score : "+ players[p].score_total );
// 		}

		level.round_number++;

		level notify( "between_round_over" );
	}
}

ai_calculate_health( round_number )
{
	// Insta rounds starting between 99-69 depends lobby size and occur on odd rounds
	if (round_number % 2 == 1)
	{
		if (level.players_playing == 1 && round_number >= 99)			// Solo
		{
			level.zombie_health = 150;
			return;
		}
		else if (level.players_playing == 2 && round_number >= 89)		// 2p
		{
			level.zombie_health = 150;
			return;
		}
		else if (level.players_playing == 3 && round_number >= 79)		// 3p
		{
			level.zombie_health = 150;
			return;
		}
		else if (level.players_playing == 4 && round_number >= 69)		// 4p
		{
			level.zombie_health = 150;
			return;
		}
	}

	level.zombie_health = level.zombie_vars["zombie_health_start"];
	for ( i=2; i<=round_number; i++ )
	{
		// After round 10, get exponentially harder
		if( i >= 10 )
		{
			level.zombie_health += Int( level.zombie_health * level.zombie_vars["zombie_health_increase_multiplier"] );
		}
		else
		{
			level.zombie_health = Int( level.zombie_health + level.zombie_vars["zombie_health_increase"] );
		}
	}
}

can_revive( reviver )
{
	return true;
}

player_damage_override( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime )
{
	iDamage = self check_player_damage_callbacks( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime );
	if ( !iDamage )
	{
		return 0;
	}

	// turret doesn't damage players
	if ( isDefined( eInflictor ) )
	{
		if(sMeansOfDeath == "MOD_RIFLE_BULLET" && sWeapon == "zombie_bullet_crouch")
		{
			return 0;
		}
	}

	// WW (8/14/10) - If a player is hit by the crossbow bolt then set them as the holder of the monkey shot
	if( sWeapon == "crossbow_explosive_upgraded_zm" && sMeansOfDeath == "MOD_IMPACT" )
	{
		level.monkey_bolt_holder = self;
	}

	// Raven - snigl - Notify of blow gun hit
	if( GetSubStr(sWeapon, 0, 8 ) == "blow_gun" && sMeansOfDeath == "MOD_IMPACT" )
	{
		eAttacker notify( "blow_gun_hit", self, eInflictor );
	}

	// WW (8/20/10) - Sledgehammer fix for Issue 43492. This should stop the player from taking any damage while in laststand
	if( self maps\_laststand::player_is_in_laststand() )
	{
		return 0;
	}

	if ( isDefined( eInflictor ) )
	{
		if ( is_true( eInflictor.water_damage ) )
		{
			return 0;
		}
	}

	if( isDefined( eAttacker ) )
	{

		//tracking player damage
		if(is_true(eAttacker.is_zombie))
		{
			self.stats["damage_taken"] += iDamage;
		}

		if( isDefined( self.ignoreAttacker ) && self.ignoreAttacker == eAttacker )
		{
			return 0;
		}

		if( (isDefined( eAttacker.is_zombie ) && eAttacker.is_zombie) || level.mutators["mutator_friendlyFire"] )
		{
			self.ignoreAttacker = eAttacker;
			self thread remove_ignore_attacker();

			if ( isdefined( eAttacker.custom_damage_func ) )
			{
				iDamage = eAttacker [[ eAttacker.custom_damage_func ]]( self );
			}
			else if ( isdefined( eAttacker.meleeDamage ) )
			{
				iDamage = eAttacker.meleeDamage;
			}
			else
			{
				iDamage = 50;		// 45
			}
		}

		eAttacker notify( "hit_player" );


		if( is_true(eattacker.is_zombie) && eattacker.animname == "director_zombie" )
		{
			 self PlaySound( "zmb_director_light_hit" );
			 if(RandomIntRange(0,1) == 0 )
		    {
		        self thread maps\_zombiemode_audio::create_and_play_dialog( "general", "hitmed" );
		    }
		    else
		    {
		        self thread maps\_zombiemode_audio::create_and_play_dialog( "general", "hitlrg" );
		    }
		}
		else if( sMeansOfDeath != "MOD_FALLING" )
		{
		    self PlaySound( "evt_player_swiped" );
		    if(RandomIntRange(0,1) == 0 )
		    {
		        self thread maps\_zombiemode_audio::create_and_play_dialog( "general", "hitmed" );
		    }
		    else
		    {
		        self thread maps\_zombiemode_audio::create_and_play_dialog( "general", "hitlrg" );
		    }
		}
	}
	finalDamage = iDamage;

	// claymores and freezegun shatters, like bouncing betties, harm no players
	if ( is_placeable_mine( sWeapon ) || sWeapon == "freezegun_zm" || sWeapon == "freezegun_upgraded_zm" || sWeapon == "tesla_gun_upgraded_zm" || sWeapon == "telsa_gun_zm" )
	{
		return 0;
	}

	if ( isDefined( self.player_damage_override ) )
	{
		self thread [[ self.player_damage_override ]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime );
	}

	if( sMeansOfDeath == "MOD_FALLING" )
	{
		if ( self HasPerk( "specialty_flakjacket" ) && isdefined( self.divetoprone ) && self.divetoprone == 1 )
		{
			if ( IsDefined( level.zombiemode_divetonuke_perk_func ) )
			{
				[[ level.zombiemode_divetonuke_perk_func ]]( self, self.origin );
			}

			return 0;
		}
	}

	if( sMeansOfDeath == "MOD_PROJECTILE" || sMeansOfDeath == "MOD_PROJECTILE_SPLASH" || sMeansOfDeath == "MOD_GRENADE" || sMeansOfDeath == "MOD_GRENADE_SPLASH" )
	{
		// check for reduced damage from flak jacket perk
		if ( self HasPerk( "specialty_flakjacket" ) )
		{
			return 0;
		}

		if( self.health > 75 )
		{
			// MM (08/10/09)
			return 75;
		}
	}

	if( iDamage < self.health )
	{
		if ( IsDefined( eAttacker ) )
		{
			eAttacker.sound_damage_player = self;

			if( IsDefined( eAttacker.has_legs ) && !eAttacker.has_legs )
			{
			    self maps\_zombiemode_audio::create_and_play_dialog( "general", "crawl_hit" );
			}
			else if( IsDefined( eAttacker.animname ) && ( eAttacker.animname == "monkey_zombie" ) )
			{
			    self maps\_zombiemode_audio::create_and_play_dialog( "general", "monkey_hit" );
			}
		}

		// MM (08/10/09)
		return finalDamage;
	}
	if( level.intermission )
	{
		level waittill( "forever" );
	}

	players = get_players();
	count = 0;
	for( i = 0; i < players.size; i++ )
	{
		if( players[i] == self || players[i].is_zombie || players[i] maps\_laststand::player_is_in_laststand() || players[i].sessionstate == "spectator" )
		{
			count++;
		}
	}
	if( count < players.size )
	{
		// MM (08/10/09)
		return finalDamage;
	}

	//if ( maps\_zombiemode_solo::solo_has_lives() )
	//{
	//	SetDvar( "player_lastStandBleedoutTime", "3" );
	//}
	//else
	//{
	if ( players.size == 1 && flag( "solo_game" ) )
	{
		if ( self.lives == 0 )
		{
			self.intermission = true;
		}
	}
	//}

	// WW (01/05/11): When a two players enter a system link game and the client drops the host will be treated as if it was a solo game
	// when it wasn't. This led to SREs about undefined and int being compared on death (self.lives was never defined on the host). While
	// adding the check for the solo game flag we found that we would have to create a complex OR inside of the if check below. By breaking
	// the conditions out in to their own variables we keep the complexity without making it look like a mess.
	solo_death = ( players.size == 1 && flag( "solo_game" ) && self.lives == 0 ); // there is only one player AND the flag is set AND self.lives equals 0
	non_solo_death = ( players.size > 1 || ( players.size == 1 && !flag( "solo_game" ) ) ); // the player size is greater than one OR ( players.size equals 1 AND solo flag isn't set )

	if ( solo_death || non_solo_death ) // if only one player on their last life or any game that started with more than one player
	{
		self thread maps\_laststand::PlayerLastStand( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime );
		self player_fake_death();
	}

	if( count == players.size )
	{
		//if ( !maps\_zombiemode_solo::solo_has_lives() )
		//{

		if ( players.size == 1 && flag( "solo_game" ) )
		{
			if ( self.lives == 0 ) // && !self maps\_laststand::player_is_in_laststand()
			{

				level notify("pre_end_game");
				wait_network_frame();

				level notify( "end_game" );
			}
			else
			{
				self thread wait_and_revive();
				return finalDamage;
			}
		}
		else
		{
			level notify("pre_end_game");
			wait_network_frame();

			level notify( "end_game" );
		}
		//}

		return 0;	// MM (09/16/09) Need to return something
	}
	else
	{
		// MM (08/10/09)
		return finalDamage;
	}
}

actor_damage_override( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, sHitLoc, modelIndex, psOffsetTime )
{

	// WW (8/14/10) - define the owner of the monkey shot
	if( weapon == "crossbow_explosive_upgraded_zm" && meansofdeath == "MOD_IMPACT" )
	{
		level.monkey_bolt_holder = self;
	}

	// Raven - snigl - Record what the blow gun hit
	if( GetSubStr(weapon, 0, 8 ) == "blow_gun" && meansofdeath == "MOD_IMPACT" )
	{
		attacker notify( "blow_gun_hit", self, inflictor );
	}

	if ( isdefined( attacker.animname ) && attacker.animname == "quad_zombie" )
	{
		if ( isdefined( self.animname ) && self.animname == "quad_zombie" )
		{
			return 0;
		}
	}

	// Turrets - kill in 2 shots
	if(meansofdeath == "MOD_RIFLE_BULLET" && weapon == "zombie_bullet_crouch")
	{
		damage = int(self.maxhealth/2) + 1;

		if(damage < 500)
		{
			damage = 500;
		}
	}

	// Gersch - skip damage if they are dead do full damage
	if( IsDefined( self._black_hole_bomb_collapse_death ) && self._black_hole_bomb_collapse_death == 1 )
	{
		return self.maxhealth + 1000;
	}

	// skip conditions
	if( !isdefined( self) || !isdefined( attacker ) )
		return damage;
	if ( !isplayer( attacker ) && isdefined( self.non_attacker_func ) )
	{
		override_damage = self [[ self.non_attacker_func ]]( damage, weapon );
		if ( override_damage )
			return override_damage;
	}
	if ( !isplayer( attacker ) && !isplayer( self ) )
		return damage;
	if( !isdefined( damage ) || !isdefined( meansofdeath ) )
		return damage;
	if( meansofdeath == "" )
		return damage;

//	println( "*********HIT :  Zombie health: "+self.health+",  dam:"+damage+", weapon:"+ weapon );

	old_damage = damage;
	final_damage = damage;

	if ( IsDefined( self.actor_damage_func ) )
	{
		final_damage = [[ self.actor_damage_func ]]( weapon, old_damage, attacker );
	}

	if ( IsDefined( self.actor_full_damage_func ) )
	{
		final_damage = [[ self.actor_full_damage_func ]]( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, sHitLoc, modelIndex, psOffsetTime );
	}

	// debug
/#
		if ( GetDvarInt( #"scr_perkdebug") )
			println( "Perk/> Damage Factor: " + final_damage/old_damage + " - Pre Damage: " + old_damage + " - Post Damage: " + final_damage );
#/

	if( attacker.classname == "script_vehicle" && isDefined( attacker.owner ) )
		attacker = attacker.owner;

	if( !isDefined( self.damage_assists ) )
	{
		self.damage_assists = [];
	}

	if ( !isdefined( self.damage_assists[attacker.entity_num] ) )
	{
		self.damage_assists[attacker.entity_num] = attacker;
	}

	if( level.mutators[ "mutator_headshotsOnly" ] && !is_headshot( weapon, sHitLoc, meansofdeath ) )
	{
		return 0;
	}

	if( level.mutators[ "mutator_powerShot" ] )
	{
		final_damage = int( final_damage * 1.5 );
	}

	if ( is_true( self.in_water ) )
	{
		if ( int( final_damage ) >= self.health )
		{
			self.water_damage = true;
		}
	}

	if((is_true(level.zombie_vars["zombie_insta_kill"]) || is_true(attacker.powerup_instakill) || is_true(attacker.personal_instakill)) && !is_true(self.magic_bullet_shield) && self.animname != "thief_zombie" && self.animname != "director_zombie" && self.animname != "napalm_zombie" && self.animname != "astro_zombie")
	{
		// insta kill should not effect these weapons as they already are insta kill, causes special anims and scripted things to not work
		no_insta_kill_on_weps = array("tesla_gun_zm", "tesla_gun_upgraded_zm", "tesla_gun_powerup_zm", "tesla_gun_powerup_upgraded_zm", "humangun_zm", "humangun_upgraded_zm", "microwavegundw_zm", "microwavegundw_upgraded_zm");

		if(!is_in_array(no_insta_kill_on_weps, weapon))
		{
			if ( !is_true( self.no_gib ) )
			{
				self maps\_zombiemode_spawner::zombie_head_gib();
			}

			if( is_true( self.in_water ) )
			{
				self.water_damage = true;
			}
				return self.maxhealth + 1000;
		}
	}

	if(meansofdeath == "MOD_MELEE")
	{
		final_damage -= final_damage % 50; // fix for melee weapons doing 1-4 extra damage
	}

	// damage scaling for explosive weapons
	// consistent damage and scales for zombies farther away from explosion better
	if(meansofdeath == "MOD_GRENADE" || meansofdeath == "MOD_GRENADE_SPLASH" || meansofdeath == "MOD_PROJECTILE" || meansofdeath == "MOD_PROJECTILE_SPLASH")
	{
		// no damage scaling for these wonder weps
		if(weapon != "tesla_gun_zm" && weapon != "tesla_gun_upgraded_zm" && weapon != "tesla_gun_powerup_zm" && weapon != "tesla_gun_powerup_upgraded_zm" )
		{
				// stop damage scaling past round 100
				scalar = level.round_number;
				if(scalar > 100)
				{
					scalar = 100;
				}

				if(is_lethal_grenade(weapon))
				{
					final_damage += 15 * scalar;
				}
				else
				{
					final_damage += 60 * scalar;
				}
		}
	}

	// damage for non-shotgun bullet weapons - deals the same amount of damage through walls and multiple zombies
	// all body shots deal the same damage
	// neck, head, and healmet shots all deal the same damage
	if(meansofdeath == "MOD_PISTOL_BULLET" || meansofdeath == "MOD_RIFLE_BULLET")
	{
		switch(weapon)
		{
		//REGULAR WEAPONS
		case "m1911_zm":
			final_damage = 25; //25
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 2.8;
			break;
		case "cz75_zm":
		case "cz75dw_zm":
			final_damage = 150; //150
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 3.5;
			break;
		case "python_zm":
			final_damage = 1000;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 1.5;
			break;
		case "m14_zm":
		case "zombie_m1garand":
			final_damage = 150; //140
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 2.5;
			break;
		case "ak74u_zm":
		case "zombie_thompson":
			final_damage = 120;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 4;
			break;
		case "mpl_zm":
		case "m16_zm":
		case "mp5k_zm":
		case "mp40_zm":
		case "pm63_zm":
		case "g11_lps_zm":
		case "famas_zm":
		case "ppsh_zm":
		case "zombie_stg44":
		case "zombie_type100_smg":
			final_damage = 100;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 4;
			break;
		case "spectre_zm":
			final_damage = 90;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 4;
			break;
		case "aug_acog_mk_acog_zm":
			final_damage = 140;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 4;
			break;
		case "commando_zm":
		case "galil_zm":
		case "ak47_zm":
			final_damage = 150;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 4;
			break;
		case "fnfal_zm":
			final_damage = 160;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 4;
			break;
		case "rpk_zm":
			final_damage = 130;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 3;
			break;
		case "hk21_zm":
			final_damage = 150;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 3;
			break;
		case "stoner63_zm":
			final_damage = 160;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 3;
			break;
		case "psg1_zm":
			final_damage = 500;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 5;
			break;
		case "l96a1_zm":
			final_damage = 1000;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 5;
			break;
		//CLASSIC WEAPONS
		case "zombie_kar98k":
		case "zombie_type99_rifle":
		case "zombie_springfield":
			final_damage = 500;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 2.5;
			break;
		case "zombie_m1carbine":
			final_damage = 150;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 2.5;
			break;
		case "zombie_gewehr43":
			final_damage = 150;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 2.5;
			break;
		case "zombie_bar":
			final_damage = 200;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 2.5;
			break;
		case "kar98k_scoped_zombie":
			final_damage = 1000;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 4;
			break;
		case "zombie_fg42":
			final_damage = 200;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 1.5;
			break;
		//UPGRADED WEAPONS
		case "cz75_upgraded_zm":
		case "cz75dw_upgraded_zm":
			final_damage = 300;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 3.5;
			break;
		case "python_upgraded_zm":
			final_damage = 1500;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 2;
			break;
		case "m14_upgraded_zm":
			final_damage = 400;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 3;
			break;
		case "mp40_upgraded_zm":
			final_damage = 200;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 5;
			break;
		case "mp5k_upgraded_zm":
		case "mpl_upgraded_zm":
		case "pm63_upgraded_zm":
		case "ppsh_upgraded_zm":
			final_damage = 140;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 5;
			break;
		case "m16_gl_upgraded_zm":
		case "famas_upgraded_zm":
			final_damage = 150;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 5;
			break;
		case "ak74u_upgraded_zm":
			final_damage = 190;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 5;
			break;
		case "aug_acog_upgraded_zm":
			final_damage = 200;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 5;
			break;
		case "commando_upgraded_zm":
		case "ak47_ft_upgraded_zm":
			final_damage = 210;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 5;
			break;
		case "galil_upgraded_zm":
			final_damage = 220;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 5;
			break;
		case "spectre_upgraded_zm":
			final_damage = 130;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 5;
			break;
		case "rpk_upgraded_zm":
			final_damage = 180;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 3;
			break;
		case "hk21_upgraded_zm":
			final_damage = 210;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 3;
			break;
		case "stoner63_upgraded_zm":
			final_damage = 230;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 3;
			break;
		case "psg1_upgraded_zm":
			final_damage = 1000;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 8;
			break;
		case "l96a1_upgraded_zm":
			final_damage = 2000;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 8;
			break;
		case "fnfal_upgraded_zm":
			final_damage = 240;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 5;
			break;
		//UPGRADED CLASSIC WEAPONS
		case "zombie_kar98k_upgraded":
			final_damage = 3000;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 2;
			break;
		case "zombie_gewehr43_upgraded":
			final_damage = 400;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 3;
			break;
		case "zombie_m1carbine_upgraded":
			final_damage = 300;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 4;
			break;
		case "zombie_type100_smg_upgraded":
			final_damage = 200;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 5.5;
			break;
		case "zombie_fg42_upgraded":
			final_damage = 220;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 1.5;
			break;
		case "zombie_stg44_upgraded":
			final_damage = 150;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 5;
			break;
		case "zombie_thompson_upgraded":
			final_damage = 200;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 5;
			break;
		}

		// Death Machine - kills in 3 body shots or 2 headshots
		if(weapon == "minigun_zm" && self.animname != "director_zombie" && self.animname != "astro_zombie")
		{
			min_damage = 500;
			final_damage = int(self.maxhealth / 3) + 1;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
			{
				min_damage *= 2;
				damage *= 2;
			}

			if(final_damage < min_damage)
			{
				final_damage = min_damage;
			}
		}
	}

	//projectile impact damage - all body shots deal the same damage
	//neck, head, and healmet shots all deal the same damage
	if(meansofdeath == "MOD_IMPACT")
	{
		if(weapon == "crossbow_explosive_zm")
		{
			final_damage = 750;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 4;
		}
		else if(weapon == "crossbow_explosive_upgraded_zm")
		{
			final_damage = 2250;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 4;
		}
		else if(weapon == "knife_ballistic_zm" || weapon == "knife_ballistic_bowie_zm" || weapon == "knife_ballistic_sickle_zm")
		{
			final_damage = 500;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 4;
		}
		else if(weapon == "knife_ballistic_upgraded_zm" || weapon == "knife_ballistic_bowie_upgraded_zm" || weapon == "knife_ballistic_sickle_upgraded_zm")
		{
			final_damage = 1000;
			if(sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck")
				final_damage *= 4;
		}
		else if(is_lethal_grenade(weapon) || is_tactical_grenade(weapon))
		{
			final_damage = 30;
		}
	}

	if(weapon == "sniper_explosive_bolt_zm" || weapon == "sniper_explosive_bolt_upgraded_zm" && self.animname == "director_zombie")
	{
		return int(10000);
	}

	if(weapon == "sniper_explosive_bolt_zm" || weapon == "sniper_explosive_bolt_upgraded_zm" && !self.animname == "director_zombie")
	{
		min_damage = 10000;
		final_damage = int(self.maxhealth / 2) + 100;

		if ( final_damage < min_damage && final_damage < 20000 )
		{
			final_damage = min_damage;
		}
	}


	if(attacker HasPerk("specialty_deadshot") && (meansofdeath == "MOD_PISTOL_BULLET" || meansofdeath == "MOD_RIFLE_BULLET") && WeaponClass(weapon) != "spread" && (sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck"))
	{
		final_damage = int(final_damage * 2);
	}

	if((is_placeable_mine(weapon) && (meansofdeath == "MOD_GRENADE" || meansofdeath == "MOD_GRENADE_SPLASH")) && self.animname != "thief_zombie" && self.animname != "director_zombie")
	{
		// fix for grenades doing 1/2 zombies health when holding mines
		if(flags == 5)
		{
			final_damage = int(self.maxhealth / 2) + 10;
		}

		if(damage >= final_damage)
		{
			final_damage = damage;
		}
	}

	if(weapon == "zombie_nesting_dolls" && self.animname != "director_zombie")
	{
		final_damage = int(self.maxhealth) + 666;
	}

	if((weapon == "tesla_gun_zm" || weapon == "tesla_gun_upgraded_zm") && self.animname == "thief_zombie" && self.animname == "director_zombie")
	{
		final_damage = 1500;
	}

	if((weapon == "blundergat_zm" || weapon == "blundergat_upgraded_zm") && meansofdeath == "MOD_RIFLE_BULLET")
	{
		final_damage = int(self.maxhealth) + 666;
	}

	// This approach is bypassing water damage debuff
	if (self.animname == "director_zombie")
	{
		switch(weapon)
		{
		case "m14_zm":
		case "m14_upgraded_zm":
		case "rottweil72_zm":
		case "rottweil72_upgraded_zm":
			final_damage = int(final_damage * 8);
			break;

		case "ray_gun_zm":
		case "m72_law_zm":
			final_damage = int(final_damage * 1.15);
			break;

		case "ray_gun_upgraded_zm":
		case "m72_law_upgraded_zm":
			final_damage = int(final_damage * 1.25);
			break;
		}
	}

	// Absolute multiplier based on max HP of the zombie
	// if (IsDefined(self.animname) && (self.animname == "zombie" || self.animname == "quad_zombie"))
	// {
		// absolute_multiplier = 0.0033;
		// if (attacker HasPerk("specialty_rof"))
		// 	absolute_multiplier = 0.0066;

		// final_damage += int(self.maxhealth * absolute_multiplier);
	// }
	// iPrintLn("final damage: " + final_damage);

	return int( final_damage );

}

is_headshot( sWeapon, sHitLoc, sMeansOfDeath )
{
	return (sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck") && sMeansOfDeath != "MOD_MELEE" && sMeansOfDeath != "MOD_BAYONET" && sMeansOfDeath != "MOD_IMPACT";
}

actor_killed_override(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime)
{
	if ( game["state"] == "postgame" )
		return;

	self SetPlayerCollision(0); // zombies lose collision right as they die


	// force ran over shunk zombies not to drop powerups
	if(sMeansOfDeath == "MOD_UNKNOWN" && (sWeapon == "shrink_ray_zm" || sWeapon == "shrink_ray_upgraded_zm"))
	{
		self.no_powerups = true;
	}

	if( isai(attacker) && isDefined( attacker.script_owner ) )
	{
		// if the person who called the dogs in switched teams make sure they don't
		// get penalized for the kill
		if ( attacker.script_owner.team != self.aiteam )
			attacker = attacker.script_owner;
	}

	if( attacker.classname == "script_vehicle" && isDefined( attacker.owner ) )
		attacker = attacker.owner;

	if( IsPlayer( level.monkey_bolt_holder ) && sMeansOfDeath == "MOD_GRENADE_SPLASH"
			&& ( sWeapon == "crossbow_explosive_upgraded_zm" || sWeapon == "explosive_bolt_upgraded_zm" ) ) //
	{
		level._bolt_on_back = level._bolt_on_back + 1;
	}


	if ( isdefined( attacker ) && isplayer( attacker ) )
	{
		multiplier = 1;
		if( maps\_remix_zombiemode::is_headshot( sWeapon, sHitLoc, sMeansOfDeath ) )
		{
			multiplier = 1.5;
		}

		type = undefined;

		//MM (3/18/10) no animname check
		if ( IsDefined(self.animname) )
		{
			switch( self.animname )
			{
			case "quad_zombie":
				type = "quadkill";
				break;
			case "ape_zombie":
				type = "apekill";
				break;
			case "zombie":
				type = "zombiekill";
				break;
			case "zombie_dog":
				type = "dogkill";
				break;
			}
		}
		//if( isDefined( type ) )
		//{
		//	value = maps\_zombiemode_rank::getScoreInfoValue( type );
		//	self process_assist( type, attacker );

		//	value = int( value * multiplier );
		//	attacker thread maps\_zombiemode_rank::giveRankXP( type, value, false, false );
		//}
	}

	if(is_true(self.is_ziplining))
	{
		self.deathanim = undefined;
	}

	if ( IsDefined( self.actor_killed_override ) )
	{
		self [[ self.actor_killed_override ]]( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime );
	}

}

end_game()
{
	level waittill ( "end_game" );

	clientnotify( "zesn" );

	if (level.win_game && level.script == "zombie_ww")
	{
		level thread maps\_zombiemode_audio::change_zombie_music( "reset" );
	} 
	else
	{
		level thread maps\_zombiemode_audio::change_zombie_music( "game_over" );
	}

	//AYERS: Turn off ANY last stand audio at the end of the game
	players = get_players();
	for( i = 0; i < players.size; i++ )
	{
		setClientSysState( "lsm", "0", players[i] );
	}

	StopAllRumbles();

	level.intermission = true;
	level.zombie_vars["zombie_powerup_insta_kill_time"] = 0;
	level.zombie_vars["zombie_powerup_fire_sale_time"] = 0;
	level.zombie_vars["zombie_powerup_point_doubler_time"] = 0;
	wait 0.1;

	update_leaderboards();

	game_over = [];
	survived = [];

	players = get_players();

	game_over_hud = newHudElem();
	game_over_hud.alignX = "center";
	game_over_hud.alignY = "middle";
	game_over_hud.horzAlign = "center";
	game_over_hud.vertAlign = "middle";
	game_over_hud.y = -130;
	game_over_hud.foreground = true;
	game_over_hud.fontScale = 3;
	game_over_hud.alpha = 0;
	game_over_hud.color = (1.0, 1.0, 1.0);

	survived_hud = newHudElem();
	survived_hud.alignX = "center";
	survived_hud.alignY = "middle";
	survived_hud.horzAlign = "center";
	survived_hud.vertAlign = "middle";
	survived_hud.y = -100;
	survived_hud.foreground = true;
	survived_hud.fontScale = 2;
	survived_hud.alpha = 0;
	survived_hud.color = (1.0, 1.0, 1.0);

	// Split screen ain't on PC anyways, no need to scan all the players
	if (players[0] isSplitScreen())
	{
		game_over_hud.y += 40;
		survived_hud.y += 40;
	}

	if (level.win_game)
		game_over_hud SetText(&"MOD_YOU_WIN");
	else
		game_over_hud SetText(&"ZOMBIE_GAME_OVER");

	//OLD COUNT METHOD
	if( level.round_number < 2 )
	{
		if( level.script == "zombie_moon" )
		{
			if( !isdefined(level.left_nomans_land) )
			{
				player_survival_time_in_mins = maps\_remix_zombiemode_utility::to_mins_short(int(level.nml_best_time / 1000));
				survived_hud SetText(level.total_nml_kills, " kills in ", player_survival_time_in_mins);
			}
			else if( level.left_nomans_land == 2 )
			{
				survived_hud SetText( &"ZOMBIE_SURVIVED_ROUND" );
			}
		}
		else
		{
			survived_hud SetText( &"ZOMBIE_SURVIVED_ROUND" );
		}
	}
	else
	{
		survived_hud SetText( &"ZOMBIE_SURVIVED_ROUNDS", level.round_number );
	}

	game_over_hud FadeOverTime(1);
	game_over_hud.alpha = 1;
	survived_hud FadeOverTime(1);
	survived_hud.alpha = 1;
		
	players = get_players();
	for (i = 0; i < players.size; i++)
	{
		players[i] SetClientDvars( "ammoCounterHide", "1",
				"miniscoreboardhide", "1" );
		//players[i] maps\_zombiemode_solo::solo_destroy_lives_hud();
		//players[i] maps\_zombiemode_ability::clear_hud();
	}
	destroy_chalk_hud();

	UploadStats();

	wait( 1 );

	//play_sound_at_pos( "end_of_game", ( 0, 0, 0 ) );
	wait( 2 );
	intermission();
	wait( level.zombie_vars["zombie_intermission_time"] );

	level notify( "stop_intermission" );
	array_thread( get_players(), ::player_exit_level );

	bbPrint( "zombie_epilogs: rounds %d", level.round_number );

	survived_hud FadeOverTime(1);
	survived_hud.alpha = 0;
	game_over_hud FadeOverTime(1);
	game_over_hud.alpha = 0;

	wait( 1.5 );


/*	we are not currently supporting the shared screen tech
	if( IsSplitScreen() )
	{
		players = get_players();
		for( i = 0; i < players.size; i++ )
		{
			share_screen( players[i], false );
		}
	}
*/

	for ( j = 0; j < get_players().size; j++ )
	{
		player = get_players()[j];
		player CameraActivate( false );

		survived[j] Destroy();
		game_over[j] Destroy();
	}

	if ( level.onlineGame || level.systemLink )
	{
		ExitLevel( false );
	}
	else
	{
		MissionFailed();
	}

	// Let's not exit the function
	wait( 666 );
}
