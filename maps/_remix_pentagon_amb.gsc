#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include animscripts\zombie_Utility;
#include maps\_ambientpackage;

play_pentagon_announcer_vox( alias, defcon_level )
{
	if( !IsDefined( alias ) )
		return;

	if( !IsDefined( level.pentann_is_speaking ) )
	{
		level.pentann_is_speaking = 0;
	}

	if( IsDefined( defcon_level ) )
	    alias = alias + "_" + defcon_level;

	// if( level.pentann_is_speaking == 0 )
	// {
	// 	level.pentann_is_speaking = 1;
    //     wait 0.5;
	// 	level play_initial_alarm();
	// 	level play_sound_2D( alias );
	// 	level.pentann_is_speaking =0;
	// }
}

phone_egg()
{
	if( !isdefined( self ) )
	{
		return;
	}
	phone = GetEnt(self.target, "targetname");
	if(IsDefined(phone))
	{
		blinky = PlayFXOnTag( level._effect["fx_zombie_light_glow_telephone"], phone, "tag_light" );
	}
	self UseTriggerRequireLookAt();
	self SetCursorHint( "HINT_NOICON" );
	self PlayLoopSound( "zmb_egg_phone_loop" );

	self waittill( "trigger", player );

	self StopLoopSound( 1 );
	player PlaySound( "zmb_egg_phone_activate" );

	level.phone_counter = level.phone_counter + 1;

	if( level.phone_counter >= 2 )
	{
        level pentagon_unlock_doa();
	    playsoundatposition( "evt_doa_unlock", (0,0,0) );
	    wait(5);
	    level thread play_music_easter_egg();
	    level.phone_counter = 0;
	}
}

play_music_easter_egg()
{
	level.music_override = true;

	if( is_mature() )
	{
	    level thread maps\_zombiemode_audio::change_zombie_music( "egg" );
	}
	else
	{
	    //UNTIL WE GET THE SAFE VERSION OF THE SONG, THIS EASTER EGG WILL DO NOTHING FOR PEOPLE IN SAFE MODE
	    level.music_override = false;
	    return;
	    //level thread maps\_zombiemode_audio::change_zombie_music( "egg_safe" );
	}

	wait(265);
	level.music_override = false;
	level thread maps\_zombiemode_audio::change_zombie_music( "wave_loop" );

	level thread setup_phone_audio();
}

setup_phone_audio()
{
    wait(1);
    level.phone_counter = 0;
    array_thread( GetEntArray( "secret_phone_trig", "targetname" ), ::phone_egg );
}
