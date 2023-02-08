_allHCs = entities "HeadlessClient_F";
_allHPs = (units (group player)) - _allHCs;

_dialogPlayer = {
	if (isPlayer _x) exitWith {
		_x
	};
} forEach _allHPs;
diag_log format ["DRO: %2 considers dialog top control player to be: %2", player, _dialogPlayer];

disableSerialization;

_lobbyCamHandle = [] execVM "sunday_system\dialogs\initLobbyCam.sqf";
diag_log format ["DRO: Lobby cam script executed: %1", _lobbyCamHandle];

_lineSpacing = 0.06;
_paddingTop = 0.16;
{
	_x setDir (_x getVariable "startDir");	

	// Create delete checkbox
	_deleteControl = (findDisplay 626262) ctrlCreate ["DROCheckBoxRemove", (_x getVariable "unitDeleteIDC"), ((findDisplay 626262) displayCtrl 6060)];		
	_deleteControl ctrlSetPosition [0, ((_forEachIndex) * _lineSpacing) + _paddingTop, 0.05, 0.05];	
	_deleteControl ctrlSetEventHandler ["CheckBoxesSelChanged", (format ["_nil=[%1, _this]ExecVM 'sunday_system\dialogs\removeAI.sqf'", _x])];	
	_deleteControl ctrlCommit 0;	
	
	// Create nametag
	_nameControl = (findDisplay 626262) ctrlCreate ["DRONameButton", (_x getVariable "unitNameTagIDC"), ((findDisplay 626262) displayCtrl 6060)];	
	_nameControl ctrlSetPosition [0.05, ((_forEachIndex) * _lineSpacing) + _paddingTop, 0.2, 0.05];		
	if (isPlayer _x) then {		
		_nameControl ctrlSetText (format ["%1:", (name _x)]);
	} else {
		_nameControl ctrlSetText (format ["%1 (AI):", (name _x)]);
	};	
	_nameControl ctrlSetEventHandler ["ButtonClick", (format ["[%1] call sun_lobbyCamTarget", _x])];	
	_nameControl ctrlCommit 0;	
	
	// Create loadout switcher
	if ((player == _x) OR ((player == _dialogPlayer) && (!isPlayer _x))) then {
		_loadoutControl = (findDisplay 626262) ctrlCreate ["DROLoadoutSwitch", (_x getVariable "unitLoadoutIDC"), ((findDisplay 626262) displayCtrl 6060)];		
		_loadoutControl ctrlSetPosition [0.25, ((_forEachIndex) * _lineSpacing) + _paddingTop, 0.3, 0.05];	
		_loadoutControl ctrlSetEventHandler ["LBSelChanged", (format ["_nil=[%1, _this]ExecVM 'sunday_system\switchUnitLoadout.sqf'", _x])];	
		_loadoutControl ctrlCommit 0;	
	} else {		
		_loadoutControl = (findDisplay 626262) ctrlCreate ["sundayText", (_x getVariable "unitLoadoutIDC"), ((findDisplay 626262) displayCtrl 6060)];	
		_loadoutControl ctrlSetPosition [0.25, ((_forEachIndex) * _lineSpacing) + _paddingTop, 0.3, 0.05];		
		_loadoutControl ctrlSetBackgroundColor [0.1,0.1,0.1,1];		
		_loadoutControl ctrlSetTextColor [1,1,1,0.5];		
		_factionClass = ((configfile >> "CfgVehicles" >> (_x getVariable "unitClass") >> "faction") call BIS_fnc_getCfgData);
		_class = format ["%1 - %2", ((configfile >> "CfgVehicles" >> (_x getVariable "unitClass") >> "displayName") call BIS_fnc_getCfgData), ((configfile >> "CfgFactionClasses" >> _factionClass >> "displayName") call BIS_fnc_getCfgData)];		
		_loadoutControl ctrlSetText _class;	
		_loadoutControl ctrlCommit 0;
	};
	
	// Create VA button
	_VAControl = (findDisplay 626262) ctrlCreate ["DROVAButton", (_x getVariable "unitArsenalIDC"), ((findDisplay 626262) displayCtrl 6060)];		
	_VAControl ctrlSetPosition [0.55, ((_forEachIndex) * _lineSpacing) + _paddingTop, 0.05, 0.05];	
	_VAControl ctrlSetEventHandler ["ButtonClick", (format ["if (!isNil '%1') then {_nil=[%1]ExecVM 'sunday_system\dialogs\openArsenal.sqf'}", _x])];	
	_VAControl ctrlCommit 0;
		
} forEach _allHPs;

menuSliderArray = [	
	["SQUAD LOADOUT", 6060],
	["BASE OPTIONS", 6070],
	["PLATOON", 6080]	
];
menuSliderCurrent = 0;

{
	if ((ctrlIDC _x) != 1053) then {
		((findDisplay 626262) displayCtrl (ctrlIDC _x)) ctrlSetFade 0;
		((findDisplay 626262) displayCtrl (ctrlIDC _x)) ctrlCommit 0.3;
	};
} forEach (allControls findDisplay 626262);

