#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;

post_init()
{
	level.no_drops = false;

	PrecacheShader( "specialty_lightningbolt_zombies" );

	set_zombie_var( "zombie_powerup_drop_increment", 1500 );	// lower this to make drop happen more often

	level._effect["powerup_last"] = LoadFX( "explosions/fx_grenade_flash" );

	level.last_powerup = false;
	flag_init("tesla_init");
}

is_valid_powerup(powerup_name)
{
	// Carpenter needs 5 destroyed windows
	if( powerup_name == "carpenter" ) //&& get_num_window_destroyed() < 5
	{
		return false;
	}
	// Don't bring up fire_sale if the box hasn't moved
	else if( powerup_name == "fire_sale" && fire_sale_drop() )
	{
		return false;
	}
	else if( powerup_name == "all_revive" )
	{
		if ( !maps\_laststand::player_num_in_laststand() ) //PI ESM - at least one player have to be down for this power-up to appear
		{
			return false;
		}
	}
	else if ( powerup_name == "bonfire_sale" )	// never drops with regular powerups
	{
		return false;
	}
	else if( powerup_name == "minigun" && minigun_no_drop() ) // don't drop unless life bought in solo, or power has been turned on
	{
		return false;
	}
	// remove double points from powerup cycle on round 60
	else if(  powerup_name == "double_points" && level.round_number >= 60 && (level.script == "zombie_cosmodrome" || level.script == "zombie_pentagon" || level.script == "zombie_coast" || level.script == "zombie_moon"))
	{
		return false;
	}
	else if ( powerup_name == "free_perk" )		// never drops with regular powerups
	{
		return false;
	}
	else if( powerup_name == "tesla" )					// never drops with regular powerups
	{
		return false;
	}
	else if( powerup_name == "random_weapon" )					// never drops with regular powerups
	{
		return false;
	}
	else if( powerup_name == "bonus_points_player" )					// never drops with regular powerups
	{
		return false;
	}
	else if( powerup_name == "bonus_points_team" )					// never drops with regular powerups
	{
		return false;
	}
	else if( powerup_name == "lose_points_team" )					// never drops with regular powerups
	{
		return false;
	}
	else if( powerup_name == "lose_perk" )					// never drops with regular powerups
	{
		return false;
	}
	else if( powerup_name == "empty_clip" )					// never drops with regular powerups
	{
		return false;
	}

	return true;
}

tesla_melee_watcher(ent_player)
{
	ent_player endon( "disconnect" );
	ent_player endon( "death" );

	while (true)
	{
		if (flag("tesla_init") && ent_player getCurrentWeapon() != "tesla_gun_zm")
		{
			flag_clear("tesla_init");
			ent_player allowMelee(true);
			break;
		}

		wait_network_frame();
	}
}

cotd_powerup_offset()
{
	level endon ("disconnect");

	if (level.script != "zombie_coast")
		return;
	dvar_state = 0;

	while (true)
	{
		wait 0.05;

		if (dvar_state == getDvarInt("george_bar_show"))
			continue;

		if (getDvarInt("george_bar_show") == 1)
		{
			for(i = 0; i < 4; i++)
				level.powerup_hud[i].y = -25;		

			players = get_players();
			for( p = 0; p < players.size; p++ )
			{
				for(i = 0; i < players[p].solo_powerup_hud_array.size; i++)
					players[p].solo_powerup_hud[i].y = -25;
			}
		}
		else
		{
			for(i = 0; i < 4; i++)
				level.powerup_hud[i].y = -5;			

			players = get_players();
			for( p = 0; p < players.size; p++ )
			{
				for(i = 0; i < players[p].solo_powerup_hud_array.size; i++)
					players[p].solo_powerup_hud[i].y = -5;
			}
		}

		dvar_state = getDvarInt("george_bar_show");
	}
}

