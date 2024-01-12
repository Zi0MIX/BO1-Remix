#include common_scripts\utility; 
#include maps\_utility;
#include maps\_zombiemode_utility;

electric_trap_think()
{	
	self sethintstring(&"WAW_ZOMBIE_BUTTON_NORTH_FLAMES");
	self setCursorHint( "HINT_NOICON" );
	self.is_available = true;
	self.zombie_cost = 1000;
	self.in_use = 0;
	level thread maps\zombie_cod5_sumpf::turnLightGreen(self.script_string);
	
	while(1)
	{
		//valve_trigs = getentarray(self.script_noteworthy ,"script_noteworthy");		
	
		//wait until someone uses the valve
		self waittill("trigger",who);
		if( who in_revive_trigger() )
		{
			continue;
		}
		
		if(!isDefined(self.is_available))
		{			
			continue;			
		}
				
		if( is_player_valid( who ) )
		{
			if( who.score >= self.zombie_cost )
			{				
				if(!self.in_use)
				{
					self.in_use = 1;
					play_sound_at_pos( "purchase", who.origin );
					who maps\_zombiemode_audio::create_and_play_dialog("level", "trap_barrel");
					self thread electric_trap_move_switch(self);
					//need to play a 'woosh' sound here, like a gas furnace starting up
					self waittill("switch_activated");
					//set the score
					who maps\_zombiemode_score::minus_to_player_score( self.zombie_cost );

					//turn off the valve triggers associated with this valve until the gas is available again
					//array_thread (valve_trigs,::trigger_off);
					self trigger_off();
					level thread maps\zombie_cod5_sumpf::turnLightRed(self.script_string);
					
					//this trigger detects zombies walking thru the flames
					self.zombie_dmg_trig = getent(self.target,"targetname");
					self.zombie_dmg_trig trigger_on();
					
					//play the flame FX and do the actual damage
					self thread activate_electric_trap(who);					
					
					//wait until done and then re-enable the valve for purchase again
					self waittill("elec_done");
					
					clientnotify(self.script_string +"off");
										
					//delete any FX ents
					if(isDefined(self.fx_org))
					{
						self.fx_org delete();
					}
					if(isDefined(self.zapper_fx_org))
					{
						self.zapper_fx_org delete();
					}
					if(isDefined(self.zapper_fx_switch_org))
					{
						self.zapper_fx_switch_org delete();
					}
										
					
					//turn the damage detection trigger off until the flames are used again
			 		self.zombie_dmg_trig trigger_off();
					wait(25);
					//array_thread (valve_trigs,::trigger_on);
					self trigger_on();
					level thread maps\zombie_cod5_sumpf::turnLightGreen(self.script_string);
				
					//Play the 'alarm' sound to alert players that the traps are available again (playing on a temp ent in case the PA is already in use.
					pa_system = getent("speaker_by_log", "targetname");
					playsoundatposition("warning", pa_system.origin);
					self notify("available");

					self.in_use = 0;					
				}
			}
		}
	}
}
