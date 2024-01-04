post_init()
{
    level._effect["thundergun_knockdown_ground"]    = loadfx( "weapon/thunder_gun/fx_thundergun_knockback_ground" );
    level._effect["thundergun_smoke_cloud"]         = loadfx( "weapon/thunder_gun/fx_thundergun_smoke_cloud" );

    set_zombie_var( "thundergun_cylinder_radius",       180 );

    set_zombie_var( "thundergun_fling_range",           650 ); // 40 feet
    set_zombie_var( "thundergun_gib_range",             1200 ); // 75 feet
    set_zombie_var( "thundergun_knockdown_range",       1500 ); // 100 feet
    if(level.script == "zombie_ww")
    {
        set_zombie_var( "thundergun_fling_range",           2000);//450 ); // 40 feet
        set_zombie_var( "thundergun_gib_range",             3000);//900 ); // 75 feet
        set_zombie_var( "thundergun_knockdown_range",       3200 ); // 100 feet
    }

    set_zombie_var( "thundergun_gib_damage",            0 );
    set_zombie_var( "thundergun_knockdown_damage",      0 );
}

wait_for_thundergun_fired()
{
    self endon( "disconnect" );
    self waittill( "spawned_player" );

    for( ;; )
    {
        self waittill( "weapon_fired" );
        currentweapon = self GetCurrentWeapon();
        if( ( currentweapon == "thundergun_zm" ) || ( currentweapon == "thundergun_upgraded_zm" ) )
        {
            self thread thundergun_fired(currentweapon);

            view_pos = self GetTagOrigin( "tag_flash" ) - self GetPlayerViewHeight();
            view_angles = self GetTagAngles( "tag_flash" );
            playfx( level._effect["thundergun_smoke_cloud"], view_pos, AnglesToForward( view_angles ), AnglesToUp( view_angles ) );
        }
    }
}


thundergun_network_choke()
{
    if ( level.thundergun_network_choke_count != 0 && !(level.thundergun_network_choke_count % 4) )
    {
        wait_network_frame();
        //wait_network_frame();
        //wait_network_frame();
    }

    level.thundergun_network_choke_count++;
}


thundergun_fired(currentweapon)
{
    // ww: physics hit when firing
    PhysicsExplosionCylinder( self.origin, 600, 240, 1 );

    if ( !IsDefined( level.thundergun_knockdown_enemies ) )
    {
        level.thundergun_knockdown_enemies = [];
        level.thundergun_knockdown_gib = [];
        level.thundergun_fling_enemies = [];
        level.thundergun_fling_vecs = [];
    }

    self thundergun_get_enemies_in_range();

    //iprintlnbold( "flg: " + level.thundergun_fling_enemies.size + " gib: " + level.thundergun_gib_enemies.size + " kno: " + level.thundergun_knockdown_enemies.size );

    level.thundergun_network_choke_count = 0;
    for ( i = 0; i < level.thundergun_fling_enemies.size; i++ )
    {
        //thundergun_network_choke();
        if(IsAI(level.thundergun_fling_enemies[i]))
        {
            level.thundergun_fling_enemies[i] thread thundergun_fling_zombie( self, level.thundergun_fling_vecs[i], i );
        }
        else if(IsPlayer(level.thundergun_fling_enemies[i]))
        {
            vec = vector_scale( level.thundergun_fling_vecs[i], 3 );
            level.thundergun_fling_enemies[i] notify("grief_damage", currentweapon, "MOD_PROJECTILE", self, true, vec);
        }
    }

    for ( i = 0; i < level.thundergun_knockdown_enemies.size; i++ )
    {
        //thundergun_network_choke();
        if(IsAI(level.thundergun_fling_enemies[i]))
        {
            level.thundergun_knockdown_enemies[i] thread thundergun_knockdown_zombie( self, level.thundergun_knockdown_gib[i] );
        }
        else if(IsPlayer(level.thundergun_fling_enemies[i]))
        {
            level.thundergun_fling_enemies[i] notify("grief_damage", currentweapon, "MOD_PROJECTILE", self);
        }
    }

    level.thundergun_knockdown_enemies = [];
    level.thundergun_knockdown_gib = [];
    level.thundergun_fling_enemies = [];
    level.thundergun_fling_vecs = [];
}


