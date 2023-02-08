sun_getCfgSide = {
	params ["_sideValue"];
	private _return = west;	
	if (typeName _sideValue == "TEXT") then {
		if ((["west", _sideValue, false] call BIS_fnc_inString)) then {
			_sideValue = 1;
		};
		if ((["east", _sideValue, false] call BIS_fnc_inString)) then {
			_sideValue = 0;
		};
		if ((["guer", _sideValue, false] call BIS_fnc_inString) || (["ind", _sideValue, false] call BIS_fnc_inString)) then {
			_sideValue = 2;
		};
	};			
	if (typeName _sideValue == "SCALAR") then {
		if (_sideValue <= 3 && _sideValue > -1) then {
			switch (_sideValue) do {
				case 0: {_return = east};
				case 1: {_return = west};
				case 2: {_return = resistance};
				case 3: {_return = civilian};
			};
		};	
	};	
	_return
};

sun_getCfgUnitSide = {
	params ["_configName"];
	private _return = west;
	_sideNum = (((configFile >> "CfgVehicles" >> _configName >> "side")) call BIS_fnc_GetCfgData);
	if (!isNil "_sideNum") then {
		if (typeName _sideNum == "TEXT") then {
			if ((["west", _sideNum, false] call BIS_fnc_inString)) then {
				_sideNum = 1;
			};
			if ((["east", _sideNum, false] call BIS_fnc_inString)) then {
				_sideNum = 0;
			};
			if ((["guer", _sideNum, false] call BIS_fnc_inString) || (["ind", _sideNum, false] call BIS_fnc_inString)) then {
				_sideNum = 2;
			};
		};			
		if (typeName _sideNum == "SCALAR") then {
			if (_sideNum <= 3 && _sideNum > -1) then {
				switch (_sideNum) do {
					case 0: {_return = east};
					case 1: {_return = west};
					case 2: {_return = resistance};
					case 3: {_return = civilian};
				};
			};	
		};
	};
	_return
};

sun_heliTransport = {
	params ["_heli", "_lzPos"];
	
	_heli setVariable ["transportSupporting", true, true];
	_heli enableAI "MOVE";
	
	_markerLZ = createMarker [(format ["mkrLZ%1", round(random 100000)]), _lzPos];						
	_markerLZ setMarkerShape "ICON";		
	_markerLZ setMarkerColor "ColorBlack";
	_markerLZ setMarkerType "mil_pickup";
	_markerLZ setMarkerText "Transport LZ";
	_markerLZ setMarkerSize [0.7, 0.7];
	
	_heliGroup = group (driver _heli);	
	
	/*	
	[_heli] spawn {
		waitUntil {!alive (_this select 0) OR !([(_this select 0)] call sun_helicopterCanFly)};
		[] remoteExec ["sun_playRadioRandom", 0];
		[[playersSide, "HQ"], (format ["We've just lost contact with %1, you'll need to extract on your own.", (_this select 0)])] remoteExec ["sideChat", 0];	
	};
	*/
	[] remoteExec ["sun_playRadioRandom", 0];
	[(driver _heli), (format ["This is %1, request received. Proceeding to grid %2.", _heli, mapGridPosition _lzPos])] remoteExec ["sideChat", 0];		
		
	while {(count (waypoints (_heli) )) > 0} do {
	   deleteWaypoint ((waypoints (_heli) ) select 0);
	};
	/*
	[_heli, _lzPos] spawn {
		waitUntil {(_this select 0) distance (_this select 1) < 300};
		(_this select 0) setCaptive true;
	};
	*/
	private _wp0 = _heliGroup addWaypoint [(getPos _heli), 0];	
	//_wp0 setWaypointBehaviour "CARELESS";
	//_wp0 setWaypointCombatMode "GREEN";
	_wp0 setWaypointSpeed "NORMAL";
	_wp0 setWaypointType "MOVE";	

	private _wpLand = _heliGroup addWaypoint [_lzPos, 0];
	_wpLand setWaypointType "MOVE";
	_wpLand setWaypointStatements ["TRUE", "vehicle this land 'GET IN'"];

	waitUntil {
		((_heli distance _lzPos) < 100) OR !([_heli] call sun_helicopterCanFly)
	};
		
	waitUntil {
		sleep 2;
		((getPos _heli) select 2) <= 3
	};
	
	_heli setVelocity [0, 0, 0];
	_heli disableAI "MOVE";
	
	deleteMarker _markerLZ;
	
	if (canMove _heli && alive _heli) then {
		_heli setVariable ["transportSupporting", false, true];
		[] remoteExec ["sun_playRadioRandom", 0];
		[(driver _heli), (format ["%1 now ready for transport tasking.", _heli])] remoteExec ["sideChat", 0];		
	};	
	
	//_heli setCaptive false;
	
};

sun_createVehicleCrew = {
	params ["_vehicle", ["_side", enemySide]];
	createVehicleCrew _vehicle;
	//waitUntil {count (crew _vehicle) > 0};	
	sleep 0.5;
	private _group = createGroup _side;
	(crew _vehicle) joinSilent _group;
};

sun_getTrueCargo = {
	private _allTurrets = ([_this select 0] call BIS_fnc_getTurrets);
	private _cargoTurretCount = {([_x >> "isPersonTurret"] call BIS_fnc_getCfgData) == 1} count _allTurrets;
	(_cargoTurretCount + ((configFile >> "CfgVehicles" >> (_this select 0) >> "transportSoldier") call BIS_fnc_GetCfgData))
};

sun_checkVehicleSpawn = {
	params [["_vehicle", objNull]];
	if (!isNull _vehicle) then {
		sleep 1;
		if (!alive _vehicle) then {
			_thisPos =  _thisPos findEmptyPosition [15, 200, _vehicleType];
			if (count _thisPos > 0) then {
				_vehicle = _vehicleType createVehicle _thisPos;
			} else {
				_vehicle = objNull;
			};	
		};
	};
	_vehicle
};

sun_stringCommaList = {
	params ["_strings"];
	_stringsCommas = "";	
	_stringsLast = "";
	if (count _strings > 1) then {
		_stringsLast = _strings call BIS_fnc_arrayPop;
		_stringsCommas = _strings joinString ", ";		
	} else {
		_stringsCommas = _strings select 0;
	};
	_stringsFull = if (count _stringsLast > 0) then {
		format ["%1 and %2", _stringsCommas, _stringsLast];
	} else {
		_stringsCommas
	};
	_stringsFull
};

sun_helicopterCanFly = {
	params ["_heli", "_return"];
	_return = true;
	
	if (alive _heli && alive (driver _heli)) then {
		_damageTypes = [
			["HitEngine",0.4],
			["HitHRotor",0.5],
			["HitVRotor",0.5],
			["HitTransmission",1.0],
			["HitHydraulics",0.9]
		];		
		{
			if (_heli getHitPointDamage (_x select 0) > (_x select 1)) exitWith {
				_return = false;
			};			
		} forEach _damageTypes;		  
	} else {
		_return = false;
	};
	_return
};

sun_checkRouteWater = {
	params ["_startPos", "_endPos", ["_returnLastLand", false]];

	_dir = [_startPos, _endPos] call BIS_fnc_dirTo;
	_checkPos = _startPos;
	_landPos = [];											
	_lastPos = [];
	_lastPosIsWater = false;
	_break = false;
	_return = false;
	while {(_startPos distance _checkPos) < (_startPos distance _endPos)} do {				
		_checkPos = [_checkPos, 50, _dir] call BIS_fnc_relPos;			
		if (surfaceIsWater _checkPos) then {
			if (_lastPosIsWater) then {
				_break = true;
				if (_returnLastLand) then {
					_return = _lastPos;
				} else {
					_return = true;
				};
			} else {
				_lastPosIsWater = true;
			};			
		} else {
			_lastPosIsWater = false;
		};
		if (_break) exitWith {};
		_lastPos = _checkPos;
	};
	_return
};

