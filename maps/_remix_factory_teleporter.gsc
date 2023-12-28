init_pack_door()
{
	//DCS: create collision blocker till door in place at load.
	collision = spawn("script_model", (-56, 467, 157));
	collision setmodel("collision_wall_128x128x10");
	collision.angles = (0, 0, 0);
	collision Hide();	
	
	door = getent( "pack_door", "targetname" );
	door movez( -50, 0.05, 0 );
	wait(1.0);

	flag_wait( "all_players_connected" );

	door movez(  50, 1.5, 0 );
	door playsound( "packa_door_1" );

	//DCS: waite for door to be in place then delete blocker.
	wait(2);
	collision Delete();

	// Open slightly the first two times
	flag_wait( "teleporter_pad_link_1" );
	door movez( -55, 1.5, 1 );
	door playsound( "packa_door_2" );
	door thread packa_door_reminder();
	wait(2);

	// Second link
	flag_wait( "teleporter_pad_link_2" );
	door movez( -60, 1.5, 1 );
	door playsound( "packa_door_2" );
	wait(2);

	// Final Link
	//flag_wait( "teleporter_pad_link_3" );

	//door movez( -25, 1.5, 1 );
	//door playsound( "packa_door_2" );

	//door rotateyaw( -90, 1.5, 1 );

	clip = getentarray( "pack_door_clip", "targetname" );
	for ( i = 0; i < clip.size; i++ )
	{
		clip[i] connectpaths();
		clip[i] delete();
	}
}
