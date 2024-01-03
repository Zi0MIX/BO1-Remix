summon_box_thread(hacker)
{
	self.chest.last_hacked_round = level.round_number + 5; //RandomIntRange(2,5);

	maps\_zombiemode_equip_hacker::deregister_hackable_struct(self);

	self.chest thread maps\_zombiemode_weapons::show_chest();
	self.chest thread maps\_zombiemode_weapons::hide_rubble();
	self.chest notify("kill_chest_think");

	self.chest.auto_open = true;
	self.chest.no_charge = true;
	self.chest.no_fly_away = true;
	self.chest.forced_user = hacker;

	self.chest thread maps\_zombiemode_weapons::treasure_chest_think();

	self.chest.chest_lid waittill( "lid_closed" );
	self.chest.chest_lid waittill( "rotatedone" );

	self.chest.forced_user = undefined;
	self.chest.auto_open = undefined;
	self.chest.no_charge = undefined;
	self.chest.no_fly_away = undefined;

	self.chest thread maps\_zombiemode_weapons::hide_chest();
	self.chest thread maps\_zombiemode_weapons::show_rubble();
}
