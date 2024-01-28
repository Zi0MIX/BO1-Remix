#include maps\_utility; 
#include common_scripts\utility;
#include maps\_zombiemode_utility; 
#include maps\_music; 
#include maps\_busing;

init_music_states()
{
    level.music_override = false;
    level.music_round_override = false;
    level.old_music_state = undefined;
    
    level.zmb_music_states                                  =   [];
    level.zmb_music_states["round_start"]                   =   spawnStruct();
    level.zmb_music_states["round_start"].music             =   "mus_zombie_round_start";
    level.zmb_music_states["round_start"].is_alias          =   true; 
    level.zmb_music_states["round_start"].override          =   true;
    level.zmb_music_states["round_start"].round_override    =   true;
    level.zmb_music_states["round_start"].musicstate        =   "WAVE";
    level.zmb_music_states["round_end"]                     =   spawnStruct();
    level.zmb_music_states["round_end"].music               =   "mus_zombie_round_over";
    level.zmb_music_states["round_end"].is_alias            =   true;
    level.zmb_music_states["round_end"].override            =   true;
    level.zmb_music_states["round_end"].round_override      =   true;
    level.zmb_music_states["round_end"].musicstate          =   "SILENCE";
    level.zmb_music_states["wave_loop"]                     =   spawnStruct();
    level.zmb_music_states["wave_loop"].music               =   "WAVE";
    level.zmb_music_states["wave_loop"].is_alias            =   false;
    level.zmb_music_states["wave_loop"].override            =   true;
    level.zmb_music_states["game_over"]                     =   spawnStruct();
    level.zmb_music_states["game_over"].music               =   "mus_zombie_game_over";
    level.zmb_music_states["game_over"].is_alias            =   true;
    level.zmb_music_states["game_over"].override            =   false;
    level.zmb_music_states["game_over"].musicstate          =   "SILENCE";
	level.zmb_music_states["reset"]                    		 =   spawnStruct();
    level.zmb_music_states["reset"].music           	 =   "mus_zombie_reset";
    level.zmb_music_states["reset"].is_alias            =   true;
    level.zmb_music_states["reset"].override            =   false;
    level.zmb_music_states["reset"].musicstate          =   "SILENCE";
    level.zmb_music_states["dog_start"]                     =   spawnStruct();
    level.zmb_music_states["dog_start"].music               =   "mus_zombie_dog_start";
    level.zmb_music_states["dog_start"].is_alias            =   true;
    level.zmb_music_states["dog_start"].override            =   true;
    level.zmb_music_states["dog_end"]                       =   spawnStruct();
    level.zmb_music_states["dog_end"].music                 =   "mus_zombie_dog_end";
    level.zmb_music_states["dog_end"].is_alias              =   true;
    level.zmb_music_states["dog_end"].override              =   true;
    level.zmb_music_states["egg"]                           =   spawnStruct();
    level.zmb_music_states["egg"].music                     =   "mus_egg";
    level.zmb_music_states["egg"].is_alias                  =   false;
    level.zmb_music_states["egg"].override                  =   false;
	level.zmb_music_states["egg1"]                           =   spawnStruct();
    level.zmb_music_states["egg1"].music                     =   "mus_egg1";
    level.zmb_music_states["egg1"].is_alias                  =   true;
    level.zmb_music_states["egg1"].override                  =   false;
	// level.zmb_music_states["egg1"].musicstate         		 =   "SILENCE";
    level.zmb_music_states["egg_safe"]                      =   spawnStruct();
    level.zmb_music_states["egg_safe"].music                =   "EGG_SAFE";
    level.zmb_music_states["egg_safe"].is_alias             =   true;
    level.zmb_music_states["egg_safe"].override             =   false;  
	level.zmb_music_states["egg_a7x"]                    	=   spawnStruct();
    level.zmb_music_states["egg_a7x"].music					=   "EGG_A7X";
    level.zmb_music_states["egg_a7x"].is_alias           	=   false;
    level.zmb_music_states["egg_a7x"].override           	=   false;
	level.zmb_music_states["sam_reveal"]                    =   spawnStruct();
    level.zmb_music_states["sam_reveal"].music				=   "SAM";
    level.zmb_music_states["sam_reveal"].is_alias           =   false;
    level.zmb_music_states["sam_reveal"].override           =   false;
}

do_player_playvox( prefix, index, sound_to_play, waittime, category, type, override )
{
    if (getDvar("player_quotes") == "0")
        return;

	players = getplayers();
	if( !IsDefined( level.player_is_speaking ) )
	{
		level.player_is_speaking = 0;	
	}
	
	if( is_true(level.skit_vox_override) && !override )
	    return;
	
	if( level.player_is_speaking != 1 )
	{
		level.player_is_speaking = 1;
		self playsound( prefix + sound_to_play, "sound_done" + sound_to_play );			
		self waittill( "sound_done" + sound_to_play );
		wait( waittime );		
		level.player_is_speaking = 0;
		
		if( !flag( "solo_game" ) && ( isdefined (level.plr_vox[category][type + "_response"] )))
		{
			if ( isDefined( level._audio_custom_response_line ) )
	        {
		        level thread [[ level._audio_custom_response_line ]]( self, index, category, type );
	        }
			else
			{
			    level thread maps\_zombiemode_audio::setup_response_line( self, index, category, type ); 
			}
		}
	}
}
