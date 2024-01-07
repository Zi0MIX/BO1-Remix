#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;

remix_hud_initialize()
{
	level thread timer_hud();
	level thread round_timer_hud();
	level thread time_summary_hud();
	level thread hud_trade_header();

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

hud_level_wait()
{
	flag_wait("all_players_spawned");
	wait 3.15;
}

hud_wait()
{
	flag_wait("all_players_spawned");
	wait 2;
}

hud_fade( hud, alpha, duration )
{
	hud fadeOverTime(duration);
	hud.alpha = alpha;
}

toggled_hud_fade(hud, alpha)
{
    duration = 0.1;
	hud fadeOverTime(duration);
	hud.alpha = alpha;
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
	while (level.script == "zombie_moon" && !isDefined(level.left_nomans_land))
		wait 0.05;

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

time_summary_hud()
{
	level endon("disconnect");
	level endon("end_game");

	hud_wait();

	// Settings
	settings_splits = array(30, 50, 70, 100);	// For later

	// Initialize vars
	level.displaying_time_summary = 0;
	last_zombie_count = maps\_remix_zombiemode_utility::get_zombie_number(1);
	round_time_array = array();
	round_time = 0;

	// NML handle
	while (!isdefined(level.left_nomans_land) && level.script == "zombie_moon")
		wait 0.05;

	while (true)
	{
		level waittill("start_of_round");

		// NML handle
		if (isdefined(level.on_the_moon) && !level.on_the_moon)
			continue;

		// Pause handle
		if (isdefined(flag("game_paused")))
		{
			round_start_time = int(getTime() / 1000);
			// Calculate total time at the beginning of next round
			game_time = round_start_time - level.beginning_timestamp;
			level.total_time_text = maps\_remix_zombiemode_utility::to_mins_short(game_time);
			// self setClientDvar("total_time_value", maps\_remix_zombiemode_utility::to_mins_short(gt));

			if (flag("game_paused"))
			{
				while (flag("game_paused"))
					wait 0.05;

				// Overwrite the variable if coop pause was active
				round_start_time = int(getTime() / 1000);
			}
		}
		else
			continue;

		// Grab zombie count from current round for SPH
		if(flag("dog_round") || flag("thief_round") || flag("monkey_round"))
			current_zombie_count = maps\_remix_zombiemode_utility::get_zombie_number(level.round_number - 1);
		else
			current_zombie_count = maps\_remix_zombiemode_utility::get_zombie_number();

		// Calculate predicted round time
		if ((level.round_number == level.last_special_round + 1) && (level.round_number > 4))
		{
			round_time = round_time_array[round_time_array.size - 1];
			round_time_array = array();		// Reset the array
		}
		predicted = (round_time / last_zombie_count) * current_zombie_count;
		level.predicted_round_text = maps\_remix_zombiemode_utility::to_mins_short(int(predicted));
		// self setClientDvar("predicted_value", maps\_remix_zombiemode_utility::to_mins_short(int(predicted)));

		level waittill("end_of_round");

		// NML Handle
		if(isDefined(flag("enter_nml")) && flag("enter_nml"))
		{
			level waittill("end_of_round"); //end no man's land
			level waittill("end_of_round"); //end actual round
		}

		// Calculate round time at the end of the round
		round_end_time = int(getTime() / 1000);
		round_time = round_end_time - round_start_time;
		round_time_array[round_time_array.size] = round_time;
		level.round_time_text = maps\_remix_zombiemode_utility::to_mins_short(round_time);
		// self setClientDvar("round_time_value", maps\_remix_zombiemode_utility::to_mins_short(round_time));

		// Calculate SPH
		sph = round_time / (current_zombie_count / 24);
		wait 0.05;
		level.sph_value = sph;
		// self setClientDvar("sph_value", sph);
			
		// Save last rounds zombie count
		last_zombie_count = current_zombie_count;
		
		level thread display_time_summary();
	}
}

display_time_summary()
{
	level endon("end_game");

	summary = NewHudElem();
	summary.horzAlign = "right";
	summary.vertAlign = "top";
	summary.alignX = "right";
	summary.alignY = "top";
	summary.y = (2 + 15 + level.pluto_offset);
	summary.x = -4;
	summary.fontScale = 1.3;
	summary.alpha = 0;

	wait_time = 5;
	fade_time = 0.5;


	level.displaying_time_summary = 1;

	wait 0.15;
	summary setText("Round Time: " + level.round_time_text);
	hud_fade( summary, 1, fade_time );
	wait wait_time;

	if ((level.round_number >= 50) && (level.round_number != level.last_special_round + 1))
	{
		hud_fade( summary, 0, fade_time );
		wait fade_time;
		summary setText("SPH: " + level.sph_value);
		hud_fade( summary, 1, fade_time );
		wait wait_time;
	}
	else
	{
		wait wait_time + fade_time;
	}

	level waittill("start_of_round");
	hud_fade( summary, 0, fade_time );
	wait fade_time;

	summary setText("Total Time: " + level.total_time_text);
	hud_fade( summary, 1, fade_time );
	wait wait_time;
	hud_fade( summary, 0, fade_time );

	// if (level.round_number != level.last_special_round)
	// {
	// 	hud_fade( summary, 0, fade_time );
	// 	wait fade_time;
	// 	summary setText("Predicted round: " + level.predicted_round_text);
	// 	hud_fade( summary, 1, fade_time );
	// 	wait wait_time;
	// }

	wait fade_time + 0.1;
	summary destroy_hud();

	level.displaying_time_summary = 0;
}

coop_pause_hud()
{
	black_hud = newhudelem();
	black_hud.horzAlign = "fullscreen";
	black_hud.vertAlign = "fullscreen";
	black_hud SetShader("black", 640, 480);
	black_hud.alpha = 0;

	black_hud FadeOverTime(1.0);
	black_hud.alpha = 0.65;

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

	paused_hud FadeOverTime(1.0);
	paused_hud.alpha = 0.8;

	level waittill_any("coop_pause_disabled", "end_game");

	black_hud FadeOverTime(1.0);
	black_hud.alpha = 0;
	paused_hud FadeOverTime(1.0);
	paused_hud.alpha = 0;
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

box_notifier()
{
	hud_level_wait();
	
	box_notifier_hud = NewHudElem();
	box_notifier_hud.horzAlign = "center";
	box_notifier_hud.vertAlign = "middle";
	box_notifier_hud.alignX = "center";
	box_notifier_hud.alignY = "middle";
	box_notifier_hud.x = 0;
	box_notifier_hud.y = -150;
	box_notifier_hud.fontScale = 1.6;
	box_notifier_hud.alpha = 0;
	box_notifier_hud.label = "^7BOX SET: ";
	box_notifier_hud.color = ( 1.0, 1.0, 1.0 );

	while(!isdefined(level.box_set))
		wait 0.5;

	box_notifier_hud setText("^0UNDEFINED");
	if (level.box_set == 0)
	{
		box_notifier_hud setText("^2DINING");
	}
	else if (level.box_set == 1)
	{
		box_notifier_hud setText("^3HELLROOM");
	}
	else if (level.box_set == 2)
	{
		box_notifier_hud setText("^5NO POWER");
	}
	hud_fade(box_notifier_hud, 1, 0.25);
	wait 4;
	hud_fade(box_notifier_hud, 0, 0.25);
	wait 0.25;
	box_notifier_hud destroy();
}

// color_hud()
// {
// 	self thread color_hud_watcher();
// 	self thread color_health_bar_watcher();
// }

// color_hud_watcher()
// {
// 	hud_level_wait();
// 	wait 0.05;
// 	self endon("disconnect");

// 	if(getDvar("hud_color") == "")
// 		setDvar("hud_color", "1 1 1");

// 	color = getDvar("hud_color");
// 	prev_color = "1 1 1";

// 	while( 1 )
// 	{
// 		while( color == prev_color )
// 		{
// 			color = getDvar( "hud_color" );
// 			wait 0.1;
// 		}

// 		colors = strTok( color, " ");
// 		if( colors.size != 3 )
// 			continue;

// 		prev_color = color;

// 		level.timer.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 		level.round_timer.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 		summary.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 		level.sph_hud.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 		self.remaining_hud.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 		self.drops_hud.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 		self.health_text.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 		self.oxygen_timer.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 		// self.vr_timer.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 		level.excavator_timer.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 		level.trade_header.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 	}
// }

// color_health_bar_watcher()
// {
// 	self endon("disconnect");

// 	if(getDvar("hud_color_health") == "")
// 		setDvar("hud_color_health", "1 1 1");

// 	color = getDvar( "hud_color_health" );
// 	prev_color = "1 1 1";

// 	while( 1 )
// 	{
// 		while( color == prev_color )
// 		{
// 			color = getDvar( "hud_color_health" );
// 			wait 0.1;
// 		}

// 		colors = strTok( color, " ");
// 		if( colors.size != 3 )
// 			continue;

// 		prev_color = color;

// 		self.barElem.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 		self.george_bar.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
// 	}
// }

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
