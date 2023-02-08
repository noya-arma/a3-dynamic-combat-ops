// Assess sector troops for retreat ratios
{
	_sectorUnits = [];
	_thisSectorGroups = _x;
	{	
		_thisGroup = _x;
		{
			_sectorUnits pushBack _x;
		} forEach (units _thisGroup);
	} forEach _thisSectorGroups;
	if (count _sectorUnits > 0) then {
		diag_log format ["DCO: Retreat trigger for sector %1", (dcoSectors select _forEachIndex) getVariable "sectorLetter"];
		diag_log format ["DCO: _sectorUnits = %1", _sectorUnits];
		diag_log format ["DCO: _thisSectorGroups = %1", _thisSectorGroups];
		diag_log format ["DCO: startTotalUnits = %1", (count _sectorUnits)];
		
		private _trgSectorRetreat = createTrigger ["EmptyDetector", (getPos (dcoSectors select _forEachIndex)), true];
		_trgSectorRetreat setTriggerArea [50, 50, 0, true];
		_trgSectorRetreat setTriggerActivation ["ANY", "PRESENT", false];
		_trgSectorRetreat setTriggerStatements [
			"
				({alive _x} count (thisTrigger getVariable 'sectorUnits')) <= ((thisTrigger getVariable 'startTotalUnits') * 0.5)
			",
			"						
				{
					if ({alive _x} count (units _x) > 0) then {					
						if (!isNull ([vehicle(leader _x), true] call dco_closestSector)) then {
							while {(count (waypoints _x)) > 0} do {deleteWaypoint ((waypoints _x) select 0)};											
							_wp1 = _x addWaypoint [getPos (vehicle(leader _x)), 0];
							_wp1 setWaypointBehaviour 'CARELESS';						
							_wp2 = _x addWaypoint [getPos ([vehicle(leader _x), true] call dco_closestSector), 75];
							_wp2 setWaypointBehaviour 'AWARE';	
						};						
					};
				} forEach (thisTrigger getVariable 'sectorGroups');					
			", 
			""];
		_trgSectorRetreat setVariable ["sectorUnits", _sectorUnits];	
		_trgSectorRetreat setVariable ["sectorGroups", _thisSectorGroups];	
		_trgSectorRetreat setVariable ["startTotalUnits", (count _sectorUnits)];		
	};	
} forEach dcoSectorTroops;