post_init()
{
	set_zombie_var( "tesla_max_enemies_killed", 10 );
	set_zombie_var( "tesla_max_enemies_killed_upgraded", 12 );
}

tesla_damage_init( hit_location, hit_origin, player )
{
	player endon( "disconnect" );

	// Make sure the closest zombie from the hit origin is the one that initially gets hit
	zombs = getaispeciesarray("axis");
	zombs_hit = [];
	for(i=0;i<zombs.size;i++)
	{
		if(IsDefined(zombs[i].attacker) && zombs[i].attacker == player)
		{
			if(IsDefined(zombs[i].damageweapon) && (zombs[i].damageweapon == "tesla_gun_zm" || zombs[i].damageweapon == "tesla_gun_upgraded_zm" || zombs[i].damageweapon == "tesla_gun_powerup_zm" || zombs[i].damageweapon == "tesla_gun_powerup_upgraded_zm"))
			{
				if(!is_true(zombs[i].zombie_tesla_hit) && !is_true(zombs[i].humangun_zombie_1st_hit_response))
				{
					zombs_hit[zombs_hit.size] = zombs[i];
				}
			}
		}
	}
	if(zombs_hit.size == 0)
	{
		return;
	}
	closest_zomb = GetClosest(hit_origin, zombs_hit);
	if(self != closest_zomb)
	{
		return;
	}

	if ( IsDefined( player.tesla_enemies_hit ) && player.tesla_enemies_hit > 0 )
	{
		debug_print( "TESLA: Player: '" + player.playername + "' currently processing tesla damage" );
		return;
	}

	if( IsDefined( self.zombie_tesla_hit ) && self.zombie_tesla_hit )
	{
		// can happen if an enemy is marked for tesla death and player hits again with the tesla gun
		return;
	}

	debug_print( "TESLA: Player: '" + player.playername + "' hit with the tesla gun" );

	//TO DO Add Tesla Kill Dialog thread....

	player.tesla_enemies = undefined;
	player.tesla_enemies_hit = 1;
	player.tesla_powerup_dropped = false;
	player.tesla_arc_count = 0;

	upgraded = (self.damageweapon == "tesla_gun_upgraded_zm" || self.damageweapon == "tesla_gun_powerup_upgraded_zm");

	self tesla_arc_damage( self, player, 1, upgraded );

	if( player.tesla_enemies_hit >= 4)
	{
		player thread tesla_killstreak_sound();
	}

	player.tesla_enemies_hit = 0;
}

// this enemy is in the range of the source_enemy's tesla effect
tesla_arc_damage( source_enemy, player, arc_num, upgraded )
{
	player endon( "disconnect" );

	debug_print( "TESLA: Evaulating arc damage for arc: " + arc_num + " Current enemies hit: " + player.tesla_enemies_hit );

	tesla_flag_hit( self, true );
	wait_network_frame();

	radius_decay = level.zombie_vars["tesla_radius_decay"] * arc_num;
	enemies = tesla_get_enemies_in_area( self GetCentroid(), level.zombie_vars["tesla_radius_start"] - radius_decay, player );
	tesla_flag_hit( enemies, true );

	self thread tesla_do_damage( source_enemy, arc_num, player, upgraded );

	debug_print( "TESLA: " + enemies.size + " enemies hit during arc: " + arc_num );

	for( i = 0; i < enemies.size; i++ )
	{
		if( enemies[i] == self )
		{
			continue;
		}

		if ( tesla_end_arc_damage( arc_num + 1, player.tesla_enemies_hit, upgraded ) )
		{
			tesla_flag_hit( enemies[i], false );
			continue;
		}

		player.tesla_enemies_hit++;
		enemies[i] tesla_arc_damage( self, player, arc_num + 1, upgraded );
	}
}


