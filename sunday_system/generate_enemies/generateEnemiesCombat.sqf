// *****
// SETUP ENEMIES
// *****

fnc_createInf = {
	params ["_pos", "_numInf"];
	_numInfMin = _numInf select 0;
	_numInfMax = _numInf select 1;
	_numInf = [_numInfMin, _numInfMax] call BIS_fnc_randomInt;
		_return = [];
	_numInf = _numInf * aiMultiplier;
	for "_infIndex" from 1 to _numInf step 1 do {
		_infPosition = [_pos, 0, 200, 2, 0, -1, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;		
		_spawnedSquad = nil;
		if !(_infPosition isEqualTo [0,0,0]) then {				
			_minAI = round (4 * aiMultiplier);
			_maxAI = round (6 * aiMultiplier);
			_spawnedSquad = [_infPosition, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI]] call dro_spawnGroupWeighted;				
			waitUntil {!isNil "_spawnedSquad"};
			_return pushBack _spawnedSquad;				
			[_spawnedSquad, _pos, [0,(sectorSize/2)], "LIMITED"] execVM "sunday_system\orders\patrolArea.sqf";				
			_spawnedSquad setCombatMode "GREEN";			
			if (_debug == 1) then {
				_garMarker = createMarker [format["garMkr%1", random 10000], _infPosition];
				_garMarker setMarkerShape "ICON";
				_garMarker setMarkerColor "ColorOrange";
				_garMarker setMarkerType "mil_dot";
				_garMarker setMarkerText format ["Patrol %1", _spawnedSquad];
			};			
		};
	};
	_return
};
_debug = 0;

_numPlayers = count allPlayers;

_enemyIntelMarkers = [];
enemyAlertableGroups = [];
enemySemiAlertableGroups = [];

