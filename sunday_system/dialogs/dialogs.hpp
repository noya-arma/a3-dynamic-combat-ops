class SUN_loadScreen {
	idd = 888888;
	movingenable = false;
	class controls {
		class loadScreen: sundayText
		{
			idc = 8888;
			style = ST_CENTER;
			text = "";
			fade = 1;
			x = 0 * safezoneW + safezoneX;
			y = 0 * safezoneH + safezoneY;
			w = 1 * safezoneW;
			h = 1 * safezoneH;
			colorBackground[] = { 0, 0, 0, 0 };			
		};
		class loadScreenText: sundayText
		{
			idc = 8889;
			style = ST_CENTER;
			text = "";
			fade = 1;
			x = 0 * safezoneW + safezoneX;
			y = 0.5 * safezoneH + safezoneY;
			w = 1 * safezoneW;
			h = 0.5 * safezoneH;
			colorBackground[] = { 0, 0, 0, 0 };
			font = "RobotoCondensed";
			sizeEx = 0.035;
		};
	};	
};

class DRO_facade {
	idd = 999999;
	movingenable = false;
	class controls {
		class facade: sundayText
		{
			idc = 9999;
			text = "";
			x = -2 * safezoneW + safezoneX;
			y = -2 * safezoneH + safezoneY;
			w = 2 * safezoneW;
			h = 2 * safezoneH;
			colorBackground[] = { 0, 0, 0, 1 };
			font = "RobotoCondensed";
			sizeEx = 0.033;
		};
	};
};

class DRO_lobbyDialog {
	idd = 626262;
	movingenable = false;
	
