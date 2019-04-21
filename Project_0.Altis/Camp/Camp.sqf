#include "camp.hpp"
#include "..\Group\Group.hpp"
#include "..\AI\Commander\AICommander.hpp"
#include "..\AI\Commander\LocationData.hpp"

/*
Class: Camp
Camp has garrisons at a static place and spawns units handle by location variable.
Camp has an arsenal and maybe events and other features ?

Author: Sparker 28.07.2018
*/

//cursorobject addaction [format ["<img size='1.5' image='\A3\ui_f\data\GUI\Rsc\RscDisplayEGSpectator\Fps.paa' />  %1", "Open Build Menu"], {  }];

#define pr private

CLASS("Camp", "Location")

	VARIABLE("arsenalBox"); // arsenal box object of this Camp
	VARIABLE("campFire"); // camp fire object of this Camp
	VARIABLE("garageBox"); // box object with garage attached to it

	// used for remoteExec
	STATIC_METHOD("newStatic") {
		params ["_thisClass", "_pos"];
		NEW_PUBLIC("Camp", [_pos]);
	} ENDMETHOD;

	STATIC_METHOD("clientInitArsenal") {
		params [P_THISCLASS, P_OBJECT("_arsenalBox")];
		[_arsenalBox] call jn_fnc_arsenal_init;
		[_arsenalBox, true] call build_UI_setObjectMovable;
	} ENDMETHOD;

	STATIC_METHOD("clientInitCampFire") {
		params [P_THISCLASS, P_OBJECT("_campFire")];
		[_campFire] call build_UI_addOpenBuildMenuAction;
		[_campFire, true] call build_UI_setObjectMovable;
	} ENDMETHOD;

	STATIC_METHOD("clientInitGarageBox") {
		params [P_THISCLASS, P_OBJECT("_garageBox")];
		[_garageBox] call JN_fnc_garage_init;
		[_garageBox, true] call build_UI_setObjectMovable;
	} ENDMETHOD;

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_pos", [], [[]]] ];

		SET_VAR(_thisObject, "capacityInf", 2);
		SET_VAR_PUBLIC(_thisObject, "pos", _pos);
		CALL_METHOD(_thisObject, "setType", [LOCATION_TYPE_CAMP]);

		// Create camp vehicles
		private _arsenalBox = "Box_FIA_Support_F" createVehicle  _pos;
		REMOTE_EXEC_STATIC_METHOD("Camp", "clientInitArsenal", [_arsenalBox], 0, _arsenalBox);
		SET_VAR(_thisObject, "arsenalBox", _arsenalBox);

		pr _campFire = "Land_Campfire_F" createVehicle _pos;
		REMOTE_EXEC_STATIC_METHOD("Camp", "clientInitCampFire", [_campFire], 0, _campFire);
		SET_VAR(_thisObject, "campFire", _campFire);

		pr _garageBox = "Land_CargoBox_V1_F" createVehicle _pos;
		REMOTE_EXEC_STATIC_METHOD("Camp", "clientInitGarageBox", [_garageBox], 0, _garageBox);
		SET_VAR(_thisObject, "garageBox", _garageBox);

		// Create Respawn Marker
		private _marker = createMarker ["respawn_west_" + _thisObject, _pos]; // magic
		_marker setMarkerAlpha 0.0;

		// Setup location's border from marker properties
		private _mrkSize = getMarkerSize _marker;
		if(_mrkSize select 0 == _mrkSize select 1) then { // if width==height, make it a circle
			private _radius = _mrkSize select 0;
			private _args = ["circle", CAMP_RADIUS];
			CALL_METHOD(_thisObject, "setBorder", _args);
		} else { // If width!=height, make border a rectangle
			private _dir = markerDir _marker;
			private _args = ["rectangle", [_mrkSize select 0, _mrkSize select 1, _dir] ];
			CALL_METHOD(_thisObject, "setBorder", _args);
		};

		// TODO: refacto ? with ->
		// https://github.com/Sparker95/Project_0.Stratis/blob/f7c1abd03b5f404d93e5b561b93bdc74f6268dd6/Project_0.Stratis/Location/createAllFromEditor.sqf#L86-L88
		// Infantry capacity
		private _side = WEST;
		private _template = tGUERILLA;
		private _args = [T_INF, [GROUP_TYPE_IDLE]];
		private _cInf = CALL_METHOD(_thisObject, "getUnitCapacity", _args);

		private _garMilMain = NEW("Garrison", [_side]);
		CALLM1(_garMilMain, "setLocation", _thisObject);

		// Add infantry
		private _addInfGroup = {
			params ["_template", "_gar", "_subcatID", "_capacity", ["_type", GROUP_TYPE_IDLE]];

			// Create an empty group
			private _side = CALL_METHOD(_gar, "getSide", []);
			_args = [_side, _type];
			private _newGroup = NEW("Group", _args);

			// Create units from template
			private _args = [_template, _subcatID];
			private _nAdded = CALL_METHOD(_newGroup, "createUnitsFromTemplate", _args);
			CALL_METHOD(_gar, "addGroup", [_newGroup]);

			// Return remaining capacity
			_capacity = _capacity - _nAdded;
			_capacity
		};

		// Add patrol groups
		private _i = 0;
		while {_cInf > 0 && _i < 3} do {
			_cInf = [_template, _garMilMain, T_GROUP_inf_sentry, _cInf, GROUP_TYPE_PATROL] call _addInfGroup;
			_i = _i + 1;
		};

		// Add default infantry groups
		private _i = 0;
		while {_cInf > 0 && _i < 666} do {
			_cInf = [_template, _garMilMain, T_GROUP_inf_rifle_squad, _cInf, GROUP_TYPE_IDLE] call _addInfGroup;
			_i = _i + 1;
		};

		CALLM2(gAICommanderWest, "updateLocationData", _thisObject, CLD_UPDATE_LEVEL_UNITS);
		OOP_INFO_1("new camp created: %1", _thisObject);
	} ENDMETHOD;


	// |                            D E L E T E                             |

	METHOD("delete") {
		params [["_thisObject", "", [""]]];

		SET_VAR(_thisObject, "arsenalBox", nil);
		SET_VAR(_thisObject, "campFire", nil);
	} ENDMETHOD;

ENDCLASS;
