/*================================================================================
	
	---------------------------------
	-*- [ZP ROTD] Class: Zombie: Jumper -*-
	---------------------------------
	
	This plugin is part of Zombie Plague Mod and is distributed under the
	terms of the GNU General Public License. Check ZP_ReadMe.txt for details.
	
================================================================================*/

#include <amxmodx>
#include <zp50_class_zombie>

// Light Zombie Attributes
new const zombieclass3_name[] = "Jumper Zombie"
new const zombieclass3_info[] = "HP- Jump+ Knockback+" 
new const zombieclass3_models[][] = { "zombie_source" }
new const zombieclass3_clawmodels[][] = { "models/zombie_plague/v_knife_zombie.mdl" }
const zombieclass3_health = 1400
const Float:zombieclass3_speed = 0.75
const Float:zombieclass3_gravity = 0.5
const Float:zombieclass3_knockback = 1.25

new g_ZombieJumper

public plugin_precache()
{
	register_plugin("[ZP ROTD] Class: Zombie: Jumper", ZP_VERSION_STRING, "ZP Dev Team + DRON12261")
	
	new index
	
	g_ZombieJumper = zp_class_zombie_register(zombieclass3_name, zombieclass3_info, zombieclass3_health, zombieclass3_speed, zombieclass3_gravity)
	zp_class_zombie_register_kb(g_ZombieJumper, zombieclass3_knockback)
	for (index = 0; index < sizeof zombieclass3_models; index++)
		zp_class_zombie_register_model(g_ZombieJumper, zombieclass3_models[index])
	for (index = 0; index < sizeof zombieclass3_clawmodels; index++)
		zp_class_zombie_register_claw(g_ZombieJumper, zombieclass3_clawmodels[index])
}
