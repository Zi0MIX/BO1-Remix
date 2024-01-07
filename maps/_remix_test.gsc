get_doors_nearby()
{
	flag_wait( "all_players_spawned" );

    players = get_players();

    while(1)
    {
        zombie_doors = GetEntArray( "zombie_door", "targetname" );
		//targets = GetEntArray( self.target, "targetname" );
        for( i = 0; i < zombie_doors.size; i++ )
        {
        	zombie_doors[i] notify("trigger", players[0]);
            if (Distance(zombie_doors[i].origin, players[0].origin) < 128)
            {
               	iprintln(zombie_doors[i].target);
               	iprintln(zombie_doors[i].origin);
               	wait 0.5;
            }
            //iprintln(zombie_doors[i].target);
        }
        wait 0.05;
    }
}

get_ent_nearby()
{
    while(1)
    {
    	players = get_players();
        ents = getEntArray( "script_model", "targetname");
        for(i = 0; i < ents.size; i++)
        {
            if (Distance(ents[i].origin, players[0].origin) < 128)
            {
                //iprintln(ents[i]);
                iprintln(ents[i].target);
                wait 0.5;
            }
        }
    }
}
get_perks_nearby()
{
	flag_wait( "all_players_spawned" );

    players = get_players();

    while(1)
    {
        machine = getentarray("vending_marathon", "classname");
        for( i = 0; i < machine.size; i++ )
        {
    		if (Distance(machine[i].origin, players[0].origin) < 128)
            {
               	iprintln(machine[i].target);
               	iPrintLn("testing");
               	wait 0.5;
            }
        }

        wait 0.05;
    }
}

get_position()
{
	flag_wait("all_players_spawned");
	players = get_players()[0];

	while(1)
	{
		//iprintln(level.zombie_vars["zombie_spawn_delay"]);
		iprintln(players.origin);
		//iprintln(players.angles);
		wait .5;
	}
}

gamemode_select()
{	
	players = get_players();
	gamemode = getDvar( "gamemode" );
	if(gamemode == "")
		setDvar( "gamemode", "survival" );
	if(getDvar( "start_round" ) == "")
		setDvar( "start_round", 50 );

	switch ( getDvar( "gamemode" ) )
	{
		case "survival":
			level.strattesting = false;
			//level.player_too_many_weapons_monitor = true;
			level.zombie_move_speed = 105;
			break;
		case "strat_tester":
			//strat tester
			level.strattesting = true;
			level.dog_health = 1600;
			level.player_too_many_weapons_monitor = false;
			level.round_number = getDvarInt( "start_round" );
			level.zombie_vars["zombie_spawn_delay"] = 0.08;
			level.zombie_move_speed = 105; // running speed
			level.first_round = false; // force first round to have the proper amount of zombies

			for(i=0;i<players.size;i++)
			{
				players[i].score = 555555;
				players[i] thread give_player_weapons();
				players[i] thread give_player_perks();
			}
			trig = getent("use_elec_switch","targetname");
			trig notify( "trigger" );
			break;
	}
}

