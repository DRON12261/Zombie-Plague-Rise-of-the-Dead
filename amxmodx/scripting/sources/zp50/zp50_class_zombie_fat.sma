/*================================================================================
	
	-------------------------------
	-*- [ZP ROTD] Class: Zombie: Fat -*-
	-------------------------------
	
	This plugin is part of Zombie Plague Mod and is distributed under the
	terms of the GNU General Public License. Check ZP_ReadMe.txt for details.
	
================================================================================*/

#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <cs_ham_bots_api>
#include <amx_settings_api>
#include <cs_maxspeed_api>

#include <zp50_core>
#include <zp50_class_nemesis>
#include <zp50_class_assassin>
#include <zp50_class_zombie>

// Settings file
new const ZP_SETTINGS_FILE[] = "zombieplague.ini"

#define SOUND_MAX_LENGTH 64

// Fat Zombie Attributes
new const zombieclass4_name[] = "Fat Zombie"
new const zombieclass4_info[] = "HP++ Speed- Knockback--"
new const zombieclass4_models[][] = { "zombie_source" }
new const zombieclass4_clawmodels[][] = { "models/zombie_plague/v_knife_zombie.mdl" }
const zombieclass4_health = 2700
const Float:zombieclass4_speed = 0.5
const Float:zombieclass4_gravity = 1.0
const Float:zombieclass4_knockback = 0.05

new g_ZombieFat

new Float:g_DefaultSpeedFat = zombieclass4_speed
new Float:g_BlockSpeedFat = 0.3
new Float:g_BlockTimeFat = 5.0
new Float:g_BlockCooldownFat = 20.0

new Float:g_iLastBlock[33]
new g_block[33]

new Float:g_iLastBotSkill[33]
new Float:g_BotSkillCooldown = 5.0

new g_maxplayers

new const sound_fat_block[][] = { "zombie_plague/zombies/fat_block1.wav", "zombie_plague/zombies/fat_block2.wav" }
new Array:g_sound_fat_block

public plugin_init()
{
	register_event("HLTV", "roundStart", "a", "1=0", "2=0")
}

public plugin_precache()
{
	register_plugin("[ZP ROTD] Class: Zombie: Fat", ZP_VERSION_STRING, "ZP Dev Team + DRON12261")
	
	new index
	
	RegisterHam(Ham_Player_PreThink, "player", "fw_PlayerPreThink")
	RegisterHamBots(Ham_Player_PreThink, "fw_PlayerPreThink")
	RegisterHam(Ham_Player_PreThink, "player", "client_prethink")
	RegisterHamBots(Ham_Player_PreThink, "client_prethink")
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	RegisterHamBots(Ham_TakeDamage, "fw_TakeDamage")
	
	g_ZombieFat = zp_class_zombie_register(zombieclass4_name, zombieclass4_info, zombieclass4_health, zombieclass4_speed, zombieclass4_gravity)
	zp_class_zombie_register_kb(g_ZombieFat, zombieclass4_knockback)
	for (index = 0; index < sizeof zombieclass4_models; index++)
		zp_class_zombie_register_model(g_ZombieFat, zombieclass4_models[index])
	for (index = 0; index < sizeof zombieclass4_clawmodels; index++)
		zp_class_zombie_register_claw(g_ZombieFat, zombieclass4_clawmodels[index])
		
	g_sound_fat_block = ArrayCreate(SOUND_MAX_LENGTH, 1)
	
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE FAT BLOCK", g_sound_fat_block)
	
	if (ArraySize(g_sound_fat_block) == 0)
	{
		for (index = 0; index < sizeof sound_fat_block; index++)
			ArrayPushString(g_sound_fat_block, sound_fat_block[index])
		
		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE FAT BLOCK", g_sound_fat_block)
	}
	
	new sound[SOUND_MAX_LENGTH]
	for (index = 0; index < ArraySize(g_sound_fat_block); index++)
	{
		ArrayGetString(g_sound_fat_block, index, sound, charsmax(sound))
		precache_sound(sound)
	}
	
	g_maxplayers = get_maxplayers()
}

public zp_fw_core_cure_post(id, attacer)
{
	g_block[id] = 0
}

public fw_PlayerPreThink(id)
{
	if (!is_user_connected(id) || !is_user_alive(id) || zp_class_zombie_get_current(id) != g_ZombieFat || !zp_core_is_zombie(id) || zp_class_assassin_get(id) || zp_class_nemesis_get(id))
	{
		return HAM_IGNORED
	}
	
	static sound[SOUND_MAX_LENGTH]
	
	static iButton; iButton = pev(id, pev_button)
	static iOldButton; iOldButton = pev(id, pev_oldbuttons)
	
	if(((iButton & IN_RELOAD) && !(iOldButton & IN_RELOAD)) || is_user_bot(id))
	{
		if(get_gametime() - g_iLastBlock[id] < g_BlockCooldownFat)
		{
			return HAM_HANDLED
		}
		
		g_iLastBlock[id] = get_gametime()
		
		if((get_gametime() - g_iLastBotSkill[id] < g_BotSkillCooldown) && is_user_bot(id))
		{
			return HAM_HANDLED
		}
		
		g_iLastBotSkill[id] = get_gametime()
		
		new skill_chance = random_num(0, 100)
		
		if ((is_user_bot(id) && skill_chance < 70) || !is_user_bot(id))
		{
			g_block[id] = 1
			
			ArrayGetString(g_sound_fat_block, random_num(0, ArraySize(g_sound_fat_block) - 1), sound, charsmax(sound))
			emit_sound(id, CHAN_STREAM, sound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			
			set_task(g_BlockTimeFat, "normal", id)
			
			return HAM_HANDLED
		}
		
		return HAM_IGNORED
	}
	
	return HAM_IGNORED
}

public normal(id)
{
	g_block[id] = 0
}

public client_prethink(id)
{
	if (!is_user_connected(id) || !is_user_alive(id) || zp_class_zombie_get_current(id) != g_ZombieFat || !zp_core_is_zombie(id) || zp_class_assassin_get(id) || zp_class_nemesis_get(id))
	{
		return HAM_IGNORED
	}
	
	if(g_block[id] == 1)
	{
		cs_set_player_maxspeed_auto(id, g_BlockSpeedFat)
	}
	else if(g_block[id] == 0)
	{
		cs_set_player_maxspeed_auto(id, g_DefaultSpeedFat)
	}
	
	return HAM_HANDLED
}

public roundStart()
{
	for (new i = 1; i <= g_maxplayers; i++)
	{
		g_block[i] = 0
	}
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
	if (!is_user_connected(victim) || !is_user_alive(victim) || zp_class_zombie_get_current(victim) != g_ZombieFat || !zp_core_is_zombie(victim) || zp_class_assassin_get(victim) || zp_class_nemesis_get(victim))
	{
		return HAM_IGNORED
	}
	
	if(g_block[victim] == 1)
	{
		SetHamParamFloat(4, 0.1 * damage)
		return HAM_HANDLED
	}
	
	return HAM_IGNORED
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
