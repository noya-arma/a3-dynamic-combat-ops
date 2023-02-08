_loadout = player getVariable "respawnLoadout";
if (!isNil "_loadout") then {
	player setUnitLoadout _loadout;
	/*
	if (count (player getVariable "respawnPWeapon") > 0) then {
		if (count (primaryWeapon player) == 0) then {		
			player addWeapon ((player getVariable "respawnPWeapon") select 0);
			{
				[player, _x] call addWeaponItemEverywhere;
			} forEach ((player getVariable "respawnPWeapon") select 1);		
		};
	};
	*/
};
if (!isNil "respawnTime") then {
	setPlayerRespawnTime respawnTime;	
};
//_handler = (_this select 0) addEventHandler ["HandleDamage", rev_handleDamage];
deleteVehicle (_this select 1);
	

