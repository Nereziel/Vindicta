NDSummary.OnToolTipsLoaded("File:Garrison/Garrison.sqf",{425:"<div class=\"NDToolTip TClass LSQF\"><div class=\"TTSummary\">Garrison is an object which holds units and groups and handles their lifecycle (spawning, despawning, destruction).&nbsp; Garrison is much like a group, it has an &lt;AIGarrison&gt;. But it can have multiple groups of different types.</div></div>",427:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Parameters: _side, _pos</div></div>",429:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Start AI Registers with commander and global garrison list Sets &quot;active&quot; variable to true</div></div>",430:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Same as activate, for calling outside the commander thread.</div></div>",431:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">This starts the delete process for this garrison. It sets the garrison to destroyed state (isDestroyed returns true, isAlive returns false), removes all units and groups, deletes the timer and AI components.</div></div>",432:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Is this Garrison ready to be used?</div></div>",433:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Is this Garrison ready to be used?</div></div>",434:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Returns all garrisons</div></div>",435:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Returns all active non empty garrisons</div></div>",436:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">See MessageReceiver.getMessageLoop</div></div>",437:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Parameters: _faction _faction - string</div></div>",438:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Parameters: _name _name - string</div></div>",439:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Sets the location of this garrison</div></div>",440:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Sets the position of this garrison. Note that position can be updated later on its own by garrison\'s actions.</div></div>",442:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Returns side of this garrison.</div></div>",443:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Returns location this garrison is attached to.</div></div>",444:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Returns groups of this garrison.</div></div>",445:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Returns all units of this garrison.</div></div>",446:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Returns all infantry units.</div></div>",447:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Returns all vehicle units.</div></div>",448:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Returns all drone units.</div></div>",449:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Returns the AI object of this garrison.</div></div>",450:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Returns the position of the garrison. It\'s the same as position world state property.</div></div>",451:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Returns true if garrison is empty (has no units)</div></div>",452:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Returns true if garrison contains only empty vehicles</div></div>",453:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Returns true if garrison is spawned</div></div>",454:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Finds groups in this garrison that have the same type as _type</div></div>",455:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Returns: total number of units in this garrison.</div></div>",456:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Count number of passenger seats available in all vehicles of the categories specified.&nbsp; Parameters: _vehicleCategories</div></div>",457:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Adds an existing unit to this garrison. Also use it if you want to move ungrouped units between garrisons.&nbsp; Unit should be not in agroup since this function doesn\'t move unit\'s group to this garrison. So, only vehicles should be added/moved this way.</div></div>",458:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Removes a unit from this garrison.&nbsp; Threading: should be called through postMethod (see &lt;MessageReceiverEx&gt;)</div></div>",459:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Adds an existing group to this garrison. Also use it when you want to move a group to another garrison.</div></div>",460:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Removes an existing group from this garrison.&nbsp; You don\'t need to call this. Use addGroup when you need to move groups between garrisons.</div></div>",461:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">DeletesEmptyGroups in this garrison</div></div>",462:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Moves all units and groups from another garrison to this one.</div></div>",463:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Moves all specified units and groups from another garrison to this one.&nbsp; Before moving, it ensures that all provided units are still in this garrison.&nbsp; New groups for infantry units and vehicle units are created.&nbsp; ALl provided units and groups must originate in one garrison!</div></div>",464:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Returns amount of needed drivers and turret operators for all vehicles in this garrison.</div></div>",465:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Merges or splits vehicle group(s)</div></div>",466:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Adds values to efficiency vector and other counters</div></div>",467:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Substracts values from efficiency vector and other counters</div></div>",468:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Returns efficiency of all mobile units</div></div>",469:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Returns efficiency of all mobile units</div></div>",470:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Spawnes the garrison and detaches it from its current location</div></div>",471:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Returns subagents of this agent.&nbsp; For garrison it returns an empty array, because the subagents of garrison (groups) are processed in a separate thread.</div></div>",472:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Called when the unit has been killed.</div></div>",473:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Called when someone enters a vehicle that belongs to this garrison.</div></div>",474:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Returns an array of units with specified category and subcategory</div></div>",475:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Counts amount of units with specified category and subcategory</div></div>",476:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Returns the amount of infantry units</div></div>",477:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Returns the amount of infantry units</div></div>",478:"<div class=\"NDToolTip TFunction LSQF\"><div class=\"TTSummary\">Returns the amount of infantry units</div></div>"});