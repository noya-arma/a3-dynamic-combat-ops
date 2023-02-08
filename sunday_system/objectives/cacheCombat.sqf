// Destroy cache
_sectorIndex = -1;
_thisPos = [];
private _styles = [];
if (count AO_flatPositions > 0) then {
	_styles pushBack "OUTSIDE";
};
if (count AO_buildingPositions > 0) then {
	_styles pushBack "INSIDE";
};

if (count _styles == 0) exitWith {
	diag_log "DCO: No valid cache styles found!";
};

private _style = selectRandom _styles;
_spawnedObjects = [];
switch (_style) do {
	case "OUTSIDE": {
		_thisPos = [AO_flatPositions] call sun_selectRemove;
		_sectorIndex = [_thisPos] call dco_closestSectorIndex;
		diag_log format ["_sectorIndex = %1", _sectorIndex];
		_targetArray = if (395180 in (getDLCs 1)) then {
			["Box_Syndicate_WpsLaunch_F", "Box_Syndicate_Wps_F", "Box_IED_Exp_F", "Box_FIA_Ammo_F", "Box_FIA_Support_F", "Box_FIA_Wps_F"]
		} else {
			["Box_FIA_Ammo_F", "Box_FIA_Support_F", "Box_FIA_Wps_F"]
		};
		for "_i" from 1 to ([1,3] call BIS_fnc_randomInt) step 1 do {	
			_thisTarget = selectRandom _targetArray;
			_targetPos = _thisPos findEmptyPosition [1, 15, _thisTarget];
			if (count _targetPos > 0) then {
				_object = createVehicle [_thisTarget, _targetPos, [], 0, "CAN_COLLIDE"];
				_object = [_object] call sun_checkVehicleSpawn;
				if (!isNil "_object") then {
					_spawnedObjects pushBack _object;
					_object setDir (random 360);
				};
			};
		};
	};
	case "INSIDE": {
		_building = [AO_buildingPositions] call sun_selectRemove;
		_thisPos = getPos _building;
		_buildingClass = typeOf _building;		
		_buildingPos = getPos _building;
		_sectorIndex = [_thisPos] call dco_closestSectorIndex;
		diag_log format ["_sectorIndex = %1", _sectorIndex];
		// Populate building
		_buildingPositions = [_building] call BIS_fnc_buildingPositions;
		_buildingPositionsShuffled = _buildingPositions call BIS_fnc_arrayShuffle;
		_buildingDir = getDir _building;

		_targetArray = ["Box_Syndicate_WpsLaunch_F", "Box_Syndicate_Wps_F", "Box_IED_Exp_F"];		
		_infCount = 0;
		_totalInf = 6 * aiMultiplier;		
		{
			if ((count _spawnedObjects) < 3) then {
				_thisTarget = selectRandom _targetArray;
				_object = createVehicle [_thisTarget, _x, [], 0, "CAN_COLLIDE"];		
				if (!isNil "_object") then {
					_spawnedObjects pushBack _object;
					_object setDir (selectRandom [_buildingDir, _buildingDir+90]);
				};
			} else {	
				if (_infCount < _totalInf) then {
					_group = [_x, enemySide, eInfClassesForWeights, eInfClassWeights, [1,1]] call dro_spawnGroupWeighted;
					_unit = ((units _group) select 0);									
					if (!isNil "_unit") then {
						_unit setUnitPos "UP";
						_infCount = _infCount + 1;
					};					
				};
			};		
		} forEach _buildingPositionsShuffled;
	};
};

if (count _spawnedObjects == 0) exitWith {
	diag_log "DCO: No valid cache object positions found";	
};

// Spawn enemies to guard
_minAI = 3 * aiMultiplier;
_maxAI = 5 * aiMultiplier;
_spawnedSquad = [_thisPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI,_maxAI]] call dro_spawnGroupWeighted;				
if (!isNil "_spawnedSquad") then {					
	[_spawnedSquad, _thisPos, [10, 30], "limited"] execVM "sunday_system\orders\patrolArea.sqf";	
	if (_sectorIndex > -1) then {
		(dcoSectorTroops select _sectorIndex) pushBack _spawnedSquad;
	};
};

// Marker
_markerName = format ["cacheMkr%1", random 10000];
_markerBuilding = createMarker [_markerName, _thisPos];
_markerBuilding setMarkerShape "ICON";
_markerBuilding setMarkerType "mil_destroy";
_markerBuilding setMarkerSize [1, 1];
_markerBuilding setMarkerColor markerColorEnemy;
_markerBuilding setMarkerAlpha 0;

// Create task
_taskName = format ["task%1", floor(random 10000)];
_taskTitle = "Destroy Cache";
_taskDesc = format ["Destroy the %1 cache at the marked <marker name='%2'>location</marker>.",enemyFactionName, _markerName];
_taskType = "destroy";
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];

// Create trigger				
_trgComplete = createTrigger ["EmptyDetector", _thisPos, true];
_trgComplete setTriggerArea [0, 0, 0, false];
_trgComplete setTriggerActivation ["ANY", "PRESENT", false];
_trgComplete setTriggerStatements [
	"
		{
			if (!alive _x) exitWith {
				true
			};
		} forEach (thisTrigger getVariable 'objects');					
	",
	"	
		{
			if (alive _x) then {
				_x setDamage 1;
			};
		} forEach (thisTrigger getVariable 'objects');	
		[(thisTrigger getVariable 'thisTask'), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
		missionNamespace setVariable [format ['%1Completed', (thisTrigger getVariable 'thisTask')], 1, true];
	", 
	""];
_trgComplete setVariable ["objects", _spawnedObjects];
_trgComplete setVariable ["thisTask", _taskName];

allObjectives pushBack _taskName;
objData pushBack [
	_taskName,
	_taskDesc,
	_taskTitle,
	_markerName,
	_taskType,
	_thisPos
];
diag_log format ["DRO: Task created: %1, %2", _taskTitle, _taskName];
diag_log format ["DRO: objData: %1", objData];
diag_log format ["DRO: allObjectives is now %1", allObjectives];