give_player_weapons()
{
	switch ( Tolower( GetDvar( #"mapname" ) ) ) 
	{
	case "zombie_cod5_prototype":
		self takeWeapon( "m1911_zm" );
		self giveWeapon( "thundergun_zm" );
		self giveWeapon( "ray_gun_zm" );
		self switchToWeapon( "thundergun_zm");
		self maps\_zombiemode_weap_cymbal_monkey::player_give_cymbal_monkey();
		break;

	case "zombie_cod5_asylum":
		self takeweapon( "m1911_zm" );
		self giveWeapon( "cz75dw_zm" );
		self giveWeapon( "ray_gun_zm" );
		self switchToWeapon( "cz75dw_zm");
		self maps\_zombiemode_weap_cymbal_monkey::player_give_cymbal_monkey();
		break;

	case "zombie_cod5_sumpf":
		self takeWeapon( "m1911_zm" );
		self giveWeapon( "tesla_gun_zm" );
		self giveWeapon( "cz75dw_zm" );
		self switchToWeapon( "tesla_gun_zm");
		self maps\_zombiemode_weap_cymbal_monkey::player_give_cymbal_monkey();
		// if(isDefined(level.additional_primaryweaponmachine_origin))
		// 	self giveWeapon( "ray_gun_zm" );}
		break;

	case "zombie_cod5_factory":
		self takeWeapon( "m1911_zm" );
		self giveWeapon( "bowie_knife_zm" );
		self giveWeapon( "tesla_gun_upgraded_zm", 0, self maps\_zombiemode_weapons::get_pack_a_punch_weapon_options( "tesla_gun_upgraded_zm" ) );
		self giveWeapon( "ray_gun_upgraded_zm", 0, self maps\_zombiemode_weapons::get_pack_a_punch_weapon_options( "ray_gun_upgraded_zm" ) );
		self switchToWeapon( "tesla_gun_upgraded_zm");
		self maps\_zombiemode_weap_cymbal_monkey::player_give_cymbal_monkey();
		// if(isDefined(level.additional_primaryweaponmachine_origin))
		// 	self giveWeapon( "m1911_upgraded_zm", 0, player maps\_zombiemode_weapons::get_pack_a_punch_weapon_options( "m1911_upgraded_zm" ) );
		break;

	case "zombie_theater":
		self takeWeapon( "m1911_zm" );
		self giveWeapon( "bowie_knife_zm" );
		self giveWeapon( "thundergun_zm" );
		self giveWeapon( "ray_gun_zm" );
		self switchToWeapon( "thundergun_zm");
		self maps\_zombiemode_weap_cymbal_monkey::player_give_cymbal_monkey();
		break;

	case "zombie_pentagon":
		self takeWeapon( "m1911_zm" );
		self giveWeapon( "bowie_knife_zm" );
		self giveWeapon( "crossbow_explosive_upgraded_zm", 0, self maps\_zombiemode_weapons::get_pack_a_punch_weapon_options( "crossbow_explosive_upgraded_zm" ) );	
		self giveWeapon( "ray_gun_upgraded_zm", 0, self maps\_zombiemode_weapons::get_pack_a_punch_weapon_options( "ray_gun_upgraded_zm" ) );
		self switchToWeapon( "crossbow_explosive_upgraded_zm");
		self maps\_zombiemode_weap_cymbal_monkey::player_give_cymbal_monkey();
		break;	

	case "zombie_cosmodrome":
		self takeWeapon( "m1911_zm" );
		self giveWeapon( "thundergun_upgraded_zm", 0, self maps\_zombiemode_weapons::get_pack_a_punch_weapon_options( "thundergun_upgraded_zm" ) );
		self giveWeapon( "ray_gun_upgraded_zm", 0, self maps\_zombiemode_weapons::get_pack_a_punch_weapon_options( "ray_gun_upgraded_zm" ) );
		self switchToWeapon( "thundergun_upgraded_zm");
		self maps\_zombiemode_weap_black_hole_bomb::player_give_black_hole_bomb();
		break;

	case "zombie_coast":
		self takeWeapon( "m1911_zm" );
		self giveWeapon( "sniper_explosive_upgraded_zm", 0, self maps\_zombiemode_weapons::get_pack_a_punch_weapon_options( "sniper_explosive_upgraded_zm" ) );
		self giveWeapon( "humangun_upgraded_zm", 0, self maps\_zombiemode_weapons::get_pack_a_punch_weapon_options( "humangun_upgraded_zm" ) );
		self switchToWeapon( "sniper_explosive_upgraded_zm");
		//self giveWeapon( "ray_gun_upgraded_zm", 0, player maps\_zombiemode_weapons::get_pack_a_punch_weapon_options( "ray_gun_upgraded_zm" ) );
		// self maps\_zombiemode_weap_nesting_dolls::player_give_nesting_dolls();
		break;

	case "zombie_temple":
		self takeWeapon( "m1911_zm" );
		self giveWeapon( "bowie_knife_zm" );
		self giveWeapon( "shrink_ray_upgraded_zm", 0, self maps\_zombiemode_weapons::get_pack_a_punch_weapon_options( "shrink_ray_upgraded_zm" ) );
		self giveWeapon( "m1911_upgraded_zm", 0, self maps\_zombiemode_weapons::get_pack_a_punch_weapon_options( "m1911_upgraded_zm" ) );
		self switchToWeapon( "shrink_ray_upgraded_zm");
		self maps\_zombiemode_weap_cymbal_monkey::player_give_cymbal_monkey();
		break;

	case "zombie_moon":
		self takeWeapon( "m1911_zm" );
		self giveWeapon( "bowie_knife_zm" );
		self giveWeapon( "microwavegun_upgraded_zm", 0, self maps\_zombiemode_weapons::get_pack_a_punch_weapon_options( "microwavegun_upgraded_zm" ) );
		self giveWeapon( "m1911_upgraded_zm", 0, self maps\_zombiemode_weapons::get_pack_a_punch_weapon_options( "m1911_upgraded_zm" ) );
		self switchToWeapon( "microwavegun_upgraded_zm");
		self maps\_zombiemode_weap_black_hole_bomb::player_give_black_hole_bomb();
		break;
	case "zombie_ww":
		self takeWeapon( "m1911_zm" );
		self giveWeapon( "bowie_knife_zm" );
		self giveWeapon( "blundergat_zm" );
		self giveWeapon( "thundergun_zm" );
		self giveWeapon( "tesla_gun_zm" );
		self switchToWeapon( "blundergat_zm");
		self maps\_zombiemode_weap_cymbal_monkey::player_give_cymbal_monkey();
		break;
	}
}

give_player_perks()
{	
	switch ( Tolower( GetDvar( #"mapname" ) ) ) 
	{
	case "zombie_cod5_prototype":
		self maps\_zombiemode_perks::give_perk( "specialty_fastreload", true );
		break;

	case "zombie_cod5_asylum":
		self maps\_zombiemode_perks::give_perk( "specialty_fastreload", true );
		self maps\_zombiemode_perks::give_perk( "specialty_rof", true );
		self maps\_zombiemode_perks::give_perk( "specialty_armorvest", true );
		self maps\_zombiemode_perks::give_perk( "specialty_quickrevive", true );
		break;

	case "zombie_cod5_sumpf":
		self maps\_zombiemode_perks::give_perk( "specialty_quickrevive", true );
		self maps\_zombiemode_perks::give_perk( "specialty_fastreload", true );
		if(isDefined(level.zombie_additionalprimaryweapon_machine_origin)) {
			self maps\_zombiemode_perks::give_perk( "specialty_additionalprimaryweapon", true );
		}
		self maps\_zombiemode_perks::give_perk( "specialty_armorvest", true );
		break;

	case "zombie_cod5_factory":
		self maps\_zombiemode_perks::give_perk( "specialty_fastreload", true );
		if(isDefined(level.zombie_additionalprimaryweapon_machine_origin)) {
			self maps\_zombiemode_perks::give_perk( "specialty_additionalprimaryweapon", true );
		}
		self maps\_zombiemode_perks::give_perk( "specialty_armorvest", true );
		self maps\_zombiemode_perks::give_perk( "specialty_quickrevive", true );
		break;

	case "zombie_theater":
		self maps\_zombiemode_perks::give_perk( "specialty_quickrevive", true );
		self maps\_zombiemode_perks::give_perk( "specialty_fastreload", true );
		self maps\_zombiemode_perks::give_perk( "specialty_armorvest", true );
		break;

	case "zombie_pentagon":
		self maps\_zombiemode_perks::give_perk( "specialty_quickrevive", true );
		self maps\_zombiemode_perks::give_perk( "specialty_fastreload", true );
		if(isDefined(level.zombie_additionalprimaryweapon_machine_origin)) {
			self maps\_zombiemode_perks::give_perk( "specialty_additionalprimaryweapon", true );
		}else{
			self maps\_zombiemode_perks::give_perk( "specialty_rof", true );
		}
		self maps\_zombiemode_perks::give_perk( "specialty_armorvest", true );
		break;	

	case "zombie_cosmodrome":
		self maps\_zombiemode_perks::give_perk( "specialty_quickrevive", true );
		self maps\_zombiemode_perks::give_perk( "specialty_flakjacket", true );
		self maps\_zombiemode_perks::give_perk( "specialty_fastreload", true );
		if(isDefined(level.zombie_additionalprimaryweapon_machine_origin)) {
			self maps\_zombiemode_perks::give_perk( "specialty_additionalprimaryweapon", true );
		}

		self maps\_zombiemode_perks::give_perk( "specialty_armorvest", true );
		self maps\_zombiemode_perks::give_perk( "specialty_longersprint", true );
		break;

	case "zombie_coast":
		self maps\_zombiemode_perks::give_perk( "specialty_quickrevive", true );
		self maps\_zombiemode_perks::give_perk( "specialty_flakjacket", true );
		self maps\_zombiemode_perks::give_perk( "specialty_fastreload", true );
		if(isDefined(level.zombie_additionalprimaryweapon_machine_origin)) {
			self maps\_zombiemode_perks::give_perk( "specialty_additionalprimaryweapon", true );
		}
		self maps\_zombiemode_perks::give_perk( "specialty_armorvest", true );
		self maps\_zombiemode_perks::give_perk( "specialty_longersprint", true );
		self maps\_zombiemode_perks::give_perk( "specialty_rof", true );
		self maps\_zombiemode_perks::give_perk( "specialty_deadshot", true );
	break;

	case "zombie_temple":
		self maps\_zombiemode_perks::give_perk( "specialty_quickrevive", true );
		self maps\_zombiemode_perks::give_perk( "specialty_flakjacket", true );
		self maps\_zombiemode_perks::give_perk( "specialty_fastreload", true );

		if(isDefined(level.zombie_additionalprimaryweapon_machine_origin)) {
			self maps\_zombiemode_perks::give_perk( "specialty_additionalprimaryweapon", true );
		}
		
		self maps\_zombiemode_perks::give_perk( "specialty_armorvest", true );
		self maps\_zombiemode_perks::give_perk( "specialty_longersprint", true );
		self maps\_zombiemode_perks::give_perk( "specialty_rof", true );
		self maps\_zombiemode_perks::give_perk( "specialty_deadshot", true );
		break;

	case "zombie_moon":
		self maps\_zombiemode_perks::give_perk( "specialty_quickrevive", true );
		self maps\_zombiemode_perks::give_perk( "specialty_flakjacket", true );
		self maps\_zombiemode_perks::give_perk( "specialty_fastreload", true );
		if(isDefined(level.zombie_additionalprimaryweapon_machine_origin)) {
			self maps\_zombiemode_perks::give_perk( "specialty_additionalprimaryweapon", true );
		}
		self maps\_zombiemode_perks::give_perk( "specialty_armorvest", true );
		self maps\_zombiemode_perks::give_perk( "specialty_longersprint", true );
		self maps\_zombiemode_perks::give_perk( "specialty_rof", true );
		self maps\_zombiemode_perks::give_perk( "specialty_deadshot", true );
		break;

	case "zombie_ww":
		self maps\_zombiemode_perks::give_perk( "specialty_quickrevive", true );
		self maps\_zombiemode_perks::give_perk( "specialty_flakjacket", true );
		self maps\_zombiemode_perks::give_perk( "specialty_fastreload", true );
		self maps\_zombiemode_perks::give_perk( "specialty_armorvest", true );
		self maps\_zombiemode_perks::give_perk( "specialty_longersprint", true );
		self maps\_zombiemode_perks::give_perk( "specialty_rof", true );
		break;
	}
}

