diag_log "DRO: Main DYN script started";

#include "sunday_system\sundayFunctions.sqf"
#include "sunday_system\droFunctions.sqf"
#include "sunday_system\dcoFunctions.sqf"
#include "sunday_system\generate_enemies\generateEnemiesFunctions.sqf"

[] execVM "sunday_system\objectsLibrary.sqf";

respawnTime = switch (paramsArray select 0) do {
	case 0: {20};
	case 1: {45};
	case 2: {90};
	case 3: {nil};
};
publicVariable "respawnTime";

waitUntil {(count ([] call BIS_fnc_listPlayers) > 0)};
_topUnit = (([] call BIS_fnc_listPlayers) select 0);
{
	[_x, false] remoteExec ["allowDamage", _x];
	[_x, "ALL"] remoteExec ["disableAI", _x];
} forEach units(group _topUnit);
topUnit = _topUnit;
publicVariable "topUnit";

_musicIntroStings = [
	"EventTrack02_F_EPB",
	"EventTrack02a_F_EPB",
	"EventTrack01a_F_EPA"
];
musicIntroSting = selectRandom _musicIntroStings;
publicVariable "musicIntroSting";

playersFaction = "";
enemyFaction = "";
civFaction = "";
pFactionIndex = 1;
publicVariable "pFactionIndex";
playersFactionAdv = [0,0,0];
publicVariable "playersFactionAdv";
eFactionIndex = 2;
publicVariable "eFactionIndex";
enemyFactionAdv = [0,0,0];
publicVariable "enemyFactionAdv";
cFactionIndex = 0;
publicVariable "cFactionIndex";

playerGroup = [];
customBasePos = [];
publicVariable "customBasePos";
randomSupports = 0;
publicVariable "randomSupports";

commandStyle = 0;
publicVariable "commandStyle";
startUnits = [[1, "RANDOMVEH", 2], [1, "RANDOMVEH", 2], [1, "RANDOMVEH", 2], [1, "RANDOMVEH", 2]];
publicVariable "startUnits";
squadVehicle = [2, "RANDOMVEH", 0];
publicVariable "squadVehicle";
startSupports = [[0, "NONE"], [0, "NONE"]];
publicVariable "startSupports";
firstLobbyOpen = true;
publicVariable "firstLobbyOpen";

reinforceCounter = 0;
supplyCounter = 0;
supplyUsed = false;

diag_log "DRO: Compile scripts";

fnc_defineFactionClasses = compile preprocessFile "sunday_system\defineFactionClasses.sqf";
fnc_generateCombatAO = compile preprocessFile "sunday_system\generateCombatAO.sqf";
fnc_generateCombatObjective = compile preprocessFile "sunday_system\generateCombatObjectives.sqf";	
fnc_secureRouteObjective = compile preprocessFile "sunday_system\objectives\secureRouteCombat.sqf";	
fnc_unitTaskObjective = compile preprocessFile "sunday_system\objectives\unitTaskObjective.sqf";	
fnc_reinfFriendly = compile preprocessFile "sunday_system\reinforceFriendly.sqf";

unitTasks = [];
blackList = [];

// *****
// EXTRACT FACTION DATA
// *****

// Check for factions that have units
_availableFactions = [];
availableFactionsData = [];
availableFactionsDataAll = [];
_unavailableFactions = [];

_factionsFiltered = [];
_factionsFilteredWithMen = [];

// Record all factions with valid vehicles
{
	if (isNumber (configFile >> "CfgVehicles" >> (configName _x) >> "scope")) then {
		if (((configFile >> "CfgVehicles" >> (configName _x) >> "scope") call BIS_fnc_GetCfgData) == 2) then {
			_factionClass = ((configFile >> "CfgVehicles" >> (configName _x) >> "faction") call BIS_fnc_GetCfgData);
			//_factionsWithUnits pushBackUnique _factionClass;		
			if ((configName _x) isKindOf "Man") then {
				_index = ([_factionsFilteredWithMen, _factionClass] call BIS_fnc_findInPairs);
				if (_index == -1) then {
					_factionsFilteredWithMen pushBack [_factionClass, 1];
					_factionsFiltered pushBack [_factionClass, 1];
				} else {
					_factionsFilteredWithMen set [_index, [((_factionsFilteredWithMen select _index) select 0), ((_factionsFilteredWithMen select _index) select 1)+1]];
					_factionsFiltered set [_index, [((_factionsFiltered select _index) select 0), ((_factionsFiltered select _index) select 1)+1]];
				}; 
			} else {
				_index = ([_factionsFiltered, _factionClass] call BIS_fnc_findInPairs);
				if (_index == -1) then {
					_factionsFiltered pushBack [_factionClass, 1];
				} else {
					_factionsFiltered set [_index, [((_factionsFiltered select _index) select 0), ((_factionsFiltered select _index) select 1)+1]];
				}; 
			};		
		};
	};
} forEach ("(configName _x) isKindOf 'AllVehicles'" configClasses (configFile / "CfgVehicles"));

