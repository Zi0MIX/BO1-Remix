#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include animscripts\zombie_Utility;

#using_animtree( "generic_human" );
thief_prespawn()
{
	self.animname = "thief_zombie";

	self.custom_idle_setup = maps\_zombiemode_ai_thief::thief_zombie_idle_setup;

	self.a.idleAnimOverrideArray = [];
	self.a.idleAnimOverrideArray["stand"] = [];
	self.a.idleAnimOverrideWeights["stand"] = [];
	self.a.idleAnimOverrideArray["stand"][0][0] 	= %ai_zombie_tech_idle_base;
	self.a.idleAnimOverrideWeights["stand"][0][0] 	= 10;
	self.a.idleAnimOverrideArray["stand"][0][1] 	= %ai_zombie_tech_idle_base;
	self.a.idleAnimOverrideWeights["stand"][0][1] 	= 10;

	rand = randomIntRange( 1, 5 );
	self.deathanim = level.scr_anim["thief_zombie"]["death"+rand];

	self.ignorelocationaldamage = true;
	self.ignoreall = true;
	self.allowdeath = true; 			// allows death during animscripted calls
	self.is_zombie = true; 			// needed for melee.gsc in the animscripts
	self.has_legs = true; 			// Sumeet - This tells the zombie that he is allowed to stand anymore or not, gibbing can take
															// out both legs and then the only allowed stance should be prone.
	self allowedStances( "stand" );

	self.gibbed = false;
	self.head_gibbed = false;

	// might need this so co-op zombie players cant block zombie pathing
	self PushPlayer( true );

	self.disableArrivals = true;
	self.disableExits = true;
	self.grenadeawareness = 0;
	self.badplaceawareness = 0;

	self.ignoreSuppression = true;
	self.suppressionThreshold = 1;
	self.noDodgeMove = true;
	self.dontShootWhileMoving = true;
	self.pathenemylookahead = 0;

	self.badplaceawareness = 0;
	self.chatInitialized = false;

	self.a.disablePain = true;
	self disable_react(); // SUMEET - zombies dont use react feature.

	if ( isdefined( level.user_ryan_thief ) )
	{
		self thread maps\_zombiemode_ai_thief::thief_health_watch();
	}

	self.freezegun_damage = 0;

	self.dropweapon = false;
	self thread maps\_zombiemode_spawner::zombie_damage_failsafe();

	self thread maps\_zombiemode_spawner::delayed_zombie_eye_glow();	// delayed eye glow for ground crawlers (the eyes floated above the ground before the anim started)
	self.meleeDamage = 1;

	self.entered_level = false;
	self.taken = false;
	self.no_powerups = true;
	self.blink = false;

	self setTeamForEntity( "axis" );

	self.actor_damage_func = ::thief_actor_damage;
	self.freezegun_damage_response_func = ::thief_freezegun_damage_response;
	self.deathanimscript = ::thief_post_death;
	self.zombie_damage_claymore_func = ::thief_damage_claymore;

	self.pregame_damage = 0;
	self.endgame_damage = 0;
	self.speed_damage = 0;

	self.light = [];
	for ( i = 0; i < 5; i++ )
	{
		self.light[i] = 0;
	}

	self thread maps\_zombiemode_spawner::play_ambient_zombie_vocals();

	self notify( "zombie_init_done" );
}

thief_round_tracker()
{
	flag_wait( "power_on" );

	level.thief_save_spawn_func = level.round_spawn_func;
	level.thief_save_wait_func = level.round_wait_func;

	if(level.round_number % 2 == 1)
	{
		level.next_thief_round = level.round_number + 2;
	}
	else
	{
		level.next_thief_round = level.round_number + 1;
	}

	level.prev_thief_round = level.next_thief_round;

	while ( 1 )
	{
		level waittill( "between_round_over" );

		if ( level.round_number >= level.next_thief_round )
		{
			level.music_round_override = true;
			level.thief_save_spawn_func = level.round_spawn_func;
			level.thief_save_wait_func = level.round_wait_func;

			thief_round_start();

			level.round_spawn_func = ::thief_round_spawning;
			level.round_wait_func = ::thief_round_wait;

			level.prev_thief_round = level.next_thief_round;
			level.next_thief_round = level.round_number + 4;
		}
		else if ( level.prev_thief_round == level.round_number )
		{
			level.music_round_override = true;
			thief_round_start();
		}
		else if ( flag( "thief_round" ) )
		{
			thief_round_stop();
			level.music_round_override = false;
		}
	}
}