init_powerups()
{
	flag_init( "zombie_drop_powerups" );	// As long as it's set, powerups will be able to spawn
	flag_set( "zombie_drop_powerups" );

	if( !IsDefined( level.zombie_powerup_array ) )
	{
		level.zombie_powerup_array = [];
	}
	if ( !IsDefined( level.zombie_special_drop_array ) )
	{
		level.zombie_special_drop_array = [];
	}

	// Random Drops
	add_zombie_powerup( "double_points","zombie_x2_icon",	&"ZOMBIE_POWERUP_DOUBLE_POINTS", false, false, false );
	add_zombie_powerup( "nuke", 		"zombie_bomb",		&"ZOMBIE_POWERUP_NUKE", false, false, false, 			"misc/fx_zombie_mini_nuke" );
//	add_zombie_powerup( "nuke", 		"zombie_bomb",		&"ZOMBIE_POWERUP_NUKE", false, false, false, 			"misc/fx_zombie_mini_nuke_hotness" );
	add_zombie_powerup( "insta_kill", 	"zombie_skull",		&"ZOMBIE_POWERUP_INSTA_KILL", false, false, false );
	add_zombie_powerup( "full_ammo",  	"zombie_ammocan",	&"ZOMBIE_POWERUP_MAX_AMMO", false, false, false );

	if( !level.mutators["mutator_noBoards"] )
	{
		add_zombie_powerup( "carpenter",  	"zombie_carpenter",	&"ZOMBIE_POWERUP_MAX_AMMO", false, false, false );
	}

	//GZheng - Temp VO
	//add the correct VO for firesale in the 3rd parameter of this function.
	if( !level.mutators["mutator_noMagicBox"] )
	{
		add_zombie_powerup( "fire_sale",  	"zombie_firesale",	&"ZOMBIE_POWERUP_MAX_AMMO", false, false, false );
	}

	add_zombie_powerup( "bonfire_sale",  	"zombie_pickup_bonfire",	&"ZOMBIE_POWERUP_MAX_AMMO", false, false, false );

	//PI ESM - Temp VO
	//TODO add the correct VO for revive all in the 3rd parameter of this function.
	add_zombie_powerup( "all_revive",  	"zombie_revive",	&"ZOMBIE_POWERUP_MAX_AMMO", false, false, false );

	//	add_zombie_special_powerup( "monkey" );

	// additional special "drops"
//	add_zombie_special_drop( "nothing" );
	add_zombie_special_drop( "dog" );

	// minigun
	add_zombie_powerup( "minigun",	"zombie_pickup_minigun", &"ZOMBIE_POWERUP_MINIGUN", true, false, false );

	// free perk
	add_zombie_powerup( "free_perk", "zombie_pickup_perk_bottle", &"ZOMBIE_POWERUP_FREE_PERK", false, false, false );

	// tesla
	add_zombie_powerup( "tesla", "lightning_bolt", &"ZOMBIE_POWERUP_MINIGUN", true, false, false );

	// random weapon
	add_zombie_powerup( "random_weapon", "zombie_pickup_minigun", &"ZOMBIE_POWERUP_MAX_AMMO", true, false, false );

	// bonus points
	add_zombie_powerup( "bonus_points_player", "zombie_z_money_icon", &"ZOMBIE_POWERUP_BONUS_POINTS", true, false, false );
	add_zombie_powerup( "bonus_points_team", "zombie_z_money_icon", &"ZOMBIE_POWERUP_BONUS_POINTS", false, false, false );
	add_zombie_powerup( "lose_points_team", "zombie_z_money_icon", &"ZOMBIE_POWERUP_LOSE_POINTS", false, false, true );

	// lose perk
	add_zombie_powerup( "lose_perk", "zombie_pickup_perk_bottle", &"ZOMBIE_POWERUP_MAX_AMMO", false, false, true );

	// empty clip
	add_zombie_powerup( "empty_clip", "zombie_ammocan", &"ZOMBIE_POWERUP_MAX_AMMO", false, false, true );

	// Randomize the order
	//randomize_powerups();
	level.zombie_powerup_index = 0;
	level.drop_tracker_index = 0;
	//randomize_powerups();

	// Rare powerups
	level.rare_powerups_active = 0;

	//AUDIO: Prevents the long firesale vox from playing more than once
	level.firesale_vox_firstime = false;

	level thread powerup_hud_overlay();
	level thread solo_powerup_hud_overlay();

	if ( isdefined( level.quantum_bomb_register_result_func ) )
	{
		[[level.quantum_bomb_register_result_func]]( "random_powerup", ::quantum_bomb_random_powerup_result, 5, level.quantum_bomb_in_playable_area_validation_func );
		[[level.quantum_bomb_register_result_func]]( "random_zombie_grab_powerup", ::quantum_bomb_random_zombie_grab_powerup_result, 5, level.quantum_bomb_in_playable_area_validation_func );
		[[level.quantum_bomb_register_result_func]]( "random_weapon_powerup", ::quantum_bomb_random_weapon_powerup_result, 60, level.quantum_bomb_in_playable_area_validation_func );
		[[level.quantum_bomb_register_result_func]]( "random_bonus_or_lose_points_powerup", ::quantum_bomb_random_bonus_or_lose_points_powerup_result, 25, level.quantum_bomb_in_playable_area_validation_func );
	}
}

//
powerup_hud_overlay()
{
	level endon ("disconnect");

	level.powerup_hud_array = [];
	level.powerup_hud_array[0] = true;
	level.powerup_hud_array[1] = true;
	level.powerup_hud_array[2] = true;
	level.powerup_hud_array[3] = true;



	level.powerup_hud = [];
	level.powerup_hud_cover = [];



	for(i = 0; i < 4; i++)
	{
		level.powerup_hud[i] = create_simple_hud();
		level.powerup_hud[i].foreground = true;
		level.powerup_hud[i].sort = 2;
		level.powerup_hud[i].hidewheninmenu = false;
		level.powerup_hud[i].alignX = "center";
		level.powerup_hud[i].alignY = "bottom";
		level.powerup_hud[i].horzAlign = "user_center";
		level.powerup_hud[i].vertAlign = "user_bottom";
		level.powerup_hud[i].x = -32 + (i * 15);
		// level.powerup_hud[i].y = level.powerup_hud[i].y - 5; // ww: used to offset by - 78
		level.powerup_hud[i].y = -5;
		level.powerup_hud[i].alpha = 0.8;
	}

	level thread Power_up_hud( "specialty_doublepoints_zombies", level.powerup_hud[0], -44, "zombie_powerup_point_doubler_time", "zombie_powerup_point_doubler_on" );
	level thread Power_up_hud( "specialty_instakill_zombies", level.powerup_hud[1], -04, "zombie_powerup_insta_kill_time", "zombie_powerup_insta_kill_on" );
	level thread Power_up_hud( "specialty_firesale_zombies", level.powerup_hud[2], 36, "zombie_powerup_fire_sale_time", "zombie_powerup_fire_sale_on" );
	level thread Power_up_hud( "zom_icon_bonfire", level.powerup_hud[3], 116, "zombie_powerup_bonfire_sale_time", "zombie_powerup_bonfire_sale_on" );

}

