params ["_trigger"];

_task = (_trigger getVariable 'thisTask');
_taskPos = getPos _trigger;

[] remoteExec ["sun_playRadioRandom", 0];
[[playersSide, "HQ"], "Area clear, we're sending the supply drop now."] remoteExec ["sideChat", 0];

// Create positions
_spawnPos = startPos;
_spawnPos set [2, 150];
_destPos = [_taskPos, 2000, ([startPos, _taskPos] call BIS_fnc_dirTo)] call BIS_fnc_relPos;
_destPos set [2, 150];

sleep 30;

// Create helicopter
_heliType = selectRandom pHeliClasses;
_heli = createVehicle [_heliType, _spawnPos, [], 0, "FLY"];
_heli setPos _spawnPos;
createVehicleCrew _heli;
_heli flyInHeight 150;
_heli setCaptive true;

// Get support types
_chuteType = ['B_Parachute_02_F', 'O_Parachute_02_F', 'I_Parachute_02_F'] select ([WEST, EAST, RESISTANCE] find playersSide); 
_crateType = ['B_supplyCrate_F', 'O_supplyCrate_F', 'I_supplyCrate_F'] select ([WEST, EAST, RESISTANCE] find playersSide);

// Create waypoints
_vehGroup = (group (driver _heli));
private _vWP0 = _vehGroup addWaypoint [(getPos _heli), 0];	
_vWP0 setWaypointBehaviour "CARELESS";
_vWP0 setWaypointCombatMode "GREEN";
_vWP0 setWaypointSpeed "NORMAL";
_vWP0 setWaypointType "MOVE";
	
private _vWP1 = _vehGroup addWaypoint [_taskPos, 0];
_vWP1 setWaypointType "MOVE";

private _fail = false;
_taskPosAir = _taskPos;
_taskPosAir set [2, 150];
while {_heli distance _taskPosAir > 110} do {
	sleep 2;
	if (!alive _heli) exitWith {
		_fail = true;
	};
};

if (_fail) exitWith {
	[_task, 'CANCELED', true] spawn BIS_fnc_taskSetState;
	missionNamespace setVariable [format ['%1Completed', _task], 1, true];
};

waitUntil {_heli distance _taskPosAir < 110};

while {(count (waypoints (group (driver _heli)))) > 0} do {
	deleteWaypoint ((waypoints (group (driver _heli))) select 0);
};

_vWP2 = _vehGroup addWaypoint [_destPos, 0];
_vWP2 setWaypointType "MOVE";
_vWP2 setWaypointStatements ["true", "					
	{(vehicle this) deleteVehicleCrew _x} forEach crew (vehicle this);
	deleteVehicle (vehicle this);	
"];

_chute = createVehicle [_chuteType, [100, 100, 200], [], 0, 'FLY'];
_chute setPos [(getPos _heli) select 0, (getPos _heli) select 1, ((getPos _heli) select 2) - 50];
//_chute setPos [_taskPos select 0, _taskPos select 1, ((getPos _heli) select 2) - 50];
_crate = createVehicle [_crateType, position _chute, [], 0, 'NONE'];
[_crate, (grpNetId call BIS_fnc_groupFromNetId)] call sun_supplyCrate;
_crate attachTo [_chute, [0, 0, 0]];
waitUntil {((velocity _crate) select 1 > 1) || isNull _chute};
waitUntil {((velocity _crate) select 1 < 1) || isNull _chute};
detach _crate;
_chute setVelocity [0,5,0];

[_task, 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
missionNamespace setVariable [format ['%1Completed', _task], 1, true];

_markerName = format["supplyMkr%1", floor(random 10000)];
_markerSupply = createMarker [_markerName, (getPos _crate)];
_markerSupply setMarkerShape "ICON";
_markerSupply setMarkerType  "mil_flag";
_markerSupply setMarkerColor markerColorPlayers;
_markerSupply setMarkerText "Resupply";	
_markerSupply setMarkerAlpha 1;	