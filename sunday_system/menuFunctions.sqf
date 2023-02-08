sun_selectFaction = {
	params ["_sideVar", "_control", "_index"];
	missionNameSpace setVariable [_sideVar, _index, true];
	publicVariable _sideVar;		
	_selectedFaction = _control lbData _index;
	
	_selectedSideNum = ((configFile >> "CfgFactionClasses" >> _selectedFaction >> "side") call BIS_fnc_GetCfgData);
	if (typeName _selectedSideNum == "TEXT") then {
		if ((["west", _selectedSideNum, false] call BIS_fnc_inString)) then {
			_selectedSideNum = 1;
		};
		if ((["east", _selectedSideNum, false] call BIS_fnc_inString)) then {
			_selectedSideNum = 0;
		};
		if ((["guer", _selectedSideNum, false] call BIS_fnc_inString) || (["ind", _selectedSideNum, false] call BIS_fnc_inString)) then {
			_selectedSideNum = 2;
		};
	};
	if (typeName _selectedSideNum == "STRING") then {
		_selectedSideNum = parseNumber _selectedSideNum;			
	};	
	
	switch (_sideVar) do {
		case "pFactionIndex": {
			{lbClear _x} forEach [3800, 3801, 3802];
			{
				_index = lbAdd [_x, "NONE"];					
				lbSetData [_x, _index, ""];
				lbSetColor [_x, _index, [1, 1, 1, 1]];	
			} forEach [3800, 3801, 3802];	
			{
				_thisFaction = (_x select 0);
				
				_thisFactionName = (_x select 1);
				_thisFactionFlag = (_x select 2);
				_thisSideNum = (_x select 3);
							
				_color = switch (_thisSideNum) do {
					case 1: {[0, 0.3, 0.6, 1]};
					case 0: {[0.5, 0, 0, 1]};
					case 2: {[0, 0.5, 0, 1]};
					case 3: {[1, 1, 1, 1]};
					default {[1, 1, 1, 1]};			
				};
				
				if (_thisSideNum == _selectedSideNum) then { 
					{
						_indexP = lbAdd [_x, _thisFactionName];					
						lbSetData [_x, _indexP, _thisFaction];
						lbSetColor [_x, _indexP, _color];
						if (!isNil "_thisFactionFlag") then {
							if (count _thisFactionFlag > 0) then {
								lbSetPicture [_x, _indexP, _thisFactionFlag];
								lbSetPictureColor [_x, _indexP, [1, 1, 1, 1]];
								lbSetPictureColorSelected [_x, _indexP, [1, 1, 1, 1]];
							};
						};
					} forEach [3800, 3801, 3802];
				};
			} forEach availableFactionsDataAll;
			lbSetCurSel [3800, 0];
			lbSetCurSel [3801, 0];
			lbSetCurSel [3802, 0];			
		};
		/*
		case "eFactionIndex": {
			{lbClear _x} forEach [3803, 3804, 3805];
			{
				_index = lbAdd [_x, "NONE"];					
				lbSetData [_x, _index, ""];
				lbSetColor [_x, _index, [1, 1, 1, 1]];	
			} forEach [3803, 3804, 3805];
			{
				_thisFaction = (_x select 0);
				_thisFactionName = (_x select 1);
				_thisFactionFlag = (_x select 2);
				_thisSideNum = (_x select 3);				
				_color = switch (_thisSideNum) do {
					case 1: {[0, 0.3, 0.6, 1]};
					case 0: {[0.5, 0, 0, 1]};
					case 2: {[0, 0.5, 0, 1]};
					case 3: {[1, 1, 1, 1]};
					default {[1, 1, 1, 1]};					
				};
				if (_thisSideNum == _selectedSideNum) then { 
					{						
						_indexE = lbAdd [_x, _thisFactionName];					
						lbSetData [_x, _indexE, _thisFaction];
						lbSetColor [_x, _indexE, _color];
						if (!isNil "_thisFactionFlag") then {
							if (count _thisFactionFlag > 0) then {
								lbSetPicture [_x, _indexE, _thisFactionFlag];
								lbSetPictureColor [_x, _indexE, [1, 1, 1, 1]];
								lbSetPictureColorSelected [_x, _indexE, [1, 1, 1, 1]];
							};
						};					
					} forEach [3803, 3804, 3805];
				};
			} forEach availableFactionsDataAll;
			lbSetCurSel [3803, 0];
			lbSetCurSel [3804, 0];
			lbSetCurSel [3805, 0];
		};
		*/
	};
	
};

