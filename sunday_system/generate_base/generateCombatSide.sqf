params ["_pos"];
_startTime = time;
diag_log format ["DCO: Generate combat side start time: %1", _startTime];

commandGroups = [];
commandGroupsInf = [];
commandGroupsVehicles = [];
commandGroupsHelis = [];
commandTransportsHeli = [];
commandTransportsGround = [];

// Add support systems
centerSide = createCenter sideLogic;
_logicGroupRequester = createGroup centerSide;
requester = _logicGroupRequester createUnit ["SupportRequester", getPos (leader (grpNetId call BIS_fnc_groupFromNetId)), [], 0, "FORM"];
{
	[requester, _x, -1] remoteExec ["BIS_fnc_limitSupport", 0, true];
	//[requester, _x, 0] call BIS_fnc_limitSupport;
} forEach [
	"Artillery",
	"CAS_Heli",
	"CAS_Bombing",
	"UAV",
	"Drop",
	"Transport"
];
transportProviders = [];
_logicGroupCAS = createGroup centerSide;
providerCAS = _logicGroupCAS createUnit ["SupportProvider_CAS_Heli", getPos (leader (grpNetId call BIS_fnc_groupFromNetId)), [], 0, "FORM"];
_logicGroupCASBomb = createGroup centerSide;
providerCASBomb = _logicGroupCASBomb createUnit ["SupportProvider_CAS_Bombing", getPos (leader (grpNetId call BIS_fnc_groupFromNetId)), [], 0, "FORM"];
_logicGroupArty = createGroup centerSide;
providerArty = _logicGroupArty createUnit ["SupportProvider_Artillery", getPos (leader (grpNetId call BIS_fnc_groupFromNetId)), [], 0, "FORM"];

// Init High Command
_groupLogic = createGroup sideLogic;
hcModule = _groupLogic createUnit ["HighCommand", position (leader (grpNetId call BIS_fnc_groupFromNetId)), [], 0, "NONE"];
hcModule synchronizeObjectsAdd [(leader (grpNetId call BIS_fnc_groupFromNetId))];

_airbase = [];
{
	if (startPos inArea ((_x select 2) select 1)) exitWith {
		_airbase = [(_x select 0), (_x select 1)];
	};
} forEach airportLocations;
diag_log format ["DCO: _airbase = %1", _airbase];

{
	deleteMarker ((_x select 2) select 0);
	deleteMarker ((_x select 2) select 1);
} forEach airportLocations;

// *****
// ALPHA
// *****

// Create squad vehicle
[squadVehicle, true, 0] execVM "sunday_system\generate_base\createBaseUnit.sqf";

diag_log startUnits;
{
	[_x, true, (_forEachIndex + 1)] execVM "sunday_system\generate_base\createBaseUnit.sqf";
} forEach startUnits;

// *****
// BRAVO
// *****

{
	[_x, false, (_forEachIndex + 1)] execVM "sunday_system\generate_base\createBaseUnit.sqf";
} forEach [[0, "RANDOMINF", 3], [0, "RANDOMINF", 3], [1, "RANDOMVEH", 3], [1, "RANDOMVEH", 3]];