	class controls {
		class menuBackground1: sundayText {
			idc = 1050;			
			x = 0.0 * safezoneW + safezoneX;
			y = 0 * safezoneH + safezoneY;
			w = 0.3 * safezoneW;
			h = 1 * safezoneH;
			colorBackground[] = { 0.1, 0.1, 0.1, 0.6 };
			text = "";
		};
		class teamPlanningTitle: sundayHeading
		{
			idc = 1098;			
			text = "TEAM PLANNING";
			x = 0 * safezoneW + safezoneX;
			y = 0.016 * safezoneH + safezoneY;
			w = 0.3 * safezoneW;
			h = 0.21 * safezoneH;
			sizeEx = 0.1;
			//font = "EtelkaNarrowMediumPro";
		};		
		class sundayTitleChoose: sundayHeading
		{
			idc = 1101;			
			style = ST_CENTER;
			text = "SQUAD LOADOUT";
			x = 0 * safezoneW + safezoneX;
			y = 0.22 * safezoneH + safezoneY;
			w = 0.3 * safezoneW;
			h = 0.045 * safezoneH;
			sizeEx = 0.035;
			colorBackground[] = {0.20,0.40,0.65,1};
		};			
		class menuLeft: DROBasicButton
		{			
			idc = 1150;
			text = "<";
			x = 0 * safezoneW + safezoneX;
			y = 0.22 * safezoneH + safezoneY;
			w = 0.0225 * safezoneW;
			h = 0.045 * safezoneH;
			sizeEx = 0.06;			
			action = "['LEFT', (findDisplay 626262)] spawn dro_menuSlider";		
		};
		class menuRight: DROBasicButton
		{			
			idc = 1151;
			text = ">";
			x = 0.2775 * safezoneW + safezoneX;
			y = 0.22 * safezoneH + safezoneY;
			w = 0.0225 * safezoneW;
			h = 0.045 * safezoneH;
			sizeEx = 0.06;			
			action = "['RIGHT', (findDisplay 626262)] spawn dro_menuSlider";		
		};
		class loadoutGroup: RscControlsGroup {
			idc = 6060;			
			x = 0.02 * safezoneW + safezoneX;
			y = 0.3 * safezoneH + safezoneY;
			w = 0.3 * safezoneW;
			h = 0.6 * safezoneH;
			class Controls {
				class squadVehicleText: sundayText {
					idc = 6100;
					text = "Squad vehicle:";
					x = 0;
					y = 0;
					w = 0.125 * safezoneW;
					h = 0.04 * safezoneH;		
				};
				class squadVehicleCombo: DROCombo
				{			
					idc = 6110;					
					x = 0;
					y = 0.07;					
					w = 0.125 * safezoneW;
					h = 0.03 * safezoneH;			
					sizeEx = 0.03;			
					onLBSelChanged = "squadVehicle set [1, (_this select 0) lbData (_this select 1)]; publicVariable 'squadVehicle'";		
				};
			};				
		};
		class unitTextBG: sundayText {
			idc = 1159;
			text = "";
			x = 0.73 * safezoneW + safezoneX;			
			y = 0.14 * safezoneH + safezoneY;
			w = 0.27 * safezoneW;
			h = 0.1 * safezoneH;			
			colorBackground[] = { 0.1, 0.1, 0.1, 0.6 };			
		};		
		class unitText: sundayTextMT {
			idc = 1160;
			text = "";			
			x = 0.74 * safezoneW + safezoneX;			
			y = 0.15 * safezoneH + safezoneY;
			w = 0.26 * safezoneW;
			h = 0.08 * safezoneH;
			font = "RobotoCondensed";					
			sizeEx = 0.02 * safezoneH;
		};		
		class previewMap: DROBasicButton
		{
			idc = 1161;
			style = 48 + 2048;			
			text = "\A3\ui_f\data\igui\cfg\simpleTasks\types\map_ca.paa";			
			x = 0 * safezoneW + safezoneX;
			y = 0 * safezoneH + safezoneY;
			w = 0.2 * safezoneW;
			h = 1 * safezoneH;
			colorBackground[] = { 0, 0, 0, 1 };			
			fade = 0;
			action = "[] spawn sun_lobbyMapPreview";
		};
		class sundayInfoText: sundayText
		{
			idc = 1053;
			type = CT_STRUCTURED_TEXT;
			text = "";
			fade = 1;
			x = 0.82 * safezoneW + safezoneX;
			y = 0.3 * safezoneH + safezoneY;
			w = 0.18 * safezoneW;
			h = 0.645 * safezoneH;
			size = 0.033;
			colorBackground[] = { 0.1, 0.1, 0.1, 0.6 }; 
			class Attributes {				
				color = "#ffffff";
				valign = "middle";
			};			
		};
		class sundayStartButton: DROBigButton
		{
			idc = 1601;
			text = "READY";
			x = 0.82 * safezoneW + safezoneX;
			y = 0.945 * safezoneH + safezoneY;
			w = 0.18 * safezoneW;
			h = 0.055 * safezoneH;	
			sizeEx = 0.05;			
			action = "[] call sun_lobbyReadyButton;";			
		};			
		class baseGroup: RscControlsGroup {
			idc = 6070;			
			x = -0.4 * safezoneW + safezoneX;
			y = 0.3 * safezoneH + safezoneY;
			w = 0.26 * safezoneW;
			h = 0.6 * safezoneH;
			class Controls {
				class lobbySelectBaseText: sundayText {
					idc = 6006;
					text = "Base position: RANDOM";
					x = 0;
					y = 0;
					w = 0.26 * safezoneW;
					h = 0.04 * safezoneH;		
				};
				class lobbySelectBase: DROBasicButton
				{			
					idc = 6004;
					text = "Set";
					x = 0;
					y = 0.08;					
					w = 0.125 * safezoneW;
					h = 0.04 * safezoneH;			
					action = "_nil=[]ExecVM 'sunday_system\dialogs\selectBase.sqf';";		
				};
				class lobbySelectBaseClear: DROBasicButton
				{			
					idc = 6005;
					text = "Clear";
					x = 0.32;
					y = 0.08;
					w = 0.125 * safezoneW;
					h = 0.04 * safezoneH;		
					action = "deleteMarker 'campMkr';";		
				};				
			};
		};	
		class platoonGroup: RscControlsGroup {
			idc = 6080;			
			x = -0.4 * safezoneW + safezoneX;
			y = 0.3 * safezoneH + safezoneY;
			w = 0.26 * safezoneW;
			h = 0.6 * safezoneH;
			class Controls {
				class lobbyCommandText: sundayText {
					idc = 6053;
					text = "Player command style";
					x = 0;
					y = 0;
					w = 0.125 * safezoneW;
					h = 0.04 * safezoneH;					
				};
				class lobbyCommandCombo: DROCombo
				{
					idc = 6054;
					x = 0;
					y = 0.08;
					w = 0.125 * safezoneW;			
					sizeEx = 0.03;			
					onLBSelChanged = "commandStyle = (_this select 1); publicVariable 'commandStyle'";					
				};
				class lobbyCommandQ: DROBigButton
				{			
					idc = 6059;
					text = "?";
					x = 0.55;
					y = 0;
					w = 0.025 * safezoneW;
					h = 0.025 * safezoneW;
					colorText[] = {1,1,1,0.5};
					colorActive[] = {1,1,1,0.5};
					onMouseEnter = "(_this select 0) ctrlsettextcolor [0,0,0,1];";
					onMouseExit = "(_this select 0) ctrlsettextcolor [1,1,1,0.5];";
					sizeEx = 0.05;			
					action = "[] call dco_commandHelp";			
				};		
				class lobbyPlatoonText: sundayText {
					idc = 6057;
					text = "Player controlled platoon";
					x = 0;
					y = 0.16;
					w = 0.125 * safezoneW;
					h = 0.04 * safezoneH;		
				};
				class lobbyPlatoonQ: DROBigButton
				{			
					idc = 6055;
					text = "?";
					x = 0.55;
					y = 0.16;
					w = 0.025 * safezoneW;
					h = 0.025 * safezoneW;
					colorText[] = {1,1,1,0.5};
					colorActive[] = {1,1,1,0.5};
					onMouseEnter = "(_this select 0) ctrlsettextcolor [0,0,0,1];";
					onMouseExit = "(_this select 0) ctrlsettextcolor [1,1,1,0.5];";
					sizeEx = 0.05;			
					action = "[] call dco_platoonHelp";			
				};			
				class lobbyPlatoonCombo1: DROCombo
				{
					idc = 6013;
					x = 0;
					y = 0.24;
					w = 0.125 * safezoneW;			
					sizeEx = 0.03;			
					onLBSelChanged = "startUnits set [0, [(_this select 1), (_this select 0) lbData (_this select 1), ((startUnits select 0) select 2)]]; publicVariable 'startUnits'";					
				};
				class lobbyPlatoonCrewingCombo1: DROCombo
				{
					idc = 6014;
					x = 0.32;
					y = 0.24;
					w = 0.125 * safezoneW;	
					sizeEx = 0.03;
					onLBSelChanged = "startUnits set [0, [((startUnits select 0) select 0), ((startUnits select 0) select 1), (_this select 1)]]; publicVariable 'startUnits'; diag_log startUnits";
				};
				class lobbyPlatoonCombo2: DROCombo
				{
					idc = 6015;
					x = 0;
					y = 0.3;
					w = 0.125 * safezoneW;	
					sizeEx = 0.03;
					onLBSelChanged = "startUnits set [1, [(_this select 1), (_this select 0) lbData (_this select 1), ((startUnits select 1) select 2)]]; publicVariable 'startUnits'";					
				};
				class lobbyPlatoonCrewingCombo2: DROCombo
				{
					idc = 6016;
					x = 0.32;
					y = 0.3;
					w = 0.125 * safezoneW;	
					sizeEx = 0.03;			
					onLBSelChanged = "startUnits set [1, [((startUnits select 1) select 0), ((startUnits select 1) select 1), (_this select 1)]]; publicVariable 'startUnits'";
				};
				class lobbyPlatoonCombo3: DROCombo
				{
					idc = 6017;
					x = 0;
					y = 0.36;
					w = 0.125 * safezoneW;	
					sizeEx = 0.03;
					onLBSelChanged = "startUnits set [2, [(_this select 1), (_this select 0) lbData (_this select 1), ((startUnits select 2) select 2)]]; publicVariable 'startUnits'";			
				};
				class lobbyPlatoonTB3: DROCombo
				{
					idc = 6018;
					x = 0.32;
					y = 0.36;
					w = 0.125 * safezoneW;
					sizeEx = 0.03;			
					onLBSelChanged = "startUnits set [2, [((startUnits select 2) select 0), ((startUnits select 2) select 1), (_this select 1)]]; publicVariable 'startUnits'";
				};
				class lobbyPlatoonCombo4: DROCombo
				{
					idc = 6019;
					x = 0;
					y = 0.42;
					w = 0.125 * safezoneW;
					sizeEx = 0.03;
					onLBSelChanged = "startUnits set [3, [(_this select 1), (_this select 0) lbData (_this select 1), ((startUnits select 3) select 2)]]; publicVariable 'startUnits'";				
				};
				class lobbyPlatoonTB4: DROCombo
				{
					idc = 6020;
					x = 0.32;
					y = 0.42;
					w = 0.125 * safezoneW;
					sizeEx = 0.03;
					onLBSelChanged = "startUnits set [3, [((startUnits select 3) select 0), ((startUnits select 3) select 1), (_this select 1)]]; publicVariable 'startUnits'";
				};
				class lobbySupportsText: sundayText {
					idc = 6058;
					text = "Supports";
					x = 0;
					y = 0.48;
					w = 0.125 * safezoneW;
					h = 0.04 * safezoneH;		
				};
				class lobbySupportsQ: DROBigButton
				{			
					idc = 6056;
					text = "?";
					x = 0.55;
					y = 0.48;
					w = 0.025 * safezoneW;
					h = 0.025 * safezoneW;
					colorText[] = {1,1,1,0.5};
					colorActive[] = {1,1,1,0.5};
					onMouseEnter = "(_this select 0) ctrlsettextcolor [0,0,0,1];";
					onMouseExit = "(_this select 0) ctrlsettextcolor [1,1,1,0.5];";
					sizeEx = 0.05;
					action = "[] call dco_supportsHelp";			
				};
				class lobbySupportsCombo1: DROCombo
				{
					idc = 6031;
					x = 0;
					y = 0.56;
					w = 0.125 * safezoneW;
					sizeEx = 0.03;			
					onLBSelChanged = "startSupports set [0, [(_this select 1), (_this select 0) lbData (_this select 1)]]; publicVariable 'startSupports'";					
				};
				class lobbySupportsCombo2: DROCombo
				{
					idc = 6032;
					x = 0.32;
					y = 0.56;
					w = 0.125 * safezoneW;
					sizeEx = 0.03;			
					onLBSelChanged = "startSupports set [1, [(_this select 1), (_this select 0) lbData (_this select 1)]]; publicVariable 'startSupports'";					
				};						
			};
		};				
	};
};


