dro_missionName = {
	_missionNameType = selectRandom ["OneWord", "DoubleWord", "TwoWords"];
	_missionName = switch (_missionNameType) do {
		case "OneWord": {
			_nameArray = ["Garrotte", "Castle", "Tower", "Sword", "Moat", "Traveller", "Headwind", "Fountain", "Taskmaster", "Tulip", "Carnation", "Gaunt", "Goshawk", "Jasper", "Flashbulb", "Banker", "Piano", "Rook", "Knight", "Bishop", "Pyrite", "Granite", "Hearth", "Staircase"];
			format ["Operation %1", selectRandom _nameArray];
		};
		case "DoubleWord": {
			_name1Array = ["Dust", "Swamp", "Red", "Green", "Black", "Gold", "Silver", "Lion", "Bear", "Dog", "Tiger", "Eagle", "Fox", "North", "Moon", "Watch", "Under", "Key", "Court", "Palm", "Fire", "Fast", "Light", "Blind", "Spite", "Smoke", "Castle"];
			_name2Array = ["bowl", "catcher", "fisher", "claw", "house", "master", "man", "fly", "market", "cap", "wind", "break", "cut", "tree", "woods", "fall", "force", "storm", "blade", "knife", "cut", "cutter", "taker", "torch"];
			format ["Operation %1%2", selectRandom _name1Array, selectRandom _name2Array];
		};
		case "TwoWords": {		
			_name1Array = ["Midnight", "Fallen", "Turbulent", "Nesting", "Daunting", "Dogged", "Darkened", "Shallow", "Second", "First", "Third", "Blank", "Absent", "Parallel", "Restless"];		
			_useWorldName = random 1;
			_name2Array = if (_useWorldName > 0.2) then {
				["Sky", "Moon", "Sun", "Hand", "Monk", "Priest", "Viper", "Snake", "Boon", "Cannon", "Market", "Rook", "Knight", "Bishop", "Command", "Mirror", "Crisis", "Spider", "Charter", "Court", "Hearth"]
			} else {
				[worldName]
			};			
			format ["Operation %1 %2", selectRandom _name1Array, selectRandom _name2Array];
		};
	};
	_missionName
};

sun_addIntel = {
	_intelObject = _this select 0;
	_taskName = _this select 1;
	_intelObject setVariable ["task", _taskName];	
	_intelObject addAction [
		"Collect Intel",
		{
			[_this select 3, 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
			missionNamespace setVariable [format ["%1Completed", (_this select 3)], 1, true];
			deleteVehicle (_this select 0);
			{
				_chance = (random 100);
				if (_chance > 50) then {
					_x setMarkerAlpha 1;
				};
			} forEach (missionNamespace getVariable "enemyIntelMarkers");
		},
		_taskName,
		6,
		true,
		true		
		
	];	
};

dro_initLobbyCam = {
	private ["_playerPos", "_camLobbyStartPos", "_camLobbyEndPos"];
	_playerPos = [((getPos player) select 0), ((getPos player) select 1), (((getPos player) select 2)+1.2)];
	_camLobbyStartPos = [(getPos player), 5, (getDir player)-35] call dro_extendPos;
	_camLobbyStartPos = [(_camLobbyStartPos select 0), (_camLobbyStartPos select 1), (_camLobbyStartPos select 2)+1];
	camLobby = "camera" camCreate _camLobbyStartPos;
	camLobby cameraEffect ["internal", "BACK"];
	camLobby camSetPos _camLobbyStartPos;
	camLobby camSetTarget _playerPos;
	camLobby camCommit 0;
	cameraEffectEnableHUD false;
	_camLobbyEndPos = [(getPos player), 5, (getDir player)+35] call dro_extendPos;
	_camLobbyEndPos = [(_camLobbyEndPos select 0), (_camLobbyEndPos select 1), (_camLobbyEndPos select 2)+1];
	camLobby camPreparePos _camLobbyEndPos;
	camLobby camPrepareTarget _playerPos;
	camLobby camCommitPrepared 120;
};

dro_hostageRelease = {
	params ["_hostage", "_player"];	
	_hostage setVariable ["hostageBound", false, true];
	[_hostage, "Acts_AidlPsitMstpSsurWnonDnon_out"] remoteExec ["playMoveNow", 0]; 
	[_hostage] joinSilent (group _player);			
	[_hostage, false] remoteExec ["setCaptive", _hostage, true];	
	[_hostage, 'MOVE'] remoteExec ["enableAI", _hostage, true];			
	[(_hostage getVariable 'taskName'), 'SUCCEEDED', true] remoteExec ["BIS_fnc_taskSetState", (leader(group _player)), true];			
	missionNamespace setVariable [format ['%1Completed', ((_this select 0) getVariable 'taskName')], 1, true];	
};

dro_detectPosMP = {
	private ["_taskName", "_taskPosFake"];
	_taskName = _this select 0;
	_taskPosFake = _this select 1;
	
	_aimedPos = screenToWorld [0.5, 0.5];
	if ((alive player) && ((_aimedPos distance _taskPosFake) < 100) && ((((vehicle player) distance _taskPosFake) < 1000) || (((getConnectedUAV player) distance _taskPosFake) < 1000))) then {		
		_currentInspTime = (missionNamespace getVariable _taskName);
		_currentInspTime = _currentInspTime + 1;
		missionNamespace setVariable [_taskName, _currentInspTime, true];
	};
};