// Supports
diag_log format ["DCO: startSupports = %1", startSupports];
_inc = 0;
{
	_inc = _inc + 1;
	_thisUnitClass = (_x select 1);	
	if (count _thisUnitClass > 0) then {
		if (_thisUnitClass == "RANDOM") then {
			_thisUnitClass = ((selectRandom supportVehicles) select 0);
		};
		_thisPos = [];
		_thisDir = 0;
		diag_log _thisUnitClass;		
		if (_thisUnitClass isKindOf "Helicopter") then {			
			if (count baseHelipads > 0) then {
				_pad = [baseHelipads] call sun_selectRemove;
				_thisPos = getPos _pad;
			} else {
				_thisPos = [_pos, 20, 80, 10, 0, 0.3, 0, [trgBase], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
			};							
		} else {
			_thisPos = [_pos, 20, 80, 8, 0, 1, 0, [trgBase], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
		};
		if (_thisUnitClass isKindOf "Plane") then {			
			if (count _airbase > 0) then {				
				_thisPos = (_airbase select 0) findEmptyPosition [0, 50, _thisUnitClass];
				_thisDir = [(_airbase select 0), [((_airbase select 1) select 0), ((_airbase select 1) select 1)]] call BIS_fnc_dirTo;
				//_thisDir = ((asin ((_airbase select 1) select 0)) + 90);
			} else {
				if (count baseHelipads > 0) then {
					_pad = [baseHelipads] call sun_selectRemove;
					_thisPos = getPos _pad;
				} else {
					_thisPos = [_pos, 20, 80, 10, 0, 0.3, 0, [trgBase], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
				};
			};			
		} else {
			_thisPos = [_pos, 20, 80, 8, 0, 1, 0, [trgBase], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
		};
		if !(_thisPos isEqualTo [0,0,0]) then {		
			_vehicle = objNull;				
			if (_thisUnitClass isKindOf "Plane") then {				
				_thisPos set [0, ((_thisPos select 0) + (random [-50, 0, 50]))];
				_thisPos set [1, ((_thisPos select 1) + (random [-50, 0, 50]))];
				_thisPos set [2, 1000];						
				_vehicle = createVehicle [_thisUnitClass, _thisPos, [], 0, "FLY"];						
				_vehicle setPos _thisPos;
				_vehicle flyInHeight 1000;								
			} else {
				_vehicle = createVehicle [_thisUnitClass, _thisPos, [], 0, "NONE"];	
			};						
			_vehicle setDir _thisDir;
			[_vehicle, playersSide] call sun_createVehicleCrew;
			_IDString = format ["C-%1 %2", _inc, ((configFile >> "CfgVehicles" >> _thisUnitClass >> "displayName") call BIS_fnc_GetCfgData)];
			(group _vehicle) setGroupIdGlobal [_IDString];			
			_supportTypes = ((configFile >> "CfgVehicles" >> _thisUnitClass >> "availableForSupportTypes") call BIS_fnc_GetCfgData);
			if ("Artillery" in _supportTypes) then {
				providerArty synchronizeObjectsAdd [_vehicle];
				// Move artillery into range if necessary
				_artyRanges = [_thisUnitClass] call dro_getArtilleryRanges;
				_trgArea = triggerArea trgAOC;
				_largestSize = if ((_trgArea select 0) > (_trgArea select 1)) then {(_trgArea select 0)} else {(_trgArea select 1)};		
				if (((_vehicle distance center) + _largestSize) > (_artyRanges select 1)) then {
					_moveDist = ((_vehicle distance center) + _largestSize) - (_artyRanges select 1);
					_dirToCenter = [_vehicle, center] call BIS_fnc_dirTo;
					(group _vehicle) addWaypoint [([_vehicle, _moveDist, _dirToCenter] call BIS_fnc_relPos), 0];
				} else {
					if (((_vehicle distance center) - _largestSize) < (_artyRanges select 0)) then {
						_moveDist = (_artyRanges select 0) - ((_vehicle distance center) + _largestSize);
						_dirAwayCenter = [center, _vehicle] call BIS_fnc_dirTo;
						(group _vehicle) addWaypoint [([_vehicle, _moveDist, _dirAwayCenter] call BIS_fnc_relPos), 0];
					};
				};
			};
			if ("CAS_Heli" in _supportTypes) then {
				providerCAS synchronizeObjectsAdd [_vehicle];
			};
			if ("Transport" in _supportTypes) then {
				//providerTransport synchronizeObjectsAdd [_vehicle];	
				transportProviders pushBack [_vehicle, _IDString];
			};
			if ("CAS_Bombing" in _supportTypes) then {
				providerCASBomb synchronizeObjectsAdd [_vehicle];
			};
			if (_vehicle isKindOf "Plane") then {								
				_wp = (group driver _vehicle) addWaypoint [getPos _vehicle, 0];
				_wp setWaypointType "LOITER";								
				_wp setWaypointLoiterType "CIRCLE";
				_wp setWaypointLoiterRadius 1000;
			};
		};
	};
} forEach startSupports;

{
	[_x, requester, providerArty] remoteExec ["BIS_fnc_addSupportLink", _x, true];	
} forEach (units (grpNetId call BIS_fnc_groupFromNetId));

[] execVM "sunday_system\generate_base\setupAttackStyles.sqf";

// Create command menu for heli transports
diag_log transportProviders;
if (count transportProviders > 0) then {
	publicVariable "transportProviders";
	[(leader (grpNetId call BIS_fnc_groupFromNetId)), "sunSupportTransport"] remoteExec ["BIS_fnc_addCommMenuItem", (leader (grpNetId call BIS_fnc_groupFromNetId)), true];
};

[[], "sun_playRadioRandom", true] call BIS_fnc_MP;
[
	["Platoon Bravo", "This is bravo lead, we will begin our assault once the route into the AO is secure.", 0] 	
] remoteExec ["BIS_fnc_EXP_camp_playSubtitles", 0, false];

// Add support heli links if AA task are completed
[] spawn {
	if !(isNil "AATasks") then {
		[] spawn {
			sleep 6;
			[] remoteExec ["sun_playRadioRandom", 0, false];
			//[] remoteExec ["dco_warningPP", 0, false];			
			[
				["HQ", "WARNING! Enemy AA emplacements are active, HQ is advising against the use of air assets until those threats are neutralized.", 0] 	
			] remoteExec ["BIS_fnc_EXP_camp_playSubtitles", 0, false];
		};				
	};
};

{
	[_x, requester, providerCAS] remoteExec ["BIS_fnc_addSupportLink", _x, true];	
	[_x, requester, providerCASBomb] remoteExec ["BIS_fnc_addSupportLink", _x, true];	
} forEach (units (grpNetId call BIS_fnc_groupFromNetId));

_mkrName = switch (playersSide) do {
	case west: {"respawn_vehicle_west"};
	case east: {"respawn_vehicle_east"};
	case resistance: {"respawn_vehicle_guerilla"};
};
_vehicleRespawnMkr = createMarker [_mkrName, _pos];
_vehicleRespawnMkr setMarkerShape "ICON";
_vehicleRespawnMkr setMarkerType "EmptyIcon";

publicVariable "commandGroups";
publicVariable "commandGroupsInf";
publicVariable "commandGroupsVehicles";
publicVariable "commandGroupsHelis";
publicVariable "commandTransportsHeli";
publicVariable "commandTransportsGround";


(group (leader (grpNetId call BIS_fnc_groupFromNetId))) setGroupIdGlobal ["A-1 Lead"];
hcRemoveAllGroups (leader (grpNetId call BIS_fnc_groupFromNetId));

[] remoteExec ["dco_mark3d", 0, true];

// Reinforcement listener
[] spawn {	
	_totalUnits = 0;	
	{			
		_totalUnits = _totalUnits + (count (units _x));
	} forEach commandGroupsInf;
	diag_log format ["DCO: Player platoon commandGroupsInf = %1", commandGroupsInf];
	diag_log format ["DCO: Player platoon full strength = %1", _totalUnits];
	_halfStrength = round (_totalUnits/2);
	while {true} do {
		sleep 30;
		_currentUnits = 0;		
		{			
			_currentUnits = _currentUnits + (count (units _x));
		} forEach commandGroupsInf;
		if (_currentUnits < _halfStrength) then {
			_groupArray = [getPos (leader (grpNetId call BIS_fnc_groupFromNetId)), [1,1], pReinfPos, ["CAR"]] call fnc_reinfFriendly;
			{
				commandGroupsInf pushBack _x;
				if (commandStyle == 0) then {
					(leader (grpNetId call BIS_fnc_groupFromNetId)) hcSetGroup [_x];	
				} else {
					[_x] call dco_attackClosestSector;
				};
			} forEach _groupArray;
			sleep 60;
		};
	};	
};
diag_log format ["DCO: Generate combat side end time: %1", time];
diag_log format ["DCO: Generate combat side total runtime: %1", (time - _startTime)];