sun_assignTask = {
	params ["_taskData", ["_pushToArray", true], ["_addExtras", true]];	
	private _taskName = _taskData select 0;
	private _taskDesc = _taskData select 1;
	private _taskTitle = _taskData select 2;
	private _markerName = _taskData select 3;
	private _taskType = _taskData select 4;
	private _taskPos = _taskData select 5;
	private _reconChance = _taskData select 6;	
	private _subTasks = if (count _taskData > 7) then {_taskData select 7};	
	private _extraData = if (count _taskData > 8) then {_taskData select 8};	
	_createType = "CREATED";
	_completed = (missionNamespace getVariable [(format ["%1Completed", _taskName]), 0]);
	if (_completed == 1) then {
		_createType = "SUCCEEDED";
	};
	
	// Create task from task data
	diag_log "DRO: Assigning regular task";
	_markerPos = getMarkerPos _markerName;		
	_markerPos set [2,0];
	diag_log format ["DRO: Task %1 _markerPos = %2", _taskName, _markerPos];
	_id = [_taskName, true, [_taskDesc, _taskTitle, _markerName], _markerPos, _createType, 1, false, true, _taskType, true] call BIS_fnc_setTask;
	diag_log format ["DRO: Created task %1: %2", _taskName, _taskTitle];
	if (_pushToArray) then {
		taskIDs pushBackUnique _id;
		diag_log ["DRO: taskIDs is now: %1", taskIDs];
	};	
	if (_addExtras) then {
		[_taskPos, _taskName] execVM "sunday_system\objectives\addTaskExtras.sqf";				
	};
	if (markerShape _markerName == "ICON") then {_markerName setMarkerAlpha 0} else {_markerName setMarkerAlpha 0.5};
	if (!isNil "_subTasks") then {
		diag_log format ["DRO: Task %1 subTasks = %2", _taskName, _subTasks];
		{
			_subTaskName = _x select 0;
			_subTaskDesc = _x select 1;
			_subTaskTitle = _x select 2;
			_subTaskType = _x select 3;
			_id = [[_subTaskName, _taskName], true, [_subTaskDesc, _subTaskTitle, _markerName], objNull, "CREATED", 1, false, true, _subTaskType, true] call BIS_fnc_setTask;
		} forEach _subTasks;
	};
	if (_reconChance <= baseReconChance) then {
		if (!isNil "_extraData") then {
			[_taskName, _extraData] call BIS_fnc_taskSetDestination;
		};
	};
	
};

sun_newUnit = {
	params ["_oldUnit", "_newPos"];	
	diag_log format ["DRO: Changing unit %1", _oldUnit];
	private _loadout = getUnitLoadout _oldUnit;
	private _face = face _oldUnit;
	private _speaker = speaker _oldUnit;
	private _class = _oldUnit getVariable ["unitClass", ""];
	private _identity = (_oldUnit getVariable ["respawnIdentity", []]);	
	if (count _class == 0) then {
		_class = ((selectRandom unitList) select 0);
	};	
	private _tempGroup = createGroup playersSide;
	private _newUnit = _tempGroup createUnit [_class, _newPos, [], 0, "NONE"];
	setPlayable _newUnit;
	addSwitchableUnit _newUnit;	
	if (isPlayer _oldUnit) then {
		 _newUnit remoteExec ["selectPlayer", _oldUnit];
	};	
	private _varName = format ["u%1", ((vehicleVarName _oldUnit) select [1])];
	diag_log format ["DRO: New unit %1 created for %2 with class %3", _newUnit, _oldUnit, _class];
	deleteVehicle _oldUnit;
	diag_log format ["DRO: Setting new unit %1 to var %2", _newUnit, _varName];
	[_newUnit, _varName] remoteExec ["setVehicleVarName", 0, true];
	missionNamespace setVariable [_varName, _newUnit, true];
	waitUntil {
		diag_log format ["DRO: Waiting for %1", (missionNamespace getVariable _varName)];
		!isNull (missionNamespace getVariable _varName)
	};
	
	_newUnit setUnitLoadout _loadout;	
	if (count _identity > 0) then {
		_newUnit setVariable ["respawnIdentity", [_newUnit,  _identity select 1, _identity select 2, _speaker], true];
		[_newUnit, _identity select 1, _identity select 2, _speaker] remoteExec ["sun_setNameMP", 0, true];
		[_newUnit, _face] remoteExec ["setFace", 0, true];
	};
	//diag_log _newGroup;
	sun_newUnitArray pushBack _newUnit;
	publicVariable "sun_newUnitArray";
	//[_newUnit] joinSilent _newGroup;
	_newUnit setVariable ["respawnLoadout", (getUnitLoadout _newUnit), true];
	_newUnit setVariable ["respawnPWeapon", [(primaryWeapon  _newUnit), primaryWeaponItems _newUnit], true];	
	_newUnit setUnitTrait ["Medic", true];
	_newUnit setUnitTrait ["engineer", true];
	_newUnit setUnitTrait ["explosiveSpecialist", true];
	_newUnit setUnitTrait ["UAVHacker", true];		
};

sun_newUnits = {
	params ["_newPos"];
	
	sun_newUnitArray = [];
	publicVariable "sun_newUnitArray";
	{		
		diag_log _x;	
		[_x, _newPos] remoteExec ["sun_newUnit", _x, true];	
		waitUntil {
			diag_log format ["DRO: units in sun_newUnitArray = %1, _forEachIndex+1 = %2", (count sun_newUnitArray), (_forEachIndex + 1)];
			((count sun_newUnitArray) >= (_forEachIndex + 1))
		};
	} forEach units (grpNetId call BIS_fnc_groupFromNetId);	
	//diag_log format ["DRO: units _newGroup = %1", (units _newGroup)];
	{
		diag_log format ["DRO: this vehicleVarName = %1", (vehicleVarName _x)];
		waitUntil {
			diag_log format ["DRO: this vehicleVarName = %1", (vehicleVarName _x)];
			((vehicleVarName _x) select [0,1]) == "u";
		};
		diag_log format ["DRO: this vehicleVarName after wait = %1", (vehicleVarName _x)];
	} forEach sun_newUnitArray;
	private _newGroup = createGroup playersSide;
	{
		[_x] joinSilent _newGroup;
	} forEach sun_newUnitArray;
	grpNetId = _newGroup call BIS_fnc_netId;
	diag_log format ["DRO: New group with netID %1 containing %2", grpNetId, units (grpNetId call BIS_fnc_groupFromNetId)];	
	publicVariable "grpNetId";
	newUnitsReady = true;
	publicVariable "newUnitsReady";	
	
	// Keep grpNetId variable assigned to player group
	[] spawn {	
		while {true} do {
			if (isNil "grpNetId") then {
				grpNetId = (group(([] call BIS_fnc_listPlayers) select 0)) call BIS_fnc_netId;
				publicVariable "grpNetId";
			} else {			
				if (isNull (grpNetId call BIS_fnc_groupFromNetId)) then {
					grpNetId = (group(([] call BIS_fnc_listPlayers) select 0)) call BIS_fnc_netId;
					publicVariable "grpNetId";
				};			
			};
		};
	};	
};


sun_jipNewUnit = {
params ["_oldUnit", "_newPos"];	
	_newGroup = createGroup playersSide;	
	private _loadout = getUnitLoadout _oldUnit;
	private _face = face _oldUnit;
	private _speaker = speaker _oldUnit;
	private _class = _oldUnit getVariable ["unitClass", ""];
	if (count _class == 0) then {
		_class = ((selectRandom unitList) select 0);
	};	
	private _newUnit = _newGroup createUnit [_class, _newPos, [], 0, "NONE"];
	setPlayable _newUnit;
	addSwitchableUnit _newUnit;	
	selectPlayer _newUnit;	
	private _varName = format ["u%1", ((vehicleVarName _oldUnit) select [1,1])];
	[_newUnit, _varName] remoteExec ["setVehicleVarName", 0, true];
	missionNamespace setVariable [_varName, _newUnit, true];
	waitUntil {!isNull (missionNamespace getVariable _varName)};	
	_newUnit setUnitLoadout _loadout;
	private _identity = (_oldUnit getVariable ["respawnIdentity", []]);	
	if (count _identity > 0) then {
		_newUnit setVariable ["respawnIdentity", [_newUnit,  _identity select 1, _identity select 2, _speaker], true];
		[_newUnit, _identity select 1, _identity select 2, _speaker] remoteExec ["sun_setNameMP", 0, true];
		[_newUnit, _face] remoteExec ["setFace", 0, true];
	};
	diag_log format ["DRO: New unit %1 created for %2 with class %3", _newUnit, _oldUnit, _class];
	deleteVehicle _oldUnit;	
	[_newUnit] joinSilent (grpNetId call BIS_fnc_groupFromNetId);
	_newUnit setVariable ["respawnLoadout", (getUnitLoadout _newUnit), true];
	_newUnit setVariable ["respawnPWeapon", [(primaryWeapon  _newUnit), primaryWeaponItems _newUnit], true];	
	if (reviveDisabled < 3) then {
		[_newUnit] call rev_addReviveToUnit;	
	};	
	_newUnit setUnitTrait ["Medic", true];
	_newUnit setUnitTrait ["engineer", true];
	_newUnit setUnitTrait ["explosiveSpecialist", true];
	_newUnit setUnitTrait ["UAVHacker", true];		
};

