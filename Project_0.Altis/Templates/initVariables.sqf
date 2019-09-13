call compile preprocessFileLineNumbers "Templates\initCategories.sqf";
call compile preprocessFileLineNumbers "Templates\initCategoriesNames.sqf";
call compile preprocessFileLineNumbers "Templates\initEfficiency.sqf";
call compile preprocessFileLineNumbers "Templates\initPlayerSpawnTemplates.sqf";
call compile preprocessFileLineNumbers "Templates\initLoadouts.sqf";

#ifndef _SQF_VM
// Hashmap that matches class name to number
t_classnames_hashmap = [false] call CBA_fnc_createNamespace;
t_classnames_array = [];
#endif