diag_log "DCO: _factionsFiltered:";
{
	diag_log _x;
} forEach _factionsFiltered;

//diag_log format ["DCO: _factionsFilteredWithMen = %1", _factionsFilteredWithMen];

// Add factions that have men
{
	_thisFaction = (_x select 0);
	diag_log _thisFaction;
	_thisSideNum = ((configFile >> "CfgFactionClasses" >> _thisFaction >> "side") call BIS_fnc_GetCfgData);	
	
	if (!isNil "_thisSideNum") then {	
		if (typeName _thisSideNum == "TEXT") then {
			if ((["west", _thisSideNum, false] call BIS_fnc_inString)) then {
				_thisSideNum = 1;
			};
			if ((["east", _thisSideNum, false] call BIS_fnc_inString)) then {
				_thisSideNum = 0;
			};
			if ((["guer", _thisSideNum, false] call BIS_fnc_inString) || (["ind", _thisSideNum, false] call BIS_fnc_inString)) then {
				_thisSideNum = 2;
			};
		};		
		if (typeName _thisSideNum == "STRING") then {
			_thisSideNum = parseNumber _thisSideNum;			
		};
		diag_log _thisSideNum;
		if (typeName _thisSideNum == "SCALAR") then {			
			_thisFactionName = ((configFile >> "CfgFactionClasses" >> _thisFaction >> "displayName") call BIS_fnc_GetCfgData);			
			_thisFactionFlag = ((configfile >> "CfgFactionClasses" >> _thisFaction >> "flag") call BIS_fnc_GetCfgData);		
			if ((_x select 1) > 1) then {						
				if (!isNil "_thisFactionFlag") then {
					availableFactionsData pushBack [_thisFaction, _thisFactionName, _thisFactionFlag, _thisSideNum];
				} else {
					availableFactionsData pushBack [_thisFaction, _thisFactionName, "", _thisSideNum];
				};
			};
		};		
	};
} forEach _factionsFilteredWithMen;

// Add factions that have vehicles with or without men
{
	_thisFaction = (_x select 0);
	_thisSideNum = ((configFile >> "CfgFactionClasses" >> _thisFaction >> "side") call BIS_fnc_GetCfgData);
	if (!isNil "_thisSideNum") then {
		if (typeName _thisSideNum == "TEXT") then {
			if ((["west", _thisSideNum, false] call BIS_fnc_inString)) then {
				_thisSideNum = 1;
			};
			if ((["east", _thisSideNum, false] call BIS_fnc_inString)) then {
				_thisSideNum = 0;
			};
			if ((["guer", _thisSideNum, false] call BIS_fnc_inString) || (["ind", _thisSideNum, false] call BIS_fnc_inString)) then {
				_thisSideNum = 2;
			};
		};
		if (typeName _thisSideNum == "STRING") then {
			_thisSideNum = parseNumber _thisSideNum;			
		};		
		if (typeName _thisSideNum == "SCALAR") then {			
			_thisFactionName = ((configFile >> "CfgFactionClasses" >> _thisFaction >> "displayName") call BIS_fnc_GetCfgData);			
			_thisFactionFlag = ((configfile >> "CfgFactionClasses" >> _thisFaction >> "flag") call BIS_fnc_GetCfgData);		
			if ((_x select 1) > 1) then {						
				if (!isNil "_thisFactionFlag") then {
					availableFactionsDataAll pushBack [_thisFaction, _thisFactionName, _thisFactionFlag, _thisSideNum];
				} else {
					availableFactionsDataAll pushBack [_thisFaction, _thisFactionName, "", _thisSideNum];
				};
			};
		};
	};
} forEach _factionsFiltered;

publicVariable "availableFactionsData";
publicVariable "availableFactionsDataAll";

missionNameSpace setVariable ["factionDataReady", 1];
publicVariable "factionDataReady";

// Initialise potential AO markers
[] execVM "sunday_system\initAO.sqf";

// *****
// PLAYERS SETUP
// *****

waitUntil {(missionNameSpace getVariable "factionsChosen") == 1};

// *****
// Just kidding; ACE SETUP
// *****

diag_log "DRO: ACE setup?";