sun_addResetAction = {
	params ["_unit"];	
	[
		_unit,
		[
			"Reset Unit",
			{[_this select 0] execVM "sunday_system\resetAIAction.sqf"},
			nil,
			20,
			false,
			true,
			"",
			"_this == _target"			
		]	
	] remoteExec ["addAction", 0, true];	
};

dro_clearData = {		
	// Faction data
	lbSetCurSel [2100, 0];
	lbSetCurSel [2101, 1];
	lbSetCurSel [2102, 0];
	lbSetCurSel [3800, 0];
	lbSetCurSel [3801, 0];
	lbSetCurSel [3802, 0];
	lbSetCurSel [3803, 0];
	lbSetCurSel [3804, 0];
	lbSetCurSel [3805, 0];
	
	// Other data
	lbSetCurSel [2103, 0];
	lbSetCurSel [2104, 0];
	lbSetCurSel [1301, 0];
	lbSetCurSel [2105, 0];
	//lbSetCurSel [2106, 0];
	//lbSetCurSel [2107, 2];
	lbSetCurSel [2108, 0];
	lbSetCurSel [2113, 0];	
	//lbSetCurSel [2115, 0];
	lbSetCurSel [2116, 0];
	sliderSetPosition [2111, 1*10];
	sliderSetPosition [2109, 3];
	[1301] call dro_inputDaysData;	
	
	pFactionIndex = 0;
	publicVariable "pFactionIndex";
	playersFactionAdv = [0,0,0];
	publicVariable "playersFactionAdv";
	eFactionIndex = 1;
	publicVariable "eFactionIndex";
	enemyFactionAdv = [0,0,0];
	publicVariable "enemyFactionAdv";
	cFactionIndex = 0;
	publicVariable "cFactionIndex";
	
	timeOfDay = 0;
	profileNamespace setVariable ["DCO_timeOfDay", nil];
	publicVariable "timeOfDay";
	month = 0;
	profileNamespace setVariable ["DCO_month", nil];
	publicVariable "month";
	day = 0;
	profileNamespace setVariable ["DCO_day", nil];
	publicVariable "day";
	weatherOvercast = "RANDOM";
	profileNamespace setVariable ["DCO_weatherOvercast", nil];
	publicVariable "weatherOvercast";
	aiSkill = 0;
	profileNamespace setVariable ["DCO_aiSkill", nil];
	publicVariable "aiSkill";
	aiMultiplier = 1;
	profileNamespace setVariable ["DCO_aiMultiplier", nil];
	publicVariable "aiMultiplier";
	numObjectives = 0;
	profileNamespace setVariable ["DCO_numObjectives", nil];
	publicVariable "numObjectives";
	preferredObjectives = [];
	publicVariable "preferredObjectives";
	aoOptionSelect = 2;
	/*
	profileNamespace setVariable ["DCO_aoOptionSelect", nil];
	publicVariable "aoOptionSelect";
	customPos = [];	
	publicVariable "customPos";
	*/
	minesEnabled = 0;
	profileNamespace setVariable ["DCO_minesEnabled", nil];
	publicVariable "minesEnabled";
	//civiliansEnabled = 0;
	//profileNamespace setVariable ["DRO_civiliansEnabled", nil];
	//publicVariable "civiliansEnabled";
	reviveDisabled = 0;
	profileNamespace setVariable ["DCO_reviveDisabled", nil];
	publicVariable "reviveDisabled";
	
	deleteMarker 'aoSelectMkr';
	aoName = nil;	
	ctrlSetText [2300, 'AO location: RANDOM'];
	selectedLocMarker setMarkerColor 'ColorPink';
	
	{
		((findDisplay 52525) displayCtrl _x) ctrlSetTextColor [1, 1, 1, 1];
	} forEach [2200, 2201, 2202, 2203, 2204, 2205, 2206, 2207, 2208, 2209, 2210];
	
	//ACE Crap vol. II
	ACE_repengineerSetting_Repair = 0;
	profileNamespace setVariable ["DRO_ACE_repengineerSetting_Repair", nil];
	publicVariable "ACE_repengineerSetting_Repair";
	ACE_repconsumeItem_ToolKit = 0;
	profileNamespace setVariable ["DRO_ACE_repconsumeItem_ToolKit", nil];
	publicVariable "ACE_repconsumeItem_ToolKit";
	ACE_repwheelRepairRequiredItems = 0;
	profileNamespace setVariable ["DRO_ACE_repwheelRepairRequiredItems", nil];
	publicVariable "ACE_repwheelRepairRequiredItems";
	ACE_medenableRevive = 1;
	profileNamespace setVariable ["DRO_ACE_medenableRevive", nil];
	publicVariable "ACE_medenableRevive";
	ACE_medmaxReviveTime = 300;
	profileNamespace setVariable ["DRO_ACE_medmaxReviveTime", nil];
	publicVariable "ACE_medmaxReviveTime";
	ACE_medamountOfReviveLives = 0;
	profileNamespace setVariable ["DRO_ACE_medamountOfReviveLives", nil];
	publicVariable "ACE_medamountOfReviveLives";
	ACE_medLevel = 0;
	profileNamespace setVariable ["DRO_ACE_medLevel", nil];
	publicVariable "ACE_medLevel";
	ACE_medmedicSetting = 1;
	profileNamespace setVariable ["DRO_ACE_medmedicSetting", nil];
	publicVariable "ACE_medmedicSetting";
	ACE_medenableScreams = 0;
	profileNamespace setVariable ["DRO_ACE_medenableScreams", nil];
	publicVariable "ACE_medenableScreams";
	ACE_medenableUnconsciousnessAI = 0;
	profileNamespace setVariable ["DRO_ACE_medenableUnconsciousnessAI", nil];
	publicVariable "ACE_medenableUnconsciousnessAI";
	ACE_medpreventInstaDeath = 1;
	profileNamespace setVariable ["DRO_ACE_medpreventInstaDeath", nil];
	publicVariable "ACE_medpreventInstaDeath";
	ACE_medbleedingCoefficient = 2;
	profileNamespace setVariable ["DRO_ACE_medbleedingCoefficient", nil];
	publicVariable "ACE_medbleedingCoefficient";
	ACE_medpainCoefficient = 10;
	profileNamespace setVariable ["DRO_ACE_medpainCoefficient", nil];
	publicVariable "ACE_medpainCoefficient";
	ACE_medenableAdvancedWounds = 0;
	profileNamespace setVariable ["DRO_ACE_medenableAdvancedWounds", nil];
	publicVariable "ACE_medenableAdvancedWounds";
	ACE_medmedicSetting_PAK = 0;
	profileNamespace setVariable ["DRO_ACE_medmedicSetting_PAK", nil];
	publicVariable "ACE_medmedicSetting_PAK";
	ACE_medconsumeItem_PAK = 0;
	profileNamespace setVariable ["DRO_ACE_medconsumeItem_PAK", nil];
	publicVariable "ACE_medconsumeItem_PAK";
	ACE_medmedicSetting_SurgicalKit = 0;
	profileNamespace setVariable ["DRO_ACE_medmedicSetting_SurgicalKit", nil];
	publicVariable "ACE_medmedicSetting_SurgicalKit";
	ACE_medconsumeItem_SurgicalKit = 0;
	profileNamespace setVariable ["DRO_ACE_medconsumeItem_SurgicalKit", nil];
	publicVariable "ACE_medconsumeItem_SurgicalKit";

	//If we change all the variables to their baseline directly before this, we can just plug the variable names in here. Readability improved by 1096%, and you only have to change one number instead of two!
	if ((configfile >> "CfgPatches" >> "ace_main") call BIS_fnc_getCfgIsClass) then {
		lbSetCurSel [6001, ACE_repengineerSetting_Repair];
		lbSetCurSel [6003, ACE_repconsumeItem_ToolKit];
		lbSetCurSel [6005, ACE_repwheelRepairRequiredItems];
		lbSetCurSel [6007, ACE_medenableRevive];
		sliderSetPosition [6009, ACE_medmaxReviveTime];
		sliderSetPosition [6011, ACE_medamountOfReviveLives];
		lbSetCurSel [6013, ACE_medLevel];
		lbSetCurSel [6015, ACE_medmedicSetting];
		lbSetCurSel [6017, ACE_medenableScreams];
		lbSetCurSel [6019, ACE_medenableUnconsciousnessAI];
		lbSetCurSel [6021, ACE_medpreventInstaDeath];
		sliderSetPosition [6023, ACE_medbleedingCoefficient];
		sliderSetPosition [6025, ACE_medpainCoefficient];
		lbSetCurSel [6027, ACE_medenableAdvancedWounds];
		lbSetCurSel [6029, ACE_medmedicSetting_PAK];
		lbSetCurSel [6031, ACE_medconsumeItem_PAK];
		lbSetCurSel [6033, ACE_medmedicSetting_SurgicalKit];
		lbSetCurSel [6035, ACE_medconsumeItem_SurgicalKit];
	};
	
};

