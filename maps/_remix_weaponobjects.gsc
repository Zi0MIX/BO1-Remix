create_base_watchers()
{
	//Check for die on respawn weapons
	for( i = 0; i < level.watcherWeaponNames.size; i++ )
	{
		watcherName = level.watcherWeaponNames[i];
		sub_str = GetSubStr( watcherName, watcherName.size - 3, watcherName.size );
		if(sub_str == "_sp" || sub_str == "_zm" || sub_str == "_mp")
		{
			watcherName = GetSubStr( watcherName, 0, watcherName.size - 3 );// the - 3 removes the _sp from the weapon name
		}

		self create_weapon_object_watcher( watcherName, level.watcherWeaponNames[i], self.team );
	}

	//Check for retrievable weapons
	for( i = 0; i < level.retrievableWeapons.size; i++ )
	{
		watcherName = level.retrievableWeapons[i];
		sub_str = GetSubStr( watcherName, watcherName.size - 3, watcherName.size );
		if(sub_str == "_sp" || sub_str == "_zm" || sub_str == "_mp")
		{
			watcherName = GetSubStr( watcherName, 0, watcherName.size - 3 );// the - 3 removes the _sp from the weapon name
		}

		self create_weapon_object_watcher( watcherName, level.retrievableWeapons[i], self.team );
	}
}

watch_use_trigger( trigger, callback )
{
	self endon( "delete" );
	self endon( "death" );
	self endon("pickUpTrigger_death");

	while ( true )
	{
		trigger waittill( "trigger", player );

		if ( !IsAlive( player ) )
			continue;

		if ( !player IsOnGround() )
			continue;

		if ( IsDefined( trigger.triggerTeam ) && ( player.pers["team"] != trigger.triggerTeam ) )
			continue;

		if ( IsDefined( trigger.claimedBy ) && ( player != trigger.claimedBy ) )
			continue;

		if ( player UseButtonPressed() )
			self thread [[callback]]();
	}
}

watch_shutdown( player )
{
	player endon( "disconnect" );

	pickUpTrigger = self.pickUpTrigger;

	self waittill_any( "death", "pickUpTrigger_death" );

	pickUpTrigger delete();
}
