
disableSerialization;
/*
{
	((findDisplay 52525) displayCtrl (ctrlIDC _x)) ctrlSetFade 1;
	((findDisplay 52525) displayCtrl (ctrlIDC _x)) ctrlCommit 0;	
} forEach (allControls findDisplay 52525);
*/

menuSliderArray = [
	["INFO", 1140, 1141, 1142],
	["SCENARIO", 2300, 2255, 2256, 1109, 2107, 1107, 2105, 1110, 2108, 2110, 2111, 2112, 2113, 2114, 2115],
	["ENVIRONMENT", 1105, 2103, 1106, 2104, 1112, 2109, 2116, 1113, 1114, 1300, 1301],	
	//["OBJECTIVES", 1108, 2106, 2200, 2201, 2202, 2203, 2204, 2205, 2206, 2207, 2208, 2209, 2210, 2211],
	["ADVANCED FACTIONS", 3712, 3704, 3705, 3800, 3706, 3801, 3707, 3802, 3708, 3709, 3803, 3710, 3804, 3711, 3805]
];
menuSliderCurrent = 0;

// Add ACE menu options if ACE detected
//if (isClass (configfile >> "CfgPatches" >> "ace_main")) then {
if(false) then {
	menuSliderArray pushBack ["ACE OPTIONS", 6000, 6001, 6002, 6003, 6004, 6005, 6006, 6007, 6008, 6009, 6010, 6011, 6012, 6013, 6014, 6015, 6016, 6017, 6018, 6019, 6020, 6021];
	_index = lbAdd [6001, "Anyone"];
	_index = lbAdd [6001, "Engineer only"];
	_index = lbAdd [6003, "No"];
	_index = lbAdd [6003, "Yes"];
	_index = lbAdd [6005, "None"];
	_index = lbAdd [6005, "Toolkit"];
	_index = lbAdd [6007, "Disabled"];
	_index = lbAdd [6007, "Players only"];
	_index = lbAdd [6007, "Players and AI"];
	sliderSetRange [6009, 30, 300];
	sliderSetPosition [6009, ACE_medmaxReviveTime];
	sliderSetRange [6011, 0, 3];
	sliderSetPosition [6011, ACE_medamountOfReviveLives];
	_index = lbAdd [6013, "Basic"];
	_index = lbAdd [6013, "Advanced"];
	_index = lbAdd [6015, "Disable Medics"];
	_index = lbAdd [6015, "Basic"];
	_index = lbAdd [6015, "Advanced"];
	_index = lbAdd [6017, "Disabled"];
	_index = lbAdd [6017, "Enabled"];
	_index = lbAdd [6019, "Disabled"];
	_index = lbAdd [6019, "50/50"];
	_index = lbAdd [6019, "Enabled"];
	_index = lbAdd [6021, "Enabled"];
	_index = lbAdd [6021, "Disabled"];
	lbSetCurSel [6001, ACE_repengineerSetting_Repair];
	lbSetCurSel [6003, ACE_repconsumeItem_ToolKit];
	lbSetCurSel [6005, ACE_repwheelRepairRequiredItems];
	lbSetCurSel [6007, ACE_medenableRevive];
	lbSetCurSel [6013, ACE_medLevel];
	lbSetCurSel [6015, ACE_medmedicSetting];
	lbSetCurSel [6017, ACE_medenableScreams];
	lbSetCurSel [6019, ACE_medenableUnconsciousnessAI];
	lbSetCurSel [6021, ACE_medpreventInstaDeath];
	menuSliderArray pushBack ["ACE OPTIONS CONT", 6022, 6023, 6024, 6025, 6026, 6027, 6028, 6029, 6030, 6031, 6032, 6033, 6034, 6035];
	sliderSetRange [6023, 0, 10];
	sliderSetPosition [6023, ACE_medbleedingCoefficient * 10];
	sliderSetRange [6025, 0, 10];
	sliderSetPosition [6025, ACE_medpainCoefficient * 10];
	_index = lbAdd [6027, "Disabled"];
	_index = lbAdd [6027, "Enabled"];
	_index = lbAdd [6029, "Anyone"];
	_index = lbAdd [6029, "Medics only"];
	_index = lbAdd [6031, "No"];
	_index = lbAdd [6031, "Yes"];
	_index = lbAdd [6033, "Anyone"];
	_index = lbAdd [6033, "Medics only"];
	_index = lbAdd [6035, "No"];
	_index = lbAdd [6035, "Yes"];
	lbSetCurSel [6027, ACE_medenableAdvancedWounds];
	lbSetCurSel [6029, ACE_medmedicSetting_PAK];
	lbSetCurSel [6031, ACE_medconsumeItem_PAK];
	lbSetCurSel [6033, ACE_medmedicSetting_SurgicalKit];
	lbSetCurSel [6035, ACE_medconsumeItem_SurgicalKit];
	((findDisplay 52525) displayCtrl 6008) ctrlSetText format ["Bleedout Time: %1 Seconds", ACE_medmaxReviveTime];
	((findDisplay 52525) displayCtrl 6010) ctrlSetText format ["Revive Lives: %1", ACE_medamountOfReviveLives];
	((findDisplay 52525) displayCtrl 6022) ctrlSetText format ["Bleeding Coefficient: %1", ACE_medbleedingCoefficient];
	((findDisplay 52525) displayCtrl 6024) ctrlSetText format ["Pain Coefficient: %1", ACE_medpainCoefficient];	
};

