#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;

powerup_hack(hacker)
{
	self.powerup notify("hacked");

	if(IsDefined(self.powerup.zombie_grabbable) && self.powerup.zombie_grabbable)
	{
		self.powerup notify("powerup_timedout");
		origin = self.powerup.origin;
		self.powerup Delete();

		self.powerup = maps\_zombiemode_net::network_safe_spawn( "powerup", 1, "script_model", origin);

		if ( IsDefined(self.powerup) )
		{
			self.powerup maps\_zombiemode_powerups::powerup_setup( "full_ammo" );

			self.powerup thread maps\_zombiemode_powerups::powerup_timeout();
			self.powerup thread maps\_zombiemode_powerups::powerup_wobble();
			self.powerup thread maps\_zombiemode_powerups::powerup_grab();
		}
	}
	else if(self.powerup.powerup_name == "full_ammo")
	{

		//level._sq_perk_array = array("specialty_armorvest","specialty_quickrevive","specialty_fastreload","specialty_rof","specialty_longersprint","specialty_flakjacket","specialty_deadshot");
		self.powerup maps\_zombiemode_powerups::powerup_setup("free_perk");
	}
	else
	{
		self.powerup maps\_zombiemode_powerups::powerup_setup("full_ammo");
	}

	maps\_zombiemode_equip_hacker::deregister_hackable_struct(self);
}
