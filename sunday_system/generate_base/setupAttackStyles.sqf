// Trigger attacks

_time = time;

if (commandStyle == 0) then {
	_infAttackUsed = false;
	_vehAttackUsed = false;
	_vehTransportUsed = false;
	_heliTransportUsed = false;
	
	while {time < _time + 60} do {
		if (count commandGroupsInf > 0 && !_infAttackUsed) then {
			[(leader (grpNetId call BIS_fnc_groupFromNetId)), "infAttack"] remoteExec ["BIS_fnc_addCommMenuItem", (leader (grpNetId call BIS_fnc_groupFromNetId)), true];
			_infAttackUsed = true;
		};
		if (count commandTransportsGround > 0 && !_vehTransportUsed) then {
			[(leader (grpNetId call BIS_fnc_groupFromNetId)), "vehTransport"] remoteExec ["BIS_fnc_addCommMenuItem", (leader (grpNetId call BIS_fnc_groupFromNetId)), true];
			_vehTransportUsed = true;			
		};
		if (count commandGroupsVehicles > 0 && !_vehAttackUsed) then {
			[(leader (grpNetId call BIS_fnc_groupFromNetId)), "vehAttack"] remoteExec ["BIS_fnc_addCommMenuItem", (leader (grpNetId call BIS_fnc_groupFromNetId)), true];
			_vehAttackUsed = true;
		};
		if (count commandTransportsHeli > 0 && !_heliTransportUsed) then {
			[(leader (grpNetId call BIS_fnc_groupFromNetId)), "heliTransport"] remoteExec ["BIS_fnc_addCommMenuItem", (leader (grpNetId call BIS_fnc_groupFromNetId)), true];
			_heliTransportUsed = true;
		};
		
		_usedGroups = [];		
		{
			if (!(_x in _usedGroups)) then {
				(leader (grpNetId call BIS_fnc_groupFromNetId)) hcSetGroup [_x];
				_usedGroups pushBackUnique _x;			
			};
		} forEach commandGroupsInf + commandGroupsHelis + commandGroupsVehicles;
		
		sleep 1;
	};
} else {
	while {time < _time + 60} do {
		_usedGroupsInf = [];
		_usedGroupsVehicles = [];
		_usedTransportsGround = [];
		_usedGroupsHelis = [];
		
		if (count commandGroupsInf > 0) then {		
			[commandGroupsInf] spawn dco_attackTrigger;
			_usedGroupsInf = _usedGroupsInf + commandGroupsInf;
		};
		if (count commandGroupsVehicles > 0) then {
			{
				[_x, 60] spawn dco_delayedAttack;
			} forEach commandGroupsVehicles;
			_usedGroupsVehicles = _usedGroupsVehicles + commandGroupsVehicles;
		};
		if (count commandTransportsGround > 0) then {
			{
				[_x, 60] spawn dco_delayedTransport;
			} forEach commandTransportsGround;
			_usedTransportsGround = _usedTransportsGround + commandTransportsGround;
		};
		if (count commandGroupsHelis > 0) then {
			[] spawn {
				if !(isNil "AATasks") then {
					if (count AATasks > 0) then {
						_continue = true;
						{
							if !([_x] call BIS_fnc_taskExists) then {
								_continue = false;
							};
						} forEach AATasks;
						if  (_continue) then {
							waitUntil {sleep 5; ({!([_x] call BIS_fnc_taskCompleted)} count AATasks) == 0};
						};
						{
							[_x, 0] spawn dco_delayedAttack;
						} forEach commandGroupsHelis;
						_usedGroupsHelis = _usedGroupsHelis + commandGroupsHelis;
					};
				};
			};	
		};
		sleep 1;
	};
};
