#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;

spear_trap_think()
{
	if( isdefined(self.enable_flag) && !flag(self.enable_flag) )
	{
		flag_wait( self.enable_flag );
	}
	
	while(1)
	{
		self waittill("trigger", who);
		
		//Only player can trigger trap
		if(!IsDefined( who ) || !IsPlayer( who ) || who maps\_laststand::player_is_in_laststand() || who.sessionstate == "spectator" )
		{
			continue;
		}

		if(!who IsOnGround())
		{
			continue;
		}

		if(who GetStance() != "stand")
		{
			continue;
		}

		wait .3;

		for(i=0;i<3;i++)
		{
			self thread spear_trap_activate_spears( i, who );	//Collin A. - Added i as a value so I could tell whether or not it was the first raise
			wait 2.4; //Allow time for spears to reset
		}
	}
}

spear_trap_activate_spears( audio_counter, player )
{
	self spear_trap_damage_all_characters( audio_counter, player );
	
	self thread spear_activate(0);
}

spear_damage_character(char, activator)
{
	char thread spear_trap_slow(activator, self);
}

#using_animtree( "generic_human" );
spear_trap_slow(activator, trap)
{
	self endon("death");

	//Already SLow
	if(is_true(self.spear_trap_slow))
	{
		return;
	}

	self.spear_trap_slow = true;
	if(isPlayer(self))
	{
		if(is_player_valid(self))
		{
			self thread maps\_zombiemode_audio::create_and_play_dialog( "general", "spikes_damage" );
			//self thread _fake_red();
			RadiusDamage(self.origin + (0, 0, 5), 10, 50, 50, undefined, "MOD_UNKNOWN");
			//iprintln(self.health);
		}
		self setvelocity((0,0,0));
		self.move_speed = .2;
		self SetMoveSpeedScale(self.move_speed);
		wait 1.0;
		self.move_speed = 1;
		if(!is_true(self.slowdown_wait))
		{
			self SetMoveSpeedScale(self.move_speed);
		}
		wait 0.5;
	}
	else if(self.animname == "zombie")
	{
		self thread spear_kill(undefined, activator);

		painAnims = [];
		painAnims[0] = %ai_zombie_taunts_5b;
		painAnims[1] = %ai_zombie_taunts_5c;
		painAnims[2] = %ai_zombie_taunts_5d;
		painAnims[3] = %ai_zombie_taunts_5e;
		painAnims[4] = %ai_zombie_taunts_5f;
		painAnim = random(painAnims);
		if(is_true(self.has_legs))
		{
			self animscripted("spear_pain_anim", self.origin, self.angles, painAnim);
			self _zombie_spear_trap_damage_wait();
		}

	}
	self.spear_trap_slow = false;
}

spear_kill(magnitude, activator)
{
	self StartRagdoll();
	self launchragdoll((0, 0, 50));
	wait_network_frame();

	// Make sure they're dead...physics launch didn't kill them.
	self.a.gib_ref = "head";

	self.trap_death = true;
	self.no_powerups = true;
	self dodamage(self.health + 666, self.origin, activator);
}
