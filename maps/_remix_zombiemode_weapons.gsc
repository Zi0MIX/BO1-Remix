#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\_zombiemode_audio;

add_remix_weapons()
{
	// Custom weapons
	add_zombie_weapon( "stoner63_zm",				"stoner63_upgraded_zm",					&"ZOMBIE_WEAPON_COMMANDO",				100,	"mg",			"",		undefined );
	add_zombie_weapon( "ppsh_zm",					"ppsh_upgraded_zm",						&"ZOMBIE_WEAPON_COMMANDO",				100,	"smg",			"",		undefined );
	add_zombie_weapon( "ak47_zm",					"ak47_ft_upgraded_zm",					&"ZOMBIE_WEAPON_COMMANDO",				100,	"assault",			"",		undefined );
    add_zombie_weapon( "blundergat_zm",				"blundergat_upgraded_zm",				&"ZOMBIE_WEAPON_BLUNDERGAT",			1500,	"shotgun",			"",		undefined );
}

// sharedbox
knife_for_shared_box( user )
{
	self endon( "user_grabbed_weapon" );

	while(1)
	{
		if(user meleeButtonPressed() && isplayer( user ) && distance(self.origin, user.origin) <= 100)
		{
			self SetVisibleToAll();
			self thread respin_respin_box();

			wait 10;
			break;
		}
		wait 0.05;
	}
	
	self notify( "trigger", level );
}

respin_respin_box()
{
	org = self.chest_origin.origin;
	
	if(IsDefined(self.chest_origin.weapon_model))
	{
		self.chest_origin.weapon_model notify("kill_weapon_movement");
		self.chest_origin.weapon_model moveto(org + (0,0,40), 0.5);
	}
	
	if(IsDefined(self.chest_origin.weapon_model_dw))
	{
		self.chest_origin.weapon_model_dw notify("kill_weapon_movement");
		self.chest_origin.weapon_model_dw moveto(org + (0,0,40) - (3,3,3), 0.5);
	}
	
	self.chest_origin notify("box_hacked_rerespin");
	
	self.box_rerespun = true;
	
	self thread fake_weapon_powerup_thread(self.chest_origin.weapon_model, self.chest_origin.weapon_model_dw);
	
}

fake_weapon_powerup_thread(weapon1, weapon2)
{
	weapon1 endon ("death");

	playfxontag (level._effect["powerup_on_solo"], weapon1, "tag_origin");
	
	playsoundatposition("zmb_spawn_powerup", weapon1.origin);
	weapon1 PlayLoopSound("zmb_spawn_powerup_loop");
	
	self thread fake_weapon_powerup_timeout(weapon1, weapon2);
	
	while (isdefined(weapon1))
	{
		waittime = randomfloatrange(2.5, 5);
		yaw = RandomInt( 360 );
		if( yaw > 300 )
		{
			yaw = 300;
		}
		else if( yaw < 60 )
		{
			yaw = 60;
		}
		yaw = weapon1.angles[1] + yaw;
		weapon1 rotateto ((-60 + randomint(120), yaw, -45 + randomint(90)), waittime, waittime * 0.5, waittime * 0.5);
		
		if(IsDefined(weapon2))
		{
			weapon2 rotateto ((-60 + randomint(120), yaw, -45 + randomint(90)), waittime, waittime * 0.5, waittime * 0.5);
		}
		wait randomfloat (waittime - 0.1);
	}
}

fake_weapon_powerup_timeout(weapon1, weapon2)
{
	weapon1 endon ("death");

	wait 10;
	
	//self.chest.chest_origin notify("weapon_grabbed");
	self notify( "trigger", level ); 
	
	if(IsDefined(weapon1))
	{
		weapon1 Delete();
	}
	
	if(IsDefined(weapon2))
	{
		weapon2 Delete();
	}
}

debug_print_boxes()
{
	for (i=0; i<level.chests.size; i++)
	{
		iPrintLn(level.chests[i].script_noteworthy);
		// iPrintLn(level.chests[i].targetname);
		wait 1;
	}
}

wonder_weapon_weighting_func()
{	
	return get_percentage_increase( level.pulls_since_last_wonder_weapon, level.player_drops_wonder_weapon );
}

// increase the chance of getting a wonder weapon after every 5 hits
default_wonder_weapon_weighting_func()
{
	num_to_add = 1;
	amount_to_add = (level.pulls_since_last_wonder_weapon / 5) / 10; //+10% every 5 pulls 
	num_to_add += amount_to_add;

	return num_to_add;
}

default_ray_gun_weighting_func()
{
	num_to_add = 1;
	if( level.round_number < 25 )
	{
		if( isDefined( level.pulls_since_last_ray_gun ) )
		{
			if( level.pulls_since_last_ray_gun > 10 )
			{
				num_to_add += 0.5;
			}
			else if( level.pulls_since_last_ray_gun > 5 )
			{
				num_to_add += 0.25;
			}
		}
	}
	return num_to_add;
}

default_sniper_explosive_weighting_func()
{
	num_to_add = 1;
	amount_to_add = (level.pulls_since_last_sniper_explosive / 5) / 10; //+10% every 5 pulls 
	num_to_add += amount_to_add;
	
	return num_to_add;
}


//	Greatly elevate the chance to get it until someone has it, then make it even
default_cymbal_monkey_weighting_func()
{
		if( level.round_number > 20 )
		{
			return 5;
		}
		else if( level.round_number > 15 )
		{
			return 4;
		}
		else if( level.round_number > 10 )
		{
			return 3;
		}
		else if( level.round_number > 5)
		{
			return 2;
		}
		else
		{
			return 1;
		}
}