thundergun_get_enemies_in_range()
{
    view_pos = self GetWeaponMuzzlePoint();
    zombies = GetAiSpeciesArray( "axis", "all" );
    zombies = array_merge(zombies, get_players());
    zombies = get_array_of_closest( view_pos, zombies, undefined, undefined, level.zombie_vars["thundergun_knockdown_range"] );
    if ( !isDefined( zombies ) )
    {
        return;
    }

    knockdown_range_squared = level.zombie_vars["thundergun_knockdown_range"] * level.zombie_vars["thundergun_knockdown_range"];
    gib_range_squared = level.zombie_vars["thundergun_gib_range"] * level.zombie_vars["thundergun_gib_range"];
    fling_range_squared = level.zombie_vars["thundergun_fling_range"] * level.zombie_vars["thundergun_fling_range"];
    cylinder_radius_squared = level.zombie_vars["thundergun_cylinder_radius"] * level.zombie_vars["thundergun_cylinder_radius"];

    forward_view_angles = self GetWeaponForwardDir();
    end_pos = view_pos + vector_scale( forward_view_angles, level.zombie_vars["thundergun_knockdown_range"] );

/#
    if ( 2 == GetDvarInt( #"scr_thundergun_debug" ) )
    {
        // push the near circle out a couple units to avoid an assert in Circle() due to it attempting to
        // derive the view direction from the circle's center point minus the viewpos
        // (which is what we're using as our center point, which results in a zeroed direction vector)
        near_circle_pos = view_pos + vector_scale( forward_view_angles, 2 );

        Circle( near_circle_pos, level.zombie_vars["thundergun_cylinder_radius"], (1, 0, 0), false, false, 100 );
        Line( near_circle_pos, end_pos, (0, 0, 1), 1, false, 100 );
        Circle( end_pos, level.zombie_vars["thundergun_cylinder_radius"], (1, 0, 0), false, false, 100 );
    }
#/

    for ( i = 0; i < zombies.size; i++ )
    {
        if ( !IsDefined( zombies[i] ) || !IsAlive( zombies[i] ) )
        {
            // guy died on us
            continue;
        }

        test_origin = zombies[i] GetCentroid();
        test_range_squared = DistanceSquared( view_pos, test_origin );
        if ( test_range_squared > knockdown_range_squared )
        {
            zombies[i] thundergun_debug_print( "range", (1, 0, 0) );
            return; // everything else in the list will be out of range
        }

        normal = VectorNormalize( test_origin - view_pos );
        dot = VectorDot( forward_view_angles, normal );
        if ( 0 > dot )
        {
            // guy's behind us
            zombies[i] thundergun_debug_print( "dot", (1, 0, 0) );
            continue;
        }

        radial_origin = PointOnSegmentNearestToPoint( view_pos, end_pos, test_origin );
        if ( DistanceSquared( test_origin, radial_origin ) > cylinder_radius_squared )
        {
            // guy's outside the range of the cylinder of effect
            zombies[i] thundergun_debug_print( "cylinder", (1, 0, 0) );
            continue;
        }

        if ( !zombies[i] DamageConeTrace( view_pos, self ) && !BulletTracePassed( view_pos, test_origin, false, undefined ) && !SightTracePassed( view_pos, test_origin, false, undefined ) )
        {
            // guy can't actually be hit from where we are
            zombies[i] thundergun_debug_print( "cone", (1, 0, 0) );
            continue;
        }

        if ( test_range_squared < fling_range_squared )
        {
            level.thundergun_fling_enemies[level.thundergun_fling_enemies.size] = zombies[i];

            // the closer they are, the harder they get flung
            dist_mult = (fling_range_squared - test_range_squared) / fling_range_squared;
            /*fling_vec = VectorNormalize( test_origin - view_pos );

            // within 6 feet, just push them straight away from the player, ignoring radial motion
            if ( 5000 < test_range_squared )
            {
                fling_vec = fling_vec + VectorNormalize( test_origin - radial_origin );
            }
            fling_vec = (fling_vec[0], fling_vec[1], abs( fling_vec[2] ));*/

            // add more to the up angle so they always get flung up
            angles = self GetPlayerAngles();
            up_angle = 90 - angles[0];
            up_angle = (180 - up_angle) / 3;
            angles = (angles[0] - up_angle, angles[1], angles[2]);

            fling_vec = AnglesToForward(angles);
            fling_vec = vector_scale( fling_vec, 100 + 100 * dist_mult );
            level.thundergun_fling_vecs[level.thundergun_fling_vecs.size] = fling_vec;

            zombies[i] thread setup_thundergun_vox( self, true, false, false );
        }
        else
        {
            level.thundergun_knockdown_enemies[level.thundergun_knockdown_enemies.size] = zombies[i];
            level.thundergun_knockdown_gib[level.thundergun_knockdown_gib.size] = false;

            zombies[i] thread setup_thundergun_vox( self, false, false, true );
        }
    }
}

thundergun_knockdown_zombie( player, gib )
{
    self endon( "death" );
    playsoundatposition ("vox_thundergun_forcehit", self.origin);
    playsoundatposition ("wpn_thundergun_proj_impact", self.origin);


    if( !IsDefined( self ) || !IsAlive( self ) )
    {
        // guy died on us
        return;
    }

    if ( IsDefined( self.thundergun_knockdown_func ) )
    {
        self [[ self.thundergun_knockdown_func ]]( player, gib );
    }
    else
    {

        //self DoDamage( level.zombie_vars["thundergun_knockdown_damage"], player.origin, player );



    }

    if ( gib )
    {
        self.a.gib_ref = random( level.thundergun_gib_refs );
        self thread animscripts\zombie_death::do_gib();
    }

//  self playsound( "thundergun_impact" );
    self.thundergun_handle_pain_notetracks = ::handle_thundergun_pain_notetracks;
    //self DoDamage( level.zombie_vars["thundergun_knockdown_damage"], player.origin, player );
    self playsound( "fly_thundergun_forcehit" );

}