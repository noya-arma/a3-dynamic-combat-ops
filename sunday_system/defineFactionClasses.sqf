_playerFactions = [playersFaction] + (playersFactionAdv select {count _x > 0});
_enemyFactions = [enemyFaction] + (enemyFactionAdv select {count _x > 0});
_playerFactions = _playerFactions apply {toUpper _x};
_enemyFactions = _enemyFactions apply {toUpper _x};

pInfClasses = [];
pOfficerClasses = [];
pCarClasses = [];
pCarNoTurretClasses = [];
pTankClasses = [];
pArtyClasses = [];
pMortarClasses = [];
pHeliClasses = [];
pPlaneClasses = [];
pShipClasses = [];
pAmmoClasses = [];
pGenericNames = [];
pLanguage = [];
pUAVClasses = [];
pInfClassesForWeights = [];
pInfClassWeights = [];
pCarTurretClasses = [];
pStaticClasses = [];
pAAClasses = [];

eInfClasses = [];
eOfficerClasses = [];
eCarClasses = [];
eCarNoTurretClasses = [];
eTankClasses = [];
eArtyClasses = [];
eMortarClasses = [];
eHeliClasses = [];
ePlaneClasses = [];
eShipClasses = [];
eAmmoClasses = [];
eGenericNames = [];
eLanguage = [];
eUAVClasses = [];
eInfClassesForWeights = [];
eInfClassWeights = [];
eCarTurretClasses = [];
eStaticClasses = [];
eAAClasses = [];

_pInfClassesUnarmed = [];
_pInfClassesUnarmedForWeights = [];
_pInfClassUnarmedWeights = [];
_pInfEditorSubcats = [];

{
	pInfClassesForWeights pushBack [];
	pInfClassWeights pushBack [];
	_pInfClassesUnarmedForWeights pushBack [];
	_pInfClassUnarmedWeights pushBack [];
	_pInfEditorSubcats pushBack [];
} forEach _playerFactions;

_eInfClassesUnarmed = [];
_eInfClassesUnarmedForWeights = [];
_eInfClassUnarmedWeights = [];
_eInfEditorSubcats = [];

{
	eInfClassesForWeights pushBack [];
	eInfClassWeights pushBack [];
	_eInfClassesUnarmedForWeights pushBack [];
	_eInfClassUnarmedWeights pushBack [];
	_eInfEditorSubcats pushBack [];
} forEach _enemyFactions;

diag_log _playerFactions;
diag_log _enemyFactions;

