#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;

_watch_for_powerups()
{
	if ( !IsDefined(level.monkey_zombie_spawners) || level.monkey_zombie_spawners.size == 0 )
	{
		return;
	}
	level waittill("powerup_dropped", powerup);
	level thread _watch_for_powerups();

	if(!isDefined(powerup))
	{
		return;
	}

	if ( level.round_number < level.nextMonkeyStealRound )
	{
		return;
	}

	wait .5;

	if ( _canGrabPowerup(powerup) )
	{
		_grab_powerup(powerup);
	}
}

_grab_powerup(powerup)
{
	// just use the first spawner and teleport the monkey (like dogs)
	spawner = level.monkey_zombie_spawners[0];

	monkey = spawner StalingradSpawn();
	/*if ( spawn_failed(monkey) )
	{
		return;
	}*/
	while ( spawn_failed(monkey) )
	{
		wait_network_frame();
		monkey = spawner StalingradSpawn();
	}

	//Try always stealing
	level.nextMonkeyStealRound = 1; //level.round_number + RandomIntRange(2,4);
	/#
	cheat = GetDvarInt("monkey_steal_debug");
	if ( cheat )
	{
		// just slam it down so monkeys chase powerups every time
		level.nextMonkeyStealRound = 1;
	}
    #/

	//Players are getting hung up on monkeys and not understanding why.
	//NOTE: If we turn off collision we will not get aim assist
	//monkey setplayercollision(0);

	monkey.ignore_enemy_count = true;
	monkey.meleeDamage = 10;
	monkey.custom_damage_func = ::monkey_temple_custom_damage;

	monkey ForceTeleport(powerup.origin, monkey.angles);
	location = monkey _monkey_GetSpawnLocation(powerup.origin);
	monkey ForceTeleport( location, monkey.angles );
	monkey.deathFunction = ::_monkey_zombieTempleEscapeDeathCallback;
	monkey.shrink_ray_fling = ::_monkey_TempleFling;
	monkey.zombie_sliding = ::_monkey_TempleSliding;

	monkey.no_shrink = false;
	monkey.ignore_solo_last_stand = 1;

	monkey disable_pain();

	// Don't play fx to help sell that monkeys come from enviroment
	//PlayFX( level._effect["monkey_death"], monkey.origin );
	//playsoundatposition( "zmb_stealer_spawn", monkey.origin );

	spawner.count = 100;
	spawner.last_spawn_time = GetTime();

	// path to the powerup
	monkey thread monkey_zombie_choose_sprint_temple();
	//monkey thread maps\_zombiemode_ai_monkey::play_random_monkey_vox();

	monkey.powerup_to_grab = powerup;
	monkey thread _monkey_zombie_grenade_watcher();
	monkey thread _monkey_CheckPlayableArea();
	monkey thread _monkey_timeout();
	monkey thread _monkey_StealPowerup();
}

_powerup_randomize(monkey)
{
	self endon("stop_randomize");
	monkey endon("remove");

	//powerup_cycle = array("carpenter","fire_sale","nuke","double_points","insta_kill");
	powerup_cycle = array("fire_sale","nuke","double_points","insta_kill");
	powerup_cycle = array_randomize_knuth(powerup_cycle);
	powerup_cycle[powerup_cycle.size] = "full_ammo"; //Ammo is always last

	//Remove fire sale so the players can not get firesale too early.
	if(level.chest_moves >= 1 || level.round_number <= 5)
	{
		powerup_cycle = array_remove_nokeys(powerup_cycle, "fire_sale");
	}

	// if(level.round_number<=1)
	// {
	// 	powerup_cycle = array_remove_nokeys(powerup_cycle, "nuke");
	// }

	//Find current power up name
	currentPowerUp = undefined;
	keys = GetArrayKeys( level.zombie_powerups );
	for(i=0;i<keys.size;i++)
	{
		if(level.zombie_powerups[keys[i]].model_name == self.model)
		{
			currentPowerUp = keys[i];
			break;
		}
	}
	//Move the current powerup to the front of the list
	if(isdefined(currentPowerUp))
	{
		powerup_cycle = array_remove(powerup_cycle, currentPowerUp);
		powerup_cycle = array_insert(powerup_cycle, currentPowerUp, 0);
	}
	//Add Perk bottel if this is a max ammo and its the f
	if(currentPowerUp == "full_ammo" && self.grab_count == 1)
	{
		index = randomintrange(1, powerup_cycle.size - 1);
		powerup_cycle = array_insert(powerup_cycle, "free_perk", index);
	}

	wait 1;

	index = 1; //Skip first because it is set to the current powerup
	while ( true )
	{
		powerupName = powerup_cycle[index];
		index++;
		if ( index >= powerup_cycle.size )
		{
			index = 0;
		}

		self maps\_zombiemode_powerups::powerup_setup( powerupName );

		monkey _monkey_BindPowerup(self);

		if(powerupName=="free_perk")
		{
			wait .25;
		}
		else
		{
			wait 1;
		}
	}
}

monkey_ambient_drops_remove_array()
{
	while(1)
	{
		previousSize = level.monkey_drops.size;
		level.monkey_drops = remove_undefined_from_array(level.monkey_drops);

		for(i=0;i<level.monkey_drops.size;i++)
		{
			if(IsDefined(level.monkey_drops[i].stolen) && level.monkey_drops[i].stolen)
				level.monkey_drops = array_remove(level.monkey_drops, level.monkey_drops[i]);
		}

		if(level.monkey_drops.size == 0 && previousSize != 0)
		{
			flag_clear("monkey_ambient_excited");
		}
		wait .1;
	}
}
