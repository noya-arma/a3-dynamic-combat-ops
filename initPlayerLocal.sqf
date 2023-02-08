diag_log format ["DRO: Player %1 waiting for player init", player];
waitUntil {!isNull player};

// Load function libraries
#include "sunday_system\sundayFunctions.sqf"
#include "sunday_system\droFunctions.sqf"
#include "sunday_system\dcoFunctions.sqf"
#include "sunday_revive\reviveFunctions.sqf";
#include "sunday_system\menuFunctions.sqf";

addWeaponItemEverywhere = compileFinal " _this select 0 addPrimaryWeaponItem (_this select 1); ";
addHandgunItemEverywhere = compileFinal " _this select 0 addHandgunItem (_this select 1); ";
removeWeaponItemEverywhere = compileFinal "_this select 0 removePrimaryWeaponItem (_this select 1)";

if (!hasInterface || isDedicated) exitWith {};

player setVariable ['startReady', false, true];
playerCameraView = cameraView;

fnc_missionText = {
	// Mission info readout
	_campName = (missionNameSpace getVariable "publicCampName");
	diag_log format ["DRO: Player %1 establishing shot initialised", player];
	sleep 3;
	[parseText format [ "<t font='EtelkaMonospaceProBold' color='#ffffff' size = '1.7'>%1</t>", toUpper _campName], true, nil, 5, 0.7, 0] spawn BIS_fnc_textTiles;
	sleep 6;
	_hours = "";
	if ((date select 3) < 10) then {
		_hours = format ["0%1", (date select 3)];
	} else {
		_hours = str (date select 3);
	};
	_minutes = "";
	if ((date select 4) < 10) then {
		_minutes = format ["0%1", (date select 4)];
	} else {
		_minutes = str (date select 4);
	};
	[parseText format [ "<t font='EtelkaMonospaceProBold' color='#ffffff' size = '1.7'>%1  %2</t>", str(date select 1) + "." + str(date select 2) + "." + str(date select 0), _hours + _minutes + " HOURS"], true, nil, 5, 0.7, 0] spawn BIS_fnc_textTiles;
	sleep 6;
	// Operation title text
	_missionName = missionNameSpace getVariable "mName";
	_string = format ["<t font='EtelkaMonospaceProBold' color='#ffffff' size = '1.7'>%1</t>", _missionName];
	[parseText format [ "<t font='EtelkaMonospaceProBold' color='#ffffff' size = '1.7'>%1</t>", toUpper _missionName], true, nil, 7, 0.7, 0] spawn BIS_fnc_textTiles;
};

cutText ["", "BLACK FADED"];

