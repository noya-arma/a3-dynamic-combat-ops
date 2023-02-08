_playersIndex = lbCurSel 2100;
_enemyIndex = lbCurSel 2101;
_civIndex = lbCurSel 2102;
_playersFaction = lbData [2100, _playersIndex];
_enemyFaction = lbData [2101, _enemyIndex];

_playersSideNum = ((configFile >> "CfgFactionClasses" >> _playersFaction >> "side") call BIS_fnc_GetCfgData);
_enemySideNum = ((configFile >> "CfgFactionClasses" >> _enemyFaction >> "side") call BIS_fnc_GetCfgData);

_continue = true;
if (_playersIndex == -1 || _enemyIndex == -1) then {
	hint "Both the player and enemy side must have a faction selected.";
	_continue = false;
} else {
	if (_continue) then {	
		//playersFaction = lbData [2100, _playersIndex];
		playersFaction = "";
		if ((lbData [2100, _playersIndex]) == "RANDOM") then {			
			playersFaction = lbData [2100, ([1, lbSize 2100] call BIS_fnc_randomInt)];
			profileNamespace setVariable ["DCO_playersFaction", "RANDOM"];
		} else {
			playersFaction = lbData [2100, _playersIndex];
			profileNamespace setVariable ["DCO_playersFaction", playersFaction];
		};		
		publicVariable "playersFaction";		
		playersFactionAdv = [lbData [3800,  lbCurSel 3800], lbData [3801,  lbCurSel 3801], lbData [3802,  lbCurSel 3802]];
		publicVariable "playersFactionAdv";
		
		
		//enemyFaction = lbData [2101, _enemyIndex];
		if ((lbData [2101, _enemyIndex]) == "RANDOM") then {			
			enemyFaction = lbData [2101, ([1, lbSize 2101] call BIS_fnc_randomInt)];
			profileNamespace setVariable ["DCO_enemyFaction", "RANDOM"];
		} else {
			enemyFaction = lbData [2101, _enemyIndex];
			profileNamespace setVariable ["DCO_enemyFaction", enemyFaction];
		};
		publicVariable "enemyFaction";		
		enemyFactionAdv = [lbData [3803,  lbCurSel 3803], lbData [3804,  lbCurSel 3804], lbData [3805,  lbCurSel 3805]];
		publicVariable "enemyFactionAdv";
		
		civFaction = lbData [2102, _civIndex];
		publicVariable "civFaction";		
		
		missionNameSpace setVariable ["factionsChosen", 1];
		publicVariable "factionsChosen";
				
		aiMultiplier = (round (((sliderPosition 2111)/10) * (10 ^ 1)) / (10 ^ 1));
		publicVariable "aiMultiplier";
		
		hintSilent  "";
		closeDialog 1;				
		[toUpper "Please wait while mission is generated", "objectivesSpawned", 1, ""] call sun_callLoadScreen;
					
	} else {
		["One or more advanced factions have differing sides from their main faction. Please make sure the sides of each advanced faction match those of the corresponding faction selected at the top of the screen."] call _warning;			
	};
};
//hint format ["%1, %2", playersFaction, enemyFaction];

