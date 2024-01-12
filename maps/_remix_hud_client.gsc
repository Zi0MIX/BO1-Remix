#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;

init_hud_dvars()
// They hold values for menu files, not used for triggering HUD elements
{
	players = get_players();
	for(i = 0; i < players.size; i++)
	{
		players[i] setClientDvar("time_summary_text", " ");
		players[i] setClientDvar("time_summary_value", 0);
		players[i] setClientDvar("show_time_summary", 0);
		players[i] setClientDvar("hud_remaining_number", 0);
		players[i] setClientDvar("hud_drops_number", 0);
		players[i] setClientDvar("round_time_value", "0");
		players[i] setClientDvar("total_time_value", "0");
		players[i] setClientDvar("predicted_value", "0");
		players[i] setClientDvar("sph_value", 0);
		players[i] setClientDvar("oxygen_time_value", "0");
		players[i] setClientDvar("oxygen_time_show", 0);
		players[i] setClientDvar("excavator_name", "null");
		players[i] setClientDvar("excavator_time_value", 0);
		players[i] setClientDvar("excavator_time_show", 0);
		players[i] setClientDvar("hud_kills_value", 0);
		players[i] setClientDvar("george_bar_show", 0);
		players[i] setClientDvar("george_bar_ratio", 0);
		players[i] setClientDvar("george_bar_health", 0);
	}
	if(level.script == "zombie_moon")
		setDvar("show_nml_kill_tracker", 1);
	else
		setDvar("show_nml_kill_tracker", 0);
}

send_message_to_csc(name, message)
{
	csc_message = name + ":" + message;

	if(isdefined(self) && IsPlayer(self))
		setClientSysState("client_systems", csc_message, self);
	else
	{
		players = get_players();

		for(i = 0; i < players.size; i++)
		{
			setClientSysState("client_systems", csc_message, players[i]);
		}
	}
}

set_summary_text( text, dvar )
{
	self setClientDvar("time_summary_text", text);
	self setClientDvar("time_summary_value", getDvar(dvar) );
}

hud_menu_fade( name, time )
{
	self send_message_to_csc("hud_anim_handler", name);
	wait time;
}

choose_zone_name(zone, current_name)
{
	if(self.sessionstate == "spectator")
	{
		zone = undefined;
	}

	if(IsDefined(zone))
	{
		if(level.script == "zombie_pentagon")
		{
			if(zone == "labs_elevator")
			{
				zone = "war_room_zone_elevator";
			}
		}
		else if(level.script == "zombie_cosmodrome")
		{
			if(IsDefined(self.lander) && self.lander)
			{
				zone = undefined;
			}
		}
		else if(level.script == "zombie_coast")
		{
			if(IsDefined(self.is_ziplining) && self.is_ziplining)
			{
				zone = undefined;
			}
		}
		else if(level.script == "zombie_temple")
		{
			if(zone == "waterfall_tunnel_a_zone")
			{
				zone = "waterfall_tunnel_zone";
			}
		}
		else if(level.script == "zombie_moon")
		{
			if(IsSubStr(zone, "airlock"))
			{
				return current_name;
			}
		}
	}

	name = " ";

	if(IsDefined(zone))
	{
		name = "reimagined_" + level.script + "_" + zone;
	}

	return name;
}

zone_hud()
{
	self endon("disconnect");

	current_name = " ";

	while(1)
	{
		wait_network_frame();

		name = choose_zone_name(self get_current_zone(), current_name);

		if(current_name == name)
		{
			continue;
		}

		current_name = name;

		self send_message_to_csc("hud_anim_handler", "hud_zone_name_out");
		wait .25;
		self SetClientDvar("hud_zone_name", name);
		self send_message_to_csc("hud_anim_handler", "hud_zone_name_in");
	}
}

health_bar_hud()
{
	self endon("disconnect");
	self endon("end_game");

	health_bar_width_max = 111;

	while (true)
	{
		wait 0.05;

		health_ratio = self.health / self.maxhealth;

		// There is a conflict while trying to import _laststand
		if (isDefined(self.revivetrigger) || (isDefined(level.intermission) && level.intermission))
		{
			self SetClientDvar("health_bar_value_hud", 0);
			self SetClientDvar("health_bar_width_hud", 0);
		}
		else
		{
			self SetClientDvar("health_bar_value_hud", self.health);
			self SetClientDvar("health_bar_width_hud", health_bar_width_max * health_ratio);
		}
	}
} 

oxygen_hud()
{
	level endon("end_game");

	self thread oxygen_hud_watcher();

    while (true)
    {
		if (isDefined(self.time_in_low_gravity) && isDefined(self.time_to_death))
		{
			oxygen_time = (self.time_to_death - self.time_in_low_gravity) / 1000;
			oxygen_left = maps\_remix_zombiemode_utility::to_mins_short(oxygen_time);
			self setClientDvar("oxygen_time_value", oxygen_left);

			if (getDvarInt("hud_oxygen_timer") || (!getDvarInt("hud_oxygen_timer") && getDvarInt("hud_tab")))
			{
				if(self.time_in_low_gravity > 0 && !self maps\_laststand::player_is_in_laststand() && isAlive(self))
					self setClientDvar("oxygen_time_show", 1);
				else
					self setClientDvar("oxygen_time_show", 0);
			}

			else
				self setClientDvar("oxygen_time_show", 0);
		}
    
        wait 0.5;
    }
}

oxygen_hud_watcher()
{
	dvar_state = -1;
	while (true)
	{
		if (getDvarInt("oxygen_time_show"))
		{
			self send_message_to_csc("hud_anim_handler", "hud_oxygen_in");

			while (getDvarInt("oxygen_time_show"))
				wait 0.05;
		}
		else
		{
			self send_message_to_csc("hud_anim_handler", "hud_oxygen_out");

			while (!getDvarInt("oxygen_time_show"))
				wait 0.05;
		}

		wait 0.05;
	}
}

george_health_bar()
{
	// self endon("disconnect");
	level endon("end_game");

	level thread maps\_zombiemode_powerups::cotd_powerup_offset();

	level waittill("start_of_round");

	george_max_health = 250000 * level.players_playing;
	george_bar_width_max = 250;	// Make sure it matches with menu file

	while (true)
	{
		wait 0.05;

		// Amount of damage dealt to director, prevent going beyond the scale
		if (isDefined(level.director_damage))
			local_director_damage = level.director_damage;
		else
			local_director_damage = 0;

		if (local_director_damage > george_max_health)
			local_director_damage = george_max_health;

		george_health = george_max_health - local_director_damage;
		george_ratio = (george_health / george_max_health) * george_bar_width_max;

		if (flag("director_alive") && getDvarInt("hud_george_bar"))
		{
			self setClientDvar("george_bar_ratio", george_ratio);
			self setClientDvar("george_bar_health", george_health);
			if(!getDvarInt("george_bar_show"))
			{
				self setClientDvar("george_bar_show", 1);
				self send_message_to_csc("hud_anim_handler", "hud_georgebar_background_in");
				self send_message_to_csc("hud_anim_handler", "hud_georgebar_image_in");
				self send_message_to_csc("hud_anim_handler", "hud_georgebar_value_in");
			}
		}
		else
		{
			if(getDvarInt("george_bar_show"))
			{
				self setClientDvar("george_bar_show", 0);
				self send_message_to_csc("hud_anim_handler", "hud_georgebar_background_out");
				self send_message_to_csc("hud_anim_handler", "hud_georgebar_image_out");
				self send_message_to_csc("hud_anim_handler", "hud_georgebar_value_out");
			}
		}
	}
}
