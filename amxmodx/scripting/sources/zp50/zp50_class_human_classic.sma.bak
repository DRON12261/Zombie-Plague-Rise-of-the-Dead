/*================================================================================
	
	----------------------------------
	-*- [ZP ROTD] Class: Human: Classic -*-
	----------------------------------
	
	This plugin is part of Zombie Plague Mod and is distributed under the
	terms of the GNU General Public License. Check ZP_ReadMe.txt for details.
	
================================================================================*/

#include <amxmodx>

#include <zp50_class_human>

// Classic Human Attributes
new const humanclass1_name[] = "Classic Human"
new const humanclass1_info[] = "Default"
new const humanclass1_models[][] = { "arctic" , "guerilla" , "leet" , "terror" , "gign" , "gsg9" , "sas" , "urban" }
const humanclass1_health = 100
const humanclass1_armor = 15
const Float:humanclass1_speed = 1.0
const Float:humanclass1_gravity = 1.0

new g_HumanClassic

public plugin_precache()
{
	register_plugin("[ZP ROTD] Class: Human: Classic", ZP_VERSION_STRING, "ZP Dev Team + DRON12261")
	
	g_HumanClassic = zp_class_human_register(humanclass1_name, humanclass1_info, humanclass1_health, humanclass1_armor, humanclass1_speed, humanclass1_gravity)
	new index
	for (index = 0; index < sizeof humanclass1_models; index++)
		zp_class_human_register_model(g_HumanClassic, humanclass1_models[index])
}
