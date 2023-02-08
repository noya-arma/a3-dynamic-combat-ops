params ["_unitData", ["_command", true], ["_inc", 0]];
private ["_thisUnitClass", "_thisUnitCrewing", "_isGroup", "_group", "_IDString", "_vehicle"];

_thisUnitClass = (_unitData select 1);
_thisUnitCrewing = (_unitData select 2);
if (_inc == 0) then {
	diag_log format ["unitData = %1", _unitData];
};
_IDString = "";
MarkerData3D = if (isNil "MarkerData3D") then {[]} else {MarkerData3D};

if (count _thisUnitClass > 0) then {
	
	// Detect whether this class is a vehicle or infantry group
	_isGroup = if (_thisUnitClass isKindOf "AllVehicles") then {false} else {true};		
	if (_thisUnitClass == "RANDOMVEH") then {			
		_thisUnitClass = selectRandom (pTankClasses + pCarClasses + pHeliClasses);		
		_isGroup = false;
	};
	if (_thisUnitClass == "RANDOMINF") then {			
		_pInfGroups = [];
		if (count pInfGroups > 0) then {
			{_pInfGroups pushBack (_x select 0)} forEach pInfGroups;
			_thisUnitClass = selectRandom _pInfGroups;	
			_isGroup = true;
		} else {
			_thisUnitClass = 0;	
			_isGroup = true;
		};			
	};
	
	
	if (_isGroup) then {
		
		// *****
		// INFANTRY GROUP
		// *****
		
		if (typeName _thisUnitClass == "SCALAR") then {
			// No group config data found, generating random group
			_thisPos = [startPos, 10, 50, 2, 0, 1, 0, [trgAOC], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
			if !(_thisPos isEqualTo [0,0,0]) then {					
				_group = [_thisPos, playersSide, pInfClassesForWeights, pInfClassWeights, [4, 8]] call dro_spawnGroupWeighted;
				if (_command && commandStyle == 0) then {
					MarkerData3D pushBack [_IDString, [(leader _group), "\A3\ui_f\data\igui\cfg\simpleTasks\types\meet_ca.paa", "Infantry"]];
				};
				_IDString = format ["%3-%1 %2", _inc, "Infantry", (if(_command)then{"A"}else{"B"})];
				_group setGroupIdGlobal [_IDString];
				if (_command) then {commandGroupsInf pushBack _group} else {[_group, 0] spawn dco_delayedAttack};
			};
		} else {
			// Group config data used for group
			_config = _thisUnitClass;				
			if (typeName _thisUnitClass == "STRING") then {						
				_configPath = _thisUnitClass splitString "/";				
				_config = configFile/(_configPath select 1)/(_configPath select 2)/(_configPath select 3)/(_configPath select 4)/(_configPath select 5);								
			};
			_thisPos = [startPos, 10, 50, 2, 0, 1, 0, [trgAOC], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
			if !(_thisPos isEqualTo [0,0,0]) then {		
				_group = [_thisPos, playersSide, _config] call BIS_fnc_spawnGroup;			
				_groupName = if (isNil {((_config >> "name") call BIS_fnc_getCfgData)}) then {"Infantry"} else {((_config >> "name") call BIS_fnc_getCfgData)};						
				_IDString = format ["%3-%1 %2", _inc, _groupName, (if(_command)then{"A"}else{"B"})];
				if (_command && commandStyle == 0) then {
					MarkerData3D pushBack [_IDString, [(leader _group), "\A3\ui_f\data\igui\cfg\simpleTasks\types\meet_ca.paa", _groupName]];
				};
				_group setGroupIdGlobal [_IDString];
				if (_command) then {commandGroupsInf pushBack _group} else {[_group, 0] spawn dco_delayedAttack};
			};
		};
	} else {
		
		// *****
		// VEHICLE GROUP
		// *****
		
		_thisPos = [];
		_thisDir = 0;
		
		// Is there a free helipad for this helicopter?
		if (_thisUnitClass isKindOf "Helicopter") then {				
			if (count baseHelipads > 0) then {
				_pad = [baseHelipads] call sun_selectRemove;
				_thisPos = getPos _pad;
			} else {
				_thisPos = [startPos, 20, 100, 10, 0, 0.3, 0, [trgBase], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
			};								
		} else {
			// Ground vehicle position
			_thisPos = [startPos, 20, 100, 8, 0, 1, 0, [trgBase], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
		};			
		
		// Is there an airstrip for this plane?
		if (_thisUnitClass isKindOf "Plane") then {			
			if (count _airbase > 0) then {				
				_thisPos = (_airbase select 0) findEmptyPosition [0, 50, _thisUnitClass];
				_thisDir = [(_airbase select 0), [((_airbase select 1) select 0), ((_airbase select 1) select 1)]] call BIS_fnc_dirTo;				
			};
		};
		
		diag_log format ["DCO: HC vehicle %1 will attempt spawn at %2", _thisUnitClass, _thisPos];
		
		if !(_thisPos isEqualTo [0,0,0]) then {
			_vehicle = objNull;				
			if (_thisUnitClass isKindOf "Plane") then {
				if (_thisUnitCrewing == 2) then {_thisUnitCrewing = 1};
				if (_thisUnitCrewing > 0) then {
					// Spawn crewed plane flying in the air
					_thisPos set [0, ((_thisPos select 0) + (random [-50, 0, 50]))];
					_thisPos set [1, ((_thisPos select 1) + (random [-50, 0, 50]))];
					_thisPos set [2, 1000];						
					_vehicle = createVehicle [_thisUnitClass, _thisPos, [], 0, "FLY"];						
					_vehicle setPos _thisPos;
					_vehicle flyInHeight 1000;
				} else {
					// Spawn empty plane on ground
					_vehicle = createVehicle [_thisUnitClass, _thisPos, [], 0, "NONE"];
				};					
			} else {
				// Spawn ground vehicle
				_vehicle = createVehicle [_thisUnitClass, _thisPos, [], 0, "NONE"];	
			};
			
			// Check for successful vehicle spawn
			_continue = true;
			_time = time;
			waitUntil {
				if (time > _time + 5) exitWith {_continue = false; true};
				(!isNull _vehicle)
			};			
			if (!_continue) exitWith {diag_log "DCO: Vehicle spawn failure!"};
			
			diag_log format ["DCO: Vehicle %1 spawned at %2", _vehicle, _thisPos];	
			_vehicle setDir _thisDir;
			
			// Create respawn data for vehicle
			_vehicleVar = format ["veh%1", round(random 100000)];
			[_vehicle, _vehicleVar] remoteExec ["setVehicleVarName", 0, true];
			diag_log format ["DCO: Vehicle %1 var set to %2", _vehicle, _vehicleVar];			
			_specificMkrName = format ["respawn_%1", _vehicleVar];
			_specificRespawnMkr = createMarker [_specificMkrName, _thisPos];
			_specificRespawnMkr setMarkerShape "ICON";
			_specificRespawnMkr setMarkerType "EmptyIcon";
			_vehicle respawnVehicle [60, 0];
			diag_log format ["DCO: Vehicle %1 respawn marker = %2", _vehicle, _specificRespawnMkr];
			if (_command && commandStyle == 0) then {
				MarkerData3D pushBack [_vehicleVar, [_vehicle, ((configFile >> "CfgVehicles" >> _thisUnitClass >> "icon") call BIS_fnc_GetCfgData), ((configFile >> "CfgVehicles" >> _thisUnitClass >> "displayName") call BIS_fnc_GetCfgData)]];
			};			
	
			// Vehicle crewing
			
			// Random crewing
			if (_thisUnitCrewing == 3) then {			
				_thisUnitCrewing = selectRandom [0,1,2];					
			};
			
			// Check the vehicle has enough transport space if transport crewing is selected
			if (_thisUnitCrewing == 2) then {
				if (((configFile >> "CfgVehicles" >> _thisUnitClass >> "transportSoldier") call BIS_fnc_GetCfgData) == 0) then {
					_thisUnitCrewing = 1;
				};
			};		
			
			if (_thisUnitCrewing > 0) then {
				diag_log format ["DCO: Vehicle %1 _thisUnitCrewing = %2", _vehicle, _thisUnitCrewing];
				if (_thisUnitCrewing == 2) then {
					// Crew plus transport group					
						[_vehicle, playersSide] call sun_createVehicleCrew;
						diag_log format ["DCO: Vehicle %1 crew = %2", _vehicle, (crew _vehicle)];
						_cargoToFill = ((configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "transportSoldier") call BIS_fnc_GetCfgData);
						diag_log format ["DCO: Vehicle %1 transport group min %2 max %3", _vehicle, ceil(_cargoToFill/2), _cargoToFill];
						_group = [_thisPos, playersSide, pInfClassesForWeights, pInfClassWeights, [ceil(_cargoToFill/2), _cargoToFill]] call dro_spawnGroupWeighted;
						diag_log format ["DCO: Vehicle %1 transport group = %2", _vehicle, _group];							
						_IDString = format ["%2-%1 Assault", _inc, (if(_command)then{"A"}else{"B"})];
						_group setGroupIdGlobal [_IDString];
						diag_log format ["DCO: Vehicle %1 transport group ID = %2", _vehicle, _IDString];
						[_group, _vehicle, true] spawn sun_groupToVehicle;									
											
						if (_vehicle isKindOf "Helicopter") then {
							if (_command) then {
								commandTransportsHeli pushBack [_vehicle, _group];
								[_vehicle, _group, _IDString] spawn {
									waitUntil {(count(assignedCargo (_this select 0))) == 0};								
									transportProviders pushBack [(_this select 0), (_this select 2)];
									publicVariable "transportProviders";
									commandGroupsInf pushBack (_this select 1);
									[(_this select 1)] call dco_attackClosestSector;							
								};
							} else {
								[_heli, _group] spawn {					
									waitUntil {((leader (grpNetId call BIS_fnc_groupFromNetId)) distance center) < maxAODist};
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
										};
									};					
									[(_this select 0), (_this select 1), 180] call dco_delayedTransport;					
								};				
								[_heli, _group, _pos] spawn {
									waitUntil {(count(assignedCargo (_this select 0))) == 0};											
									[(_this select 1)] call dco_attackClosestSector;
									_wp = (group(_this select 0)) addWaypoint [(_this select 2), 50];
									_wp setWaypointType "GETOUT";
								};		
							};
							
						} else {
							if (_command) then {
								commandGroupsVehicles pushBack (group driver _vehicle);	
							} else {
								[(units _group)] joinSilent (group driver _vehicle);				
								(group driver _vehicle) allowFleeing 0;								
								[(group driver _vehicle), 60] spawn dco_delayedAttack;
							};							
						};
					
				} else {
					// Only crew
					[_vehicle, playersSide] call sun_createVehicleCrew;
					diag_log format ["DCO: Vehicle %1 crew = %2", _vehicle, (crew _vehicle)];
					if (_command) then {
						if (_vehicle isKindOf "Helicopter" OR _vehicle isKindOf "Plane") then {							
							commandGroupsHelis pushBack (group driver _vehicle);
							if (_vehicle isKindOf "Plane") then {								
								_wp = (group driver _vehicle) addWaypoint [getPos _vehicle, 0];
								_wp setWaypointType "LOITER";								
								_wp setWaypointLoiterType "CIRCLE";
								_wp setWaypointLoiterRadius 1000;
							};
						} else {							
							commandGroupsVehicles pushBack (group driver _vehicle);					
						};
					} else {
						if (_vehicle isKindOf "Helicopter" OR _vehicle isKindOf "Plane") then {
							[_vehicle] spawn {					
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
									};
								};					
								[(group driver (_this select 0)), 180] spawn dco_delayedAttack;					
							};		
						} else {							
							[(group driver _vehicle), 60] spawn dco_delayedAttack;				
						};
					};						
				};							
				_IDString = format ["%3-%1 %2", _inc, ((configFile >> "CfgVehicles" >> _thisUnitClass >> "displayName") call BIS_fnc_GetCfgData), (if(_command)then{"A"}else{"B"})];
				(group driver _vehicle) setGroupIdGlobal [_IDString];
				diag_log format ["DCO: Vehicle %1 ID = %2", _vehicle, _IDString];					
			};			
		};		
	};
};

publicVariable "MarkerData3D";












