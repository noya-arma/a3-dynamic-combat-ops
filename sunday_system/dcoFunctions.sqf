dco_callSupportTransport = {	
	transportCommMenu = [["Helicopter Transport", true]];	
	{
		transportCommMenu = transportCommMenu + [
			[
				(_x select 1),
				[_forEachIndex + 2],
				"",
				-5,
				[[
					"expression",
					format ["[(((transportProviders) select %1) select 0), %2] spawn sun_heliTransport", _forEachIndex, _pos]
				]],
				"1",				
				if (((_x select 0) getVariable ["transportSupporting", false]) || fuel (_x select 0) < 0.1 || !canMove (_x select 0) || !alive (_x select 0)) then {"0"} else {"1"},
				""
			]
		];
	} forEach transportProviders;	
	[] spawn {
		sleep 0.1;
		showCommandingMenu "#USER:transportCommMenu";		
	}
};
dco_commandHelp = {
	if (ctrlFade ((findDisplay 626262) displayCtrl 1053) == 1) then {
		_str = "
			<t font='RobotoCondensed' align='left'>
				<t color='#b6e0ff' size='2' align='center'>Command Help</t>
				<br /><br />Dynamic Combat Ops gives you two commanding style options to choose from.
				<br /><br /><t color='#b6e0ff'>Platoon commander</t> puts you in charge of platoon Alpha defined by the selections below. You will be given High Command control over them as well as support triggers to begin an automated attack.
				<br /><br /><t color='#b6e0ff'>Cog in battle</t> gives control of both Alpha and Bravo platoons over to the AI allowing you to pursue your objectives and operate within the battle without needing to manage the overall offensive.
			</t>
		";		
		((findDisplay 626262) displayCtrl 1053) ctrlSetStructuredText (parseText _str);
		((findDisplay 626262) displayCtrl 1053) ctrlSetFade 0;
		((findDisplay 626262) displayCtrl 1053) ctrlCommit 0.1;
	} else {
		((findDisplay 626262) displayCtrl 1053) ctrlSetFade 1;
		((findDisplay 626262) displayCtrl 1053) ctrlCommit 0.1;
	};
};
dco_platoonHelp = {
	if (ctrlFade ((findDisplay 626262) displayCtrl 1053) == 1) then {
		_str = "
			<t font='RobotoCondensed' align='left'>
				<t color='#b6e0ff' size='2' align='center'>Platoon Help</t>
				<br /><br />In Dynamic Combat Ops you have access to 4 platoon slots which can be filled with infantry groups or vehicles for you to command or use personally.
				<br /><br />Each slot has a corresponding type selection, either <t color='#b6e0ff'>Empty</t>, <t color='#b6e0ff'>Crewed</t> or <t color='#b6e0ff'>Crewed + Cargo</t>. When the slot has a vehicle selected, choosing <t color='#b6e0ff'>Empty</t> will spawn an empty vehicle with no crew. When choosing <t color='#b6e0ff'>Crewed</t> a vehicle will be spawned with a crew for you to command. Similarly for <t color='#b6e0ff'>Crewed + Cargo</t>, except any cargo slots for infantry units will be filled with a group.
				<br /><br />All of these units will be available to command under the High Command menu (default Ctrl-Space). Additionally you will be given a support menu option that will send the units to attack the nearest sector without requiring further commands.<br />The exception to this is crewed transport helicopters, which will only be assigned a support command to allow them to drop off their infantry cargo, after which they will become a regular support transport.
				<br /><br />Your chosen units will make up Platoon Alpha. During the battle you will be supported by the AI Platoon Bravo, who will attack once any Secure Route tasks have been completed.
				<br /><br />If choosing a plane as one or more of your platoon options it is recommended that you set your base position near a runway. Planes cannot spawn with an AI crew.
			</t>
		";		
		((findDisplay 626262) displayCtrl 1053) ctrlSetStructuredText (parseText _str);
		((findDisplay 626262) displayCtrl 1053) ctrlSetFade 0;
		((findDisplay 626262) displayCtrl 1053) ctrlCommit 0.1;
	} else {
		((findDisplay 626262) displayCtrl 1053) ctrlSetFade 1;
		((findDisplay 626262) displayCtrl 1053) ctrlCommit 0.1;
	};
};
dco_supportsHelp = {
	if (ctrlFade ((findDisplay 626262) displayCtrl 1053) == 1) then {
		_str = "
			<t font='RobotoCondensed' align='left'>
				<t color='#b6e0ff' size='2' align='center'>Supports Help</t>
				<br /><br />Your chosen supports will become available under the support menu accessed by pressing 0 then 8. In the dropdown menu you can see which support type the unit will be (either transport, CAS or artillery). These units will not be available to command in the High Command interface.
			</t>
		";
		((findDisplay 626262) displayCtrl 1053) ctrlSetStructuredText (parseText _str);
		((findDisplay 626262) displayCtrl 1053) ctrlSetFade 0;
		((findDisplay 626262) displayCtrl 1053) ctrlCommit 0.1;
	} else {
		((findDisplay 626262) displayCtrl 1053) ctrlSetFade 1;
		((findDisplay 626262) displayCtrl 1053) ctrlCommit 0.1;
	};
};

