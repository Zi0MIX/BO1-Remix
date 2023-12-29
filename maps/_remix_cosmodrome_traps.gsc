centrifuge_random()
{
	// objects
	centrifuge_model = GetEnt( "rotating_trap_group1", "targetname" );
	centrifuge_damage_trigger = GetEnt( "trigger_centrifuge_damage", "targetname" );
	
	// save the start angles
	centrifuge_start_angles = centrifuge_model.angles;

	while( true )
	{	
		// randomize centrifuge so it has the chance of missing a round
		malfunction_for_round = RandomInt( 10 );
		if( malfunction_for_round > 6 )
		{
			level waittill( "between_round_over" ); // this will wait for the next time a round starts
		}
		// else if( malfunction_for_round == 1 )
		// {
		// 	level waittill( "between_round_over" ); // this will wait for the next time a round starts
		// 	level waittill( "between_round_over" ); // this will wait for the next time a round starts
		// }
		
		wait( RandomIntRange( 24, 48 ) );	// (24, 90)
		
		// figure out the roatation amount
		rotation_amount = RandomIntRange( 3, 7 ) * 360;
		
		// how much time will it take to rotate?
		wait_time = RandomIntRange( 4, 7 );
		
		// activation warning
		level centrifuge_spin_warning( centrifuge_model );
		
		// set client flag for rumble
		centrifuge_model SetClientFlag( level._SCRIPTMOVER_COSMODROME_CLIENT_FLAG_CENTRIFUGE_RUMBLE );
		
		// rotate the centrifuge
		centrifuge_model RotateYaw( rotation_amount, wait_time, 1.0, 2.0 );
		
		// start the damage
		centrifuge_damage_trigger thread centrifuge_damage();
		
		//C. Ayers: Start the sound
		//centrifuge_model playsound ("zmb_cent_start");
		
		wait( 3.0 );
		
		// Spin full rotations as long as we can
		
		// track when the fuge should start slowing down in order to change the sound
		// wait time minus the spin up and spin down times
		slow_down_moment = wait_time - 3;
		if( slow_down_moment < 0 )
		{
			slow_down_moment = Abs( slow_down_moment );
		}
		centrifuge_model stoploopsound (4);
		centrifuge_model playsound ("zmb_cent_end");
		wait( slow_down_moment );
		
		//Shawn J Sound - power down sound for centrifuge
		
		centrifuge_model waittill( "rotatedone" );
		centrifuge_damage_trigger notify( "trap_done" );
		centrifuge_model PlaySound( "zmb_cent_lockdown" );
		
		// warning lights on
		centrifuge_model ClearClientFlag( level._SCRIPTMOVER_COSMODROME_CLIENT_FLAG_CENTRIFUGE_LIGHTS );
		
		//for( i = 0; i < red_lights_fx.size; i++ )
		//{
		//	red_lights_fx[i] Unlink();
		//}
		
		//array_delete( red_lights_fx );
		
		// clear client flag for rumble
		centrifuge_model ClearClientFlag( level._SCRIPTMOVER_COSMODROME_CLIENT_FLAG_CENTRIFUGE_RUMBLE );
	}
	
}
