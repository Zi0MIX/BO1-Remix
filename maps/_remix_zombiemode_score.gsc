#include maps\_utility; 
#include common_scripts\utility;
#include maps\_zombiemode_utility;

player_add_points( event, mod, hit_location ,is_dog)
{
	if( level.intermission )
	{
		return;
	}

	if( !is_player_valid( self ) )
	{
		return;
	}

	player_points = 0;
	team_points = 0;
	multiplier = maps\_zombiemode_score::get_points_multiplier();

	switch( event )
	{
		case "death":
			player_points	= maps\_zombiemode_score::get_zombie_death_player_points();
			team_points		= maps\_zombiemode_score::get_zombie_death_team_points();
			points = player_add_points_kill_bonus( mod, hit_location );
			if( level.zombie_vars["zombie_powerup_insta_kill_on"] == 1 && mod == "MOD_UNKNOWN" )
			{
				points = points * 2;
			}

			// Give bonus points 
			player_points	= player_points + points;
			// Don't give points if there's no team points involved.
			if ( team_points > 0 )
			{
				team_points		= team_points + points;
			}

			if(IsDefined(self.kill_tracker))
			{
				self.kill_tracker++;
			}
			else
			{
				self.kill_tracker = 1;
			}
			//stats tracking
			self.stats["kills"] = self.kill_tracker;

			break; 
	
		case "ballistic_knife_death":
			player_points = maps\_zombiemode_score::get_zombie_death_player_points() + level.zombie_vars["zombie_score_bonus_melee"];

			if(IsDefined(self.kill_tracker))
			{
				self.kill_tracker++;
			}
			else
			{
				self.kill_tracker = 1;
			}
			//stats tracking
			self.stats["kills"] = self.kill_tracker;

			break; 
	
		case "damage_light":
			player_points = level.zombie_vars["zombie_score_damage_light"];
			break;
	
		case "damage":
			player_points = level.zombie_vars["zombie_score_damage_normal"];
			break; 
	
		case "damage_ads":
			player_points = Int( level.zombie_vars["zombie_score_damage_normal"] * 1.25 ); 
			break;

		case "rebuild_board":
		case "carpenter_powerup":
			player_points	= mod;
			break;

		case "bonus_points_powerup":
			player_points	= mod;
			break;

		case "nuke_powerup":
			player_points	= mod;
			team_points		= mod;
			break;
	
		case "thundergun_fling":
			player_points = mod;
			break;
		
		case "hacker_transfer":
			player_points = mod;
			break;
		
		case "reviver":
			player_points = mod;
			break;

		case "blundergat_fling":
			player_points = mod;
			break;

		default:
			assertex( 0, "Unknown point event" ); 
			break; 
	}

	player_points = multiplier * round_up_score( player_points, 5 );
	team_points = multiplier * round_up_score( team_points, 5 );
	
	if ( isdefined( self.point_split_receiver ) && (event == "death" || event == "ballistic_knife_death") )
	{
		split_player_points = player_points - round_up_score( (player_points * self.point_split_keep_percent), 10 );
		self.point_split_receiver maps\_zombiemode_score::add_to_player_score( split_player_points );
		player_points = player_points - split_player_points;
	}

	// Add the points
	self maps\_zombiemode_score::add_to_player_score( player_points );
	players = get_players();
	if ( players.size > 1 )
	{
		self maps\_zombiemode_score::add_to_team_score( team_points );
	}

	//stat tracking
	self.stats["score"] = self.score_total;

//	self thread play_killstreak_vo();
}

player_add_points_kill_bonus( mod, hit_location )
{
	if( mod == "MOD_MELEE" )
	{
		return level.zombie_vars["zombie_score_bonus_melee"]; 
	}

	if( mod == "MOD_BURNED" )
	{
		return level.zombie_vars["zombie_score_bonus_burn"];
	}

	score = 0; 

	switch( hit_location )
	{
		case "head":
		case "helmet":
		case "neck":
			score = level.zombie_vars["zombie_score_bonus_head"]; 
			break; 
		case "torso_upper":
		case "torso_lower":
			score = level.zombie_vars["zombie_score_bonus_torso"]; 
			break; 
	}

	return score; 
}