dco_warningPP = {
	playSound ["Alarm", true];
	0 fadeSpeech 0.2;
	_warningPP = ppEffectCreate ["ColorCorrections", 1700];
	_warningPP ppEffectAdjust [1,1,0,[0.3,0,0,0.2],[0.7,0.3,0,0.6],[0.587,0.199,0.114,0],[0.4,0.15,0.3,0,0.25,0.2,1]];
	_warningPP ppEffectCommit 0.1;
	_warningPP ppEffectEnable true;	
	sleep 1;
	_warningPP ppEffectAdjust [1, 1, 0, [1, 1, 1, 0], [0, 0, 0, 1],[0,0,0,0]];
	_warningPP ppEffectCommit 1;
	sleep 1;
	playSound ["Alarm", true];	
	_warningPP ppEffectAdjust [1,1,0,[0.3,0,0,0.2],[0.7,0.3,0,0.6],[0.587,0.199,0.114,0],[0.4,0.15,0.3,0,0.25,0.2,1]];
	_warningPP ppEffectCommit 0.1;
	_warningPP ppEffectEnable true;	
	sleep 1;
	_warningPP ppEffectAdjust [1, 1, 0, [1, 1, 1, 0], [0, 0, 0, 1],[0,0,0,0]];
	_warningPP ppEffectCommit 1;
	sleep 1;
	_warningPP ppEffectEnable false;
	5 fadeSpeech 1;
};

dco_delayedAttack = {
	params ["_group", "_delay"];
	waitUntil {
		_completeReturn = true;
		{
			sleep 5;
			if ([_x] call BIS_fnc_taskExists) then {
				_desc = [_x] call BIS_fnc_taskDescription;
				if (["route", ((_desc select 1) select 0), false] call BIS_fnc_inString) then {
					_complete = [_x] call BIS_fnc_taskCompleted;
					if (!_complete) then {
						_completeReturn = false;
					};
				};
			};			
		} forEach taskIDs;
		_completeReturn
	};
	waitUntil {((leader (grpNetId call BIS_fnc_groupFromNetId)) distance center) < maxAODist};
	sleep _delay;
	{
		_x setCaptive false;
	} forEach units _group;
	_sector = [_group] call dco_attackClosestSector;
	[leader _group, (format ['This is %1, moving to assault sector %2.', (_this select 0), (_sector getVariable "sectorLetter")])] remoteExec ['sideChat', 0];
};

dco_delayedTransport = {
	params ["_group", "_cargoGroup", "_delay"];
	waitUntil {
		_completeReturn = true;
		{
			sleep 5;
			if ([_x] call BIS_fnc_taskExists) then {
				_desc = [_x] call BIS_fnc_taskDescription;
				if (["route", ((_desc select 1) select 0), false] call BIS_fnc_inString) then {
					_complete = [_x] call BIS_fnc_taskCompleted;
					if (!_complete) then {
						_completeReturn = false;
					};
				};
			};			
		} forEach taskIDs;
		_completeReturn
	};
	waitUntil {(u1 distance center) < maxAODist};
	sleep _delay;	
	_sector = [(vehicle(leader _group)), _cargoGroup] call dco_transportToSector;
	[leader _group, (format ['This is %1, transport inbound to sector %2.', _group, (_sector getVariable "sectorLetter")])] remoteExec ['sideChat', 0];		
};

