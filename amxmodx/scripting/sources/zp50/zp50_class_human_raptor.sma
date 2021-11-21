/*================================================================================
	
	----------------------------------
	-*- [ZP ROTD] Class: Human: Raptor -*-
	----------------------------------
	
	This plugin is part of Zombie Plague Mod and is distributed under the
	terms of the GNU General Public License. Check ZP_ReadMe.txt for details.
	
================================================================================*/

#include <amxmodx>
#include <fakemeta>
#include <cstrike>
#include <hamsandwich>
#include <cs_ham_bots_api>
#include <engine>

#include <zp50_class_survivor>
#include <zp50_class_sniper>
#include <zp50_class_human>

#define TASK_BOT 1150
#define ID_TASK_BOT (taskid - TASK_BOT)

// Raptor Human Attributes
new const humanclass2_name[] = "Raptor Human"
new const humanclass2_info[] = "Speed Up"
new const humanclass2_models[][] = { "leet" }
const humanclass2_health = 50
const humanclass2_armor = 15
const Float:humanclass2_speed = 1.2
const Float:humanclass2_gravity = 1.2

new g_HumanRaptor

const XO_CWEAPONBOX = 4;
new const m_rgpPlayerItems_CWeaponBox[6] = {34, 35, ...}

const g_RestCountRaptor = 12
new g_RestIdsRaptor[g_RestCountRaptor] = { CSW_GALIL, CSW_FAMAS, CSW_M4A1, CSW_AK47, CSW_SG552, CSW_AUG, CSW_M3, CSW_XM1014, CSW_M249, CSW_AWP, CSW_SG550, CSW_G3SG1 }

public plugin_precache()
{
	register_plugin("[ZP ROTD] Class: Human: Raptor", ZP_VERSION_STRING, "ZP Dev Team + DRON12261")
	
	RegisterHam(Ham_Touch, "weaponbox", "fw_TouchWeapon")
	
	RegisterHam(Ham_Item_AddToPlayer, "weapon_galil", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_famas", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_m4a1", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_ak47", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_sg552", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_aug", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_m3", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_xm1014", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_m249", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_awp", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_sg550", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_g3sg1", "fw_ItemAddPost", true)
	
	g_HumanRaptor = zp_class_human_register(humanclass2_name, humanclass2_info, humanclass2_health, humanclass2_armor, humanclass2_speed, humanclass2_gravity)
	new index
	for (index = 0; index < sizeof humanclass2_models; index++)
		zp_class_human_register_model(g_HumanRaptor, humanclass2_models[index])
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
	if (!is_user_alive(ID_TASK_BOT) || !is_user_connected(ID_TASK_BOT) || zp_class_human_get_current(ID_TASK_BOT) != g_HumanRaptor || zp_class_sniper_get(ID_TASK_BOT) || zp_class_survivor_get(ID_TASK_BOT))
	{
		return
	}
	
	if (!CanUserPickupWeapon(get_user_weapon(ID_TASK_BOT)))
	{
		engclient_cmd(ID_TASK_BOT, "drop")
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
	for (new i = 0; i < g_RestCountRaptor; i++)
	{
		if(weapon == g_RestIdsRaptor[i])
		{
			return false
		}
	}
	return true
}

public fw_TouchWeapon(weapon, player)
{
	if (!is_user_alive(player) || zp_class_human_get_current(player) != g_HumanRaptor)
	{
		return HAM_IGNORED
	}
	
	if(!CanUserPickupWeapon(cs_get_weaponbox_type(weapon)))
			return HAM_SUPERCEDE
	
	return HAM_IGNORED
}

public fw_ItemAddPost(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) != g_HumanRaptor)
	{
		return HAM_IGNORED
	}
	
	client_cmd(player, "drop")
	return HAM_HANDLED
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
