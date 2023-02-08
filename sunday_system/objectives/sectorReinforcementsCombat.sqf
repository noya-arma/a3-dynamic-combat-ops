params ["_thisSector"];
_thisSectorPos = getPos _thisSector;
_sectorLetter = _thisSector getVariable "sectorLetter";
_markerName = _thisSector getVariable "marker";

_reinfGroups = [_thisSectorPos, [2,3], eReinfPos, ["INFANTRY"]] call fnc_reinfForTask;

waitUntil {count _reinfGroups > 0};

[[playersSide, "HQ"], (format ["We have reports that an enemy force is moving on sector %1 to retake it. Hold and defend your position.", _sectorLetter])] remoteExec ["sideChat", 0];

_taskName = format ["task%1", floor(random 100000)];
_taskTitle = format ["Hold Sector %1", _sectorLetter];
_taskDesc = format ["Hold <marker name='%1'>sector %3</marker> and repel incoming reinforcements.", _markerName, enemyFactionName, _sectorLetter];		

_markerPos = getMarkerPos _markerName;
_id = [_taskName, group u1, [_taskDesc, _taskTitle, _markerName], [(_markerPos select 0), (_markerPos select 1), 0], "CREATED", 1, true, true, "defend", true] call BIS_fnc_setTask;		
taskIDs pushBack _id;
diag_log ["DRO: taskIDs is now: %1", taskIDs];

// Unpack units from reinforcement groups
_reinfUnits = [];
{
	{
		_reinfUnits pushBack _x;
	} forEach units _x;
} forEach _reinfGroups;
_totalEnemies = count _reinfUnits;
/*
// Failsafe trigger
_trgFailsafe = [objNull, _markerName] call BIS_fnc_triggerToMarker;
_trgFailsafe setTriggerActivation ["ANY", "PRESENT", false];
_trgFailsafe setTriggerStatements [
	"
		(time > startTime + 120) &&	
		(({(side _x == (thisTrigger getVariable 'side')) && ((lifeState _x == 'HEALTHY') OR (lifeState _x == 'INJURED'))} count thisList) <= 0)
	",
	"		
		[(thisTrigger getVariable 'thisTask'), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;		
	", 
	""];			
_trgFailsafe setTriggerTimeout [5, 8, 10, true];
_trgFailsafe setVariable ["side", enemySide];	
_trgFailsafe setVariable ["startTime", time];	
_trgFailsafe setVariable ["thisTask", _taskName];	
*/
// Wait for majority of reinforcements to be dead
_startTime = time;
waitUntil {
	sleep 5;
	//hint format ["Start time: %1\nCurrent time: %2\nTimeout: %3\nUnits in marker: %4", _startTime, time, _startTime + 200, ({alive _x && _x inArea _markerName} count _reinfUnits)];
	({alive _x} count _reinfUnits) < (_totalEnemies * 0.2) || ((time > _startTime + 300) && (({alive _x && _x inArea _markerName} count _reinfUnits) == 0))
};

[_id, 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;

