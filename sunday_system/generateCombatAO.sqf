
aoSize = 1000;
sectorLetters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K"];
dcoSectors = [];
dcoSectorTroops = [];
_randomLoc = [];

// *****
// Primary AO location
// *****

if (getMarkerColor "aoSelectMkr" == "") then {
	diag_log "DRO: No custom AO position found, will generate random.";
	{
		deleteMarker _x;
	} forEach locMarkerArray;
	// Get a random location
	_size = worldSize;
	_worldCenter = (_size/2);
	_firstLocList = nearestLocations [[_worldCenter, _worldCenter], ["NameLocal","NameVillage","NameCity","NameCityCapital"], _size];
	_randomLoc = [_firstLocList] call dro_selectRemove;
	progressLoadingScreen 0.1;
	while {		
		(((getPos _randomLoc) select 0) < aoSize) ||
		(((getPos _randomLoc) select 1) < aoSize) ||
		(((getPos _randomLoc) select 0) > (_size-aoSize)) ||
		(((getPos _randomLoc) select 1) > (_size-aoSize)) ||
		(((getPos _randomLoc) distance logicStartPos) < 600)
		
	} do {
		_randomLoc = [_firstLocList] call dro_selectRemove;
	};
} else {
	diag_log "DRO: Custom AO position found.";
	_randomLoc = nearestLocation [getMarkerPos "aoSelectMkr", ""];
	"aoSelectMkr" setMarkerAlpha 0;
	{
		deleteMarker _x;
	} forEach locMarkerArray;
};

center = getPos _randomLoc;
publicVariable "center";
_locType = type _randomLoc;
_locName = text _randomLoc;
_briefLocType = "";
missionNameSpace setVariable ["aoCamPos", center, true];
missionNameSpace setVariable ["aoLocationName", _locName, true];

aoLocation = _randomLoc;
publicVariable "aoLocation";

gridX = 5;
gridY = 5;
sectorSize = 600;
_gridData = [center, gridX, gridY, sectorSize];

trgAOC = createTrigger ["EmptyDetector", center];
trgAOC setTriggerArea [(sectorSize * (gridX-1))*0.6, (sectorSize * (gridX-1))*0.6, 0, true];
if (!isMultiplayer) then {	
	trgAOC setTriggerActivation ["ANY", "PRESENT", false];
	trgAOC setTriggerStatements ["(vehicle player in thisList)", "saveGame", ""];
};
_markerCenter = createMarker ["centerMkr", center];
_markerCenter setMarkerShape "ICON";
_markerCenter setMarkerType "EmptyIcon";

// *****
// Create grid
// *****

_grid = _gridData call sun_defineGrid;
_tempGrid = _grid;
{
	if (surfaceIsWater _x) then {
		_tempGrid = _tempGrid - [_x];
	};
} forEach _grid;
_grid = _tempGrid;



// *****
// Select sectors
// *****
_tempSectors = [];
{
	_markerName = (format ["mkrSectorTemp%1", _forEachIndex]);
	private _sectorMarker = createMarker [_markerName, _x];
	_sectorMarker setMarkerShape "RECTANGLE";
	_sectorMarker setMarkerSize [sectorSize/2, sectorSize/2];
	_sectorMarker setMarkerBrush "Solid";	
	_sectorMarker setMarkerColor "ColorGreen";
	_sectorMarker setMarkerAlpha 0;
	_tempSectors pushBack _markerName;
} forEach _grid;
diag_log format ["DCO: _tempSectors = %1", _tempSectors];

// Primary positions
_primaryPositions = [center];
for "_i" from 0 to 7 step 1 do {
	_relPos = ([center, sectorSize-20, (_i * 45)] call BIS_fnc_relPos);
	_relPos set [2, 0];
	_primaryPositions pushBack _relPos;
};
diag_log format ["DCO: _primaryPositions = %1", _primaryPositions];

// Find valid primary sectors
_primaryPositionsTemp = _primaryPositions;
_primaryPositions = [];
_secondaryPositions = [];
{
	_thisSector = _x;
	_isPrimary = false;	
	// Check this sector against primary positions
	{
		_primaryPos = _x;
		if (_primaryPos inArea _thisSector) then {
			_isPrimary = true;			
		};
	} forEach _primaryPositionsTemp;
	
	if (_isPrimary) then {
		_primaryPositions pushBack (getMarkerPos _thisSector);		
	} else {
		_secondaryPositions pushBackUnique (getMarkerPos _thisSector);
	};
	
} forEach _tempSectors;	