if (isClass (configfile >> "CfgPatches" >> "ace_main")) then { //Yay, we have ACE, lets do ACE things!
	diag_log "DRO: Beginning ACE setup";
	if (isClass (configfile >> "CfgPatches" >> "ace_medical")) then { //We have ACE Medical, lets use the medical settings.
		//Start with settings we're forcing our players to use, because we obviously hate them.
		["ace_medical_medicSetting_basicEpi", 0, true, true] call ace_common_fnc_setSetting; //We allow anyone to use Epinephrine.
		["ace_medical_increaseTrainingInLocations", true, true, true] call ace_common_fnc_setSetting; //Locations boost training.
		["ace_medical_useCondition_PAK", 0, true, true] call ace_common_fnc_setSetting; //PAKs can always be used.
		["ace_medical_useLocation_PAK", 0, true, true] call ace_common_fnc_setSetting; //PAKs can be used anywhere.
		["ace_medical_useLocation_SurgicalKit", 0, true, true] call ace_common_fnc_setSetting; //Surgical Kits can be used anywhere.

		//Settings that players can set.
		//if(ACE_medenableRevive > 0) then { //Disable Sunday Revive if we want to use ACE Revive.
			reviveDisabled = 3;
			publicVariable "reviveDisabled";
		//};
		["ace_medical_enableRevive", ACE_medenableRevive, true, true] call ace_common_fnc_setSetting;
		["ace_medical_maxReviveTime", ACE_medmaxReviveTime, true, true] call ace_common_fnc_setSetting;
		["ace_medical_amountOfReviveLives", ACE_medamountOfReviveLives, true, true] call ace_common_fnc_setSetting;
		["ace_medical_level", (ACE_medLevel + 1), true, true] call ace_common_fnc_setSetting; //Are you kidding me, ACE Team?
		["ace_medical_medicSetting", ACE_medmedicSetting, true, true] call ace_common_fnc_setSetting;
		if(ACE_medenableScreams == 0) then { //ArmA can't convert Numbers to Booleans, isn't that dandy?
			["ace_medical_enableScreams", false, true, true] call ace_common_fnc_setSetting;
		} else {
			["ace_medical_enableScreams", true, true, true] call ace_common_fnc_setSetting;
		};
		["ace_medical_enableUnconsciousnessAI", ACE_medenableUnconsciousnessAI, true, true] call ace_common_fnc_setSetting;
		if(ACE_medpreventInstaDeath == 0) then {
			["ace_medical_preventInstaDeath", false, true, true] call ace_common_fnc_setSetting;
		} else {
			["ace_medical_preventInstaDeath", true, true, true] call ace_common_fnc_setSetting;
		};
		["ace_medical_bleedingCoefficient", ACE_medbleedingCoefficient, true, true] call ace_common_fnc_setSetting;
		["ace_medical_painCoefficient", ACE_medpainCoefficient, true, true] call ace_common_fnc_setSetting;
		if(ACE_medenableAdvancedWounds == 0) then {
			["ace_medical_enableAdvancedWounds", false, true, true] call ace_common_fnc_setSetting;
		} else {
			["ace_medical_enableAdvancedWounds", true, true, true] call ace_common_fnc_setSetting;
		};
		["ace_medical_medicSetting_PAK", ACE_medmedicSetting_PAK, true, true] call ace_common_fnc_setSetting;
		["ace_medical_consumeItem_PAK", ACE_medconsumeItem_PAK, true, true] call ace_common_fnc_setSetting;
		["ace_medical_medicSetting_SurgicalKit", ACE_medmedicSetting_SurgicalKit, true, true] call ace_common_fnc_setSetting;
		["ace_medical_consumeItem_SurgicalKit", ACE_medconsumeItem_SurgicalKit, true, true] call ace_common_fnc_setSetting;
	};
	if (isClass (configfile >> "CfgPatches" >> "ace_medical")) then { //We have ACE Repair, lets use the repair settings.
		//More settings we force our players to use, further cementing our apathy towards them.
		["ace_repair_fullRepairLocation", 0, true, true] call ace_common_fnc_setSetting; //Full repair anywhere.
		["ace_repair_engineerSetting_fullRepair", 1, true, true] call ace_common_fnc_setSetting; //Only Engineers can full repair

		//Settings that players can set.
		["ace_repair_engineerSetting_Repair", ACE_repengineerSetting_Repair, true, true] call ace_common_fnc_setSetting;
		["ace_repair_consumeItem_ToolKit", ACE_repconsumeItem_ToolKit, true, true] call ace_common_fnc_setSetting;
		["ace_repair_wheelRepairRequiredItems", ACE_repwheelRepairRequiredItems, true, true] call ace_common_fnc_setSetting;
	};
	diag_log "DRO: Ended ACE setup";
} else {
	diag_log "DRO: ACE not detected";
};

