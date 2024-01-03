zios_spawn_printer()
{
	while (1)
	{
		keys = getArrayKeys(level.enemy_spawns);
		for(z=0; z<level.enemy_spawns.size; z++)
		{
			iPrintLn(level.enemy_spawns[z].targetname);
			iPrintLn(keys[z]);
			wait 1;
		}
		iPrintLn("^1BREAK");
		
		wait 1;
	}
}

zone_watcher(zone_array, flag_array)
{
	if (!isdefined(zone_array))
	{
		zone_array = array("crematorium_zone", "alleyway_zone");
	}
	if (!isdefined(flag_array))
	{
		flag_array = array("crematorium", "alley");
	}

	while (1)
	{
		for (z=0; z<zone_array.size; z++)
		{
			flag = flag_array[z];
			if (level.zones[zone_array[z]].is_occupied)
			{
				if (!flag(flag + "_occupied"))
				{
					flag_set(flag + "_occupied");
				}
			}
			else
			{
				if (flag(flag + "_occupied"))
				{
					flag_clear(flag + "_occupied");
				}			
			}
		}
		wait 0.05;
	}
}

//	Create the list of enemies to be used for spawning
create_spawner_list( zkeys )
{
	level.enemy_spawns = [];
//	level.enemy_dog_spawns = [];
	level.enemy_dog_locations = [];
	level.zombie_rise_spawners = [];

	for( z=0; z<zkeys.size; z++ )
	{
		zone = level.zones[ zkeys[z] ];

		if ( zone.is_enabled && zone.is_active )
		{
			//DCS: check to see if zone is setup for random spawning.
			if(IsDefined(level.random_spawners) && level.random_spawners == true)
			{
				if (isdefined(level.shrink_zones))
				{
					zone.num_spawners = [[ level.shrink_zones ]]( zkeys[z] );
				}

				if (isdefined(level.spawners_to_remove))
				{
					remove_spawns = level.spawners_to_remove;
				}
				else				// Original five code
				{
					disabled_window1 = 4;
					disabled_window2 = 0;

					remove_spawns = [];
					remove_spawns[0] = disabled_window1;
					remove_spawns[1] = disabled_window2;
				}

				if(IsDefined(zone.num_spawners) && zone.spawners.size > zone.num_spawners )
				{
					j = 0;
					while(zone.spawners.size > zone.num_spawners)
					{
						//i = RandomIntRange(0, zone.spawners.size);
						i = remove_spawns[j];
						//iprintln(i);
						zone.spawners = array_remove(zone.spawners, zone.spawners[i], true);
						j++;
					}
					array = [];
					keys = GetArrayKeys(zone.spawners);
					for(i=0;i<zone.spawners.size;i++)
					{
						array[i] = zone.spawners[keys[i]];
					}
					zone.spawners = array;
				}



				/*if(IsDefined(zone.num_spawners) && zone.spawners.size > zone.num_spawners )
				{
					while(zone.spawners.size > zone.num_spawners)
					{
						i = RandomIntRange(0, zone.spawners.size);
						zone.spawners = array_remove(zone.spawners, zone.spawners[i]);
					}
				}*/
			}

			// Add spawners
			for(x=0;x<zone.spawners.size;x++)
			{
				if ( zone.spawners[x].is_enabled )
				{
					level.enemy_spawns[ level.enemy_spawns.size ] = zone.spawners[x];
				}
			}

			// add dog_spawn locations
			for(x=0; x<zone.dog_locations.size; x++)
			{
				if ( zone.dog_locations[x].is_enabled )
				{
					level.enemy_dog_locations[ level.enemy_dog_locations.size ] = zone.dog_locations[x];
				}
			}

			// add zombie_rise locations
			for(x=0; x<zone.rise_locations.size; x++)
			{
				if ( zone.rise_locations[x].is_enabled )
				{
					level.zombie_rise_spawners[ level.zombie_rise_spawners.size ] = zone.rise_locations[x];
				}
			}
		}
	}
}
