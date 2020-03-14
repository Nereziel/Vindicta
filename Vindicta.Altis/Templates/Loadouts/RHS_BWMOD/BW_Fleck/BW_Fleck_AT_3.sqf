removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["BWA3_OpsCore_Fleck"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["rhs_googles_black","rhs_googles_clear","rhs_googles_yellow","rhs_googles_orange","rhs_ess_black"];
this addGoggles _RandomGoggles;
this forceAddUniform "BWA3_Uniform_sleeves_Fleck";
_RandomVest = selectRandom ["BWA3_Vest_Rifleman_Fleck"];
this addVest _RandomVest;
this addBackpack "BWA3_Kitbag_Fleck";

this addWeapon "BWA3_G38K";
this addPrimaryWeaponItem "BWA3_acc_VarioRay_irlaser";
this addPrimaryWeaponItem "BWA3_optic_EOTech552";
this addPrimaryWeaponItem "BWA3_30Rnd_556x45_G36";
this addWeapon "BWA3_CarlGustav";
this addSecondaryWeaponItem "BWA3_CarlGustav_HEAT";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "BWA3_30Rnd_556x45_G36";};
for "_i" from 1 to 2 do {this addItemToVest "BWA3_DM51A1";};
for "_i" from 1 to 4 do {this addItemToBackpack "BWA3_CarlGustav_HEAT";};
this linkItem "ItemWatch";
