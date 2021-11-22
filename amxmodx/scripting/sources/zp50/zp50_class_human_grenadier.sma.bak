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

#include <zp50_core>
#include <zp50_class_survivor>
#include <zp50_class_sniper>
#include <zp50_class_human>

#define MAXPLAYERS 32

#define TASK_BOT 1250
#define ID_TASK_BOT (taskid - TASK_BOT)
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

new g_HumanGrenadier

const XO_CWEAPONBOX = 4;
new const m_rgpPlayerItems_CWeaponBox[6] = {34, 35, ...}

const g_RestCountRunner = 16
new g_RestIdsRunner[g_RestCountRunner] = { CSW_GALIL, CSW_FAMAS, CSW_M4A1, CSW_AK47, CSW_SG552, CSW_AUG, CSW_M249, CSW_AWP, CSW_SG550, CSW_G3SG1, CSW_SCOUT, CSW_MAC10, CSW_UMP45, CSW_MP5NAVY, CSW_TMP, CSW_P90 }

public plugin_precache()
{
	register_plugin("[ZP ROTD] Class: Human: Grenadier", ZP_VERSION_STRING, "ZP Dev Team + DRON12261")
	
	RegisterHam(Ham_Touch, "weaponbox", "fw_TouchWeapon")

	RegisterHam(Ham_Item_AddToPlayer, "weapon_galil", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_famas", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_m4a1", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_ak47", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_sg552", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_aug", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_m249", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_awp", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_sg550", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_g3sg1", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_scout", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_mac10", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_ump45", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_mp5navy", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_tmp", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_p90", "fw_ItemAddPost", true)
	
	g_HumanGrenadier = zp_class_human_register(humanclass6_name, humanclass6_info, humanclass6_health, humanclass6_armor, humanclass6_speed, humanclass6_gravity)
	new index
	for (index = 0; index < sizeof humanclass6_models; index++)
		zp_class_human_register_model(g_HumanGrenadier, humanclass6_models[index])
}

public client_connect(id)
{
	if (is_user_bot(id))
	{
		set_task(0.1, "BotsHandle", id+TASK_BOT, _, _, "b");
	}
}

public BotsHandle(taskid)
{
	if (!is_user_alive(ID_TASK_BOT) || !is_user_connected(ID_TASK_BOT) || zp_class_human_get_current(ID_TASK_BOT) != g_HumanGrenadier || zp_class_sniper_get(ID_TASK_BOT) || zp_class_survivor_get(ID_TASK_BOT))
	{
		return
	}
	
	if (!CanUserPickupWeapon(get_user_weapon(ID_TASK_BOT)))
	{
		engclient_cmd(ID_TASK_BOT, "drop")
	}
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
	
	if (is_user_bot(id))
	{
		remove_task(id+TASK_BOT)
	}
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

cs_get_weaponbox_type( iWeaponBox ) // assuming weaponbox contain only 1 weapon
{
    new iWeapon
    for(new i=1; i<=5; i++)
    {
        iWeapon = get_pdata_cbase(iWeaponBox, m_rgpPlayerItems_CWeaponBox[i], XO_CWEAPONBOX)
        if( iWeapon > 0 )
        {
            return cs_get_weapon_id(iWeapon)
        }
    }
    return 0
}

bool:CanUserPickupWeapon(weapon)
{
	for (new i = 0; i < g_RestCountRunner; i++)
	{
		if(weapon == g_RestIdsRunner[i])
		{
			return false
		}
	}
	return true
}

public fw_TouchWeapon(weapon, player)
{
	if (!is_user_alive(player) || zp_class_human_get_current(player) != g_HumanGrenadier)
	{
		return HAM_IGNORED
	}
	
	if(!CanUserPickupWeapon(cs_get_weaponbox_type(weapon)))
			return HAM_SUPERCEDE
	
	return HAM_IGNORED
}

public fw_ItemAddPost(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) != g_HumanGrenadier)
	{
		return HAM_IGNORED
	}
	
	client_cmd(player, "drop")
	return HAM_HANDLED
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