class sundayDialog {
	idd = 52525;
	movingenable = false;
	widthRailWay = 1;
		
	class controls {		
		
		widthRailWay = 1;
		class menuBackground1: sundayText {
			idc = 1050;			
			x = 0.23 * safezoneW + safezoneX;
			y = 0 * safezoneH + safezoneY;
			w = 0.59 * safezoneW;
			h = 0.1 * safezoneH;
			colorBackground[] = { 0.1, 0.1, 0.1, 0.6 };
			text = "";
		};
		class menuBackground2: sundayText {
			idc = 1051;			
			x = 0.0 * safezoneW + safezoneX;
			y = 0 * safezoneH + safezoneY;
			w = 0.18 * safezoneW;
			h = 1 * safezoneH;
			colorBackground[] = { 0, 0, 0, 1 };			
			fade = 0;
			text = "";
		};	
		class sundayTitlePic: RscPicture
		{			
			idc = 1098;
			text = "images\combat_icon.paa";
			x = 0.025 * safezoneW + safezoneX;
			y = 0.0 * safezoneH + safezoneY;
			w = 0.13 * safezoneW;
			h = 0.21 * safezoneH;			
		};		
		class sundayWarningBox: sundayText
		{
			idc = 1052;
			text = "";
			fade = 1;
			x = 0.82 * safezoneW + safezoneX;
			y = 0.745 * safezoneH + safezoneY;
			w = 0.18 * safezoneW;
			h = 0.2 * safezoneH;
			colorBackground[] = { 0.1, 0.1, 0.1, 0.6 };
		};
		class sundayWarningText: sundayText
		{
			idc = 1053;
			type = CT_STRUCTURED_TEXT;
			text = "";
			fade = 1;
			x = 0.83 * safezoneW + safezoneX;
			y = 0.755 * safezoneH + safezoneY;
			w = 0.16 * safezoneW;
			h = 0.18 * safezoneH;
			size = 0.033;
			class Attributes {				
				color = "#ff0000";
				valign = "middle";
		};
		};				
		class sundayTitleChoose: sundayHeading
		{
			idc = 1101;			
			style = ST_CENTER;
			text = "INFO"; //--- ToDo: Localize;
			x = 0 * safezoneW + safezoneX;
			y = 0.22 * safezoneH + safezoneY;
			w = 0.18 * safezoneW;
			h = 0.045 * safezoneH;
			sizeEx = 0.035;
			colorBackground[] = {0.20,0.40,0.65,1};
		};		
		