solo_powerup_hud_overlay()
{
	level endon ("disconnect");

	flag_wait( "all_players_connected" );
	wait( 0.1 );  // wait for solo zombie_vars to be initialized in init_player_zombie_vars

	players = get_players();
	for( p = 0; p < players.size; p++ )
	{
		players[p].solo_powerup_hud_array = [];
		players[p].solo_powerup_hud_array[ players[p].solo_powerup_hud_array.size ] = true; // minigun
		players[p].solo_powerup_hud_array[ players[p].solo_powerup_hud_array.size ] = true; // tesla

		players[p].solo_powerup_hud = [];
		players[p].solo_powerup_hud_cover = [];

		for(i = 0; i < players[p].solo_powerup_hud_array.size; i++)
		{
			players[p].solo_powerup_hud[i] = create_simple_hud( players[p] );
			players[p].solo_powerup_hud[i].foreground = true;
			players[p].solo_powerup_hud[i].sort = 2;
			players[p].solo_powerup_hud[i].hidewheninmenu = false;
			players[p].solo_powerup_hud[i].alignX = "center";
			players[p].solo_powerup_hud[i].alignY = "bottom";
			players[p].solo_powerup_hud[i].horzAlign = "user_center";
			players[p].solo_powerup_hud[i].vertAlign = "user_bottom";
			players[p].solo_powerup_hud[i].x = -32 + (i * 15);
			players[p].solo_powerup_hud[i].y = -5;
			players[p].solo_powerup_hud[i].alpha = 0.8;
		}

		players[p] thread solo_power_up_hud( "zom_icon_minigun", players[p].solo_powerup_hud[0], 76, "zombie_powerup_minigun_time", "zombie_powerup_minigun_on" );
		// the weapon powerups are mutually exclusive, so we use the same screen position
		players[p] thread solo_power_up_hud( "specialty_lightningbolt_zombies", players[p].solo_powerup_hud[1], 76, "zombie_powerup_tesla_time", "zombie_powerup_tesla_on" );
	}
}

get_next_powerup()
{
	powerup = level.zombie_powerup_array[ level.zombie_powerup_index ];

	while(1)
	{
		if(is_valid_powerup(level.zombie_powerup_array[level.zombie_powerup_index]))
		{
			level.drop_tracker_index++;
		}
		level.zombie_powerup_index++;

		if( level.zombie_powerup_index >= level.zombie_powerup_array.size )
		{
			level.drop_tracker_index = 0;
			level.zombie_powerup_index = 0;
			randomize_powerups();
			level.last_powerup = true;
		}

		if(is_valid_powerup(level.zombie_powerup_array[level.zombie_powerup_index]))
		{
			break;
		}
	}

	return powerup;
}

// Powerup Rules:
// 	 "double_points": gets removed after 65
//   "fire_sale": after round 5 and box has not moved
get_valid_powerup()
{
/#
	if( isdefined( level.zombie_devgui_power ) && level.zombie_devgui_power == 1 )
		return level.zombie_powerup_array[ level.zombie_powerup_index ];
#/

	if ( isdefined( level.zombie_powerup_boss ) )
	{
		i = level.zombie_powerup_boss;
		level.zombie_powerup_boss = undefined;
		return level.zombie_powerup_array[ i ];
	}

	if ( isdefined( level.zombie_powerup_ape ) )
	{
		powerup = level.zombie_powerup_ape;
		level.zombie_powerup_ape = undefined;
		return powerup;
	}

	powerup = get_next_powerup();
	while( 1 )
	{
		if(!is_valid_powerup(powerup))
		{
			powerup = get_next_powerup();
		}
		else
		{
			return( powerup );
		}
	}
}

fire_sale_drop()
{
	if ( level.round_number > 5 && level.chest_moves == 0 )
	{
		return false;
	}
	else
	{
		return true;
	}
}

minigun_no_drop()
{
	//mini only drops after round 60
	if( level.round_number >= 60 && (level.script == "zombie_cosmodrome" || level.script == "zombie_pentagon" || level.script == "zombie_coast" || level.script == "zombie_moon"))
	{
		return false;
	}
	else
	{
		return true; // true means no drop
	}

	// players = GetPlayers();
	// for ( i=0; i<players.size; i++ )
	// {
	// 	if ( players[i] HasPerk( "specialty_quickrevive" ) )
	// 	{
	// 		return false;
	// 	}

	// }
	// return true;
}

powerup_drop(drop_point)
{
	if( level.mutators["mutator_noPowerups"] )
	{
		return;
	}

	if( level.no_drops == true)
	{
		return;
	}

	if( level.powerup_drop_count >= level.zombie_vars["zombie_powerup_drop_max_per_round"] )
	{
/#
		println( "^3POWERUP DROP EXCEEDED THE MAX PER ROUND!" );
#/
		return;
	}

	if( !isDefined(level.zombie_include_powerups) || level.zombie_include_powerups.size == 0 )
	{
		return;
	}

	// some guys randomly drop, but most of the time they check for the drop flag
	rand_drop = randomint(100);

	// changed from 3% to 5%
	if (rand_drop > 4)
	{
		if (!level.zombie_vars["zombie_drop_item"])
		{
			return;
		}

		debug = "score";
	}
	else
	{
		debug = "random";
	}

	// Never drop unless in the playable area
	playable_area = getentarray("player_volume","script_noteworthy");

	// This needs to go above the network_safe_spawn because that has a wait.
	//	Otherwise, multiple threads could attempt to drop powerups.
	level.powerup_drop_count++;

	powerup = maps\_zombiemode_net::network_safe_spawn( "powerup", 1, "script_model", drop_point + (0,0,40));

	//chris_p - fixed bug where you could not have more than 1 playable area trigger for the whole map
	valid_drop = false;
	for (i = 0; i < playable_area.size; i++)
	{
		if (powerup istouching(playable_area[i]))
		{
			valid_drop = true;
		}
	}

	// If a valid drop
	// We will rarely override the drop with a "rare drop"  (MikeA 3/23/10)
	if( valid_drop && level.rare_powerups_active )
	{
		pos = ( drop_point[0], drop_point[1], drop_point[2] + 42 );
		if( check_for_rare_drop_override( pos ) )
		{
			level.zombie_vars["zombie_drop_item"] = 0;
			valid_drop = 0;
		}
	}

	// If not a valid drop, allow another spawn to be attempted
	if(! valid_drop )
	{
		level.powerup_drop_count--;
		powerup delete();
		return;
	}

	powerup powerup_setup();

	print_powerup_drop( powerup.powerup_name, debug );

	if(level.last_powerup)
	{
		//iprintln("last powerup");
		if(powerup.caution)
		{
			playfx( level._effect["powerup_grabbed_red"], powerup.origin );
			playfx(level._effect["powerup_grabbed_wave_caution"], powerup.orgin );
		}
		else
		{
			playfx(level._effect["powerup_grabbed_wave_caution"], powerup.orgin );
			playfx( level._effect["powerup_grabbed"], powerup.origin );
		}
		PlayFX( level._effect["powerup_last"], powerup.origin );
		level.last_powerup = false;
	}

	powerup thread powerup_timeout();
	powerup thread powerup_wobble();
	powerup thread powerup_grab();

	level.zombie_vars["zombie_drop_item"] = 0;

	// RAVEN BEGIN bhackbarth: let the level know that a powerup has been dropped
	level notify("powerup_dropped", powerup);
	// RAVEN END
}

