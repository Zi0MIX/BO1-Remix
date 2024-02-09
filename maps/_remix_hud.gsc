#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;

remix_hud_initialize()
{
	level thread timer_hud();
	level thread round_timer_hud();
	// level thread time_summary_hud();

	// level thread display_sph();
	// level thread hud_color_watcher();	// For later
}

remix_player_hud_initialize()
{
	self thread remaining_hud();
	// self thread drop_tracker_hud();
	self thread maps\_remix_hud_client::health_bar_hud();
	self thread maps\_remix_hud_client::zone_hud();
	if(level.script == "zombie_coast")
		self thread maps\_remix_hud_client::george_health_bar();

	// testing only
	//self thread get_position();
	//self thread get_zone();
	//self thread get_doors_nearby();
	//self thread get_ent_nearby();
	//self thread get_perks_nearby();
	//self thread set_move_speed();
}

/* Call these util functions on hud element */
freeze_timer(freeze_value, end)
{
	level endon("end_game");
	level endon(end);

	while (true)
	{
		self setTimer(freeze_value - 0.1);
		wait 0.25;
	}
}

hud_toggle_watcher(hud_dvar, hud_alpha, hud_flag)
{
	if (!isDefined(hud_alpha))
		hud_alpha = 1;
	if (isDefined(hud_flag))
		flag_init(hud_flag);

	while (true)
	{
		if (getDvar(hud_dvar) == "1")
		{
			if (!self.alpha)
				self.alpha = hud_alpha;
			if (isDefined(hud_flag))
				flag_set(hud_flag);
		}
		else
		{
			if (self.alpha > 0)
				self.alpha = 0;
			if (isDefined(hud_flag))
				flag_clear(hud_flag);
		}

		wait 0.05;
	}
}

hud_fade(alpha, duration)
{
	if (!isDefined(alpha)) 
	{
		if (self.alpha == 0)
			alpha = 1;
		else
			alpha = 0;
	}
	if (!isDefined(duration))
		duration = 0.1;
	self fadeOverTime(duration);
	self.alpha = alpha;
}

/* Actual huds */

timer_hud()
{
	flag_wait("initial_blackscreen_passed");

	y_pos = 2;
	if (maps\_remix_zombiemode_utility::is_plutonium())
		y_pos = 17;

	level.timer = NewHudElem();
	level.timer.horzAlign = "right";
	level.timer.vertAlign = "top";
	level.timer.alignX = "right";
	level.timer.alignY = "top";
	level.timer.x = -4;
	level.timer.y = y_pos;
	level.timer.fontScale = 1.3;
	level.timer.alpha = 1;
	level.timer.hidewheninmenu = 0;
	level.timer.foreground = 1;
	level.timer.color = (1, 1, 1);

	level.timer SetTimerUp(0);
	/* Attach info about game start */
	level.timer.beginning = int(getTime() / 1000);

	level.timer thread hud_toggle_watcher("remix_timer");
}

round_timer_hud()
{
	level endon("end_game");

	flag_wait("initial_blackscreen_passed");

	/* Do not initialize round timer until players left no man's land */
	if (level.script == "zombie_moon" && !isDefined(level.left_nomans_land))
		level waittill("kill_hud_end");		// TODO actually trigger it

	y_pos = 17;
	if (maps\_remix_zombiemode_utility::is_plutonium())
		y_pos = 32;

	level.round_timer = NewHudElem();
	level.round_timer.horzAlign = "right";
	level.round_timer.vertAlign = "top";
	level.round_timer.alignX = "right";
	level.round_timer.alignY = "top";
	level.round_timer.x = -4;
	level.round_timer.y = y_pos;
	level.round_timer.fontScale = 1.3;
	level.round_timer.alpha = 1;
	level.round_timer.color = (1, 1, 1);

	level.round_timer setTimerUp(0);
	level.round_timer.beginning = int(getTime() / 1000);
	level.round_timer thread freeze_timer(0, "start_of_round");

	level.round_timer thread hud_toggle_watcher("remix_round_timer");
}

info_row_hud()
{
	level endon("end_game");

	flag_wait("initial_blackscreen_passed");

	y_pos = 32;
	if (maps\_remix_zombiemode_utility::is_plutonium())
		y_pos = 47;

	info_row_hud = NewHudElem();
	info_row_hud.horzAlign = "right";
	info_row_hud.vertAlign = "top";
	info_row_hud.alignX = "right";
	info_row_hud.alignY = "top";
	info_row_hud.x = -4;
	info_row_hud.y = y_pos;
	info_row_hud.fontScale = 1.3;
	info_row_hud.alpha = 0;
	info_row_hud.color = (1, 1, 1);

	level.info_row_queue = [];

	info_row_hud thread hud_toggle_watcher("remix_info_hud", 1, "remix_info_hud");

	while (true)
	{
		wait 0.05;

		if (level.info_row_queue.size == 0)
			continue;

		// TODO add dvar condition to if statements to skip showing element if hud is disabled
		if (is_true(flag("remix_info_hud")) && level.info_row_queue[0]["event"] == "split")
		{
			info_row_hud.label = &"Total time: ";			// TODO locstring
			info_row_hud setTimer(level.info_row_queue[0]["value"]);
			info_row_hud freeze_timer(level.info_row_queue[0]["value"], "end_total_time_summary");
			info_row_hud hud_fade();
			wait 6;
			info_row_hud hud_fade();
			level notify("end_total_time_summary");
		}
		else if (is_true(flag("remix_info_hud")) && level.info_row_queue[0]["event"] == "sph")
		{
			info_row_hud.label = &"SPH: ";					// TODO locstring
			info_row_hud setValue(level.info_row_queue[0]["value"]);
			info_row_hud hud_fade();
			wait 6;
			info_row_hud hud_fade();
		}

		array_remove(level.info_row_queue, level.info_row_queue[0]);
	}
}