dro_inputDaysData = {
	params ["_idc"];
	//_currentDaySelection = lbCurSel _idc;
	_currentDaySelection = profileNamespace getVariable ["DRO_day", 0];
	_days = [(date select 0), (date select 1)] call BIS_fnc_monthDays;	
	lbClear _idc;
	_daySelectionFound = false;
	for '_i' from 0 to _days step 1 do {
		if (_i == 0) then {
			lbAdd [_idc, "Random"];
		} else {
			lbAdd [_idc, str _i];
		};
		if (_i == _currentDaySelection) then {			
			lbSetCurSel [_idc, _i];
			_daySelectionFound = true;
		};
	};
	if !(_daySelectionFound) then {lbSetCurSel [_idc, 0];};
};

sun_setDateMP = {
	params ["_type", "_value"];
	if (_value > 0) then {
		_date = date;
		switch (toUpper _type) do {
			case "MONTH": {
				_date set [1, _value];
			};
			case "DAY": {
				_date set [2, _value];
			};
		};
		setDate _date;		
	};		
};

sun_randomTime = {	
	params ["_time"];
	if (_time == 0) then {_time = [1,4] call BIS_fnc_randomInt};
	_date = date;
	_dawnDusk = date call BIS_fnc_sunriseSunsetTime;
	_dawnNum = _dawnDusk select 0;
	_duskNum = _dawnDusk select 1;	
	switch (_time) do {
		case 1: {
			// DAWN		
			//skipTime _dawnNum;
			_date set [3, _dawnNum];
			setDate _date;		
		};
		case 2: {
			// DAY
			_dayTime = [_dawnNum+1, _duskNum-1] call BIS_fnc_randomNum;
			//skipTime _dayTime;
			_date set [3, _dayTime];
			setDate _date;	
		};
		case 3: {
			// DUSK			
			//skipTime _duskNum;
			_date set [3, _duskNum];
			setDate _date;		
		};
		case 4: {
			// NIGHT
			_nightTime1 = [(_duskNum + 1), 24] call BIS_fnc_randomNum;
			_nightTime2 = [0, (_dawnNum - 1)] call BIS_fnc_randomNum;
			_nightTime = selectRandom [_nightTime1, _nightTime2];
			_date set [3, _nightTime];
			setDate _date;
			//skipTime _nightTime;						
		};
	};	
};

sun_findRoadRoute = {
	params ["_startRoad", "_maxRoads"];	
	private _roadArray = [_startRoad];
	_connectedRoads = roadsConnectedTo _startRoad;	
	_roadChoice1 = nil;	

	// Get initial connected road, selecting randomly if there are more than one
	switch (count _connectedRoads) do {
		case 0: {
			_roadChoice1 = nil;			
		};
		case 1: {
			_roadChoice1 = (_connectedRoads select 0);			
		};		
		default {
			_roadChoice1 = selectRandom _connectedRoads;					
		};
	};	
	
	if (!isNil "_roadChoice1") then {
		// Add the second connected road and start searching for the next		
		_roadArray pushBack _roadChoice1;
		_lastRoad = _roadChoice1;
		for "_i" from 1 to (_maxRoads-1) step 1 do {
			// Check for new connected roads
			_connectedRoads = roadsConnectedTo _lastRoad;
			if (count _connectedRoads > 0) then {
				// Filter out any roads that have been used already
				_filteredRoadArray = _connectedRoads;
				{
					if (_x in _roadArray) then {
						_filteredRoadArray = _filteredRoadArray - [_x];
					};
				} forEach _connectedRoads;
				// If no new roads are found then exit loop
				if (count _filteredRoadArray == 0) exitWith {};				
				// Add new road to the array and use it to start the next loop
				_thisRoad = selectRandom _filteredRoadArray;								
				_roadArray pushBack _thisRoad;
				_lastRoad = _thisRoad;				
			};
		};
	};
	_roadArray
};

sun_refitTrigger = {
	params ["_pos", "_size", "_side"];
	/*
	_applicableUnits  = [];
	{
		if (side _x == _side) then {_applicableUnits pushBack _x};
	} forEach allUnits;
		*/
	while {true} do {		
		sleep 3;
		_list = _pos nearEntities [["Man", "Car", "Tank", "Helicopter", "Plane"], _size];
		_unitsToTest = [];
		{
			if (side _x == _side) then {_unitsToTest pushBack _x};
		} forEach _list;
		//_unitsToTest = _applicableUnits inAreaArray [_pos, _size, _size, 0, true];
		if (count _unitsToTest > 0) then {		
			{				
				//if (damage (vehicle _x) > 0.05 || fuel (vehicle _x) < 1) then {
					if !((vehicle _x) getVariable ['sun_refitActive', false]) then {
						[(vehicle _x), _pos, _size] spawn sun_refit;
					};
				//};			
			} forEach _unitsToTest;
		};
	};
};