sun_lobbyReadyButton = {
	if (player getVariable ['startReady', false]) then {
		player setVariable ['startReady', false, true];
		((findDisplay 626262) displayCtrl 1601) ctrlSetEventHandler ["MouseEnter", "(_this select 0) ctrlsettextcolor [0,0,0,1]"];
		((findDisplay 626262) displayCtrl 1601) ctrlSetEventHandler ["MouseExit", "(_this select 0) ctrlsettextcolor [1,1,1,1]"];
		((findDisplay 626262) displayCtrl 1601) ctrlSetTextColor [0,0,0,1];
	} else {
		player setVariable ['startReady', true, true];
		((findDisplay 626262) displayCtrl 1601) ctrlSetEventHandler ["MouseEnter", "(_this select 0) ctrlsettextcolor [0.04, 0.7, 0.4, 1]"];
		((findDisplay 626262) displayCtrl 1601) ctrlSetEventHandler ["MouseExit", "(_this select 0) ctrlsettextcolor [0.05, 1, 0.5, 1]"];
		((findDisplay 626262) displayCtrl 1601) ctrlSetTextColor [0.05, 1, 0.5, 1];
	};
};

sun_clearInsert = {
	deleteMarker 'campMkr';
	{
		[626262, 6006, "Insertion position: RANDOM"] remoteExec ["sun_lobbyChangeLabel", _x];	
	} forEach allPlayers;
};

sun_lobbyMapPreview = {
	closeDialog 1;
	camLobby cameraEffect ["terminate","back"];
	camUseNVG false;
	camDestroy camLobby;	
	_mapOpen = openMap [true, false];
	mapAnimAdd [0, 0.05, markerPos "centerMkr"];
	mapAnimCommit;
	player switchCamera "INTERNAL";
	waitUntil {!visibleMap};	
	_handle = CreateDialog "DRO_lobbyDialog";
	[] execVM "sunday_system\dialogs\populateLobby.sqf";
};

sun_lobbyChangeLabel = {
	disableSerialization;
	params ["_display", "_idc", "_label"];		
	if ((ctrlClassName ((findDisplay _display) displayCtrl _idc) == "sundayText") OR (ctrlClassName ((findDisplay _display) displayCtrl _idc) == "sundayTextMT")) then {
		((findDisplay _display) displayCtrl _idc) ctrlSetText _label;
	};
};

