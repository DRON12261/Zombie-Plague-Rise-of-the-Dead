/*================================================================================
	
	----------------------------------
	-*- [ZP ROTD] Class: Human: Runner -*-
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

#include <zp50_core>
#include <zp50_class_survivor>
#include <zp50_class_sniper>
#include <zp50_class_human>

#define MAXPLAYERS 32

// Classic Human Attributes
new const humanclass5_name[] = "Runner"
new const humanclass5_info[] = "GottaGoFast"
new const humanclass5_models[][] = { "arctic" , "guerilla" , "leet" , "terror" , "gign" , "gsg9" , "sas" , "urban" }
const humanclass5_health = 50
const humanclass5_armor = 0
const Float:humanclass5_speed = 2.0
const Float:humanclass5_gravity = 0.5
new humanclass5_weaponrestricts[] = { CSW_GALIL, CSW_FAMAS, CSW_M4A1, CSW_AK47, CSW_SG552, CSW_AUG, CSW_M3, CSW_XM1014, CSW_M249, CSW_AWP, CSW_SG550, CSW_G3SG1, CSW_SCOUT, CSW_MAC10, CSW_UMP45, CSW_MP5NAVY, CSW_TMP, CSW_P90 }

new g_HumanRunner

new Float:g_LeapLastTimeRunner[MAXPLAYERS+1]

new Float:g_CooldownRunner = 10.0
new g_ForceRunner = 600
new Float:g_HeightRunner = 200.0

public plugin_precache()
{
	register_plugin("[ZP ROTD] Class: Human: Runner", ZP_VERSION_STRING, "ZP Dev Team + DRON12261")
	
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	RegisterHamBots(Ham_TakeDamage, "fw_TakeDamage")
	
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	
	g_HumanRunner = zp_class_human_register(humanclass5_name, humanclass5_info, humanclass5_health, humanclass5_armor, humanclass5_speed, humanclass5_gravity)
	new index
	for (index = 0; index < sizeof humanclass5_models; index++)
		zp_class_human_register_model(g_HumanRunner, humanclass5_models[index])
	for (index = 0; index < sizeof humanclass5_weaponrestricts; index++)
		zp_class_human_register_restricted_weapon(g_HumanRunner, humanclass5_weaponrestricts[index])
}

// Get entity's speed (from fakemeta_util)
stock fm_get_speed(entity)
{
	static Float:velocity[3]
	pev(entity, pev_velocity, velocity)
	
	return floatround(vector_length(velocity));
}

public fw_PlayerPreThink(id)
{
	if (!is_user_alive(id) || zp_class_human_get_current(id) != g_HumanRunner || zp_core_is_zombie(id) || zp_class_sniper_get(id) || zp_class_survivor_get(id))
	{
		return
	}
		
	static Float:current_time
	current_time = get_gametime()
	
	// Cooldown not over yet
	if (current_time - g_LeapLastTimeRunner[id] < g_CooldownRunner)
		return;
	
	// Not doing a longjump (don't perform check for bots, they leap automatically)
	if (!is_user_bot(id) && !(pev(id, pev_button) & (IN_JUMP | IN_DUCK) == (IN_JUMP | IN_DUCK)))
		return;
	
	// Not on ground or not enough speed
	if (!(pev(id, pev_flags) & FL_ONGROUND) || fm_get_speed(id) < 80)
		return;
	
	static Float:velocity[3]
	
	// Make velocity vector
	velocity_by_aim(id, g_ForceRunner, velocity)
	
	// Set custom height
	velocity[2] = g_HeightRunner
	
	// Apply the new velocity
	set_pev(id, pev_velocity, velocity)
	
	// Update last leap time
	g_LeapLastTimeRunner[id] = current_time
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if (victim == attacker || !is_user_alive(attacker) || zp_class_human_get_current(attacker) != g_HumanRunner || zp_core_is_zombie(attacker) || zp_class_sniper_get(attacker) || zp_class_survivor_get(attacker))
	{
		return HAM_IGNORED
	}
	
	if (inflictor == attacker)
	{
		new plrWeapId, plrClip, plrAmmo    
		plrWeapId = get_user_weapon(attacker, plrClip, plrAmmo)
		
		if (plrWeapId == CSW_P228 || CSW_ELITE || CSW_FIVESEVEN || CSW_USP || CSW_GLOCK18 || CSW_DEAGLE) 
		{
			SetHamParamFloat(4, damage * 1.5)
		}
		else if (plrWeapId == CSW_KNIFE) 
		{
			SetHamParamFloat(4, damage * 3.0)
		}
	}
	return HAM_HANDLED
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
