// Find suitable posision
params ["_sector"];
_thisPos = [getPos _sector, 0, ((triggerArea _sector) select 0), 5, 0, 0.5, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
if (_thisPos isEqualTo [0,0,0]) then {
	_thisPos = [getPos _sector, 0, ((triggerArea _sector) select 0)*4, 5, 0, 0.5, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;				
};	
_thisPos set [2, 0];

// Create area marker
_markerName = format["areaMkr%1", floor(random 10000)];
_markerArea = createMarker [_markerName, _thisPos];
_markerArea setMarkerShape "ELLIPSE";
_markerArea setMarkerBrush "Grid";
_markerArea setMarkerColor markerColorPlayers;
_markerArea setMarkerSize [100, 100];
_markerArea setMarkerAlpha 1;	

// Create Task
_taskName = format ["task%1", floor(random 100000)];
_taskTitle = "Await Support";
_taskDesc = format ["Clear <marker name='%1'>marked area</marker> and await supply drop.", _markerName];
	
// Create triggers
_trgAreaClear = createTrigger ["EmptyDetector", _thisPos, true];
_trgAreaClear setTriggerArea [100, 100, 0, false];
_trgAreaClear setTriggerActivation ["ANY", "PRESENT", false];
_trgAreaClear setTriggerStatements [
	"		
		(({(side _x == (thisTrigger getVariable 'side')) && ((lifeState _x == 'HEALTHY') OR (lifeState _x == 'INJURED'))} count thisList) <= 0) &&
		({vehicle _x in thisList} count allPlayers) > 0
	",
	"				
		(thisTrigger getVariable 'markerName') setMarkerAlpha 0;
		[thisTrigger] execVM 'sunday_system\objectives\supportCrate.sqf';
	", 
	""];			
_trgAreaClear setTriggerTimeout [5, 8, 10, true];
_trgAreaClear setVariable ["side", enemySide];	
_trgAreaClear setVariable ["markerName", _markerName];	
_trgAreaClear setVariable ["thisTask", _taskName];	

_markerPos = getMarkerPos _markerName;
_id = [_taskName, true, [_taskDesc, _taskTitle, _markerName], [(_markerPos select 0), (_markerPos select 1), 0], "CREATED", 1, true, true, "rearm", true] call BIS_fnc_setTask;
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];	
//taskIDs pushBack _id;
//diag_log ["DRO: taskIDs is now: %1", taskIDs];