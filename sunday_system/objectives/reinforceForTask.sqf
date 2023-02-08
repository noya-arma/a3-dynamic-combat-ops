params ["_target", "_numbers", "_reinforcePos", "_blacklistedTypes"];
// _target can be marker name string or unit

_min = _numbers select 0;
_max = _numbers select 1;

_return = [];

private _debug = 0;

// Convert target to center position array if not already
_targetPos = switch (typeName _target) do {
	case "STRING": {getMarkerPos _target};
	case "OBJECT": {getPos _target};
	case "ARRAY": {_target};
};

// Check available reinforcement types
_styles = ["INFANTRY"];
if (count enemyGVPool > 0) then {		
	_styles pushBackUnique "CAR";	
};
if (count enemyHeliPool > 0) then {				
	_styles pushBackUnique "HELI";		
};
if (!isNil "_blacklistedTypes") then {
	{
		if (_x in _styles) then {
			_styles = _styles - [_x];
		};
	} forEach _blacklistedTypes;
};
_weights = [];
{
	switch (_x) do {
		case "INFANTRY": {_weights pushBack 0.1};		
		case "CAR": {_weights pushBack 0.7};
		case "HELI": {_weights pushBack 0.7};
	};
} forEach _styles;

_overridePos = [];
if (!isNil "_reinforcePos") then {	
	_overridePos = _reinforcePos;
	if (surfaceIsWater _overridePos) then {
		_styles = [];
		_weights = [];		
		if (count enemyHeliPool > 0) then {	
			_styles pushBack "HELI";
			_weights pushBack 1;
		};		
		if (count eShipClasses > 0) then {
			_styles pushBack "SHIP";
			_weights pushBack 1;
		};
	};	
};

