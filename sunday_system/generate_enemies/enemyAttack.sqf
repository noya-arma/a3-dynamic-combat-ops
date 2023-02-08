params ["_reinforcePos", "_targetPos"];

_styles = [];
if (count enemyGVPool > 0) then {
	if (!surfaceIsWater _reinforcePos) then {	
		_styles pushBack "GROUND";
	};	
};
if (count enemyHeliPool > 0) then {
	_styles pushBack "AIRHELI";
};
if (count enemyPlanePool > 0) then {
	_styles pushBack "AIRPLANE";
};
if (count _styles > 0) then {
	switch (selectRandom _styles) do {
		case "GROUND": {
			_roadList = _reinforcePos nearRoads 300;				
			_spawnPos = if (count _roadList > 0) then {
				_thisRoad = (selectRandom _roadList);
				getPos _thisRoad				
			} else {
				_reinforcePos
			};		
			if ((({(_spawnPos distance _x) < 600} count (units (grpNetId call BIS_fnc_groupFromNetId)) == 0))) then {			
				_numVehicles = [round (1 * aiMultiplier), round (2 * aiMultiplier)] call BIS_fnc_randomInt;
				_vehGroup = createGroup enemySide;		
				for "_vehIndex" from 1 to _numVehicles step 1 do {
					_vehType = [enemyGVPool] call sun_selectRemove;
					_vehPosition = _spawnPos findEmptyPosition [0, 50, _vehType];
					if (count _vehPosition > 0) then {					
						_veh = createVehicle [_vehType, _vehPosition, [], 0, "NONE"];			
						[_veh] call sun_createVehicleCrew;
						waitUntil {!isNull (driver _veh)};
						(units (group (driver _veh))) joinSilent _vehGroup;
					};						
				};
				[_vehGroup, _targetPos] spawn BIS_fnc_taskAttack;				
				[[_vehGroup, "VEHICLES"]] call fnc_unitTaskObjective;
				diag_log format ["DCO: Spawning enemy ground attack wave: %1", _vehGroup];
			};		
		};
		case "AIRHELI": {
			_spawnPos = _reinforcePos;
			_spawnPos set [2, 300];					
			_vehType = [enemyHeliPool] call sun_selectRemove;	
			_reinfVeh = createVehicle [_vehType, _spawnPos, [], 0, "FLY"];		
			_reinfVeh setPos _spawnPos;
			[_reinfVeh] call sun_createVehicleCrew;
			waitUntil {!isNull (driver _reinfVeh)};
			[(group (driver _reinfVeh)), _targetPos] spawn BIS_fnc_taskAttack;				
			[[(group (driver _reinfVeh)), "VEHICLES"]] call fnc_unitTaskObjective;
			diag_log format ["DCO: Spawning enemy helicopter attack wave: %1", (group (driver _reinfVeh))];			
		};
		case "AIRPLANE": {
			_spawnPos = _reinforcePos;
			_spawnPos set [2, 1500];					
			_vehType = [enemyPlanePool] call sun_selectRemove;	
			_reinfVeh = createVehicle [_vehType, _spawnPos, [], 0, "FLY"];		
			_reinfVeh setPos _spawnPos;
			[_reinfVeh] call sun_createVehicleCrew;
			waitUntil {!isNull (driver _reinfVeh)};
			[(group (driver _reinfVeh)), _targetPos] spawn BIS_fnc_taskAttack;				
			[[(group (driver _reinfVeh)), "VEHICLES"]] call fnc_unitTaskObjective;
			diag_log format ["DCO: Spawning enemy plane attack wave: %1", (group (driver _reinfVeh))];	
		};
	};
};