/*
// Debug markers
{
	_markerName = (format ["mkrSectorTemp%1", (random 10000)]);
	private _sectorMarker2 = createMarker [_markerName, _x];
	_sectorMarker2 setMarkerShape "RECTANGLE";
	_sectorMarker2 setMarkerSize [sectorSize/2, sectorSize/2];
	_sectorMarker2 setMarkerBrush "Solid";	
	_sectorMarker2 setMarkerColor "ColorGreen";
	_sectorMarker2 setMarkerAlpha 0.4;	
} forEach _secondaryPositions;

{
	_markerNameLetter = (format ["mkrPrimary%1", (random 10000)]);
	private _sectorMarkerLetter = createMarker [_markerNameLetter, _x];
	_sectorMarkerLetter setMarkerShape "ICON";
	_sectorMarkerLetter setMarkerType "mil_dot";		
	_sectorMarkerLetter setMarkerColor "ColorGreen";	
} forEach _primaryPositions;
*/

_numSectors = [((count _primaryPositions) min 2), ((count _primaryPositions) min 3)] call BIS_fnc_randomInt;
diag_log format ["DCO: Total primary sectors = %1", _numSectors];

for "_i" from 0 to (_numSectors - 1) step 1 do {
	diag_log format ["count _primaryPositions = %1", count _primaryPositions];
	if (count _primaryPositions > 0) then {
		_thisSectorPos = [_primaryPositions] call sun_selectRemove;			
		if (!isNil "_thisSectorPos") then {			
			diag_log format ["_thisSectorPos = %1", _thisSectorPos];		
			if (count _thisSectorPos > 0) then {
				_taskLetter = sectorLetters deleteAt 0;	
				
				_markerName = (format ["mkrSector%1", (random 10000)]);
				private _sectorMarker = createMarker [_markerName, _thisSectorPos];
				_sectorMarker setMarkerShape "RECTANGLE";
				_sectorMarker setMarkerSize [sectorSize/2, sectorSize/2];
				_sectorMarker setMarkerBrush "Solid";
				_sectorMarker setMarkerColor markerColorEnemy;	
				_sectorMarker setMarkerAlpha 0.3;
				
				_markerName2 = (format ["mkrSector2%1", (random 10000)]);
				private _sectorMarker2 = createMarker [_markerName2, _thisSectorPos];
				_sectorMarker2 setMarkerShape "RECTANGLE";
				_sectorMarker2 setMarkerSize [sectorSize/2, sectorSize/2];
				_sectorMarker2 setMarkerBrush "Grid";
				_sectorMarker2 setMarkerColor markerColorEnemy;	
				_sectorMarker2 setMarkerAlpha 0.2;				
				
				_markerNameLetter = (format ["mkrSector%1", (random 10000)]);
				private _sectorMarkerLetter = createMarker [_markerNameLetter, _thisSectorPos];
				_sectorMarkerLetter setMarkerShape "ICON";
				_sectorMarkerLetter setMarkerType "o_unknown";
				_sectorMarkerLetter setMarkerText _taskLetter;
				_sectorMarkerLetter setMarkerSize [1,1];	
				_sectorMarkerLetter setMarkerColor markerColorEnemy;
				_sectorMarkerLetter setMarkerAlpha 1;
				
							
				//_taskName = format ["task%1", floor(random 100000)];	
				
				private _trgSector = createTrigger ["EmptyDetector", _thisSectorPos, true];
				_trgSector setTriggerArea [sectorSize/2, sectorSize/2, 0, true];
				_trgSector setTriggerActivation ["ANY", "PRESENT", false];
				_trgSector setTriggerStatements [
					"
						(missionNameSpace getVariable ['playersReady', 0] == 1) && 
						(({(side _x == enemySide) && (alive _x)} count thisList) <= (({(side _x == playersSide) && (alive _x)} count thisList)*0.35)) &&
						({(side _x == playersSide) && (alive _x)} count thisList) > 0
					",
					"				
						[thisTrigger] call dco_captureSector;						
					", 
					""];
				_trgSector setVariable ["marker", _sectorMarker];	
				_trgSector setVariable ["assignedGroups", [], true];
				_trgSector setVariable ["sectorLetter", _taskLetter, true];
				dcoSectors pushBack _trgSector;	
			};
		};
	};
};


// *****
// Secondary AO locations
// *****

