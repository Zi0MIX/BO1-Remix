#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include animscripts\zombie_Utility;

ape_round_tracker()
{
	level.ape_save_spawn_func = level.round_spawn_func;
	level.ape_save_wait_func = level.round_wait_func;

	level.next_ape_round = 6;//randomintrange( 7, 9 );
	level.prev_ape_round = level.next_ape_round;

	while ( 1 )
	{
		//level waittill( "between_round_over" );

		if ( level.round_number == level.next_ape_round )
		{
			level.ape_save_spawn_func = level.round_spawn_func;
			level.ape_save_wait_func = level.round_wait_func;

			ape_round_start();

			level.round_spawn_func = ::ape_round_spawning;
			level.round_wait_func = ::ape_round_wait;

			level.prev_ape_round = level.next_ape_round;
			level.next_ape_round = level.round_number + 4;//randomintrange( 5, 8 );
		}
	}
}
