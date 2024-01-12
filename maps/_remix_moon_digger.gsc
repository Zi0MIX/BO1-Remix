#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;

digger_notify_visually(digger_name, time_left)
{
	switch (digger_name)
	{
		case "teleporter":
			current_excavator = "Pi";
			excavator_area = "(Tunnel 6)";
			break;
		case "hangar":
			current_excavator = "Omicron";
			excavator_area = "(Tunnel 11)";
			break;
		case "biodome":
			current_excavator = "Epsilon";
			excavator_area = "(Biodome)";
			break;
		default:
			current_excavator = digger_name;
			excavator_area = "";
	}

	iPrintLn("Excavator " + current_excavator + excavator_area + " time left: " + maps\_remix_zombiemode_utility::to_mins_short(int(time_left)))
}

play_timer_vox(digger_name)
{
	level endon("end_game");
	level endon(digger_name + "_vox_timer_stop");
	
	time_left = level.diggers_global_time;
	
	played180sec = false;
	played120sec = false;
	played60sec = false;
	played30sec = false;
	
	digger_start_time = GetTime();
	
	while( time_left>0 )
	{
		curr_time = GetTime();
		time_used = (curr_time - digger_start_time) / 1000.0;
		time_left = (level.diggers_global_time - time_used); //4mins - time_used
		
		if (time_left <= 180.0 && !played180sec)
		{
			level thread maps\zombie_moon_amb::play_mooncomp_vox("vox_mcomp_digger_start_", digger_name);
			played180sec = true;
			digger_notify_visually(digger_name, time_left);
		}
		
		if (time_left <= 120.0 && !played120sec)
		{
			level thread maps\zombie_moon_amb::play_mooncomp_vox("vox_mcomp_digger_start_", digger_name);
			played120sec = true;
			digger_notify_visually(digger_name, time_left);
		}
		
		if (time_left <= 60.0 && !played60sec)
		{
			level thread maps\zombie_moon_amb::play_mooncomp_vox("vox_mcomp_digger_time_60_", digger_name);
			played60sec = true;
			digger_notify_visually(digger_name, time_left);
		}
		
		if (time_left <= 30.0 && !played30sec)
		{
			level thread maps\zombie_moon_amb::play_mooncomp_vox("vox_mcomp_digger_time_30_", digger_name);
			played30sec = true;
			digger_notify_visually(digger_name, time_left);
		}
	
		wait(1.0);
	}
}