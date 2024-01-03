post_init()
{
	set_zombie_var( "microwavegun_sizzle_range",		550); //480 )
    init_tesla();
}

init_tesla()
{
	level._effect["tesla_bolt"]				= loadfx( "maps/zombie/fx_zombie_tesla_bolt_secondary" );
	level._effect["tesla_shock"]			= loadfx( "maps/zombie/fx_zombie_tesla_shock" );
	level._effect["tesla_shock_secondary"]	= loadfx( "maps/zombie/fx_zombie_tesla_shock_secondary" );

	level._effect["tesla_shock_eyes"]		= loadfx( "maps/zombie/fx_zombie_tesla_shock_eyes" );

	precacheshellshock( "electrocution" );

	//set_zombie_var( "tesla_max_arcs",			3 );
	//set_zombie_var( "tesla_max_enemies_killed", 4 );
	//set_zombie_var( "tesla_radius_decay",		20 );
	//set_zombie_var( "tesla_radius_start",		150 );
	set_zombie_var( "tesla_min_fx_distance",	128 );
	set_zombie_var( "tesla_arc_travel_time",	0.5, true );

	level.tesla_max_arcs = 3;
	level.tesla_max_enemies_killed = 3;
	level.tesla_radius_decay = 15;
	level.tesla_radius_start = 135;
}

microwavegun_network_choke()
{
	if ( level.microwavegun_network_choke_count != 0 && !(level.microwavegun_network_choke_count % 4) )
	{
		wait_network_frame();
	}

	level.microwavegun_network_choke_count++;
}


microwavegun_fired(upgraded)
{
	if ( !IsDefined( level.microwavegun_sizzle_enemies ) )
	{
		level.microwavegun_sizzle_enemies = [];
		level.microwavegun_sizzle_vecs = [];
	}

	self microwavegun_get_enemies_in_range(upgraded, false);
	self microwavegun_get_enemies_in_range(upgraded, true); // second pass does shrinkable objects.

	//iprintlnbold( "szl: " + level.microwavegun_sizzle_enemies.size );

	level.microwavegun_network_choke_count = 0;
	for ( i = 0; i < level.microwavegun_sizzle_enemies.size; i++ )
	{
		//microwavegun_network_choke();
		level.microwavegun_sizzle_enemies[i] thread microwavegun_sizzle_zombie( self, level.microwavegun_sizzle_vecs[i], i );
	}

	level.microwavegun_sizzle_enemies = [];
	level.microwavegun_sizzle_vecs = [];
}

microwavegun_sizzle_zombie( player, sizzle_vec, index )
{
	if( !IsDefined( self ) || !IsAlive( self ) )
	{
		// guy died on us
		return;
	}

	if ( IsDefined( self.microwavegun_sizzle_func ) )
	{
		self [[ self.microwavegun_sizzle_func ]]( player );
		return;
	}

	self.no_gib = true;
	self.gibbed = true;

	self DoDamage( self.health + 666, player.origin, player );

	if ( self.health <= 0 )
	{
		points = 10;
		if ( !index )
		{
			points = maps\_zombiemode_score::get_zombie_death_player_points();
		}
		else if ( 1 == index )
		{
			points = 30;
		}
		player maps\_zombiemode_score::player_add_points( "thundergun_fling", points );

		self.microwavegun_death = true;

		if ( !self.isdog )
		{
			if ( self.has_legs )
			{
				self.deathanim = random( level._zombie_microwavegun_zap_death[self.animname] );
			}
			else
			{
				self.deathanim = random( level._zombie_microwavegun_zap_crawl_death[self.animname] );
			}
		}
		else
		{
			self.a.nodeath = undefined;
		}

		if ( is_true( self.is_traversing ) )
		{
			self.deathanim = undefined;
		}

		self thread microwavegun_zap_death_fx( self.damageweapon );


		/*if ( !self.isdog )
		{
			if ( self.has_legs )
			{
				self.deathanim = random( level._zombie_microwavegun_sizzle_death[self.animname] );
			}
			else
			{
				self.deathanim = random( level._zombie_microwavegun_sizzle_crawl_death[self.animname] );
			}
		}
		else
		{
			self.a.nodeath = undefined;
			instant_explode = true;
		}

		if ( is_true( self.is_traversing ) || is_true( self.in_the_ceiling ) )
		{
			self.deathanim = undefined;
			instant_explode = true;
		}

		if ( instant_explode )
		{
			if( isdefined( self.animname ) && self.animname != "astro_zombie" )
			{
				self thread setup_microwavegun_vox( player );
			}
			self setclientflag( level._ZOMBIE_ACTOR_FLAG_MICROWAVEGUN_EXPAND_RESPONSE );
			wait (0.1);
			self clearclientflag( level._ZOMBIE_ACTOR_FLAG_MICROWAVEGUN_EXPAND_RESPONSE );
			self thread microwavegun_sizzle_death_ending();
		}
		else
		{
			if( isdefined( self.animname ) && self.animname != "astro_zombie" )
			{
				self thread setup_microwavegun_vox( player, 6 );
			}
			self setclientflag( level._ZOMBIE_ACTOR_FLAG_MICROWAVEGUN_INITIAL_HIT_RESPONSE );
			self.nodeathragdoll = true;
			self.handle_death_notetracks = ::microwavegun_handle_death_notetracks;
		}*/
	}
}

