// Destroy Artillery emplacement
_thisPos = [AO_flatPositions] call sun_selectRemove;

// Find this sector
_sectorIndex = [_thisPos] call dco_closestSectorIndex;
diag_log format ["_sectorIndex = %1", _sectorIndex];
_tempPos = [(_thisPos select 0), (_thisPos select 1), 0];
_thisPos = _tempPos;

_vehicleType = [enemyAAPool] call sun_selectRemove;
		
// Marker
_markerName = format["artMkr%1", floor(random 10000)];
_markerArty = createMarker [_markerName, _thisPos];
_markerArty setMarkerShape "ICON";
_markerArty setMarkerType  "o_art";
_markerArty setMarkerColor markerColorEnemy;
_markerArty setMarkerAlpha 0;	

// Create Task		
_artyName = ((configFile >> "CfgVehicles" >> _vehicleType >> "displayName") call BIS_fnc_GetCfgData);

_taskName = format ["task%1", floor(random 100000)];
_taskTitle = "Destroy AA";
_taskDesc = format ["Destroy the %3 %1 AA emplacement at the <marker name='%2'>marked location</marker>.", _artyName, _markerName, enemyFactionName];
_taskType = "destroy";
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];

_numVehicles = [1,3] call BIS_fnc_randomInt;
_targets = [];
for "_i" from 1 to _numVehicles step 1 do {
	_safePos = [_thisPos, 0, 30, 5, 0, 1, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
	if !(_safePos isEqualTo [0,0,0]) then {				
		_thisVeh = _vehicleType createVehicle _safePos;
		[_thisVeh] call sun_createVehicleCrew;		
		_thisVeh disableAI "MOVE";
		_targets pushBack _thisVeh;
	};	
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
_randItems = [4,10] call BIS_fnc_randomInt;
_itemsArray = [
	"Land_CargoBox_V1_F",
	"Land_Cargo10_grey_F",
	"Land_Cargo10_military_green_F",
	"CargoNet_01_barrels_F",
	"CargoNet_01_box_F",
	"Land_MetalBarrel_F",
	"Land_PaperBox_closed_F",
	"Land_PaperBox_open_empty_F",
	"Land_PaperBox_open_full_F",
	"Land_Pallet_MilBoxes_F",
	"Land_Pallets_F",
	"Land_Pallet_F"			
];
for "_i" from 1 to _randItems do {
	_itemPos = [_thisPos, 8, 20, 1, 0, 1, 0] call BIS_fnc_findSafePos;
	_thisItem = selectRandom _itemsArray;
	[_thisItem, _itemPos, (random 360)] call dro_createSimpleObject;
};

// Create a bunker object and spawn enemies to guard it
_netPos = [_thisPos, 10, 40, 5, 0, 10, 0] call BIS_fnc_findSafePos;
	
_net = "CamoNet_INDP_big_F" createVehicle _netPos;
_net setDir (random 360);
_minAI = 3 * aiMultiplier;
_maxAI = 5 * aiMultiplier;
_spawnedSquad = [_netPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI]] call dro_spawnGroupWeighted;		
if (!isNil "_spawnedSquad") then {	
	[_spawnedSquad, _netPos] call bis_fnc_taskDefend;		
	if (_sectorIndex > -1) then {		
		(dcoSectorTroops select _sectorIndex) pushBack _spawnedSquad;
	};	
};

if (isNil "AATasks") then {
	AATasks = [_taskName];
} else {
	AATasks pushBack _taskName;
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