// Get player faction
playersFactionName = (configFile >> "CfgFactionClasses" >> playersFaction >> "displayName") call BIS_fnc_GetCfgData;
_playerSideNum = (configFile >> "CfgFactionClasses" >> playersFaction >> "side") call BIS_fnc_GetCfgData;
playersSide = [_playerSideNum] call sun_getCfgSide;
playersSideCfgGroups = "West";
switch (playersSide) do {
	case east: {		
		playersSideCfgGroups = "East";		
	};
	case west: {		
		playersSideCfgGroups = "West";		
	};
	case resistance: {		
		playersSideCfgGroups = "Indep";		
	};
	case civilian: {
		playersSide = civilian
	};
};
publicVariable "playersSide";
publicVariable "playersSideCfgGroups";
diag_log format ["DRO: playersSide = %1, playersFaction = %2", playersSide, playersFaction];

diag_log "DRO: Define player group";
playerGroup = (units(group _topUnit));
groupPlayers = (group _topUnit);
groupLeader = leader groupPlayers;

groupPlayers = (group _topUnit);
grpNetId = group _topUnit call BIS_fnc_netId;
publicVariable "grpNetId";

publicVariable "playersSide";
publicVariable "playerGroup";
publicVariable "groupPlayers";
publicVariable "groupLeader";

// Keep group name assigned throughout setup process
[] spawn {
	while {(missionNameSpace getVariable ["playersReady", 0] == 0)} do {	
		if (isNull (grpNetId call BIS_fnc_groupFromNetId)) then {
			grpNetId = (group(([] call BIS_fnc_listPlayers) select 0)) call BIS_fnc_netId;
			publicVariable "grpNetId";
		};
	};
};

{
	removeFromRemainsCollector [_x];
} forEach playerGroup;

unitDirs = [];
{
	if (!isNull _x) then {
		unitDirs set [_forEachIndex, (getDir _x)];
	};
} forEach playerGroup;
publicVariable "unitDirs";

[((findDisplay 888888) displayCtrl 8889), "EXTRACTING FACTION DATA"] remoteExecCall ["ctrlSetText", 0];

// Prepare data for player lobby
[] call fnc_defineFactionClasses;

publicVariable "pCarClasses";
publicVariable "pHeliClasses";
publicVariable "pTankClasses";
publicVariable "pArtyClasses";
publicVariable "pMortarClasses";
publicVariable "pPlaneClasses";
publicVariable "pShipClasses";

pInfGroups = [];
_playersFaction = playersFaction;
if (playersFaction == "BLU_G_F") then {_playersFaction = "Guerilla"};
if (playersFaction == "BLU_GEN_F") then {_playersFaction = "Gendarmerie"};
{	
	_thisCategory = _x;
	{
		_thisGroup = _x;
		if (
			!(["diver", (configName _thisGroup)] call BIS_fnc_inString) &&
			!(["support", (configName _thisGroup)] call BIS_fnc_inString)
		) then {
			_save = true;
			{			
				_vehicle = ((_x >> "vehicle") call BIS_fnc_getCfgData);
				if !(_vehicle isKindOf "Man") then {_save = false};
			} forEach ([_thisGroup] call BIS_fnc_returnChildren);
			if (_save) then {pInfGroups pushBack [_thisGroup, ((_thisGroup >> "name") call BIS_fnc_getCfgData)]};
		};
	} forEach ([_thisCategory] call BIS_fnc_returnChildren);
} forEach ([configfile >> "CfgGroups" >> playersSideCfgGroups >> _playersFaction] call BIS_fnc_returnChildren);
diag_log format ["pInfGroups: %1", pInfGroups];
publicVariable "pInfGroups";

_pInfGroups8 = [];
_pInfGroupsNon8 = [];
{
	if (count ([(_x select 0)] call BIS_fnc_returnChildren) >= 8) then {		
		_pInfGroups8 pushBack (_x select 0);	
	} else {
		_pInfGroupsNon8 pushBack (_x select 0);
	};
} forEach pInfGroups;
diag_log format ["DRO: _pInfGroups8: %1", _pInfGroups8];
_startingLoadoutGroup = [];
if (count _pInfGroups8 > 0) then {
	_chosenGroup = selectRandom _pInfGroups8;
	{
		_startingLoadoutGroup pushBack ((_x >> "vehicle") call BIS_fnc_getCfgData);
	} forEach ([_chosenGroup] call BIS_fnc_returnChildren);
} else {
	if (count _pInfGroupsNon8 > 0) then {
		_chosenGroup = selectRandom _pInfGroupsNon8;
		{
			_startingLoadoutGroup pushBack ((_x >> "vehicle") call BIS_fnc_getCfgData);
		} forEach ([_chosenGroup] call BIS_fnc_returnChildren);
	};
};
diag_log format ["DRO: _startingLoadoutGroup: %1", _startingLoadoutGroup];

