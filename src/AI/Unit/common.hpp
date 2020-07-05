#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#define OOP_DEBUG
#define OFSTREAM_FILE "AI.rpt"
#include "..\..\common.h"
#include "..\..\Message\Message.hpp"
#include "..\Action\Action.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\defineCommon.inc"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"
#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"
#include "..\parameterTags.hpp"
#include "..\..\Group\Group.hpp"
#include "..\WorldState\WorldState.hpp"
#include "..\Group\groupWorldStateProperties.hpp"
#include "..\Garrison\garrisonWorldStateProperties.hpp"
#include "..\targetStruct.hpp"
#include "unitHumanWorldStateProperties.hpp"
#include "vehicleRoles.hpp"
#include "..\goalRelevance.hpp"
#include "..\..\MessageReceiver\MessageReceiver.hpp"
#include "AIUnit.hpp"