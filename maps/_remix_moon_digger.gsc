digger_time(timestamp)
{
	level endon ("end_game");

	excavator_breach = timestamp + level.diggers_global_time;
	level.digger_time_left = level.diggers_global_time;
	while(level.digger_time_left > 0)
	{
		level.digger_time_left = excavator_breach - (getTime() / 1000);
		wait 0.05;
	}
	level.digger_to_activate = "null";
}

setup_diggers()
{	
	
	//digger_think_panel(blocker_name,trig_name,start_flag,pause_flag,blocker_func)		
	level thread digger_think_panel("digger_hangar_blocker","hangar_digger_switch","start_hangar_digger","hangar_digger_hacked","hangar_digger_hacked_before_breached","hangar_breached",::digger_think_blocker,"hangar");
	level thread digger_think_panel("digger_teleporter_blocker","teleporter_digger_switch","start_teleporter_digger","teleporter_digger_hacked","teleporter_digger_hacked_before_breached","teleporter_breached",::digger_think_blocker,"teleporter");
	
	level thread digger_think_panel(undefined,"biodome_digger_switch","start_biodome_digger","biodome_digger_hacked","biodome_digger_hacked_before_breached","biodome_breached",::digger_think_biodome,"biodome");
	
	//hides/shows the diggers from view when the players travel to NML
	level thread diggers_think_no_mans_land();
	
	//controls the digger random activations
	level thread digger_round_logic();
	
	//sets up their movement
	diggers = GetEntArray("digger_body","targetname");
	array_thread(diggers,::digger_think_move);
	level thread waitfor_smash();
	wait(.5);
	flag_clear("init_diggers");
	
	players = get_players();
	for(i = 0; i < players.size; i++)
	{
		players[i] thread maps\_custom_hud_menu::excavator_hud();
	}
}


digger_activate(force_digger)
{
	
	
	if( isDefined(force_digger))
	{
		flag_set("start_" + force_digger + "_digger");
	
		level thread digger_time(getTime() / 1000);
		level thread send_clientnotify( force_digger, false );
		level thread play_digger_start_vox( force_digger );
		wait(1);
		
		level notify(force_digger + "_vox_timer_stop");
		level thread play_timer_vox( force_digger );
		return;
	}
	
	
	non_active = [];
	for(i=0;i<level.diggers.size;i++)
	{
		if(!flag("start_" + level.diggers[i] + "_digger"))
		{
			non_active[non_active.size] = level.diggers[i];
		}
	}	
	
	if(non_active.size > 0)
	{
		level.digger_to_activate = random(non_active);
	
		flag_set("start_" + level.digger_to_activate + "_digger");

		level thread digger_time(getTime() / 1000);
		level thread send_clientnotify( level.digger_to_activate, false );
		level thread play_digger_start_vox( level.digger_to_activate );
		wait(1);
		
		level thread play_timer_vox( level.digger_to_activate );
	}
}

digger_hack_func(hacker)
{
	level thread send_clientnotify( self.digger_name, true );
	hacker thread maps\_zombiemode_audio::create_and_play_dialog( "digger", "hacked" );
	level thread delayed_computer_hacked_vox( self.digger_name );
	//iprintlnbold("Digger has been disabled");

	flag_set(self.hacked_flag);
	if ( !flag( self.breached_flag ) )
	{
		level.digger_time_left = 0;
		flag_set( self.hacked_before_breached_flag );
	}

	level notify(self.digger_name + "_vox_timer_stop");
	
	while(1)
	{
		 level waittill("digger_reached_end",digger_name);
		 if(digger_name == self.digger_name)
		 {
		 	break;
		 }
	}
	
	level notify("digger_hacked",self.digger_name	);
		
	
}

digger_round_logic()
{
	level endon( "digger_logic_stop" );

	//wait until the power is turned on before any diggers activate
	flag_wait("power_on");	
	
	wait( 20.0 ); //min time after power is on before starting diggers
	
	last_active_round = level.round_number;
	
	first_digger_activated = false;
	
	if( randomint(100) >= 90 ) //10% chance to activate digger
	{
		digger_activate();
		last_active_round = level.round_number;
		first_digger_activated = true;
	}	
	
	rnd = 0;
	//one digger guaranteed to activate by 2 rounds after power is activated
	while(!first_digger_activated)
	{
		level waittill( "between_round_over" );	
		
		if(level flag_exists( "teleporter_used" ) && flag( "teleporter_used" ) )
		{
			continue;
		}	
		
		if( randomint(100) >= 90  || rnd > 2) 
		{
			digger_activate();
			last_active_round = level.round_number;
			first_digger_activated = true;
		}	
		rnd++;	
	}
	
	while(1)
	{
		level waittill( "between_round_over" );
		
		if(level flag_exists( "teleporter_used" ) && flag( "teleporter_used" ) )
		{
			continue;
		}
		
		//if any diggers are active then 
		if(flag("digger_moving"))
		{
			continue;
		}
	
		if(level.round_number < 10)
		{
			min_activation_time = 3;
			max_activation_time = 8;
		}
		else
		{
			min_activation_time = 2;
			max_activation_time = 8;
		}
		
		diff = abs(level.round_number - last_active_round);	
		
		if( diff >= min_activation_time && diff < max_activation_time)
		{
			if( randomint(100) >= 80 )
			{
				digger_activate();
				last_active_round = level.round_number;
			}			
		}
		else if(diff >= max_activation_time)
		{
			digger_activate();
			last_active_round = level.round_number;
		}
	}
	
}

