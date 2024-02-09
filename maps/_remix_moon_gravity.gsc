#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include animscripts\zombie_Utility;

check_player_gravity()
{
	flag_wait( "all_players_connected" );

	players = getplayers();
	for ( i = 0; i < players.size; i++ )
	{
		players[i] thread low_gravity_watch();
		players[i] thread maps\_remix_hud_client::oxygen_hud();
	}
}

low_gravity_watch()
{
	self endon( "death" );
	self endon( "disconnect" );
	
	self notify("low_gravity_watch_start");	// Make sure that there's only one of these...
 	self endon("low_gravity_watch_start");
 	
 	self.airless_vox_in_progess = false;
	
	self.time_in_low_gravity = 0;
	self.time_to_death = 0;
	time_to_death_default = 15000;
	time_to_death_jug = 17000;
	time_til_damage = 0;

	blur_level = 0;
	blur_level_max = 7;

	blur_occur = [];
	blur_occur[0] = 1000;
	blur_occur[1] = 1250;
	blur_occur[2] = 1250;
	blur_occur[3] = 1500;

	blur_occur[4] = 1500;
	blur_occur[5] = 1750;
	blur_occur[6] = 2250;
	blur_occur[7] = 2500;

	blur_intensity = [];
	blur_intensity[0] = 1;
	blur_intensity[1] = 2;
	blur_intensity[2] = 3;
	blur_intensity[3] = 5;

	blur_intensity[4] = 7;
	blur_intensity[5] = 8;
	blur_intensity[6] = 9;
	blur_intensity[7] = 10;

	blur_duration = [];
	blur_duration[0] = 0.2;
	blur_duration[1] = 0.25;
	blur_duration[2] = 0.25;
	blur_duration[3] = 0.5;

	blur_duration[4] = 0.5;
	blur_duration[5] = 0.75;
	blur_duration[6] = 0.75;
	blur_duration[7] = 1;

	if ( is_true( level.debug_low_gravity ) )
	{
		self.time_to_death = 3000;
	}

	startTime = GetTime();
	nextTime = GetTime();

	while ( 1 )
	{
		diff = nextTime - startTime;
		//iprintln( "time in low gravity = " + self.time_in_low_gravity );

		if ( IsGodMode( self ) )
		{
			self.time_in_low_gravity = 0;
			blur_level = 0;
			wait( 1 );
			continue;
		}

		if ( !is_player_valid( self ) || !is_true( level.on_the_moon ) )
		{
			self.time_in_low_gravity = 0;
			blur_level = 0;
			wait_network_frame();
			continue;
		}

		if ( ( !flag( "power_on" ) || is_true( self.in_low_gravity ) ) && !self maps\_zombiemode_equip_gasmask::gasmask_active() )
		{
			self thread airless_vox_without_repeat();
			
			time_til_damage += diff;
			self.time_in_low_gravity += diff;

			if ( self HasPerk( "specialty_armorvest" ) )
			{
				self.time_to_death = time_to_death_jug;
			}
			else
			{
				self.time_to_death = time_to_death_default;
			}

			if ( self.time_in_low_gravity > self.time_to_death )
			{
				self playsoundtoplayer( "evt_suffocate_whump", self );
				self DoDamage( self.health * 10, self.origin );
				//iprintln( "low g too long" );
				self SetBlur( 0, 0.1 );
			}
			else if ( blur_level < blur_occur.size && time_til_damage > blur_occur[ blur_level ] )
			{
				self setclientflag(level._CLIENTFLAG_PLAYER_GASP_RUMBLE);
				self playsoundtoplayer( "evt_suffocate_whump", self );
				self SetBlur( blur_intensity[ blur_level ], 0.1 );
				self thread remove_blur( blur_duration[ blur_level ] );
				blur_level++;
				if ( blur_level > blur_level_max )
				{
					blur_level = blur_level_max;
				}
				//dmg = self.health * 0.5;
				//self DoDamage( dmg, self.origin );
				time_til_damage = 0;
				//iprintln( "low g tick" );
			}
		}
		else
		{
			if ( self.time_in_low_gravity > 0 )
			{
				self.time_in_low_gravity = 0;
				time_til_damage = 0;
				blur_level = 0;
			}
		}

		startTime = GetTime();
		wait(0.1);
		nextTime = GetTime();
	}
}