		class menuLeft: DROBasicButton
		{			
			idc = 1150;
			text = "<";
			x = 0 * safezoneW + safezoneX;
			y = 0.22 * safezoneH + safezoneY;
			w = 0.0225 * safezoneW;
			h = 0.045 * safezoneH;
			sizeEx = 0.06;			
			action = "['LEFT', (findDisplay 52525)] spawn dro_menuSlider";		
		};
		class menuRight: DROBasicButton
		{			
			idc = 1151;
			text = ">";
			x = 0.1576 * safezoneW + safezoneX;
			y = 0.22 * safezoneH + safezoneY;
			w = 0.0225 * safezoneW;
			h = 0.045 * safezoneH;
			sizeEx = 0.06;			
			action = "['RIGHT', (findDisplay 52525)] spawn dro_menuSlider";		
		};
		
		class mapBox: RscMapControl
		{			
			idc = 2251;			
			x = 0.22 * safezoneW + safezoneX;
			y = 0.18 * safezoneH + safezoneY;
			w = 0;
			h = 0;	
			widthRailWay = 1;				
		};
						
		class sundayTitlePlayer: sundayText
		{
			idc = 1102;
			text = "Player faction"; //--- ToDo: Localize;
			x = 0.25 * safezoneW + safezoneX;
			y = 0.007 * safezoneH + safezoneY;
			w = 0.15 * safezoneW;
			h = 0.044 * safezoneH;
		};		
		class sundayComboPlayerFactions: DROCombo
		{
			idc = 2100;
			x = 0.254 * safezoneW + safezoneX;
			y = 0.042 * safezoneH + safezoneY;
			w = 0.16 * safezoneW;
			h = 0.035 * safezoneH;
			sizeEx = 0.045;
			rowHeight = 0.05;
			wholeHeight = 5 * 0.10;
			onLBSelChanged = "['pFactionIndex', (_this select 0), (_this select 1)] call sun_selectFaction;";				
		};		
		
		class sundayTitleEnemy: sundayText
		{
			idc = 1103;
			text = "Enemy faction"; //--- ToDo: Localize;
			x = 0.44 * safezoneW + safezoneX;
			y = 0.007 * safezoneH + safezoneY;
			w = 0.15 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class sundayComboEnemyFactions: DROCombo
		{
			idc = 2101;
			x = 0.444 * safezoneW + safezoneX;
			y = 0.042 * safezoneH + safezoneY;
			w = 0.16 * safezoneW;
			h = 0.035 * safezoneH;
			sizeEx = 0.045;
			rowHeight = 0.05;
			wholeHeight = 5 * 0.10;	
			onLBSelChanged = "eFactionIndex = (_this select 1); publicVariable 'eFactionIndex'";
		};
		class sundayTitleCivilians: sundayText
		{
			idc = 1104;
			text = "Civilian faction"; //--- ToDo: Localize;
			x = 0.63 * safezoneW + safezoneX;
			y = 0.007 * safezoneH + safezoneY;
			w = 0.15 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class sundayComboCivFactions: DROCombo
		{
			idc = 2102;
			x = 0.634 * safezoneW + safezoneX;
			y = 0.042 * safezoneH + safezoneY;
			w = 0.16 * safezoneW;
			h = 0.035 * safezoneH;
			sizeEx = 0.045;
			rowHeight = 0.05;
			wholeHeight = 5 * 0.10;	
			onLBSelChanged = "cFactionIndex = (_this select 1); publicVariable 'cFactionIndex'";			
		};
		