sun_refit = {
	params ["_object", "_pos", "_size"];
	
	if (isTouchingGround _object) then {	
		_object setVariable ["sun_refitActive", true, true];
			
		// Repair
		disableSerialization;
		_rscLayer = ["RscRefit"] call BIS_fnc_rscLayer;
		_rscLayer cutRsc ["SUN_refitProgress", "PLAIN", 1, true];
		_progressBar = ((uiNamespace getVariable "RscRefit") displayCtrl 8000);
		_textBox = ((uiNamespace getVariable "RscRefit") displayCtrl 8100);
		//_refitDisplay = findDisplay 46 createDisplay "SUN_refitProgress";
		//_progressBar = _refitDisplay displayCtrl 8000;
		//_textBox = _refitDisplay displayCtrl 8100;
		
		if !(_object isKindOf "Man") then {
			_hitPoints = (getAllHitPointsDamage _object);		
			diag_log _hitPoints;
			_doRepair = false;
			if (count _hitPoints > 0) then {
				{
					if (_x > 0.01) then {
						_doRepair = true;
					};
				} forEach (_hitPoints select 2);
			};
			if (_doRepair) then {
				_startDamage = damage _object;
				_progressBar progressSetPosition 0;
				_progressBar ctrlSetFade 0;
				_progressBar ctrlCommit 1;
				_textBox ctrlSetFade 0;
				_textBox ctrlCommit 1;	
				_textBox ctrlSetText "REPAIRING";
				_counter = 0;
				while {_counter < 1} do {
					sleep 0.1;
					_counter = _counter + 0.01;
					_progressBar progressSetPosition _counter;
				};
				_object setDamage 0;
			};
		} else {	
			if (damage _object > 0.05) then {
				_startDamage = damage _object;
				_progressBar progressSetPosition 1-_startDamage;
				_progressBar ctrlSetFade 0;
				_progressBar ctrlCommit 1;
				_textBox ctrlSetFade 0;
				_textBox ctrlCommit 1;			
				_textBox ctrlSetText "HEALING";			
				while {damage _object > 0} do {				
					sleep 0.1;		
					_object setDamage (_startDamage - 0.005);		
					_startDamage = (_startDamage - 0.005);	
					_progressBar progressSetPosition 1-_startDamage;		
				};
			};
		};
		if !(_object isKindOf "Man") then {
			// Rearm
			if (ctrlFade _progressBar > 0) then {
				_progressBar ctrlSetFade 0;
				_progressBar ctrlCommit 1;
				_textBox ctrlSetFade 0;
				_textBox ctrlCommit 1;
			};
			_textBox ctrlSetText "REARMING";
			_progressBar progressSetPosition 0;			
			[_progressBar] spawn {
				_counter = 0;
				while {_counter < 1} do {
					sleep 0.1;
					_counter = _counter + 0.01;
					(_this select 0) progressSetPosition _counter;
				};
			};			
			_turrets = [[-1]] + allTurrets [_object, false];			
			if (count _turrets > 0) then {				
				{
					_thisTurret = _x;					
					_mags = _object magazinesTurret _thisTurret;
					if (_object turretLocal _thisTurret) then {
						{
							_object removeMagazinesTurret [_x, _thisTurret];
						} forEach _mags;
						{
							_object addMagazineTurret [_x, _thisTurret];
						} forEach _mags;
					} else {
						{
							[_object, [_x, _thisTurret]] remoteExec ["removeMagazinesTurret", (_object turretOwner _thisTurret)];							
						} forEach _mags;
						{
							[_object, [_x, _thisTurret]] remoteExec ["addMagazineTurret", (_object turretOwner _thisTurret)];							
						} forEach _mags;
					};			
				} forEach _turrets;				
			};
			_object setVehicleAmmo 1;
			
			// Refuel		
			_startFuel = fuel _object;
			_textBox ctrlSetText "REFUELLING";
			_progressBar progressSetPosition _startFuel;
			while {fuel _object < 1} do {
				sleep 0.1;
				_object setFuel (_startFuel + 0.005);
				_startFuel = fuel _object;	
				_progressBar progressSetPosition _startFuel;
			};	
		};
		_progressBar ctrlSetFade 1;
		_progressBar ctrlCommit 1;
		_textBox ctrlSetFade 1;
		_textBox ctrlCommit 1;
		//_refitDisplay closeDisplay 1;
		waitUntil {!(_object inArea [_pos, _size, _size, 0, true])};
		_object setVariable ["sun_refitActive", nil, true];	
	};
};

sun_supplyCrate = {
	params ["_crate", "_group"];
	clearWeaponCargoGlobal _crate;
	clearMagazineCargoGlobal _crate;
	clearItemCargoGlobal _crate;

	_crate addMagazineCargoGlobal ["SatchelCharge_Remote_Mag", 2];
	_crate addMagazineCargoGlobal ["DemoCharge_Remote_Mag", 4];
	_crate addItemCargoGlobal ["Medikit", 2];
	_crate addItemCargoGlobal ["FirstAidKit", 10];
	_crate addItemCargoGlobal ["ToolKit", 2];
	_crate addItemCargoGlobal ["MineDetector", 2];
	if !(isNil "_group") then {
		{	
			_magazines = magazinesAmmoFull _x;		
			{
				_crate addMagazineCargoGlobal [(_x select 0), 2];
			} forEach _magazines;	
		} forEach (units _group);
	};
	[_crate] call sun_supplyBox;
};

sun_getRoadDir = {
	params ["_road", "_roadsConnectedTo", "_connectedRoad", "_dir"];	
	_roadsConnectedTo = roadsConnectedTo _road;
	_dir = if (count _roadsConnectedTo > 0) then {
		_connectedRoad = _roadsConnectedTo select 0;
		[_road, _connectedRoad] call BIS_fnc_DirTo
	} else {
		(random 360)
	};
	_dir
};

sun_menuDataCollect = {
	params ["_var", "_control", "_index", "_data"];
	_data = _control lbData _index;
	//missionNameSpace setVariable [_var, [_index, _data]];
	profileNamespace setVariable [_var, [_index, _data]];
	//publicVariable _var;
};	

sun_medicBox = {
	params ["_box", "_boxName", "_actionStr"];
	_boxName = (configFile >> "CfgVehicles" >> (typeOf _box) >> "displayName") call BIS_fnc_GetCfgData;
	_actionStr = format ["Treat at %1", _boxName];
	[_box, [
		_actionStr,
		{
			(_this select 1) setDamage 0;					
		},
		[],
		1001,
		false,
		false,
		"",
		"",
		200,
		false
	]] remoteExec ["addAction", 0, true];			
};

sun_supplyBox = {	
	params ["_box", "_boxName", "_actionStr"];
	_boxName = (configFile >> "CfgVehicles" >> (typeOf _box) >> "displayName") call BIS_fnc_GetCfgData;
	_actionStr = format ["Force rearm at %1", _boxName];
	[_box, [
		_actionStr,
		{
			_unit = (_this select 1);
								
			_primaryWeapon = [primaryWeapon (_this select 1)] call BIS_fnc_baseWeapon;
			_secondaryWeapon = secondaryWeapon (_this select 1);
			//_handgun = [handgunWeapon (_this select 1)] call BIS_fnc_baseWeapon;
			
			if (count _primaryWeapon > 0) then {
				_unit addMagazines [(((configfile >> "CfgWeapons" >> _primaryWeapon >> "magazines") call BIS_fnc_getCfgData) select 0), 5];
			};
			if (count _secondaryWeapon > 0) then {
				_unit addMagazines [(((configfile >> "CfgWeapons" >> _secondaryWeapon >> "magazines") call BIS_fnc_getCfgData) select 0), 2];
			};
			/*
			if (count _handgun > 0) then {
				_unit addMagazines [(((configfile >> "CfgWeapons" >> _handgun >> "magazines") call BIS_fnc_getCfgData) select 0), 2];
			};
			*/			
		},
		[],
		20,
		false,
		false,
		"",
		"!isPlayer (_this)",
		200,
		false
	]] remoteExec ["addAction", 0, true];	
			
};

sun_checkMinDist = {
	params ["_array", "_maxDist"];
	private _tempArray = _array;
	private _return = [];
	{
		private _thisPos = if (typeName _x == "ARRAY") then {
			_x
		} else {
			getPos _x;
		};
		private _continue = true;
		{
			private _testedPos = _x;			
			if !(_thisPos isEqualTo _testedPos) then {
				if ((_thisPos distance _testedPos) < _maxDist) then {
					_continue = false;
				};
			};
		} forEach _tempArray;
		if (_continue) then {
			_return pushBack _thisPos;
		};
	} forEach _array;
	if (count _return == 0) then {
		_return pushBack (selectRandom _array);
	};
	diag_log _return;
	_return
};

sun_setSideMarkerColor = {	
	private _return = switch (_this select 0) do {
		case west: {		
			"colorBLUFOR"
		};
		case east: {		
			"colorOPFOR"
		};
		case resistance: {		
			"colorIndependent"
		};
		default {
			"ColorKhaki"
		};
	};
	_return
};