// Define unitList for all selectable lobby classes
unitList = [];
publicVariable "unitList";
{
	_displayName = ((configfile >> "CfgVehicles" >> _x >> "displayName") call BIS_fnc_getCfgData);
	_factionClass = ((configfile >> "CfgVehicles" >> _x >> "faction") call BIS_fnc_getCfgData);
	_factionName = ((configfile >> "CfgFactionClasses" >> _factionClass >> "displayName") call BIS_fnc_getCfgData);	
	unitList pushBackUnique [_x, _displayName, _factionName];
} forEach pInfClasses;
publicVariable "unitList";

// Init player unit lobby variables
{
	_thisUnitType = if (count _startingLoadoutGroup > 0) then {
		_desiredUnit = if (_forEachIndex < (count _startingLoadoutGroup)) then {
			_startingLoadoutGroup select _forEachIndex			
		} else {
			selectRandom _startingLoadoutGroup
		};		
		diag_log format ["DRO: _desiredUnit: %1", _desiredUnit];
		
		_index = {
			if ((_x select 0) == _desiredUnit) exitWith {_forEachIndex};
		} forEach unitList;
		
		unitList select _index		
	} else {
		selectRandom unitList
	};			
	_x setVariable ['unitLoadoutIDC', (1200 + _forEachIndex), true];
	_x setVariable ['unitArsenalIDC', (1300 + _forEachIndex), true];
	_x setVariable ['unitDeleteIDC', (1500 + _forEachIndex), true];
	_x setVariable ['unitNameTagIDC', (1700 + _forEachIndex), true];
	
	[[_x, _thisUnitType], 'sunday_system\switchUnitLoadout.sqf'] remoteExec ["execVM", _x, false];	
	
} forEach playerGroup;


// *****
// ENEMY SETUP
// *****

// Get enemy faction
enemyFactionName = (configFile >> "CfgFactionClasses" >> enemyFaction >> "displayName") call BIS_fnc_GetCfgData;
_enemySideNum = (configFile >> "CfgFactionClasses" >> enemyFaction >> "side") call BIS_fnc_GetCfgData;
enemySide = [_enemySideNum] call sun_getCfgSide;
enemySideCfgGroups = "Indep";
switch (enemySide) do {
	case east: {		
		enemySideCfgGroups = "East";		
	};
	case west: {		
		enemySideCfgGroups = "West";		
	};
	case resistance: {		
		enemySideCfgGroups = "Indep";		
	};
};
publicVariable "enemySide";
diag_log format ["DCO: Enemy side detected as %1", enemySide];

if (playersSide == enemySide) then {
	enemySide = switch (enemySide) do {
		case east: {resistance};
		default {east};				
	};
	publicVariable "enemySide";
	diag_log format ["DCO: Enemy side switched to %1", enemySide];
};



// *****
// DEFINE MARKER COLOURS
// *****

markerColorPlayers = [playersSide] call sun_setSideMarkerColor;
publicVariable "markerColorPlayers";
//markerColorEnemy = [enemySide] call sun_setSideMarkerColor;

markerColorEnemy = "colorOPFOR";
switch (enemySide) do {
	case west: {		
		markerColorEnemy = "colorBLUFOR";
	};
	case east: {		
		markerColorEnemy = "colorOPFOR";
	};
	case resistance: {		
		markerColorEnemy = "colorIndependent";
	};	
};

publicVariable "markerColorEnemy";

// *****
// AO SETUP
// *****

diag_log "DRO: Call AO script";
[((findDisplay 888888) displayCtrl 8889), "GENERATING AREA OF OPERATIONS"] remoteExecCall ["ctrlSetText", 0];

// Generate AO and collect data
[] call fnc_generateCombatAO;

// *****
// WEATHER & TIME
// *****

if (timeOfDay == 0) then {
	timeOfDay = [1,4] call BIS_fnc_randomInt;
};
publicVariable "timeOfDay";

_year = date select 0;
_month = if (month == 0) then {
	[1, 12] call BIS_fnc_randomInt
} else {
	month
};
_day = [1, 28] call BIS_fnc_randomInt;

if (typeName weatherOvercast == "STRING") then {
	[(random [0, 0.4, 1])] call BIS_fnc_setOvercast;
};

0 setFog 0;
simulWeatherSync;

_nextOvercast = (random 1);
_nextFog = if (_nextOvercast < 0.5) then {
	[(random 0.03), 0, 0];	
} else {
	[(random 0.10), 0, 0];
};

//2500 setFog _nextFog;

[2500, _nextOvercast] remoteExec ["setOvercast", 0, true];

diag_log format ["DRO: time of day is %1", timeOfDay];

// *****
// INTRO SETUP
// *****

