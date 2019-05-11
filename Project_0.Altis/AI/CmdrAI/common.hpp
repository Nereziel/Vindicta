#define OOP_INFO
#define OOP_DEBUG
#define OOP_WARNING
#define OOP_ERROR

#define MODEL_HANDLE_INVALID 		-1

// Flags for WorldModel.new type parameter.
#define WORLD_TYPE_REAL					0	// Real world model
#define WORLD_TYPE_SIM_NOW				1	// Sim model with only current effects of actions applied
#define WORLD_TYPE_SIM_FUTURE			2	// Sim model with current and future effects of actions applied

// Flags for GarrisonModel.splitActual flags parameter
#define ASSIGN_TRANSPORT				1	// Attempt to assign transport for the new garrison
#define FAIL_WITHOUT_FULL_TRANSPORT		2	// Fail if we couldn't assign transport to the new garrison (ASSIGN_TRANSPORT required)
#define FAIL_UNDER_EFF					3	// Fail if the split garrison didn't meet efficiency requirements
#define CHEAT_TRANSPORT					4	// Spawn trucks if they are not available and transport is requested

#define OFSTREAM_FILE "CmdrAI.rpt"
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Templates\Efficiency.hpp"
#include "..\..\Mutex\Mutex.hpp"
#include "CmdrAction\CmdrActionStates.hpp"
#include "..\Commander\AICommander.hpp"

#ifndef RELEASE_BUILD
#define DEBUG_CMDRAI
#endif

#define LABEL(model) GETV(model, "label")

#define EFF_ZERO T_EFF_null

// Minimum efficiency of a garrison.
// Controls lots of commander actions, e.g. reinforcements won't be less than this, or leave less than this at an outpost.
#define EFF_MIN_EFF [6, 0, 0, 0, 6, 0, 0, 0]

#ifdef OOP_ASSERT
#define ASSERT_CLUSTER_ACTUAL_OR_NULL(actual)  \
	ASSERT_MSG(actual isEqualType [], __STRINGIFY(actual) + " is invalid type. It should be an array."); \
	if(count actual > 0) then { \
		ASSERT_CLUSTER_ACTUAL_NOT_NULL(actual); \
	}
#define ASSERT_CLUSTER_ACTUAL_NOT_NULL(actual) \
	ASSERT_MSG(actual isEqualType [], __STRINGIFY(actual) + " is invalid type. It should be an array."); \
	ASSERT_MSG(count actual == 2, __STRINGIFY(actual) + " should be an array of the form [AICommander, Cluster ID]"); \
	ASSERT_OBJECT_CLASS(actual select 0, "AICommander"); \
	ASSERT_MSG((actual select 1) isEqualType 0, __STRINGIFY(actual) + " should be an array of the form [AICommander, Cluster ID]")
#else
#define ASSERT_CLUSTER_ACTUAL_OR_NULL(actual)
#define ASSERT_CLUSTER_ACTUAL_NOT_NULL(actual)
#endif

#ifdef OOP_INFO
#define OOP_INFO_MSG_REAL_ONLY(world, fmt, args) \
	if(CALLM(world, "isReal", [])) then { \
		OOP_INFO_MSG(fmt, args); \
	};
#else
#define OOP_INFO_MSG_REAL_ONLY(world, fmt, args)
#endif
#ifdef OOP_DEBUG
#define OOP_DEBUG_MSG_REAL_ONLY(world, fmt, args) \
	if(CALLM(world, "isReal", [])) then { \
		OOP_DEBUG_MSG(fmt, args); \
	};
#else
#define OOP_DEBUG_MSG_REAL_ONLY(world, fmt, args)
#endif