sun_groupToVehicle = {
	params ["_group", "_vehicle", ["_cargoOnly", false]];
	
	if (typeName _group == "GROUP") then {
		_group = units _group;
	};
	diag_log format ["sun_groupToVehicle called for %1", _group];	
	
	_commanderPositions = _vehicle emptyPositions "Commander";
	_driverPositions = _vehicle emptyPositions "Driver";	
	_gunnerPositions = _vehicle emptyPositions "Gunner";	
	
	if (_cargoOnly) then {
		_commanderPositions = 0;
		_driverPositions = 0;	
		_gunnerPositions = 0;
	};	
	
	_cargoPositions = _vehicle emptyPositions "Cargo";	
	diag_log format ["sun_groupToVehicle: commander slots = %1", _commanderPositions];
	diag_log format ["sun_groupToVehicle: driver slots = %1", _driverPositions];
	diag_log format ["sun_groupToVehicle: gunner slots = %1", _gunnerPositions];
	diag_log format ["sun_groupToVehicle: cargo slots = %1", _cargoPositions];
	{		
		_unit = _x;
		diag_log format ["sun_groupToVehicle: assigning %1", _unit];
		if (_commanderPositions > 0) then {			
			_unit assignAsCommander _vehicle;			
			[_unit, _vehicle] remoteExecCall ["moveInCommander", _unit];
			waitUntil {vehicle _unit != _unit};
			diag_log format ["sun_groupToVehicle: remote %1 moveInCommander to %2", _unit, _vehicle];						
			_commanderPositions = _commanderPositions - 1;			
		} else {
			if (_driverPositions > 0) then {			
				_unit assignAsDriver _vehicle;				
				[_unit, _vehicle] remoteExecCall ["moveInDriver", _unit];
				waitUntil {vehicle _unit != _unit};
				diag_log format ["sun_groupToVehicle: remote %1 moveInDriver to %2", _unit, _vehicle];			
				_driverPositions = _driverPositions - 1;			
			} else {
				if (_gunnerPositions > 0) then {			
					_unit assignAsGunner _vehicle;					
					[_unit, _vehicle] remoteExecCall ["moveInGunner", _unit];
					waitUntil {vehicle _unit != _unit};
					diag_log format ["sun_groupToVehicle: remote %1 moveInGunner to %2", _unit, _vehicle];					
					_gunnerPositions = _gunnerPositions - 1;			
				} else {
					if (_cargoPositions > 0) then {			
						_unit assignAsCargo _vehicle;						
						[_unit, _vehicle] remoteExecCall ["moveInCargo", _unit];
						waitUntil {vehicle _unit != _unit};
						diag_log format ["sun_groupToVehicle: remote %1 moveInCargo to %2", _unit, _vehicle];						
						_cargoPositions = _cargoPositions - 1;			
					};
				};
			};
		};			
	} forEach _group;	
};

sun_moveGroup = {
	params ["_group", "_pos", "_extendArray", "_posParams"];
	
	_extendArray = [];
	{
		_distToLead = (leader _group) distance _x;
		_dirFromLead = [(leader _group), _x] call BIS_fnc_dirTo;
		_extendArray pushBack [_distToLead, _dirFromLead];
	} forEach units _group;
	
	(leader _group) setPos _pos;
	{
		_posParams = _extendArray select _forEachIndex;
		_extendPos = [_pos, (_posParams select 0), (_posParams select 1)] call dro_extendPos;
		_x setPos _extendPos;
		while {_x distance _extendPos > 100} do {
			_x setPos _extendPos;
		};
	} forEach units _group;		
};	

sun_defineGrid = {
	params ["_center", "_numPosX", "_numPosY", "_spacing"];	
	_positions = [];
	_totalXSpacing = _spacing * _numPosX;
	_totalYSpacing = _spacing * _numPosY;
	
	_xOrigin = (_center select 0) - (_totalXSpacing/2);
	_yOrigin = (_center select 1) - (_totalYSpacing/2);
	
	_thisX = 0;
	_thisY = 0;
	for "_i" from 0 to (_numPosY - 1) step 1 do {
		for "_j" from 0 to (_numPosX - 1) step 1 do {
			_thisX = _xOrigin + (_spacing * _i) + (_spacing/2);
			_thisY = _yOrigin + (_spacing * _j) + (_spacing/2);			
			_positions pushBack [_thisX, _thisY, 0];
		};
	};
	_positions
	
};

dro_createSimpleObject = {
	params ["_class", "_pos", "_dir", "_object"];
	_pos set [2, 0];
	_object = createVehicle [_class, _pos, [], 0, "CAN_COLLIDE"];	
	//_object = _class createVehicle _pos;
	_object setDir _dir;
	_object setVectorUp (surfaceNormal (getPosATL _object));
	_simpleObject = [_object] call BIS_fnc_replaceWithSimpleObject;	
	_simpleObject
};

sun_removeEnemyNVG = {
	{
		if (side _x != side u1) then {
			_unit = _x;		
			_nvgs = hmd _unit;			
			_unit unassignItem _nvgs;
			_unit removeItem _nvgs;			
			_unit removePrimaryWeaponItem "acc_pointer_IR";   
			_unit addPrimaryWeaponItem "acc_flashlight";
			_unit enableGunLights "forceon";		
		};
	} forEach allunits;
};

sun_getUnitPositionId = {
	private ["_vvn", "_str"];
	_vvn = vehicleVarName (_this select 0);
	(_this select 0) setVehicleVarName "";
	_str = str (_this select 0);
	(_this select 0) setVehicleVarName _vvn;
	parseNumber (_str select [(_str find ":") + 1])
};

sun_avgPos = {
	params ["_positions"];
	_xTotal = 0;
	_yTotal = 0;	
	{	
		_pos = switch (typeName _x) do {
			case "STRING": {getMarkerPos _x};
			case "OBJECT": {getPos _x};
			case "ARRAY": {_x};
			default {_x};
		};
		_xTotal = _xTotal + (_pos select 0);
		_yTotal = _yTotal + (_pos select 1);
	} forEach _positions;
	_numPositions = count _positions;	
	([(_xTotal / _numPositions), (_yTotal / _numPositions), 0])
};

dro_extendPos = {
	//private ["_center", "_dist", "angle", "_x2", "_y2"];
	_center = (_this select 0);
	_dist = (_this select 1);
	_angle = (_this select 2);
	_x2 = ((_center select 0) + ((cos (90-_angle)) * _dist));
	_y2 = ((_center select 1) + ((sin (90-_angle)) * _dist));
	[_x2, _y2, 0]
};

dro_selectRemove = {
	_index = [0, (count (_this select 0)-1)] call BIS_fnc_randomInt;	
	_return = (_this select 0) select _index;
	(_this select 0) deleteAt _index;
	_return
};

sun_selectRemove = {
	_index = [0, (count (_this select 0)-1)] call BIS_fnc_randomInt;	
	_return = (_this select 0) select _index;
	(_this select 0) deleteAt _index;
	_return
};

dro_getArtilleryRanges = {
	private ["_turrets", "_vehicleMinRange", "_vehicleMaxRange", "_turretMinRange", "_turretMaxRange"];
	_turrets = [(_this select 0)] call BIS_fnc_getTurrets;
	_vehicleMinRange = 100000;
	_vehicleMaxRange = 0;
	{
		_modesToTest = [];
		_thisTurret = _x;
		_weapons = ((_thisTurret >> "weapons") call BIS_fnc_GetCfgData);	
		{		
			_thisWeapon = _x;		
			_modes = ((configfile >> "CfgWeapons" >> _thisWeapon >> "modes") call BIS_fnc_GetCfgData);		
			{
				_weaponChild = _x;
				_weaponChildName = (configName _x);
				{
					if (_x == _weaponChildName) then {					
						_modesToTest pushBackUnique _weaponChild;
					};
				} forEach _modes;
			} forEach ([(configfile >> "CfgWeapons" >> _thisWeapon), 0, true] call BIS_fnc_returnChildren);
			
		} forEach _weapons;	
		_turretMinRange = 100000;
		_turretMaxRange = 0;
		if (count _modesToTest > 0) then {
			{
				_minRange = ((_x >> "minRange") call BIS_fnc_GetCfgData);
				if (_minRange < _turretMinRange) then {_turretMinRange = _minRange};
				_maxRange = ((_x >> "maxRange") call BIS_fnc_GetCfgData);
				if (_maxRange > _turretMaxRange) then {_turretMaxRange = _maxRange};
			} forEach _modesToTest;	
		};	
		
		if (_turretMinRange < _vehicleMinRange) then {_vehicleMinRange = _turretMinRange};	
		if (_turretMaxRange > _vehicleMaxRange) then {_vehicleMaxRange = _turretMaxRange};
		
	} forEach _turrets;

	[_vehicleMinRange, _vehicleMaxRange]
};

