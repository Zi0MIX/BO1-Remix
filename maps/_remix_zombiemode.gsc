remix_main()
{
	precachemenu("clientdvar");

	// limited betties/claymores on the map
	level.max_mines = 10;

	// added win con
	level.win_game = false;

	//level.start_time = GetTime();

    level.global_print_hud_color = (1, 1, 1);

	level.total_pause_time = 0;
	level.last_special_round = -1;	// Set to negative to not mess with hud

    init_hud_dvars();

	//isClientPluto("com_useConfig", "");

	level thread remix_post_all_players_connected();
}

remix_post_all_players_connected()
{
	flag_wait("all_players_connected");

	/* Wait 0.05 to override */
	wait 0.05;
	players = get_players();

	for (p = 0; p < players.size; p++)
	{
		players[p].score = 555;
		players[p].score_total = players[p].score;
		players[p].old_score = players[p].score;
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

	// Pluto HUD
    maps\_remix_zombiemode_utility::init_dvar("hud_pluto", 0);

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