add_to_info_hud_queue(key, value)
{
	index = level.info_row_queue.size;
	level.info_row_queue[index] = [];
	level.info_row_queue[index]["event"] = key;
	level.info_row_queue[index]["value"] = value;
}

coop_pause_hud()
{
	black_hud = newhudelem();
	black_hud.horzAlign = "fullscreen";
	black_hud.vertAlign = "fullscreen";
	black_hud SetShader("black", 640, 480);
	black_hud.alpha = 0;

	black_hud hud_fade(0.65);

	paused_hud = newhudelem();
	paused_hud.horzAlign = "center";
	paused_hud.vertAlign = "middle";
	paused_hud setText(&"HUD_HUD_ZOMBIES_COOP_PAUSE");
	paused_hud.foreground = true;
	paused_hud.fontScale = 2.3;
	paused_hud.x = -63;
	paused_hud.y = -20;
	paused_hud.alpha = 0;
	paused_hud.color = (1.0, 1.0, 1.0);

	paused_hud hud_fade(0.8);

	level waittill_any("coop_pause_disabled", "end_game");

	black_hud hud_fade();
	paused_hud hud_fade();
	black_hud destroy_hud();
	paused_hud destroy_hud();
}

remaining_hud()
{
	level endon("end_game");

	flag_wait("initial_blackscreen_passed");

	remaining_hud = NewHudElem();
	remaining_hud.horzAlign = "left";
	remaining_hud.vertAlign = "top";
	remaining_hud.alignX = "left";
	remaining_hud.alignY = "top";
	remaining_hud.x = 4;
	remaining_hud.y = 2;
	remaining_hud.fontScale = 1.3;
	remaining_hud.alpha = 1;
	remaining_hud.color = (1, 1, 1);
	remaining_hud.label = &"Remaining: ";	// TODO locstring
	if (level.script == "zombie_moon")
	{
		remaining_hud.label = &"Kills: ";	// TODO locstring
	}

	remaining_hud setValue(0);

	remaining_hud thread hud_toggle_watcher("remix_remaining_hud");

	/* We do this to controll kill hud, we then manually break out and enter the proper remaining hud */
	while (level.script == "zombie_moon")
	{
		if (isDefined(level.left_nomans_land) && level.left_nomans_land > 0)
		{
			level notify("kill_hud_end");
			remaining_hud.label = &"Remaining: ";	// TODO locstring
			break;
		}

		players = get_players();
		current_nml_kills = 0;
		for (i = 0; i < players.size; i++)
			current_nml_kills += players[i].kills;

		remaining_hud setValue(current_nml_kills);

		wait 0.05;
	}

	while (true)
	{
		zombie_count = level.zombie_total + get_enemy_count();
		/* For Der Riese when dogs fuck with enemy array */
		if (zombie_count < 0)
			zombie_count = 0;

		remaining_hud setValue(zombie_count);
		
		wait 0.05;
	}
}

drop_hud()
{
	level endon("end_game");

	flag_wait("initial_blackscreen_passed");

	drop_hud = NewHudElem();
	drop_hud.horzAlign = "left";
	drop_hud.vertAlign = "top";
	drop_hud.alignX = "left";
	drop_hud.alignY = "top";
	drop_hud.x = 4;
	drop_hud.y = 17;
	drop_hud.fontScale = 1.3;
	drop_hud.alpha = 1;
	drop_hud.color = (1, 1, 1);
	drop_hud.label = &"Drops: ";	// TODO locstring

	drop_hud setValue(0);

	drop_hud thread hud_toggle_watcher("remix_drop_hud");

	while (true)
	{
		tracked_drops = 0;
		if (isDefined(level.drop_tracker_index))
			tracked_drops = level.drop_tracker_index;

		drop_hud setValue(tracked_drops);

		wait 0.05;
	}
}

george_health()
{
	level endon("end_game");

	flag_wait("initial_blackscreen_passed");

	george_health = NewHudElem();
	george_health.x = self.origin[0];
	george_health.y = self.origin[1];
	george_health.z = self.origin[2] + 40;
	george_health.fontScale = 1;
	george_health.alpha = 1;
	george_health.color = (1, 1, 1);
	george_health.hidewheninmenu = 1;
	george_health.label = &"%";		// TODO locstring

	george_max_health = 250000 * level.players_playing;

	while (is_true(level.num_director_zombies))
	{
		george_health.x = self.origin[0];
		george_health.y = self.origin[1];
		george_health.z = self.origin[2] + 40;
		george_health setValue(0);
	}

	george_health hud_fade();
	george_health destroy_hud();
}

instakill_timer_hud()
{
    self.vr_timer = NewClientHudElem( self );
    self.vr_timer.horzAlign = "right";
    self.vr_timer.vertAlign = "bottom";
    self.vr_timer.alignX = "right";
    self.vr_timer.alignY = "bottom";
    self.vr_timer.alpha = 1.3;
    self.vr_timer.fontscale = 1.0;
    self.vr_timer.foreground = true;
    self.vr_timer.y = -57;
    self.vr_timer.x = -86;
    self.vr_timer.hidewheninmenu = 1;
    self.vr_timer.alpha = 0;
	self.vr_timer.color = (1, 1, 1);

    while (true)
    {
        insta_time = self.humangun_player_ignored_timer - level.total_time;
        //iprintln(insta_time);
        if(self.personal_instakill)
            self.vr_timer.alpha = 1;
        else
            self.vr_timer.alpha = 0;

        self.vr_timer setTimer(insta_time - 0.1);
        wait 0.05;
    }
}
