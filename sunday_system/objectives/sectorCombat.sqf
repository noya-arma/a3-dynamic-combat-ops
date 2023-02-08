_thisSector = [dcoSectorsForTasks] call sun_selectRemove;

_thisSectorPos = getPos _thisSector;
_sectorLetter = _thisSector getVariable "sectorLetter";
_markerName = _thisSector getVariable "marker";

_taskName = format ["task%1", floor(random 100000)];

_taskTitle = format ["Take Sector %1", _sectorLetter];
_taskDesc = format ["Attack and hold <marker name='%1'>sector %3</marker> held by %2 troops.", _markerName, enemyFactionName, _sectorLetter];		

allObjectives pushBack _taskName;
objData pushBack [
	_taskName,
	_taskDesc,
	_taskTitle,
	_markerName,
	_sectorLetter,
	_thisSectorPos
];
diag_log format ["DRO: Task created: %1, %2", _taskTitle, _taskName];
diag_log format ["DRO: objData: %1", objData];
diag_log format ["DRO: allObjectives is now %1", allObjectives];