default_zombie_black_hole_bomb_weighting_func()
{
	if( level.round_number > 50 )
	{
		return 2;
	}
	else if( level.round_number > 20 )
	{
		return 5;
	}
	else if( level.round_number > 15 )
	{
		return 4;
	}
	else if( level.round_number > 10 )
	{
		return 3;
	}
	else if( level.round_number > 5)
	{
		return 2;
	}
	else
	{
		return 1;
	}
}

get_percentage_increase( pulls_since_weapon, player_dropped )
{	
	num_to_add = 1;

	if(!player_dropped)
	{
		num_to_add += 0.5; //150% for settup
	}
	else
	{
		amount_to_add = int(pulls_since_weapon / 5) / 10; //+10% every 5 pulls 
		num_to_add += amount_to_add;
	}

	return num_to_add;
}

//	For weapons which should only appear once the box moves
default_1st_move_weighting_func()
{
	if( level.chest_moves > 0 )
	{
		num_to_add = 1;

		return num_to_add;
	}
	else
	{
		return 0;
	}
}


//
//	Default weighting for a high-level weapon that is too good for the normal box
default_upgrade_weapon_weighting_func()
{
	if ( level.chest_moves > 1 )
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

// for the random weapon chest
//
//	The chests need to be setup as follows:
//		trigger_use - for the chest
//			targets the lid
//		lid - script_model.  Flips open to reveal the items
//			targets the script origin inside the box
//		script_origin - inside the box, used for spawning the weapons
//			targets the box
//		box - script_model of the outer casing of the chest
//		rubble - pieces that show when the box isn't there
//			script_noteworthy should be the same as the use_trigger + "_rubble"
//
treasure_chest_init()
{
	if( level.mutators["mutator_noMagicBox"] )
	{
		chests = GetEntArray( "treasure_chest_use", "targetname" );
		for( i=0; i < chests.size; i++ )
		{
			chests[i] get_chest_pieces();
			chests[i] hide_chest();
		}
		return;
	}
	flag_init("moving_chest_enabled");
	flag_init("moving_chest_now");
	flag_init("chest_has_been_used");

	level.chest_moves = 0;
	level.chest_level = 0;	// Level 0 = normal chest, 1 = upgraded chest
	level.chests = GetEntArray( "treasure_chest_use", "targetname" );
	for (i=0; i<level.chests.size; i++ )
	{
		level.chests[i].box_hacks = [];

		level.chests[i].orig_origin = level.chests[i].origin;
		level.chests[i] get_chest_pieces();

		if ( isDefined( level.chests[i].zombie_cost ) )
		{
			level.chests[i].old_cost = level.chests[i].zombie_cost;
		}
		else
		{
			// default chest cost
			level.chests[i].old_cost = 950;
		}
	}

	level.chest_accessed = 0;

	level.box_set = randomInt(3);	// Level var for hud
	if (level.chests.size > 1)
	{
		// Always remove boxes here, using for loop above will cause inability to remove box model placeholders, and doing it in init_starting_chest_location() will cause conflicts, it'll try to reffer to keys that's already been removed (kino)
		for (i=0; i<level.chests.size; i++ )
		{
			if(level.script == "zombie_theater")
			{
				// Set for dining
				if (level.box_set == 0)
				{
					if(level.chests[i].script_noteworthy == "alleyway_chest")
					{
						level.chests[i] hide_rubble();
						level.chests[i] hide_chest();
						level.chests = array_remove_nokeys(level.chests, level.chests[i]);
					}
					else if(level.chests[i].script_noteworthy == "control_chest")
					{
						level.chests[i] hide_chest();
						level.chests[i] hide_rubble();
						level.chests = array_remove_nokeys(level.chests, level.chests[i]);
					}
					else if(level.chests[i].script_noteworthy == "start_chest")
					{
						level.chests[i] hide_chest();
						level.chests[i] hide_rubble();
						level.chests = array_remove_nokeys(level.chests, level.chests[i]);
					}
				}
				// Set for hellroom
				else if (level.box_set == 1)
				{
					if(level.chests[i].script_noteworthy == "dressing_chest")
					{
						level.chests[i] hide_rubble();
						level.chests[i] hide_chest();
						level.chests = array_remove_nokeys(level.chests, level.chests[i]);
					}
					else if(level.chests[i].script_noteworthy == "dining_chest")
					{
						level.chests[i] hide_chest();
						level.chests[i] hide_rubble();
						level.chests = array_remove_nokeys(level.chests, level.chests[i]);
					}
					else if(level.chests[i].script_noteworthy == "stage_chest")
					{
						level.chests[i] hide_chest();
						level.chests[i] hide_rubble();
						level.chests = array_remove_nokeys(level.chests, level.chests[i]);
					}
				}
				// Set for no power
				else if (level.box_set == 2)
				{
					if (level.chests[i].script_noteworthy == "theater_chest")
					{
						level.chests[i] hide_rubble();
						level.chests[i] hide_chest();
						level.chests = array_remove_nokeys(level.chests, level.chests[i]);
					}
				}
			}

			else if(level.script == "zombie_cod5_sumpf")
			{
				if(level.chests[i].script_noteworthy == "nw_chest")
				{
					level.chests[i] hide_rubble();
					level.chests[i] hide_chest();
					level.chests = array_remove_nokeys(level.chests, level.chests[i]);
				}
			}

			else if(level.script == "zombie_cod5_factory")
			{
				if(level.chests[i].script_noteworthy == "chest3")
				{
					level.chests[i] hide_rubble();
					level.chests[i] hide_chest();
					level.chests = array_remove_nokeys(level.chests, level.chests[i]);
				}
			}
		}
		
		flag_set("moving_chest_enabled");

		level.chests = array_randomize(level.chests);

		//determine magic box starting location at random or normal
		init_starting_chest_location();
	}
	else
	{
		level.chest_index = 0;
	}

	array_thread( level.chests, ::treasure_chest_think );

}

init_starting_chest_location()
{
    level.chest_index = 0;
    start_chest_found = false;
    for( i = 0; i < level.chests.size; i++ )
    {
        if(level.script == "zombie_pentagon")
        {
			if(level.chests[i].script_noteworthy == "start_chest")
			//if(IsSubStr(level.chests[i].script_noteworthy,  "start_chest" ))
			{
				level.chest_index = i;
				level.chests[level.chest_index] hide_rubble();
				level.chests[level.chest_index].hidden = false;
			}
			else
			{
				level.chests[i] hide_chest();
			}
        }
		else if(level.script == "zombie_theater")
        {
			if (level.box_set == 0)
			{
				if(IsSubStr(level.chests[i].script_noteworthy,  "dining_chest" ))
				{
					level.chest_index = i;
					level.chests[level.chest_index] hide_rubble();
					level.chests[level.chest_index].hidden = false;
				}
				else
				{
					level.chests[i] hide_chest();
				}
			}
			// Same starting box for hellroom and no power
			else
			{
				if(IsSubStr(level.chests[i].script_noteworthy,  "crematorium_chest" ))
				{
					level.chest_index = i;
					level.chests[level.chest_index] hide_rubble();
					level.chests[level.chest_index].hidden = false;
				}
				else
				{
					level.chests[i] hide_chest();
				}
			}
        }
        else if(level.script == "zombie_coast")
        {
            if(IsSubStr(level.chests[i].script_noteworthy, "residence_chest" ))
                {
                    level.chest_index = i;
                    level.chests[level.chest_index] hide_rubble();
                    level.chests[level.chest_index].hidden = false;
                }
                else
                {
                    level.chests[i] hide_chest();
                }
        }
        else if(level.script == "zombie_temple")
        {
            if(IsSubStr(level.chests[i].script_noteworthy, "caves1_chest" ))
                {
                    level.chest_index = i;
                    level.chests[level.chest_index] hide_rubble();
                    level.chests[level.chest_index].hidden = false;
                }
                else
                {
                    level.chests[i] hide_chest();
                }
        }
        else if(level.script == "zombie_moon")
        {
            if(IsSubStr(level.chests[i].script_noteworthy, "bridge_chest" ))
                {
                    level.chest_index = i;
                    level.chests[level.chest_index] hide_rubble();
                    level.chests[level.chest_index].hidden = false;
                }
                else
                {
                    level.chests[i] hide_chest();
                }
        }
        else if(level.script == "zombie_ww")
        {
            if(level.chests[i].script_noteworthy == "start_chest")
            {
                level.chest_index = i;
                level.chests[level.chest_index] hide_rubble();
                level.chests[level.chest_index].hidden = false;
            }
            else
            {
                level.chests[i] hide_chest();
            }
        }

        else if( isdefined( level.random_pandora_box_start ) && level.random_pandora_box_start == true )
        {
            if ( start_chest_found || (IsDefined( level.chests[i].start_exclude ) && level.chests[i].start_exclude == 1) )
            {
                level.chests[i] hide_chest();
            }
            else
            {
                level.chest_index = i;
                level.chests[level.chest_index] hide_rubble();
                level.chests[level.chest_index].hidden = false;
                start_chest_found = true;
            }

        }
        else
        {
            // Semi-random implementation (not completely random).  The list is randomized
            //  prior to getting here.
            // Pick from any box marked as the "start_chest"
            if ( start_chest_found || !IsDefined(level.chests[i].script_noteworthy ) || ( !IsSubStr( level.chests[i].script_noteworthy, "start_chest" ) ) )
            {
                level.chests[i] hide_chest();
            }
            else
            {
                level.chest_index = i;
                level.chests[level.chest_index] hide_rubble();
                level.chests[level.chest_index].hidden = false;
                start_chest_found = true;
            }
        }
    }

    //make first chest the first index
    if(level.chest_index != 0)
    {
        level.chests = array_swap(level.chests,0,level.chest_index);
        level.chest_index = 0;
    }

    // Show the beacon
    if( !isDefined( level.pandora_show_func ) )
    {
        level.pandora_show_func = ::default_pandora_show_func;
    }

	// if (isdefined(level.chests[level.chest_index]))
	// {
	level.chests[level.chest_index] thread [[ level.pandora_show_func ]]();
	// }
}

treasure_chest_think()
{
	self endon("kill_chest_think");
	if( IsDefined(level.zombie_vars["zombie_powerup_fire_sale_on"]) && level.zombie_vars["zombie_powerup_fire_sale_on"] && self [[level._zombiemode_check_firesale_loc_valid_func]]())
	{
		self set_hint_string( self, "powerup_fire_sale_cost" );
	}
	else
	{
		self set_hint_string( self, "default_treasure_chest_" + self.zombie_cost );
	}
	self setCursorHint( "HINT_NOICON" );

	// waittill someuses uses this
	user = undefined;
	user_cost = undefined;
	self.box_rerespun = undefined;
	self.weapon_out = undefined;

	while( 1 )
	{
		if(!IsDefined(self.forced_user))
		{
			self waittill( "trigger", user );
		}
		else
		{
			user = self.forced_user;
		}

		if( user in_revive_trigger() )
		{
			wait( 0.1 );
			continue;
		}

		if( user is_drinking() )
		{
			wait( 0.1 );
			continue;
		}

		if ( is_true( self.disabled ) )
		{
			wait( 0.1 );
			continue;
		}

		if( user GetCurrentWeapon() == "none" )
		{
			wait( 0.1 );
			continue;
		}

		// make sure the user is a player, and that they can afford it
		if( IsDefined(self.auto_open) && is_player_valid( user ) )
		{
			if(!IsDefined(self.no_charge))
			{
				user maps\_zombiemode_score::minus_to_player_score( self.zombie_cost );
				user_cost = self.zombie_cost;
			}
			else
			{
				user_cost = 0;
			}

			self.chest_user = user;
			break;
		}
		else if( is_player_valid( user ) && user.score >= self.zombie_cost )
		{
			user maps\_zombiemode_score::minus_to_player_score( self.zombie_cost );
			user_cost = self.zombie_cost;
			self.chest_user = user;
			break;
		}
		else if ( user.score < self.zombie_cost )
		{
			user maps\_zombiemode_audio::create_and_play_dialog( "general", "no_money", undefined, 2 );
			continue;
		}

		wait 0.05;
	}

	flag_set("chest_has_been_used");

	self._box_open = true;
	self._box_opened_by_fire_sale = false;
	if ( is_true( level.zombie_vars["zombie_powerup_fire_sale_on"] ) && !IsDefined(self.auto_open) && self [[level._zombiemode_check_firesale_loc_valid_func]]())
	{
		self._box_opened_by_fire_sale = true;
	}

	//open the lid
	self.chest_lid thread treasure_chest_lid_open();

	// SRS 9/3/2008: added to help other functions know if we timed out on grabbing the item
	self.timedOut = false;

	// mario kart style weapon spawning
	self.weapon_out = true;
	self.chest_origin thread treasure_chest_weapon_spawn( self, user );

	// the glowfx
	self.chest_origin thread treasure_chest_glowfx();

	// take away usability until model is done randomizing
	self disable_trigger();

	self.chest_origin waittill( "randomization_done" );

	// refund money from teddy.
	if (flag("moving_chest_now") && !self._box_opened_by_fire_sale && IsDefined(user_cost))
	{
		user maps\_zombiemode_score::add_to_player_score( user_cost, false );
	}

	if (flag("moving_chest_now") && !level.zombie_vars["zombie_powerup_fire_sale_on"])
	{
		//CA AUDIO: 01/12/10 - Changed dialog to use correct function
		//self.chest_user maps\_zombiemode_audio::create_and_play_dialog( "general", "box_move" );
		self thread treasure_chest_move( self.chest_user );
	}
	else
	{
		// Let the player grab the weapon and re-enable the box //
		self.grab_weapon_hint = true;
		self.chest_user = user;
		self sethintstring( &"ZOMBIE_TRADE_WEAPONS" );
		self setCursorHint( "HINT_NOICON" );

		self	thread decide_hide_show_hint( "weapon_grabbed");
		//self setvisibletoplayer( user );

		// Limit its visibility to the player who bought the box
		self enable_trigger();
		self thread treasure_chest_timeout();
		self thread knife_for_shared_box( user );

		// make sure the guy that spent the money gets the item
		// SRS 9/3/2008: ...or item goes back into the box if we time out
		while( 1 )
		{
			self waittill( "trigger", grabber );
			self.weapon_out = undefined;
			if( IsDefined( grabber.is_drinking ) && grabber is_drinking() )
			{
				wait( 0.1 );
				continue;
			}

			if ( grabber == user && user GetCurrentWeapon() == "none" )
			{
				wait( 0.1 );
				continue;
			}

			if(grabber != level && (IsDefined(self.box_rerespun) && self.box_rerespun))
			{
				user = grabber;
			}

			if( grabber == user || grabber == level )
			{
				self.box_rerespun = undefined;
				current_weapon = "none";

				if(is_player_valid(user))
				{
					current_weapon = user GetCurrentWeapon();
				}

				if( grabber == user && is_player_valid( user ) && !user is_drinking() && !is_placeable_mine( current_weapon ) && !is_equipment( current_weapon ) && "syrette_sp" != current_weapon )
				{
					bbPrint( "zombie_uses: playername %s playerscore %d teamscore %d round %d cost %d name %s x %f y %f z %f type magic_accept",
						user.playername, user.score, level.team_pool[ user.team_num ].score, level.round_number, self.zombie_cost, self.chest_origin.weapon_string, self.origin );
					self notify( "user_grabbed_weapon" );
					user thread treasure_chest_give_weapon( self.chest_origin.weapon_string );

					//fix grenade ammo
					if(is_lethal_grenade(self.chest_origin.weapon_string) && user GetWeaponAmmoClip(self.chest_origin.weapon_string) > 4)
					{
						user SetWeaponAmmoClip(self.chest_origin.weapon_string, 4);
					}

					if(is_tactical_grenade(self.chest_origin.weapon_string) && user GetWeaponAmmoClip(self.chest_origin.weapon_string) > 3)
					{
						user SetWeaponAmmoClip(self.chest_origin.weapon_string, 3);
					}

					break;
				}
				else if( grabber == level )
				{
					// it timed out
					unacquire_weapon_toggle( self.chest_origin.weapon_string );
					self.timedOut = true;
					if(is_player_valid(user))
					{
						bbPrint( "zombie_uses: playername %s playerscore %d teamscore %d round %d cost %d name %s x %f y %f z %f type magic_reject",
							user.playername, user.score, level.team_pool[ user.team_num ].score, level.round_number, self.zombie_cost, self.chest_origin.weapon_string, self.origin );
					}
					break;
				}
			}

			wait 0.05;
		}

		self.grab_weapon_hint = false;
		self.chest_origin notify( "weapon_grabbed" );

		if ( !is_true( self._box_opened_by_fire_sale ) )
		{
			//increase counter of amount of time weapon grabbed, but not during a fire sale
			level.chest_accessed += 1;
		}

		// PI_CHANGE_BEGIN
		// JMA - we only update counters when it's available
		if( isDefined(level.pulls_since_last_ray_gun) )
		{
			level.pulls_since_last_ray_gun += 1;
		}

		if( isDefined(level.pulls_since_last_wonder_weapon) )
		{
			level.pulls_since_last_wonder_weapon += 1;
			// iPrintLn(level.pulls_since_last_wonder_weapon);
		}

		self disable_trigger();

		// spend cash here...
		// give weapon here...
		self.chest_lid thread treasure_chest_lid_close( self.timedOut );

		//Chris_P
		//magic box dissapears and moves to a new spot after a predetermined number of uses

		wait 1; //3
		if ( (is_true( level.zombie_vars["zombie_powerup_fire_sale_on"] ) && self [[level._zombiemode_check_firesale_loc_valid_func]]()) || self == level.chests[level.chest_index] )
		{
			self enable_trigger();
			self setvisibletoall();
		}
	}

	self._box_open = false;
	self._box_opened_by_fire_sale = false;
	self.chest_user = undefined;

	self notify( "chest_accessed" );

	self thread treasure_chest_think();
}

decide_hide_show_hint( endon_notify )
{
	if( isDefined( endon_notify ) )
	{
		self endon( endon_notify );
	}

	if(!IsDefined(level._weapon_show_hint_choke))
	{
		level thread weapon_show_hint_choke();
	}

	use_choke = false;

	if(IsDefined(level._use_choke_weapon_hints) && level._use_choke_weapon_hints == 1)
	{
		use_choke = true;
	}

	while( true )
	{

		last_update = GetTime();

		if(IsDefined(self.chest_user) && !IsDefined(self.box_rerespun))
		{
			if( is_placeable_mine( self.chest_user GetCurrentWeapon() ) || self.chest_user hacker_active())
			{
				self SetInvisibleToPlayer( self.chest_user);
			}
			else
			{
				self SetVisibleToPlayer( self.chest_user );
			}
		}
		// fix for grenade ammo
		else if(is_lethal_grenade(self.zombie_weapon_upgrade) || is_tactical_grenade(self.zombie_weapon_upgrade))
		{	
			dist = 256 * 256;
			players = get_players();
			for( i = 0; i < players.size; i++ )
			{	
				if(DistanceSquared( players[i].origin, self.origin ) < dist)
				{
					player_ammo = players[i] GetWeaponAmmoStock(self.zombie_weapon_upgrade);
					max_ammo = undefined;

					if(is_lethal_grenade(self.zombie_weapon_upgrade))
					{
						max_ammo = 4;
					}
					else if(is_tactical_grenade(self.zombie_weapon_upgrade))
					{
						max_ammo = 3;
					}

					if( players[i] can_buy_weapon() && player_ammo < max_ammo)
					{	
						self SetInvisibleToPlayer( players[i], false );
					}
					else
					{	
						self SetInvisibleToPlayer( players[i], true );
					}
				}
			}
			
		}
		else // all players
		{
			players = get_players();
			for( i = 0; i < players.size; i++ )
			{
				if( players[i] can_buy_weapon())
				{
					self SetInvisibleToPlayer( players[i], false );
				}
				else
				{
					self SetInvisibleToPlayer( players[i], true );
				}

			}
		}

		if(use_choke)
		{
			while((level._weapon_show_hint_choke > 4) && (GetTime() < (last_update + 150)))
			{
				wait 0.05;
			}
		}
		else
		{
			wait(0.1);
		}

		level._weapon_show_hint_choke ++;
	}
}

// FYI not used
rotateroll_box()
{
	angles = 40;
	angles2 = 0;
	//self endon("movedone");
	while(isdefined(self))
	{
		self RotateRoll(angles + angles2, 0.5);
		wait(0.40); //0.7
		angles2 = 40;
		self RotateRoll(angles * -2, 0.5);
		wait(0.40); //0.7
	}
}

treasure_chest_timeout()
{
	self endon( "user_grabbed_weapon" );
	self.chest_origin endon( "box_hacked_respin" );
	self.chest_origin endon( "box_hacked_rerespin" );

	wait( 10 );
	self notify( "trigger", level );
}

treasure_chest_lid_open()
{
	openRoll = 105;
	openTime = 0.3; //0.5

	self RotateRoll( 105, openTime, ( openTime * 0.4 ) ); //0.2
	//TODO
	play_sound_at_pos( "open_chest", self.origin );
	play_sound_at_pos( "music_chest", self.origin );
}

treasure_chest_lid_close( timedOut )
{
	closeRoll = -105;
	closeTime = 0.3;

	self RotateRoll( closeRoll, closeTime, ( closeTime * 0.4 ) );
	play_sound_at_pos( "close_chest", self.origin );

	self notify("lid_closed");
}

treasure_chest_weapon_spawn( chest, player, respin )
{
	self endon("box_hacked_respin");
	self thread clean_up_hacked_box();
	assert(IsDefined(player));
	// spawn the model
//	model = spawn( "script_model", self.origin );
//	model.angles = self.angles +( 0, 90, 0 );

//	floatHeight = 40;

	//move it up
//	model moveto( model.origin +( 0, 0, floatHeight ), 3, 2, 0.9 );

	// rotation would go here

	// make with the mario kart
	self.weapon_string = undefined;
	modelname = undefined;
	rand = undefined;
	number_cycles = 40;

	chest.chest_box setclientflag(level._ZOMBIE_SCRIPTMOVER_FLAG_BOX_RANDOM);

	for( i = 0; i < number_cycles; i++ )
	{

		if( i < 20 )
		{
			wait( 0.025 ); // 0.05
		}
		else if( i < 30 )
		{
			wait( 0.05 ); // 0.1
		}
		else if( i < 35 )
		{
			wait( 0.1 ); // 0.2
		}
		else if( i < 38 )
		{
			wait( 0.15 ); // 0.3
		}

		if( i + 1 < number_cycles )
		{
			rand = treasure_chest_ChooseRandomWeapon( player );
		}
		else
		{
			rand = treasure_chest_ChooseWeightedRandomWeapon( player );

/#
			weapon = GetDvar( #"scr_force_weapon" );
			if ( weapon != "" && IsDefined( level.zombie_weapons[ weapon ] ) )
			{
				rand = weapon;
				SetDvar( "scr_force_weapon", "" );
			}
#/
		}
	}

	// Here's where the org get it's weapon type for the give function
	self.weapon_string = rand;

	chest.chest_box clearclientflag(level._ZOMBIE_SCRIPTMOVER_FLAG_BOX_RANDOM);

	wait_network_frame();

	floatHeight = 40;

	self.model_dw = undefined;

	self.weapon_model = spawn( "script_model", self.origin + ( 0, 0, floatHeight));
	self.weapon_model.angles = self.angles +( 0, 90, 0 );

	modelname = GetWeaponModel( rand );
	self.weapon_model setmodel( modelname );
	self.weapon_model useweaponhidetags( rand );

	if ( weapon_is_dual_wield(rand))
	{
		self.weapon_model_dw = spawn( "script_model", self.weapon_model.origin - ( 3, 3, 3 ) ); // extra model for dualwield weapons
		self.weapon_model_dw.angles = self.angles +( 0, 90, 0 );

		self.weapon_model_dw setmodel( get_left_hand_weapon_model_name( rand ) );
		self.weapon_model_dw useweaponhidetags( rand );
	}

	// Increase the chance of joker appearing from 0-100 based on amount of the time chest has been opened.
	if( (GetDvar( #"magic_chest_movable") == "1") && !is_true( chest._box_opened_by_fire_sale ) && !(is_true( level.zombie_vars["zombie_powerup_fire_sale_on"] ) && self [[level._zombiemode_check_firesale_loc_valid_func]]()) )
	{
		// random change of getting the joker that moves the box
		random = Randomint(100);

		if( !isdefined( level.chest_min_move_usage ) )
		{
			level.chest_min_move_usage = 5;
		}

		if( level.chest_accessed < level.chest_min_move_usage )
		{
			chance_of_joker = -1;
		}
		else
		{
			chance_of_joker = level.chest_accessed + 20;

			// make sure teddy bear appears on the 8th pull if it hasn't moved from the initial spot
			if ( level.chest_moves == 0 && level.chest_accessed >= 8 )
			{
				chance_of_joker = 100;
			}

			// pulls 4 thru 8, there is a 15% chance of getting the teddy bear
			// NOTE:  this happens in all cases
			//if( level.chest_accessed >= 4 && level.chest_accessed < 8 )
			if( level.chest_accessed >= 5 && level.chest_accessed < 10 )
			{
				if( random < 15 )
				{
					chance_of_joker = 100;
				}
				else
				{
					chance_of_joker = -1;
				}
			}

			// after the first magic box move the teddy bear percentages changes
			if ( level.chest_moves > 0 )
			{
				// between pulls 8 thru 12, the teddy bear percent is 30%
				//if( level.chest_accessed >= 8 && level.chest_accessed < 12 )
				if( level.chest_accessed >= 10 && level.chest_accessed < 15 )
				{
					if( random < 30 )
					{
						chance_of_joker = 100;
					}
					else
					{
						chance_of_joker = -1;
					}
				}

				// after 12th pull, the teddy bear percent is 50%
				//if( level.chest_accessed >= 13 )
				if( level.chest_accessed >= 15 )
				{
					if( random < 50 )
					{
						chance_of_joker = 100;
					}
					else
					{
						chance_of_joker = -1;
					}
				}
			}
		}

		if(IsDefined(chest.no_fly_away))
		{
			chance_of_joker = -1;
		}

		if(IsDefined(level._zombiemode_chest_joker_chance_mutator_func))
		{
			chance_of_joker = [[level._zombiemode_chest_joker_chance_mutator_func]](chance_of_joker);
		}

		if ( chance_of_joker > random )
		{
			self.weapon_string = undefined;

			self.weapon_model SetModel("zombie_teddybear");
		//	model rotateto(level.chests[level.chest_index].angles, 0.01);
			//wait(1);
			self.weapon_model.angles = self.angles;

			if(IsDefined(self.weapon_model_dw))
			{
				self.weapon_model_dw Delete();
				self.weapon_model_dw = undefined;
			}

			self.chest_moving = true;
			flag_set("moving_chest_now");
			level.chest_accessed = 0;

			//allow power weapon to be accessed.
			level.chest_moves++;
		}
	}

	self notify( "randomization_done" );

	if (flag("moving_chest_now") && !(level.zombie_vars["zombie_powerup_fire_sale_on"] && self [[level._zombiemode_check_firesale_loc_valid_func]]()))
	{
		wait .5;	// we need a wait here before this notify
		level notify("weapon_fly_away_start");
		wait 1; //2
		self.weapon_model MoveZ(500, 4, 3);

		if(IsDefined(self.weapon_model_dw))
		{
			self.weapon_model_dw MoveZ(500,4,3);
		}

		self.weapon_model waittill("movedone");
		self.weapon_model delete();

		if(IsDefined(self.weapon_model_dw))
		{
			self.weapon_model_dw Delete();
			self.weapon_model_dw = undefined;
		}

		self notify( "box_moving" );
		level notify("weapon_fly_away_end");
	}
	else
	{
		acquire_weapon_toggle( rand, player );

		//turn off power weapon, since player just got one
		if( rand == "tesla_gun_zm" || rand == "ray_gun_zm" || rand == "thundergun_zm" || rand == "humangun_zm" || rand == "sniper_explosive_zm" || rand == "microwavegundw_zm" || rand == "shrink_ray_zm" || rand == "blundergat_zm" )
		{
			level.pulls_since_last_wonder_weapon = 0;
		}

		if( rand == "ray_gun_zm" )
		{
			level.pulls_since_last_ray_gun = 0;
		}

		if(!IsDefined(respin))
		{
			if(IsDefined(chest.box_hacks["respin"]))
			{
				self [[chest.box_hacks["respin"]]](chest, player);
			}
		}
		else
		{
			if(IsDefined(chest.box_hacks["respin_respin"]))
			{
				self [[chest.box_hacks["respin_respin"]]](chest, player);
			}
		}
		self.weapon_model thread timer_til_despawn(floatHeight);
		if(IsDefined(self.weapon_model_dw))
		{
			self.weapon_model_dw thread timer_til_despawn(floatHeight);
		}

		self waittill( "weapon_grabbed" );

		if( !chest.timedOut )
		{
			if(IsDefined(self.weapon_model))
			{
				self.weapon_model Delete();
			}

			if(IsDefined(self.weapon_model_dw))
			{
				self.weapon_model_dw Delete();
			}
		}
	}

	self.weapon_string = undefined;
	self notify("box_spin_done");
}

// FYI never used
chest_get_min_usage()
{
	return 5;
}

timer_til_despawn(floatHeight)
{
	self endon("kill_weapon_movement");
	// SRS 9/3/2008: if we timed out, move the weapon back into the box instead of deleting it
	putBackTime = 8;
	self MoveTo( self.origin - ( 0, 0, floatHeight ), putBackTime, ( putBackTime * 0.5 ) );
	wait( putBackTime );

	if(isdefined(self))
	{
		self Delete();
	}
}

// self is the player string comes from the randomization function
treasure_chest_give_weapon( weapon_string )
{
	self.last_box_weapon = GetTime();
	primaryWeapons = self GetWeaponsListPrimaries();
	current_weapon = undefined;
	weapon_limit = 3;

	if( self HasWeapon( weapon_string ) )
	{
		if ( issubstr( weapon_string, "knife_ballistic_" ) )
		{
			self notify( "zmb_lost_knife" );
		}
		self GiveStartAmmo( weapon_string );
		self SwitchToWeapon( weapon_string );
		return;
	}

 	// if ( self HasPerk( "specialty_additionalprimaryweapon" ) )
 	// {
 	// 	weapon_limit = 4;
 	// }

	// This should never be true for the first time.
	if( primaryWeapons.size >= weapon_limit )
	{
		current_weapon = self getCurrentWeapon(); // get hiss current weapon

		if ( is_placeable_mine( current_weapon ) || is_equipment( current_weapon ) )
		{
			current_weapon = undefined;
		}

		if( isdefined( current_weapon ) )
		{
			if( !is_offhand_weapon( weapon_string ) )
			{
				if( current_weapon == "tesla_gun_zm" )
				{
					level.player_drops_tesla_gun = true;
				}

				if( current_weapon == "blundergat_zm" )
				{
					level.player_drops_wonder_weapon = true;
				}

				if( current_weapon == "humangun_zm" )
				{
					level.player_drops_humangun = true;
				}

				if( current_weapon == "sniper_explosive_zm" )
				{
					level.player_drops_sniper_explosive = true;
				}


				// PI_CHANGE_END

				if ( issubstr( current_weapon, "knife_ballistic_" ) )
				{
					self notify( "zmb_lost_knife" );
				}

				self TakeWeapon( current_weapon );
				unacquire_weapon_toggle( current_weapon );
				if ( current_weapon == "m1911_zm" )
				{
					self.last_pistol_swap = GetTime();
				}

			}
		}
	}

	self play_sound_on_ent( "purchase" );

	if( IsDefined( level.zombiemode_offhand_weapon_give_override ) )
	{
		self [[ level.zombiemode_offhand_weapon_give_override ]]( weapon_string );
	}

	if( weapon_string == "zombie_cymbal_monkey" )
	{
		self maps\_zombiemode_weap_cymbal_monkey::player_give_cymbal_monkey();
		self play_weapon_vo(weapon_string);
		return;
	}
	else if ( weapon_string == "knife_ballistic_zm" && self HasWeapon( "bowie_knife_zm" ) )
	{
		weapon_string = "knife_ballistic_bowie_zm";
	}
	else if ( weapon_string == "knife_ballistic_zm" && self HasWeapon( "sickle_knife_zm" ) )
	{
		weapon_string = "knife_ballistic_sickle_zm";
	}
	if (weapon_string == "ray_gun_zm")
	{
			playsoundatposition ("mus_raygun_stinger", (0,0,0));
	}

	self GiveWeapon( weapon_string, 0 );
	self GiveStartAmmo( weapon_string );
	self SwitchToWeapon( weapon_string );

	self play_weapon_vo(weapon_string);

}

weapon_give( weapon, is_upgrade )
{
	primaryWeapons = self GetWeaponsListPrimaries();
	current_weapon = undefined;
	weapon_limit = 3;

	//if is not an upgraded perk purchase
	if( !IsDefined( is_upgrade ) )
	{
		is_upgrade = false;
	}

	// This should never be true for the first time.
	if( primaryWeapons.size >= weapon_limit )
	{
		current_weapon = self getCurrentWeapon(); // get his current weapon

		if ( is_placeable_mine( current_weapon ) || is_equipment( current_weapon ) )
		{
			current_weapon = undefined;
		}

		if( isdefined( current_weapon ) )
		{
			if( !is_offhand_weapon( weapon ) )
			{
				if ( issubstr( current_weapon, "knife_ballistic_" ) )
				{
					self notify( "zmb_lost_knife" );
				}
				self TakeWeapon( current_weapon );
				unacquire_weapon_toggle( current_weapon );
				if ( current_weapon == "m1911_zm" )
				{
					self.last_pistol_swap = GetTime();
				}
			}
		}
	}

	if( IsDefined( level.zombiemode_offhand_weapon_give_override ) )
	{
		if( self [[ level.zombiemode_offhand_weapon_give_override ]]( weapon ) )
		{
			return;
		}
	}

	if( weapon == "zombie_cymbal_monkey" )
	{
		self maps\_zombiemode_weap_cymbal_monkey::player_give_cymbal_monkey();
		self play_weapon_vo( weapon );
		return;
	}

	self play_sound_on_ent( "purchase" );

	if ( !is_weapon_upgraded( weapon ) )
	{
		self GiveWeapon( weapon );
	}
	else
	{
		self GiveWeapon( weapon, 0, self get_pack_a_punch_weapon_options( weapon ) );
	}

	acquire_weapon_toggle( weapon, self );
	self GiveStartAmmo( weapon );
	self SwitchToWeapon( weapon );

	self play_weapon_vo(weapon);

	//fix grenade ammo
	if(is_lethal_grenade(weapon) && self GetWeaponAmmoClip(weapon) > 4)
	{
		self SetWeaponAmmoClip(weapon, 4);
	}

	if(is_tactical_grenade(weapon) && self GetWeaponAmmoClip(weapon) > 3)
	{
		self SetWeaponAmmoClip(weapon, 3);
	}
}

ammo_give( weapon )
{
	// We assume before calling this function we already checked to see if the player has this weapon...

	// Should we give ammo to the player
	give_ammo = false;

	// Check to see if ammo belongs to a primary weapon
	if( !is_offhand_weapon( weapon ) )
	{
		if( isdefined( weapon ) )
		{
			// get the max allowed ammo on the current weapon
			stockMax = 0;	// scope declaration
			stockMax = WeaponStartAmmo( weapon );

			// Get the current weapon clip count
			clipCount = self GetWeaponAmmoClip( weapon );

			currStock = self GetAmmoCount( weapon );

			// compare it with the ammo player actually has, if more or equal just dont give the ammo, else do
			if( ( currStock - clipcount ) >= stockMax )
			{
				give_ammo = false;
			}
			else
			{
				give_ammo = true; // give the ammo to the player
			}
		}
	}
	else
	{
		// Ammo belongs to secondary weapon
		if( self has_weapon_or_upgrade( weapon ) )
		{
			// Check if the player has less than max stock, if no give ammo
			if( self getammocount( weapon ) < WeaponMaxAmmo( weapon ) )
			{
				// give the ammo to the player
				give_ammo = true;
			}
		}
	}

	if( give_ammo )
	{
		self play_sound_on_ent( "purchase" );
		self GiveStartAmmo( weapon );
// 		if( also_has_upgrade )
// 		{
// 			self GiveMaxAmmo( weapon+"_upgraded" );
// 		}

		// fix for grenade ammo
		if(is_lethal_grenade(weapon) && self GetWeaponAmmoClip(weapon) > 4)
		{
			self SetWeaponAmmoClip(weapon, 4);
		}

		if(is_tactical_grenade(weapon) && self GetWeaponAmmoClip(weapon) > 3)
		{
			self SetWeaponAmmoClip(weapon, 3);
		}
		return true;
	}

	if( !give_ammo )
	{
		return false;
	}
}