dro_heliInsertion = {
	_heli = _this select 0;
	_insertPos = _this select 1;
	_type = _this select 2;
	
	diag_log format ["DRO: Init heli insertion with heli %1 to %2", _heli, _insertPos];
	
	_heliGroup = (group _heli);
	_startPos = [((getPos _heli) select 0), ((getPos _heli) select 1), ((getPos _heli) select 2)];
	_height = getTerrainHeightASL _insertPos; 
	_insertPosHigh = [(_insertPos select 0), (_insertPos select 1), _height+150];
	
	_flyDir = [_startPos, _insertPosHigh] call BIS_fnc_dirTo;
	_flyByPosExtend = [_insertPosHigh, 3000, _flyDir] call dro_extendPos;
	_flyByPos = [(_flyByPosExtend select 0), (_flyByPosExtend select 1), 200];
	
	_heli flyInHeight 200;
	_heliGroup = (group _heli);
	
	_driver = driver _heli;
	_heliGroup setBehaviour "careless";
    _driver disableAI "FSM";
    _driver disableAI "Target";
    _driver disableAI "AutoTarget";
	
	// Clear current waypoints
	while {(count (waypoints _heliGroup)) > 0} do {
		deleteWaypoint ((waypoints _heliGroup) select 0);
	};	
	
	_wp0 = _heliGroup addWaypoint [_startPos, 0];	
	_wp0 setWaypointSpeed "FULL";
	_wp0 setWaypointType "MOVE";	
	_wp0 setWaypointBehaviour "COMBAT";
	
	_wp1 = _heliGroup addWaypoint [_flyByPos, 0];	
	_wp1 setWaypointSpeed "FULL";
	_wp1 setWaypointType "MOVE";	
	
	_trgEject = createTrigger ["EmptyDetector", _insertPosHigh];
	_trgEject setTriggerArea [800, 50, _flyDir, false];
	_trgEject setTriggerActivation ["ANY", "PRESENT", false];
	_trgEject setTriggerStatements ["(thisTrigger getVariable 'heli') in thisList", "[(assignedCargo (thisTrigger getVariable 'heli'))] execVM 'sunday_system\callParadrop.sqf';", ""];
	_trgEject setVariable ["heli", _heli];
	
	_trgDelete = createTrigger ["EmptyDetector", _flyByPos];
	_trgDelete setTriggerArea [100, 100, 0, false];
	_trgDelete setTriggerActivation ["ANY", "PRESENT", false];
	_trgDelete setTriggerStatements ["(thisTrigger getVariable 'heli') in thisList", "deleteVehicle (thisTrigger getVariable 'heli');", ""];
	_trgDelete setVariable ["heli", _heli];
	
	
	diag_log format ["DRO: heli waypoints %1, %2", waypointPosition [_heliGroup, 0], waypointPosition [_heliGroup, 1]];
	
};

sun_getCfgSide = {
	params ["_sideValue"];
	private _return = west;	
	if (typeName _sideValue == "TEXT") then {
		if ((["west", _sideValue, false] call BIS_fnc_inString)) then {
			_sideValue = 1;
		};
		if ((["east", _sideValue, false] call BIS_fnc_inString)) then {
			_sideValue = 0;
		};
		if ((["guer", _sideValue, false] call BIS_fnc_inString) || (["ind", _sideValue, false] call BIS_fnc_inString)) then {
			_sideValue = 2;
		};
	};			
	if (typeName _sideValue == "SCALAR") then {
		if (_sideValue <= 3 && _sideValue > -1) then {
			switch (_sideValue) do {
				case 0: {_return = east};
				case 1: {_return = west};
				case 2: {_return = resistance};
				case 3: {_return = civilian};
			};
		};	
	};	
	_return
};

sun_getCfgUnitSide = {
	params ["_configName"];
	private _return = west;
	_sideNum = (((configFile >> "CfgVehicles" >> _configName >> "side")) call BIS_fnc_GetCfgData);
	if (!isNil "_sideNum") then {
		if (typeName _sideNum == "TEXT") then {
			if ((["west", _sideNum, false] call BIS_fnc_inString)) then {
				_sideNum = 1;
			};
			if ((["east", _sideNum, false] call BIS_fnc_inString)) then {
				_sideNum = 0;
			};
			if ((["guer", _sideNum, false] call BIS_fnc_inString) || (["ind", _sideNum, false] call BIS_fnc_inString)) then {
				_sideNum = 2;
			};
		};			
		if (typeName _sideNum == "SCALAR") then {
			if (_sideNum <= 3 && _sideNum > -1) then {
				switch (_sideNum) do {
					case 0: {_return = east};
					case 1: {_return = west};
					case 2: {_return = resistance};
					case 3: {_return = civilian};
				};
			};	
		};
	};
	_return
};

dro_spawnGroupWeighted = {	
	_pos = [];
	if (!isNil {(_this select 0)}) then {
		_pos = (_this select 0);
	};
	_side = (_this select 1);	
	_unitArrIndex = [0, (count (_this select 2) -1)] call BIS_fnc_randomInt;
	_unitArr = ((_this select 2) select _unitArrIndex);		// Array : [classnames]
	_unitArrWeights = ((_this select 3) select _unitArrIndex);		// Array : [weights]
	/*
	_unitArr = (_this select 2);		// Array : [classnames]
	_unitArrWeights = (_this select 3);		// Array : [weights]
	*/
	_unitNumbers = (_this select 4);	// Array : [min units, max units]

	if (_side == enemySide) then {		
		//_side = [(_unitArr select 0)] call sun_getCfgUnitSide;		
		if (_side == playersSide) then {
			_side = switch (playersSide) do {
				case east: {resistance};				
				default {east};				
			};
		};
	};
	
	if (count _pos > 0) then {			
		// Get a random number of units to select between the boundaries
		_minUnits = (_unitNumbers select 0);
		if (_minUnits < 1) then {_minUnits = 1};
		_maxUnits = (_unitNumbers select 1);	
		_limitUnits = [_minUnits, _maxUnits] call BIS_fnc_randomInt;
		
		_unitsToSpawn = [];
		for "_i" from 1 to _limitUnits do {
			_thisUnit = nil;
			if (count _unitArrWeights > 0) then {
				_thisUnit = [_unitArr, _unitArrWeights] call BIS_fnc_selectRandomWeighted;
			} else {
				_thisUnit = selectRandom _unitArr;
			};				
			_unitsToSpawn pushBack _thisUnit;
		};
		
		_group = [_pos, _side, _unitsToSpawn] call BIS_fnc_spawnGroup;
		if (!isNil "aiSkill") then {			
			[_group] call dro_setSkillAction;			
		};	
		_group
	};	
};

dro_setSkillAction = {
	switch (aiSkill) do {

		default {};

		// 컴뱃옵스 자체 난이도 제거
		/*
		case 0: {
			if (typeName (_this select 0) == "OBJECT") then {
				_unit = (_this select 0);
				_unit setSkill ["aimingAccuracy", random [0.06, 0.07, 0.08]];
				_unit setSkill ["aimingShake", random [0.01, 0.015, 0.02]];
				_unit setSkill ["aimingSpeed", random [0.1, 0.1, 0.15]];
				_unit setSkill ["spotDistance", random [0.7, 0.75, 0.8]];
				_unit setSkill ["spotTime", random [0.3, 0.4, 0.5]];
				_unit setSkill ["general", random [0.7, 0.75, 0.8]];	
				_unit setSkill ["courage", random [0.1, 0.2, 0.3]];
				_unit setSkill ["reloadSpeed", random [0.1, 0.1, 0.2]];
			};
			if (typeName (_this select 0) == "GROUP") then {		
				{
					_unit = _x;
					_unit setSkill ["aimingAccuracy", random [0.06, 0.07, 0.08]];
					_unit setSkill ["aimingShake", random [0.01, 0.015, 0.02]];
					_unit setSkill ["aimingSpeed", random [0.1, 0.1, 0.15]];
					_unit setSkill ["spotDistance", random [0.7, 0.75, 0.8]];
					_unit setSkill ["spotTime", random [0.3, 0.4, 0.5]];
					_unit setSkill ["general", random [0.7, 0.75, 0.8]];	
					_unit setSkill ["courage", random [0.1, 0.2, 0.3]];
					_unit setSkill ["reloadSpeed", random [0.1, 0.1, 0.2]];
				} forEach (units (_this select 0));
			};
		};
		case 1: {
			if (typeName (_this select 0) == "OBJECT") then {
				_unit = (_this select 0);
				_unit setSkill ["aimingAccuracy", random [0.15, 0.18, 0.2]];
				_unit setSkill ["aimingShake", random [0.06, 0.08, 0.1]];
				_unit setSkill ["aimingSpeed", random [0.2, 0.2, 0.25]];
				_unit setSkill ["spotDistance", random [0.7, 0.75, 0.8]];
				_unit setSkill ["spotTime", random [0.3, 0.4, 0.5]];
				_unit setSkill ["general", random [0.7, 0.75, 0.8]];	
				_unit setSkill ["courage", random [0.3, 0.4, 0.5]];
				_unit setSkill ["reloadSpeed", random [0.2, 0.3, 0.3]];
			};
			if (typeName (_this select 0) == "GROUP") then {		
				{
					_unit = _x;
					_unit setSkill ["aimingAccuracy", random [0.15, 0.18, 0.2]];
					_unit setSkill ["aimingShake", random [0.06, 0.08, 0.1]];
					_unit setSkill ["aimingSpeed", random [0.2, 0.2, 0.25]];
					_unit setSkill ["spotDistance", random [0.7, 0.75, 0.8]];
					_unit setSkill ["spotTime", random [0.3, 0.4, 0.5]];
					_unit setSkill ["general", random [0.7, 0.75, 0.8]];	
					_unit setSkill ["courage", random [0.3, 0.4, 0.5]];
					_unit setSkill ["reloadSpeed", random [0.2, 0.3, 0.3]];
				} forEach (units (_this select 0));
			};
		};
		*/
	}; 
	
};