_secondaryLocList = [];
{
	_thisLocList = nearestLocations [_x, ["NameLocal","NameVillage","NameCity","NameCityCapital"], (sectorSize/2)];
	if (count _thisLocList > 0) then {
		_secondaryLocList pushBack _x;
	} else {
		_listBuildings = _x nearObjects ["House", (sectorSize/2)];
		if (count _listBuildings >= 5) then {
			_secondaryLocList pushBack _x;
		};
	};
} forEach _secondaryPositions;

/*
if (count _filteredLocList == 0) then {
	_filteredBestPlaces = [];
	{
		_secondaryBestPlaces = selectBestPlaces [_x, (sectorSize/2), "houses - 2*hills", 20, 1];
		if (((_secondaryBestPlaces select 0) select 1) >= 1) then {
			_location = createLocation ["NameLocal", (_x select 0), 100, 100];
			_filteredLocList pushBack _location;
		};
	} forEach _secondaryGrid;
};*/

_numSecondaryLocs = [1, 2] call BIS_fnc_randomInt;
diag_log format ["DCO: Total secondary sectors = %1", _numSecondaryLocs];
if (_numSecondaryLocs > 0) then {
	for "_i" from 1 to _numSecondaryLocs step 1 do {
		
		_thisSectorPos = [];
		if (count _secondaryLocList > 0) then {
			_thisSectorPos = [_secondaryLocList] call sun_selectRemove;
		} else {
			_thisSectorPos = [_secondaryPositions] call sun_selectRemove;
		};		
		if (count _thisSectorPos > 0) then {	
			_taskLetter = sectorLetters deleteAt 0;
			
			_markerName = (format ["mkrSector%1", (random 10000)]);
			private _sectorMarker = createMarker [_markerName, _thisSectorPos];
			_sectorMarker setMarkerShape "RECTANGLE";
			_sectorMarker setMarkerSize [sectorSize/2, sectorSize/2];
			_sectorMarker setMarkerBrush "Solid";
			_sectorMarker setMarkerColor markerColorEnemy;	
			_sectorMarker setMarkerAlpha 0.3;
			
			_markerName2 = (format ["mkrSector2%1", (random 10000)]);
			private _sectorMarker2 = createMarker [_markerName2, _thisSectorPos];
			_sectorMarker2 setMarkerShape "RECTANGLE";
			_sectorMarker2 setMarkerSize [sectorSize/2, sectorSize/2];
			_sectorMarker2 setMarkerBrush "Grid";
			_sectorMarker2 setMarkerColor markerColorEnemy;	
			_sectorMarker2 setMarkerAlpha 0.2;				
			
			_markerNameLetter = (format ["mkrSector%1", (random 10000)]);
			private _sectorMarkerLetter = createMarker [_markerNameLetter, _thisSectorPos];
			_sectorMarkerLetter setMarkerShape "ICON";
			_sectorMarkerLetter setMarkerType "o_unknown";
			_sectorMarkerLetter setMarkerText _taskLetter;
			_sectorMarkerLetter setMarkerSize [1,1];	
			_sectorMarkerLetter setMarkerColor markerColorEnemy;
			_sectorMarkerLetter setMarkerAlpha 1;
			
			//_taskName = format ["task%1", floor(random 100000)];	
			
			private _trgSector = createTrigger ["EmptyDetector", _thisSectorPos, true];
			_trgSector setTriggerArea [sectorSize/2, sectorSize/2, 0, true];
			_trgSector setTriggerActivation ["ANY", "PRESENT", false];
			_trgSector setTriggerStatements [
				"
					(missionNameSpace getVariable ['playersReady', 0] == 1) && 
					(({(side _x == enemySide) && (alive _x)} count thisList) <= (({(side _x == playersSide) && (alive _x)} count thisList)*0.2)) &&
					({(side _x == playersSide) && (alive _x)} count thisList) > 0
				",
				"				
					[thisTrigger] call dco_captureSector;				
				", 
				""];
			_trgSector setVariable ["marker", _sectorMarker];		
			_trgSector setVariable ["assignedGroups", [], true];
			_trgSector setVariable ["sectorLetter", _taskLetter, true];
			dcoSectors pushBack _trgSector;	
		};
	};
};

dcoSectorsForTasks = dcoSectors;

// Create array of road positions for roadblocks
_furthestSectors = [dcoSectors, [], {center distance _x}, "DESCEND", {}] call BIS_fnc_sortBy;
_furthestSector = _furthestSectors select 0;
_dist = center distance _furthestSector;
_allRoadPosTop = center nearRoads (_dist + 300);
_allRoadPosCut = center nearRoads _dist;
maxAODist = (_dist + 100);
publicVariable "maxAODist";