//	Pick the next powerup in the list
powerup_setup( powerup_override )
{
	powerup = undefined;

	if ( !IsDefined( powerup_override ) )
	{
		powerup = get_valid_powerup();
	}
	else
	{
		powerup = powerup_override;

		/*if ( "tesla" == powerup && tesla_powerup_active() )
		{
			// only one tesla at a time, give a minigun instead
			powerup = "minigun";
		}*/
	}

	struct = level.zombie_powerups[powerup];

	if ( powerup == "random_weapon" )
	{
		// select the weapon for this instance of random_weapon
		self.weapon = maps\_zombiemode_weapons::treasure_chest_ChooseWeightedRandomWeapon();

/#
		weapon = GetDvar( #"scr_force_weapon" );
		if ( weapon != "" && IsDefined( level.zombie_weapons[ weapon ] ) )
		{
			self.weapon = weapon;
			SetDvar( "scr_force_weapon", "" );
		}
#/

		self.base_weapon = self.weapon;
		if ( !isdefined( level.random_weapon_powerups ) )
		{
			level.random_weapon_powerups = [];
		}
		level.random_weapon_powerups[level.random_weapon_powerups.size] = self;
		self thread cleanup_random_weapon_list();

		if ( IsDefined( level.zombie_weapons[self.weapon].upgrade_name ) && !RandomInt( 4 ) ) // 25% chance
		{
			self.weapon = level.zombie_weapons[self.weapon].upgrade_name;
		}

		self SetModel( GetWeaponModel( self.weapon ) );
		self useweaponhidetags( self.weapon );

		offsetdw = ( 3, 3, 3 );
		self.worldgundw = undefined;
		if ( maps\_zombiemode_weapons::weapon_is_dual_wield( self.weapon ) )
		{
			self.worldgundw = spawn( "script_model", self.origin + offsetdw );
			self.worldgundw.angles  = self.angles;
			self.worldgundw setModel( maps\_zombiemode_weapons::get_left_hand_weapon_model_name( self.weapon ) );
			self.worldgundw useweaponhidetags( self.weapon );
			self.worldgundw LinkTo( self, "tag_weapon", offsetdw, (0, 0, 0) );
		}
	}
	else
	{
		self SetModel( struct.model_name );
	}

	if(powerup == "tesla")
	{
		self.weapon = "tesla_gun_zm";
		self.base_weapon = self.weapon;
		struct.weapon = self.weapon;
	}


	//TUEY Spawn Powerup
	playsoundatposition("zmb_spawn_powerup", self.origin);

	self.powerup_name 		= struct.powerup_name;
	self.hint 				= struct.hint;
	self.solo 				= struct.solo;
	self.caution 			= struct.caution;
	self.zombie_grabbable 	= struct.zombie_grabbable;

	if( IsDefined( struct.fx ) )
	{
		self.fx = struct.fx;
	}

	self PlayLoopSound("zmb_spawn_powerup_loop");
}

powerup_grab()
{
	if ( isdefined( self ) && self.zombie_grabbable )
	{
		self thread powerup_zombie_grab();
		return;
	}

	self endon ("powerup_timedout");
	self endon ("powerup_grabbed");

	range_squared = 64 * 64;
	while (isdefined(self))
	{
		players = get_players();

		for (i = 0; i < players.size; i++)
		{
			// Don't let them grab the minigun, tesla, or random weapon if they're downed or reviving
			//	due to weapon switching issues.
			if ( (self.powerup_name == "minigun" || self.powerup_name == "tesla" || self.powerup_name == "random_weapon") &&
				( players[i] maps\_laststand::player_is_in_laststand() ||
				  ( players[i] UseButtonPressed() && players[i] in_revive_trigger() ) ) )
			{
				continue;
			}

			if ( DistanceSquared( players[i].origin, self.origin ) < range_squared )
			{
				if( IsDefined( level.zombie_powerup_grab_func ) )
				{
					level thread [[level.zombie_powerup_grab_func]]();
				}
				else
				{
					switch (self.powerup_name)
					{
					case "nuke":
						level thread nuke_powerup( self );

						//chrisp - adding powerup VO sounds
						players[i] thread powerup_vo("nuke");
						zombies = getaiarray("axis");
						players[i].zombie_nuked = get_array_of_closest( self.origin, zombies );
						players[i] notify("nuke_triggered");

						break;
					case "full_ammo":
						level thread full_ammo_powerup( self );
						players[i] thread powerup_vo("full_ammo");
						break;
					case "double_points":
						level thread double_points_powerup( self );
						players[i] thread powerup_vo("double_points");
						break;
					case "insta_kill":
						level thread insta_kill_powerup( self );
						players[i] thread powerup_vo("insta_kill");
						break;
					case "carpenter":
						if(isDefined(level.use_new_carpenter_func))
						{
							level thread [[level.use_new_carpenter_func]](self.origin);
						}
						else
						{
							level thread start_carpenter( self.origin );
						}
						players[i] thread powerup_vo("carpenter");
						break;

					case "fire_sale":
						level thread start_fire_sale( self );
						players[i] thread powerup_vo("firesale");
						break;

					case "bonfire_sale":
						level thread start_bonfire_sale( self );
						players[i] thread powerup_vo("firesale");
						break;

					case "minigun":
						level thread minigun_weapon_powerup( players[i] );
						players[i] thread powerup_vo( "minigun" );
						break;

					case "free_perk":
						level thread free_perk_powerup( self );
						//players[i] thread powerup_vo( "insta_kill" );
						break;

					case "all_revive":
						level thread start_revive_all( self );
						players[i] thread powerup_vo("revive");
						break;

					case "tesla":
						level thread tesla_weapon_powerup( players[i] );
						level thread tesla_melee_watcher(players[i]);
						players[i] thread powerup_vo( "tesla" ); // TODO: Audio should uncomment this once the sounds have been set up
						break;

					case "random_weapon":
						if ( !level random_weapon_powerup( self, players[i] ) )
						{
							continue;
						}
						// players[i] thread powerup_vo( "random_weapon" ); // TODO: Audio should uncomment this once the sounds have been set up
						break;

					case "bonus_points_player":
						level thread bonus_points_player_powerup( self, players[i] );
						players[i] thread powerup_vo( "bonus_points_solo" ); // TODO: Audio should uncomment this once the sounds have been set up
						break;

					case "bonus_points_team":
						level thread bonus_points_team_powerup( self );
						players[i] thread powerup_vo( "bonus_points_team" ); // TODO: Audio should uncomment this once the sounds have been set up
						break;

					default:
						// RAVEN BEGIN bhackbarth: callback for level specific powerups
						if ( IsDefined( level._zombiemode_powerup_grab ) )
						{
							level thread [[ level._zombiemode_powerup_grab ]]( self );
						}
						// RAVEN END
						else
						{
							println ("Unrecognized poweup.");
						}

						break;

					}
				}

				if ( self.solo )
				{
					playfx( level._effect["powerup_grabbed_solo"], self.origin );
					playfx( level._effect["powerup_grabbed_wave_solo"], self.origin );
				}
				else if ( self.caution )
				{
					playfx( level._effect["powerup_grabbed_caution"], self.origin );
					playfx( level._effect["powerup_grabbed_wave_caution"], self.origin );
				}
				else
				{
					playfx( level._effect["powerup_grabbed"], self.origin );
					playfx( level._effect["powerup_grabbed_wave"], self.origin );
				}

				if ( is_true( self.stolen ) )
				{
					level notify( "monkey_see_monkey_dont_achieved" );
				}

				// RAVEN BEGIN bhackbarth: since there is a wait here, flag the powerup as being taken
				self.claimed = true;
				self.power_up_grab_player = players[i]; //Player who grabbed the power up
				// RAVEN END

				wait( 0.1 );

				playsoundatposition("zmb_powerup_grabbed", self.origin);
				self stoploopsound();

				//Preventing the line from playing AGAIN if fire sale becomes active before it runs out
				if( self.powerup_name != "fire_sale" )
				{
				    level thread maps\_zombiemode_audio::do_announcer_playvox( level.devil_vox["powerup"][self.powerup_name] );
				}

				if ( isdefined( self.worldgundw ) )
				{
					self.worldgundw delete();
				}
				self delete();
				self notify ("powerup_grabbed");
			}
		}
		wait 0.1;
	}
}

// kill them all!
nuke_powerup( drop_item )
{
	zombies = getaispeciesarray("axis");
	location = drop_item.origin;

	PlayFx( drop_item.fx, location );
	level thread nuke_flash();

	wait( 0.5 );


	zombies = get_array_of_closest( location, zombies );
	zombies_nuked = [];

	// Mark them for death
	for (i = 0; i < zombies.size; i++)
	{
		// already going to die
		if ( IsDefined(zombies[i].marked_for_death) && zombies[i].marked_for_death )
		{
			continue;
		}

		// check for custom damage func
		if ( IsDefined(zombies[i].nuke_damage_func) )
		{
 			zombies[i] thread [[ zombies[i].nuke_damage_func ]]();
			continue;
		}

		if( is_magic_bullet_shield_enabled( zombies[i] ) )
		{
			continue;
		}

		zombies[i].marked_for_death = true;
		zombies[i].nuked = true;
		zombies_nuked[ zombies_nuked.size ] = zombies[i];
	}

 	for (i = 0; i < zombies_nuked.size; i++)
  	{
 		wait (0.2);
 		if( !IsDefined( zombies_nuked[i] ) )
 		{
 			continue;
 		}

 		if( is_magic_bullet_shield_enabled( zombies_nuked[i] ) )
 		{
 			continue;
 		}

 		if( i < 5 && !( zombies_nuked[i].isdog ) )
 		{
 			zombies_nuked[i] thread animscripts\zombie_death::flame_death_fx();
 			zombies_nuked[i] playsound ("evt_nuked");

 		}

 		if( !( zombies_nuked[i].isdog ) )
 		{
			if ( !is_true( zombies_nuked[i].no_gib ) )
			{
	 			zombies_nuked[i] maps\_zombiemode_spawner::zombie_head_gib();
	 		}
 			zombies_nuked[i] playsound ("evt_nuked");
 		}


 		zombies_nuked[i] dodamage( zombies_nuked[i].health + 666, zombies_nuked[i].origin );
 	}

	players = get_players();
	for(i = 0; i < players.size; i++)
	{
		players[i] maps\_zombiemode_score::player_add_points( "nuke_powerup", 400 );
	}
}

// double the points
double_points_powerup( drop_item )
{
	level notify ("powerup points scaled");
	level endon ("powerup points scaled");

	//	players = get_players();
	//	array_thread(level,::point_doubler_on_hud, drop_item);
	level thread point_doubler_on_hud( drop_item );

	level.zombie_vars["zombie_point_scalar"] = 2;

	wait self.zombie_vars["zombie_powerup_point_doubler_time"];

	level.zombie_vars["zombie_point_scalar"] = 1;
}

double_points_powerup( drop_item )
{
	level notify ("powerup points scaled");
	level endon ("powerup points scaled");

	//	players = get_players();
	//	array_thread(level,::point_doubler_on_hud, drop_item);
	level thread point_doubler_on_hud( drop_item );

	level.zombie_vars["zombie_point_scalar"] = 2;

	wait self.zombie_vars["zombie_powerup_point_doubler_time"];

	level.zombie_vars["zombie_point_scalar"] = 1;
}

full_ammo_powerup( drop_item )
{
	players = get_players();
	for (i = 0; i < players.size; i++)
	{
		// skip players in last stand
		if ( players[i] maps\_laststand::player_is_in_laststand() )
		{
			continue;
		}

		primary_weapons = players[i] GetWeaponsList();

		players[i] notify( "zmb_max_ammo" );
		players[i] notify( "zmb_lost_knife" );
		players[i] notify( "zmb_disable_claymore_prompt" );
		players[i] notify( "zmb_disable_spikemore_prompt" );
		for( x = 0; x < primary_weapons.size; x++ )
		{
			// Fill the clip
			//players[i] SetWeaponAmmoClip( primary_weapons[x], WeaponClipSize( primary_weapons[x] ) );
			
			//players[i] GiveMaxAmmo( primary_weapons[x] );
			

			// weapon only uses clip ammo, so GiveMaxAmmo won't work
			if(WeaponMaxAmmo(primary_weapons[x]) == 0)
			{
				players[i] SetWeaponAmmoClip(primary_weapons[x], WeaponClipSize(primary_weapons[x]));
				continue;
			}

			//players[i] maps\_zombiemode_weapons::give_max_ammo(primary_weapons[x]);
			players[i] GiveMaxAmmo( primary_weapons[x] );

			// fix for grenade ammo
			if(is_lethal_grenade(primary_weapons[x]) || is_tactical_grenade(primary_weapons[x]))
			{
				ammo = 0;
				if(is_lethal_grenade(primary_weapons[x]))
				{
					ammo = 4;
				}
				else if(is_tactical_grenade(primary_weapons[x]))
				{
					ammo = 3;
				}

				players[i] SetWeaponAmmoClip(primary_weapons[x], ammo);
			}
		}
	}
	//	array_thread (players, ::full_ammo_on_hud, drop_item);
	level thread full_ammo_on_hud( drop_item );
}

insta_kill_powerup( drop_item )
{
	level notify( "powerup instakill" );
	level endon( "powerup instakill" );
	self endon ("disconnect");


	//	array_thread (players, ::insta_kill_on_hud, drop_item);
	level thread insta_kill_on_hud( drop_item );

	level.zombie_vars["zombie_insta_kill"] = 1;
	wait self.zombie_vars["zombie_powerup_insta_kill_time"];
	level.zombie_vars["zombie_insta_kill"] = 0;
	players = get_players();
	for(i = 0; i < players.size; i++)
	{
		players[i] notify("insta_kill_over");

	}

}

check_for_instakill( player, mod, hit_location )
{
	if( level.mutators["mutator_noPowerups"] )
	{
		return;
	}
	if( IsDefined( player ) && IsAlive( player ) && level.zombie_vars["zombie_insta_kill"])
	{
		if( is_magic_bullet_shield_enabled( self ) )
		{
			return;
		}

		if( IsDefined(self.animname) && self.animname == "director_zombie" )
		{
			return;
		}

		if(player.use_weapon_type == "MOD_MELEE")
		{
			player.last_kill_method = "MOD_MELEE";
		}
		else
		{
			player.last_kill_method = "MOD_UNKNOWN";

		}

		modName = remove_mod_from_methodofdeath( mod );
		if( flag( "dog_round" ) )
		{
			self DoDamage( self.health * 10, self.origin, player, undefined, modName, hit_location );
			player notify("zombie_killed");
		}
		else
		{
			self maps\_zombiemode_spawner::zombie_head_gib();
			self DoDamage( self.health * 10, self.origin, player, undefined, modName, hit_location );
			player notify("zombie_killed");

		}
	}
}

insta_kill_on_hud( drop_item )
{
	self endon ("disconnect");

	// check to see if this is on or not
	if ( level.zombie_vars["zombie_powerup_insta_kill_on"] )
	{
		// reset the time and keep going
		level.zombie_vars["zombie_powerup_insta_kill_time"] += 30;
		return;
	}

	else
	{
		self.zombie_vars["zombie_powerup_insta_kill_time"] = 30;
	}

	level.zombie_vars["zombie_powerup_insta_kill_on"] = true;

	// set up the hudelem
	//hudelem = maps\_hud_util::createFontString( "objective", 2 );
	//hudelem maps\_hud_util::setPoint( "TOP", undefined, 0, level.zombie_vars["zombie_timer_offset"] + level.zombie_vars["zombie_timer_offset_interval"]);
	//hudelem.sort = 0.5;
	//hudelem.alpha = 0;
	//hudelem fadeovertime(0.5);
	//hudelem.alpha = 1;
	//hudelem.label = drop_item.hint;

	// set time remaining for insta kill
	level thread time_remaning_on_insta_kill_powerup();

	// offset in case we get another powerup
	//level.zombie_timer_offset -= level.zombie_timer_offset_interval;
}

time_remaning_on_insta_kill_powerup()
{
	self endon ("disconnect");
	//self setvalue( level.zombie_vars["zombie_powerup_insta_kill_time"] );
	//level thread maps\_zombiemode_audio::do_announcer_playvox( level.devil_vox["powerup"]["instakill"] );
	temp_enta = spawn("script_origin", (0,0,0));
	temp_enta playloopsound("zmb_insta_kill_loop");

	/*
	players = get_players();
	for (i = 0; i < players.size; i++)
	{
	players[i] playloopsound ("zmb_insta_kill_loop");
	}
	*/


	// time it down!
	while ( level.zombie_vars["zombie_powerup_insta_kill_time"] >= 0)
	{
		wait 0.1;
		level.zombie_vars["zombie_powerup_insta_kill_time"] = level.zombie_vars["zombie_powerup_insta_kill_time"] - 0.1;
	//	self setvalue( level.zombie_vars["zombie_powerup_insta_kill_time"] );
	}

	players = get_players();
	for (i = 0; i < players.size; i++)
	{
		//players[i] stoploopsound (2);

		players[i] playsound("zmb_insta_kill");

	}

	temp_enta stoploopsound(2);
	// turn off the timer
	level.zombie_vars["zombie_powerup_insta_kill_on"] = false;

	// remove the offset to make room for new powerups, reset timer for next time
	level.zombie_vars["zombie_powerup_insta_kill_time"] = 30;
	//level.zombie_timer_offset += level.zombie_timer_offset_interval;
	//self destroy();
	temp_enta delete();
}

point_doubler_on_hud( drop_item )
{
	self endon ("disconnect");

	// check to see if this is on or not
	if ( level.zombie_vars["zombie_powerup_point_doubler_on"] )
	{
		// reset the time and keep going
		level.zombie_vars["zombie_powerup_point_doubler_time"] += 30;
		return;
	}
	else
	{
		self.zombie_vars["zombie_powerup_point_doubler_time"] = 30;
	}

	level.zombie_vars["zombie_powerup_point_doubler_on"] = true;
	//level.powerup_hud_array[0] = true;
	// set up the hudelem
	//hudelem = maps\_hud_util::createFontString( "objective", 2 );
	//hudelem maps\_hud_util::setPoint( "TOP", undefined, 0, level.zombie_vars["zombie_timer_offset"] );
	//hudelem.sort = 0.5;
	//hudelem.alpha = 0;
	//hudelem fadeovertime( 0.5 );
	//hudelem.alpha = 1;
	//hudelem.label = drop_item.hint;

	// set time remaining for point doubler
	level thread time_remaining_on_point_doubler_powerup();

	// offset in case we get another powerup
	//level.zombie_timer_offset -= level.zombie_timer_offset_interval;
}

time_remaining_on_point_doubler_powerup()
{
	//self setvalue( level.zombie_vars["zombie_powerup_point_doubler_time"] );
	temp_ent = undefined;
	players = get_players();
	if(self == players[0])
	{
		temp_ent = spawn("script_origin", (0,0,0));
		temp_ent playloopsound ("zmb_double_point_loop");
	}

	//level thread maps\_zombiemode_audio::do_announcer_playvox( level.devil_vox["powerup"]["doublepoints"] );


	// time it down!
	while ( self.zombie_vars["zombie_powerup_point_doubler_time"] >= 0)
	{
		wait 0.1;
		self.zombie_vars["zombie_powerup_point_doubler_time"] = self.zombie_vars["zombie_powerup_point_doubler_time"] - 0.1;
		//self setvalue( level.zombie_vars["zombie_powerup_point_doubler_time"] );
	}

	// turn off the timer
	self.zombie_vars["zombie_powerup_point_doubler_on"] = false;

	self playsound("zmb_points_loop_off");
	if(IsDefined(temp_ent))
		temp_ent stoploopsound(2);


	// remove the offset to make room for new powerups, reset timer for next time
	self.zombie_vars["zombie_powerup_point_doubler_time"] = 30;
	//level.zombie_timer_offset += level.zombie_timer_offset_interval;
	//self destroy();
	if(IsDefined(temp_ent))
		temp_ent delete();
}

minigun_weapon_powerup( ent_player, time )
{
	ent_player endon( "disconnect" );
	ent_player endon( "death" );
	ent_player endon( "player_downed" );

	if ( !IsDefined( time ) )
	{
		if( IsDefined(level.longer_minigun_reward) && level.longer_minigun_reward )
			time = 90;
		else
			time = 30;
	}
	/*if( !IsDefined(time) && IsDefined(level.longer_minigun_reward) && level.longer_minigun_reward )
	{
		time = 90;
	}*/

	// Just replenish the time if it's already active
	if ( ent_player.zombie_vars[ "zombie_powerup_minigun_on" ] &&
		 ("minigun_zm" == ent_player GetCurrentWeapon() || (IsDefined(ent_player.has_minigun) && ent_player.has_minigun) ))
	{
		ent_player.zombie_vars["zombie_powerup_minigun_time"] += time;
		return;
	}

	ent_player notify( "replace_weapon_powerup" );
	ent_player._show_solo_hud = true;

	// make sure weapons are replaced properly if the player is downed
	level._zombie_minigun_powerup_last_stand_func = ::minigun_watch_gunner_downed;
	ent_player.has_minigun = true;
	ent_player.has_powerup_weapon = true;

	ent_player increment_is_drinking();
	ent_player._zombie_gun_before_minigun = ent_player GetCurrentWeapon();

	// give player a minigun
	ent_player GiveWeapon( "minigun_zm" );
	ent_player SwitchToWeapon( "minigun_zm" );

	ent_player.zombie_vars[ "zombie_powerup_minigun_on" ] = true;

	level thread minigun_weapon_powerup_countdown( ent_player, "minigun_time_over", time );
	level thread minigun_weapon_powerup_replace( ent_player, "minigun_time_over" );
	level thread minigun_weapon_powerup_weapon_change( ent_player, "minigun_time_over" );
}

minigun_weapon_powerup_remove( ent_player, str_gun_return_notify, weapon_swap )
{
	ent_player endon( "death" );
	ent_player endon( "player_downed" );

	if(!IsDefined(weapon_swap))
	{
		weapon_swap = true;
	}

	ent_player.zombie_vars[ "zombie_powerup_minigun_on" ] = false;
	ent_player._show_solo_hud = false;

	if(weapon_swap)
	{
		primaryWeapons = ent_player GetWeaponsListPrimaries();
		if( IsDefined( ent_player._zombie_gun_before_minigun ) && ent_player HasWeapon(ent_player._zombie_gun_before_minigun) )
		{
			ent_player SwitchToWeapon( ent_player._zombie_gun_before_minigun );
		}
		else if( primaryWeapons.size > 0 )
		{
			ent_player SwitchToWeapon( primaryWeapons[0] );
		}
		else
		{
			ent_player SwitchToWeapon("combat_" + ent_player get_player_melee_weapon());
		}
	}

	ent_player DisableWeaponCycling();
	ent_player waittill("weapon_change");

	ent_player TakeWeapon( "minigun_zm" );

	ent_player.has_minigun = false;
	ent_player.has_powerup_weapon = false;

	ent_player notify( str_gun_return_notify );

	ent_player decrement_is_drinking();
}

minigun_weapon_powerup_weapon_change( ent_player, str_gun_return_notify )
{
	ent_player endon( "death" );
	ent_player endon( "disconnect" );
	ent_player endon( "player_downed" );
	ent_player endon( str_gun_return_notify );
	ent_player endon( "replace_weapon_powerup" );

	while(ent_player GetCurrentWeapon() != "minigun_zm")
	{
		ent_player waittill("weapon_change_complete");
	}
	ent_player EnableWeaponCycling();

	while(!ent_player IsSwitchingWeapons())
	{
		wait_network_frame();
	}

	level thread minigun_weapon_powerup_remove( ent_player, str_gun_return_notify, false );
}

minigun_watch_gunner_downed()
{
	if ( !is_true( self.has_minigun ) )
	{
		return;
	}

	if(self HasWeapon("minigun_zm"))
	{
		self TakeWeapon( "minigun_zm" );
	}

	// self decrement_is_drinking();

	// this gives the player back their weapons
	self notify( "minigun_time_over" );
	self.zombie_vars[ "zombie_powerup_minigun_on" ] = false;
	self._show_solo_hud = false;

	// wait a frame to let last stand finish initializing so that
	// the wholethe system knows we went into last stand with a powerup weapon
	wait( 0.05 );
	self.has_minigun = false;
	self.has_powerup_weapon = false;
}

tesla_weapon_powerup( ent_player, time )
{
	ent_player endon( "disconnect" );
	ent_player endon( "death" );
	ent_player endon( "player_downed" );

	if ( !IsDefined( time ) )
	{
		time = 11; // no blink
	}

	// Just replenish the time if it's already active
	if ( ent_player.zombie_vars[ "zombie_powerup_tesla_on" ] &&
		 ("tesla_gun_zm" == ent_player GetCurrentWeapon() || (IsDefined(ent_player.has_tesla) && ent_player.has_tesla) ))
	{
		ent_player GiveMaxAmmo( "tesla_gun_zm" );
		if ( ent_player.zombie_vars[ "zombie_powerup_tesla_time" ] < time )
		{
			ent_player.zombie_vars[ "zombie_powerup_tesla_time" ] = time;
		}
		return;
	}

	ent_player notify( "replace_weapon_powerup" );
	ent_player._show_solo_hud = true;

	// make sure weapons are replaced properly if the player is downed
	level._zombie_tesla_powerup_last_stand_func = ::tesla_watch_gunner_downed;
	ent_player.has_tesla = true;
	ent_player.has_powerup_weapon = true;

	ent_player increment_is_drinking();
	ent_player._zombie_gun_before_tesla = ent_player GetCurrentWeapon();

	// give player a minigun
	ent_player GiveWeapon( "tesla_gun_zm" );
	ent_player GiveMaxAmmo( "tesla_gun_zm" );
	ent_player SwitchToWeapon( "tesla_gun_zm" );

	ent_player.zombie_vars[ "zombie_powerup_tesla_on" ] = true;

	level thread tesla_weapon_powerup_countdown( ent_player, "tesla_time_over", time );
	level thread tesla_weapon_powerup_replace( ent_player, "tesla_time_over" );
	level thread tesla_weapon_powerup_weapon_change( ent_player, "tesla_time_over" );
}

tesla_weapon_powerup_weapon_change( ent_player, str_gun_return_notify )
{
    ent_player endon( "death" );
    ent_player endon( "disconnect" );
    ent_player endon( "player_downed" );
    ent_player endon( str_gun_return_notify );
    ent_player endon( "replace_weapon_powerup" );

	removed_melee = "";
	melee_removed = false;

    while(ent_player GetCurrentWeapon() != "tesla_gun_zm")
    {
        ent_player waittill("weapon_change_complete");
    }

	if (isDefined(flag("tesla_init")))
		flag_set("tesla_init");
    ent_player EnableWeaponCycling();

	while(ent_player GetAmmoCount("tesla_gun_zm") > 0)
	{
		if (ent_player IsSwitchingWeapons())
			break;

		while (ent_player getWeaponAmmoClip("tesla_gun_zm") == 0)
		{
			if (isDefined(level.fix_wunderwaffe) && level.fix_wunderwaffe && !melee_removed)
			{
				ent_player AllowMelee(false);
				melee_removed = true;
			}
			wait_network_frame();
		}

		if (melee_removed)
		{
			ent_player AllowMelee(true);
			melee_removed = false;
		}

		wait_network_frame();
	}

	if (isDefined(flag("tesla_init")))
		flag_clear("tesla_init");

    level thread tesla_weapon_powerup_remove( ent_player, str_gun_return_notify, false );
}