sun_lobbyCamTarget = {
	params ["_target"];
	if (camLobbyTarget != _target) then {
		((findDisplay 626262) displayCtrl 1159) ctrlSetPosition [1 * safezoneW + safezoneX, (ctrlPosition ((findDisplay 626262) displayCtrl 1159)) select 1, (ctrlPosition ((findDisplay 626262) displayCtrl 1159)) select 2, (ctrlPosition ((findDisplay 626262) displayCtrl 1159)) select 3];
		((findDisplay 626262) displayCtrl 1159) ctrlCommit 0.1;
		((findDisplay 626262) displayCtrl 1160) ctrlSetText "";
		((findDisplay 626262) displayCtrl 1160) ctrlSetFade 1;
		((findDisplay 626262) displayCtrl 1160) ctrlCommit 0;
		camLobbyTarget = _target;		
		_camPos = [(getPos _target), 3.4, (getDir _target)] call BIS_fnc_relPos;
		_camPos set [2, 1.1];
		_camTarget = [(getPos _target), 0.4, (getDir _target)+90] call BIS_fnc_relPos;
		_camTarget set [2, 0.9];
		camLobby camSetPos _camPos;
		camLobby camSetTarget _camTarget;
		camLobby camSetFocus [3.4, 1];
		camLobby camCommit 1;
		//sleep 1;
		[_target] spawn {
			_target = _this select 0;			
			_class = (configfile >> "CfgVehicles" >> (_target getVariable "unitClass") >> "displayName") call BIS_fnc_getCfgData;		
			_weapon	= (configfile >> "CfgWeapons" >> primaryWeapon _target >> "displayName") call BIS_fnc_getCfgData;			
			_string = format ["%2%1%3%1%4%1%5", "\n", name _target, rank _target, _class, _weapon];
			sleep 0.8;
			((findDisplay 626262) displayCtrl 1159) ctrlSetPosition [0.73 * safezoneW + safezoneX, (ctrlPosition ((findDisplay 626262) displayCtrl 1159)) select 1, (ctrlPosition ((findDisplay 626262) displayCtrl 1159)) select 2, (ctrlPosition ((findDisplay 626262) displayCtrl 1159)) select 3];			
			((findDisplay 626262) displayCtrl 1159) ctrlCommit 0.1;
			sleep 0.1;
			((findDisplay 626262) displayCtrl 1160) ctrlSetText _string;
			((findDisplay 626262) displayCtrl 1160) ctrlSetFade 0;
			((findDisplay 626262) displayCtrl 1160) ctrlCommit 0.2;
		};		
	};
};

dro_menuSlider = {
	disableSerialization;
	params ["_slide", "_display"];
	_currentMenu = menuSliderArray select menuSliderCurrent;	
	_selectedMenu = [];
	_menuSliderTarget = 0;
	switch (_slide) do {
		case "LEFT": {
			_menuSliderTarget = if (menuSliderCurrent == 0) then {((count menuSliderArray) - 1)} else {menuSliderCurrent - 1};
			_selectedMenu = menuSliderArray select _menuSliderTarget;
		};
		case "RIGHT": {
			_menuSliderTarget = if (menuSliderCurrent == ((count menuSliderArray) - 1)) then {0} else {menuSliderCurrent + 1};
			_selectedMenu = menuSliderArray select _menuSliderTarget;
		};
	};	
	// Slide current menu out to the left
	{
		if (_forEachIndex != 0) then {
			_thisCtrl = (_display displayCtrl _x);				
			_thisCtrl ctrlSetPosition [-0.4 * safezoneW + safezoneX, (ctrlPosition _thisCtrl) select 1, (ctrlPosition _thisCtrl) select 2, (ctrlPosition _thisCtrl) select 3];
			_thisCtrl ctrlCommit 0.1;
		};
	} forEach _currentMenu;
	sleep 0.1;
	// Slide next menu in from the left
	{
		if (_forEachIndex == 0) then {
			_thisCtrl = (_display displayCtrl 1101);
			_thisCtrl ctrlSetText _x;
		} else {
			_thisCtrl = (_display displayCtrl _x);				
			_thisCtrl ctrlSetPosition [0.02 * safezoneW + safezoneX, (ctrlPosition _thisCtrl) select 1, (ctrlPosition _thisCtrl) select 2, (ctrlPosition _thisCtrl) select 3];
			_thisCtrl ctrlCommit 0.2;
		};
	} forEach _selectedMenu;			
	menuSliderCurrent = _menuSliderTarget;		
};