microwavegun_dw_zombie_hit_response_internal( mod, damageweapon, player )
{
	player endon( "disconnect" );

	if ( !IsDefined( self ) || !IsAlive( self ) )
	{
		// guy died on us
		return;
	}

	if ( !self.isdog )
	{
		if ( self.has_legs )
		{
			self.deathanim = random( level._zombie_microwavegun_zap_death[self.animname] );
		}
		else
		{
			self.deathanim = random( level._zombie_microwavegun_zap_crawl_death[self.animname] );
		}
	}
	else
	{
		self.a.nodeath = undefined;
	}

	if ( is_true( self.is_traversing ) )
	{
		self.deathanim = undefined;
	}

	self.microwavegun_dw_death = true;
	self thread microwavegun_zap_death_fx( damageweapon );

	/*if ( IsDefined( self.microwavegun_zap_damage_func ) )
	{
		self [[self.microwavegun_zap_damage_func]]( player );
		return;
	}
	else
	{
		self DoDamage( self.health + 666, self.origin, player );
	}

	player maps\_zombiemode_score::player_add_points( "death", "", "" );

	if( randomintrange(0,101) >= 75 )
	{
		player thread maps\_zombiemode_audio::create_and_play_dialog( "kill", "micro_dual" );
	}*/


	player.tesla_enemies = undefined;
	player.tesla_enemies_hit = 1;
	player.tesla_powerup_dropped = false;
	player.tesla_arc_count = 0;


	self tesla_arc_damage( self, player, 1);
}

tesla_arc_damage( source_enemy, player, arc_num )
{
	player endon( "disconnect" );

	tesla_flag_hit( self, true );
	wait_network_frame();

	radius_decay = level.tesla_radius_decay * arc_num;
	enemies = tesla_get_enemies_in_area( self GetCentroid(), level.tesla_radius_start - radius_decay, player );
	tesla_flag_hit( enemies, true );

	self thread tesla_do_damage( source_enemy, arc_num, player );

	//debug_print( "TESLA: " + enemies.size + " enemies hit during arc: " + arc_num );

	for( i = 0; i < enemies.size; i++ )
	{
		if( enemies[i] == self )
		{
			continue;
		}

		if ( tesla_end_arc_damage( arc_num + 1, player.tesla_enemies_hit) )
		{
			tesla_flag_hit( enemies[i], false );
			continue;
		}

		player.tesla_enemies_hit++;
		enemies[i] tesla_arc_damage( self, player, arc_num + 1 );
	}
}


