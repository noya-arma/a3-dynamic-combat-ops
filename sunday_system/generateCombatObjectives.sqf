fnc_reinfForTask = compile preprocessFile "sunday_system\objectives\reinforceForTask.sqf";
fnc_objectiveAA = compile preprocessFile "sunday_system\objectives\aaCombat.sqf";
fnc_objectiveCache = compile preprocessFile "sunday_system\objectives\cacheCombat.sqf";
fnc_objectiveMotor = compile preprocessFile "sunday_system\objectives\motorPoolCombat.sqf";


/*
{
	_markerName = (format ["mkrDebug%1", (random 10000)]);
	private _marker = createMarker [_markerName, _x];
	_marker setMarkerShape "ICON";
	_marker setMarkerType "mil_box_noShadow";				
	_marker setMarkerColor "ColorGreen";		
} forEach AO_flatPositions;
*/

private _styles = [];
if (count AO_flatPositions > 0) then {
	_styles pushBackUnique "CACHE";		
	if (count enemyGVPool > 0) then {
		_styles pushBackUnique "MOTOR";
	};
	if (count enemyAAPool > 0) then {
		_styles pushBackUnique "AA";
	};
};
if (count AO_buildingPositions > 0) then {
	_styles pushBackUnique "CACHE";	
};

if (count _styles > 0) then {
	_thisStyle = selectRandom _styles;
	switch (_thisStyle) do {
		case "AA": {
			//[] execVM "sunday_system\objectives\aaCombat.sqf";			
			[] call fnc_objectiveAA;
		};		
		case "CACHE": {
			//[] execVM "sunday_system\objectives\cacheCombat.sqf";
			[] call fnc_objectiveCache;
		};
		case "MOTOR": {
			//[] execVM "sunday_system\objectives\motorPoolCombat.sqf";
			[] call fnc_objectiveMotor;
		};		
		default {
			diag_log "DCO: No valid objectives found!";
		};
	};
};
