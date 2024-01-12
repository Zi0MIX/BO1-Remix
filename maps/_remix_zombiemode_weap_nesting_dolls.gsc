#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include animscripts\zombie_Utility;

player_give_nesting_dolls()
{
	// create our randomized index arrays here so we can pass the appropriate first cammo
	self nesting_dolls_create_randomized_indices( 0 );

	start_cammo = level.nesting_dolls_data[ self.nesting_dolls_randomized_indices[0][0] ].id;

	self giveweapon( "zombie_nesting_dolls", 0, self CalcWeaponOptions( start_cammo ) );
	self set_player_tactical_grenade( "zombie_nesting_dolls" );

	// fix for grenade ammo
	if(is_tactical_grenade("zombie_nesting_dolls") && self GetWeaponAmmoClip("zombie_nesting_dolls") > 3)
	{
		self SetWeaponAmmoClip("zombie_nesting_dolls", 3);
	}

	self thread player_handle_nesting_dolls();
}

#using_animtree( "zombie_cymbal_monkey" ); // WW: A new animtree or should we just use generic human's throw?
player_handle_nesting_dolls()
{
	//self notify( "starting_nesting_dolls" );
	self endon( "disconnect" );
	//self endon( "starting_nesting_dolls" );

	grenade = get_thrown_nesting_dolls();
	self thread player_handle_nesting_dolls();
	if( IsDefined( grenade ) )
	{
		if( self maps\_laststand::player_is_in_laststand() )
		{
			grenade delete();
			return;
		}

		self thread doll_spawner_cluster( grenade );
	}
}

// FYI it's not actually used, like ever
doll_spawner( start_grenade )
{
	self endon( "disconnect" );
	self endon( "death" );

	// initialize the number of dolls
	num_dolls = 1;

	// define the maximum to spawn
	max_dolls = 4;

	// get the id of this doll run
	self nesting_dolls_set_id();

	// switch cammo
	self thread nesting_dolls_setup_next_doll_throw();

	// spin off the achievement threads
	//self thread nesting_dolls_track_achievement( self.doll_id );
	//self thread nesting_dolls_check_achievement( self.doll_id );

	// so the compiler doesn't puke
	if ( IsDefined( start_grenade ) )
	{
		start_grenade spawn_doll_model( self.doll_id, 0, self );
		start_grenade thread doll_behavior_explode_when_stopped( self, self.doll_id, 0 );
	}

	start_grenade waittill( "spawn_doll", origin, angles );

	while( num_dolls < max_dolls )
	{
		grenade_vel = self get_launch_velocity( origin, 2000 );
		if ( grenade_vel == ( 0, 0, 0 ) )
		{
			grenade_vel = self get_random_launch_velocity( origin, angles);
		}

		grenade = self MagicGrenadeType( "zombie_nesting_doll_single", origin, grenade_vel );
		grenade spawn_doll_model( self.doll_id, num_dolls, self );
		grenade thread doll_behavior_explode_when_stopped( self, self.doll_id, num_dolls );

		//self thread nesting_dolls_tesla_nearby_zombies( grenade );

		num_dolls++;

		grenade waittill( "spawn_doll", origin, angles );
	}
}

doll_spawner_cluster( start_grenade )
{
	self endon( "disconnect" );
	self endon( "death" );

	// initialize the number of dolls
	num_dolls = 1;

	// define the maximum to spawn
	max_dolls = 4;

	// get the id of this doll run
	self nesting_dolls_set_id();

	// switch cammo
	self thread nesting_dolls_setup_next_doll_throw();

	// spin off the achievement threads
	self thread nesting_dolls_track_achievement( self.doll_id );
	self thread nesting_dolls_check_achievement( self.doll_id );

	// so the compiler doesn't puke
	if ( IsDefined( start_grenade ) )
	{
		start_grenade.angles = (0, start_grenade.angles[1], 0);

		start_grenade spawn_doll_model( self.doll_id, 0, self );
		start_grenade thread doll_behavior_explode_when_stopped( self, self.doll_id, 0 );
	}

	start_grenade waittill( "spawn_doll", origin, angles );

	while( num_dolls < max_dolls )
	{

		// get a velocity
		grenade_vel = self get_cluster_launch_velocity( angles, num_dolls );

		// spawn a magic grenade
		grenade = self MagicGrenadeType( "zombie_nesting_doll_single", origin, grenade_vel );
		grenade.angles = (0, grenade.angles[1], 0);
		grenade spawn_doll_model( self.doll_id, num_dolls, self );

		grenade PlaySound( "wpn_nesting_pop_npc" );

		grenade thread doll_behavior_explode_when_stopped( self, self.doll_id, num_dolls );

		num_dolls++;

		wait( 0.25 );
	}
}