// Intro Music
_musicArrayDay = [
	"LeadTrack02_F_EXP",	
	"AmbientTrack03_F",
	"LeadTrack02_F_EPA",
	"LeadTrack01_F_EPA",
	"LeadTrack03_F_EPA",
	"LeadTrack01_F_EPB",
	"LeadTrack06_F",
	"BackgroundTrack02_F_EPC",	
	"LeadTrack03_F_Mark",
	"LeadTrack02_F_EPB"
];
_musicArrayNight = [
	"AmbientTrack04_F",
	"AmbientTrack04a_F",
	"AmbientTrack01_F_EPB",
	"AmbientTrack01b_F",
	"AmbientTrack01_F_EXP",
	"LeadTrack03_F_EPA",
	"LeadTrack03_F_EPC",
	"BackgroundTrack04_F_EPC",
	"EventTrack03_F_EPC"	
];
_track = nil;
if (timeOfDay <= 2) then {
	_track = selectRandom _musicArrayDay;
} else {
	_track = selectRandom _musicArrayNight;
};
//[[_track,0,1],"bis_fnc_playmusic",true] call BIS_fnc_MP;

// Mission Name
_missionName = [] call dro_missionName;
missionNameSpace setVariable ["mName", _missionName];
publicVariable "mName";

missionNameSpace setVariable ["weatherChanged", 1];
publicVariable "weatherChanged";

// *****
// PLAYERS SETUP
// *****

// Change arsenal location
_officer = if (count pOfficerClasses > 0) then {
	selectRandom pOfficerClasses
} else {
	selectRandom pInfClasses
};
_grpOfficer = createGroup playersSide;
[_officer] joinSilent _grpOfficer;
briefingOfficer setUnitLoadout _officer;
[[briefingOfficer, "BRIEFING_POINT_LEFT", "MEDIUM"], BIS_fnc_ambientAnim] remoteExec ["call"]; 

// Setup player identities
_firstNameClass = (configFile >> "CfgWorlds" >> "GenericNames" >> pGenericNames >> "FirstNames");
firstNames = [];
for "_i" from 0 to count _firstNameClass - 1 do {
	firstNames pushBack (getText (_firstNameClass select _i));
};
_lastNameClass = (configFile >> "CfgWorlds" >> "GenericNames" >> pGenericNames >> "LastNames");
lastNames = [];
for "_i" from 0 to count _lastNameClass - 1 do {
	lastNames pushBack (getText (_lastNameClass select _i));
};

// Extract voice data
speakersArray = [];
{
	_thisVoice = (configName _x);	
	_scopeVar = typeName ((configFile >> "CfgVoice" >> _thisVoice >> "scope") call BIS_fnc_GetCfgData);
	switch (_scopeVar) do {
		case "STRING": {
			if ( ((configFile >> "CfgVoice" >> _thisVoice >> "scope") call BIS_fnc_GetCfgData) == "public") then {		
				{
					if (typeName _x == "STRING") then {
						if (pLanguage == _x) then {
							speakersArray pushBack _thisVoice;
						};
					};
				} forEach ((configFile >> "CfgVoice" >> _thisVoice >> "identityTypes") call BIS_fnc_GetCfgData);
			};	
		};		
		case "SCALAR": {
			if ( ((configFile >> "CfgVoice" >> _thisVoice >> "scope") call BIS_fnc_GetCfgData) == 2) then {		
				{			
					if (typeName _x == "STRING") then {
						if (pLanguage == _x) then {
							speakersArray pushBack _thisVoice;
						};
					};
				} forEach ((configFile >> "CfgVoice" >> _thisVoice >> "identityTypes") call BIS_fnc_GetCfgData);
			};	
		};		
	};	
} forEach ("true" configClasses (configFile / "CfgVoice"));

if (count speakersArray == 0) then {	
	switch (playersSide) do {
		case west: {
			speakersArray = ["Male01ENG", "Male02ENG", "Male03ENG", "Male04ENG", "Male05ENG", "Male06ENG", "Male07ENG", "Male08ENG", "Male10ENG", "Male11ENG", "Male12ENG", "Male01ENGB", "Male02ENGB", "Male03ENGB", "Male04ENGB", "Male05ENGB"];
		};
		case east: {
			speakersArray = ["Male01PER", "Male02PER", "Male03PER"];
		};
		case resistance: {
			speakersArray = ["Male01GRE", "Male02GRE", "Male03GRE", "Male04GRE", "Male05GRE", "Male06GRE"];
		};
	};	
};
publicVariable "firstNames";
publicVariable "lastNames";
publicVariable "speakersArray";
diag_log format ["DRO: Available voices: %1", speakersArray];

// Change units to correct ethnicity and voices
nameLookup = [];
{
	_thisUnit = _x;			
	if (count speakersArray > 0) then {
		_firstName = selectRandom firstNames;
		_lastName = selectRandom lastNames;
		_speaker = selectRandom speakersArray;
		[[_thisUnit, _firstName, _lastName, _speaker], 'sun_setNameMP', true] call BIS_fnc_MP;
		nameLookup pushBack [_firstName, _lastName, _speaker];
		_thisUnit setVariable ["respawnIdentity", [_thisUnit, _firstName, _lastName, _speaker], true];
	};			
} forEach playerGroup;
publicVariable "nameLookup";