// Creates a hudelem used for the points awarded/taken away
create_highlight_hud( x, y, value )
{
	font_size = 8; 
	if ( self IsSplitscreen() )
	{
		font_size *= 2;
	}

	hud = create_simple_hud( self );

	// level.hudelem_count++; 

	hud.foreground = true; 
	hud.sort = 0; 
	hud.x = x; 
	hud.y = y; 
	hud.fontScale = font_size; 
	hud.alignX = "right"; 
	hud.alignY = "middle"; 
	hud.horzAlign = "user_right";
	hud.vertAlign = "user_bottom";

	if( value < 1 )
	{
		hud.color = ( 0.15, 0, 0 ); 
		// hud.color = ( 0.21, 0, 0 );
	}
	else
	{
		hud.color = ( 0.9, 0.8, 0.0 );
		// hud.color = ( 0.9, 0.9, 0.0 ); 
		hud.label = &"SCRIPT_PLUS";
	}

	//	hud.glowColor = ( 0.3, 0.6, 0.3 );
	//	hud.glowAlpha = 1; 
	hud.hidewheninmenu = true; 

	hud SetValue( value ); 

	return hud; 	
}

// Handles the creation/movement/deletion of the moving hud elems
//
score_highlight( scoring_player, score, value )
{
	self endon( "disconnect" ); 

	// Location from hud.menu
	score_x = -103;
	score_y = -100;

	if ( self IsSplitscreen() )
	{
		score_y = -95;
	}

	x = score_x;

	// local only splitscreen only displays each player's own score in their own viewport only
	if( !level.onlineGame && !level.systemLink && IsSplitScreen() )
	{
		y = score_y;
	}
	else
	{
		players = get_players();

		num = 0;		
		for ( i = 0; i < players.size; i++ )
		{
			if ( scoring_player == players[i] )
			{
				num = players.size - i - 1;
			}
		}
		y = ( num * -20 ) + score_y;
	}

	if ( self IsSplitscreen() )
	{
		y *= 2;
	}

	if(value < 1)
	{
		y += 5;
	}
	else
	{
		y -= 5;
	}

	time = 0.5; 
	half_time = time * 0.5;
	quarter_time = time * 0.25;

	player_num = scoring_player GetEntityNumber();

	if(value < 1)
	{
		if(IsDefined(self.negative_points_hud) && IsDefined(self.negative_points_hud[player_num]))
		{
			value += self.negative_points_hud_value[player_num];
			self.negative_points_hud[player_num] Destroy();
		}
	}
	else if(IsDefined(self.positive_points_hud) && IsDefined(self.positive_points_hud[player_num]))
	{
		value += self.positive_points_hud_value[player_num];
		self.positive_points_hud[player_num] Destroy();
	}

	hud = self create_highlight_hud( x, y, value ); 

    if( value < 1 )
	{
		if(!IsDefined(self.negative_points_hud))
		{
			self.negative_points_hud = [];
		}
		if(!IsDefined(self.negative_points_hud_value))
		{
			self.negative_points_hud_value = [];
		}
		self.negative_points_hud[player_num] = hud;
		self.negative_points_hud_value[player_num] = value;
	}
	else
	{
		if(!IsDefined(self.positive_points_hud))
		{
			self.positive_points_hud = [];
		}
		if(!IsDefined(self.positive_points_hud_value))
		{
			self.positive_points_hud_value = [];
		}
		self.positive_points_hud[player_num] = hud;
		self.positive_points_hud_value[player_num] = value;
	}

	// Move the hud
	hud MoveOverTime( time ); 
	hud.x -= 50;
	if(value < 1)
	{
		hud.y += 5;
	}
	else
	{
		hud.y -= 5;
	}
	// hud.x -= 20 + RandomInt( 40 ); 
	// hud.y -= ( -15 + RandomInt( 30 ) );

	wait( half_time ); 

	if(!IsDefined(hud))
	{
		return;
	}

	// Fade half-way through the move
	hud FadeOverTime( half_time ); 
	hud.alpha = 0; 

	wait( half_time );

		if(!IsDefined(hud))
	{
		return;
	}

	hud Destroy();
}
