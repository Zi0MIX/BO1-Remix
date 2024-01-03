_randomize_pressure_plates(triggers)
{
	//Randomize what plates required for the players to activate the pap
	rand_nums = array(1,2,3,4);
	//rand_nums = array_randomize(rand_nums);
	for(i=0;i<triggers.size;i++)
	{
		triggers[i].requiredPlayers = rand_nums[i];
	}

}