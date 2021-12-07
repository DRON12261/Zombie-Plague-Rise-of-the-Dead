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

// Classic Human Attributes
new const humanclass7_name[] = "Killer"
new const humanclass7_info[] = "Sniper Master"
new const humanclass7_models[][] = { "arctic" , "guerilla" , "leet" , "terror" , "gign" , "gsg9" , "sas" , "urban" }
const humanclass7_health = 50
const humanclass7_armor = 50
const Float:humanclass7_speed = 0.9
const Float:humanclass7_gravity = 1.2
new const humanclass7_weaponrestricts[] = {CSW_P228, CSW_ELITE, CSW_FIVESEVEN, CSW_USP, CSW_GLOCK18, CSW_DEAGLE, CSW_M3, CSW_XM1014, CSW_MAC10, CSW_UMP45, CSW_MP5NAVY, CSW_TMP, CSW_P90, CSW_AUG, CSW_GALIL, CSW_FAMAS, CSW_M4A1, CSW_AK47, CSW_SG552, CSW_M249}

new g_HumanKiller

new g_MaxNumJumpsKiller = 2
new g_jumpNumKiller[33] = 0
new bool:g_doJumpKiller[33] = false

new Float: g_PushAngleKiller[33][3]

public plugin_precache()
{
	register_plugin("[ZP ROTD] Class: Human: Killer", ZP_VERSION_STRING, "ZP Dev Team + DRON12261")
	
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
	for (index = 0; index < sizeof humanclass7_weaponrestricts; index++)
		zp_class_human_register_restricted_weapon(g_HumanKiller, humanclass7_weaponrestricts[index])
}

public client_putinserver(id)
{
	g_jumpNumKiller[id] = 0
	g_doJumpKiller[id] = false
}

public client_disconnected(id)
{		
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
