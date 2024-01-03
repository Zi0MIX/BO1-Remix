#using_animtree( "zombie_cymbal_monkey" );
player_handle_cymbal_monkey()
{
	//self notify( "starting_monkey_watch" );
	self endon( "disconnect" );
	//self endon( "starting_monkey_watch" );

	// Min distance to attract positions
	attract_dist_diff = level.monkey_attract_dist_diff;
	if( !isDefined( attract_dist_diff ) )
	{
		attract_dist_diff = 45;
	}

	num_attractors = level.num_monkey_attractors;
	if( !isDefined( num_attractors ) )
	{
		num_attractors = 96;
	}

	max_attract_dist = level.monkey_attract_dist;
	if( !isDefined( max_attract_dist ) )
	{
		max_attract_dist = 1536;
	}

	grenade = get_thrown_monkey();
	self thread player_handle_cymbal_monkey();
	if( IsDefined( grenade ) )
	{
		if( self maps\_laststand::player_is_in_laststand() )
		{
			grenade delete();
			return;
		}

		grenade hide();
		grenade.angles = (0, grenade.angles[1], 0);

		model = spawn( "script_model", grenade.origin );
		model.angles = grenade.angles;
		model SetModel( "weapon_zombie_monkey_bomb" );
		model UseAnimTree( #animtree );
		model linkTo( grenade );

		info = spawnStruct();
		info.sound_attractors = [];
		grenade thread monitor_zombie_groans( info );
		velocitySq = 10000*10000;
		oldPos = grenade.origin;

		while( velocitySq != 0 )
		{
			wait( 0.05 );

			if( !isDefined( grenade ) )
			{
				return;
			}

			velocitySq = distanceSquared( grenade.origin, oldPos );
			oldPos = grenade.origin;
		}

		if( isDefined( grenade ) )
		{
			model SetAnim( %o_monkey_bomb );
			model thread monkey_cleanup( grenade );

			model unlink();
			model.origin = grenade.origin;
			model.angles = grenade.angles;

			grenade resetmissiledetonationtime();
			PlayFxOnTag( level._effect["monkey_glow"], model, "origin_animate_jnt" );

			valid_poi = check_point_in_active_zone( grenade.origin );

			if( !valid_poi )
			{
				valid_poi = check_point_in_playable_area( grenade.origin );
			}

			if(valid_poi)
			{
				grenade create_zombie_point_of_interest( max_attract_dist, num_attractors, 0 );
				level notify("attractor_positions_generated");
			}
			else
			{
				self.script_noteworthy = undefined;
			}

			grenade thread do_monkey_sound( model, info );
		}

		//level thread maps\_zombiemode_weapons::entity_stolen_by_sam( grenade, model );
	}
}

do_monkey_sound( model, info )
{
	monk_scream_vox = false;

	if( isdefined(level.monk_scream_trig) && self IsTouching( level.monk_scream_trig))
	{
		self playsound( "zmb_vox_monkey_scream" );
		monk_scream_vox = true;
	}
	else if( level.music_override == false )
	{
		monk_scream_vox = false;
		self playsound( "zmb_monkey_song" );
	}

	self thread play_delayed_explode_vox();

	self waittill( "explode", position );
	if( isDefined( model ) )
	{
		model ClearAnim( %o_monkey_bomb, 0.2 );
	}

	for( i = 0; i < info.sound_attractors.size; i++ )
	{
		if( isDefined( info.sound_attractors[i] ) )
		{
			info.sound_attractors[i] notify( "monkey_blown_up" );
		}
	}

	if( !monk_scream_vox )
	{
		//play_sound_in_space( "zmb_vox_monkey_explode", position );
	}
	else
	{
		thread play_sam_furnace();
	}

	level notify("attractor_positions_generated");
}

