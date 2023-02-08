if (!isServer) exitWith {};

#include "sunday_system\sundayFunctions.sqf"

if (isClass (configfile >> "CfgPatches" >> "ace_weather")) then { //We have ACE Weather, oh god, we've gotta turn it off before it breaks everything!
	["ace_weather_useACEWeather", false, true, true] call ace_common_fnc_setSetting;
	["ace_weather_enableServerController", false, true, true] call ace_common_fnc_setSetting;
	["ace_weather_syncRain", false, true, true] call ace_common_fnc_setSetting;
	["ace_weather_syncWind", false, true, true] call ace_common_fnc_setSetting;
	["ace_weather_syncMisc", false, true, true] call ace_common_fnc_setSetting;	
};

cutText ["", "BLACK FADED"];
missionNameSpace setVariable ["factionDataReady", 0];
publicVariable "factionDataReady";
missionNameSpace setVariable ["weatherChanged", 0];
publicVariable "weatherChanged";
missionNameSpace setVariable ["factionsChosen", 0];
publicVariable "factionsChosen";
missionNameSpace setVariable ["arsenalComplete", 0];
publicVariable "arsenalComplete";
missionNameSpace setVariable ["aoCamPos", []];
publicVariable "aoCamPos";
missionNameSpace setVariable ["briefingReady", 0];
publicVariable "briefingReady";
missionNameSpace setVariable ["playersReady", 0];
publicVariable "playersReady";
missionNameSpace setVariable ["publicCampName", ""];
publicVariable "publicCampName";
missionNameSpace setVariable ["startPos", []];
publicVariable "startPos";
missionNameSpace setVariable ["initArsenal", 0];
publicVariable "initArsenal";
missionNameSpace setVariable ["allArsenalComplete", 0];
publicVariable "allArsenalComplete";
missionNameSpace setVariable ["aoComplete", 0];
publicVariable "aoComplete";
missionNameSpace setVariable ["objectivesSpawned", 0];
publicVariable "objectivesSpawned";
missionNameSpace setVariable ["aoLocationName", ""];
publicVariable "aoLocationName";
missionNameSpace setVariable ["aoLocation", ""];
publicVariable "aoLocation";
missionNameSpace setVariable ["lobbyComplete", 0];
publicVariable "lobbyComplete";
missionNameSpace setVariable ["playerUnitStandbyPosition", ([[],0,-1] call BIS_fnc_findSafePos), true];


// Initialize group management for server
["Initialize"] call BIS_fnc_dynamicGroups; 

[] execVM "start.sqf";

sleep 1;

missionNameSpace setVariable ["serverReady", 1];
publicVariable "serverReady";

