post_init()
{
	registerClientSys("client_systems");
}

init_dvar(dvar, base_value)
{
	if (getDvar(dvar) == "")
		setDvar(base_value);
}

special_round_watcher()
{
	while(true)
	{
		level waittill("start_of_round");
		if(flag("dog_round") || flag("thief_round") || flag("monkey_round"))
			level.last_special_round = level.round_number;
	}
}

// print time with leading zeros removed
to_mins_short(seconds)
{
	hours = int(seconds / 3600);
	minutes = int((seconds - (hours * 3600)) / 60);
	seconds = int(seconds - (hours * 3600) - (minutes * 60));

	if( minutes < 10 && hours >= 1 )
	{
		minutes = "0" + minutes;
	}
	if( seconds < 10 )
	{
		seconds = "0" + seconds;
	}

	combined = "";
	if(hours >= 1)
	{
		combined = "" + hours + ":" + minutes + ":" + seconds;
	}
	else
	{
		combined = "" + minutes + ":" + seconds;
	}

	return combined;
}

get_zombie_number(round)
{
	if (!isDefined(round))
		round = level.round_number;

	max = level.zombie_vars["zombie_max_ai"];

	multiplier = round / 5;
	if( multiplier < 1 )
	{
		multiplier = 1;
	}

	// After round 10, exponentially have more AI attack the player
	if( round >= 10 )
	{
		multiplier *= round * 0.15;
	}

	player_num = get_players().size;

	if( player_num == 1 )
	{
		max += int( ( 0.5 * level.zombie_vars["zombie_ai_per_player"] ) * multiplier );
	}
	else
	{
		max += int( ( ( player_num - 1 ) * level.zombie_vars["zombie_ai_per_player"] ) * multiplier );
	}

	nerfed_zc = used_max_zombie_func(max, round);
	return nerfed_zc;
}

used_max_zombie_func( max_num, round )
{
	max = max_num;

	if ( round == 1 )
	{
		max = int( max_num * 0.25 );
	}
	else if (round < 3)
	{
		max = int( max_num * 0.3 );
	}
	else if (round < 4)
	{
		max = int( max_num * 0.5 );
	}
	else if (round < 5)
	{
		max = int( max_num * 0.7 );
	}
	else if (round < 6)
	{
		max = int( max_num * 0.9 );
	}

	return max;
}

do_player_vo(snd, variation_count)
{
    if (getDvar("player_quotes") == "0")
        return;

	index = maps\_zombiemode_weapons::get_player_index(self);
	
	// updated to new alias format - Steve G
	sound = "zmb_vox_plr_" + index + "_" + snd; 
	if(IsDefined (variation_count))
	{
		sound = sound + "_" + randomintrange(0, variation_count);
	}
	if(!isDefined(level.player_is_speaking))
	{
		level.player_is_speaking = 0;
	}
	
	if (level.player_is_speaking == 0)
	{	
		level.player_is_speaking = 1;
		self playsound(sound, "sound_done");			
		self waittill("sound_done");
		//This ensures that there is at least 3 seconds waittime before playing another VO.
		wait(2);
		level.player_is_speaking = 0;
	}	
}
