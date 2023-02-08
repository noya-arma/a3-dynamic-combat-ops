//closeDialog 1;

//camLobby cameraEffect ["terminate","back"];
//camUseNVG false;
//camDestroy camLobby;	

_aoCoverMarker = createMarkerLocal ["aoCoverMkr", markerPos "centerMkr"];
_aoCoverMarker setMarkerShapeLocal "ELLIPSE";
_aoCoverMarker setMarkerBrushLocal "Border";
_aoCoverMarker setMarkerSizeLocal [2500, 2500];
_aoCoverMarker setMarkerColorLocal "ColorRed";

_mapOpen = openMap [true, false];
mapAnimAdd [0, 0.05, markerPos "centerMkr"];
mapAnimCommit;

player switchCamera "INTERNAL";
[
	"mapStartSelect",
	"onMapSingleClick",
	{		
		_hint1 = "";
		_hint2 = "";
		_newPos = (_pos isFlatEmpty [3, -1, 0.25, 50, 0, false]);
		if (count _newPos == 0) then {
			_hint1 = "Terrain too steep."
		};
		if (count (nearestTerrainObjects [_pos, ["TREE", "HOUSE"], 30, false, true]) > 0) then {
			_newPos = [];
			_hint2 = "Terrain objects too close."
		};
		if (count _newPos > 0) then {
			hintSilent "";
			deleteMarker "campMkr";
			customBasePos = _newPos;
			publicVariable "customBasePos";
			markerPlayerStart = createMarker ["campMkr", _newPos];
			markerPlayerStart setMarkerShape "ICON";
			markerPlayerStart setMarkerColor markerColorPlayers;
			markerPlayerStart setMarkerType "loc_Bunker";
			markerPlayerStart setMarkerSize [3, 3];
			markerPlayerStart setMarkerText "Base Position";
			if (_newPos inArea "aoCoverMkr") then {			
				markerPlayerStart setMarkerColor "ColorRed";
			};
			publicVariable "markerPlayerStart";
		} else {
			hint format ["Position not valid: %1 %2", _hint1, _hint2];
		};
	},
	[]
] call BIS_fnc_addStackedEventHandler;

[] spawn {
	hint "Could not find a random base location, please choose a position.";
	sleep 5;
	_hint1 = "<t align='center'><t size='1.2'>Base Placement</t><br /><br />";
	_hint2 = "Place your desired base location by clicking anywhere on the map.<br /><br />";
	_hint3 = "The <t color='#ff0000'>red marked radius</t> represents a recommended distance from the AO. Placing within this radius is valid but may cause engagements to begin immediately. The <t color='#0000ff'>blue marked areas</t> show potential airbases. Placing within these areas will cause any planes selected to spawn at the nearby runway.</t>";
	hintSilent parseText (_hint1 + _hint2 + _hint3);
};
/*
while {count customBasePos == 0} do {
	if (!visibleMap) exitWith {
		["sunday_system\dialogs\selectBaseFailsafe.sqf"] remoteExec ["execVM", topUnit];
	};
};
*/
waitUntil {!visibleMap};
deleteMarkerLocal _aoCoverMarker;
hintSilent "";
["mapStartSelect", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
player switchCamera playerCameraView;
[] execVM "sunday_system\generate_base\setupPlayersBase.sqf";