tesla_end_arc_damage( arc_num, enemies_hit_num )
{
	if ( arc_num >= level.tesla_max_arcs )
	{
		debug_print( "TESLA: Ending arcing. Max arcs hit" );
		return true;
		//TO DO Play Super Happy Tesla sound
	}

	max = level.tesla_max_enemies_killed;


	if ( enemies_hit_num >= max )
	{
		debug_print( "TESLA: Ending arcing. Max enemies killed" );
		return true;
	}

	radius_decay = level.tesla_radius_decay * arc_num;
	if ( level.tesla_radius_start - radius_decay <= 0 )
	{
		debug_print( "TESLA: Ending arcing. Radius is less or equal to zero" );
		return true;
	}

	return false;
	//TO DO play Tesla Missed sound (sad)
}

tesla_do_damage( source_enemy, arc_num, player )
{
	player endon( "disconnect" );

	if ( arc_num > 1 )
	{
		time = RandomFloat( 0.2, 0.6 ) * arc_num;

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
		if ( player.tesla_arc_count > 2 )
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

	//player.tesla_network_death_choke++;

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

tesla_flag_hit( enemy, hit )
{
	if( IsArray( enemy ) )
	{
		for( i = 0; i < enemy.size; i++ )
		{
			enemy[i].zombie_tesla_hit = hit;
		}
	}
	else
	{
		enemy.zombie_tesla_hit = hit;
	}
}

tesla_get_enemies_in_area( origin, distance, player )
{
	distance_squared = distance * distance;
	enemies = [];

	player.tesla_enemies = GetAiSpeciesArray( "axis", "all" );
	player.tesla_enemies = get_array_of_closest( origin, player.tesla_enemies );


	zombies = player.tesla_enemies;


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

			if ( DistanceSquared( origin, test_origin ) > distance_squared )
			{
				continue;
			}

			if ( !zombies[i] DamageConeTrace(origin, player) && !BulletTracePassed( origin, test_origin, false, undefined ) && !SightTracePassed( origin, test_origin, false, undefined ) )
			{
				continue;
			}

			enemies[enemies.size] = zombies[i];
		}

	return enemies;
}

tesla_play_death_fx( arc_num )
{
	tag = "J_SpineUpper";
	//fx = "tesla_shock";
	fx = "tesla_shockmicrowavegun_zap_shock_dw";

	if ( self.isdog )
	{
		tag = "J_Spine1";
	}

	if ( arc_num > 1 )
	{
		fx = "tesla_shock_secondary";
		//fx = "tesla_shockmicrowavegun_zap_shock_dw";
	}

	network_safe_play_fx_on_tag( "tesla_death_fx", 2, level._effect[fx], self, tag );
	self playsound( "wpn_imp_tesla" );

	// if ( IsDefined( self.tesla_head_gib_func ) && !self.head_gibbed )
	// {
	// 	[[ self.tesla_head_gib_func ]]();
	// }
}

tesla_play_arc_fx( target )
{
	if ( !IsDefined( self ) || !IsDefined( target ) )
	{
		// TODO: can happen on dog exploding death
		wait( level.zombie_vars["tesla_arc_travel_time"] );
		return;
	}

	tag = "J_SpineUpper";

	if ( self.isdog )
	{
		tag = "J_Spine1";
	}

	target_tag = "J_SpineUpper";

	if ( target.isdog )
	{
		target_tag = "J_Spine1";
	}

	origin = self GetTagOrigin( tag );
	target_origin = target GetTagOrigin( target_tag );
	distance_squared = level.zombie_vars["tesla_min_fx_distance"] * level.zombie_vars["tesla_min_fx_distance"];

	if ( DistanceSquared( origin, target_origin ) < distance_squared )
	{
		debug_print( "TESLA: Not playing arcing FX. Enemies too close." );
		return;
	}

	fxOrg = Spawn( "script_model", origin );
	fxOrg SetModel( "tag_origin" );

	fx = PlayFxOnTag( level._effect["tesla_bolt"], fxOrg, "tag_origin" );
	//fx = PlayFxOnTag( level._effect["tesla_bolt"], fxOrg, "tag_origin" );
	playsoundatposition( "wpn_tesla_bounce", fxOrg.origin );

	fxOrg MoveTo( target_origin, level.zombie_vars["tesla_arc_travel_time"] );
	fxOrg waittill( "movedone" );
	fxOrg delete();
}