// Roadblocks
_numRoadblocks = [5,7] call BIS_fnc_randomInt;
roadTasks = [];
for "_x" from 1 to _numRoadblocks do {
	if (count roadblockPosArray > 0) then {
		_roadPosition = [roadblockPosArray] call dro_selectRemove; 
		
		// Get road direction
		_roadList = _roadPosition nearRoads 50;
		_thisRoad = _roadList select 0;
		_roadConnectedTo = roadsConnectedTo _thisRoad;
		if (count _roadConnectedTo == 0) exitWith {_bunker = "Land_BagBunker_Small_F" createVehicle _roadPosition;};
		_connectedRoad = _roadConnectedTo select 0;
		_direction = [_thisRoad, _connectedRoad] call BIS_fnc_DirTo;
		
		_styles = ["ROADBLOCK", "BARRIER"];
		if (minesEnabled == 0) then {_styles pushBack "MINES"};
		_style = selectRandom _styles;
		switch (_style) do {
			case "ROADBLOCK": {				
				_objects = selectRandom compositionsRoadblocks;
				diag_log format ["spawned objects: %1", _objects];
				diag_log format ["_direction: %1", _direction];
				_spawnedObjects = [_roadPosition, _direction, _objects] call BIS_fnc_ObjectsMapper;
				diag_log format ["spawned objects: %1", _spawnedObjects];
				// Collect guard positions
							
				_guardPositions = [];		
				{
					if (typeOf _x == "Sign_Arrow_Blue_F") then {
						_spawnPos = getPos _x;
						_dir = getDir _x;				
						_guardPositions pushBack [_spawnPos, _dir];				
						deleteVehicle _x;			
					};
				} forEach _spawnedObjects;
				/*
				_garMarker = createMarker [format["garMkr%1", random 10000], _roadPosition];
				_garMarker setMarkerShape "ICON";
				_garMarker setMarkerColor "ColorOrange";
				_garMarker setMarkerType "mil_dot";				
				*/
				// Spawn guards at guard positions
				_leader = nil;
				_leaderChosen = 0;				
				_totalRoadInf = round (4 * aiMultiplier);				
				_roadInfCount = 0;
				{
					_spawnPos = (_x select 0) findEmptyPosition [0,10];
					if (count _spawnPos > 0) then {
						if (_roadInfCount < _totalRoadInf) then {
							_guardGroup = [_spawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [1,1]] call dro_spawnGroupWeighted;
							if (!isNil "_guardGroup") then {	
								_guardUnit = ((units _guardGroup) select 0);					
								_guardUnit setFormDir (_x select 1);
								_guardUnit setDir (_x select 1);
								
								if (_leaderChosen == 0) then {
									_leader = _guardUnit;
									_leaderChosen = 1;
								} else {
									[_guardUnit] joinSilent _leader;
									doStop _guardUnit;
								};
								_roadInfCount = _roadInfCount + 1;
							};
						};
					};
				} forEach _guardPositions;				
				roadTasks pushBack ["ROADBLOCK", _roadPosition, (group _leader)];	
								
			};
			case "BARRIER": {				
				_objects = selectRandom compositionsBarriers;
				_spawnedObjects = [_roadPosition, _direction, _objects] call BIS_fnc_ObjectsMapper;				
				_spawnPos = _roadPosition findEmptyPosition [0,10];
				if (count _spawnPos > 0) then {
				_guardGroup = [_spawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [4,6]] call dro_spawnGroupWeighted;
					if (!isNil "_guardGroup") then {	
						[_guardGroup, _roadPosition] call BIS_fnc_taskDefend;					
						//roadTasks pushBack ["BARRIER", _roadPosition, _spawnedObjects];					
					};
				};
			};
			case "MINES": {			
						
				_roadsToUse = [_thisRoad, 3] call sun_findRoadRoute;
				if (count _roadsToUse > 1) then {
					_direction = [(_roadsToUse select 0), (_roadsToUse select 1)] call BIS_fnc_DirTo;
					_minePositions = [];
					{				
						if (_forEachIndex < (count _roadsToUse - 1)) then {
							_direction = [_x, (_roadsToUse select (_forEachIndex + 1))] call BIS_fnc_DirTo;
						};
						
						_incrementedPos0 = [getPos _x, 4, (_direction + 180)] call BIS_fnc_relPos;
						_incrementedPos1 = getPos _x;
						_incrementedPos2 = [getPos _x, 4, _direction] call BIS_fnc_relPos;
						
						{
							_spawnPos = [_x, 2, (_direction + (selectRandom [-90, 90]))] call BIS_fnc_relPos;
							_minePositions pushBack _spawnPos;
						} forEach [_incrementedPos0, _incrementedPos1, _incrementedPos2];					
						
					} forEach _roadsToUse;
					
					_mines = [];
					{
						switch (_forEachIndex) do {
							case 0: {
								["Land_Sign_WarningUnexplodedAmmo_F", _x, _direction] call dro_createSimpleObject;
							};
							case ((count _minePositions)-1): {
								["Land_Sign_WarningUnexplodedAmmo_F", _x, _direction+180] call dro_createSimpleObject;
							};							
							default {
								_mine = "ATMine_Range_Ammo" createVehicle _x;						
								_mines pushBack _mine;
							};
						};
						
					} forEach _minePositions;
					roadTasks pushBack ["MINES", getPos _thisRoad, _mines];											
				};				
			};
		};			
	};
};

//_groundVehicles = eTankClasses + eCarTurretClasses;

