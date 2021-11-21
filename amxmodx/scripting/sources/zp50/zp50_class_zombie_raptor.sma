/*================================================================================
	
	----------------------------------
	-*- [ZP ROTD] Class: Zombie: Raptor -*-
	----------------------------------
	
	This plugin is part of Zombie Plague Mod and is distributed under the
	terms of the GNU General Public License. Check ZP_ReadMe.txt for details.
	
================================================================================*/

#include <amxmodx>
#include <hamsandwich>
#include <cs_ham_bots_api>

#include <zp50_core>
#include <zp50_class_nemesis>
#include <zp50_class_assassin>
#include <zp50_class_zombie>

// Raptor Zombie Attributes
new const zombieclass2_name[] = "Raptor Zombie"
new const zombieclass2_info[] = "HP-- Speed++ Knockback++"
new const zombieclass2_models[][] = { "zombie_source" }
new const zombieclass2_clawmodels[][] = { "models/zombie_plague/v_knife_zombie.mdl" }
const zombieclass2_health = 900
const Float:zombieclass2_speed = 0.9
const Float:zombieclass2_gravity = 1.0
const Float:zombieclass2_knockback = 1.5

new g_ZombieRaptor

new Float:g_DefaultSpeedRaptor = zombieclass2_speed
new Float:g_SprintSpeedRaptor = 1.2
new Float:g_SprintTimeRaptor = 3.0
new Float:g_SprintCooldownRaptor = 20.0

public plugin_precache()
{
	register_plugin("[ZP ROTD] Class: Zombie: Raptor", ZP_VERSION_STRING, "ZP Dev Team + DRON12261")
	
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	RegisterHamBots(Ham_Killed, "fw_PlayerKilled")
	
	new index
	
	g_ZombieRaptor = zp_class_zombie_register(zombieclass2_name, zombieclass2_info, zombieclass2_health, zombieclass2_speed, zombieclass2_gravity)
	zp_class_zombie_register_kb(g_ZombieRaptor, zombieclass2_knockback)
	for (index = 0; index < sizeof zombieclass2_models; index++)
		zp_class_zombie_register_model(g_ZombieRaptor, zombieclass2_models[index])
	for (index = 0; index < sizeof zombieclass2_clawmodels; index++)
		zp_class_zombie_register_claw(g_ZombieRaptor, zombieclass2_clawmodels[index])
}

public fw_PlayerKilled(victim, attacker, shouldgib)
{
	if (zp_class_zombie_get_current(victim) != g_ZombieRaptor || zp_class_nemesis_get(victim) || zp_class_assassin_get(victim))
	{
		return
	}
	
	SetHamParamInteger(3, 2)
}