if (count _styles > 0) then {

	_numReinforcements = [_min, _max] call BIS_fnc_randomInt;

	for "_i" from 1 to _numReinforcements step 1 do {
				
		diag_log "DRO: Reinforcing";	
		_reinforceType = [_styles, _weights] call BIS_fnc_selectRandomWeighted;
		//_reinforceType = "HELI";
		if (!isNil "_reinforceType") then {
			switch (_reinforceType) do {
				case "INFANTRY": {
					// Get position data
					_spawnPos = if (count _overridePos > 0) then {
						_overridePos
					} else {
						[_targetPos,900,1100,1,0,100,0] call BIS_fnc_findSafePos
					};
								
					if ((({(_spawnPos distance _x) < 600} count (units (grpNetId call BIS_fnc_groupFromNetId)) == 0))) then {
										
						// Debug marker
						if (_debug == 1) then {
							hint "REINFORCING";
							_markerRB = createMarker [format ["rbMkr%1",(random 10000)], _spawnPos];
							_markerRB setMarkerShape "ICON";
							_markerRB setMarkerColor "ColorOrange";
							_markerRB setMarkerType "mil_objective";
						};
						
						// Spawn units
						_minAI = 4 * aiMultiplier;
						_maxAI = 8 * aiMultiplier;						
						_reinfGroup = [_spawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI,_maxAI]] call dro_spawnGroupWeighted;				
						if (!isNil "_reinfGroup") then {
							[_reinfGroup, _targetPos] call BIS_fnc_taskAttack;
							//[_reinfGroup, _targetPos, [50, 300], "FULL"] execVM "sunday_system\orders\patrolArea.sqf";											
							_return pushBack _reinfGroup;
							diag_log format ["REINFORCEMENT: Infantry group %1 spawned at %2",_reinfGroup, _spawnPos];							
						};
					};
				};			
				case "CAR": {			
					_initPos = if (count _overridePos > 0) then {
						_overridePos
					} else {
						[_targetPos,1500,2000,0,0,0.5,0] call BIS_fnc_findSafePos
					};
					_roadList = [];	
					_spawnPos = [];	
					_roadList = _initPos nearRoads 500;			
						
					if (count _roadList > 0) then {
						_thisRoad = (selectRandom _roadList);
						_spawnPos = getPos _thisRoad;				
					} else {
						_spawnPos = _initPos;
					};
					if ((({(_spawnPos distance _x) < 600} count (units (grpNetId call BIS_fnc_groupFromNetId)) == 0))) then {				
						// Debug marker
						if (_debug == 1) then {
							hint "REINFORCING";
							_markerRB = createMarker [format ["rbMkr%1",(random 10000)], _spawnPos];
							_markerRB setMarkerShape "ICON";
							_markerRB setMarkerColor "ColorOrange";
							_markerRB setMarkerType "mil_objective";
						};					
						
						// Spawn vehicle
						_vehType = [enemyGVPool] call sun_selectRemove;					
						_reinfVeh = createVehicle [_vehType, _spawnPos, [], 0, "NONE"];
						[_reinfVeh] call sun_createVehicleCrew;
						waitUntil {!isNull driver _reinfVeh};				
						
						if (((configFile >> "CfgVehicles" >> _vehType >> "transportSoldier") call BIS_fnc_GetCfgData) >= 4) then {
							// Spawn units
							_maxUnits = ((configFile >> "CfgVehicles" >> _vehType >> "transportSoldier") call BIS_fnc_GetCfgData);
							_minAI = ((_maxUnits/2) * aiMultiplier) min _maxUnits;										
							_reinfGroup = [_spawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI,_maxUnits]] call dro_spawnGroupWeighted;				
							if (!isNil "_reinfGroup") then {
								[_reinfGroup, _reinfVeh, true] spawn sun_groupToVehicle;												
								[_reinfVeh, _reinfGroup, _targetPos, true, true] execVM "sunday_system\orders\insertGroup.sqf";
								_return pushBack _reinfGroup;							
								diag_log format ["REINFORCEMENT: Car transport group %1 spawned at %2; inserting at %3",_reinfGroup, _spawnPos, _targetPos];						
							};
						} else {
							diag_log format ["REINFORCEMENT: Car attack group %1 spawned at %2; inserting at %3",_reinfVeh, _spawnPos, _targetPos];	
							[group(driver _reinfVeh), _targetPos] call BIS_fnc_taskAttack;	
							_return pushBack group(driver _reinfVeh);
						};							
					};
				};			
				case "HELI": {
						
					
					// Heli type
					_spawnPos = if (count _overridePos > 0) then {
						_overridePos
					} else {
						[_targetPos,1000,1500,0,1,100,0] call BIS_fnc_findSafePos
					};				
					_heliInsertType = selectRandom ["LAND", "PARACHUTE"];
					_height = switch (_heliInsertType) do {
						case "LAND": {40};
						case "PARACHUTE": {300};
						default {300};
					};
					_spawnPos set [2,_height];
													
					// Debug marker
					if (_debug == 1) then {
						hint "REINFORCING";
						_markerRB = createMarker [format ["rbMkr%1",(random 10000)], _spawnPos];
						_markerRB setMarkerShape "ICON";
						_markerRB setMarkerColor "ColorOrange";
						_markerRB setMarkerType "mil_objective";
					};
					
					// Spawn vehicle
					_vehType = [enemyHeliPool] call sun_selectRemove;					
					_reinfVeh = createVehicle [_vehType, _spawnPos, [], 0, "FLY"];
					_reinfVeh setPos _spawnPos;
					[_reinfVeh] call sun_createVehicleCrew;
					waitUntil {!isNull driver _reinfVeh};
					if (((configFile >> "CfgVehicles" >> _vehType >> "transportSoldier") call BIS_fnc_GetCfgData) >= 4) then {
						// Spawn units					
						_maxUnits = ((configFile >> "CfgVehicles" >> _vehType >> "transportSoldier") call BIS_fnc_GetCfgData);
						_minAI = ((_maxUnits/2) * aiMultiplier) min _maxUnits;
						_reinfGroup = [_spawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI,_maxUnits]] call dro_spawnGroupWeighted;			
						if (!isNil "_reinfGroup") then {
							[_reinfGroup, _reinfVeh, true] spawn sun_groupToVehicle;					
							[_reinfVeh, _reinfGroup, _targetPos, true, true, _heliInsertType] execVM "sunday_system\orders\insertGroup.sqf";	
							_return pushBack _reinfGroup;						
							diag_log format ["REINFORCEMENT: Heli transport group %1 spawned at %2; inserting at %3",_reinfGroup, _spawnPos, _targetPos];					
						} else {
							{deleteVehicle _x} forEach crew _reinfVeh;
							deleteVehicle _reinfVeh;
						};
					};
				};
				case "SHIP": {
					_dir = [_overridePos, _targetPos] call BIS_fnc_dirTo;
					_closerPos = ([_overridePos, 800, _dir] call BIS_fnc_relPos);
					_spawnPos = if (surfaceIsWater _closerPos) then {
						_closerPos
					} else {
						_overridePos
					};					
					_spawnPos set [0, ((_spawnPos select 0) + ([-20,20] call BIS_fnc_randomNum))];
					_spawnPos set [1, ((_spawnPos select 1) + ([-20,20] call BIS_fnc_randomNum))];
					_spawnPos set [2, 0];
					diag_log eShipClasses;
					_vehType = selectRandom eShipClasses;
					_reinfVeh = createVehicle [_vehType, _spawnPos, [], 0, "NONE"];
					diag_log _reinfVeh;
					if (!isNil "_reinfVeh") then {
						_vehRoles = (count([_vehType] call BIS_fnc_vehicleRoles));
						_minAI = ((_vehRoles/2) * aiMultiplier) min _vehRoles;												
						_reinfGroup = [_spawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _vehRoles]] call dro_spawnGroupWeighted;	
						if (!isNil "_reinfGroup") then {
							_return pushBack _reinfGroup;
							[_reinfGroup, _reinfVeh] spawn sun_groupToVehicle;
							// Find land for disembark waypoint
							_dir = [_targetPos, _spawnPos] call BIS_fnc_dirTo;
							_checkPos = _targetPos;
							_landPos = [];
																	
							_lastPos = [];
							while {(_targetPos distance _checkPos) < (_targetPos distance _spawnPos)} do {				
								_checkPos = [_checkPos, 50, _dir] call BIS_fnc_relPos;			
								if (surfaceIsWater _checkPos) exitWith {
									_landPos = _lastPos;
								};
								_lastPos = _checkPos;
							};
							
							if (count _landPos > 0) then {
								_checkPos = _landPos;
								_lastPos = [];
								while {(_checkPos distance _landPos) < 100} do {				
									_checkPos = [_checkPos, 5, _dir+180] call BIS_fnc_relPos;								
									if (surfaceIsWater _checkPos) exitWith {
										_landPos = _lastPos;
									};
									_lastPos = _checkPos;
								};
							};						
							
							private _vWP0 = _reinfGroup addWaypoint [_spawnPos, 0];
							_vWP0 setWaypointCompletionRadius 10;
							_vWP0 setWaypointBehaviour "CARELESS";
							_vWP0 setWaypointCombatMode "GREEN";
							_vWP0 setWaypointSpeed "NORMAL";
							_vWP0 setWaypointType "MOVE";
							
							if (count _landPos > 0) then {	
								private _vWP1 = _reinfGroup addWaypoint [_landPos, 0];
								_vWP1 setWaypointCompletionRadius 100;
								_vWP1 setWaypointType "GETOUT";
								_vWP1 setWaypointBehaviour "AWARE";
								_vWP1 setWaypointCombatMode "RED";
							} else {
								private _vWP1 = _reinfGroup addWaypoint [_checkPos, 0];
								_vWP1 setWaypointCompletionRadius 100;
								_vWP1 setWaypointType "GETOUT";
								_vWP1 setWaypointBehaviour "AWARE";
								_vWP1 setWaypointCombatMode "RED";
							};

							private _vWP2 = _reinfGroup addWaypoint [_targetPos, 0];						
							_vWP2 setWaypointType "MOVE";
							diag_log format ["REINFORCEMENT: Naval group %1 spawned at %2; inserting at %3", _reinfGroup, _spawnPos, _targetPos];
						};										
					};
				};
			};		
		};			
	};
};
_return