{
	_isPlayerFaction = if ((toUpper ((configFile >> "CfgVehicles" >> (configName _x) >> "faction") call BIS_fnc_GetCfgData)) in _playerFactions) then {
		true
	} else {false};
	_isEnemyFaction = if ((toUpper ((configFile >> "CfgVehicles" >> (configName _x) >> "faction") call BIS_fnc_GetCfgData)) in _enemyFactions) then {
		true
	} else {false};	
	if (_isPlayerFaction OR _isEnemyFaction) then {				
		if (configName _x isKindOf 'Man') then {				
			if (_isPlayerFaction) then {	
				if (count pGenericNames == 0) then {
					pGenericNames = ((configFile >> "CfgVehicles" >> (configName _x) >> "genericNames") call BIS_fnc_GetCfgData);
					pLanguage = (((configFile >> "CfgVehicles" >> (configName _x) >> "identityTypes") call BIS_fnc_GetCfgData) select 0);
				};
			};
			if (_isEnemyFaction) then {
				if (count eGenericNames == 0) then {
					eGenericNames = ((configFile >> "CfgVehicles" >> (configName _x) >> "genericNames") call BIS_fnc_GetCfgData);
					eLanguage = (((configFile >> "CfgVehicles" >> (configName _x) >> "identityTypes") call BIS_fnc_GetCfgData) select 0);
				};
			};					
			
			if ( ["officer", (configName _x), false] call BIS_fnc_inString ) then {
				if (_isPlayerFaction) then {
					pOfficerClasses pushBack (configName _x);
				};
				if (_isEnemyFaction) then {
					eOfficerClasses pushBack (configName _x);
				};
			} else {					
				if (						
					(["driver", (configName _x), false] call BIS_fnc_inString) ||
					(["diver", (configName _x), false] call BIS_fnc_inString) ||
					(["story", (configName _x), false] call BIS_fnc_inString) ||
					(["competitor", (configName _x), false] call BIS_fnc_inString) ||
					(["survivor", (configName _x), false] call BIS_fnc_inString) ||
					(["unarmed", (configName _x), false] call BIS_fnc_inString) ||
					(["protagonist", (configName _x), false] call BIS_fnc_inString) ||						
					(["_vr_", (configName _x), false] call BIS_fnc_inString) ||
					(["story", ((configFile >> "CfgVehicles" >> (configName _x) >> "editorSubcategory") call BIS_fnc_GetCfgData), false] call BIS_fnc_inString)						
				) then {
				
				} else {
					
					_pFactionIndex = if (_isPlayerFaction) then {							
						(_playerFactions find (toUpper ((configFile >> "CfgVehicles" >> (configName _x) >> "faction") call BIS_fnc_GetCfgData)))
					};
					_eFactionIndex = if (_isEnemyFaction) then {
						(_enemyFactions find (toUpper ((configFile >> "CfgVehicles" >> (configName _x) >> "faction") call BIS_fnc_GetCfgData)))
					};							
					if ((count ((configFile >> "CfgVehicles" >> (configName _x) >> "weapons") call BIS_fnc_GetCfgData) <= 2)) then {
						if (_isPlayerFaction) then {
							_pInfClassesUnarmed pushBack (configName _x);
							(_pInfClassesUnarmedForWeights select _pFactionIndex) pushBack (configName _x);
							(_pInfClassUnarmedWeights select _pFactionIndex) pushBack 0.5;
						};
						if (_isEnemyFaction) then {
							_eInfClassesUnarmed pushBack (configName _x);
							(_eInfClassesUnarmedForWeights select _eFactionIndex) pushBack (configName _x);
							(_eInfClassUnarmedWeights select _eFactionIndex) pushBack 0.5;
						};
					} else {
						if (_isPlayerFaction) then {
							pInfClasses pushBack (configName _x);
						};
						if (_isEnemyFaction) then {
							eInfClasses pushBack (configName _x);
						};							
						_thisWeight = 0;							
						// Check config 'role' value
						_thisRole = ((configFile >> "CfgVehicles" >> (configName _x) >> "role") call BIS_fnc_GetCfgData);
						switch (_thisRole) do {
							case "Crewman": {_thisWeight = 0};
							case "Assistant": {_thisWeight = 0.15};
							case "CombatLifeSaver": {_thisWeight = 0.25};
							case "Grenadier": {_thisWeight = 0.25};
							case "MachineGunner": {_thisWeight = 0.25};
							case "Marksman": {_thisWeight = 0.1};
							case "MissileSpecialist": {_thisWeight = 0.15};
							case "Rifleman": {_thisWeight = 1};
							case "Sapper": {_thisWeight = 0.15};
							case "SpecialOperative": {_thisWeight = 0.15};
							default {_thisWeight = 0.5};
						};						
						// Overwrite weight if certain words appear in unit name
						_thisDisplayName = ((configFile >> "CfgVehicles" >> (configName _x) >> "displayName") call BIS_fnc_GetCfgData);
						{
							if (([(_x select 0), _thisDisplayName, false] call BIS_fnc_inString)) exitWith {
								_thisWeight = (_x select 1);
							};
						} forEach [
							["medic", 0.25],
							["grenadier", 0.25],
							["machine", 0.25],
							["auto", 0.25],
							["sniper", 0.1],
							["marksman", 0.1],
							["spotter", 0.1],
							["sharp", 0.1],
							["asst.", 0.15],
							["missile", 0.15],
							["AT", 0.15],
							["AA", 0.15],
							["special", 0.15],
							["leader", 0.15],
							["gunner", 0.15],
							["ammo", 0.15],
							["pilot", 0],
							["crew", 0]
						];						
						if (_isPlayerFaction) then {
							(pInfClassesForWeights select _pFactionIndex) pushBack (configName _x);
							(pInfClassWeights select _pFactionIndex) pushBack _thisWeight;
							(_pInfEditorSubcats select _pFactionIndex) pushBackUnique ((configFile >> "CfgVehicles" >> (configName _x) >> "editorSubcategory") call BIS_fnc_GetCfgData);
						};
						if (_isEnemyFaction) then {
							(eInfClassesForWeights select _eFactionIndex) pushBack (configName _x);
							(eInfClassWeights select _eFactionIndex) pushBack _thisWeight;
							(_eInfEditorSubcats select _eFactionIndex) pushBackUnique ((configFile >> "CfgVehicles" >> (configName _x) >> "editorSubcategory") call BIS_fnc_GetCfgData);
						};
					};
				};					
			};
		} else {
			_checkSubcats = true;
			if (configName _x isKindOf 'Car') then {				
				_edSubcat = ((configFile >> "CfgVehicles" >> (configName _x) >> "editorSubcategory") call BIS_fnc_GetCfgData);
				if (!isNil "_edSubcat") then {
					if (_edSubcat == "EdSubcat_Drones") then {
						
					} else {
						if (_isPlayerFaction) then {
							pCarClasses pushBackUnique (configName _x);
						};
						if (_isEnemyFaction) then {
							eCarClasses pushBackUnique (configName _x);
						};
						_checkSubcats = false;			
						_thisVehClass = (configName _x);							
						{					
							if ((configName _x) == "Turrets") then {						
								_turretCfg = ([(configFile >> "CfgVehicles" >> _thisVehClass >> "Turrets"), 0, true] call BIS_fnc_returnChildren);						
								if (count _turretCfg > 0) then {									
									_noTurret = 0;
									{										
										if (((configFile >> "CfgVehicles" >> _thisVehClass >> "Turrets" >> (configName _x) >> "gun") call BIS_fnc_GetCfgData) == "mainGun") then {
											_noTurret = 1;
											if (_isPlayerFaction) then {
												pCarTurretClasses pushBackUnique _thisVehClass;
											};
											if (_isEnemyFaction) then {
												eCarTurretClasses pushBackUnique _thisVehClass;
											};
										};
									} forEach _turretCfg;
									if (_noTurret == 0) then {
										if (_isPlayerFaction) then {
											pCarNoTurretClasses pushBackUnique _thisVehClass;
										};
										if (_isEnemyFaction) then {
											eCarNoTurretClasses pushBackUnique _thisVehClass;
										};
									};
								} else {
									if (_isPlayerFaction) then {
										pCarNoTurretClasses pushBackUnique _thisVehClass;
									};
									if (_isEnemyFaction) then {
										eCarNoTurretClasses pushBackUnique _thisVehClass;
									};
								};
							};
						} forEach ([(configFile >> "CfgVehicles" >> _thisVehClass), 0, true] call BIS_fnc_returnChildren);
					};
				};								
			} else {
				if (configName _x isKindOf 'Tank') then {
					_edSubcat = ((configFile >> "CfgVehicles" >> (configName _x) >> "editorSubcategory") call BIS_fnc_GetCfgData);
					if (
						!(["artillery", ((configFile >> "CfgVehicles" >> (configName _x) >> "editorSubcategory") call BIS_fnc_GetCfgData), false] call BIS_fnc_inString) &&
						!(["aa", ((configFile >> "CfgVehicles" >> (configName _x) >> "editorSubcategory") call BIS_fnc_GetCfgData), false] call BIS_fnc_inString)						
					) then {
						if (_isPlayerFaction) then {
							pTankClasses pushBackUnique (configName _x);
						};
						if (_isEnemyFaction) then {
							eTankClasses pushBackUnique (configName _x);
						};
						_checkSubcats = false;
					};					
				};
			};
			if (_checkSubcats) then {
				_edSubcat = ((configFile >> "CfgVehicles" >> (configName _x) >> "editorSubcategory") call BIS_fnc_GetCfgData);
				if (!isNil "_edSubcat") then {
					
					_configName = (configName _x);
					_pVars = [pArtyClasses, pAAClasses, pTankClasses, pTankClasses, pHeliClasses, pPlaneClasses, pShipClasses, pUAVClasses];
					_eVars = [eArtyClasses, eAAClasses, eTankClasses, eTankClasses, eHeliClasses, ePlaneClasses, eShipClasses, eUAVClasses];
					{						
						if ( [_x, ((configFile >> "CfgVehicles" >> _configName >> "editorSubcategory") call BIS_fnc_GetCfgData), false] call BIS_fnc_inString ) exitWith {
							if (_isPlayerFaction) then {
								(_pVars select _forEachIndex) pushBackUnique _configName;
							};
							if (_isEnemyFaction) then {
								(_eVars select _forEachIndex) pushBackUnique _configName;
							};
						};
					} forEach ["artillery", "aa", "tank", "apc", "helicopter", "plane", "boat", "drone"];					
				};
				_configName = (configName _x);
				_pVars = [pMortarClasses, pStaticClasses, pStaticClasses, pAmmoClasses];
				_eVars = [eMortarClasses, eStaticClasses, eStaticClasses, eAmmoClasses];
				{						
					if (_configName isKindOf 'StaticMortar') exitWith {
						if (_isPlayerFaction) then {
							(_pVars select _forEachIndex) pushBackUnique _configName;
						};
						if (_isEnemyFaction) then {
							(_eVars select _forEachIndex) pushBackUnique _configName;
						};
					};
				} forEach ["StaticMortar", "StaticMGWeapon", "StaticGrenadeLauncher", "ReammoBox_F"];			
			};
		};
	};
} forEach ("(getNumber (_x >> 'scope') == 2)" configClasses (configFile / "CfgVehicles"));

