lighthouse_wait_for_power()
{
	level waittill( "power_on" );
	clientnotify("LHL");

	while(1)
	{
		pack_a_punch_hide();
		wait(randomintrange(20,30));	//pap is searching for between 0:20 and 0:30

		clientnotify("lhfo"); // the lighthouse freaks out for a bit
		exploder(310);
		playsoundatposition ("zmb_pap_lightning_1", (0,0,0));
		wait(15);
		exploder(310);
		playsoundatposition ("zmb_pap_lightning_2", (0,0,0));
		clientnotify("lhfd");
		pack_a_punch_move_to_spot();
		wait(120);//2:00 wait while pap is active

		//make sure the machine is done being used before moving it!
		while(flag("pack_machine_in_use"))
		{
			wait .05;
		}

	}
}
