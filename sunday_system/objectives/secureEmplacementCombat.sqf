// Get routes on correct side of AO
_dirToStart = [(getPos trgAOC), startPos] call BIS_fnc_dirTo;
_dirMin = _dirToStart - 50;
_dirMax = _dirToStart + 50;

_availableRoute = [];
{	
	_thisDir = [(getPos trgAOC), (_x select 1)] call BIS_fnc_dirTo;
	if ((_thisDir > _dirMin) && ((_thisDir < _dirMax))) exitWith {
		_availableRoute pushBack _x;
	};
} forEach roadTasks;
roadTasks = roadTasks - _availableRoute;

diag_log format ["DCO: Secure Route Task route = %1", _availableRoute];

if (count _availableRoute > 0) then {
	
	_thisRoadTask = [_availableRoute] call sun_selectRemove;
	_thisStyle = _thisRoadTask select 0;
	_thisPos = _thisRoadTask select 1;
	_thisGroup = _thisRoadTask select 2;
	_descExtra = "";	
	
	_taskName = format ["task%1", floor(random 100000)];
	
	switch (_thisStyle) do {
		case "ROADBLOCK": {
			_descExtra = "Expect the route to be fortified and eliminate any enemy forces.";
			
			// Create trigger
			private _trgAreaClear = createTrigger ["EmptyDetector", _thisPos, true];
			_trgAreaClear setTriggerArea [50, 50, 0, false];
			_trgAreaClear setTriggerActivation ["ANY", "PRESENT", false];
			_trgAreaClear setTriggerStatements [
				"
						
					(({(side _x == (thisTrigger getVariable 'side')) && ((lifeState _x == 'HEALTHY') OR (lifeState _x == 'INJURED'))} count thisList) <= 0)
				",
				"						
					[(thisTrigger getVariable 'thisTask'), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
					missionNamespace setVariable [format ['%1Completed', (thisTrigger getVariable 'thisTask')], 1, true];
				", 
				""];			
			_trgAreaClear setTriggerTimeout [5, 8, 10, true];
			_trgAreaClear setVariable ["side", enemySide];			
			_trgAreaClear setVariable ["thisTask", _taskName];	
		};	
		case "MINES": {
			_descExtra = "Intel suggests the road has been mined. These mines must be disabled or detonated to make the route safe.";
			// Create trigger
			private _trgAreaClear = createTrigger ["EmptyDetector", _thisPos, true];
			_trgAreaClear setTriggerArea [50, 50, 0, false];
			_trgAreaClear setTriggerActivation ["ANY", "PRESENT", false];
			_trgAreaClear setTriggerStatements [
				"					
					({mineActive _x} count (thisTrigger getVariable 'mines')) <= 0
				",
				"				
					
					[(thisTrigger getVariable 'thisTask'), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
					missionNamespace setVariable [format ['%1Completed', (thisTrigger getVariable 'thisTask')], 1, true];
				", 
				""];			
			_trgAreaClear setTriggerTimeout [5, 8, 10, true];
			_trgAreaClear setVariable ["mines", _thisGroup, true];				
			_trgAreaClear setVariable ["thisTask", _taskName, true];	
		};
	};	
	
	// Marker
	_markerName = format["routeMkr%1", floor(random 10000)];
	_markerArty = createMarker [_markerName, _thisPos];
	_markerArty setMarkerShape "ICON";
	_markerArty setMarkerType  "o_art";	
	_markerArty setMarkerAlpha 0;	

	// Create Task			
	_taskTitle = "Secure Route";
	_taskDesc = format ["Secure the route into the AO at <marker name='%1'>marked location</marker>. %2", _markerName, _descExtra];	

	_markerPos = getMarkerPos _markerName;
	_id = [_taskName, true, [_taskDesc, _taskTitle, _markerName], [(_markerPos select 0), (_markerPos select 1), 0], "CREATED", 1, true, true, "Default", true] call BIS_fnc_setTask;
	missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];	
	//taskIDs pushBack _id;
	//diag_log ["DRO: taskIDs is now: %1", taskIDs];
	
} else {
	[] call fnc_generateCombatObjective;
};