// Check to see if there are a lot of unarmed units, in which case, allow them to be valid
if (count _pInfClassesUnarmed > count pInfClasses) then {
	pInfClasses = pInfClasses + _pInfClassesUnarmed;
	{	
		(pInfClassesForWeights set [_forEachIndex, ((pInfClassesForWeights select _forEachIndex) + (pInfClassesUnarmedForWeights select _forEachIndex))]);	
		(pInfClassWeights set [_forEachIndex, ((pInfClassWeights select _forEachIndex) + (pInfClassUnarmedWeights select _forEachIndex))]);			
	} forEach _playerFactions;
};

if (count _eInfClassesUnarmed > count eInfClasses) then {
	eInfClasses = eInfClasses + _eInfClassesUnarmed;
	{	
		(eInfClassesForWeights set [_forEachIndex, ((eInfClassesForWeights select _forEachIndex) + (eInfClassesUnarmedForWeights select _forEachIndex))]);	
		(eInfClassWeights set [_forEachIndex, ((eInfClassWeights select _forEachIndex) + (eInfClassUnarmedWeights select _forEachIndex))]);			
	} forEach _enemyFactions;
};

diag_log format ["DRO: _pInfEditorSubcats = %1", _pInfEditorSubcats];
diag_log format ["DRO: pInfClassWeights = %1", pInfClassWeights];
diag_log format ["DRO: _eInfEditorSubcats = %1", _eInfEditorSubcats];
diag_log format ["DRO: eInfClassWeights = %1", eInfClassWeights];

