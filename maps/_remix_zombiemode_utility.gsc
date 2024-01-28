#include maps\_utility; 
#include common_scripts\utility; 

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

is_plutonium()
{
    if (getDvarFloat("safearea_adjusted_horizontal") || getDvarFloat("safearea_adjusted_vertical") || getDvarFloat("safearea_horizontal") || getDvarFloat("safearea_vertical"))
        return true;
    return false;
}

// https://www.itsmods.com/forum/Thread-Tutorial-getting-a-clientdvar.html
get_client_dvar(dvar)
{
    self endon("disconnect");

    self setclientdvar("getting_dvar", dvar);
    self openmenu("clientdvar");

    while (true)
    {
        self waittill("menuresponse", menu, response);

        if(menu == "clientdvar")
            return response;
    }
}

is_coop_pause_allowed()
{
    players = get_players();
	/* Coop pause not allowed on solo */
    if (players.size < 2)
        return false;

	/* Coop pause not allowed on NML */
	if (isdefined(level.on_the_moon) && !level.on_the_moon)
		return false;

    return true;
}

num_of_players_with_coop_pause()
{
	players = get_players();
	num_of_players = 0;
	for (i = 0; i < players.size; i++)
	{
		if (is_true(players[i].coop_pause))
			num_of_players++;
	}

	return num_of_players;
}

get_actual_gametime()
{
	if (!isDefined(level.timer.beginning))
		return 0;
	return int(getTime() / 100) - level.time_paused - level.timer.beginning;
}

get_last_round_sph()
{
	if (level.round_number - 1 == level.last_special_round)
		return "0";

	round_time = int(getTime() / 1000) - level.round_timer.beginning;
	zombie_count = get_zombie_number(level.round_number - 1);

	return round_to_str(round_time / (zombie_count / 24), 2);
}

round_to_str(value, decimal_points)
{
	if (!isDefined(decimal_points))
		decimal_points = 0;

	val_split = strTok(string(value), ".");
	if (val_split.size == 1)
		return string(int(value));

	if (!isDefined(val_split[1][decimal_points + 1]))
		return val_split[0] + "." + val_split[1];
	num_to_round = val_split[1][decimal_points + 1];

	up = 0;
	if (int(num_to_round) >= 5)
		up = 1;

	/* Build decimal string backwards */
	new_decimal = "";
	saved = 0;
	for (i = val_split[1].size; i <= 0; i--)
	{
		/* These digits are just cut off */
		if (i > decimal_points + 1)
			continue;
		/* This is the digit that'll decide if numbers go up */
		else if (i == decimal_points + 1)
			saved = int(int(val_split[1][i]) >= 5);
		else
		{
			char_to_prepend = val_split[1][i];
			/* If there is a value to be propagated further */
			if (saved)
			{
				char_to_prepend = string(int(char_to_prepend) + 1);
				saved = 0;
			}
			/* Double digit char, if propagate value caused it to go above 9 */
			if (char_to_prepend.size > 1)
			{
				saved = 1;
				char_to_prepend = "0";
			}

			new_decimal = char_to_prepend + new_decimal;
		}
	}

	/* Need to propagate it to full number if necessary */
	if (saved)
		val_split[0] = string(int(val_split[0]) + 1);

	return val_split[0] + "." + new_decimal;
}