missionNameSpace setVariable ["initArsenal", 1];
publicVariable "initArsenal";


// Enemy unit pool
enemyAAPool = [];
if (count eAAClasses > 0) then {	
	for "_aa" from 1 to ([1,2] call BIS_fnc_randomInt) step 1 do {
		enemyAAPool pushBack (selectRandom eAAClasses);
	};	
};
enemyGVPool = [];
_groundVehicles = eTankClasses + eCarTurretClasses;
if (count _groundVehicles > 0) then {	
	for "_gv" from 1 to ([20, 25] call BIS_fnc_randomInt) step 1 do {
		enemyGVPool pushBack (selectRandom _groundVehicles);
	};	
};
enemyHeliPool = [];
if (count eHeliClasses > 0) then {	
	for "_h" from 1 to ([6,9] call BIS_fnc_randomInt) step 1 do {
		enemyHeliPool pushBack (selectRandom eHeliClasses);
	};	
};
enemyPlanePool = [];
if (count ePlaneClasses > 0) then {	
	for "_p" from 1 to ([3,6] call BIS_fnc_randomInt) step 1 do {
		enemyPlanePool pushBack (selectRandom ePlaneClasses);
	};	
};

diag_log "DCO: Enemy force pools:";
diag_log enemyAAPool;
diag_log enemyGVPool;
diag_log enemyHeliPool;
diag_log enemyPlanePool;

// *****
// OBJECTIVES SETUP
// *****
[((findDisplay 888888) displayCtrl 8889), "GENERATING OBJECTIVES"] remoteExecCall ["ctrlSetText", 0];

allObjectives = [];
objData = [];
taskIDs = [];
// Get number of tasks
_numObjs = [1,2] call BIS_fnc_randomInt;
for "_i" from 1 to (_numObjs) step 1 do {
	[] call fnc_generateCombatObjective;
	sleep 1;	
};
waitUntil {(count allObjectives) == _numObjs};

// Based on task data, assign tasks to players
if (count objData > 0) then {
	{	
		_markerPos = getMarkerPos (_x select 3);
		_id = [(_x select 0), true, [(_x select 1), (_x select 2), (_x select 3)], [(_markerPos select 0), (_markerPos select 1), 0], "CREATED", 1, false, true, (_x select 4), true] call BIS_fnc_setTask;		
		//taskIDs pushBack _id;
		//diag_log format ["DRO: taskIDs is now: %1", taskIDs];	
		[(_x select 5), (_x select 0)] execVM "sunday_system\objectives\addTaskExtras.sqf";
	} forEach objData;
};

// *****
// CIVILIAN SETUP
// *****

missionNameSpace setVariable ["objectivesSpawned", 1, true];

// *****
// GENERATE ENEMIES
// *****
[((findDisplay 888888) displayCtrl 8889), "GENERATING ENEMIES"] remoteExecCall ["ctrlSetText", 0];
_enemiesHandle = [] execVM "sunday_system\generate_enemies\generateEnemiesCombat.sqf";

// *****
// WAIT FOR LOBBY COMPLETION
// *****

waitUntil {(missionNameSpace getVariable "lobbyComplete") == 1};

_setupPlayersHandle = [] execVM "sunday_system\generate_base\setupPlayersBase.sqf";

waitUntil {(missionNameSpace getVariable ["playersReady", 0] == 1)};
//waitUntil {scriptDone _setupPlayersHandle};

diag_log "DCO: setupPlayersBase completed";

_setupSideHandle = [startPos] execVM "sunday_system\generate_base\generateCombatSide.sqf";


//sleep 3;
//waitUntil {scriptDone _setupSideHandle};
//waitUntil {scriptDone _enemiesHandle};

// *****
// OTHER TASKING
// *****

// Add route tasks
if (count roadTasks > 0) then {
	for "_r" from 1 to ((count roadTasks) min ([1,3] call BIS_fnc_randomInt)) step 1 do {
		if ((random 1) > 0.4) then {
			[] call fnc_secureRouteObjective;
		};
	};
};

if (count unitTasks > 0) then {
	for "_u" from 1 to ((count unitTasks) min ([2,4] call BIS_fnc_randomInt)) step 1 do {		
		_thisTask = [unitTasks] call sun_selectRemove;
		[_thisTask] call fnc_unitTaskObjective;		
	};
};

// Add retreat triggers
[] execVM "sunday_system\generate_enemies\enemySectorRetreat.sqf";

// *****
// SEQUENCING
// *****