if (player getVariable ['startReady', false]) then {
	((findDisplay 626262) displayCtrl 1601) ctrlSetEventHandler ["MouseEnter", "(_this select 0) ctrlsettextcolor [0.04, 0.7, 0.4, 1]"];
	((findDisplay 626262) displayCtrl 1601) ctrlSetEventHandler ["MouseExit", "(_this select 0) ctrlsettextcolor [0.05, 1, 0.5, 1]"];
	((findDisplay 626262) displayCtrl 1601) ctrlSetTextColor [0.05, 1, 0.5, 1];
};

{
	_thisUnit = _x;
	if ((player == _thisUnit) OR ((player == _dialogPlayer) && (!isPlayer _thisUnit))) then {
		// Populate unit classes
		
		// Get listbox for this unit, make sure it's clear and add all class options to it
		_thisLB = (_thisUnit getVariable "unitLoadoutIDC");
		
		lbClear _thisLB;
		{		
			_index = lbAdd [_thisLB, format ["%1 - %2", (_x select 1), (_x select 2)]];			
			lbSetData [_thisLB, _index, (_x select 0)];
		} forEach unitList;	
			
		if (typeName (_thisUnit getVariable "unitChoice") == "STRING") then {		
			if ((_thisUnit getVariable "unitChoice") == "CUSTOM") then {
				_index = lbAdd [_thisLB, "Custom Loadout"];
				lbSetData [_thisLB, _index, "CUSTOM"];
				lbSetCurSel [_thisLB, _index];
			} else {		
				for "_i" from 1 to (lbSize _thisLB) do {
					_className = lbData [_thisLB, (_i - 1)];
					if ((_thisUnit getVariable "unitChoice") == _className) then {
						lbSetCurSel [_thisLB, (_i - 1)];						
					};
				};
			};		
		};
		diag_log format ["DRO: populateLobby gave %1 a starting loadout of %2", _thisUnit, (_thisUnit getVariable "unitChoice")];
		
	};
	// Disable delete button for players
	if (isPlayer _thisUnit) then {
		ctrlEnable [(_thisUnit getVariable "unitDeleteIDC"), false];
	};
	
} forEach playerGroup;

lbAdd [6054, "Platoon commander"];
lbAdd [6054, "Cog in battle"];

// Insert basic options
{
	_index = lbAdd [(_x select 0), "Random Infantry"];
	lbSetData [(_x select 0), _index, "RANDOMINF"];
	_index = lbAdd [(_x select 0), "Random Vehicle"];
	lbSetData [(_x select 0), _index, "RANDOMVEH"];
	_index = lbAdd [(_x select 0), "None"];
	lbSetData [(_x select 0), _index, ""];	
} forEach [[6013, 6014], [6015, 6016], [6017, 6018], [6019, 6020]];

// Add basic options to squad vehicle
_index = lbAdd [6110, "Random Vehicle"];
lbSetData [6110, _index, "RANDOMVEH"];
_index = lbAdd [6110, "None"];
lbSetData [6110, _index, ""];	

// Insert infantry group options
{
	_thisGroup = _x;
	{		
		_index = lbAdd [_x, (_thisGroup select 1)];
		lbSetPicture [_x, _index, "\A3\ui_f\data\igui\cfg\simpleTasks\types\meet_ca.paa"];	
		lbSetPictureColor [_x, _index, [1, 1, 1, 1]];
		lbSetData [_x, _index, str (_thisGroup select 0)];			
	} forEach [6013, 6015, 6017, 6019];
} forEach pInfGroups;

// Insert vehicle options
_validVehicles = pHeliClasses + pTankClasses + pCarClasses + pArtyClasses + pPlaneClasses;
{
	_thisVehicle = _x;
	{		
		_index = lbAdd [_x, ((configfile >> "CfgVehicles" >> _thisVehicle >> "displayName") call BIS_fnc_getCfgData)];
		lbSetPicture [_x, _index, ((configfile >> "CfgVehicles" >> _thisVehicle >> "icon") call BIS_fnc_getCfgData)];	
		lbSetPictureColor [_x, _index, [1, 1, 1, 1]];
		lbSetData [_x, _index, _thisVehicle];		
	} forEach [6013, 6015, 6017, 6019, 6110];
} forEach _validVehicles;

{
	lbAdd [_x, "Empty"];
	lbAdd [_x, "Crewed"];	
	lbAdd [_x, "Crewed + Cargo"];	
	lbAdd [_x, "Random"];	
} forEach [6014, 6016, 6018, 6020];

