dog_round_tracker()
{	
	level.dog_round_count = 1;
	
	// PI_CHANGE_BEGIN - JMA - making dog rounds random between round 5 thru 7
	// NOTE:  RandomIntRange returns a random integer r, where min <= r < max
	level.next_dog_round = 5;//randomintrange( 5 );	
	// PI_CHANGE_END
	
	old_spawn_func = level.round_spawn_func;
	old_wait_func  = level.round_wait_func;

	while ( 1 )
	{
		level waittill ( "between_round_over" );

		/#
			if( GetDvarInt( #"force_dogs" ) > 0 )
			{
				level.next_dog_round = level.round_number; 
			}
		#/

		if ( level.round_number == level.next_dog_round )
		{
			level.music_round_override = true;
			old_spawn_func = level.round_spawn_func;
			old_wait_func  = level.round_wait_func;
			dog_round_start();
			level.round_spawn_func = ::dog_round_spawning;

			level.next_dog_round = level.round_number + 4;//randomintrange( 4 );
			/#
				get_players()[0] iprintln( "Next dog round: " + level.next_dog_round );
			#/
		}
		else if ( flag( "dog_round" ) )
		{
			dog_round_stop();
			level.round_spawn_func = old_spawn_func;
			level.round_wait_func  = old_wait_func;
            level.music_round_override = false;
			level.dog_round_count += 1;
		}			
	}	
}
