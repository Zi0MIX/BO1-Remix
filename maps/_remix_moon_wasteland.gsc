#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;
#include maps\zombie_moon_teleporter;

zombie_moon_start_init()
{
	flag_wait( "begin_spawning" );

	players = get_players();
	for(i = 0; i < players.size; i++)
	{
		players[i] thread maps\_custom_hud_menu::kill_hud();
	}

	level thread nml_dogs_init();

	teleporter = getent( "generator_teleporter", "targetname" );
	teleporter_ending( teleporter, 0 );
}	

nml_round_manager()
{
	level endon("restart_round");

	// *** WHAT IS THIS? *** 
	level.dog_targets = getplayers();
	for( i=0; i<level.dog_targets.size; i++ )
	{
		level.dog_targets[i].hunted_by = 0;
	}
	
	level.nml_start_time = GetTime();
	
	// Time when dog spawns start in NML
	dog_round_start_time = 2000;
	dog_can_spawn_time = -1000*10;
	dog_difficulty_min_time = 3000;
	dog_difficulty_max_time = 9500;
	
	// Attack Waves setup
	wave_1st_attack_time = (1000 * 25);
	prepare_attack_time = (1000 * 2.1);
	wave_attack_time = (1000 * 35);		// 35
	cooldown_time = (1000 * 1);//(1000 * 16);
	next_attack_time = (1000 * 25);		// 25

	max_zombies = 20;
	
	next_round_time = level.nml_start_time + wave_1st_attack_time;
	mode = "normal_spawning";
	
	area = 1;
	
	// Once some AI appear, make sure the round never ends
	level thread nml_round_never_ends();

	while( 1 )
	{
		current_time = GetTime();
		
		wait_override = 0.0;


		/**************************************************************/
		/* There is a limit of 24 AI entities, wait to hit this limit */
		/**************************************************************/

		zombies = GetAiSpeciesArray( "axis", "all" );
		
		while( zombies.size >= max_zombies )
		{
			zombies = GetAiSpeciesArray( "axis", "all" );
			wait( 0.5 );
		}


		/***************************/
		/* Update the Spawner Mode */
		/***************************/

		switch( mode )
		{
			// Default Ambient Zombies
			case "normal_spawning":
				
				if(level.initial_spawn == true)
				{
					spawn_a_zombie( 15, "nml_zone_spawners", 0.01 );
				}
				else
				{	
					ai = spawn_a_zombie( max_zombies, "nml_zone_spawners", 0.01 );
					if( isdefined (ai) )
					{
						ai.zombie_move_speed = "sprint";
						
						//Normal sprint (1,4)
						//Super-sprint (5,6)
						
						if(flag("start_supersprint"))
						{
							theanim = "sprint" + randomintrange(1, 6);
						}	
						else
						{
							theanim = "sprint" + randomintrange(1, 4);
						}	 
						
						if( IsDefined( ai.pre_black_hole_bomb_run_combatanim ) )
						{
							ai.pre_black_hole_bomb_run_combatanim = theanim;
						}
						else
						{
							ai set_run_anim( theanim );                         
							ai.run_combatanim = level.scr_anim[ai.animname][theanim];
							ai.walk_combatanim = level.scr_anim[ai.animname][theanim];
							ai.crouchRunAnim = level.scr_anim[ai.animname][theanim];
							ai.crouchrun_combatanim = level.scr_anim[ai.animname][theanim];
							ai.needs_run_update = true;			
						}

					}
				}
				
				// Check for Spawner Wave to Start
				if( current_time > next_round_time )
				{
					next_round_time = current_time + prepare_attack_time;
					mode = "preparing_spawn_wave";
					level thread screen_shake_manager( next_round_time );
				}
			break;


			// Shake screen, start existing zombies running, then start a wave
			case "preparing_spawn_wave":
				zombies = GetAiSpeciesArray( "axis" );
				for( i=0; i < zombies.size; i++ )
				{
					if( zombies[i].has_legs && zombies[i].animname == "zombie") // make sure not a dog.
					{
						zombies[i].zombie_move_speed = "sprint";
						
						//Normal sprint (1,4)
						//Super-sprint (5,6)
						if(flag("start_supersprint"))
						{
							theanim = "sprint" + randomintrange(1, 6);
						}	
						else
						{
							theanim = "sprint" + randomintrange(1, 4);
						}	 
												
						level.initial_spawn = false;
						level notify( "start_nml_ramp" );
						
						if( IsDefined( zombies[i].pre_black_hole_bomb_run_combatanim ) )
						{
							zombies[i].pre_black_hole_bomb_run_combatanim = theanim;
						}
						else
						{
							zombies[i] set_run_anim( theanim );                         
							zombies[i].run_combatanim = level.scr_anim[zombies[i].animname][theanim];
							zombies[i].walk_combatanim = level.scr_anim[zombies[i].animname][theanim];
							zombies[i].crouchRunAnim = level.scr_anim[zombies[i].animname][theanim];
							zombies[i].crouchrun_combatanim = level.scr_anim[zombies[i].animname][theanim];
							zombies[i].needs_run_update = true;
						}
								

					}
				}
				 
				if( current_time > next_round_time )
				{
					level notify( "nml_attack_wave" );
					mode = "spawn_wave_active";
					
					if( area == 1 )
					{
						// area = 2;
						level thread nml_wave_attack( max_zombies, "nml_area2_spawners" );
					}
					// else
					// {
					// 	area = 1;
					// 	level thread nml_wave_attack( max_zombies, "nml_area1_spawners" );
					// }
									
					next_round_time = current_time + wave_attack_time;
				}
				wait_override = 0.1;
			break;


			// Attack wave in progress
			// Occasionally spawn a zombie
			case "spawn_wave_active":
				if( current_time < next_round_time )
				{
					if( randomfloatrange(0, 1) < 0.05 )
					{
						ai = spawn_a_zombie( max_zombies, "nml_zone_spawners", 0.01 );
						if( isdefined (ai) )
						{
							ai.ignore_gravity = true;
							ai.zombie_move_speed = "sprint";
							
							//Normal sprint (1,4)
							//Super-sprint (5,6)
							if(flag("start_supersprint"))
							{
								theanim = "sprint" + randomintrange(1, 6);
							}	
							else
							{
								theanim = "sprint" + randomintrange(1, 4);
							}	 
							
							if( IsDefined( ai.pre_black_hole_bomb_run_combatanim ) )
							{
								ai.pre_black_hole_bomb_run_combatanim = theanim;
							}
							else
							{
								ai set_run_anim( theanim );                         
								ai.run_combatanim = level.scr_anim[ai.animname][theanim];
								ai.walk_combatanim = level.scr_anim[ai.animname][theanim];
								ai.crouchRunAnim = level.scr_anim[ai.animname][theanim];
								ai.crouchrun_combatanim = level.scr_anim[ai.animname][theanim];
								ai.needs_run_update = true;			
							}
															
						}			
					}
				}
				else
				{
					level notify("wave_attack_finished");
					mode = "wave_finished_cooldown";
					next_round_time = current_time + cooldown_time;
				}
			break;
			

			// Round over, cooldown period
			case "wave_finished_cooldown":
			
				if( current_time > next_round_time )
				{
					next_round_time = current_time + next_attack_time;
					mode = "normal_spawning";
				}
				
				wait_override = 0.01;
			break;
		}


		/***************************************************************************************/
		/* If there are any dog targets (players running about in NML (away from the platform) */
		/* Send dogs after them																   */
		/***************************************************************************************/

		num_dog_targets = 0;
		if( (current_time - level.nml_start_time) > dog_round_start_time )
		{
			skip_dogs = 0;
			
			// *** DIFFICULTY FOR 1 Player ***
			players = get_players();
			if( players.size <= 1 )
			{
				dt = current_time - dog_can_spawn_time;
				if( dt < 0 )
				{
					//iPrintLn( "DOG SKIP" );
					skip_dogs = 1;
				}
				else
				{
					dog_can_spawn_time = current_time + randomfloatrange(dog_difficulty_min_time, dog_difficulty_max_time);
				}
			}
			
			if( mode == "preparing_spawn_wave" )
			{
				skip_dogs = 1;
			}

			if( !skip_dogs && level.nml_dogs_enabled == true)
			{
				num_dog_targets = level.num_nml_dog_targets;
				//iPrintLn( "Num Dog Targets: " + num_dog_targets );
		
				if( num_dog_targets )
				{
					// Send 2 dogs after each player
					dogs = getaispeciesarray( "axis", "dog" );
					num_dog_targets *= 2;
						
					if( dogs.size < num_dog_targets )
					{
						//IPrintLnBold("Spawn a dog");
						ai = maps\_zombiemode_ai_dogs::special_dog_spawn();
						
						//set their health to current level immediately.
						zombie_dogs = GetAISpeciesArray("axis","zombie_dog");
						if(IsDefined(zombie_dogs))
						{
							for( i=0; i<zombie_dogs.size; i++ )
							{
								zombie_dogs[i].maxhealth = int( level.nml_dog_health);
								zombie_dogs[i].health = int( level.nml_dog_health );
							}	
						}
					}
				}
			}
		}
	
		if( wait_override != 0.0 )
		{
			wait( wait_override );
		}
		else
		{
			wait randomfloatrange( 0.1, 0.8 );
		}
	}
}

perk_machine_arrival_update()
{
	top_height = 1200;		// 700
	fall_time = 4;
	num_model_swaps = 20;

	perk_index = 1; // always jug

	// Flash an effect to the perk machines destination
	ent = level.speed_cola_ents[0];
	level thread perk_arrive_fx( ent.origin );

	// while( 1 )
	{
		// Move the perk machines high in the sky
		move_perk( top_height, 0.01, 0.001 );
		wait( 0.3 );
		perk_machines_hide( 0, 0, true );
		wait( 1 );

		// Start the machines falling
		move_perk( top_height*-1, fall_time, 1.5 );

		// Swap visible Perk as we fall
		wait_step = fall_time / num_model_swaps;
		for( i=0; i<num_model_swaps; i++ )
		{
			perk_machine_show_selected( perk_index, true );
			wait( wait_step );
			
			perk_index++;
			if( perk_index > 1 )
			{
				perk_index = 0;
			}
		}

		// Make sure we don't get a perk machine duplicate next time we visit
		while( perk_index == level.last_perk_index )
		{
			perk_index = randomintrange( 0, 2 );
		}
		
		level.last_perk_index = perk_index;
		perk_machine_show_selected( perk_index, false );
	
	}
}
