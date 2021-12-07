/*================================================================================
	
	----------------------------------
	-*- [ZP ROTD] Class: Human: Glowman -*-
	----------------------------------
	
	This plugin is part of Zombie Plague Mod and is distributed under the
	terms of the GNU General Public License. Check ZP_ReadMe.txt for details.
	
================================================================================*/

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <csx>
#include <hamsandwich>
#include <cs_ham_bots_api>

#include <zp50_core>
#include <zp50_class_survivor>
#include <zp50_class_sniper>
#include <zp50_gamemodes>
#include <zp50_class_human>

#define MAXPLAYERS 32

#define TASK_AURA 900
#define ID_AURA (taskid - TASK_AURA)
#define TASK_FLARE_GIVE 950
#define ID_FLARE_GIVE (taskid - TASK_FLARE_GIVE)

// Classic Human Attributes
new const humanclass4_name[] = "Glowman"
new const humanclass4_info[] = "With flares"
new const humanclass4_models[][] = { "arctic" , "guerilla" , "leet" , "terror" , "gign" , "gsg9" , "sas" , "urban" }
const humanclass4_health = 100
const humanclass4_armor = 10
const Float:humanclass4_speed = 1.1
const Float:humanclass4_gravity = 1.1
new humanclass4_weaponrestricts[] = {CSW_M3, CSW_XM1014, CSW_MAC10, CSW_UMP45, CSW_MP5NAVY, CSW_TMP, CSW_P90, CSW_SCOUT, CSW_AWP, CSW_G3SG1, CSW_SG550, CSW_M249}

new g_HumanGlowman

public plugin_precache()
{
	register_plugin("[ZP ROTD] Class: Human: Glowman", ZP_VERSION_STRING, "ZP Dev Team + DRON12261")
	
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	RegisterHamBots(Ham_Killed, "fw_PlayerKilled")
	
	g_HumanGlowman = zp_class_human_register(humanclass4_name, humanclass4_info, humanclass4_health, humanclass4_armor, humanclass4_speed, humanclass4_gravity)
	new index
	for (index = 0; index < sizeof humanclass4_models; index++)
		zp_class_human_register_model(g_HumanGlowman, humanclass4_models[index])
	for (index = 0; index < sizeof humanclass4_weaponrestricts; index++)
		zp_class_human_register_restricted_weapon(g_HumanGlowman, humanclass4_weaponrestricts[index])
}

public zp_fw_gamemodes_end()
{
	for (new i = 0; i <= MAXPLAYERS; i++)
	{
		remove_task(i+TASK_FLARE_GIVE)
	}
}

public client_disconnected(id)
{
	remove_task(id+TASK_AURA)
	remove_task(id+TASK_FLARE_GIVE)
}

public fw_PlayerKilled(victim, attacker, shouldgib)
{
	if (zp_class_human_get_current(victim) == g_HumanGlowman)
	{
		remove_task(victim+TASK_AURA)
		remove_task(victim+TASK_FLARE_GIVE)
	}
	return HAM_HANDLED
}

public zp_fw_core_spawn_post(id)
{
	remove_task(id+TASK_AURA)
	remove_task(id+TASK_FLARE_GIVE)
}

public zp_fw_core_infect_pre(id, attacker)
{
	if (zp_class_human_get_current(id) == g_HumanGlowman)
	{
		remove_task(id+TASK_AURA)
		remove_task(id+TASK_FLARE_GIVE)
	}
}

public zp_fw_core_cure_post(id, attacker)
{
	if (zp_class_human_get_current(id) == g_HumanGlowman)
	{
		set_task(0.1, "glowman_aura", id+TASK_AURA, _, _, "b")
	}
}

public glowman_aura(taskid)
{
	if (!is_user_connected(ID_AURA) || !is_user_alive(ID_AURA) || zp_class_human_get_current(ID_AURA) != g_HumanGlowman || zp_core_is_zombie(ID_AURA) || zp_class_sniper_get(ID_AURA) || zp_class_survivor_get(ID_AURA))
	{
		return
	}
	
	// Get player's origin
	static origin[3]
	get_user_origin(ID_AURA, origin)
	
	// Colored Aura
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_DLIGHT) // TE id
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	write_byte(30) // radius
	write_byte(150) // r
	write_byte(150) // g
	write_byte(150) // b
	write_byte(2) // life
	write_byte(0) // decay rate
	message_end()
}

public grenade_throw(player, grenade, type)
{
	if (!is_user_connected(player) || !is_user_alive(player) || zp_class_human_get_current(player) != g_HumanGlowman || zp_core_is_zombie(player) || zp_class_sniper_get(player) || zp_class_survivor_get(player))
		return 0;
	
	if (type == CSW_SMOKEGRENADE)
	{
		set_task(30.0, "give_flare", player+TASK_FLARE_GIVE, _, _)	
	}
	
	return 1;
}

public give_flare(taskid)
{
	if (!is_user_alive(ID_FLARE_GIVE) || zp_class_human_get_current(ID_FLARE_GIVE) != g_HumanGlowman || zp_core_is_zombie(ID_FLARE_GIVE) || zp_class_sniper_get(ID_FLARE_GIVE) || zp_class_survivor_get(ID_FLARE_GIVE))
	{
		return
	}
	
	give_item(ID_FLARE_GIVE, "weapon_smokegrenade")
}