{
	_thisSectorIndex = _forEachIndex;	
	diag_log format ["DCO: Generating enemies for sector %1", _thisSectorIndex+1];
	// Infantry patrols
	_infGroups = [getPos _x, [round (1 * aiMultiplier), round (2 * aiMultiplier)]] call fnc_createInf;
	{(dcoSectorTroops select _thisSectorIndex) pushBack _x} forEach _infGroups;
	
	// Vehicle patrol
	if (count enemyGVPool > 0) then {
		_numVehicles = [round (1 * aiMultiplier), round (2 * aiMultiplier)] call BIS_fnc_randomInt;
		_vehGroup = createGroup enemySide;		
		for "_vehIndex" from 1 to _numVehicles step 1 do {
			_vehType = [enemyGVPool] call sun_selectRemove;
			_vehPositionRough = [getPos _x, 0, (sectorSize/2), 2, 0, 0.3, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
			if !(_vehPositionRough isEqualTo [0,0,0]) then {
				_vehPosition = _vehPositionRough findEmptyPosition [0, 50, _vehType];
				if (count _vehPosition > 0) then {					
					_veh = createVehicle [_vehType, _vehPosition, [], 0, "NONE"];			
					[_veh] call sun_createVehicleCrew;
					waitUntil {!isNull (driver _veh)};
					(units (group (driver _veh))) joinSilent _vehGroup;
				};
			};			
		};
		[_vehGroup, getPos _x, [0,(sectorSize/2)], "LIMITED"] execVM "sunday_system\orders\patrolArea.sqf";
		_vehGroup setCombatMode "GREEN";
		if (random 1 > 0.5) then {
			unitTasks pushBack [_vehGroup, "VEHICLES"];
		};
		(dcoSectorTroops select _thisSectorIndex) pushBack _vehGroup;
	} else {
		_infGroups = [getPos _x, [1,2]] call fnc_createInf;
		{(dcoSectorTroops select _thisSectorIndex) pushBack _x} forEach _infGroups;
	};
	
	// Garrisons
	_nearHouses = nearestObjects [getPos _x, ["House"], (sectorSize/2)];
	_buildingsPresent = (count _nearHouses);
	if (_buildingsPresent > 0) then {
		_maxBuildings = 5;
		if (_buildingsPresent <= 20) then {
			_maxBuildings = ceil(_buildingsPresent * 0.15);		
		} else {
			if (_buildingsPresent <= 30) then {
				_maxBuildings = ceil(_buildingsPresent * 0.25);			
			} else {
				_maxBuildings = 10;			
			};		
		};	
		_buildings = [];
		{
			_thisBuilding = _x;
			if ((count([_thisBuilding] call BIS_fnc_buildingPositions)) >= 2) then {						
				_buildings pushBack _thisBuilding;	
			};		
		} forEach _nearHouses;	
		for "_buildingIndex" from 1 to _maxBuildings step 1 do {
			if (count _buildings > 0) then {
				_thisBuilding = [_buildings] call sun_selectRemove;
				_group = [_thisBuilding] call dro_spawnEnemyGarrison;
				(dcoSectorTroops select _thisSectorIndex) pushBack _group;
				_group setCombatMode "GREEN";
			};
		};
	};	
} forEach dcoSectors;

if (count AO_flatPositions > 0) then {
	for "_i" from 1 to ([(((count AO_flatPositions)-1) min 2), (((count AO_flatPositions)-1) min 4)] call BIS_fnc_randomInt) step 1 do {
		_thisPos = [AO_flatPositions] call sun_selectRemove;
		_spawnedObjects = [_thisPos, (random 360), (selectRandom compositionsEmplacements)] call BIS_fnc_ObjectsMapper;
		_minAI = round (4 * aiMultiplier);
		_maxAI = round (6 * aiMultiplier);
		_guardGroup = [_thisPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI]] call dro_spawnGroupWeighted;
		waitUntil {!isNil "_guardGroup"};		
		[_guardGroup, _thisPos],  call BIS_fnc_taskDefend;				
		_staticClasses = eMortarClasses + eStaticClasses;
		_staticType = selectRandom _staticClasses;
		if (count _staticClasses > 0) then {			
			for "_s" from 1 to ([1, 2] call BIS_fnc_randomInt) step 1 do {
				_staticPosition = _thisPos findEmptyPosition [0, 10, _staticType];
				if (count _staticPosition > 0) then {					
					_veh = createVehicle [_staticType, _staticPosition, [], 0, "NONE"];			
					[_veh] call sun_createVehicleCrew;
					waitUntil {!isNull (gunner _veh)};
					(units (group (gunner _veh))) joinSilent _guardGroup;
				};
			};
		};
		unitTasks pushBack [_guardGroup, "EMPLACEMENT"];		
	};
};