tesla_end_arc_damage( arc_num, enemies_hit_num, upgraded )
{
	if ( arc_num >= level.zombie_vars["tesla_max_arcs"] )
	{
		debug_print( "TESLA: Ending arcing. Max arcs hit" );
		return true;
		//TO DO Play Super Happy Tesla sound
	}

	max = level.zombie_vars["tesla_max_enemies_killed"];
	if(upgraded)
	{
		max = level.zombie_vars["tesla_max_enemies_killed_upgraded"];
	}

	if ( enemies_hit_num >= max )
	{
		debug_print( "TESLA: Ending arcing. Max enemies killed" );
		return true;
	}

	radius_decay = level.zombie_vars["tesla_radius_decay"] * arc_num;
	if ( level.zombie_vars["tesla_radius_start"] - radius_decay <= 0 )
	{
		debug_print( "TESLA: Ending arcing. Radius is less or equal to zero" );
		return true;
	}

	return false;
	//TO DO play Tesla Missed sound (sad)
}


tesla_get_enemies_in_area( origin, distance, player )
{
	/#
		level thread tesla_debug_arc( origin, distance );
	#/

	distance_squared = distance * distance;
	enemies = [];

	if ( !IsDefined( player.tesla_enemies ) )
	{
		player.tesla_enemies = GetAiSpeciesArray( "axis", "all" );
		player.tesla_enemies = get_array_of_closest( origin, player.tesla_enemies );
	}

	zombies = player.tesla_enemies;

	if ( IsDefined( zombies ) )
	{
		for ( i = 0; i < zombies.size; i++ )
		{
			if ( !IsDefined( zombies[i] ) )
			{
				continue;
			}

			test_origin = zombies[i] GetCentroid();

			if ( IsDefined( zombies[i].zombie_tesla_hit ) && zombies[i].zombie_tesla_hit == true )
			{
				continue;
			}

			if ( is_magic_bullet_shield_enabled( zombies[i] ) )
			{
				continue;
			}

			if ( DistanceSquared( origin, test_origin ) > distance_squared )
			{
				continue;
			}

			if ( !zombies[i] DamageConeTrace(origin, player) && !BulletTracePassed( origin, test_origin, false, undefined ) && !SightTracePassed( origin, test_origin, false, undefined ) )
			{
				continue;
			}

			if ( is_true(zombies[i].humangun_zombie_1st_hit_response) )
			{
				continue;
			}

			enemies[enemies.size] = zombies[i];
		}
	}

	return enemies;
}

tesla_do_damage( source_enemy, arc_num, player, upgraded )
{
	player endon( "disconnect" );

	if ( arc_num > 1 )
	{
		time = RandomFloat( 0.2, 0.6 ) * arc_num;

		if(upgraded)
		{
			time /= 1.5;
		}

		wait time;
	}

	if( !IsDefined( self ) || !IsAlive( self ) )
	{
		// guy died on us
		return;
	}

	if ( !self.isdog )
	{
		if( self.has_legs )
		{
			self.deathanim = random( level._zombie_tesla_death[self.animname] );
		}
		else
		{
			self.deathanim = random( level._zombie_tesla_crawl_death[self.animname] );
		}
	}
	else
	{
		self.a.nodeath = undefined;
	}

	if( is_true( self.is_traversing))
	{
		self.deathanim = undefined;
	}

	if( source_enemy != self )
	{
		if ( player.tesla_arc_count > 3 )
		{
			wait_network_frame();
			player.tesla_arc_count = 0;
		}

		player.tesla_arc_count++;
		source_enemy tesla_play_arc_fx( self );
	}

	/*while ( player.tesla_network_death_choke > level.zombie_vars["tesla_network_death_choke"] )
	{
		debug_print( "TESLA: Choking Tesla Damage. Dead enemies this network frame: " + player.tesla_network_death_choke );
		wait( 0.05 );
	}*/

	if( !IsDefined( self ) || !IsAlive( self ) )
	{
		// guy died on us
		return;
	}

	player.tesla_network_death_choke++;

	self.tesla_death = true;
	self tesla_play_death_fx( arc_num );

	// use the origin of the arc orginator so it pics the correct death direction anim
	origin = source_enemy.origin;
	if ( source_enemy == self || !IsDefined( origin ) )
	{
		origin = player.origin;
	}

	if( !IsDefined( self ) || !IsAlive( self ) )
	{
		// guy died on us
		return;
	}

	if ( IsDefined( self.tesla_damage_func ) )
	{
		self [[ self.tesla_damage_func ]]( origin, player );
		return;
	}
	else
	{
		self DoDamage( self.health + 666, origin, player );
	}

	if(!self.isdog)
	{
		player maps\_zombiemode_score::player_add_points( "death", "", "" );
	}

// 	if ( !player.tesla_powerup_dropped && player.tesla_enemies_hit >= level.zombie_vars["tesla_kills_for_powerup"] )
// 	{
// 		player.tesla_powerup_dropped = true;
// 		level.zombie_vars["zombie_drop_item"] = 1;
// 		level thread maps\_zombiemode_powerups::powerup_drop( self.origin );
// 	}
}