thief_trap_watcher()
{
	traps = getentarray( "zombie_trap", "targetname" );
	sh_found = false;
	nh_found = false;
	for ( i = 0; i < traps.size; i++ )
	{
		if ( traps[i].target == "trap_elevator" && !sh_found )
		{
			sh_found = true;
			self thread thief_trap_watch( traps[i] );
		}
		if ( traps[i].target == "trap_quickrevive" && !nh_found )
		{
			nh_found = true;
			self thread thief_trap_watch( traps[i] );
		}
	}
}

thief_round_start()
{
	flag_set( "thief_round" );

	//AUDIO: Got rid of typical announcer vox
	//level thread maps\zombie_pentagon_amb::play_pentagon_announcer_vox( "zmb_vox_pentann_thiefstart" );
	//level thread play_looping_alarms( 7 );
	level thread maps\_zombiemode_audio::change_zombie_music( "dog_start" );

	if ( isDefined( level.thief_round_start ) )
	{
		level thread [[ level.thief_round_start ]]();
	}

	level thread thief_round_vision();

	self thread thief_trap_watcher();

	// turn lights off
	clientnotify( "TLF" );
}

thief_trap_watch( trig )
{
	self endon( "death" );
	self endon( "thief_trap_stop" );

	clip = getent( trig.target + "_clip", "targetname" );
	clip.dis = false;

	self thread thief_trap_stop_watch(trig);

	while ( 1 )
	{
		if ( trig._trap_in_use == 1 && trig._trap_cooling_down == 0 && !clip.dis )
		{
			thief_print( "blocking " + trig.target );
			// block path
			clip.origin = clip.realorigin;
			clip disconnectpaths();
			clip.dis = true;
		}
		else if ( (trig._trap_in_use == 0 || trig._trap_cooling_down == 1) && clip.dis )
		{
			thief_print( "unblocking " + trig.target );
			clip.origin += ( 0, 0, 10000 );
			clip connectpaths();
			clip.dis = false;
		}
		wait_network_frame();
	}
}

thief_trap_stop_watch(trig)
{
	self endon( "death" );

	clip = getent( trig.target + "_clip", "targetname" );

	self waittill( "thief_trap_stop" );

	if(clip.dis)
	{
		thief_print( "unblocking " + trig.target );

		clip.origin += ( 0, 0, 10000 );
		clip connectpaths();
		clip.dis = false;
	}
}

thief_zombie_think()
{
	self endon( "death" );

	self thief_set_state( "stalking" );

	// ww: set the flag for pregame death
	flag_set( "death_in_pre_game" );

	self thread thief_zombie_choose_run();

	self.goalradius = 32;
	self.ignoreall = false;
	self.pathEnemyFightDist = 64;
	self.meleeAttackDist = 64;

	start_health = level.round_number * level.thief_health_multiplier;
	if ( start_health > level.max_thief_health )
	{
		start_health = level.max_thief_health;
	}
	start_health = thief_scale_health( start_health );
	//pregame_health = thief_scale_health( GetDvarInt( #"scr_thief_health_pregame" ) );
	self.maxhealth = start_health;
	self.health = start_health;

	self thief_print( "start_health = " + start_health );

	if ( isdefined( level.user_ryan_thief_health ) )
	{
		self.maxhealth = 1;
		self.health = 1;
	}

	//try to prevent always turning towards the enemy
	self.maxsightdistsqrd = 96 * 96;

	self.zombie_move_speed = "walk";


	//self thread [[ level.thief_zombie_enter_level ]]();

	self thief_zombie_setup_victims();

	self.fx_org = spawn( "script_model", self.origin );
	self.fx_org SetModel( "tag_origin" );
	self.fx_org.angles = self.angles;
	self.fx_org linkto( self );
	PlayFxOnTag( level._effect["tech_trail"], self.fx_org, "tag_origin" );

	while ( 1 )
	{
		self thief_zombie_set_visibility();
		self thief_portal_to_victim();

		self thread thief_check_vision();
		self thread thief_try_steal();
		self thread thief_chasing();

		self waittill( "next_victim" );
	}
}