		class sundayStartButton: DROBigButton
		{
			idc = 1601;
			text = "START";
			x = 0.82 * safezoneW + safezoneX;
			y = 0.945 * safezoneH + safezoneY;
			w = 0.18 * safezoneW;
			h = 0.055 * safezoneH;	
			sizeEx = 0.05;			
			action = "_nil=[]ExecVM 'sunday_system\dialogs\okAO.sqf';";
		};	
		
		// INFO
		class welcomeHeading: sundayHeading
		{
			idc = 1140;
			text = "Welcome";
			x = 0.02 * safezoneW + safezoneX;
			y = 0.3 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.04 * safezoneH;
		};			
		class welcomeText: sundayTextMT
		{
			idc = 1141;
			text = "Dynamic Combat Ops is a randomised, replayable combined arms scenario that generates an enemy occupied area with a selection of tasks to complete and sectors to capture.\n\nYou can press the START button at the bottom right to immediately play a random scenario or use the arrow buttons above to scroll through the available customisation options.\n\nThanks for playing and have fun!";
			x = 0.02 * safezoneW + safezoneX;
			y = 0.35 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.4 * safezoneH;
		};	
		class clearData: DROBasicButton
		{			
			idc = 1142;
			text = "Reset Default Options";
			x = 0.02 * safezoneW + safezoneX;
			y = 0.9 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.04 * safezoneH;			
			action = "[] call dro_clearData";		
		};
		
