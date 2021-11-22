/*================================================================================
	
	----------------------------------
	-*- [ZP ROTD] Class: Human: Raptor -*-
	----------------------------------
	
	This plugin is part of Zombie Plague Mod and is distributed under the
	terms of the GNU General Public License. Check ZP_ReadMe.txt for details.
	
================================================================================*/

#include <amxmodx>
#include <cstrike>

#include <zp50_class_human>

// Raptor Human Attributes
new const humanclass2_name[] = "Raptor Human"
new const humanclass2_info[] = "Speed Up"
new const humanclass2_models[][] = { "leet" }
const humanclass2_health = 50
const humanclass2_armor = 15
const Float:humanclass2_speed = 1.2
const Float:humanclass2_gravity = 1.2
new humanclass2_weaponrestricts[] = { CSW_GALIL, CSW_FAMAS, CSW_M4A1, CSW_AK47, CSW_SG552, CSW_AUG, CSW_M3, CSW_XM1014, CSW_M249, CSW_AWP, CSW_SG550, CSW_G3SG1 }

new g_HumanRaptor

public plugin_precache()
{
	register_plugin("[ZP ROTD] Class: Human: Raptor", ZP_VERSION_STRING, "ZP Dev Team + DRON12261")
	
	g_HumanRaptor = zp_class_human_register(humanclass2_name, humanclass2_info, humanclass2_health, humanclass2_armor, humanclass2_speed, humanclass2_gravity)
	new index
	for (index = 0; index < sizeof humanclass2_models; index++)
		zp_class_human_register_model(g_HumanRaptor, humanclass2_models[index])
	for (index = 0; index < sizeof humanclass2_weaponrestricts; index++)
		zp_class_human_register_restricted_weapon(g_HumanRaptor, humanclass2_weaponrestricts[index])
}