dco_mark3d = {	
	while {(player distance startPos) < 150} do {
		if (!isNil "MarkerData3D") then {
			{				
				[
					(_x select 0),
					"onEachFrame",
					{					
						drawIcon3D [((_this select 0) select 1), [1,1,1,1], [(getPos ((_this select 0) select 0) select 0), (getPos ((_this select 0) select 0) select 1), (getPos ((_this select 0) select 0) select 2)+5.5], 1, 1, 0, ((_this select 0) select 2), 2, 0.032, "RobotoCondensed", "center", true];	
					},
					[(_x select 1)]
				] call BIS_fnc_addStackedEventHandler;
			} forEach MarkerData3D;
		};
		sleep 2;
	};
	{
		[(_x select 0), "onEachFrame"] call BIS_fnc_removeStackedEventHandler;		
	} forEach MarkerData3D;
};

dco_debugWinSectors = {
	{
		if (side _x == side player) then {
			_x allowDamage false;
		};
	} forEach allUnits;

	{
		[_x] call dco_captureSector;
	} forEach dcoSectors;
};


dco_transportTrigger = {
	params ["_groupArray"];
	{
		
		_thisGroup = group(driver(_x select 0));
		_sector = [(_x select 0), (_x select 1)] call dco_transportToSector;
		[leader _thisGroup, (format ['This is %1, transport inbound to sector %2.', _thisGroup, (_sector getVariable "sectorLetter")])] remoteExec ['sideChat', 0];		
		sleep 2;
	} forEach _groupArray;
};

dco_attackTrigger = {
	params ["_groupArray"];
	{
		{
			_x setCaptive false;	
		} forEach units _x;	
		_sector = [_x] call dco_attackClosestSector;
		[leader _x, (format ['This is %1, moving to assault sector %2.', _x, (_sector getVariable "sectorLetter")])] remoteExec ['sideChat', 0];		
		sleep 2;
	} forEach _groupArray;	
};

dco_addGroupIcon = {
	params ["_group", "_groupType"];
	private _iconSide = switch (side _group) do {
		case west: {"b_"};
		case east: {"o_"};
		case resistance: {"n_"};
		default {"b_"};
	};
	private _iconType = switch (toUpper _groupType) do {
		case "INFANTRY": {"inf"};
		case "ARMOR": {"armor"};
		case "NAVAL": {"naval"};
		case "CAR": {"motor_inf"};
		case "PLANE": {"plane"};
		case "HELI": {"air"};
		case "SUPPORT": {"art"};
		default {"inf"};
	};	
	private _icon = [_iconSide, _iconType] joinString "";
	private _color = switch (side _group) do {	
		case west: {[(profilenamespace getvariable ['Map_BLUFOR_R',0]),(profilenamespace getvariable ['Map_BLUFOR_G',1]),(profilenamespace getvariable ['Map_BLUFOR_B',1]),(profilenamespace getvariable ['Map_BLUFOR_A',0.8])]};
		case east: {[(profilenamespace getvariable ['Map_OPFOR_R',0]),(profilenamespace getvariable ['Map_OPFOR_G',1]),(profilenamespace getvariable ['Map_OPFOR_B',1]),(profilenamespace getvariable ['Map_OPFOR_A',0.8])]};
		case resistance: {[(profilenamespace getvariable ['Map_Independent_R',0]),(profilenamespace getvariable ['Map_Independent_G',1]),(profilenamespace getvariable ['Map_Independent_B',1]),(profilenamespace getvariable ['Map_Independent_A',0.8])]};
		default {[(profilenamespace getvariable ['Map_BLUFOR_R',0]),(profilenamespace getvariable ['Map_BLUFOR_G',1]),(profilenamespace getvariable ['Map_BLUFOR_B',1]),(profilenamespace getvariable ['Map_BLUFOR_A',0.8])]};
	};
	_group addGroupIcon [_icon, [1, 0.5]];
	_group setGroupIconParams [_color, "", 1, true];
};

