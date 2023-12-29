display_time_survived()
{
	players = get_players();

	level.nml_best_time = GetTime() - level.nml_start_time;
	
	//Should only be 1 player......
	level.nml_kills = players[0].kills;
	level.nml_score = players[0].score_total;
	level.nml_didteleport = true;
	level.nml_pap = 0;
	level.nml_speed = 0;
	level.nml_jugg = 0;
	
	level.left_nomans_land = 1;

	survived = [];
	for( i = 0; i < players.size; i++ )
	{
		//Store the perk and pap values
		if( isdefined(players[i].pap_used) && players[i].pap_used )
		{
			level.nml_pap = 22;
		}
		if( isdefined(players[i].speed_used) && players[i].speed_used )
		{
			level.nml_speed = 33;
		}
		if( isdefined(players[i].jugg_used) && players[i].jugg_used )
		{
			level.nml_jugg = 44;
		}
	
		survived[i] = NewClientHudElem( players[i] );
		survived[i].alignX = "center";
		survived[i].alignY = "middle";
		survived[i].horzAlign = "center";
		survived[i].vertAlign = "middle";
		survived[i].y -= 100;
		survived[i].foreground = true;
		survived[i].fontScale = 2;
		survived[i].alpha = 0;
		survived[i].color = ( 1.0, 1.0, 1.0 );
		if ( players[i] isSplitScreen() )
		{
			survived[i].y += 40;
		}
		
		nomanslandtime = level.nml_best_time; 
		player_survival_time = int( nomanslandtime/1000 ); 
		player_survival_time_in_mins = to_mins_short( player_survival_time );		
		survived[i] SetText( &"ZOMBIE_SURVIVED_NOMANS", player_survival_time_in_mins );
		survived[i] FadeOverTime( 1 );
		survived[i].alpha = 1;
	}
	
	wait( 3.0 );
	
	for( i = 0; i < players.size; i++ )
	{
		survived[i] FadeOverTime( 1 );
		survived[i].alpha = 0;
	}
	
	level.left_nomans_land = 2;

	wait 1;
	for( i = 0; i < players.size; i++ )
	{
		survived[i] destroy();
	}
}
