#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;

remix_hud_initialize()
{
	level thread timer_hud();
	level thread round_timer_hud();
	level thread time_summary_hud();

	// level thread display_sph();
	// level thread hud_color_watcher();	// For later
}

remix_player_hud_initialize()
{
	self thread time_summary_hud();
	self thread remaining_hud();
	self thread drop_tracker_hud();
	self thread health_bar_hud();
	self thread zone_hud();
	if(level.script == "zombie_coast")
		self thread maps\_custom_hud_menu::george_health_bar();

	// testing only
	//self thread get_position();
	//self thread get_zone();
	//self thread get_doors_nearby();
	//self thread get_ent_nearby();
	//self thread get_perks_nearby();
	//self thread set_move_speed();
}

hud_fade(alpha, duration)
{
	if (!isDefined(alpha)) 
	{
		if (self.alpha = 0)
			alpha = 1;
		else
			alpha = 0;
	}
	if (!isDefined(duration))
		duration = 0.1;
	self fadeOverTime(duration);
	self.alpha = alpha;
}

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

	// TODO toggling hud
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

	// TODO toggling hud
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

	while (true)
	{
		wait 0.05;

		if (level.info_row_queue.size == 0)
			continue;

		// TODO add dvar condition to if statements to skip showing element if hud is disabled
		if (level.info_row_queue[0]["event"] == "split")
		{
			info_row_hud.label = &"Total time: ";			// TODO locstring
			info_row_hud setTimer(level.info_row_queue[0]["value"]);
			info_row_hud freeze_timer(level.info_row_queue[0]["value"], "end_total_time_summary");
			info_row_hud hud_fade();
			wait 6;
			info_row_hud hud_fade();
			level notify("end_total_time_summary");
		}
		else if (level.info_row_queue[0]["event"] == "sph")
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

/* Call on hud element */
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
