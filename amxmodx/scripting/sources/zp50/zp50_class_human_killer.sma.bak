/*================================================================================
	
	----------------------------------
	-*- [ZP ROTD] Class: Human: Killer -*-
	----------------------------------
	
	This plugin is part of Zombie Plague Mod and is distributed under the
	terms of the GNU General Public License. Check ZP_ReadMe.txt for details.
	
================================================================================*/

#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <amxmisc>
#include <engine>
#include <xs>

#include <zp50_core>
#include <zp50_class_survivor>
#include <zp50_class_sniper>
#include <zp50_class_human>

#define TASK_BOT 1200
#define ID_TASK_BOT (taskid - TASK_BOT)

// Classic Human Attributes
new const humanclass7_name[] = "Killer"
new const humanclass7_info[] = "Sniper Master"
new const humanclass7_models[][] = { "arctic" , "guerilla" , "leet" , "terror" , "gign" , "gsg9" , "sas" , "urban" }
const humanclass7_health = 50
const humanclass7_armor = 50
const Float:humanclass7_speed = 0.9
const Float:humanclass7_gravity = 1.2

new g_HumanKiller

const XO_CWEAPONBOX = 4;
new const m_rgpPlayerItems_CWeaponBox[6] = {34, 35, ...}

const g_RestCountRunner = 20
new g_RestIdsRunner[g_RestCountRunner] = { CSW_GALIL, CSW_FAMAS, CSW_M4A1, CSW_AK47, CSW_SG552, CSW_AUG, CSW_M3, CSW_XM1014, CSW_M249, CSW_MAC10, CSW_UMP45, CSW_MP5NAVY, CSW_TMP, CSW_P90, CSW_P228, CSW_ELITE, CSW_FIVESEVEN, CSW_USP, CSW_GLOCK18, CSW_DEAGLE }

new g_MaxNumJumpsKiller = 3
new g_jumpNumKiller[33] = 0
new bool:g_doJumpKiller[33] = false

new Float: g_PushAngleKiller[33][3]

public plugin_precache()
{
	register_plugin("[ZP ROTD] Class: Human: Killer", ZP_VERSION_STRING, "ZP Dev Team + DRON12261")
	
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
	RegisterHam(Ham_Item_AddToPlayer, "weapon_mac10", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_ump45", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_mp5navy", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_tmp", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_p90", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_p228", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_glock18", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_usp", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_deagle", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_fiveseven", "fw_ItemAddPost", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_elite", "fw_ItemAddPost", true)
	
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_awp", "fw_Weapon_PrimaryAttack_Pre")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_awp", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_scout", "fw_Weapon_PrimaryAttack_Pre")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_scout", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_sg550", "fw_Weapon_PrimaryAttack_Pre")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_sg550", "fw_Weapon_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_g3sg1", "fw_Weapon_PrimaryAttack_Pre")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_g3sg1", "fw_Weapon_PrimaryAttack_Post", 1)
	
	g_HumanKiller = zp_class_human_register(humanclass7_name, humanclass7_info, humanclass7_health, humanclass7_armor, humanclass7_speed, humanclass7_gravity)
	new index
	for (index = 0; index < sizeof humanclass7_models; index++)
		zp_class_human_register_model(g_HumanKiller, humanclass7_models[index])
}

public client_putinserver(id)
{
	g_jumpNumKiller[id] = 0
	g_doJumpKiller[id] = false
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
	if (!is_user_alive(ID_TASK_BOT) || !is_user_connected(ID_TASK_BOT) || zp_class_human_get_current(ID_TASK_BOT) != g_HumanKiller || zp_class_sniper_get(ID_TASK_BOT) || zp_class_survivor_get(ID_TASK_BOT))
	{
		return
	}
	
	if (!CanUserPickupWeapon(get_user_weapon(ID_TASK_BOT)))
	{
		engclient_cmd(ID_TASK_BOT, "drop")
	}
}

public client_disconnected(id)
{	
	if (is_user_bot(id))
	{
		remove_task(id+TASK_BOT)
	}
	
	g_jumpNumKiller[id] = 0
	g_doJumpKiller[id] = false
}

public client_PreThink(id)
{
	if(!is_user_alive(id) || zp_class_human_get_current(id) != g_HumanKiller || zp_core_is_zombie(id) || zp_class_sniper_get(id) || zp_class_survivor_get(id)) 
	{
		return PLUGIN_CONTINUE
	}
	
	new nbut = get_user_button(id)
	new obut = get_user_oldbutton(id)
	
	if((nbut & IN_JUMP) && !(get_entity_flags(id) & FL_ONGROUND) && !(obut & IN_JUMP))
	{
		if(g_jumpNumKiller[id] < g_MaxNumJumpsKiller)
		{
			g_doJumpKiller[id] = true
			g_jumpNumKiller[id]++
			return PLUGIN_CONTINUE
		}
	}
	
	if((nbut & IN_JUMP) && (get_entity_flags(id) & FL_ONGROUND))
	{
		g_jumpNumKiller[id] = 0
		return PLUGIN_CONTINUE
	}
	
	return PLUGIN_CONTINUE
}

public client_PostThink(id)
{
	if(!is_user_alive(id) || zp_class_human_get_current(id) != g_HumanKiller || zp_core_is_zombie(id) || zp_class_sniper_get(id) || zp_class_survivor_get(id)) 
	{
		return PLUGIN_CONTINUE
	}
	
	if(g_doJumpKiller[id] == true)
	{
		new Float:velocity[3]	
		
		entity_get_vector(id,EV_VEC_velocity,velocity)
		velocity[2] = random_float(265.0,285.0)
		entity_set_vector(id,EV_VEC_velocity,velocity)
		g_doJumpKiller[id] = false
		
		return PLUGIN_CONTINUE
	}
	
	return PLUGIN_CONTINUE
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
	if (!is_user_alive(player) || zp_class_human_get_current(player) != g_HumanKiller)
	{
		return HAM_IGNORED
	}
	
	if(!CanUserPickupWeapon(cs_get_weaponbox_type(weapon)))
			return HAM_SUPERCEDE
	
	return HAM_IGNORED
}

public fw_ItemAddPost(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) != g_HumanKiller)
	{
		return HAM_IGNORED
	}
	
	client_cmd(player, "drop")
	return HAM_HANDLED
}

public fw_Weapon_PrimaryAttack_Pre(entity)
{
	new id = pev(entity, pev_owner)

	if(!is_user_alive(id) || zp_class_human_get_current(id) != g_HumanKiller || zp_core_is_zombie(id) || zp_class_sniper_get(id) || zp_class_survivor_get(id)) 
	{
		return HAM_IGNORED
	}
	
	pev(id, pev_punchangle, g_PushAngleKiller[id])
	
	return HAM_HANDLED;
}

public fw_Weapon_PrimaryAttack_Post(entity)
{
	new id = pev(entity, pev_owner)

	if(!is_user_alive(id) || zp_class_human_get_current(id) != g_HumanKiller || zp_core_is_zombie(id) || zp_class_sniper_get(id) || zp_class_survivor_get(id)) 
	{
		return HAM_IGNORED
	}
	
	new Float: push[3]
	pev(id, pev_punchangle, push)
	xs_vec_sub(push, g_PushAngleKiller[id], push)
	xs_vec_mul_scalar(push, 0.0, push)
	xs_vec_add(push, g_PushAngleKiller[id], push)
	set_pev(id, pev_punchangle, push)

	return HAM_HANDLED;
}