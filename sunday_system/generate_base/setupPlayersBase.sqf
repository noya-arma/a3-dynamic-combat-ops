_customStart = false;
startPos = [];
baseHelipads = [];

{	
	if (isObjectHidden _x) then {		
		deleteVehicle _x;
		diag_log format ["DRO: Deleting unit %1", _x];
	};
} forEach (units(grpNetId call BIS_fnc_groupFromNetId));

if (count customBasePos == 0) then {
	diag_log "No custom base position found, will generate random.";
	startPos = [];
} else {
	diag_log "Custom base position found.";
	startPos = customBasePos;	
	_customStart = true;
};

if (count startPos == 0) then {
	startPos = [center, (aoSize*2), (aoSize*3), 10, 0, 0.25, 0, [trgAOC], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
};
_newPos = [];
if !(startPos isEqualTo [0,0,0]) then {
	for "_i" from 0 to 19 step 1 do {		
		_newPos = (startPos isFlatEmpty [3, -1, 0.25, 50, 0, false]);
		_posFound = true;
		if (count _newPos == 0) then {
			_posFound = false;
		};
		if (count (nearestTerrainObjects [startPos, ["TREE", "HOUSE"], 30, false, true]) > 0) then {
			_posFound = false;
		};
		if (_posFound) exitWith {
			_newPos
		};
	};
};
if (count _newPos == 0) then {
	startPos = [center, (aoSize*2), (aoSize+10000), 10, 0, 0.25, 0, [trgAOC], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;				
};
if !(startPos isEqualTo [0,0,0]) then {
	for "_i" from 0 to 19 step 1 do {		
		_newPos = (startPos isFlatEmpty [3, -1, 0.25, 50, 0, false]);
		_posFound = true;
		if (count _newPos == 0) then {
			_posFound = false;
		};
		if (count (nearestTerrainObjects [startPos, ["TREE", "HOUSE"], 30, false, true]) > 0) then {
			_posFound = false;
		};
		if (_posFound) exitWith {
			_newPos
		};
	};
};

//if ((count customBasePos == 0)) then {_newPos = []};
if ((count _newPos == 0) && (count customBasePos == 0)) exitWith {	
	diag_log "DCO: Could not find a valid base location!";		
	["sunday_system\dialogs\selectBaseFailsafe.sqf"] remoteExec ["execVM", topUnit];
};

startPos = _newPos;

publicVariable "startPos";
eReinfPos = ([center, 2000, ([startPos, center] call BIS_fnc_dirTo)] call BIS_fnc_relPos);
pReinfPos = ([startPos, 1000, ([center, startPos] call BIS_fnc_dirTo)] call BIS_fnc_relPos);

_largeBunkers = ["Land_BagBunker_Large_F", "Land_BagBunker_Tower_F"];
_smallBunkers = ["Land_BagBunker_Small_F", "Land_Bunker_F"];
_largeCargo = switch (selectRandom ["Green", "Brown"]) do {
	case "Green": {["Land_Cargo_House_V1_F", "Land_Cargo_HQ_V1_F"]};
	case "Brown": {["Land_Cargo_House_V3_F", "Land_Cargo_HQ_V3_F"]};
};
_smallCargo = switch (selectRandom ["Green", "Brown"]) do {
	case "Green": {["Land_Cargo_House_V1_F", "Land_Cargo_Patrol_V1_F"]};
	case "Brown": {["Land_Cargo_House_V3_F", "Land_Cargo_Patrol_V3_F"]};
};

_mainOrientation = 0;

//_obj = createVehicle [(selectRandom _largeCargo), startPos, [], 0, "CAN_COLLIDE"];
//_obj setDir _mainOrientation;

_grid = [startPos, 3, 3, 15] call sun_defineGrid;
trgBase = createTrigger ["EmptyDetector", startPos, true];
trgBase setTriggerArea [30, 30, 0, true];
trgBase setTriggerActivation ["ANY", "PRESENT", false];
trgBase setTriggerStatements ["","",""];

//_grid deleteAt 4;
_cornerDir1 = 0;
_cornerDir2 = 90;
_edgeDir1 = 0;
_edgeDir2 = 90;
_dirOut = 225;
_numHelipads = 0;
_gridSorted = [(_grid select 0), (_grid select 3), (_grid select 6), (_grid select 7), (_grid select 8), (_grid select 5), (_grid select 2), (_grid select 1)];
/*
{
	_mkr = createMarker [(format ["mkrGrid%1",_forEachIndex]), _x];
	_mkr setMarkerShape "ICON";
	_mkr setMarkerType "mil_dot";
	_mkr setMarkerText (str _forEachIndex);
} forEach _gridSorted;
*/
["Land_HelipadRescue_F", startPos, 0] call dro_createSimpleObject;

{
	_thisGridPos = _x;
	if (_forEachIndex == 0 || _forEachIndex == 2 || _forEachIndex == 4 || _forEachIndex == 6) then {
		// CORNER
		if ((random 1)>0.66) then {
			// Spawn building
			_class = (selectRandom _smallCargo);
			_dir = 0;
			_spawnPos = _thisGridPos;
			if (["house", _class] call BIS_fnc_inString) then {
				_dir = _dirOut;
			} else {
				if (["hq", _class] call BIS_fnc_inString) then {
					_dir = (_dirOut-90);
					_spawnPos = [_thisGridPos, 8, _dirOut] call BIS_fnc_relPos;
				} else {
					_dir = (_dirOut+180);					
				};				
			};
			
			_obj = createVehicle [_class, _spawnPos, [], 0, "CAN_COLLIDE"];
			_obj setDir _dir;		
			
			
			_dimensions = sizeOf _class;
			_barrierPos = [_thisGridPos, (_dimensions/2), _dirOut-135] call dro_extendPos;			
			["Land_HBarrier_5_F", _barrierPos, _cornerDir1] call dro_createSimpleObject;
			_barrierPos2 = [_thisGridPos, (_dimensions/2), _dirOut+135] call dro_extendPos;			
			["Land_HBarrier_5_F", _barrierPos2, _cornerDir2] call dro_createSimpleObject;
			
		} else {
			// Spawn corner walls
			_dirTo = ([startPos, _thisGridPos] call BIS_fnc_dirTo);
			
			// Walls
			for "_barrier1" from 0 to 2 step 1 do {
				_dist = (3*_barrier1)+2;
				_barrierPos = [_thisGridPos, _dist, _cornerDir1] call dro_extendPos;			
				["Land_HBarrier_3_F", _barrierPos, _cornerDir1+90] call dro_createSimpleObject;
			};			
			for "_barrier2" from 0 to 2 step 1 do {
				_dist = (3*_barrier2)+2;
				_barrierPos = [_thisGridPos, _dist, _cornerDir2] call dro_extendPos;			
				["Land_HBarrier_3_F", _barrierPos, _cornerDir2+90] call dro_createSimpleObject;
			};
			// Corner posts
			if ((random 1)>0.5) then {
				_postPos = [_thisGridPos, 2, _dirTo] call dro_extendPos;
				_obj = createVehicle ["Land_LampHalogen_F", _postPos, [], 0, "CAN_COLLIDE"];
				_obj setDir (_dirTo-90);				
			};			
		};
		_cornerDir1 = _cornerDir1 - 90;
		_cornerDir2 = _cornerDir2 - 90;		
	};
	
	if (_forEachIndex == 3) then {		
		_obj = createVehicle ["B_Slingload_01_Medevac_F", _thisGridPos, [], 0, "CAN_COLLIDE"];
		[_obj] call sun_medicBox;
		_obj setDir _dirOut+90;	
		_dimensions = sizeOf "Land_Medevac_house_V1_F";		
	};
	
	if (_forEachIndex == 5 || _forEachIndex == 7) then {		
		// EDGE		
		if ((random 1)>0.66) then {
			// Spawn building					
			_class = (selectRandom _smallCargo);
			_dir = 0;
			_spawnPos = _thisGridPos;
			if (["house", _class] call BIS_fnc_inString) then {
				_dir = _dirOut;
			} else {
				if (["hq", _class] call BIS_fnc_inString) then {
					_dir = (_dirOut-90);
					_spawnPos = [_thisGridPos, 8, _dirOut] call BIS_fnc_relPos;
				} else {
					_dir = (_dirOut+180);					
				};				
			};
			
			_obj = createVehicle [_class, _spawnPos, [], 0, "CAN_COLLIDE"];
			_obj setDir _dir;		
			
			_dimensions = sizeOf _class;
			_barrierPos = [_thisGridPos, (_dimensions/2), _dirOut-90] call dro_extendPos;			
			["Land_HBarrier_1_F", _barrierPos, _edgeDir1] call dro_createSimpleObject;
			_barrierPos2 = [_thisGridPos, (_dimensions/2), _dirOut+90] call dro_extendPos;			
			["Land_HBarrier_1_F", _barrierPos2, _edgeDir1] call dro_createSimpleObject;
			
		};
		_edgeDir1 = _edgeDir1 - 90;					
	};
	
	if (_forEachIndex == 1) then {
		// ENTRANCE		
	};
	
	// Create helipads	
	//if (_numHelipads < 3) then {
		_helipadPos = [_thisGridPos, 30, _dirOut] call dro_extendPos;
		_safePos = [_helipadPos, 0, 10, 10, 0, 0.2, 0, [trgAOC], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
		if !(_safePos isEqualTo [0,0,0]) then {
			_obj = createVehicle ["Land_HelipadCircle_F", _safePos, [], 0, "CAN_COLLIDE"];
			baseHelipads pushBack _obj;
			_numHelipads = _numHelipads + 1;
		};
	//};	
	
	_dirOut = _dirOut - 45;
	
} forEach _gridSorted;

// Create new units
newUnitsReady = false;
[startPos] remoteExec ["sun_newUnits", s1];
waitUntil {newUnitsReady};
groupPlayers = (grpNetId call BIS_fnc_groupFromNetId);
sleep 1;

// Recreate tasks
if (count objData > 0) then {
	{	
		_markerPos = getMarkerPos (_x select 3);
		//BIS_fnc_deleteTask
		_id = [(_x select 0), true, [(_x select 1), (_x select 2), (_x select 3)], [(_markerPos select 0), (_markerPos select 1), 0], "CREATED", 1, false, true, (_x select 4), true] call BIS_fnc_setTask;		
		//taskIDs pushBack _id;
		//diag_log format ["DRO: taskIDs is now: %1", taskIDs];	
		[(_x select 5), (_x select 0)] execVM "sunday_system\objectives\addTaskExtras.sqf";
	} forEach objData;
};

missionNameSpace setVariable ["playersReady", 1, true];

// Redefine grpNetId in case any mods cause groups to change
grpNetId = (group u1) call BIS_fnc_netId;
publicVariable "grpNetId";

// Supply crates
_resupplyPos = [startPos, 12, 90] call BIS_fnc_relPos;
_resupply = "B_supplyCrate_F" createVehicle _resupplyPos;
[_resupply, (grpNetId call BIS_fnc_groupFromNetId)] call sun_supplyCrate;
["AmmoboxInit", [_resupply, true]] spawn BIS_fnc_arsenal;

// Refit trigger
[startPos, 50, playersSide] spawn sun_refitTrigger;

deleteMarker "campMkr";
_campNames = ["Mockingbird", "Bluejay", "Cormorant", "Heron", "Albatross", "Hornbill", "Osprey", "Kingfisher", "Nuthatch"];
_campName = format ["FOB %1", selectRandom _campNames];
missionNameSpace setVariable ["publicCampName", _campName];
publicVariable "publicCampName";
markerBase = createMarker ["campMkr", startPos];
markerBase setMarkerShape "ICON";
markerBase setMarkerColor markerColorPlayers;
markerBase setMarkerType "loc_Bunker";
markerBase setMarkerSize [3, 3];
markerBase setMarkerText _campName;

if ((paramsArray select 0) < 3) then {	
	respawnFOB = [missionNamespace, "campMkr", _campName] call BIS_fnc_addRespawnPosition;
};

{
	[_x, true] remoteExec ["allowDamage", _x, true];	
	_x enableGunLights "forceon";
	if (!isPlayer _x) then {	
		[_x] call sun_addResetAction;
	};
} forEach (units (grpNetId call BIS_fnc_groupFromNetId));

(leader (grpNetId call BIS_fnc_groupFromNetId)) createDiarySubject ["reset", "Reset AI units"];
(leader (grpNetId call BIS_fnc_groupFromNetId)) createDiaryRecord ["reset", ["Reset AI units", "<br /><font size='20' face='PuristaBold'>Reset AI Units</font><br /><br />Reset AI functions have moved! They can now be found by selecting the stuck unit using F1-10 and opening command menu 6."]];


if (reviveDisabled < 3) then {
	diag_log "DRO: Revive enabled";
	[(grpNetId call BIS_fnc_groupFromNetId)] execVM "sunday_revive\initRevive.sqf";
};

if (isMultiplayer) then {
	// If respawn is enabled add the dynamic team respawn position
	if ((paramsArray select 0) < 3) then {	
		[] execVM 'sunday_system\teamRespawnPos.sqf';
		diag_log format ["DRO: Respawn time = %1", respawnTime];
		{		
			respawnTime remoteExec ["setPlayerRespawnTime", _x, true];				
		} forEach allPlayers;
	};	
	{
		if (!isPlayer _x) then {		
			// Add eventhandlers to govern respawning AI in MP games
			if ((paramsArray select 0) == 3) then {
				[_x, ["respawn", {
					_unit = (_this select 0);				
					deleteVehicle _unit
				}]] remoteExec ["addEventHandler", _x, true];
			} else {
				[_x, ["killed", {[(_this select 0)] execVM "sunday_system\fakeRespawn.sqf"}]] remoteExec ["addEventHandler", _x, true];
				[_x, ["respawn", {
					_unit = (_this select 0);				
					deleteVehicle _unit
				}]] remoteExec ["addEventHandler", _x, true];				
			};			
		};
		// Add player's side to spectator whitelist
		_x setVariable ["WhitelistedSides", [playersSideCfgGroups], true];
		_x setVariable ["AllowFreeCamera", true, true];
		_x setVariable ["AllowAi", true, true];
		_x setVariable ["Allow3PPCamera", true, true];
		_x setVariable ["ShowFocusInfo", true, true];
		_x setVariable ["ShowCameraButtons", true, true];		
		_x setVariable ["respawnLoadout", (getUnitLoadout _x), true];
		_x setVariable ["respawnPWeapon", [(primaryWeapon  _x), primaryWeaponItems _x], true];			
	} forEach (units (grpNetId call BIS_fnc_groupFromNetId));
};

hintSilent "";
// Remove arsenal backdrop objects
[] spawn {
	sleep 2;
	_backdropList = (getPos logicStartPos) nearObjects 20;
	_backdropList = _backdropList - (units(group u1));
	{
		deleteVehicle _x;	
	} forEach _backdropList;
};

// If MCC4 is present re-initialise it for new players
if (isClass (configFile >> "CfgPatches" >> "mcc_sandbox")) then {
	[] execVM "\mcc_sandbox_mod\init.sqf";
};

// Reboot HCC
if (!isNil ("IGIT_HCC_HCConverter")) then {[] spawn IGIT_HCC_HCConverter};