digger_think_move()
{
	targets = getentarray(self.target,"targetname");
	
	if(targets[0].model == "p_zom_digger_body")
	{
		tracks = targets[0];
		arm = targets[1];
	}
	else
	{
		arm = targets[0];
		tracks = targets[1];
	}
	
	blade_center = GetEnt(arm.target, "targetname");
	
	blade = GetEnt(blade_center.target,"targetname");

	blade LinkTo(blade_center);	
	blade_center LinkTo( arm );
	arm LinkTo( self );
	self linkto(tracks);	
	
	tracks clearclientflag(level._CLIENTFLAG_SCRIPTMOVER_DIGGER_MOVING_EARTHQUAKE_RUMBLE);
  arm clearclientflag(level._CLIENTFLAG_SCRIPTMOVER_DIGGER_ARM_FX);
  	
		
	switch(tracks.target)
	{
		case "hangar_vehicle_path":			
			self.digger_name = "hangar";
			self.down_angle = -45;
			self.up_angle = 45;
			self.zones = array("cata_right_start_zone","cata_right_middle_zone","cata_right_end_zone");	
			break;
		
		case "digger_path_teleporter": 				
			self.digger_name = "teleporter";
			self.down_angle = -52;
			self.up_angle = 52;
			self.zones = array("cata_left_middle_zone","cata_left_start_zone");
			self.arm_lowered = false;			
			break;			
			
		case "digger_path_biodome":			
			self.digger_name = "biodome";
			self.down_angle = -20;
			self.up_angle = 20;		
			self.zones = array("forest_zone");					
			break;
	
	}
	
	self.hacked_flag = self.digger_name + "_digger_hacked";
	self.hacked_before_breached_flag = self.digger_name + "_digger_hacked_before_breached";
	self.breached_flag = self.digger_name + "_breached";
	self.start_flag  = "start_" + self.digger_name + "_digger";	
			
	self.arm_lowered = false;	
	
	tracks digger_follow_path(self,undefined,arm);//,"stop_hangar_digger","start_hangar_digger","pause_hangar_digger");
	
	self endon(self.digger_name + "_digger_hacked");	
	
	self stoploopsound( 2 );
	self playsound( "evt_dig_move_stop" );
	
	//once the digger reaches the end...get it set up to start digging
	self unlink();	

	level.arm_move_speed =  11;
	level.blade_spin_speed =  80;
	level.blade_spin_up_time = 1;
	
	body_turn = RandomIntRange(-1,1);

	body_turn_speed = max(1, abs(body_turn))* .3;
	
	arm Unlink(self);
	arm.og_angles = arm.angles;
		
	self thread wait_for_digger_hack_digging(arm,blade_center,tracks);
	self thread wait_for_digger_hack_moving(arm,blade_center,tracks);
	self thread digger_arm_logic(arm,blade_center,tracks);

}

digger_arm_logic(arm,blade_center,tracks)
{
	arm setclientflag(level._CLIENTFLAG_SCRIPTMOVER_DIGGER_ARM_FX);
	tracks setclientflag(level._CLIENTFLAG_SCRIPTMOVER_DIGGER_MOVING_EARTHQUAKE_RUMBLE);
	
	
	if(!flag(self.hacked_flag)) //
	{
		
	//if the arm is not already lowered, then lower it
		if(!is_true(self.arm_lowered))
		{
			self notify("arm_lower");
			self.arm_lowered = true;
			self.arm_moving = true;
			
			arm Unlink(self);
			
			arm playsound( "evt_dig_arm_move" );
			
			arm RotatePitch( self.down_angle, level.arm_move_speed, level.arm_move_speed/4, level.arm_move_speed/4);
			
			self thread digger_arm_breach_logic( arm, blade_center, tracks );
        }
		
		while(!flag(self.hacked_flag))
		{
		
			blade_center RotatePitch(360, 3 );										
			wait(3);
		}
			
	}
	
	//wait until the arm is done lowering
	while( is_true(self.arm_moving) && !flag(self.hacked_flag) )
	{
		wait(.1);
	}
	
	
	if(is_true(self.arm_lowered))
	{
		self.arm_moving = true;
		self.arm_lowered = false;
		// stop diggin loop blade
		blade_center stoploopsound (2);
		
		blade_center clearclientflag(level._CLIENTFLAG_SCRIPTMOVER_DIGGER_DIGGING_EARTHQUAKE_RUMBLE);
		
		blade_center LinkTo(arm);
		
		arm playsound( "evt_dig_arm_move" );
		arm RotatePitch(self.up_angle, level.arm_move_speed, level.arm_move_speed/4, level.arm_move_speed/4 );
		wait(2);
		level notify("digger_arm_lift",self.digger_name);
		
		switch(self.digger_name)
		{
			case "hangar": 
				stop_exploder(101);
				 
				if(flag("tunnel_11_door1"))
				{
					level.zones["cata_right_start_zone"].adjacent_zones["cata_right_middle_zone"].is_connected = true;
					level.zones["cata_right_middle_zone"].adjacent_zones["cata_right_start_zone"].is_connected = true;
				}				
				
				flag_clear("hangar_blocked");
				flag_clear("both_tunnels_blocked");
				break;
				
			case "teleporter": 
				stop_exploder(111); 
				
				if(flag("catacombs_west4"))
				{
					
					level.zones["airlock_west2_zone"].adjacent_zones["cata_left_middle_zone"].is_connected = true;
					level.zones["cata_left_middle_zone"].adjacent_zones["airlock_west2_zone"].is_connected = true;
				}
				
				
				flag_clear("teleporter_blocked");
				flag_clear("both_tunnels_blocked");
				break;
		}
				
		arm waittill ("rotatedone");
		arm LinkTo( self );
		
		arm playsound( "evt_dig_arm_stop" );
		self.arm_moving = undefined;

		self notify("digger_arm_raised");	
	}

}
