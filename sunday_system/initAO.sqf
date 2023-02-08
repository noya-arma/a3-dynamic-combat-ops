_size = worldSize;
_worldCenter = (_size/2);
_locList = nearestLocations [[_worldCenter, _worldCenter], ["NameLocal","NameVillage","NameCity","NameCityCapital"], _size];

locMarkerArray = [];
selectedLocMarker = "";

{	
	//_mkrName = format ["%1", getPos _x];
	_mkrName = format ["locMkr%1", _forEachIndex];
	_thisMkr = createMarker [_mkrName, getPos _x];
	_thisMkr setMarkerShape "ICON";			
	_thisMkr setMarkerType "Select";
	_thisMkr setMarkerColor "ColorPink";
	_thisMkr setMarkerAlpha 1;
	locMarkerArray pushBack _mkrName;
} forEach _locList;

publicVariable "selectedLocMarker";
publicVariable "locMarkerArray";

airportLocations = [[((configfile >> "CfgWorlds" >> worldName >> "ilsPosition") call BIS_fnc_getCfgData), ((configfile >> "CfgWorlds" >> worldName >> "ilsTaxiOff") call BIS_fnc_getCfgData)]];
{
	airportLocations pushBack [((_x >> "ilsPosition") call BIS_fnc_getCfgData), ((_x >> "ilsTaxiOff") call BIS_fnc_getCfgData)];
} forEach ([configfile >> "CfgWorlds" >> worldName >> "SecondaryAirports"] call BIS_fnc_returnChildren);

//_airbaseMarkers = [];
{	
	//_mkrName = format ["%1", getPos _x];
	_mkrName = format ["airportMkr%1", random 100000];
	_labelMkr = createMarker [_mkrName, (_x select 0)];
	_labelMkr setMarkerShape "ICON";			
	_labelMkr setMarkerType "mil_arrow_noShadow";
	_labelMkr setMarkerSize [0.8, 0.8];
	_labelMkr setMarkerText "Airbase";
	_labelMkr setMarkerColor "ColorBlue";
	_labelMkr setMarkerDir ([(_x select 0), [((_x select 1) select 0), ((_x select 1) select 1)]] call BIS_fnc_dirTo);
	//_labelMkr setMarkerDir ((asin ((_x select 1) select 0)) + 90);
	
	_mkrName = format ["airportMkr%1", random 100000];	
	_airCoverMarker = createMarker [_mkrName, (_x select 0)];
	_airCoverMarker setMarkerShape "ELLIPSE";
	_airCoverMarker setMarkerBrush "Border";
	_airCoverMarker setMarkerSize [300, 300];
	_airCoverMarker setMarkerColor "ColorBlue";
	//_airbaseMarkers pushBack [_labelMkr, _airCoverMarker];
	(airportLocations select _forEachIndex) pushBack [_labelMkr, _airCoverMarker];
} forEach airportLocations;

{
	diag_log _x;
} forEach airportLocations;

publicVariable "airportLocations";