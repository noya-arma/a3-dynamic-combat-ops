// Destroy Artillery emplacement
_thisPos = [AO_flatPositions] call sun_selectRemove;
_sectorIndex = [_thisPos] call dco_closestSectorIndex;
diag_log format ["_sectorIndex = %1", _sectorIndex];
_tempPos = [(_thisPos select 0), (_thisPos select 1), 0];
_thisPos = _tempPos;

_vehicleList = eTankClasses + eCarClasses;
_vehicleType = selectRandom _vehicleList;
		
// Marker
_markerName = format["motorMkr%1", floor(random 10000)];
_markerArty = createMarker [_markerName, _thisPos];
_markerArty setMarkerShape "ICON";
_markerArty setMarkerType  "o_art";
_markerArty setMarkerColor markerColorEnemy;
_markerArty setMarkerAlpha 0;	

// Create Task
_taskName = format ["task%1", floor(random 100000)];
_taskTitle = "Destroy Motor Pool";
_taskDesc = format ["Destroy the %3 motor pool at the <marker name='%2'>marked location</marker>.", _markerName, enemyFactionName];
_taskType = "destroy";
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];

_numVehicles = [3,5] call BIS_fnc_randomInt;
_dir = random 360;
_lastPos = _thisPos;
_targets = [];
for "_i" from 1 to _numVehicles step 1 do {
	_pos = [_lastPos, 6, _dir + 90] call BIS_fnc_relPos;
	_lastPos = _pos;
	_isFlat = !(_pos isFlatEmpty [6, -1, 0.3, 10, -1] isEqualTo []);
	if (_isFlat) then {
		_thisVeh = _vehicleType createVehicle _pos;
		_thisVeh setDir _dir;
		_targets pushBack _thisVeh;
	};
	// Fortifications
	switch (_i) do {
		case 1: {
			_fortStartPos = [_pos, 12, _dir + 225] call BIS_fnc_relPos;
			_fort1Pos = [_fortStartPos, 3, _dir] call BIS_fnc_relPos;
			_fort2Pos = [_fortStartPos, 3, _dir+90] call BIS_fnc_relPos;
			_fort1 = ["Land_HBarrier_5_F", _fort1Pos, _dir+90] call dro_createSimpleObject;
			_fort2 = ["Land_HBarrier_5_F", _fort2Pos, _dir] call dro_createSimpleObject;
		};
		case _numVehicles: {
			_fortStartPos = [_pos, 12, _dir + 135] call BIS_fnc_relPos;
			_fort1Pos = [_fortStartPos, 3, _dir] call BIS_fnc_relPos;
			_fort2Pos = [_fortStartPos, 3, _dir+270] call BIS_fnc_relPos;
			_fort1 = ["Land_HBarrier_5_F", _fort1Pos, _dir+90] call dro_createSimpleObject;
			_fort2 = ["Land_HBarrier_5_F", _fort2Pos, _dir] call dro_createSimpleObject;
		};
		default {
			_fortPos = [_pos, 8.25, _dir + 180] call BIS_fnc_relPos;			
			_fort = ["Land_HBarrier_5_F", _fortPos, _dir] call dro_createSimpleObject;
		};
	};	
};

if (count _targets == 0) exitWith {
	[] call fnc_generateCombatObjective;	
};

// Success Trigger
private _trgKilled = createTrigger ["EmptyDetector", _thisPos, true];
_trgKilled setTriggerArea [1, 1, 0, true];
_trgKilled setTriggerActivation ["ANY", "PRESENT", false];
_trgKilled setTriggerStatements [
	"
		({alive _x} count (thisTrigger getVariable ('targets'))) <= 0
	",
	"				
		[(thisTrigger getVariable ('thisTask')), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
		missionNamespace setVariable [format ['%1Completed', (thisTrigger getVariable ('thisTask'))], 1, true];
	", 
	""];
_trgKilled setVariable ["thisTask", _taskName];		
_trgKilled setVariable ["targets", _targets];	


/*
// Create fortifications
_dir = direction _thisVeh;
_rotation = (_dir - 45);
for "_i" from 1 to 4 do {
	_cornerPos = [getPos _thisVeh, 16, _dir] call dro_extendPos;
	_corner = ["Land_HBarrierWall_corner_F", _cornerPos, _rotation] call dro_createSimpleObject;
	_dir = _dir + 90;
	_rotation = _rotation + 90;
};
*/

_minAI = 3 * aiMultiplier;
_maxAI = 5 * aiMultiplier;
_spawnedSquad = [_thisPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI]] call dro_spawnGroupWeighted;		
if (!isNil "_spawnedSquad") then {
	[_spawnedSquad, _thisPos] call bis_fnc_taskDefend;
	if (_sectorIndex > -1) then {
		(dcoSectorTroops select _sectorIndex) pushBack _spawnedSquad;
	};	
};

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