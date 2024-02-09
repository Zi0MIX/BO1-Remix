#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;

post_init()
{
    maps\_weaponobjects::create_retrievable_hint("mine_bouncing_betty", "Hold ^3[{+activate}]^7 to pick up betty");
	level.create_level_specific_weaponobject_watchers = ::create_betty_watcher_zm;

	level thread update_betty_fires();
}

create_betty_watcher_zm()
{
	watcher = self maps\_weaponobjects::create_use_weapon_object_watcher( "mine_bouncing_betty", "mine_bouncing_betty", self.team );
	watcher.pickup = ::pickup_betty;
	watcher.pickup_trigger_listener = ::pickup_betty_trigger_listener;
	watcher.skip_weapon_object_damage = true;
}

pickup_betty()
{
	player = self.owner;

	if ( !player hasweapon( self.name ) )
	{
		player thread bouncing_betty_watch();
		player thread bouncing_betty_setup();

		player notify( "zmb_enable_betty_prompt" );
	}
	else
	{
		clip_ammo = player GetWeaponAmmoClip( self.name );
		clip_max_ammo = WeaponClipSize( self.name );
		if ( clip_ammo >= clip_max_ammo )
		{
			player notify( "zmb_disable_betty_prompt" ); // just to be safe
			return;
		}
	}

	self maps\_weaponobjects::pick_up();

	clip_ammo = player GetWeaponAmmoClip( self.name );
	clip_max_ammo = WeaponClipSize( self.name );
	if ( clip_ammo >= clip_max_ammo )
	{
		player notify( "zmb_disable_betty_prompt" );
	}
}

pickup_betty_trigger_listener( trigger, player )
{
	self thread pickup_betty_trigger_listener_enable( trigger, player );
	self thread pickup_betty_trigger_listener_disable( trigger, player );
}

pickup_betty_trigger_listener_enable( trigger, player )
{
	self endon( "delete" );

	while ( true )
	{
		player waittill_any( "zmb_enable_betty_prompt", "spawned_player" );

		if ( !isDefined( trigger ) )
		{
			return;
		}

		trigger trigger_on();
		trigger linkto( self );
	}
}

pickup_betty_trigger_listener_disable( trigger, player )
{
	self endon( "delete" );

	while ( true )
	{
		player waittill( "zmb_disable_betty_prompt" );

		if ( !isDefined( trigger ) )
		{
			return;
		}

		trigger unlink();
		trigger trigger_off();
	}
}

update_betty_fires()
{
	while(true)
	{
		level.hasBettyFiredRecently = 0;
		wait_network_frame();
	}
}

wait_to_fire_betty()
{
	while(level.hasBettyFiredRecently >= 4)
	{
		wait_network_frame();
	}

	level.hasBettyFiredRecently++;
}

buy_bouncing_betties()
{
	self.zombie_cost = 1000;
	self UseTriggerRequireLookAt();
	self sethintstring( &"ZOMBIE_BETTY_PURCHASE" );
	self setCursorHint( "HINT_NOICON" );

	level thread set_betty_visible();
	//self.placeable_mine_name = "mine_bouncing_betty";
	//self thread maps\_remix_zombiemode_weapons::decide_hide_show_hint();
	self.betties_triggered = false;

	while(1)
	{
		self waittill("trigger",who);
		if( who in_revive_trigger() )
		{
			continue;
		}

		if( is_player_valid( who ) )
		{
			if( who.score >= self.zombie_cost )
			{
				if ( !who is_player_placeable_mine( "mine_bouncing_betty" ) )
				{
					who maps\_zombiemode_weapons::check_collector_achievement( "mine_bouncing_betty" );
					who thread show_betty_hint("betty_purchased");

					who thread bouncing_betty_watch();

					//set the score
					who maps\_zombiemode_score::minus_to_player_score( self.zombie_cost );
					who thread bouncing_betty_setup();
					who notify( "zmb_disable_betty_prompt" );

					play_sound_at_pos( "purchase", self.origin );

					trigs = getentarray("betty_purchase","targetname");
					for(i = 0; i < trigs.size; i++)
					{
						trigs[i] SetInvisibleToPlayer(who);
					}
				}

				// JMA - display the bouncing betties
				if( self.betties_triggered == false )
				{
					model = getent( self.target, "targetname" );
					model thread maps\_zombiemode_weapons::weapon_show( who );
					self.betties_triggered = true;
				}
			}
			else
			{
				who maps\_zombiemode_audio::create_and_play_dialog( "general", "no_money", undefined, 1 );
			}
		}
	}
}

