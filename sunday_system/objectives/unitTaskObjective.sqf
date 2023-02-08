params ["_thisTask"];

[_thisTask] spawn {
	_thisTask = _this select 0;
	_taskName = format ["task%1", floor(random 100000)];
	missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];
	_object = vehicle (leader (_thisTask select 0));
	_groupStrength = count (units (_thisTask select 0));	
	
	// Create trigger
	if (_object == (leader (_thisTask select 0))) then {
		// Trigger if leader is not inside a vehicle
		private _trgClear = createTrigger ["EmptyDetector", getPos _object, true];
		_trgClear setTriggerArea [50, 50, 0, false];
		_trgClear setTriggerActivation ["ANY", "PRESENT", false];
		_trgClear setTriggerStatements [
			"				
				(({alive _x} count (units (thisTrigger getVariable 'group'))) <= ((thisTrigger getVariable 'groupStrength') * 0.2))
			",
			"						
				[(thisTrigger getVariable 'thisTask'), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
				missionNamespace setVariable [format ['%1Completed', (thisTrigger getVariable 'thisTask')], 1, true];
			", 
			""
		];				
		_trgClear setVariable ["group", (_thisTask select 0)];			
		_trgClear setVariable ["groupStrength", _groupStrength];			
		_trgClear setVariable ["thisTask", _taskName];	
	} else {
		// Trigger if leader is inside a vehicle
		_groupVehicles = [];
		{
			if (vehicle _x != _x) then {
				_groupVehicles pushBackUnique (vehicle _x);
			};
		} forEach (units (_thisTask select 0));
		private _trgClear = createTrigger ["EmptyDetector", getPos _object, true];
		_trgClear setTriggerArea [50, 50, 0, false];
		_trgClear setTriggerActivation ["ANY", "PRESENT", false];
		_trgClear setTriggerStatements [
			"				
				(({alive _x} count (thisTrigger getVariable 'groupVehicles')) == 0) OR (({(count (crew _x) > 0)} count (thisTrigger getVariable 'groupVehicles')) == 0)
			",
			"						
				[(thisTrigger getVariable 'thisTask'), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
				missionNamespace setVariable [format ['%1Completed', (thisTrigger getVariable 'thisTask')], 1, true];
			", 
			""
		];				
		_trgClear setVariable ["groupVehicles", _groupVehicles];							
		_trgClear setVariable ["thisTask", _taskName];	
	};
	
	// Wait for target reveal
	waitUntil {
		sleep 5;
		(playersSide knowsAbout _object) > 2
	};	
	
	// Marker
	_markerName = format["taskMkr%1", floor(random 100000)];
	_markerTask = createMarker [_markerName, getPos _object];
	_markerTask setMarkerShape "ICON";	
	_markerTask setMarkerAlpha 0;	
	
	// Create task	
	_taskTitle = format ["Eliminate %1", toLower (_thisTask select 1)];
	_taskDesc = format ["Eliminate the %1", toLower (_thisTask select 1)];
	_id = "";
	if ((missionNamespace getVariable (format ["%1Completed", _taskName])) == 0) then {
		_id = [_taskName, true, [_taskDesc, _taskTitle, _markerName], _object, "CREATED", 1, true, true, "target", true] call BIS_fnc_setTask;
	} else {
		_id = [_taskName, true, [_taskDesc, _taskTitle, _markerName], _object, "SUCCEEDED", 1, true, true, "target", true] call BIS_fnc_setTask;
	};		
	//taskIDs pushBack _id;
	//diag_log ["DCO: taskIDs is now: %1", taskIDs];		
};