// Supports
supportVehicles = [];
{
	_supportTypes = ((configFile >> "CfgVehicles" >> _x >> "availableForSupportTypes") call BIS_fnc_GetCfgData);
	if ("Artillery" in _supportTypes) then {
		supportVehicles pushBackUnique [_x, "Artillery: "];
	};
	if ("CAS_Heli" in _supportTypes) then {
		supportVehicles pushBackUnique [_x, "CAS: "];
	};
	if ("CAS_Bombing" in _supportTypes) then {
		supportVehicles pushBackUnique [_x, "CAS: "];
	};
	if ("Transport" in _supportTypes) then {
		supportVehicles pushBackUnique [_x, "Transport: "];
	};
} forEach (pHeliClasses + pArtyClasses + pPlaneClasses);

{
	_index = lbAdd [_x, "None"];	
	lbSetData [_x, _index, ""];	
	_index = lbAdd [_x, "Random"];
	lbSetData [_x, _index, "RANDOM"];	
} forEach [6031, 6032];
{
	_thisVehicle = _x select 0;
	_typeStr = _x select 1;
	{		
		_str = _typeStr + ((configfile >> "CfgVehicles" >> _thisVehicle >> "displayName") call BIS_fnc_getCfgData);
		_index = lbAdd [_x, _str];
		lbSetPicture [_x, _index, ((configfile >> "CfgVehicles" >> _thisVehicle >> "icon") call BIS_fnc_getCfgData)];	
		lbSetPictureColor [_x, _index, [1, 1, 1, 1]];
		lbSetData [_x, _index, _thisVehicle];		
	} forEach [6031, 6032];
} forEach supportVehicles;
publicVariable "supportVehicles";

if (player == _dialogPlayer) then {
	lbSetCurSel [6054, commandStyle];
	lbSetCurSel [6013, ((startUnits select 0) select 0)];
	lbSetCurSel [6015, ((startUnits select 1) select 0)];
	lbSetCurSel [6017, ((startUnits select 2) select 0)];
	lbSetCurSel [6019, ((startUnits select 3) select 0)];
	lbSetCurSel [6014, ((startUnits select 0) select 2)];
	lbSetCurSel [6016, ((startUnits select 1) select 2)];
	lbSetCurSel [6018, ((startUnits select 2) select 2)];
	lbSetCurSel [6020, ((startUnits select 3) select 2)];
	lbSetCurSel [6031, ((startSupports select 0) select 0)];
	lbSetCurSel [6032, ((startSupports select 1) select 0)];	
	lbSetCurSel [6110, 0];	
};

// Support options
lbAdd [6010, "Random"];
lbAdd [6010, "Custom"];
if (player == _dialogPlayer) then {
	lbSetCurSel [6010, randomSupports];
};


// If player is not _dialogPlayer then disable all other controls
if (player != _dialogPlayer) then {
	{
		if (_x != player) then {			
			ctrlEnable [(_x getVariable "unitArsenalIDC"), false];			
			ctrlEnable [(_x getVariable "unitDeleteIDC"), false];
		}
	} forEach playerGroup;
	ctrlEnable [6004, false];
	ctrlEnable [6005, false];
	ctrlEnable [6009, false];
	ctrlEnable [6010, false];
	ctrlEnable [6011, false];
	ctrlEnable [6013, false];
	ctrlEnable [6014, false];
	ctrlEnable [6015, false];
	ctrlEnable [6016, false];
	ctrlEnable [6017, false];
	ctrlEnable [6018, false];
	ctrlEnable [6019, false];
	ctrlEnable [6020, false];
	ctrlEnable [6050, false];
	ctrlEnable [6031, false];
	ctrlEnable [6032, false];
	ctrlEnable [6110, false];
};

// Remove controls for AI no longer in group
{
	if (isObjectHidden _x) then {		
		ctrlEnable [(_x getVariable "unitLoadoutIDC"), false];
		ctrlEnable [(_x getVariable "unitArsenalIDC"), false];		
		ctrlEnable [(_x getVariable "unitDeleteIDC"), true];
		((findDisplay 626262) displayCtrl (_x getVariable "unitDeleteIDC")) ctrlSetChecked true;		
	};	
} forEach playerGroup;

// Change name texts
/*
{
	if (isPlayer _x) then {		
		((findDisplay 626262) displayCtrl ((_x getVariable "unitLoadoutIDC")-1)) ctrlSetText (format ["%1:", (name _x)]);
	} else {
		((findDisplay 626262) displayCtrl ((_x getVariable "unitLoadoutIDC")-1)) ctrlSetText (format ["%1 (AI):", (name _x)]);
	};	
} forEach playerGroup;
*/
// Destroy camera and allow player control if lobby isn't complete and dialog is exited
waitUntil {!dialog};
if (((missionNameSpace getVariable "lobbyComplete") != 1)) then {	
	if (isNull (uiNamespace getVariable ["BIS_fnc_arsenal_cam", objNull ])) then {
		if (!visibleMap) then {
			camLobby cameraEffect ["terminate","back"];
			camUseNVG false;
			camDestroy camLobby;
			player switchCamera playerCameraView;
		};
	};	
};