// If there are more than one subcategory of infantry units then select one
{
	_thisFactionIndex = _forEachIndex;
	if (count (_pInfEditorSubcats select _thisFactionIndex) > 1) then {
		_chosenClasses = [];
		_chosenWeights = [];
		
		// Check how many units are in a subcategory
		_unavailableSubcats = [];
		_availableSubcats = [];
		_subcatWeights = [];
		{
			_thisSubcat = _x;
			_chosenClasses = [];
			_chosenWeights = [];
						
			for "_i" from 0 to ((count (pInfClassesForWeights select _thisFactionIndex))-1) do {
				_unitSubcat = (((configFile >> "CfgVehicles" >> ((pInfClassesForWeights select _thisFactionIndex) select _i) >> "editorSubcategory")) call BIS_fnc_GetCfgData);
				if (_unitSubcat == _thisSubcat) then {
					_chosenClasses pushBack ((pInfClassesForWeights select _thisFactionIndex) select _i);
					_chosenWeights pushBack ((pInfClassWeights select _thisFactionIndex) select _i);
				};
			};
			
			diag_log format ["Subcat %2 _chosenWeights = %1", _chosenWeights, _thisSubcat];
			
			// Look at weights in this subcategory, if there are none above sniper level then disallow the subcategory
			_allowThisSubcat = false;
			{
				if (_x > 0.1) then {
					_allowThisSubcat = true;
				};
			} forEach _chosenWeights;
			
			if (!_allowThisSubcat) then {
				_unavailableSubcats pushBack _thisSubcat;
			} else {
				_availableSubcats pushBack _thisSubcat;
				_subcatWeights pushBack ((count _chosenClasses)/100);
			};
		} forEach (_pInfEditorSubcats select _thisFactionIndex);
		
		diag_log format ["_availableSubcats = %1", _availableSubcats];
		diag_log format ["_unavailableSubcats = %1", _unavailableSubcats];
		diag_log format ["_subcatWeights = %1", _subcatWeights];	
		
		// Choose a subcategory out of those remaining	
		_chosenSubcat = [_availableSubcats, _subcatWeights] call BIS_fnc_selectRandomWeighted;
		diag_log format ["_chosenSubcat = %1", _chosenSubcat];
		
		// Add units with that subcategory to the chosen units
		_chosenClasses = [];
		_chosenWeights = [];
		for "_i" from 0 to ((count (pInfClassesForWeights select _thisFactionIndex))-1) do {
			_thisSubcat = (((configFile >> "CfgVehicles" >> ((pInfClassesForWeights select _thisFactionIndex) select _i) >> "editorSubcategory")) call BIS_fnc_GetCfgData);
			if (_thisSubcat == _chosenSubcat) then {
				_chosenClasses pushBack ((pInfClassesForWeights select _thisFactionIndex) select _i);
				_chosenWeights pushBack ((pInfClassWeights select _thisFactionIndex) select _i);
			};		
		};
		pInfClassesForWeights set [_thisFactionIndex, _chosenClasses];
		pInfClassWeights set [_thisFactionIndex, _chosenWeights];		
	};
} forEach _playerFactions;