thief_zombie_die()
{
	self maps\_zombiemode_spawner::reset_attack_spot();
	self unlink();

	self.grenadeAmmo = 0;

	if ( isdefined( self.worldgun ) )
	{
		self.worldgun unlink();
		wait_network_frame();
		self.worldgun delete();
	}

	players = getplayers();
	for ( i = 0; i < players.size; i++ )
	{
		players[i] FreezeControls( false );
		players[i] EnableOffhandWeapons();
		players[i] EnableWeaponCycling();

		players[i] AllowLean( true );
		players[i] AllowAds( true );
		players[i] AllowSprint( true );
		players[i] AllowProne( true );
		players[i] AllowMelee( true );

		players[i] Unlink();
	}

	// ww: check to see if he died during the pregame
	if( flag( "death_in_pre_game" ) )
	{
		players = getplayers();
		for ( i = 0; i < players.size; i++ )
		{
			if ( isDefined( players[i].thief_damage ) && players[i].thief_damage )
			{
				players[i] giveachievement_wrapper( "SP_ZOM_TRAPS" );
			}
		}

		// drop bonfire sale
		level thread maps\_zombiemode_powerups::specific_powerup_drop( "tesla", self.origin );
	}
	else
	{
		level thread maps\_zombiemode_powerups::specific_powerup_drop( "bonfire_sale", self.origin );
	}

	forward = VectorNormalize( AnglesToForward( self.angles ) );
	endPos = self.origin - vector_scale( forward, 32 );

	level thread maps\_zombiemode_powerups::specific_powerup_drop( "full_ammo", endPos );

    self thread maps\_zombiemode_audio::do_zombies_playvocals( "death", self.animname );

	// Give attacker points

	//ChrisP - 12/8/08 - added additional 'self' argument
	level maps\_zombiemode_spawner::zombie_death_points( self.origin, self.damagemod, self.damagelocation, self.attacker,self );

	if( self.damagemod == "MOD_BURNED" )
	{
		self thread animscripts\zombie_death::flame_death_fx();
	}

	self thief_return_loot();
	self thief_shutdown_lights();
	self thief_clear_portals();

	flag_set( "last_thief_down" );
	//level thread maps\zombie_pentagon_amb::play_pentagon_announcer_vox( "zmb_vox_pentann_thiefend_good" );

	return false;
}