dro_menuMap = {
	disableSerialization;
	_map = ((findDisplay 52525) displayCtrl 2251);
	_button = ((findDisplay 52525) displayCtrl 2255);
	
	if (isNil "mapOpen") then {		
		_map ctrlSetPosition [0.23 * safezoneW + safezoneX, 0.18 * safezoneH + safezoneY, 0, 0.59 * safezoneH];		
		_map ctrlCommit 0;
		_map ctrlSetPosition [0.23 * safezoneW + safezoneX, 0.18 * safezoneH + safezoneY, 0.59 * safezoneW, 0.59 * safezoneH];		
		_map ctrlCommit 0.2;
		mapOpen = true;
		_button ctrlSetText "Close Map";
		[
			"mapStartSelect",
			"onMapSingleClick",
			{
				deleteMarker "aoSelectMkr";
				_nearestMarker = [locMarkerArray, _pos] call BIS_fnc_nearestPosition;		
				markerPlayerStart = createMarker ["aoSelectMkr", getMarkerPos _nearestMarker];
				markerPlayerStart setMarkerShape "ICON";			
				markerPlayerStart setMarkerType "mil_dot";		
				markerPlayerStart setMarkerAlpha 0;		
				_loc = nearestLocation [getMarkerPos _nearestMarker, ""];
				aoName = text _loc;			
				selectedLocMarker setMarkerColor "ColorPink";		
				selectedLocMarker = _nearestMarker;				
				_nearestMarker setMarkerColor "ColorGreen";
				((findDisplay 52525) displayCtrl 2300) ctrlSetText format ["AO location: %1", aoName];
				publicVariableServer "markerPlayerStart";
				publicVariableServer "aoName";
				publicVariableServer "selectedLocMarker";
			},
			[]
		] call BIS_fnc_addStackedEventHandler;
	} else {
		if (mapOpen) then {
			["mapStartSelect", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
			_map ctrlSetPosition [0.23 * safezoneW + safezoneX, 0.18 * safezoneH + safezoneY, 0, 0.59 * safezoneH];
			_map ctrlCommit 0.1;
			sleep 0.1;
			_map ctrlSetPosition [0.23 * safezoneW + safezoneX, 0.18 * safezoneH + safezoneY, 0, 0];		
			_map ctrlCommit 0;
			mapOpen = false;
			_button ctrlSetText "Open Map";
		} else {
			_map ctrlSetPosition [0.23 * safezoneW + safezoneX, 0.18 * safezoneH + safezoneY, 0, 0.59 * safezoneH];		
			_map ctrlCommit 0;
			_map ctrlSetPosition [0.23 * safezoneW + safezoneX, 0.18 * safezoneH + safezoneY, 0.59 * safezoneW, 0.59 * safezoneH];		
			_map ctrlCommit 0.2;
			mapOpen = true;
			_button ctrlSetText "Close Map";
			[
				"mapStartSelect",
				"onMapSingleClick",
				{
					deleteMarker "aoSelectMkr";
					_nearestMarker = [locMarkerArray, _pos] call BIS_fnc_nearestPosition;		
					markerPlayerStart = createMarker ["aoSelectMkr", getMarkerPos _nearestMarker];
					markerPlayerStart setMarkerShape "ICON";			
					markerPlayerStart setMarkerType "mil_dot";		
					markerPlayerStart setMarkerAlpha 0;		
					_loc = nearestLocation [getMarkerPos _nearestMarker, ""];
					aoName = text _loc;				
					selectedLocMarker setMarkerColor "ColorPink";		
					selectedLocMarker = _nearestMarker;				
					_nearestMarker setMarkerColor "ColorGreen";
					((findDisplay 52525) displayCtrl 2300) ctrlSetText format ["AO location: %1", aoName];
					publicVariableServer "markerPlayerStart";
					publicVariableServer "aoName";
					publicVariableServer "selectedLocMarker";
				},
				[]
			] call BIS_fnc_addStackedEventHandler;			
		};
	};	
};

sun_callLoadScreen = {
	params ["_message", "_endVar", "_endValue", "_fadeType"];		
	disableSerialization;	
	_loadDisplay = findDisplay 46 createDisplay "SUN_loadScreen";	
	_loadScreen = _loadDisplay displayCtrl 8888;
	_loadScreenText = _loadDisplay displayCtrl 8889;
	
	_loadScreen ctrlSetFade 1;
	_loadScreenText ctrlSetFade 1;
	_loadScreen ctrlCommit 0;
	_loadScreenText ctrlCommit 0;
	
	_loadScreenText ctrlSetText _message;		
	_loadScreenText ctrlSetTextColor [1, 1, 1, 0.8];
	
	if (toUpper _fadeType == "BLACK") then {
		_loadScreen ctrlSetBackgroundColor [0, 0, 0, 1];
	};	
	
	_loadScreen ctrlSetFade 0;
	_loadScreenText ctrlSetFade 0;
	_loadScreen ctrlCommit 2;
	_loadScreenText ctrlCommit 2;

	sleep 2;	
	waitUntil {missionNameSpace getVariable _endVar == _endValue};
	_loadScreen ctrlSetFade 1;
	_loadScreenText ctrlSetFade 1;
	_loadScreen ctrlCommit 0.5;
	_loadScreenText ctrlCommit 0.5;
	sleep 0.5;
	_loadDisplay closeDisplay 1;	
};

sun_randomCam = {
	params ["_var"];	
	_worldCenterVal = (worldSize/2);
	_worldCenter = [_worldCenterVal, _worldCenterVal, 0];	
	_randomPos = [] call BIS_fnc_randomPos;	
	_randomPos set [2, (random [2, 5, 20])];
	_dir = [_randomPos, _worldCenter] call BIS_fnc_dirTo;
	_targetPos = [_randomPos, 600, _dir] call BIS_fnc_relPos;	
	_cam = "camera" camCreate _randomPos;
	randomCamActive = true;
	_cam cameraEffect ["internal", "BACK"];
	_cam camSetPos _randomPos;
	_cam camSetTarget _targetPos;	
	_cam camCommit 0;	
	cameraEffectEnableHUD false;
	showCinemaBorder false;
	["Mediterranean"] call BIS_fnc_setPPeffectTemplate;	
	_end = false;
	_blackOut = false;
	while {(missionNameSpace getVariable [_var, 0]) == 0} do {
		_startTime = time;		
		while {time < (_startTime + 10)} do {
			if (sunOrMoon < 1) then {camUseNVG true} else {camUseNVG false};			
			if ((missionNameSpace getVariable [_var, 0]) == 1) exitWith {_end = true};
		};
		if (_end) exitWith {_blackOut = true};
		cutText ["", "BLACK OUT", 2];
		_startTime = time;
		while {time < (_startTime + 2.5)} do {
			if ((missionNameSpace getVariable [_var, 0]) == 1) exitWith {_end = true};
		};		
		if (_end) exitWith {};
		_randomPos = [] call BIS_fnc_randomPos;		
		_randomPos set [2, (random [2, 5, 20])];
		_dir = [_randomPos, _worldCenter] call BIS_fnc_dirTo;
		_targetPos = [_randomPos, 600, _dir] call BIS_fnc_relPos;
		_cam camSetPos _randomPos;
		_cam camSetTarget _targetPos;	
		_cam camCommit 0;
		_startTime = time;
		while {time < (_startTime + 2)} do {
			if ((missionNameSpace getVariable [_var, 0]) == 1) exitWith {_end = true};
		};
		if (_end) exitWith {};
		cutText ["", "BLACK IN", 2];
	};
	if (_blackOut) then {
		cutText ["", "BLACK OUT", 2];
		sleep 2;
	};
	_cam cameraEffect ["terminate","back"];
	camUseNVG false;
	camDestroy _cam;
	["Default"] call BIS_fnc_setPPeffectTemplate;
	randomCamActive = false;
	/*
	if (_blackOut) then {
		sleep 1;
		cutText ["", "BLACK IN", 2];		
	};
	*/
	diag_log "DRO: Closed random cam";
};
