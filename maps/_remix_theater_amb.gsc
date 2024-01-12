#include common_scripts\utility;
#include maps\_utility;
#include maps\_ambientpackage;
#include maps\_music;
#include maps\_zombiemode_utility;
#include maps\_busing;

meteor_egg()
{
	// if( !isdefined( self ) )
	// {
	// 	return;
	// }
	//level thread maps\zombie_theater::wait_for_power();

	/*self UseTriggerRequireLookAt();
	self SetCursorHint( "ZOMBIE_ELECTRIC_SWITCH" );
	self PlayLoopSound( "zmb_meteor_loop" );
*/

    // power trigger in spawn room
    self UseTriggerRequireLookAt();
    self sethintstring( "Hold ^3[{+activate}]^7 to turn on power" );
    self setCursorHint( "HINT_NOICON" );

	self waittill( "trigger", player );

    self sethintstring( "" );

	self StopLoopSound( 1 );
	//player PlaySound( "zmb_meteor_activate" );

	flag_set( "power_on" );
	Objective_State(8,"done");


	player maps\_zombiemode_audio::create_and_play_dialog( "eggs", "meteors", undefined, level.meteor_counter );

	level.meteor_counter = level.meteor_counter + 1;

	if( level.meteor_counter == 3 )
	{
	    level thread play_music_easter_egg( player );
        level.meteor_counter = 0;
	}
}