// Periodic enemy attacks after strength depleted
[] spawn {
	_totalEnemyStrength = {side _x == enemySide} count allUnits;
	waitUntil {({side _x == enemySide} count allUnits) < (_totalEnemyStrength * 0.5)};
	diag_log "DCO: Beginning enemy attack waves";
	[] spawn {
		_sleep = ([60, 120] call BIS_fnc_randomInt);			
		while {true} do {			
			sleep _sleep;
			_attackPos = if (count dcoSectors > 0) then {
				(selectRandom [getPos (selectRandom dcoSectors), (getPos (leader (grpNetId call BIS_fnc_groupFromNetId)))]);
			} else {
				(getPos (leader (grpNetId call BIS_fnc_groupFromNetId)))
			};			
			[eReinfPos, _attackPos] execVM "sunday_system\generate_enemies\enemyAttack.sqf";
			_sleep = _sleep + ([200, 300] call BIS_fnc_randomInt);
		};
	};
};
/*
// Wait until main tasks are complete
if (count objData > 0) then {
	waituntil { 
		sleep 10;
		
		_completeReturn = true;
		{
			if ([_x] call BIS_fnc_taskExists) then {
				_complete = [_x] call BIS_fnc_taskCompleted;
				if (!_complete) then {
					_completeReturn = false;
				};
			};
		} forEach taskIDs;
		_completeReturn	
	};
};
*/
// Assign sector tasks
// Check not all sectors have been completed
_continue = false;
{
	if !(triggerActivated _x) then {
		_continue = true;
	};
} forEach dcoSectors;

//taskIDs2 = [];
if (_continue) then {
	_sectorsTaskName = format ["task%1", floor(random 100000)];
	_sectorsTaskTitle = "Take all sectors";
	_sectorsTaskDesc = format ["Attack and hold <marker name='%1'>all sectors</marker> held by %2 troops.", "centerMkr", enemyFactionName];	
	_sectorTaskID = [_sectorsTaskName, true, [_sectorsTaskDesc, _sectorsTaskTitle, "centerMkr"], center, "CREATED", 1, false, true, "attack", true] call BIS_fnc_setTask;			

	{
		if !(triggerActivated _x) then {
			_thisSector = _x;
			_thisSectorPos = getPos _thisSector;
			_sectorLetter = _thisSector getVariable "sectorLetter";
			_markerName = _thisSector getVariable "marker";

			_taskSubName = format ["task%1", floor(random 100000)];
			_taskName = [_taskSubName, _sectorTaskID];

			_taskTitle = format ["Take Sector %1", _sectorLetter];
			_taskDesc = format ["Attack and hold <marker name='%1'>sector %3</marker> held by %2 troops.", _markerName, enemyFactionName, _sectorLetter];		
			
			_taskID = [_taskName, true, [_taskDesc, _taskTitle, _markerName], _thisSectorPos, "CREATED", 1, false, true, _sectorLetter, true] call BIS_fnc_setTask;
			_thisSector setVariable ['taskID', _taskID, true];			
			taskIDs pushBack _taskID;
		};

	} forEach dcoSectors;

	waituntil { 
		sleep 10;
		
		_completeReturn = true;
		{
			if ([_x] call BIS_fnc_taskExists) then {
				_complete = [_x] call BIS_fnc_taskCompleted;
				if (!_complete) then {
					_completeReturn = false;
				};
			};
		} forEach taskIDs;
		_completeReturn	
	};
	[_sectorTaskID, 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
};

sleep 5;

_RTBTaskDesc = format ["Return to <marker name='campMkr'>%1</marker> when you're ready to end the mission.", (missionNameSpace getVariable "publicCampName")];
_RTBTaskID = ["RTBTask", true, [_RTBTaskDesc, "RTB", "campMkr"], (getMarkerPos "campMkr"), "CREATED", 1, true, true, "exit", true] call BIS_fnc_setTask;

_trgEnd = createTrigger ["EmptyDetector", (getMarkerPos "campMkr"), true];
_trgEnd setTriggerArea [100, 100, 0, false];
_trgEnd setTriggerActivation ["ANY", "PRESENT", false];
_trgEnd setTriggerStatements [
	"
		({_x in thisList} count allPlayers) >= (count allPlayers)		
	",
	"			
		if (isMultiplayer) then {
			diag_log 'DRO: Ending MP mission: success';
			'Won' call BIS_fnc_endMissionServer;
		} else {
			diag_log 'DRO: Ending SP mission: success';
			'end1' call BIS_fnc_endMission;
		};					
	", 
	""
];
/*
if (isMultiplayer) then {
	diag_log 'DRO: Ending MP mission: success';
	'Won' call BIS_fnc_endMissionServer;
} else {
	diag_log 'DRO: Ending SP mission: success';
	'end1' call BIS_fnc_endMission;
};
*/		