doll_do_damage( origin, owner, id, index )
{
	self waittill( "explode" );

	zombies = GetAiSpeciesArray( "axis", "all" );
	if ( zombies.size == 0 )
	{
		return;
	}

	zombie_sort = get_array_of_closest( origin, zombies, undefined, undefined, level.nesting_dolls_damage_radius );

	// "Name: DoDamage( <health>, <source position>, <attacker>, <destructible_piece_index>, <means of death>, <hitloc> )"
	for ( i = 0; i < zombie_sort.size; i++ )
	{
		if ( IsAlive( zombie_sort[i] ) )
		{
			if ( zombie_sort[i] DamageConeTrace( origin, owner ) == 1 )
			{
				//// Kill 'em
				//zombie_sort[i] DoDamage( zombie_sort[i].health + 666, origin, owner, 0, "explosive", "none" );

				// track for the achievement
				owner.nesting_dolls_tracker[id][index] = owner.nesting_dolls_tracker[id][index] + 1;

				// Debug
				//PrintLn("ID: " + id + " Doll: " + index + " Count: " + owner.nesting_dolls_tracker[id][index] );
			}
		}
	}

	RadiusDamage( origin, level.nesting_dolls_damage_radius, level.zombie_health + 666, level.zombie_health + 666, owner, "MOD_GRENADE_SPLASH", "zombie_nesting_doll_single" );
}

spawn_doll_model( id, index, parent )
{
	// hide the grenade model
	self hide();

	// spawn the doll model
	self.doll_model = spawn( "script_model", self.origin );
	self.doll_model.angles = self.angles + (0, 180, 0);

	// fix out the index
	data_index = parent.nesting_dolls_randomized_indices[ id ][ index ];

	// get the name from the data array...
	name = level.nesting_dolls_data[ data_index ].name;

	// construct the name
	model_index = index + 1;
	model_name = "t5_nesting_bomb_world_doll" + model_index + "_" + name;

	// finish setting up
	self.doll_model SetModel( model_name );
	self.doll_model UseAnimTree( #animtree );
	self.doll_model LinkTo( self );

	// attach the effect
	PlayFxOnTag( level.nesting_dolls_data[ data_index ].trailFx, self.doll_model, "tag_origin" );

	// spin off the clean up thread here
	self.doll_model thread nesting_dolls_cleanup( self );
}

doll_behavior_explode_when_stopped( parent, doll_id, index )
{
	velocitySq = 10000*10000;
	oldPos = self.origin;

	wait .05;

	while( velocitySq != 0 )
	{
		wait( 0.1 );

		if( !isDefined( self ) )
		{
			break;
		}

		velocitySq = distanceSquared( self.origin, oldPos );
		oldPos = self.origin;
	}

	if( isDefined( self ) )
	{
		// spawn a new doll
		self notify( "spawn_doll", self.origin, self.angles );

		// spin the damage thread
		self thread doll_do_damage( self.origin, parent, doll_id, index );

		// blow up!
		self ResetMissileDetonationTime( level.nesting_dolls_det_time );

		// if we're the last doll
		if ( IsDefined( index ) && index == 3 )
		{
			parent thread nesting_dolls_end_achievement_tracking( doll_id );
		}
	}
}
