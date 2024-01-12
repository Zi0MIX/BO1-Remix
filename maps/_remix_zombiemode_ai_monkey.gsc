#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include animscripts\zombie_Utility;

monkey_setup_health()
{
	switch( level.monkey_encounters )
	{
	case 1:
		level.monkey_zombie_health = level.zombie_health * 0.25;
		break;

	case 2:
		level.monkey_zombie_health = level.zombie_health * 0.5;
		break;

	case 3:
		level.monkey_zombie_health = level.zombie_health * 0.75;
		break;

	default:
		level.monkey_zombie_health = level.zombie_health;
		break;
	}

	if ( level.monkey_zombie_health > 1500 )
	{
		level.monkey_zombie_health = 1500;
	}

	monkey_print( "monkey health = " + level.monkey_zombie_health );
}

monkey_round_tracker()
{
	flag_wait( "power_on" );
	flag_wait( "perk_bought" );

	level.monkey_save_spawn_func = level.round_spawn_func;
	level.monkey_save_wait_func = level.round_wait_func;

	if(level.round_number % 2 == 1)
	{
		level.next_monkey_round = level.round_number + 2;
	}
	else
	{
		level.next_monkey_round = level.round_number + 1;
	}
	level.prev_monkey_round = level.next_monkey_round;

	while ( 1 )
	{
		level waittill( "between_round_over" );

		if ( level.round_number == level.next_monkey_round )
		{
			// only allow round change if someone has a perk
			if ( !monkey_player_has_perk() )
			{
				level.next_monkey_round = level.next_monkey_round + 2;
				continue;
			}

			level.music_round_override = true;
			level.monkey_save_spawn_func = level.round_spawn_func;
			level.monkey_save_wait_func = level.round_wait_func;

			monkey_round_start();

			level.round_spawn_func = ::monkey_round_spawning;
			level.round_wait_func = ::monkey_round_wait;

			if(!IsDefined(level.prev_monkey_round_amount))
			{
				if(level.next_monkey_round % 2 != 1)
				{
					level.next_monkey_round++;
				}
				level.prev_monkey_round = level.next_monkey_round;
				level.prev_monkey_round_amount = 4;
				level.next_monkey_round = level.round_number + level.prev_monkey_round_amount;
			}
			else
			{
				if(level.next_monkey_round % 2 != 1)
				{
					level.next_monkey_round++;
				}
				level.prev_monkey_round = level.next_monkey_round;
				level.next_monkey_round = level.round_number + 4;
				level.prev_monkey_round_amount = undefined;
			}
		}
		else if ( flag( "monkey_round" ) )
		{
			monkey_round_stop();
			level.music_round_override = false;
		}
	}
}

monkey_zombie_watch_machine_damage()
{
	self endon( "death" );
	self endon( "stop_perk_attack" );
	self endon( "stop_machine_watch" );

	machine = self.pack.machine;
	machine waittill( "attacked" );

	while ( 1 )
	{
		monkey_zone = self monkey_get_zone();
		if ( isdefined( monkey_zone ) )
		{
			if ( monkey_zone.is_occupied )
			{
				monkey_print( "player is here, go crazy" );
				self.machine_damage = level.machine_damage_max;
				break;
			}
		}

		wait_network_frame();
	}
}