bouncing_betty_watch()
{
	self endon("death");

	while(1)
	{
		self waittill("grenade_fire",betty,weapname);
		if(weapname == "mine_bouncing_betty")
		{
			betty.owner = self;
			betty thread betty_think();
			betty thread betty_death_think();
			//betty thread pickup_betty();

			self notify( "zmb_enable_betty_prompt" );
		}
	}
}

betty_death_think()
{
	self waittill("death");

	self.owner.mines = array_removeUndefined(self.owner.mines);

	if(isDefined(self.trigger))
	{
		self.trigger delete();
	}

	self delete();
}

bouncing_betty_setup()
{
	self giveweapon("mine_bouncing_betty");
	self set_player_placeable_mine("mine_bouncing_betty");
	self setactionslot(4,"weapon","mine_bouncing_betty");
	self setweaponammostock("mine_bouncing_betty",2);
}

betty_think()
{
	self endon("death");

	if(!isdefined(self.owner.mines))
		self.owner.mines = [];
	self.owner.mines = array_add( self.owner.mines, self );

	amount = level.max_mines / get_players().size;

	if( self.owner.mines.size > amount )
	{
		self.too_many_mines_explode = true;
		self.trigger notify("trigger");
		self.owner.mines = array_remove_nokeys( self.owner.mines, self );
	}

	self waittill_not_moving();

	trigger = spawn("trigger_radius",self.origin,1,80,64);//9
	self.trigger = trigger;

	wait(1);

	if(!(IsDefined(self.too_many_mines_explode) && self.too_many_mines_explode))
	{
		while(1)
		{
			trigger waittill( "trigger", ent );

			if(IsDefined(self.too_many_mines_explode) && self.too_many_mines_explode)
				break;

			if ( isdefined( self.owner ) && ent == self.owner )
			{
				continue;
			}

			if( level.gamemode == "survival" && isDefined( ent.pers ) && isDefined( ent.pers["team"] ) && ent.pers["team"] != "axis" )
			{
				continue;
			}

			if( level.gamemode != "survival" && IsPlayer(ent) && ent.vsteam == self.owner.vsteam )
			{
				continue;
			}

			if ( ent damageConeTrace(self.origin, self) == 0 )
			{
				continue;
			}

			break;
		}
	}

	wait_to_fire_betty();

	if(is_in_array(self.owner.mines,self))
	{
		self.owner.mines = array_remove_nokeys(self.owner.mines,self);
	}

	self notify("pickUpTrigger_death");
	if ( isdefined( trigger ) )
	{
		trigger delete();
	}
	self playsound("betty_activated");
	wait(.1);
	fake_model = spawn("script_model",self.origin);
	fake_model setmodel(self.model);
	self hide();
	tag_origin = spawn("script_model",self.origin);
	tag_origin setmodel("tag_origin");
	tag_origin linkto(fake_model);
	playfxontag(level._effect["betty_trail"], tag_origin,"tag_origin");
	fake_model moveto (fake_model.origin + (0,0,32),.2);
	fake_model waittill("movedone");
	playfx(level._effect["betty_explode"], fake_model.origin);
	earthquake(1, .4, fake_model.origin, 512);

	if ( isdefined( fake_model ) )
	{
		fake_model delete();
	}
	if ( isdefined( tag_origin ) )
	{
		tag_origin delete();
	}

	if ( isdefined( self.owner ) )
	{
		self detonate( self.owner );
	}
	else
	{
		self detonate( undefined );
	}

	if ( isdefined( self ) )
	{
		self delete();
	}
}

give_betties_after_rounds()
{
	while(1)
	{
		level waittill( "between_round_over" );
		{
			players = get_players();
			for(i=0;i<players.size;i++)
			{
				if ( players[i] is_player_placeable_mine( "mine_bouncing_betty" ) )
				{
					players[i] giveweapon("mine_bouncing_betty");
					players[i] set_player_placeable_mine("mine_bouncing_betty");
					players[i] setactionslot(4,"weapon","mine_bouncing_betty");
					players[i] setweaponammoclip("mine_bouncing_betty",2);
					players[i] notify( "zmb_disable_betty_prompt" );
				}
			}
		}
	}
}
