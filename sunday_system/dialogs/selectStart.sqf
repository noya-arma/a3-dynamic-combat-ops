closeDialog 1;

camLobby cameraEffect ["terminate","back"];
camUseNVG false;
camDestroy camLobby;	

_mapOpen = openMap [true, false];
mapAnimAdd [0, 0.05, markerPos "centerMkr"];
mapAnimCommit;

player switchCamera "INTERNAL";
[
	"mapStartSelect",
	"onMapSingleClick",
	{		
		deleteMarker "startMkr";
		customStartPos = _pos;
		publicVariable "customStartPos";
		markerPlayerStart = createMarker ["startMkr", _pos];
		markerPlayerStart setMarkerShape "ICON";
		markerPlayerStart setMarkerColor markerColorPlayers;
		markerPlayerStart setMarkerType "mil_end";
		markerPlayerStart setMarkerSize [1, 1];
		markerPlayerStart setMarkerText "Start Position";		
		publicVariable "markerPlayerStart";
	},
	[]
] call BIS_fnc_addStackedEventHandler;

waitUntil {!visibleMap};
["mapStartSelect", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
player switchCamera playerCameraView;
_handle = CreateDialog "DRO_lobbyDialog";
[] execVM "sunday_system\dialogs\populateLobby.sqf";