dco_captureSector = {
	params ["_sector"];
	(_sector getVariable 'marker') setMarkerColor markerColorPlayers;
	if (count (_sector getVariable 'taskID') > 0) then { 
		[(_sector getVariable 'taskID'), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
	};
	dcoSectors = dcoSectors - [_sector];
	publicVariable "dcoSectors";
	if (count dcoSectors > 0) then {
		{
			[_x] call dco_attackClosestSector;
		} forEach (_sector getVariable "assignedGroups");
	};
	
	// Random reinforcement task chance		
	reinforceCounter = reinforceCounter + 1;
	_chance = 17 * reinforceCounter;
	if ((random 100) < _chance) then {
		[_sector] execVM "sunday_system\objectives\sectorReinforcementsCombat.sqf";
	};	
	// Random supply task chance
	if (count pHeliClasses > 0) then {		
		if !(supplyUsed) then {
			supplyCounter = supplyCounter + 1;				
			_chance = 15 * supplyCounter;
			if ((random 100) < _chance) then {
				supplyUsed = true;
				[_sector] spawn {
					if !(isNil "AATasks") then {
						if (count AATasks > 0) then {
							_continue = true;
							{
								if !([_x] call BIS_fnc_taskExists) then {
									_continue = false;
								};
							} forEach AATasks;
							if  (_continue) then {
								waitUntil {({!([_x] call BIS_fnc_taskCompleted)} count AATasks) == 0};
							};
						};
					};				
					[_this select 0] execVM "sunday_system\objectives\clearSupportCombat.sqf";
				};				
			};
		};
	};
};

dco_assignSectorAttacker = {
	params ["_sector", "_group"];
	_sector setVariable ["assignedGroups", (_sector getVariable "assignedGroups") + [_group]];
};

dco_closestSector = {
	params ["_subject", "_nextClosest"];
	_pos = switch (typeName _subject) do {
		case "OBJECT": {getPos _subject};
		case "ARRAY": {_subject};
	};
	_closestSectors = [dcoSectors, [_pos], {_input0 distance _x}, "ASCEND", {}] call BIS_fnc_sortBy;
	private _return = objNull;
	if (!isNil "_nextClosest") then {
		if ((count _closestSectors > 1) && (_nextClosest)) then {
			_return = _closestSectors select 1;
		};
	};
	if (count _closestSectors > 0) then {
		_return = _closestSectors select 0;
	};
	_return
};

dco_closestSectorIndex = {
	params ["_pos", "_closestSector", "_sectorIndex"];
	_closestSector = [_pos] call dco_closestSector;
	_sectorIndex = if (!isNull _closestSector) then {
		dcoSectors find _closestSector;
	} else {
		-1
	};
	_sectorIndex
};

dco_attackClosestSector = {
	params ["_group"];
	private _return = objNull;
	//if (vehicle (leader _group) == (leader _group)) then {
		_closestSector = [vehicle(leader _group)] call dco_closestSector;		
		if !(_closestSector isEqualTo objNull) then {
			[_group, getPos _closestSector] call BIS_fnc_taskAttack;			
			[_closestSector, _group] call dco_assignSectorAttacker;
			_return = _closestSector;
			diag_log (format ['DCO: %1 attacking sector %2.', _group, (_closestSector getVariable "sectorLetter")]);
		} else {
			diag_log "DCO: No valid sectors found to attack";
			_return = objNull;
		};
	//};
	_return
};

dco_transportToSector = {
	params ["_vehicle", "_group"];
	private _return = objNull;
	_closestSector = [_vehicle] call dco_closestSector;
	if !(_closestSector isEqualTo objNull) then {
		_RTB = if (_vehicle isKindOf "Helicopter") then {
			true
		} else {
			false
		};
		[_vehicle, _group, getPos _closestSector, _RTB, false, "LAND"] execVM "sunday_system\orders\insertGroup.sqf";
		_return = _closestSector;		
		diag_log (format ['DCO: %1 transporting %2 to sector %3.', group(driver _vehicle), _group, (_closestSector getVariable "sectorLetter")]);
	} else {
		diag_log "DCO: No valid sectors found for transport";
		_return = objNull;
	};
	_return
};

dco_beginPlayerAttack = {	
	{
		[_x] call dco_attackClosestSector;
	} forEach commandGroupsVehicles;
	{
		[(_x select 0), (_x select 1)] call dco_transportToSector;		
	} forEach commandTransports;
};