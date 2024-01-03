watch_for_kicked()
{
	self endon("death");
	self endon("unshrink");
	
	self.shrinkTrigger = spawn( "trigger_radius", self.origin, 0, 30, 24 );
	self.shrinkTrigger setHintString( "" );
	self.shrinkTrigger setCursorHint( "HINT_NOICON" );

	self.shrinkTrigger EnableLinkTo();
	self.shrinkTrigger LinkTo( self );
	
	self thread delete_on_unshrink();

	while(1)
	{
		self.shrinkTrigger waittill("trigger", who);
		if(!isPlayer(who))
		{
			continue;	
		}
		
		//Don't kick zombies behind barriers
		if(!is_true(self.completed_emerging_into_playable_area))
		{
			continue;
		}
		
		//Don't kick guys with mbs (for risers, sonics, and napalms)
		if(is_true(self.magic_bullet_shield))
		{
			continue;
		}
		
		//Movement Dir
		movement = who GetNormalizedMovement();
		if ( Length(movement) < .1)
		{
			continue;
		}
		
		//Direction to enemy
		toEnemy = self.origin - who.origin;
		toEnemy = (toEnemy[0], toEnemy[1], 0);
		toEnemy = VectorNormalize( toEnemy );
		
		//Facing Direction
		forward_view_angles = AnglesToForward(who.angles);
		
		dotFacing = VectorDot( forward_view_angles, toEnemy );	//Check player is facing enemy
		
		//Kick if facing enemy
		if( dotFacing > 0.5 && movement[0] > 0.0)
		{
			//Kick if in front
			self notify("kicked");
			self kicked_death(who);	
		}
		else
		{
			//Step on
			self notify("stepped_on");
			self shrink_death(who);
		}
	}		
}

delete_on_unshrink()
{
	self endon("death");

	self waittill("unshrink");
	if( isDefined(self.shrinkTrigger))
	{
		self.shrinkTrigger Delete();
	}
}

shrink_ray_get_enemies_in_range( upgraded, shrinkable_objects )
{
	range = 1000;//480; //40 feet
	radius = 80;//60; //5 feet
	
	if(upgraded)
	{
		range = 1300;//1200; //100 feet
		radius = 85; //7 feet	
	}
	hitZombies = [];

	view_pos = self GetWeaponMuzzlePoint();

	// Add a 10% epsilon to the range on this call to get guys right on the edge
	
	test_list = undefined;
	
	if(shrinkable_objects)
	{
		test_list = level._shrinkable_objects;
		range *= 5;
	}
	else
	{
		test_list = GetAISpeciesArray("axis", "all");
	}
	
	zombies = get_array_of_closest( view_pos, test_list, undefined, undefined, (range * 1.1) );
	
	if ( !isDefined( zombies ))
	{
		return;
	}

	range_squared = range * range;
	radius_squared = radius * radius;

	forward_view_angles = self GetWeaponForwardDir();
	end_pos = view_pos + vector_scale( forward_view_angles, range );

/#
	if ( 2 == GetDvarInt( #"scr_shrink_ray_debug" ) )
	{
		// push the near circle out a couple units to avoid an assert in Circle() due to it attempting to
		// derive the view direction from the circle's center point minus the viewpos
		// (which is what we're using as our center point, which results in a zeroed direction vector)
		near_circle_pos = view_pos + vector_scale( forward_view_angles, 2 );

		Circle( near_circle_pos, radius, (1, 0, 0), false, false, 100 );
		Line( near_circle_pos, end_pos, (0, 0, 1), 1, false, 100 );
		Circle( end_pos, radius, (1, 0, 0), false, false, 100 );
	}
#/

	for ( i = 0; i < zombies.size; i++ )
	{
		if ( !IsDefined( zombies[i] ) || (IsAI(zombies[i]) && !IsAlive( zombies[i] )) )
		{
			// guy died on us
			continue;
		}
		
		if(isDefined(zombies[i].shrinked) && zombies[i].shrinked)
		{
			zombies[i] shrink_ray_debug_print( "shrinked", (1, 0, 0) );
			continue; //Dont include already shrinked guys
		}

		if ( IsDefined(zombies[i].no_shrink) && zombies[i].no_shrink )
		{
			zombies[i] shrink_ray_debug_print( "no_shrink", (1, 0, 0) );
			continue; //Dont include zombies that cannot be shrunk guys
		}

		test_origin = zombies[i] getcentroid();
		test_range_squared = DistanceSquared( view_pos, test_origin );
		if ( test_range_squared > range_squared )
		{
			zombies[i] shrink_ray_debug_print( "range", (1, 0, 0) );
			break; // everything else in the list will be out of range
		}

		normal = VectorNormalize( test_origin - view_pos );
		dot = VectorDot( forward_view_angles, normal );
		if ( 0 > dot )
		{
			// guy's behind us
			zombies[i] shrink_ray_debug_print( "dot", (1, 0, 0) );
			continue;
		}
		
		radial_origin = PointOnSegmentNearestToPoint( view_pos, end_pos, test_origin );
		if ( DistanceSquared( test_origin, radial_origin ) > radius_squared )
		{
			// guy's outside the range of the cylinder of effect
			zombies[i] shrink_ray_debug_print( "cylinder", (1, 0, 0) );
			continue;
		}

		if ( 0 == zombies[i] DamageConeTrace( view_pos, self ) )
		{
			// guy can't actually be hit from where we are
			zombies[i] shrink_ray_debug_print( "cone", (1, 0, 0) );
			continue;
		}

		hitZombies[hitZombies.size] = zombies[i];
	}
	
	return hitZombies;
}
