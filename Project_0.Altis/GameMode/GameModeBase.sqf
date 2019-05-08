#include "common.hpp"

CLASS("GameModeBase", "")

	VARIABLE("name");

	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("name", "unnamed");

	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	METHOD("init") {
		params [P_THISOBJECT];

		// Global flags
		gFlagAllCommanders = true; //false;
		// Main timer service
		gTimerServiceMain = NEW("TimerService", [0.2]); // timer resolution

		T_CALLM("preInitAll", []);

		if(isServer || IS_HEADLESSCLIENT) then {
			// Main message loop for garrisons
			gMessageLoopMain = NEW("MessageLoop", []);
			CALL_METHOD(gMessageLoopMain, "setDebugName", ["Main thread"]);

			// Global debug printer for tests
			private _args = ["TestDebugPrinter", gMessageLoopMain];
			gDebugPrinter = NEW("DebugPrinter", _args);

			// Message loop for group AI
			gMessageLoopGroupAI = NEW("MessageLoop", []);
			CALL_METHOD(gMessageLoopGroupAI, "setDebugName", ["Group AI thread"]);

			// Message loop for Stimulus Manager
			gMessageLoopStimulusManager = NEW("MessageLoop", []);
			CALL_METHOD(gMessageLoopStimulusManager, "setDebugName", ["Stimulus Manager thread"]);

			// Global Stimulus Manager
			gStimulusManager = NEW("StimulusManager", []);

			// Message loop for locations
			gMessageLoopLocation = NEW("MessageLoop", []);
			CALL_METHOD(gMessageLoopLocation, "setDebugName", ["Location thread"]);

			// Location unit array provider
			gLUAP = NEW("LocationUnitArrayProvider", []);

			T_CALLM("initServerOrHC", []);
		};
		if(isServer) then {
			T_CALLM("initCommanders", []);
			T_CALLM("initLocations", []);
			T_CALLM("initSideStats", []);
			T_CALLM("initMissionEventHandlers", []);
			T_CALLM("registerKnownLocations", []);

			T_CALLM("initServerOnly", []);
		};
		if (hasInterface || IS_HEADLESSCLIENT) then {
			T_CALLM("initClientOrHCOnly", []);
		};
		if (IS_HEADLESSCLIENT) then {

			private _str = format ["Mission: I am a headless client! My player object is: %1. I have just connected! My owner ID is: %2", player, clientOwner];
			OOP_INFO_0(_str);
			systemChat _str;

			// Test: ask the server to create an object and pass it to this computer
			[clientOwner, {
				private _remoteOwner = _this;
				diag_log format ["---- Connected headless client with owner ID: %1. RemoteExecutedOwner: %2, isRemoteExecuted: %3", _remoteOwner, remoteExecutedOwner, isRemoteExecuted];
				diag_log format ["all players: %1, all headless clients: %2", allPlayers, entities "HeadlessClient_F"];
				diag_log format ["Owners of headless clients: %1", (entities "HeadlessClient_F") apply {owner _x}];

				private _args = ["Remote DebugPrinter test", gMessageLoopMain];
				remoteDebugPrinter = NEW("DebugPrinter", _args);
				CALLM(remoteDebugPrinter, "setOwner", [_remoteOwner]); // Transfer it to the machine that has connected
				diag_log format ["---- Created a debug printer for the headless client: %1", remoteDebugPrinter];

			}] remoteExec ["spawn", 2, false];

			T_CALLM("initHCOnly", []);
		};
		if(hasInterface) then {
			diag_log "----- Player detected!";
			0 spawn {
				waitUntil {!((finddisplay 12) isEqualTo displayNull)};
				call compile preprocessfilelinenumbers "UI\initPlayerUI.sqf";
			};

			T_CALLM("initClientOnly", []);
		};
		T_CALLM("postInitAll", []);
	} ENDMETHOD;

	// -------------------------------------------------------------------------
	// |                  V I R T U A L   F U N C T I O N S                    |
	// -------------------------------------------------------------------------
	// These are the customization points for game mode setups, implement them
	// in derived classes.
	/* protected virtual */ METHOD("preInitAll") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected virtual */ METHOD("initServerOrHC") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected virtual */ METHOD("initServerOnly") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected virtual */ METHOD("initClientOrHCOnly") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected virtual */ METHOD("initHCOnly") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected virtual */ METHOD("initClientOnly") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected virtual */ METHOD("postInitAll") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	// -------------------------------------------------------------------------
	// |                        S E R V E R   O N L Y                          |
	// -------------------------------------------------------------------------
	/* private */ METHOD("initCommanders") {
		params [P_THISOBJECT];

		// Garrison objects to track players and player owned vehicles
		gGarrisonPlayersWest = NEW("Garrison", [WEST]);
		gGarrisonPlayersEast = NEW("Garrison", [EAST]);
		gGarrisonPlayersInd = NEW("Garrison", [INDEPENDENT]);
		gGarrisonPlayersCiv = NEW("Garrison", [CIVILIAN]);
		gGarrisonAmbient = NEW("Garrison", [CIVILIAN]);

		gSpecialGarrisons = [gGarrisonPlayersWest, gGarrisonPlayersEast, gGarrisonPlayersInd, gGarrisonPlayersCiv, gGarrisonAmbient];

		// Message loops for commander AI
		gMessageLoopCommanderInd = NEW("MessageLoop", []);

		// Commander AIs
		gCommanders = [];

		// Independent
		gCommanderInd = NEW("Commander", []); // all commanders are equal
		private _args = [gCommanderInd, INDEPENDENT, gMessageLoopCommanderInd];
		gAICommanderInd = NEW_PUBLIC("AICommander", _args);
		publicVariable "gAICommanderInd";
		gCommanders pushBack gAICommanderInd;

		if(gFlagAllCommanders) then { // but some are more equal

			gMessageLoopCommanderWest = NEW("MessageLoop", []);
			gMessageLoopCommanderEast = NEW("MessageLoop", []);

			// West
			gCommanderWest = NEW("Commander", []);
			private _args = [gCommanderWest, WEST, gMessageLoopCommanderWest];
			gAICommanderWest = NEW_PUBLIC("AICommander", _args);
			publicVariable "gAICommanderWest";
			gCommanders pushBack gAICommanderWest;

			// East
			gCommanderEast = NEW("Commander", []);
			private _args = [gCommanderEast, EAST, gMessageLoopCommanderEast];
			gAICommanderEast = NEW_PUBLIC("AICommander", _args);
			publicVariable "gAICommanderEast";
			gCommanders pushBack gAICommanderEast;
		};
	} ENDMETHOD;

	// Create locations
	///* private */ METHOD_FILE("initLocations", "GameMode\initLocations.sqf");
	METHOD("initLocations") {
		params [P_THISOBJECT];

		{
			private _locSector = _x;
			private _locSectorPos = getPos _locSector;
			private _locName = _locSector getVariable ["Name", ""];
			private _locType = _locSector getVariable ["Type", ""];
			private _locSide = _locSector getVariable ["Side", ""];
			private _locCapacityInf = _locSector getVariable ["CapacityInfantry", ""];
			private _locCivPresUnitCount = _locSector getVariable ["CivPresUnitCount", ""];
			private _template = "";
			private _side = "";

			if (_locType == "city") exitWith{};

			OOP_DEBUG_1("_locName %1", _locName);
			OOP_DEBUG_1("_locCapacityInf %1", _locCapacityInf);
			OOP_DEBUG_1("_locCivPresUnitCount %1", _locCivPresUnitCount);
			
			if (_locSide == "none") exitWith { OOP_WARNING_1("No side for Location Sector %1", _locationSector); };
			
			private _side = switch (_locSide) do{
				case "west": { WEST };
				case "east": { EAST };
				case "independant": { INDEPENDENT };
				default { INDEPENDENT };
			};

			// Create a new location
			private _loc = NEW_PUBLIC("Location", [_locSectorPos]);
			CALL_METHOD(_loc, "initFromEditor", [_locSector]);
			CALL_METHOD(_loc, "setDebugName", [_locName]);
			CALL_METHOD(_loc, "setSide", [_side]);
			CALL_METHOD(_loc, "setType", [_locType]);
			CALL_METHOD(_loc, "setCapacityInf", [_locCapacityInf]);

		} forEach (entities "Project_0_LocationSector");

	} ENDMETHOD;

	// STATIC_METHOD("getTemplateForSide") {
	// 	params [P_THISCLASS, P_SIDE("_side")];
	// 	switch(_side) do {
	// 		case WEST: { tNATO };
	// 		case EAST: { tCSAT };
	// 		case INDEPENDENT: { tAAF };
	// 	}
	// } ENDMETHOD;
	
	STATIC_METHOD("createGarrison") {
		params [P_THISOBJECT, P_SIDE("_side"), P_NUMBER("_cInf"), P_NUMBER("_cVehGround"), P_NUMBER("_cHMGGMG"), P_NUMBER("_cBuildingSentry")];
		
		// TODO: use synced waypoints to help AIs
		// _waypoints = synchronizedObjects _locationSector;

		// // Output the capacity of this garrison
		// // Infantry capacity
		// private _cInf = 0;
		// // Wheeled and tracked vehicle capacity
		// private _cVehGround = 0;
		// // Static HMG capacity
		// private _cHMGGMG = 0;
		// // Building sentry capacity
		// private _cBuildingSentry = 0;

		//T_CALLM("getLocationInitialForces", [_loc]) params ["_cInf", "_cVehGround", "_cHMGGMG", "_cBuildingSentry"];

		//if(_cInf > 0) then {
			// Add the main garrison to this location
		private _gar = NEW("Garrison", [_side]);

		// Add default units to the garrison

		// Specification for groups to add to the garrison
		private _infSpec = [
			//|Min groups of this type
			//|    |Max groups of this type
			//|    |    |Group template
			//|	   |    |                          |Group behaviour
			[  0,   3,   T_GROUP_inf_sentry,   		GROUP_TYPE_PATROL],
			[  0,  -1,   T_GROUP_inf_rifle_squad,   GROUP_TYPE_IDLE]
		];

		private _vehGroupSpec = [
			//|Chance to spawn
			//|      |Min veh of this type
			//|      |    |Max veh of this type
			//|      |    |            |Veh type                          
			[  0.5,   0,  -1,           T_VEH_MRAP_HMG],
			[  0.5,   0,  -1,           T_VEH_MRAP_GMG],
			[  0.3,   0,  -1,           T_VEH_APC],
			[  0.1,   0,  -1,           T_VEH_MBT]
		];

		{
			_x params ["_min", "_max", "_groupTemplate", "_groupBehaviour"];
			private _i = 0;
			while{(_cInf > 0 or _i < _min) and (_max == -1 or _i < _max)} do {
				CALLM(_gar, "createAddInfGroup", [_side ARG _groupTemplate ARG _groupBehaviour])
					params ["_newGroup", "_unitCount"];
				_cInf = _cInf - _unitCount;
				_i = _i + 1;
			};
		} forEach _infSpec;

		{
			_x params ["_chance", "_min", "_max", "_type"];
			if(random 1 <= _chance) then {
				private _i = 0;
				while{(_cVehGround > 0 or _i < _min) and (_max == -1 or _i < _max)} do {
					CALLM(_gar, "createAddVehGroup", [_side ARG T_VEH ARG T_VEH_APC ARG -1]);
					_cVehGround = _cVehGround - 1;
					_i = _i + 1;
				};
			};
		} forEach _vehGroupSpec;
		
		private _template = GET_TEMPLATE(_side);
		
		// Add building sentries
		#ifdef ADD_SENTRY
		if (_cBuildingSentry > 0) then {
			private _sentryGroup = NEW("Group", [_side ARG GROUP_TYPE_BUILDING_SENTRY]);
			while {_cBuildingSentry > 0} do {
				private _variants = [T_INF_marksman, T_INF_marksman, T_INF_LMG, T_INF_LAT, T_INF_LMG];
				private _newUnit = NEW("Unit", [_template ARG 0 ARG selectrandom _variants ARG -1 ARG _sentryGroup]);
				_cBuildingSentry = _cBuildingSentry - 1;
			};
			CALL_METHOD(_gar, "addGroup", [_sentryGroup]);
		};
		#endif

		// Add default vehicles
		// Some trucks
		private _i = 0;
		#ifdef ADD_TRUCKS
		while {_cVehGround > 0 && _i < 3} do {
			private _newUnit = NEW("Unit", [_template ARG T_VEH ARG T_VEH_truck_inf ARG -1 ARG ""]);
			if (CALL_METHOD(_newUnit, "isValid", [])) then {
				CALL_METHOD(_gar, "addUnit", [_newUnit]);
				_cVehGround = _cVehGround - 1;
			} else {
				DELETE(_newUnit);
			};
			_i = _i + 1;
		};
		#endif

		#ifdef ADD_UNARMED_MRAPS
		_i = 0;
		while {(_cVehGround > 0) && _i < 1} do  {
			private _newUnit = NEW("Unit", [_template ARG T_VEH ARG T_VEH_MRAP_unarmed ARG -1 ARG ""]);
			if (CALL_METHOD(_newUnit, "isValid", [])) then {
				CALL_METHOD(_gar, "addUnit", [_newUnit]);
				_cVehGround = _cVehGround - 1;
			} else {
				DELETE(_newUnit);
			};
			_i = _i + 1;
		};
		#endif

		#ifdef ADD_STATICS
		// Static weapons
		if (_cHMGGMG > 0) then {
			// temp cap of amount of static guns
			_cHMGGMG = (4 + random 5) min _cHMGGMG;
			
			private _staticGroup = NEW("Group", [_side ARG GROUP_TYPE_VEH_STATIC]);
			while {_cHMGGMG > 0} do {
				private _variants = [T_VEH_stat_HMG_high, T_VEH_stat_GMG_high];
				private _newUnit = NEW("Unit", [_template ARG T_VEH ARG selectrandom _variants ARG -1 ARG _staticGroup]);
				CALL_METHOD(_newUnit, "createDefaultCrew", [_template]);
				_cHMGGMG = _cHMGGMG - 1;
			};
			CALL_METHOD(_gar, "addGroup", [_staticGroup]);
		};
		#endif
		//};
		_gar
	} ENDMETHOD;


	// Create SideStats
	/* private */ METHOD("initSideStats") {
		params [P_THISOBJECT];
		
		private _args = [EAST, 5];
		SideStatWest = NEW("SideStat", _args);
		gSideStatWestHR = CALLM0(SideStatWest, "getHumanResources");
		publicVariable "gSideStatWestHR";
	} ENDMETHOD;

	// create MissionEventHandlers
	/* private */ METHOD("initMissionEventHandlers") {
		params [P_THISOBJECT];
		call compile preprocessFileLineNumbers "Init\initMissionEH.sqf";
	} ENDMETHOD;

	// Add friendly locations to commanders
	/* private */ METHOD("registerKnownLocations") {
		params [P_THISOBJECT];

		// Register garrisons of friendly locations
		// And start them
		private _allGars = CALLSM0("Garrison", "getAll") - gSpecialGarrisons;
		{
			private _AI = _x;
			private _side = GETV(_x, "side");
			{
				private _loc = CALLM0(_x, "getLocation");
				
				private _updateLevel = CLD_UPDATE_LEVEL_TYPE_UNKNOWN; // Only know that there's something unexplored over here
				if (CALLM0(_x, "getSide") == _side) then { // If this garrison should belong to this commander	
					// Activate the Garrison
					CALLM(_x, "activate", []);
					_updateLevel = CLD_UPDATE_LEVEL_UNITS; // Know about all units at this place
				};

				if (_loc != "") then {
					CALLM4(_AI, "updateLocationData", _loc, _updateLevel, sideUnknown, false); // false - don't show notification
				};
			} forEach _allGars;

			CALLM1(_x, "setProcessInterval", 10);
			CALLM0(_x, "start");
		} forEach gCommanders;
	} ENDMETHOD;

	/* private */ METHOD("fn") {
		params [P_THISOBJECT];

	} ENDMETHOD;
ENDCLASS;