thief_take_loot()
{
	player = self.victims.current;

	//self.victim_score = self.victims.current.score;
	//self.victims.current maps\_zombiemode_score::minus_to_player_score( self.victim_score );

	//ammo = self.victims.current GetWeaponAmmoStock( weapon );
	//self.victim_ammo = ammo;

	// take ammo
	//self.victim SetWeaponAmmoStock( weapon, 0 );

	weapon = player GetCurrentWeapon();

	is_laststand = player maps\_laststand::player_is_in_laststand();

	// don't take these items...choose random primary instead
	if ( weapon == "claymore_zm" || weapon == "knife_zm" || weapon == "bowie_knife_zm" || weapon == "frag_grenade_zm" ||
		 weapon == "zombie_bowie_flourish" || weapon == "none" || isSubStr( weapon, "zombie_perk_bottle" ) || is_laststand )
	{
		primaries = player GetWeaponsListPrimaries();
		if( isDefined( primaries ) )
		{
			// don't take last stand pistol
			if ( is_laststand && primaries.size > 1 )
			{
				for ( i = 0; i < primaries.size; i++ )
				{
					if ( primaries[i] == weapon )
					{
						primaries = array_remove( primaries, primaries[i] );
						break;
					}
				}
			}

			if ( primaries.size > 0 )
			{
				pick = RandomInt(100) % primaries.size;
				weapon = primaries[ pick ];
			}
			else
			{
				weapon = undefined;
			}
		}
	}

	if ( isDefined( weapon ) && weapon != "none")
	{
		// spawn weapon in hand
		model = GetWeaponModel( weapon );
		pos = self GetTagOrigin( "TAG_WEAPON_RIGHT" );
		self.worldgun = spawn( "script_model", pos );
		self.worldgun.angles = self GetTagAngles( "TAG_WEAPON_RIGHT" );
		self.worldgun setModel( model );
		self.worldgun linkto( self, "TAG_WEAPON_RIGHT" );

		// take weapon
		player.weapons_list = player GetWeaponsList();
		if( is_weapon_attachment( weapon ) )
		{
			weapon = player get_baseweapon_for_attachment( weapon );
		}

		player TakeWeapon( weapon );
		thief_print( "taking " + weapon );

		if ( isDefined( player.lastActiveWeapon ) && player.lastActiveWeapon == weapon )
		{
			player.lastActiveWeapon = "none";
		}

		// don't give minigun powerup back
		if ( weapon == "minigun_zm" )
		{
			maps\_zombiemode_powerups::minigun_weapon_powerup_off();
			weapon = undefined;
		}
	}

	self.victims.weapon[ self.victims.current_idx ] = weapon;

	player thread maps\_zombiemode_ai_thief::player_do_knuckle_crack();
}

thief_return_loot()
{
	players = getplayers();
	for ( i = 0; i < players.size; i++ )
	{
		for ( j = 0; j < self.victims.player.size; j++ )
		{
			if ( players[i] == self.victims.player[j] )
			{
				if ( isDefined( self.victims.weapon[j] ) )
				{
					// more than 2...take one and return the thief's
					primaries = players[i] GetWeaponsListPrimaries();
					if ( isDefined( primaries ) && primaries.size >= 3 )
					{
						weapon = players[i] GetCurrentWeapon();

						// don't take these items...choose random primary instead
						if ( weapon == "claymore_zm" || weapon == "knife_zm" || weapon == "bowie_knife_zm" || weapon == "frag_grenade_zm" ||
							 weapon == "zombie_bowie_flourish" || isSubStr( weapon, "zombie_perk_bottle" ) )
						{
							weapon = primaries[1];
						}

						players[i] TakeWeapon( weapon );
						primaries = players[i] GetWeaponsListPrimaries();
					}

					if ( isDefined( primaries ) && primaries.size < 3 )
					{
						players[i] GiveWeapon( self.victims.weapon[j], 0, players[i] maps\_zombiemode_weapons::get_pack_a_punch_weapon_options( self.victims.weapon[j] ) );
						players[i] SwitchToWeapon( self.victims.weapon[j] );
					}
				}
			}
		}
	}
}

thief_actor_damage( weapon, damage, attacker )
{
	//self thread thief_blink( attacker );

	if ( isdefined( attacker ) )
	{
		thief_info( attacker.playername + " " + weapon + " " + damage );
		attacker.thief_damage = true;
	}

	if ( self.state == "exiting" )
	{
		self.endgame_damage += damage;
	}
	else
	{
		self.pregame_damage += damage;
	}

	if ( weapon != "freezegun_zm" && weapon != "freezegun_upgraded_zm" )
	{
		self.speed_damage += damage;
	}

	if ( self.state == "stalking" )
	{
		self thief_set_state( "chasing" );
	}
	else if ( self.state == "chasing" )
	{
		if ( isDefined( self.chase_damage ) )
		{
			self.chase_damage -= damage;
			if ( self.chase_damage <= 0 )
			{
				thief_print( "chase_damage exceeded...sprint" );
				self thief_set_state( "sprinting" );
			}
		}
	}

	return damage;
}

thief_nuke_damage()
{
	self endon( "death" );

	self.bonfire = true;

	self thread animscripts\zombie_death::flame_death_fx();
	self playsound ("evt_nuked");
	self dodamage( self.health + 666, self.origin );
}