ctrlSetFocus ((findDisplay 52525) displayCtrl 1150);

{	
	if ((ctrlIDC _x != 1098) && (ctrlIDC _x != 1052) && (ctrlIDC _x != 1053)) then {
		((findDisplay 52525) displayCtrl (ctrlIDC _x)) ctrlSetFade 0;
	};	
	if (ctrlIDC _x < 3000) then {
		((findDisplay 52525) displayCtrl (ctrlIDC _x)) ctrlCommit 0.3;
	}; 		
} forEach (allControls findDisplay 52525);
[] spawn {
	//sleep 2;
	((findDisplay 52525) displayCtrl 1098) ctrlSetFade 0;
	((findDisplay 52525) displayCtrl 1098) ctrlCommit 1.5;
};
_index = lbAdd [2103, "Random"];
_index = lbAdd [2103, "Dawn"];
_index = lbAdd [2103, "Day"];
_index = lbAdd [2103, "Dusk"];
_index = lbAdd [2103, "Night"];

lbAdd [2104, "Random"];
lbAdd [2104, "January"];
lbAdd [2104, "February"];
lbAdd [2104, "March"];
lbAdd [2104, "April"];
lbAdd [2104, "May"];
lbAdd [2104, "June"];
lbAdd [2104, "July"];
lbAdd [2104, "August"];
lbAdd [2104, "September"];
lbAdd [2104, "October"];
lbAdd [2104, "November"];
lbAdd [2104, "December"];

lbAdd [2116, "Random"];
lbAdd [2116, "Custom"];

_index = lbAdd [2105, "Action - Normal"];
_index = lbAdd [2105, "Action - Hard"];
_index = lbAdd [2105, "Realism"];

_index = lbAdd [2107, "Enabled"];
_index = lbAdd [2107, "Disabled"];

_index = lbAdd [2108, "Enabled - 300 seconds"];
_index = lbAdd [2108, "Enabled - 120 seconds"];
_index = lbAdd [2108, "Enabled - 60 seconds"];
_index = lbAdd [2108, "Disabled"];

lbAdd [2113, "Enabled"];
lbAdd [2113, "Disabled"];

lbSetCurSel [2105, aiSkill];
lbSetCurSel [2106, numObjectives];
lbSetCurSel [2107, aoOptionSelect];
lbSetCurSel [2108, reviveDisabled];
lbSetCurSel [2113, minesEnabled];
lbSetCurSel [2104, month];
[1301] call dro_inputDaysData;
lbSetCurSel [1301, day];

diag_log format ["timeOfDay = %1", timeOfDay];	
lbSetCurSel [2103, timeOfDay];

// Slider items
sliderSetRange [2111, 5, 30];
((findDisplay 52525) displayCtrl 2110) ctrlSetText format ["Enemy force size multiplier: x%1", profileNamespace getVariable ['DRO_aiMultiplier', 0]];
sliderSetPosition [2111, aiMultiplier*10];

sliderSetRange [2109, 0, 10];

if (typeName weatherOvercast == "STRING") then {	
	sliderSetPosition [2109, 3];
	lbSetCurSel [2116, 0];
} else {	
	sliderSetPosition [2109, (weatherOvercast*10)];
	lbSetCurSel [2116, 1];
};

if (!isNil "aoName") then {
	ctrlSetText [2202, format ["AO location: %1", aoName]];
};

{
	_indexP = lbAdd [_x, "NONE"];					
	lbSetData [_x, _indexP, ""];
	lbSetColor [_x, _indexP, [1, 1, 1, 1]];	
} forEach [3800, 3801, 3802, 3803, 3804, 3805];	

{
	_index = lbAdd [_x, "RANDOM"];					
	lbSetData [_x, _index, "RANDOM"];
} forEach [2100, 2101];	

_pFactionSel = pFactionIndex;
_eFactionSel = eFactionIndex;


