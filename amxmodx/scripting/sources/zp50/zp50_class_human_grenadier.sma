/*================================================================================
	
	----------------------------------
	-*- [ZP ROTD] Class: Human: Grenadier -*-
	----------------------------------
	
	This plugin is part of Zombie Plague Mod and is distributed under the
	terms of the GNU General Public License. Check ZP_ReadMe.txt for details.
	
================================================================================*/

#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <fun>
#include <csx>

#include <zp50_core>
#include <zp50_class_survivor>
#include <zp50_class_sniper>
#include <zp50_class_human>

#define MAXPLAYERS 32

#define TASK_NAPALM_GIVE 1300
#define ID_NAPALM_GIVE (taskid - TASK_NAPALM_GIVE)
#define TASK_FROST_GIVE 1350
#define ID_FROST_GIVE (taskid - TASK_FROST_GIVE)

// Grenadier Attributes
new const humanclass6_name[] = "Grenadier"
new const humanclass6_info[] = "Unlimited Grenades"
new const humanclass6_models[][] = { "arctic" , "guerilla" , "leet" , "terror" , "gign" , "gsg9" , "sas" , "urban" }
const humanclass6_health = 75
const humanclass6_armor = 15
const Float:humanclass6_speed = 0.9
const Float:humanclass6_gravity = 1.0
new humanclass6_weaponrestricts[] = { CSW_GALIL, CSW_FAMAS, CSW_M4A1, CSW_AK47, CSW_SG552, CSW_AUG, CSW_M249, CSW_AWP, CSW_SG550, CSW_G3SG1, CSW_SCOUT, CSW_MAC10, CSW_UMP45, CSW_MP5NAVY, CSW_TMP, CSW_P90 }

new g_HumanGrenadier

public plugin_precache()
{
	register_plugin("[ZP ROTD] Class: Human: Grenadier", ZP_VERSION_STRING, "ZP Dev Team + DRON12261")
	
	g_HumanGrenadier = zp_class_human_register(humanclass6_name, humanclass6_info, humanclass6_health, humanclass6_armor, humanclass6_speed, humanclass6_gravity)
	new index
	for (index = 0; index < sizeof humanclass6_models; index++)
		zp_class_human_register_model(g_HumanGrenadier, humanclass6_models[index])
	for (index = 0; index < sizeof humanclass6_weaponrestricts; index++)
		zp_class_human_register_restricted_weapon(g_HumanGrenadier, humanclass6_weaponrestricts[index])
}

public zp_fw_gamemodes_end()
{
	for (new i = 0; i <= MAXPLAYERS; i++)
	{
		remove_task(i+TASK_NAPALM_GIVE)
		remove_task(i+TASK_FROST_GIVE)
	}
}

public client_disconnected(id)
{
	remove_task(id+TASK_NAPALM_GIVE)
	remove_task(id+TASK_FROST_GIVE)
}

public fw_PlayerKilled(victim, attacker, shouldgib)
{
	if (zp_class_human_get_current(victim) == g_HumanGrenadier)
	{
		remove_task(victim+TASK_NAPALM_GIVE)
		remove_task(victim+TASK_FROST_GIVE)
	}
	return HAM_HANDLED
}

public zp_fw_core_spawn_post(id)
{
	remove_task(id+TASK_NAPALM_GIVE)
	remove_task(id+TASK_FROST_GIVE)
}

public zp_fw_core_infect_pre(id, attacker)
{
	if (zp_class_human_get_current(id) == g_HumanGrenadier)
	{
		remove_task(id+TASK_NAPALM_GIVE)
		remove_task(id+TASK_FROST_GIVE)
	}
}

public grenade_throw(player, grenade, type)
{
	if (!is_user_connected(player) || !is_user_alive(player) || zp_class_human_get_current(player) != g_HumanGrenadier || zp_core_is_zombie(player) || zp_class_sniper_get(player) || zp_class_survivor_get(player))
		return 0;
     
	if (type == CSW_HEGRENADE)
		set_task(30.0, "give_napalm", player+TASK_NAPALM_GIVE, _, _)

	if (type == CSW_FLASHBANG)
		set_task(30.0, "give_frost", player+TASK_FROST_GIVE, _, _)
     
	return 1;
}

public give_napalm(taskid)
{
	if (!is_user_alive(ID_NAPALM_GIVE) || zp_class_human_get_current(ID_NAPALM_GIVE) != g_HumanGrenadier || zp_core_is_zombie(ID_NAPALM_GIVE) || zp_class_sniper_get(ID_NAPALM_GIVE) || zp_class_survivor_get(ID_NAPALM_GIVE))
	{
		return
	}
	
	give_item(ID_NAPALM_GIVE, "weapon_hegrenade")
}

public give_frost(taskid)
{
	if (!is_user_alive(ID_FROST_GIVE) || zp_class_human_get_current(ID_FROST_GIVE) != g_HumanGrenadier || zp_core_is_zombie(ID_FROST_GIVE) || zp_class_sniper_get(ID_FROST_GIVE) || zp_class_survivor_get(ID_FROST_GIVE))
	{
		return
	}
	
	give_item(ID_FROST_GIVE, "weapon_flashbang")
}
