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
#include <csx>
#include <fun>
#include <fakemeta>
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
#define TASK_BOT 1100
#define ID_TASK_BOT (taskid - TASK_BOT)

// Classic Human Attributes
new const humanclass4_name[] = "Glowman"
new const humanclass4_info[] = "With flares"
new const humanclass4_models[][] = { "arctic" , "guerilla" , "leet" , "terror" , "gign" , "gsg9" , "sas" , "urban" }
const humanclass4_health = 100
const humanclass4_armor = 10
const Float:humanclass4_speed = 1.1
const Float:humanclass4_gravity = 1.1

new g_HumanGlowman

const XO_CWEAPONBOX = 4;
new const m_rgpPlayerItems_CWeaponBox[6] = {34, 35, ...}

const g_RestCountGlowman = 12
new g_RestIdsGlowman[g_RestCountGlowman] = { CSW_M3, CSW_XM1014, CSW_M249, CSW_AWP, CSW_SG550, CSW_G3SG1, CSW_SCOUT, CSW_MAC10, CSW_UMP45, CSW_MP5NAVY, CSW_TMP, CSW_P90 }

public plugin_precache()
{
	register_plugin("[ZP ROTD] Class: Human: Glowman", ZP_VERSION_STRING, "ZP Dev Team + DRON12261")
	
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	RegisterHamBots(Ham_Killed, "fw_PlayerKilled")
	
	RegisterHam(Ham_Touch, "weaponbox", "fw_TouchWeapon")
	
	RegisterHam(Ham_Item_AddToPlayer, "weapon_scout", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_mac10", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_ump45", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_mp5navy", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_tmp", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_p90", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_m3", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_xm1014", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_m249", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_awp", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_sg550", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_g3sg1", "fw_ItemAddPost", true)
	
	g_HumanGlowman = zp_class_human_register(humanclass4_name, humanclass4_info, humanclass4_health, humanclass4_armor, humanclass4_speed, humanclass4_gravity)
	new index
	for (index = 0; index < sizeof humanclass4_models; index++)
		zp_class_human_register_model(g_HumanGlowman, humanclass4_models[index])
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
	if (!is_user_alive(ID_TASK_BOT) || !is_user_connected(ID_TASK_BOT) || zp_class_human_get_current(ID_TASK_BOT) != g_HumanGlowman || zp_class_sniper_get(ID_TASK_BOT) || zp_class_survivor_get(ID_TASK_BOT))
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
		remove_task(i+TASK_FLARE_GIVE)
	}
}

public client_disconnected(id)
{
	remove_task(id+TASK_AURA)
	remove_task(id+TASK_FLARE_GIVE)
	
	if (is_user_bot(id))
	{
		remove_task(id+TASK_BOT)
	}
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
	for (new i = 0; i < g_RestCountGlowman; i++)
	{
		if(weapon == g_RestIdsGlowman[i])
		{
			return false
		}
	}
	return true
}

public fw_TouchWeapon(weapon, player)
{
	if (!pev_valid(weapon) || !is_user_alive(player) || zp_class_human_get_current(player) != g_HumanGlowman)
	{
		return HAM_IGNORED
	}
	
	if(!CanUserPickupWeapon(cs_get_weaponbox_type(weapon)))
			return HAM_SUPERCEDE
	
	return HAM_IGNORED
}

public fw_ItemAddPost(weapon, player)
{	
	if (!pev_valid(weapon) || !is_user_alive(player) || zp_class_human_get_current(player) != g_HumanGlowman)
	{
		return HAM_IGNORED
	}
	
	client_cmd(player, "drop")
	return HAM_HANDLED
}

public grenade_throw(player, grenade, type)
{
	if (!is_user_connected(player) || !is_user_alive(player) || zp_class_human_get_current(player) != g_HumanGlowman || zp_core_is_zombie(player) || zp_class_sniper_get(player) || zp_class_survivor_get(player))
		return 0;
     
	if (type == CSW_SMOKEGRENADE)
		set_task(30.0, "give_flare", player+TASK_FLARE_GIVE, _, _)
     
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
