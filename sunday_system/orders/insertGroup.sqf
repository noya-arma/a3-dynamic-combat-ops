params ["_vehicle", "_insertGroup", "_pos", "_return", "_delete", "_heliInsertType", "_startPos"];

_startPos = getPos _vehicle;
_safePos = if (_vehicle isKindOf "Helicopter") then {
	_areaPos = [_pos,0,200,3,1,1,0,[],[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
	_result = [];
	if !(_areaPos isEqualTo [0,0,0]) then {
		_result = _areaPos;
	} else {
		_result = _pos;
	};
	_result
} else {
	_nearRoads = (_pos nearRoads 200);
	_roadPos = (_pos nearRoads 200) select 0;
	_result = [];
	if (count _nearRoads > 0) then {
		_result = (_nearRoads select 0);
	} else {
		_areaPos = [_pos,0,200,3,1,1,0,[],[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
		if !(_areaPos isEqualTo [0,0,0]) then {
			_result = _areaPos;
		} else {
			_result = _pos;
		}; 
	};
	_result
};

[_insertGroup, _vehicle, true] call sun_groupToVehicle;

while {(count (waypoints (_vehicle) )) > 0} do {
   deleteWaypoint ((waypoints (_vehicle) ) select 0);
};
while {(count (waypoints (_insertGroup) )) > 0} do {
   deleteWaypoint ((waypoints (_insertGroup) ) select 0);
};

_vehGroup = (group (driver _vehicle));
_vehicle setVariable ["assignedGroup", _insertGroup];

if (_vehicle isKindOf "Helicopter") then {
	
	_heliDestination = [_safePos, 2000, ([(getPos _vehicle), _safePos] call BIS_fnc_dirTo)] call dro_extendPos;
	_heliDestination set [2, 300];
	
	_vehicle flyInHeight 300;
	if (!isNil "_heliInsertType") then {		
		if (toUpper _heliInsertType == "LAND") then {
			_vehicle flyInHeight 40;
			_heliDestination set [2, 40];
		};
	};	
	
	private _vWP0 = _vehGroup addWaypoint [(getPos _vehicle), 0];	
	_vWP0 setWaypointBehaviour "CARELESS";
	_vWP0 setWaypointCombatMode "GREEN";
	_vWP0 setWaypointSpeed "NORMAL";
	_vWP0 setWaypointType "MOVE";
	
	private _vWP1 = _vehGroup addWaypoint [_heliDestination, 0];
	_vWP1 setWaypointType "MOVE";

	waitUntil {_vehicle distance _safePos < 500};
		
	if (!isNil "_heliInsertType") then {		
		if (toUpper _heliInsertType == "LAND") then {
			_vehicle land "GET OUT";
			waitUntil {((getPosATL _vehicle) select 2) < 2};
			{				
				unassignVehicle _x;
				_x action ['GetOut', (objectParent _x)];			
			} forEach (units _insertGroup);
			waitUntil {{_x in _vehicle} count (units _insertGroup) == 0};
		} else {
			{			
				removeBackpackGlobal _x;
				_x addBackpackGlobal "B_Parachute";
				sleep 1;
				unassignVehicle _x;
				_x action ['Eject', (objectParent _x)];			
			} forEach (units _insertGroup);
		};
	} else {
		{			
			removeBackpackGlobal _x;
			_x addBackpackGlobal "B_Parachute";
			sleep 1;
			unassignVehicle _x;
			_x action ['Eject', (objectParent _x)];			
		} forEach (units _insertGroup);
	};	
	
	//[_insertGroup, _safePos, 200] call BIS_fnc_taskPatrol;
	[_insertGroup, _safePos] call BIS_fnc_taskAttack;
	
		
} else {
	
	private _vWP0 = _vehGroup addWaypoint [(getPos _vehicle), 0];
	_vWP0 setWaypointCompletionRadius 10;
	_vWP0 setWaypointBehaviour "CARELESS";
	_vWP0 setWaypointCombatMode "GREEN";
	_vWP0 setWaypointSpeed "NORMAL";
	_vWP0 setWaypointType "MOVE";

	private _vWP1 = _vehGroup addWaypoint [_safePos, 0];
	//_vWP1 setWaypointCompletionRadius 170;
	_vWP1 setWaypointType "MOVE";
	_vWP1 setWaypointBehaviour "AWARE";
	_vWP1 setWaypointCombatMode "RED";
	_vWP1 setWaypointStatements ["true", "	
		{	
			unassignVehicle _x;
			doGetOut _x;
		} forEach (units ((vehicle this) getVariable 'assignedGroup'));
		[((vehicle this) getVariable 'assignedGroup'), (getPos this)] call BIS_fnc_taskAttack;	
	"];	
};

if (!isNil "_return") then {
	//sleep 20;
	if (_return) then {		
		private _vWPReturn = _vehGroup addWaypoint [_startPos, 0];		
		_vWPReturn setWaypointType "MOVE";
		if (!isNil "_delete") then {
			if (_delete) then {
				_vWPReturn setWaypointStatements ["true", "					
					deleteVehicle (vehicle this);
				"];
			};
		};		
	} else {
		[_vehGroup, _safePos, 200] call bis_fnc_taskPatrol;
	};
};

