post_init()
{
    level.insta_time = 0;
	level._ZOMBIE_PLAYER_FLAG_HUMANGUN_UPGRADED_HIT_RESPONSE = 11;//10
}

humangun_on_player_connect()
{
	for( ;; )
	{
		level waittill( "connecting", player );
		player thread wait_for_humangun_fired();
        player thread maps\_custom_hud::instakill_timer_hud();
	}
}


wait_for_humangun_fired()
{
	self endon( "disconnect" );
	self waittill( "spawned_player" );

	/*for( ;; )
	{
		self waittill( "weapon_fired" );
		currentweapon = self GetCurrentWeapon();
		if( ( currentweapon == "humangun_zm" ) || ( currentweapon == "humangun_upgraded_zm" ) )
		{
			self thread humangun_fired( currentweapon == "humangun_upgraded_zm" );

			view_pos = self GetTagOrigin( "tag_flash" ) - self GetPlayerViewHeight();
			view_angles = self GetTagAngles( "tag_flash" );
//			playfx( level._effect["humangun_smoke_cloud"], view_pos, AnglesToForward( view_angles ), AnglesToUp( view_angles ) );
		}
	}*/

	for( ;; )
    {
        self waittill("missile_fire", grenade, weapon);

        if(weapon == "humangun_zm" || weapon == "humangun_upgraded_zm")
        {
            self thread humangun_radius_damage(grenade, weapon);
        }
    }
}

humangun_radius_damage(grenade, weapon)
{
    upgraded = weapon == "humangun_upgraded_zm";

    grenade waittill_not_moving();
    grenade_origin = grenade.origin;

    closest = undefined;
    dist = 64 * 64;
    zombs = GetAiSpeciesArray( "axis", "all" );
    players = get_players();
    ents = array_combine(zombs, players);
    ents = get_array_of_closest(grenade_origin, ents);
    valid_ents = [];
    valid_players = [];
    valid_zombs = [];
    for (i = 0; i < ents.size; i++)
    {
        // out of range, all other ents will be also
        if(DistanceSquared(grenade_origin, ents[i].origin) > dist)
        {
            break;
        }

        if(!ents[i] DamageConeTrace(grenade_origin, self))
        {
            continue;
        }

        valid_ents[valid_ents.size] = ents[i];
        if(IsPlayer(ents[i]))
        {
            valid_players[valid_players.size] = ents[i];
        }
        else
        {
            valid_zombs[valid_zombs.size] = ents[i];
        }

        // only need 1 of each max
        if(valid_players.size > 0 && valid_zombs.size > 0)
        {
            break;
        }
    }

    if(valid_ents.size > 0)
    {
        closest = valid_ents[0];
        // HACK - sometimes chooses player when it should choose zombie when both are close
        if(valid_players.size > 0 && valid_zombs.size > 0 && valid_ents[0] != valid_zombs[0])
        {
            if(DistanceSquared(grenade_origin, valid_players[0].origin) < 32 * 32)
            {
                closest = valid_players[0];
            }
            else
            {
                closest = valid_zombs[0];
            }
        }
    }

    if(IsDefined(closest))
    {
        if(IsPlayer(closest))
        {
            closest thread humangun_player_hit_response( self, upgraded );
        }
        else if(IsAI(closest))
        {
            if(IsDefined(closest.animname) && closest.animname == "director_zombie")
            {
                closest thread maps\_zombiemode_ai_director::director_humangun_hit_response( upgraded );
            }
            else
            {
                closest thread humangun_zombie_hit_response_internal( "MOD_IMPACT", weapon, self );
            }
        }
    }
}

humangun_player_ignored_timer( owner, upgraded )
{
	self endon( "humangun_player_ignored_timer_done" );
	self endon( "player_downed" );
	self endon( "spawned_spectator" );
	self endon( "disconnect" );

	self thread humangun_player_ignored_timer_clear( upgraded );
	self thread humangun_player_effects_audio();

	self.ignoreme = false;

	self.point_split_receiver = owner;
	if ( !upgraded )
	{
		self.point_split_keep_percent = 1;
		self.personal_instakill = true;

		self setclientflag( level._ZOMBIE_PLAYER_FLAG_HUMANGUN_HIT_RESPONSE );
	}
	else
	{
		self.point_split_keep_percent = 1;
		self.personal_instakill = true;

		self setclientflag( level._ZOMBIE_PLAYER_FLAG_HUMANGUN_UPGRADED_HIT_RESPONSE );
	}

	enemy_zombies = GetAiSpeciesArray( "axis", "all" );
	for ( i = 0; i < enemy_zombies.size; i++ )
	{
		if ( isdefined( enemy_zombies[i].favoriteenemy ) && self == enemy_zombies[i].favoriteenemy )
		{
			enemy_zombies[i].zombie_path_timer = 0;
		}
	}

	self.humangun_player_ignored_timer = level.total_time + (level.zombie_vars["humangun_player_ignored_time"]);

	while ( level.total_time < self.humangun_player_ignored_timer )
	{
        if( level.total_time + 1 > self.humangun_player_ignored_timer)
        {
            self clearclientflag( level._ZOMBIE_PLAYER_FLAG_HUMANGUN_HIT_RESPONSE );
            self clearclientflag( level._ZOMBIE_PLAYER_FLAG_HUMANGUN_UPGRADED_HIT_RESPONSE );
        }
		wait .05;
	}

	self.ignoreme = false;
	humangun_player_ignored_timer_cleanup( upgraded );
}

humangun_player_hit_response( owner, upgraded )
{
	if ( !isdefined( self.humangun_player_ignored_timer ) )
	{
		self.humangun_player_ignored_timer = 0;
	}

	if ( self.humangun_player_ignored_timer )
	{
		self.humangun_player_ignored_timer += (level.zombie_vars["humangun_player_ignored_time"]);
	}
	else
	{
		self thread humangun_player_ignored_timer( owner, upgraded );
	}
}
