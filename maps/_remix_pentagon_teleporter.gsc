#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;
#include maps\_zombiemode_zone_manager;

teleport_player(user)
{
	prone_offset = (0, 0, 49);
	crouch_offset = (0, 0, 20);
	stand_offset = (0, 0, 0);
	destination = undefined;
	dest_trig = 0;

	if(IsDefined(user.teleporting) && user.teleporting == true)
	{
		return;
	}

	user.teleporting = true;
	user FreezeControls( true );
	//user disableOffhandWeapons();
	//user disableweapons();

	// random portal to exit check, or at defcon 5 go to pack room, pack room still goes random.
	if(flag("defcon_active") && self.script_noteworthy != "conference_level2")
	{
		for ( i = 0; i < level.portal_trig.size; i++ )
		{
			if(IsDefined(level.portal_trig[i].script_noteworthy) && level.portal_trig[i].script_noteworthy == "conference_level2")
			{
				dest_trig = i;
				user thread start_defcon_countdown();
				self thread defcon_pack_poi();
			}
		}
	}
	else
	{
		dest_trig = find_portal_destination(self);

		// rediculous failsafe.
		if(!IsDefined(dest_trig))
		{
			while(!IsDefined(dest_trig))
			{
				dest_trig = find_portal_destination(self);
				break;
				wait_network_frame();
			}
		}

		// setup zombies to follow.
		self thread no_zombie_left_behind(level.portal_trig[dest_trig], user);
	}

	// script origin trigger destination targets for player placement.
	player_destination = getstructarray(level.portal_trig[dest_trig].target, "targetname");
	if(IsDefined(player_destination))
	{
		for ( i = 0; i < player_destination.size; i++ )
		{
			if(IsDefined(player_destination[i].script_noteworthy) && player_destination[i].script_noteworthy == "player_pos")
			{
				destination = player_destination[i];
			}
		}
	}

	if(!IsDefined(destination))
	{
		destination = groundpos(level.portal_trig[dest_trig].origin);
	}

	// add cool down for exiting portal.
	level.portal_trig[dest_trig] thread cooldown_portal_timer(user);

	if( user getstance() == "prone" )
	{
		desired_origin = destination.origin + prone_offset;
	}
	else if( user getstance() == "crouch" )
	{
		desired_origin = destination.origin + crouch_offset;
	}
	else
	{
		desired_origin = destination.origin + stand_offset;
	}

	wait_network_frame();
	PlayFX(level._effect["transporter_start"], user.origin);
	playsoundatposition( "evt_teleporter_out", user.origin );

	//user.teleport_origin = spawn( "script_origin", user.origin );
	//user.teleport_origin.angles = user.angles;
	//user linkto( user.teleport_origin );
	//user.teleport_origin.origin = desired_origin;
	//user.teleport_origin.angles = destination.angles;

	//DCS 113010: fix for telefrag posibility.
	players = getplayers();
	for ( i = 0; i < players.size; i++ )
	{
		if(players[i] == user)
		{
			continue;
		}

		if(Distance(players[i].origin, desired_origin) < 18)
		{
			desired_origin = desired_origin + (AnglesToForward(destination.angles) * -32);
		}
	}

	// trying to force angles on player.
	user SetOrigin( desired_origin );
	user SetPlayerAngles( destination.angles );

	PlayFX(level._effect["transporter_beam"], user.origin);
	playsoundatposition( "evt_teleporter_go", user.origin );
	wait(0.5);
	//user enableweapons();
	//user enableoffhandweapons();
	user FreezeControls( false );
	user.teleporting = false;

	//user Unlink();
//	if(IsDefined(user.teleport_origin))
//	{
//		user.teleport_origin Delete();
//	}

	//now check if and empty floors to clean up.
	level thread check_if_empty_floors();

	setClientSysState( "levelNotify", "cool_fx", user );

	//teleporter after effects.
	setClientSysState( "levelNotify", "ae1", user );
	wait( 1.25 );

	//check if a thief round.
	if(flag("thief_round"))
	{
		setClientSysState( "levelNotify", "vis4", user );
		return;
	}
	else
	{
		user.floor = maps\_zombiemode_ai_thief::thief_check_floor( user );
		setClientSysState( "levelNotify", "vis" + user.floor, user );
	}
}

find_portal_destination(orig_trig)
{
	// rsh091310 - thief can override destination
	if(IsDefined(orig_trig.thief_override))
	{
		return orig_trig.thief_override;
	}

	// DCS 091210: power room portal go to another floor.
	if(IsDefined(orig_trig.script_string) && orig_trig.script_string == "power_room_portal")
	{
		loc = [];

		for (i = 0; i < level.portal_trig.size; i++)
		{
			/*if(level.portal_trig[i].script_noteworthy == "war_room_zone_north")
			{
				loc[0] = i;
			}*/
			if(level.portal_trig[i].script_noteworthy == "conference_level1")
			{
				loc[1] = i;
			}
		}

		dest_trig = loc[RandomIntRange(0,2)];
		return dest_trig;
	}
	else
	{
		dest_trig = RandomIntRange(0,level.portal_trig.size);

		assertex(IsDefined(level.portal_trig[dest_trig].script_noteworthy),"portals need a script_noteworthy");

		// make sure didn't pick same portal or to inactive zone.
		if(level.portal_trig[dest_trig] == orig_trig || level.portal_trig[dest_trig].script_noteworthy == "conference_level2"
		|| !level.zones[level.portal_trig[dest_trig].script_noteworthy].is_enabled)
		{

			portals = level.portal_trig;

			for( i = 0; i < level.portal_trig.size; i ++)
			{
				level.portal_trig[i].index = i;

				if(level.portal_trig[i] == orig_trig || level.portal_trig[i].script_noteworthy == "conference_level2"
				|| !level.zones[level.portal_trig[i].script_noteworthy].is_enabled)
				{
					portals = array_remove( portals, level.portal_trig[i] );
				}
			}

			rand = RandomIntRange(0, portals.size);
			dest_trig = portals[rand].index;
			//IPrintLnBold("destination ", level.portal_trig[dest_trig].script_noteworthy);
		}
		return dest_trig;
	}
}