		// ENVIRONMENT
		class sundayTitleTime: sundayText
		{
			idc = 1105;
			text = "Time of day"; //--- ToDo: Localize;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.48 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
	};
		class sundayTBTime: DROCombo
		{
			idc = 2103;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.34 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;						
			onLBSelChanged = "timeOfDay = (_this select 1); publicVariable 'timeOfDay'; [(_this select 1)] remoteExec ['sun_randomTime', 0, true]; profileNamespace setVariable ['DCO_timeOfDay', (_this select 1)];";		
		};
		class sundayTitleMonth: sundayText
		{
			idc = 1106;
			text = "Month"; //--- ToDo: Localize;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.36 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class sundayCBMonth: DROCombo
		{
			idc = 2104;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.4 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;						
			onLBSelChanged = "month = (_this select 1); publicVariable 'month'; ['MONTH', (_this select 1)] remoteExec ['sun_setDateMP', 0, true]; [1301] call dro_inputDaysData; profileNamespace setVariable ['DCO_month', (_this select 1)];";		
		};
		class sundayTitleDay: sundayText
		{
			idc = 1300;
			text = "Day"; //--- ToDo: Localize;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.42 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class sundayCBDay: DROCombo
		{
			idc = 1301;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.46 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "day = (_this select 1); publicVariable 'day'; ['DAY', (_this select 1)] remoteExec ['sun_setDateMP', 0, true]; profileNamespace setVariable ['DCO_day', (_this select 1)];";		
		};
		class sundayTitleWeather: sundayText
		{
			idc = 1112;
			text = "Weather";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.48 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class sundayCBWeather: DROCombo
		{
			idc = 2116;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.52 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "if ((_this select 1) == 0) then {weatherOvercast = 'RANDOM'} else {weatherOvercast = (round (((sliderPosition 2109)/10) * (10 ^ 3)) / (10 ^ 3))}; publicVariable 'weatherOvercast'; if (typeName weatherOvercast isEqualTo 'SCALAR') then {[weatherOvercast] call BIS_fnc_setOvercast;}; profileNamespace setVariable ['DCO_weatherOvercast', weatherOvercast];";		
		};
		class sundaySliderWeatherFair: sundayText
		{
			idc = 1113;
			text = "Fair";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.54 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class sundaySliderWeatherBad: sundayText
		{
			idc = 1114;
			style = ST_RIGHT;
			text = "Bad";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.54 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class sundaySliderWeather: sundaySlider
		{
			idc = 2109;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.58 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onSliderPosChanged = "_mult = ((_this select 1)/10); _rounded = round (_mult * (10 ^ 3)) / (10 ^ 3); lbSetCurSel [2116, 1]; weatherOvercast = _rounded; publicVariable 'weatherOvercast';";
		};
		
		// SCENARIO
		class droSelectAOText: sundayText {
			idc = 2300;			
			text = "AO location: RANDOM";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.3 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.04 * safezoneH;
			sizeEx = 0.04;
		};
		class droSelectAONew: DROBasicButton
		{
			idc = 2255;
			text = "Open Map";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.34 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.04 * safezoneH;			
			action = "[] spawn dro_menuMap";		
		};
		class droSelectAOClear: DROBasicButton
		{
			idc = 2256;
			text = "Clear AO Location";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.39 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.04 * safezoneH;			
			action = "deleteMarker 'aoSelectMkr'; aoName = nil; ctrlSetText [2202, 'AO location: RANDOM']; selectedLocMarker setMarkerColor 'ColorPink';";		
		};	
		class sundayTitleAISize: sundayText
		{
			idc = 2110;
			text = "Enemy force size multiplier: x1.0";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.57 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			
		};
		class sundaySliderAISize: sundaySlider
		{
			idc = 2111;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.61 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onSliderPosChanged = "_mult = ((_this select 1)/10); _rounded = round (_mult * (10 ^ 1)) / (10 ^ 1); ((findDisplay 52525) displayCtrl 2110) ctrlSetText format ['Enemy force size multiplier: x%1', _rounded]; aiMultiplier = _rounded; publicVariable 'aiMultiplier'; profileNamespace setVariable ['DCO_aiMultiplier', _rounded];";
		};
		class sundayTitleMines: sundayText
		{
			idc = 2112;
			text = "Mines"; //--- ToDo: Localize;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.63 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class sundayCBMines: DROCombo
		{
			idc = 2113;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.67 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "minesEnabled = (_this select 1); publicVariable 'minesEnabled'; profileNamespace setVariable ['DCO_minesEnabled', (_this select 1)];";				
		};
		
		class sundayTitleRevive: sundayText
		{
			idc = 1110;
			text = "Revive"; //--- ToDo: Localize;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.75 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Enable or disable revival";
		};
		class sundayTBRevive: DROCombo
		{
			idc = 2108;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.79 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "reviveDisabled = (_this select 1); publicVariable  'reviveDisabled'; profileNamespace setVariable ['DCO_reviveDisabled', (_this select 1)];";			
		};
		// ADVANCED FACTIONS			
		class sundayTextAdvPlayer: sundayTextMT
		{
			idc = 3712;			
			text = "These advanced options allow you to add additional factions to your currently selected side. Each extra selection made will add that faction's full complement of units and vehicles to the usable pool."; //--- ToDo: Localize;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.3 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.15 * safezoneH;
		};
		class sundayTitleAdvPlayer: sundayText
		{
			idc = 3704;
			text = "Player faction"; //--- ToDo: Localize;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.37 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class sundayComboAdvPlayerFactionsG: DROCombo
		{
			idc = 3800;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.41 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "playersFactionAdv set [0, (_this select 1)]; publicVariable 'playersFactionAdv'";				
		};
		class sundayComboAdvPlayerFactionsA: DROCombo
		{
			idc = 3801;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.44 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "playersFactionAdv set [1, (_this select 1)]; publicVariable 'playersFactionAdv'";				
		};
		class sundayComboAdvPlayerFactionsS: DROCombo
		{
			idc = 3802;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.47 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "playersFactionAdv set [2, (_this select 1)]; publicVariable 'playersFactionAdv'";				
		};
		class sundayTitleAdvEnemy: sundayText
		{
			idc = 3708;
			text = "Enemy faction"; //--- ToDo: Localize;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.49 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class sundayComboAdvEnemyFactionsG: DROCombo
		{
			idc = 3803;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.53 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "enemyFactionAdv set [0, (_this select 1)]; publicVariable 'enemyFactionAdv'";				
		};
		class sundayComboAdvEnemyFactionsA: DROCombo
		{
			idc = 3804;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.56 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "enemyFactionAdv set [1, (_this select 1)]; publicVariable 'enemyFactionAdv'";			
		};
		class sundayComboAdvEnemyFactionsS: DROCombo
		{
			idc = 3805;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.59 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "enemyFactionAdv set [2, (_this select 1)]; publicVariable 'enemyFactionAdv'";				
		};
		// ACE
		class sundayACE_RepWho_Text: sundayText
		{
			idc = 6000;
			text = "Allow Repair";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.3 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Let everyone repair vehicles or limit it to Engineer classes only. Will not be used if ACE Repair is not installed.";			
		};
		class sundayACE_RepWho_Select: DROCombo
		{
			idc = 6001;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.34 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;						
			onLBSelChanged = "ACE_repengineerSetting_Repair = (_this select 1); publicVariable 'ACE_repengineerSetting_Repair'; profileNamespace setVariable ['DCO_ACE_repengineerSetting_Repair', (_this select 1)];";			
		};
		class sundayACE_RepConsume_Text: sundayText
		{
			idc = 6002;
			text = "Consume Toolkit";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.36 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Should toolkits be consumed on use? Will not be used if ACE Repair is not installed.";			
		};
		class sundayACE_RepConsume_Select: DROCombo
		{
			idc = 6003;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.4 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;						
			onLBSelChanged = "ACE_repconsumeItem_ToolKit = (_this select 1); publicVariable 'ACE_repconsumeItem_ToolKit'; profileNamespace setVariable ['DCO_ACE_repconsumeItem_ToolKit', (_this select 1)];";			
		};
		class sundayACE_RepWheel_Text: sundayText
		{
			idc = 6004;
			text = "Wheel repair requirements";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.42 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Should toolkits be needed to work on wheels? Will not be used if ACE Repair is not installed.";			
		};
		class sundayACE_RepWheel_Select: DROCombo
		{
			idc = 6005;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.46 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;						
			onLBSelChanged = "ACE_repwheelRepairRequiredItems = (_this select 1); publicVariable 'ACE_repwheelRepairRequiredItems'; profileNamespace setVariable ['DCO_ACE_repwheelRepairRequiredItems', (_this select 1)];";			
		};
		class sundayACE_MedRevive_Text: sundayText
		{
			idc = 6006;
			text = "Enable revive?";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.48 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Enable ACE revive system? This will disable the revive system included in the mission. Will not be used if ACE Medical is not installed.";			
		};
		class sundayACE_MedRevive_Select: DROCombo
		{
			idc = 6007;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.52 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;						
			onLBSelChanged = "ACE_medenableRevive = (_this select 1); publicVariable 'ACE_medenableRevive'; profileNamespace setVariable ['DCO_ACE_medenableRevive', (_this select 1)];";			
		};
		class sundayACE_MedTime_Text: sundayText
		{
			idc = 6008;
			text = "Bleedout Time: 120 Seconds";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.54 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Time you can be unconscious before dying. Will not be used if ACE Medical is not installed.";
		};
		class sundayACE_MedTime_Slider: sundaySlider
		{
			idc = 6009;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.58 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onSliderPosChanged = "_rounded = round(_this select 1); ((findDisplay 52525) displayCtrl 6008) ctrlSetText format ['Bleedout Time: %1 Seconds', _rounded]; ACE_medmaxReviveTime = _rounded; publicVariable 'ACE_medmaxReviveTime'; profileNamespace setVariable ['DCO_ACE_medmaxReviveTime', _rounded];";
		};
		class sundayACE_MedLives_Text: sundayText
		{
			idc = 6010;
			text = "Revive Lives: 0";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.60 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Amount of times you can be revived before dying. 0 will give an infinite amount of revives. Will not be used if ACE Medical is not installed.";
		};
		class sundayACE_MedLives_Slider: sundaySlider
		{
			idc = 6011;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.64 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onSliderPosChanged = "_rounded = round(_this select 1); ((findDisplay 52525) displayCtrl 6010) ctrlSetText format ['Revive Lives: %1', _rounded]; ACE_medamountOfReviveLives = _rounded; publicVariable 'ACE_medamountOfReviveLives'; profileNamespace setVariable ['DCO_ACE_medamountOfReviveLives', _rounded];";
		};
		class sundayACE_MedLevel_Text: sundayText
		{
			idc = 6012;
			text = "Player Medical Level";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.66 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "ACE Medical Level used by non-medics. Will not be used if ACE Medical is not installed.";	
		};
		class sundayACE_MedLevel_Select: DROCombo
		{
			idc = 6013;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.70 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "ACE_medLevel = (_this select 1); publicVariable 'ACE_medLevel'; profileNamespace setVariable ['DCO_ACE_medLevel', (_this select 1)];";
		};
		class sundayACE_MedMLevel_Text: sundayText
		{
			idc = 6014;
			text = "Medic Medical Level";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.72 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "ACE Medical Level used by medics. Will not be used if ACE Medical is not installed.";	
		};
		class sundayACE_MedMLevel_Select: DROCombo
		{
			idc = 6015;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.76 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "ACE_medmedicSetting = (_this select 1); publicVariable 'ACE_medmedicSetting'; profileNamespace setVariable ['DCO_ACE_medmedicSetting', (_this select 1)];";
		};
		class sundayACE_MedScreams_Text: sundayText
		{
			idc = 6016;
			text = "Enable Screams";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.78 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Should injured units scream? Will not be used if ACE Medical is not installed.";	
		};
		class sundayACE_MedScreams_Select: DROCombo
		{
			idc = 6017;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.82 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "ACE_medenableScreams = (_this select 1); publicVariable 'ACE_medenableScreams'; profileNamespace setVariable ['DCO_ACE_medenableScreams', (_this select 1)];";
		};
		class sundayACE_MedAIUncon_Text: sundayText
		{
			idc = 6018;
			text = "AI Unconsciousness";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.84 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Should AI units fall unconscious? Will not be used if ACE Medical is not installed.";	
		};
		class sundayACE_MedAIUncon_Select: DROCombo
		{
			idc = 6019;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.88 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "ACE_medenableUnconsciousnessAI = (_this select 1); publicVariable 'ACE_medenableUnconsciousnessAI'; profileNamespace setVariable ['DCO_ACE_medenableUnconsciousnessAI', (_this select 1)];";
		};
		class sundayACE_MedDeath_Text: sundayText
		{
			idc = 6020;
			text = "Allow Instant Death";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.90 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Should instant death be allowed, or should players fall unconscious first? Will not be used if ACE Medical is not installed.";	
		};
		class sundayACE_MedDeath_Select: DROCombo
		{
			idc = 6021;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.94 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "ACE_medpreventInstaDeath = (_this select 1); publicVariable 'ACE_medpreventInstaDeath'; profileNamespace setVariable ['DCO_ACE_medpreventInstaDeath', (_this select 1)];";
		};
		class sundayACE_MedBleeding_Text: sundayText
		{
			idc = 6022;
			text = "Bleeding Coefficient: 0.2";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.3 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Sets the speed at which blood is lost. Will not be used if ACE Medical is not installed.";
		};
		class sundayACE_MedBleeding_Slider: sundaySlider
		{
			idc = 6023;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.34 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onSliderPosChanged = "_mult = ((_this select 1)/10); _rounded = round (_mult * (10 ^ 1)) / (10 ^ 1); ((findDisplay 52525) displayCtrl 6022) ctrlSetText format ['Bleeding Coefficient: %1', _rounded]; ACE_medbleedingCoefficient = _rounded; publicVariable 'ACE_medbleedingCoefficient'; profileNamespace setVariable ['DCO_ACE_medbleedingCoefficient', _rounded];";
		};
		class sundayACE_MedPain_Text: sundayText
		{
			idc = 6024;
			text = "Pain Coefficient: 1";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.36 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Sets the speed at which pain is gained. Will not be used if ACE Medical is not installed.";
		};
		class sundayACE_MedPain_Slider: sundaySlider
		{
			idc = 6025;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.4 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onSliderPosChanged = "_mult = ((_this select 1)/10); _rounded = round (_mult * (10 ^ 1)) / (10 ^ 1); ((findDisplay 52525) displayCtrl 6024) ctrlSetText format ['Pain Coefficient: %1', _rounded]; ACE_medpainCoefficient = _rounded; publicVariable 'ACE_medpainCoefficient'; profileNamespace setVariable ['DCO_ACE_medpainCoefficient', _rounded];";
		};
		class sundayACE_MedWounds_Text: sundayText
		{
			idc = 6026;
			text = "Advanced Wounds";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.42 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Should wounds reopen and require stitching? Applies to Advanced Medical only. Will not be used if ACE Medical is not installed.";
		};
		class sundayACE_MedWounds_Select: DROCombo
		{
			idc = 6027;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.46 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "ACE_medenableAdvancedWounds = (_this select 1); publicVariable 'ACE_medenableAdvancedWounds'; profileNamespace setVariable ['DCO_ACE_medenableAdvancedWounds', (_this select 1)];";
		};
		class sundayACE_MedPAK_Text: sundayText
		{
			idc = 6028;
			text = " Who can use PAKs";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.48 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Should PAKs be available to everyone or just Medics? Applies to Advanced Medical only. Will not be used if ACE Medical is not installed.";
		};
		class sundayACE_MedPAK_Select: DROCombo
		{
			idc = 6029;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.52 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "ACE_medmedicSetting_PAK = (_this select 1); publicVariable 'ACE_medmedicSetting_PAK'; profileNamespace setVariable ['DCO_ACE_medmedicSetting_PAK', (_this select 1)];";
		};
		class sundayACE_MedPAKConsume_Text: sundayText
		{
			idc = 6030;
			text = "Consume PAK on use";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.54 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Should PAKs be consumed on use? Applies to Advanced Medical only. Will not be used if ACE Medical is not installed.";
		};
		class sundayACE_MedPAKConsume_Select: DROCombo
		{
			idc = 6031;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.58 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "ACE_medconsumeItem_PAK = (_this select 1); publicVariable 'ACE_medconsumeItem_PAK'; profileNamespace setVariable ['DCO_ACE_medconsumeItem_PAK', (_this select 1)];";
		};
		class sundayACE_MedSKit_Text: sundayText
		{
			idc = 6032;
			text = " Who can use Surgical Kits";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.6 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Should Surgical Kits be available to everyone or just Medics? Applies to Advanced Medical only. Will not be used if ACE Medical is not installed.";
		};
		class sundayACE_MedSKit_Select: DROCombo
		{
			idc = 6033;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.64 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "ACE_medmedicSetting_SurgicalKit = (_this select 1); publicVariable 'ACE_medmedicSetting_SurgicalKit'; profileNamespace setVariable ['DCO_ACE_medmedicSetting_SurgicalKit', (_this select 1)];";
		};
		class sundayACE_MedSKitConsume_Text: sundayText
		{
			idc = 6034;
			text = "Consume Surgical Kits on use";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.66 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Should Surgical Kits be consumed on use? Applies to Advanced Medical only. Will not be used if ACE Medical is not installed.";
		};
		class sundayACE_MedSKitConsume_Select: DROCombo
		{
			idc = 6035;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.7 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "ACE_medconsumeItem_SurgicalKit = (_this select 1); publicVariable 'ACE_medconsumeItem_SurgicalKit'; profileNamespace setVariable ['DCO_ACE_medconsumeItem_SurgicalKit', (_this select 1)];";
		};
	};
	
};


