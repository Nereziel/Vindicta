#include "..\..\common.hpp"

/*
Class: AI.CmdrAI.CmdrAction.Actions.QRFCmdrAction

CmdrAI QRF action.
Takes a source garrison model ID and cluster model ID and generates an action
to attack the cluster using the garrison.

Parent: <AttackCmdrAction>
*/
CLASS("QRFCmdrAction", "AttackCmdrAction")
	// The target cluster model ID
	VARIABLE("tgtClusterId");

	/*
	Constructor: new
	Create a CmdrAI action to send a detachment from a garrison to destroy an enemy
	cluster.
	
	Parameters:
		_srcGarrId - Number, <Model.GarrisonModel> id from which to send the QRF detachment.
		_tgtClusterId - Number, <Model.ClusterModel> id to attack.
	*/
	METHOD("new") {
		params [P_THISOBJECT, P_NUMBER("_srcGarrId"), P_NUMBER("_tgtClusterId")];

		T_SETV("tgtClusterId", _tgtClusterId);

		// Target can be modified during the action, if the initial target dies, so we want it to save/restore.
		T_SET_AST_VAR("targetVar", [TARGET_TYPE_CLUSTER ARG _tgtClusterId]);

#ifdef DEBUG_CMDRAI
		T_SETV("debugColor", "ColorRed");
		T_SETV("debugSymbol", "mil_destroy")
#endif
	} ENDMETHOD;

	// Create the intel object for this action
	/* protected override */ METHOD("updateIntel") {
		params [P_THISOBJECT, P_OOP_OBJECT("_world")];

		ASSERT_MSG(CALLM(_world, "isReal", []), "Can only updateIntel from real world, this shouldn't be possible as updateIntel should ONLY be called by CmdrAction");

		T_PRVAR(intel);
		// Created lazily here on the first call to update it. This ensures we only
		// create intel objects for actions that are active rather than merely proposed.
		private _intelNotCreated = IS_NULL_OBJECT(_intel);
		if(_intelNotCreated) then
		{
			// Create new intel object and fill in the constant values
			_intel = NEW("IntelCommanderActionAttack", []);

			T_PRVAR(srcGarrId);
			T_PRVAR(tgtClusterId);
			private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
			ASSERT_OBJECT(_srcGarr);
			private _tgtCluster = CALLM(_world, "getCluster", [_tgtClusterId]);
			ASSERT_OBJECT(_tgtCluster);

			CALLM(_intel, "create", []);

			SETV(_intel, "type", "Take Location");
			SETV(_intel, "side", GETV(_srcGarr, "side"));
			SETV(_intel, "srcGarrison", GETV(_srcGarr, "actual"));
			SETV(_intel, "posSrc", GETV(_srcGarr, "pos"));
			SETV(_intel, "tgtClusterId", GETV(_tgtCluster, "actual") select 1);
			//SETV(_intel, "location", GETV(_tgtCluster, "actual"));
			SETV(_intel, "posTgt", GETV(_tgtCluster, "pos"));
			SETV(_intel, "dateDeparture", T_GET_AST_VAR("startDateVar")); // Sparker added this, I think it's allright??

			// Call the base class function to update the detachment specific intel
			T_CALLM("updateIntelFromDetachment", [_world ARG _intel]);

			// If we just created this intel then register it now 			
			private _intelClone = CALL_STATIC_METHOD("AICommander", "registerIntelCommanderAction", [_intel]);
			T_SETV("intel", _intelClone);

			// Send the intel to some places that should "know" about it
			T_CALLM("addIntelAt", [_world ARG GETV(_srcGarr, "pos")]);
			T_CALLM("addIntelAt", [_world ARG GETV(_tgtCluster, "pos")]);
		} else {
			// Call the base class function to update the detachment specific intel
			T_CALLM("updateIntelFromDetachment", [_world ARG _intel]);
			CALLM(_intel, "updateInDb", []);
		};
	} ENDMETHOD;

	// Update score for this action
	/* override */ METHOD("updateScore") {
		params [P_THISOBJECT, P_OOP_OBJECT("_worldNow"), P_OOP_OBJECT("_worldFuture")];
		ASSERT_OBJECT_CLASS(_worldNow, "WorldModel");
		ASSERT_OBJECT_CLASS(_worldFuture, "WorldModel");

		T_PRVAR(srcGarrId);
		T_PRVAR(tgtClusterId);

		private _srcGarr = CALLM(_worldNow, "getGarrison", [_srcGarrId]);
		ASSERT_OBJECT(_srcGarr);
		private _tgtCluster = CALLM(_worldFuture, "getCluster", [_tgtClusterId]);
		ASSERT_OBJECT(_tgtCluster);

		// Source or target being dead means action is invalid, return 0 score
		if(CALLM(_srcGarr, "isDead", []) or CALLM(_tgtCluster, "isDead", [])) exitWith {
			T_CALLM("setScore", [ZERO_SCORE]);
		};

		private _side = GETV(_srcGarr, "side");

		// CALCULATE THE RESOURCE SCORE
		// In this case it is how well the source garrison can meet the resource requirements of this action,
		// specifically efficiency, transport and distance. Score is 0 when full requirements cannot be met, and 
		// increases with how much over the full requirements the source garrison is (i.e. how much OVER the 
		// required efficiency it is), with a distance based fall off (further away from target is lower scoring).

		// Calculate our possible efficiency
		private _detachEff = T_CALLM("getDetachmentEff", [_worldNow ARG _worldFuture]);
		// Save the calculation of the efficiency for use later.
		// We DON'T want to try and recalculate the detachment against the REAL world state when the action is actually active because
		// it won't be correctly taking into account our knowledge about other actions (as this is represented in the sim world models 
		// which are only available now, during scoring/planning).
		T_SET_AST_VAR("detachmentEffVar", _detachEff);

		// Take the sum of the attack part of the efficiency vector.
		private _detachEffStrength = EFF_SUB_SUM(EFF_DEF_SUB(_detachEff));

		private _srcGarrPos = GETV(_srcGarr, "pos");
		private _tgtClusterPos = GETV(_tgtCluster, "pos");

		// We scale up the influence of distance in the case of QRFs as reaction time is most important.
		private _distCoeff = CALLSM("CmdrAction", "calcDistanceFalloff", [_srcGarrPos ARG _tgtClusterPos ARG 4]) * 2;
		private _dist = _srcGarrPos distance _tgtClusterPos;
		private _transportationScore = if(_dist < 1000) then {
			// If we are less than 1000m then we don't need transport so set the transport score to 1
			// (we "fullfilled" the transport requirements of not needing transport)
			1
		} else {
			// We will cheat transport on top of scoring if we need to
			T_SET_AST_VAR("splitFlagsVar", [ASSIGN_TRANSPORT ARG CHEAT_TRANSPORT]);
			// Call to the garrison to calculate the transportation score
			CALLM(_srcGarr, "transportationScore", [_detachEff])
		};

		// Our final resource score combining available efficiency, distance and transportation.
		private _scoreResource = _detachEffStrength * _distCoeff * _transportationScore;

		// TODO: implement priority score for TakeLocationCmdrAction
		// TODO:OPT cache these scores!
		private _scorePriority = 1;

		// OOP_DEBUG_MSG("[w %1 a %2] %3 take %4 Score %5, _detachEff = %6, _detachEffStrength = %7, _distCoeff = %8, _transportationScore = %9",
		// 	[_worldNow ARG _thisObject ARG LABEL(_srcGarr) ARG LABEL(_tgtCluster) ARG [_scorePriority ARG _scoreResource] 
		// 	ARG _detachEff ARG _detachEffStrength ARG _distCoeff ARG _transportationScore]);

		// APPLY STRATEGY
		// Get our Cmdr strategy implementation and apply it
		private _strategy = CALL_STATIC_METHOD("AICommander", "getCmdrStrategy", [_side]);
		private _baseScore = MAKE_SCORE_VEC(_scorePriority, _scoreResource, 1, 1);
		private _score = CALLM(_strategy, "getQRFScore", [_thisObject ARG _baseScore ARG _worldNow ARG _worldFuture ARG _srcGarr ARG _tgtCluster ARG _detachEff]);
		T_CALLM("setScore", [_score]);
		#ifdef OOP_INFO
		private _str = format ["{""cmdrai"": {""side"": ""%1"", ""action_name"": ""QRF"", ""src_garrison"": ""%2"", ""tgt_cluster"": ""%3"", ""score_priority"": %4, ""score_resource"": %5, ""score_strategy"": %6, ""score_completeness"": %7}}", 
			_side, LABEL(_srcGarr), LABEL(_tgtCluster), _score#0, _score#1, _score#2, _score#3];
		OOP_INFO_MSG(_str, []);
		#endif
	} ENDMETHOD;

	// Get composition of reinforcements we should send from src to tgt. 
	// This is the min of what src has spare and what tgt wants.
	// TODO: factor out logic for working out detachments for various situations
	/* private */ METHOD("getDetachmentEff") {
		params [P_THISOBJECT, P_OOP_OBJECT("_worldNow"), P_OOP_OBJECT("_worldFuture")];
		ASSERT_OBJECT_CLASS(_worldNow, "WorldModel");
		ASSERT_OBJECT_CLASS(_worldFuture, "WorldModel");

		T_PRVAR(srcGarrId);
		T_PRVAR(tgtClusterId);

		private _srcGarr = CALLM(_worldNow, "getGarrison", [_srcGarrId]);
		ASSERT_OBJECT(_srcGarr);
		private _tgtCluster = CALLM(_worldFuture, "getCluster", [_tgtClusterId]);
		ASSERT_OBJECT(_tgtCluster);

		// Calculate how much efficiency is available for QRF then clamp desired efficiency against it

		// How much resources src can spare.
		private _srcOverEff = EFF_MAX_SCALAR(CALLM(_worldNow, "getOverDesiredEff", [_srcGarr]), 0);

		// How much resources we need to defeat target and be safe in hot zone
		private _clusterEff = GETV(_tgtCluster, "efficiency");
		private _zoneEff = CALLM(_worldNow, "getDesiredEff", [GETV(_tgtCluster, "pos")]);
		// Max of our two eff predictions * 1.5 (for margin of safety, somewhat), with a min required value so we don't send something ridiculously small
		private _tgtRequiredEff = EFF_MAX(EFF_MUL_SCALAR(EFF_MAX(_clusterEff, _zoneEff), 1.5), EFF_MIN_EFF);

		// Min of those values
		// TODO: make this a "nice" composition. We don't want to send a bunch of guys to walk or whatever.
		private _effAvailable = EFF_MAX_SCALAR(EFF_FLOOR(EFF_MIN(_srcOverEff, _tgtRequiredEff)), 0);

		//OOP_DEBUG_MSG("[w %1 a %2] %3 take %4 getDetachmentEff: _tgtRequiredEff = %5, _srcOverEff = %6, _effAvailable = %7", [_worldNow ARG _thisObject ARG _srcGarr ARG _tgtCluster ARG _tgtRequiredEff ARG _srcOverEff ARG _effAvailable]);

		// Only send a reasonable amount at a time
		// TODO: min compositions should be different for detachments and garrisons holding outposts.
		if(!EFF_GTE(_effAvailable, EFF_MIN_EFF)) exitWith { EFF_ZERO };

		//if(_effAvailable#0 < MIN_COMP#0 or _effAvailable#1 < MIN_COMP#1) exitWith { [0,0] };
		_effAvailable
	} ENDMETHOD;

	/*
	Method: (virtual) getRecordSerial
	Returns a serialized CmdrActionRecord associated with this action.
	Derived classes should implement this to have proper support for client's UI.
	
	Parameters:	
		_world - <Model.WorldModel>, real world model that is being used.
	*/
	/* virtual override */ METHOD("getRecordSerial") {
		params [P_THISOBJECT, P_OOP_OBJECT("_garModel"), P_OOP_OBJECT("_world")];

		// Create a record
		private _record = NEW("AttackCmdrActionRecord", []);

		// Fill data values
		//SETV(_record, "garRef", GETV(_garModel, "actual"));

		// Resolve target
		private _tgtClusterModel = CALLM1(_world, "getCluster", T_GETV("tgtClusterId"));
		private _pos = GETV(_tgtClusterModel, "pos");
		SETV(_record, "pos", _pos);

		// Serialize and delete it
		private _serial = SERIALIZE(_record);
		DELETE(_record);

		// Return the serialized data
		_serial
	} ENDMETHOD;

ENDCLASS;

#ifdef _SQF_VM

#define SRC_POS [0, 0, 0]
#define TARGET_POS [1, 2, 3]

["TakeLocationCmdrAction", {
	private _realworld = NEW("WorldModel", [WORLD_TYPE_REAL]);
	private _world = CALLM(_realworld, "simCopy", [WORLD_TYPE_SIM_NOW]);
	private _garrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	private _srcEff = [100,100,100,100,100,100,100,100];
	SETV(_garrison, "efficiency", _srcEff);
	SETV(_garrison, "pos", SRC_POS);
	SETV(_garrison, "side", WEST);

	private _targetLocation = NEW("LocationModel", [_world ARG "<undefined>"]);
	SETV(_targetLocation, "pos", TARGET_POS);

	private _thisObject = NEW("TakeLocationCmdrAction", [GETV(_garrison, "id") ARG GETV(_targetLocation, "id")]);
	
	private _future = CALLM(_world, "simCopy", [WORLD_TYPE_SIM_FUTURE]);
	CALLM(_thisObject, "updateScore", [_world ARG _future]);

	private _nowSimState = CALLM(_thisObject, "applyToSim", [_world]);
	private _futureSimState = CALLM(_thisObject, "applyToSim", [_future]);
	["Now sim state correct", _nowSimState == CMDR_ACTION_STATE_READY_TO_MOVE] call test_Assert;
	["Future sim state correct", _futureSimState == CMDR_ACTION_STATE_END] call test_Assert;
	
	private _futureLocation = CALLM(_future, "getLocation", [GETV(_targetLocation, "id")]);
	private _futureGarrison = CALLM(_futureLocation, "getGarrison", [WEST]);
	["Location is occupied in future", !IS_NULL_OBJECT(_futureGarrison)] call test_Assert;
	// ["Initial state is correct", GETV(_obj, "state") == CMDR_ACTION_STATE_START] call test_Assert;
}] call test_AddTest;

#endif