monkey_zombie_attack_perk()
{
	self endon( "death" );
	self endon( "stop_perk_attack" );
	self endon( "next_perk" );

	if ( !isdefined( self.perk ) )
	{
		return;
	}

	flag_clear( "monkey_free_perk" );

	self.following_player = false;

	//self thread monkey_zombie_health_watcher();
	self monkey_zombie_set_state( "attack_perk" );

	//C. Ayers: Adding in player dialogue stating that their perk is being taken
    level thread play_player_perk_theft_vox( self.perk.script_noteworthy, self );

	spot = self.attack.script_int;

	// try this to align
	self Teleport( self.attack.origin, self.attack.angles );

	monkey_print( "attack " + self.perk.script_noteworthy + " from " + spot );

	choose = 0;
	if ( spot == 1 )
	{
		choose = RandomIntRange( 1, 3 );
	}
	else if ( spot == 3 )
	{
		choose = RandomIntRange( 3, 5 );
	}

	perk_attack_anim = undefined;

	// check for machine specific attacks
	if ( choose == 2 )
	{
		if ( isdefined( level.monkey_perk_attack_anims[ self.perk.script_noteworthy ] ) )
		{
			perk_attack_anim = level.monkey_perk_attack_anims[ self.perk.script_noteworthy ][ "left_top" ];
		}
	}
	else if ( choose == 4 )
	{
		if ( isdefined( level.monkey_perk_attack_anims[ self.perk.script_noteworthy ] ) )
		{
			perk_attack_anim = level.monkey_perk_attack_anims[ self.perk.script_noteworthy ][ "right_top" ];
		}
	}

	if ( !isdefined( perk_attack_anim ) )
	{
		perk_attack_anim = level.monkey_perk_attack_anims[ choose ];
	}

	//perk_attack_anim = animscripts\zombie_melee::pick_zombie_melee_anim( self );
	time = getAnimLength( perk_attack_anim );

	self thread monkey_wait_to_drop();

	machine = self.pack.machine;
	machine notify( "attacked" );

	while ( 1 )
	{
		monkey_pack_flash_perk( self.perk.script_noteworthy, self.machine_damage );

		self animscripted( "perk_attack_anim", self.attack.origin, self.attack.angles, perk_attack_anim, "normal", %body, 1, 0.2 );
		//self animscripted( "perk_attack_anim", self.origin, self.angles, perk_attack_anim, "normal", %body, 1 );
		//self thread maps\_zombiemode_audio::do_zombies_playvocals( "attack", self.animname );
		self thread play_attack_impacts( time );

		if ( self monkey_zombie_perk_damage( self.machine_damage ) )
		{
			self monkey_pack_take_perk();
			break;
		}

		wait( time );
	}

	self notify( "stop_machine_watch" );
	self monkey_zombie_set_state( "attack_perk_done" );
}

play_player_perk_theft_vox( perk, monkey )
{
    force_quit = 0;

    if( !IsDefined( level.perk_theft_vox ) )
        level.perk_theft_vox = [];

    if( !IsDefined( level.perk_theft_vox[perk] ) )
        level.perk_theft_vox[perk] = false;

    if( level.perk_theft_vox[perk] )
        return;

    level.perk_theft_vox[perk] = true;

    while(1)
    {
        player = getplayers();
        rand = RandomIntRange(0, player.size );

        if ( monkey.pack.machine.monkey_health == 0 )
	    {
		    level.perk_theft_vox[perk] = false;
		    return;
	    }

        if( ( IsAlive( player[rand] ) ) && ( !player[rand] maps\_laststand::player_is_in_laststand() ) && ( player[rand] HasPerk( perk ) ) )
        {
            player[rand] maps\_zombiemode_audio::create_and_play_dialog( "perk", "steal_" + perk );
            break;
        }
        else if( force_quit >= 6 )
        {
            break;
        }

        force_quit ++;
        wait(.05);
    }

	while( IsDefined(monkey) && IsDefined(monkey.pack) && IsDefined(monkey.pack.machine) && IsDefined(monkey.pack.machine.monkey_health) &&
		monkey.pack.machine.monkey_health != 0 )
	{
	    wait(1);
	}

	level.perk_theft_vox[perk] = false;
}

monkey_pack_take_perk()
{
	players = getplayers();

	self.perk.targeted = 0;
	perk = self.perk.script_noteworthy;

	for ( i = 0; i < players.size; i++ )
	{
		if ( players[i] HasPerk( perk ) )
		{
			//iprintln("taking perk " + perk);
			perk_str = perk + "_stop";
			players[i] notify( perk_str );

			if ( flag( "solo_game" ) && perk == "specialty_quickrevive" )
			{
				players[i].lives--;
				//iprintln(level.solo_lives_given);
				level.solo_lives_given--;
			}
		}
	}
	//iprintln("took perk");
}

monkey_perk_lost( perk )
{
	if ( perk == "specialty_armorvest" )
	{
		if ( self.health > self.maxhealth )
		{
			self.health = self.maxhealth;
		}
	}

	self maps\_zombiemode_perks::update_perk_hud();
}

monkey_pack_flash_perk( perk, damage )
{
	if ( !isdefined( perk ) )
	{
		return;
	}

	players = getplayers();
	for ( i = 0; i < players.size; i++ )
	{
		players[i] maps\_zombiemode_perks::perk_hud_start_flash( perk, damage );
	}
}
