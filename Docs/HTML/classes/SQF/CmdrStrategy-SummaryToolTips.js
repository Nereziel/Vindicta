NDSummary.OnToolTipsLoaded("SQFClass:CmdrStrategy",{185:"<div class=\"NDToolTip TClass LSQF\"><div class=\"TTSummary\">Acts as a customization entry point for driving commander behaviour to achieve specific gameplay.&nbsp; e.g If you want to change the criteria the commander will use to decide when to occupy a specific location then you can derive a custom `CmdrStrategy` and override `getLocationDesirability` (or modify the `takeLoc*` member values).</div></div>",187:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Return a value indicating the commanders desire to occupy the specified location.</div></div>",188:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Return a value indicating the commanders desire to send a QRF in response to the specified cluster, from the specified garrison.&nbsp; Default QRF behaviour is to send QRFs always, from any location that can spare the entire required efficiency.</div></div>",189:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Return a value indicating the commanders desire to send a patrol from the specified source garrison on the specified route.&nbsp; Default Patrol behaviour is to send patrols always, from any location that can spare any efficiency, to all surrounding city locations.</div></div>",190:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Return a value indicating the commanders desire to send reinforcements from the specified source garrison to the specified target garrison.&nbsp; Default Reinforce behaviour is to send reinforcements whenever they are needed, from any location that can spare the entire required efficiency.</div></div>",191:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Return a value indicating the commanders desire to take the specified location using the specified source garrison.&nbsp; Default TakeLocation behaviour is to always take bases and outposts, but only take roadblocks if there is both nearby activity and a nearby friendly location.&nbsp; It prefer locations in this order generally: base &gt; outpost &gt; roadblock However roadblocks become more important the stronger activity is in the area, such that they can be the most important with high activity.</div></div>"});