_allRoadPosValid = [];
{
	if !(_x in _allRoadPosCut) then {
		_allRoadPosValid pushBackUnique _x;
	};
} forEach _allRoadPosTop;

roadblockPosArray = [];
for "_i" from 1 to ((count _allRoadPosValid) min 10) step 1 do {
	_randRoad = [_allRoadPosValid] call dro_selectRemove;
	if (typeName _randRoad == "OBJECT") then {
		roadblockPosArray pushBack (getPos _randRoad);
	};
};
_rbTemp = [roadblockPosArray, 50] call sun_checkMinDist;
roadblockPosArray = _rbTemp;
diag_log format ["DRO: roadblockPosArray = %1", roadblockPosArray];
/*
{
	private _markerName = (format ["mkrRB%1", (random 10000)]);
	private _marker = createMarker [_markerName, _x];
	_marker setMarkerShape "ICON";
	_marker setMarkerType "mil_dot";		
	_marker setMarkerColor "ColorGreen";	
} forEach roadblockPosArray;
*/

// Find flat areas to use
// Not too close to each other and not too close to roads
AO_flatPositions = [];
{	
	_bestPlaces = selectBestPlaces [getPos _x, sectorSize/2, "meadow - 2*houses - hills - 2*sea", 10, 10];
	_bestPlacesPositions = [];
	{
		_bestPlacesPositions pushBack (_x select 0);
	} forEach _bestPlaces;
	_bestPlacesFiltered = [_bestPlacesPositions, 25] call sun_checkMinDist;
	diag_log format ["DCO: Sector %2 filtered flat places = %1", _bestPlacesFiltered, (_x getVariable 'sectorLetter')];
	if (count _bestPlacesFiltered > 0) then {
		{
			_thisPos = [_x, 0, 60, 3, 0, 0.3, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
			if !(_thisPos isEqualTo [0,0,0]) then {				
				if ((count (_thisPos nearRoads 20)) == 0) then {					
					AO_flatPositions pushBack _thisPos;					
				};				
			};
		} forEach _bestPlacesFiltered;
	};	
} forEach dcoSectors;
diag_log format ["DCO: AO_flatPositions = %1", count AO_flatPositions];

// Create array of valid buildings
AO_buildingPositions = [];
{
	_list = (getPos _x) nearObjects ["House", sectorSize/2];
	diag_log format ["DCO: Sector %2 building list = %1", _list, (_x getVariable 'sectorLetter')];
	if (count _list > 0) then {
		if (count _list > 10) then {
			_list = _list call BIS_fnc_arrayShuffle;
			_list = [_list, 11, (count _list)-1] call BIS_fnc_removeIndex;
		};		
		{
			_building = _x;	
			
			_buildingClass = typeOf _building;
			
			_continue = true;			
			if (!alive _building) then {	
				_continue = false;
			};
			if ((count([_building] call BIS_fnc_buildingPositions)) < 2) then {
				_continue = false;
			};			
			
			if (_continue) then {
				AO_buildingPositions pushBackUnique _building;				
			};
		} forEach _list;
	};
} forEach dcoSectors;
diag_log format ["DCO: AO_buildingPositions = %1", count AO_buildingPositions];

// Create list of close roads for scenery/waypoints
AO_sectorRoads = [];
{
	_sectorRoads = [];
	_list = (getPos _x) nearRoads (sectorSize/3);
	for "_r" from 1 to ((count _list) min 8) step 1 do {
		_sectorRoads pushBack ([_list] call sun_selectRemove);
	};
	diag_log format ["DCO: _sectorRoads = %1", _sectorRoads];
	for "_s" from 0 to (((count _sectorRoads)/2)-1) step 1 do {		
		_thisRoad = _sectorRoads select _s;
		_direction = [_thisRoad] call sun_getRoadDir;
		_dirChange = selectRandom [-90, +90];
		_spawnPos = [(getPos _thisRoad), 5, _direction+_dirChange] call BIS_fnc_relPos;
		
		_objects = selectRandom compositionsBarriers;
		_spawnedObjects = [_spawnPos, _direction+_dirChange, _objects] call BIS_fnc_ObjectsMapper;		
	};
} forEach dcoSectors;

{
	dcoSectorTroops set [_forEachIndex, []];
} forEach dcoSectors;

publicVariable "dcoSectors";
publicVariable "dcoSectorsForTasks";
