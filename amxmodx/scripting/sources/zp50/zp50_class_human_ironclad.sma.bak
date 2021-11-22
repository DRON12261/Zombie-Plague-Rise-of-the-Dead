/*================================================================================
	
	----------------------------------
	-*- [ZP ROTD] Class: Human: Ironclad -*-
	----------------------------------
	
	This plugin is part of Zombie Plague Mod and is distributed under the
	terms of the GNU General Public License. Check ZP_ReadMe.txt for details.
	
================================================================================*/

#include <amxmodx>
#include <amxmisc>

#include <zp50_class_human>

// Classic Human Attributes
new const humanclass3_name[] = "Ironclad"
new const humanclass3_info[] = "Armored"
new const humanclass3_models[][] = { "gign" , "urban" }
const humanclass3_health = 100
const humanclass3_armor = 80
const Float:humanclass3_speed = 0.7
const Float:humanclass3_gravity = 1.0

new g_HumanIronclad

public plugin_precache()
{
	register_plugin("[ZP ROTD] Class: Human: Ironclad", ZP_VERSION_STRING, "ZP Dev Team + DRON12261")
	
	g_HumanIronclad = zp_class_human_register(humanclass3_name, humanclass3_info, humanclass3_health, humanclass3_armor, humanclass3_speed, humanclass3_gravity)
	new index
	for (index = 0; index < sizeof humanclass3_models; index++)
		zp_class_human_register_model(g_HumanIronclad, humanclass3_models[index])
}