{
	_thisFactionIndex = _forEachIndex;
	if (count (_eInfEditorSubcats select _thisFactionIndex) > 1) then {
		_chosenClasses = [];
		_chosenWeights = [];
		
		// Check how many units are in a subcategory
		_unavailableSubcats = [];
		_availableSubcats = [];
		_subcatWeights = [];
		{
			_thisSubcat = _x;
			_chosenClasses = [];
			_chosenWeights = [];
						
			for "_i" from 0 to ((count (eInfClassesForWeights select _thisFactionIndex))-1) do {
				_unitSubcat = (((configFile >> "CfgVehicles" >> ((eInfClassesForWeights select _thisFactionIndex) select _i) >> "editorSubcategory")) call BIS_fnc_GetCfgData);
				if (_unitSubcat == _thisSubcat) then {
					_chosenClasses pushBack ((eInfClassesForWeights select _thisFactionIndex) select _i);
					_chosenWeights pushBack ((eInfClassWeights select _thisFactionIndex) select _i);
				};
			};
			
			diag_log format ["Subcat %2 _chosenWeights = %1", _chosenWeights, _x];
			
			// Look at weights in this subcategory, if there are none above sniper level then disallow the subcategory
			_allowThisSubcat = false;
			{
				if (_x > 0.1) then {
					_allowThisSubcat = true;
				};
			} forEach _chosenWeights;
			
			if (!_allowThisSubcat) then {
				_unavailableSubcats pushBack _x;
			} else {
				_availableSubcats pushBack _x;
				_subcatWeights pushBack ((count _chosenClasses)/100);
			};
		} forEach (_eInfEditorSubcats select _thisFactionIndex);
		
		diag_log format ["_availableSubcats = %1", _availableSubcats];
		diag_log format ["_unavailableSubcats = %1", _unavailableSubcats];
		diag_log format ["_subcatWeights = %1", _subcatWeights];	
		
		// Choose a subcategory out of those remaining	
		_chosenSubcat = [_availableSubcats, _subcatWeights] call BIS_fnc_selectRandomWeighted;
		diag_log format ["_chosenSubcat = %1", _chosenSubcat];
		
		// Add units with that subcategory to the chosen units
		_chosenClasses = [];
		_chosenWeights = [];
		for "_i" from 0 to ((count (eInfClassesForWeights select _thisFactionIndex))-1) do {
			_thisSubcat = (((configFile >> "CfgVehicles" >> ((eInfClassesForWeights select _thisFactionIndex) select _i) >> "editorSubcategory")) call BIS_fnc_GetCfgData);
			if (_thisSubcat == _chosenSubcat) then {
				_chosenClasses pushBack ((eInfClassesForWeights select _thisFactionIndex) select _i);
				_chosenWeights pushBack ((eInfClassWeights select _thisFactionIndex) select _i);
			};		
		};
		eInfClassesForWeights set [_thisFactionIndex, _chosenClasses];
		eInfClassWeights set [_thisFactionIndex, _chosenWeights];		
	};
} forEach _enemyFactions;

diag_log "DRO: Beginning DLC checks";
{
	_unavailableVehicles = [];
	{
		_veh = _x createVehicle [0,0,0];
		_appID = getObjectDLC _veh;		
		if (!isNil "_appID") then {			
			if (!isDLCAvailable _appID) then {
				_unavailableVehicles pushBack _x;
			};
		};
		deleteVehicle _veh;
	} forEach _x;	
	if (count _unavailableVehicles > 0) then {
		diag_log format ["DRO: Vehicle group %1 unavailable vehicles = %2", _forEachIndex, _unavailableVehicles];
		_x = _x - _unavailableVehicles;
	};
} forEach [pCarClasses, pCarNoTurretClasses, pCarTurretClasses, pTankClasses, pHeliClasses, pPlaneClasses, pUAVClasses];
diag_log "DRO: Completed DLC checks";