player createDiarySubject ["dco", "Dynamic Combat Ops"];
if ((configfile >> "CfgPatches" >> "ace_main") call BIS_fnc_getCfgIsClass) then {	
	player createDiaryRecord ["dco", ["ACE Compatibility", "
		<br /><br />
		ACE has been detected and the DRO startup menu will include new options to govern the various ACE variables.<br /><br />
		All credit for the work on ACE integration goes to Ledere, many thanks to him for taking the time to make this patch and allowing me to integrate it into DRO!
	"]];
};
player createDiaryRecord ["dco", ["Hints", "
<br /><br />
Resupply crates at the FOB and dropped by support missions have a 'Force Resupply' option that's available to AI only. You can call it be selecting individual team members and using command menu 6 to order them to resupply regardless of how much ammo they are carrying.
<br /><br />
Standing near the FOB will initiate a refit for units and vehicles. Infantry will be healed while vehicles will be repaired, rearmed and refueled.
<br /><br />
Your chosen platoon (unless designated as supports) can be controlled using the High Command menu, accessed by default by pressing Ctrl-Space.
"]];
player createDiaryRecord ["dco", ["Dynamic Combat Ops", "
<font image='images\combat_image_collection.jpg' width='350' height='175'></font><br /><br />
Dynamic Combat Ops is a randomised, replayable scenario that focuses on combined arms operations.
Select your AO location, the factions you want to use and your platoon makeup or leave them all randomised and see what mission you are sent on.<br /><br />
Thank you for playing! If you have any feedback or bug reports please email me at mbrdmn@gmail.com.
<br /><br />
DCO has been developed with the support of subscribers at www.patreon.com/mbrdmn. If you've enjoyed DCO or want to be involved in the design of current and future projects please consider a donation. 
Everything is appreciated and will directly go towards new content for DCO and any planned future missions.
"]];

player setVariable ["respawnLoadout", (getUnitLoadout player), true];
VAR_CAMERA_VIEW = playerCameraView;

diag_log format ["clientOwner = %1", clientOwner];
playerReady = 0;
enableTeamSwitch false;
enableSentences false;

// Move to mission area if JIP and do not process intro script
_doJIP = if (didJIP) then {
	if ((missionNameSpace getVariable ["lobbyComplete", 0]) == 0) then {
		false
	} else {
		true
	};	
} else {
	false
};

if (_doJIP) exitWith {		
	
	//Position
	_pos = if (getMarkerColor "respawn" == "") then {
		getMarkerPos "campMkr"
	} else {
		getMarkerPos "respawn"
	};
	_pos set [2,0];
	// Loadout	
	_chosenSlotUnit = objNull;
	{
		if (!isPlayer _x) exitWith {
			_chosenSlotUnit = _x;
		};
	} forEach units (grpNetId call BIS_fnc_groupFromNetId);	
	if (!isNull _chosenSlotUnit) then {
		selectPlayer _chosenSlotUnit;
		removeAllActions _chosenSlotUnit;
		if (reviveDisabled < 3) then {
			[_chosenSlotUnit] call rev_addReviveToUnit;	
		};	
	} else {
		_class = (selectRandom unitList);
		[player, _class] execVM 'sunday_system\switchUnitLoadout.sqf';
		sleep 1;
		[player, _pos] call sun_jipNewUnit;
	};
	_allHCs = entities "HeadlessClient_F";
	_currentPlayers = allPlayers - _allHCs;
	_currentPlayers = _currentPlayers - [player];
	_tasks = [_currentPlayers select 0] call BIS_fnc_tasksUnit;
	{
		_taskDesc = [_x] call BIS_fnc_taskDescription;
		_taskDest = [_x] call BIS_fnc_taskDestination;		
		_taskState = [_x] call BIS_fnc_taskState;		
		_taskType = [_x] call BIS_fnc_taskType;		
		_id = [_x, player, _taskDesc, _taskDest, _taskState, 1, false, false, _taskType, true] call BIS_fnc_setTask;							
	} forEach _tasks;
	enableSentences true;
	cutText ["", "BLACK IN", 3];
	[] call fnc_missionText;	
};

sleep 2;
["objectivesSpawned"] spawn sun_randomCam;
cutText ["", "BLACK IN", 2];

//["Preload"] spawn BIS_fnc_arsenal;
//sleep 2;
diag_log format ["DRO: Player %1 waiting for factionDataReady", player];
waitUntil {(missionNameSpace getVariable ["factionDataReady", 0]) == 1};
diag_log format ["DRO: Player %1 received factionDataReady", player];
/*
_dialogPlayer = {
	if (isPlayer _x) exitWith {
		_x
	};
} forEach (units (group player));
*/
waitUntil {!isNil "topUnit"};
if (player == topUnit) then {
	waitUntil {!dialog};
	// Faction dialog
	diag_log "DRO: Create menu dialog";
	_handle = createDialog "sundayDialog";
	diag_log format ["DRO: Created dialog: %1", _handle];
	[] call compile preprocessFileLineNumbers "loadProfile.sqf";
	[] execVM "sunday_system\dialogs\populateStartupMenu.sqf";	
};	

//diag_log format ["DRO: Player %1 waiting for serverReady", player];
//waitUntil {(missionNameSpace getVariable ["serverReady", 0]) == 1};
//diag_log format ["DRO: Player %1 received serverReady", player];

if (player != topUnit) then {
	[toUpper "Please wait while mission is generated", "objectivesSpawned", 1, ""] spawn sun_callLoadScreen;
};

diag_log format ["DRO: Player %1 waiting for objectivesSpawned", player];
waitUntil{(missionNameSpace getVariable ["objectivesSpawned", 0]) == 1};
diag_log format ["DRO: Player %1 objectivesSpawned == 1", player];

// Get camera target point
_heightEnd = getTerrainHeightASL (missionNameSpace getVariable ["aoCamPos", []]);
_camEndPos = [(missionNameSpace getVariable "aoCamPos") select 0, (missionNameSpace getVariable ["aoCamPos", []]) select 1, 10];
_iconPos = ASLToAGL _camEndPos;

_aoLocationName = (missionNameSpace getVariable "aoLocationName");

// Create camera initial zoom point
_camDir = (random 360);
_initialCamPos = [_camEndPos, 3000, _camDir] call BIS_fnc_relPos;

// Create camera slowdown point
_extendPos = [_camEndPos, 200, _camDir] call BIS_fnc_relPos;
_heightStart = getTerrainHeightASL _extendPos;
if (_heightStart < _heightEnd) then {
	_heightStart = _heightEnd; 
};
if (_heightStart < 20) then {_heightStart = 0};
_camStartPos = [(_extendPos select 0), (_extendPos select 1), (_heightStart+15)];

_initialHeight = (_heightStart+50);
_initialCamPos set [2, _initialHeight];
_attempts = 0;
while {(terrainIntersectASL [_camStartPos, _initialCamPos])} do {
	if (_attempts > 10) exitWith {};
	_initialHeight = _initialHeight + 30;
	_initialCamPos set [2, _initialHeight];	
	_attempts = _attempts + 1;
	diag_log "DRO: Raised _initialCamPos";
};

// Init camera
cam = "camera" camCreate _initialCamPos;
diag_log format ["DRO: Player %1 waiting for randomCamActive", player];
waitUntil {!randomCamActive};
diag_log format ["DRO: Player %1 received randomCamActive", player];
cam cameraEffect ["internal", "BACK"];
cam camSetPos _initialCamPos;
cam camSetTarget _camEndPos;
cam camCommit 0;
if (timeOfDay == 4) then {
	camUseNVG true;
};	
cameraEffectEnableHUD false;
cam camPreparePos _camStartPos;
cam camCommitPrepared 3;

cutText ["", "BLACK IN", 3];
diag_log "DRO: Intro camera begun";

playmusic [musicIntroSting, 0];

sleep 3;
cam camPreparePos _camEndPos;
cam camPrepareFov 0.2;
cam camCommitPrepared 50;

[
	[
		[toUpper _aoLocationName, "align = 'center' shadow = '0' size = '2' font='EtelkaMonospaceProBold'"]		
	],
	0 * safezoneW + safezoneX,
	0.75 * safezoneH + safezoneY,
	false
] spawn BIS_fnc_typeText2;
sleep 7;
cutText ["", "BLACK OUT", 1];
10 fademusic 0;
sleep 1;

closeDialog 1;

cam cameraEffect ["terminate","back"];
camUseNVG false;
camDestroy cam;	
diag_log format ["DRO: Player %1 cam terminated", player];	

// Open map
_mapOpen = openMap [true, false];
mapAnimAdd [0, 0.05, markerPos "centerMkr"];
mapAnimCommit;
cutText ["", "BLACK IN", 1];
hintSilent "Close map when ready to access loadout menu";
diag_log format ["DRO: Player %1 map initialised", player];

waitUntil {!visibleMap};
diag_log format ["DRO: Player %1 map closed", player];
hintSilent "";

// Open lobby
_handle = CreateDialog "DRO_lobbyDialog";
diag_log format ["DRO: Player %1 created DRO_lobbyDialog: %2", player, _handle];
[] execVM "sunday_system\dialogs\populateLobby.sqf";

_actionID = player addAction ["Open Team Planning", 
	{
		_handle = CreateDialog "DRO_lobbyDialog";
		[] execVM "sunday_system\dialogs\populateLobby.sqf";
	}, nil, 6
];

while {
	((missionNameSpace getVariable ["lobbyComplete", 0]) == 0)
} do {
	sleep 0.2;	
	if ((getMarkerColor "campMkr" == "")) then {
		((findDisplay 626262) displayCtrl 6006) ctrlSetText "Insertion position: RANDOM";
	} else {
		((findDisplay 626262) displayCtrl 6006) ctrlSetText format ["Insertion position: %1", (mapGridPosition (getMarkerPos 'campMkr'))];			
	};
	{
		if (_x getVariable ["startReady", false] OR !isPlayer _x) then {
			((findDisplay 626262) displayCtrl (_x getVariable "unitNameTagIDC")) ctrlSetTextColor [0.05, 1, 0.5, 1];
		} else {
			((findDisplay 626262) displayCtrl (_x getVariable "unitNameTagIDC")) ctrlSetTextColor [1, 1, 1, 1];
		};
	} forEach (units group player);
	if (player == topUnit) then {
		_allHCs = entities "HeadlessClient_F";
		_allHPs = allPlayers - _allHCs;
		if (({(_x getVariable ["startReady", false])} count _allHPs) >= count _allHPs) then {
			missionNameSpace setVariable ['lobbyComplete', 1, true];	
		};	
	};
};

// Wait for host to press the start button
diag_log format ["DRO: Player %1 waiting for lobbyComplete", player];
waitUntil {((missionNameSpace getVariable ["lobbyComplete", 0]) == 1)};
diag_log format ["DRO: Player %1 received lobbyComplete", player];

// Close dialogs twice in case player has arsenal open
closeDialog 1;	
closeDialog 1;	

player removeAction _actionID;

(format ["DRO: Player %1 lobby closed", player]) remoteExec ["diag_log", 2, false];

//player setVariable ["playerLoadout", (getUnitLoadout player)];

cutText ["", "BLACK FADED"];

camLobby cameraEffect ["terminate","back"];
camUseNVG false;
camDestroy camLobby;
player switchCamera playerCameraView;
sleep 3;
//waitUntil {count (missionNameSpace getVariable ["startPos", []]) > 0};

enableSentences true;
cutText ["", "BLACK IN", 3];

// Mission info readout
[] call fnc_missionText;

// Start saving player loadout periodically
[] spawn {
	while {true} do {
		sleep 5;
		if (alive player) then {
			player setVariable ["respawnLoadout", getUnitLoadout player]; 
		};
	};
};