is_tesla_damage( mod )
{
	return ( ( IsDefined( self.damageweapon ) && (self.damageweapon == "tesla_gun_zm" || self.damageweapon == "tesla_gun_upgraded_zm" || self.damageweapon == "tesla_gun_powerup_zm" || self.damageweapon == "tesla_gun_powerup_upgraded_zm") ) && ( mod == "MOD_PROJECTILE" || mod == "MOD_PROJECTILE_SPLASH" ) );
}

tesla_sound_thread()
{
	self endon( "disconnect" );
	self waittill( "spawned_player" );

	for( ;; )
	{
		result = self waittill_any_return( "grenade_fire", "death", "player_downed", "weapon_change", "grenade_pullback" );

		if ( !IsDefined( result ) )
		{
			continue;
		}

		if( ( result == "weapon_change" || result == "grenade_fire" ) && (self GetCurrentWeapon() == "tesla_gun_zm" || self GetCurrentWeapon() == "tesla_gun_upgraded_zm" || self GetCurrentWeapon() == "tesla_gun_powerup_zm" || self GetCurrentWeapon() == "tesla_gun_powerup_upgraded_zm") )
		{
			self PlayLoopSound( "wpn_tesla_idle", 0.25 );
			//self thread tesla_engine_sweets();
		}
		else
		{
			self notify ("weap_away");
			self StopLoopSound(0.25);
		}
	}
}
tesla_engine_sweets()
{
	self endon( "disconnect" );
	self endon ("weap_away");

	while(1)
	{
		wait(randomintrange(7,15));
		self play_tesla_sound ("wpn_tesla_sweeps_idle");
	}
}


tesla_pvp_thread()
{
	self endon( "disconnect" );
	self endon( "death" );
	self waittill( "spawned_player" );

	for( ;; )
	{
		self waittill( "weapon_pvp_attack", attacker, weapon, damage, mod );

		if( self maps\_laststand::player_is_in_laststand() )
		{
			continue;
		}

		if ( weapon != "tesla_gun_zm" && weapon != "tesla_gun_upgraded_zm" && weapon != "tesla_gun_powerup_zm" && weapon != "tesla_gun_powerup_upgraded_zm" )
		{
			continue;
		}

		if ( mod != "MOD_PROJECTILE" && mod != "MOD_PROJECTILE_SPLASH" )
		{
			continue;
		}

		//if ( self == attacker )
		//{
			/*damage = int( self.maxhealth * .25 );
			if ( damage < 25 )
			{
				damage = 25;
			}*/

		//	damage = 75;

		//	self.health -= damage;
		//}

		self setelectrified( 1.0 );
		self shellshock( "electrocution", 1.0 );
		self playsound( "wpn_tesla_bounce" );
	}
}