sun_addArsenal = {
	(_this select 0) addAction ["Arsenal", "['Open', true] call BIS_fnc_arsenal", nil, 6];
};	

sun_pasteLoadoutAdd = {
	_target = _this select 0;
	
	_actionIndex = _target addAction [
		"Paste Loadout",
		{
			_unit = _this select 1;
			_target = _this select 0;
			
			// Remove current loadout			
			_target removeWeaponGlobal (primaryWeapon _target);
			_target removeWeaponGlobal (secondaryWeapon _target);
			_target removeWeaponGlobal (handgunWeapon _target);
			removeUniform _target;
			removeVest _target;
			removeHeadgear _target;
			removeGoggles _target;
			removeBackpack _target;
			_target unassignItem "NVGoggles";
			_target removeItem "NVGoggles";	
			
			// Paste player's loadout
			_loadoutName = format ["loadout%1", _unit];
			[_unit, [missionNameSpace, _loadoutName]] call BIS_fnc_saveInventory;
			[_target, [missionNameSpace, _loadoutName]] call BIS_fnc_loadInventory;			
		},
		nil,
		1.5,
		false,
		false
	];
	
	// Record this action index for later removal
	_target setVariable ["loadoutAction", _actionIndex];
	
};

sun_pasteLoadoutRemove = {
	_target = _this select 0;
	_actionIndex = _target getVariable "loadoutAction";		
	_target removeAction _actionIndex;
};

sun_moveInCargo = {
	//_unit = _this select 0;
	_vehicle = _this select 0;	
	player moveInCargo _vehicle;	
};

sun_playRadioRandom = {
	_radioArray = [		
		"RadioAmbient2",
		"RadioAmbient6",
		"RadioAmbient8"
	];
	playSound [(selectRandom _radioArray), true];
};

sun_setNameMP = {
	diag_log "sun_setNameMP called";
	_unit = _this select 0;
	_firstName = _this select 1;
	_lastName = _this select 2;
	_speaker = _this select 3;
	_unit setName [format ["%1 %2", _firstName, _lastName], _firstName, _lastName];
	_unit setNameSound _lastName;
	_unit setSpeaker _speaker;
};

sun_spawnGroup = {
	_pos = [];
	if (!isNil {(_this select 0)}) then {
		_pos = _this select 0;
	};
	_side = _this select 1;			
	_unitArr = _this select 2;		// Array : [classnames]
	_unitNumbers = _this select 3;	// Array : [min units, max units]
	_skill = _this select 4;
	
	if (count _unitArr > 0) then {
		if (count _pos > 0) then {	
			// Get a random number of units to select between the boundaries
			_minUnits = (_unitNumbers select 0);
			_maxUnits = (_unitNumbers select 1);	
			_limitUnits = [_minUnits,_maxUnits] call BIS_fnc_randomInt;
			
			_unitsToSpawn = [];
			for "_i" from 1 to _limitUnits do {
				_thisUnit = selectRandom _unitArr;
				_unitsToSpawn pushBack _thisUnit;
			};
			
			_group = [_pos, _side, _unitsToSpawn] call BIS_fnc_spawnGroup;
			if (!isNil "_skill") then {
				if (_skill == "Militia") then {
					[_group] call dro_setSkillAction;
				};
			};
			_group
		};
	};
};

sun_spawnCfgGroup = {
	_pos = [];
	if (!isNil {(_this select 0)}) then {
		_pos = _this select 0;
	};
	_side = _this select 1;			
	_groupsCfgArr = _this select 2;		// Array : [group classnames]
	_unitNumbers = _this select 3;
	_skill = _this select 4;
	_unitArr = _this select 5;			// Array : [unit classnames] optional, for use if no groups found
	
	_minUnits = (_unitNumbers select 0);
	_maxUnits = (_unitNumbers select 1);	
	
	if (count _groupsCfgArr > 0) then {			
		if (count _pos > 0) then {	
			{		
				if ((count ([_x, 0, true] call BIS_fnc_returnChildren)) > _maxUnits) then {
					_groupsCfgArr = _groupsCfgArr - [_x];
				}
			} forEach _groupsCfgArr;
			
			_thisGroup = selectRandom _groupsCfgArr;
			if (!isNil "_thisGroup") then {
				diag_log "DRO: Spawning group using Cfg data";
				_group = [_pos, _side, _thisGroup, [], [], [], [], [_minUnits, 0.65]] call BIS_fnc_spawnGroup;
				if (_skill == "Militia") then {
					[_group] call dro_setSkillAction;
				};
				_group
			} else {
				if (!isNil "_unitArr") then {
					if (count _unitArr > 0) then {
						diag_log "DRO: Spawning group using array data";
						_group = [_pos, _side, _unitArr, _unitNumbers, _skill] call sun_spawnGroup;
						if (_skill == "Militia") then {
							[_group] call dro_setSkillAction;
						};
						_group
					};
				};
			};
		};
	} else {
		if (!isNil "_unitArr") then {
			if (count _unitArr > 0) then {
				diag_log "DRO: Spawning group using array data";
				_group = [_pos, _side, _unitArr, _unitNumbers, _skill] call sun_spawnGroup;
				if (_skill == "Militia") then {
					[_group] call dro_setSkillAction;
				};
				_group
			};
		};
	};

};

sun_spawnGroupSingleUnit = {
	_pos = [];
	if (!isNil {(_this select 0)}) then {
		_pos = _this select 0;
	};
	_side = _this select 1;			
	_groupsCfgArr = _this select 2;		// Array : [group classnames]
	_skill = _this select 3;
	_unitArr = _this select 4;			// Array : [unit classnames] optional, for use if no groups found
		
	if (count _groupsCfgArr > 0) then {
		if (count _pos > 0) then {		
			_thisUnitClass = selectRandom _groupsCfgArr;
			if (count _thisUnitClass > 0) then {
				_group = createGroup _side;
				_unit = _group createUnit [_thisUnitClass, _pos, [], 0, "NONE"];	
				if (_skill == "Militia") then {
					[_unit] call dro_setSkillAction;
				};			
				_unit
			} else {
				if (isNil "_thisUnitClass") then {
					_thisUnitClass = selectRandom _unitArr;
					_group = createGroup _side;
					_unit = _group createUnit [_thisUnitClass, _pos, [], 0, "NONE"];	
					if (_skill == "Militia") then {
						[_unit] call dro_setSkillAction;
					};
					_unit
				};
			};
		};
	} else {
		if (!isNil "_unitArr") then {
			if (count _unitArr > 0) then {
				_thisUnitClass = selectRandom _unitArr;
				_group = createGroup _side;
				_unit = _group createUnit [_thisUnitClass, _pos, [], 0, "NONE"];	
				if (_skill == "Militia") then {
					[_unit] call dro_setSkillAction;
				};
				_unit
			};
		};
	};
};

