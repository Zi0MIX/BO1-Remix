#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;

activate_vending_machine(machine, origin, entity)
{
	//activate perks-a-cola
	level notify( "master_switch_activated" );

	level.open_hut_count++;
	if( isdefined(level.open_hut_count) && level.open_hut_count >= 3)
	{
		level notify( "activate_doubletap");
	}
	switch(machine)
	{

	   case "zombie_vending_jugg_on":
	        level notify("juggernog_sumpf_on");
	        level notify( "specialty_armorvest_power_on" );
	        clientnotify("jugg_on");
			entity maps\_zombiemode_perks::perk_fx("jugger_light");
           break;

	   case "zombie_vending_doubletap_on":
	        level notify("doubletap_sumpf_on");
	        level notify( "specialty_rof_power_on" );
	        clientnotify("doubletap_on");
			entity maps\_zombiemode_perks::perk_fx("doubletap_light");
	        break;

	   case "zombie_vending_revive_on":
	        level notify("revive_sumpf_on");
	        level notify( "specialty_quickrevive_power_on" );
	        clientnotify("revive_on");
			entity maps\_zombiemode_perks::perk_fx("revive_light");
           break;

       case "zombie_vending_sleight_on":
	        level notify("sleight_sumpf_on");
	        level notify( "specialty_fastreload_power_on" );
	        clientnotify("fast_reload_on");
			entity maps\_zombiemode_perks::perk_fx("sleight_light");
           break;
   }

   play_vending_vo( machine, origin );
}
