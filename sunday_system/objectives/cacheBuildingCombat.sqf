// Destroy building

// Find a random building in the area
_building = [AO_buildingPositions] call dro_selectRemove;
_buildingClass = typeOf _building;		
_buildingPos = getPos _building;

// Find this sector
_sectorIndex = [_thisPos] call dco_closestSectorIndex;
diag_log format ["_sectorIndex = %1", _sectorIndex];

// Populate building
_buildingPositions = [_building] call BIS_fnc_buildingPositions;
_buildingPositionsShuffled = _buildingPositions call BIS_fnc_arrayShuffle;
_buildingDir = getDir _building;

_targetArray = if (395180 in (getDLCs 1)) then {
	["Box_Syndicate_WpsLaunch_F", "Box_Syndicate_Wps_F", "Box_IED_Exp_F", "Box_FIA_Ammo_F", "Box_FIA_Support_F", "Box_FIA_Wps_F"]
} else {
	["Box_FIA_Ammo_F", "Box_FIA_Support_F", "Box_FIA_Wps_F"]
};
_spawnedObjects = [];
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

if (count _spawnedObjects == 0) exitWith {
	diag_log "DRO: No valid building cache object positions found";
};

// Spawn enemies to guard the building
_minAI = 2 * aiMultiplier;
_maxAI = 5 * aiMultiplier;
_spawnedSquad2 = [getPos _building, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI]] call dro_spawnGroupWeighted;				
if (!isNil "_spawnedSquad2") then {
	[_spawnedSquad2, getPos _building, 100] call bis_fnc_taskPatrol;
	if (_sectorIndex > -1) then {
		(dcoSectorTroops select _sectorIndex) pushBack _spawnedSquad;
	};
};
// Marker
_markerName = format ["structureMkr%1", random 10000];
_markerBuilding = createMarker [_markerName, _buildingPos];
_markerBuilding setMarkerShape "ICON";
_markerBuilding setMarkerType "mil_destroy";
_markerBuilding setMarkerSize [1, 1];
_markerBuilding setMarkerColor markerColorEnemy;
_markerBuilding setMarkerAlpha 0;

// Create task
_taskName = format ["task%1", floor(random 10000)];
_taskTitle = "Destroy Cache";
_buildingName = ((configFile >> "CfgVehicles" >> _buildingClass >> "displayName") call BIS_fnc_GetCfgData);
_taskDesc = format ["Destroy the %1 cache in the %2 at the marked <marker name='%3'>location</marker>.",enemyFactionName, _buildingName, _markerName];
_taskType = "destroy";
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];

// Create trigger				
_trgComplete = createTrigger ["EmptyDetector", _buildingPos, true];
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
	_buildingPos
];
diag_log format ["DRO: Task created: %1, %2", _taskTitle, _taskName];
diag_log format ["DRO: objData: %1", objData];
diag_log format ["DRO: allObjectives is now %1", allObjectives];