{	
	_thisFaction = (_x select 0);
	_thisFactionName = (_x select 1);
	_thisFactionFlag = (_x select 2);
	_thisSideNum = (_x select 3);

	// Add factions to combo boxes
	_color = switch (_thisSideNum) do {
		case 1: {[0, 0.3, 0.6, 1]};
		case 0: {[0.5, 0, 0, 1]};
		case 2: {[0, 0.5, 0, 1]};
		case 3: {[1, 1, 1, 1]};	
		default {[1, 1, 1, 1]};	
	};				
	if (_thisSideNum == 3) then {
		_indexC = lbAdd [2102, _thisFactionName];					
		lbSetData [2102, _indexC, _thisFaction];
		lbSetColor [2102, _indexC, _color];
		if (!isNil "_thisFactionFlag") then {
			if (count _thisFactionFlag > 0) then {
				lbSetPicture [2102, _indexC, _thisFactionFlag];
				lbSetPictureColor [2102, _indexC, [1, 1, 1, 1]];
				lbSetPictureColorSelected [2102, _indexC, [1, 1, 1, 1]];
			};
		};
	} else {		
		_indexP = lbAdd [2100, _thisFactionName];					
		lbSetData [2100, _indexP, _thisFaction];
		lbSetColor [2100, _indexP, _color];
		if (!isNil "_thisFactionFlag") then {
			if (count _thisFactionFlag > 0) then {
				lbSetPicture [2100, _indexP, _thisFactionFlag];
				lbSetPictureColor [2100, _indexP, [1, 1, 1, 1]];
				lbSetPictureColorSelected [2100, _indexP, [1, 1, 1, 1]];
			};
		};
		if ((profileNamespace getVariable ["DCO_playersFaction", ""]) == _thisFaction) then {
			_pFactionSel = _indexP;
		};
		_indexE = lbAdd [2101, _thisFactionName];					
		lbSetData [2101, _indexE, _thisFaction];
		lbSetColor [2101, _indexE, _color];
		if (!isNil "_thisFactionFlag") then {
			if (count _thisFactionFlag > 0) then {
				lbSetPicture [2101, _indexE, _thisFactionFlag];
				lbSetPictureColor [2101, _indexE, [1, 1, 1, 1]];
				lbSetPictureColorSelected [2101, _indexE, [1, 1, 1, 1]];
			};
		};
		if ((profileNamespace getVariable ["DCO_enemyFaction", ""]) == _thisFaction) then {
			_eFactionSel = _indexE;
		};
	};				
} forEach availableFactionsData;

{
	_thisFaction = (_x select 0);
	_thisFactionName = (_x select 1);
	_thisFactionFlag = (_x select 2);
	_thisSideNum = (_x select 3);
	// Add factions to combo boxes
	_color = switch (_thisSideNum) do {
		case 1: {[0, 0.3, 0.6, 1]};
		case 0: {[0.5, 0, 0, 1]};
		case 2: {[0, 0.5, 0, 1]};
		case 3: {[1, 1, 1, 1]};
		default {[1, 1, 1, 1]};
	};				
	if (_thisSideNum != 3) then {			
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

lbSetCurSel [2100, _pFactionSel];
lbSetCurSel [2101, _eFactionSel];
lbSetCurSel [2102, cFactionIndex];
/*
lbSetCurSel [3800, (playersFactionAdv select 0)];
lbSetCurSel [3801, (playersFactionAdv select 1)];
lbSetCurSel [3802, (playersFactionAdv select 2)];
*/
lbSetCurSel [3803, (enemyFactionAdv select 0)];
lbSetCurSel [3804, (enemyFactionAdv select 1)];
lbSetCurSel [3805, (enemyFactionAdv select 2)];

// Search for incompatible mods
_modList = "";
/*
if ((configfile >> "CfgPatches" >> "ace_main") call Bis_fnc_getCfgIsClass) then {		
	_modList = composeText [_modList, lineBreak, "ACE3"];
};
*/
if (typeName _modList == "TEXT") then {
	_text = composeText ["Warning!", lineBreak, "The following mods may cause compatibility issues with this scenario:", lineBreak, _modList];
	((findDisplay 52525) displayCtrl 1053) ctrlSetStructuredText _text;
	[] spawn {
		disableSerialization;
		{
			_x ctrlSetFade 0;
		} forEach [((findDisplay 52525) displayCtrl 1052), ((findDisplay 52525) displayCtrl 1053)];
		{
			_x ctrlCommit 0.2;
		} forEach [((findDisplay 52525) displayCtrl 1052), ((findDisplay 52525) displayCtrl 1053)];
	};
};