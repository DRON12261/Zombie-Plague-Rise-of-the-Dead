/*================================================================================
	
	----------------------------------
	-*- [ZP ROTD] Class: Zombie: Raptor -*-
	----------------------------------
	
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
new Float:g_SprintSpeedRaptor = 3.0
new Float:g_SprintTimeRaptor = 2.0
new Float:g_SprintCooldownRaptor = 15.0

new Float:g_iLastSprint[33]
new g_speed[33]

new Float:g_iLastBotSkill[33]
new Float:g_BotSkillCooldown = 5.0

new g_maxplayers

new const sound_raptor_sprint[][] = { "zombie_plague/zombies/raptor_sprint1.wav", "zombie_plague/zombies/raptor_sprint2.wav" }
new Array:g_sound_raptor_sprint

public plugin_init()
{
	register_event("HLTV", "roundStart", "a", "1=0", "2=0")
}

public plugin_precache()
{
	register_plugin("[ZP ROTD] Class: Zombie: Raptor", ZP_VERSION_STRING, "ZP Dev Team + DRON12261")
	
	new index
	
	g_ZombieRaptor = zp_class_zombie_register(zombieclass2_name, zombieclass2_info, zombieclass2_health, zombieclass2_speed, zombieclass2_gravity)
	zp_class_zombie_register_kb(g_ZombieRaptor, zombieclass2_knockback)
	for (index = 0; index < sizeof zombieclass2_models; index++)
		zp_class_zombie_register_model(g_ZombieRaptor, zombieclass2_models[index])
	for (index = 0; index < sizeof zombieclass2_clawmodels; index++)
		zp_class_zombie_register_claw(g_ZombieRaptor, zombieclass2_clawmodels[index])
	
	RegisterHam(Ham_Player_PreThink, "player", "fw_PlayerPreThink")
	RegisterHamBots(Ham_Player_PreThink, "fw_PlayerPreThink")
	RegisterHam(Ham_Player_PreThink, "player", "client_prethink")
	RegisterHamBots(Ham_Player_PreThink, "client_prethink")
		
	g_sound_raptor_sprint = ArrayCreate(SOUND_MAX_LENGTH, 1)
	
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAPTOR SPRINT", g_sound_raptor_sprint)
	
	if (ArraySize(g_sound_raptor_sprint) == 0)
	{
		for (index = 0; index < sizeof sound_raptor_sprint; index++)
			ArrayPushString(g_sound_raptor_sprint, sound_raptor_sprint[index])
		
		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAPTOR SPRINT", g_sound_raptor_sprint)
	}
	
	new sound[SOUND_MAX_LENGTH]
	for (index = 0; index < ArraySize(g_sound_raptor_sprint); index++)
	{
		ArrayGetString(g_sound_raptor_sprint, index, sound, charsmax(sound))
		precache_sound(sound)
	}
	
	g_maxplayers = get_maxplayers()
}

public zp_fw_core_cure_post(id, attacer)
{
	g_speed[id] = 0
}

public fw_PlayerPreThink(id)
{
	if (!is_user_connected(id) || !is_user_alive(id) || zp_class_zombie_get_current(id) != g_ZombieRaptor || !zp_core_is_zombie(id) || zp_class_assassin_get(id) || zp_class_nemesis_get(id))
	{
		return HAM_IGNORED
	}
	
	static sound[SOUND_MAX_LENGTH]
	
	static iButton; iButton = pev(id, pev_button)
	static iOldButton; iOldButton = pev(id, pev_oldbuttons)
	
	if(((iButton & IN_RELOAD) && !(iOldButton & IN_RELOAD)) || is_user_bot(id))
	{
		if(get_gametime() - g_iLastSprint[id] < g_SprintCooldownRaptor)
		{
			return HAM_HANDLED
		}
		
		g_iLastSprint[id] = get_gametime()
		
		if((get_gametime() - g_iLastBotSkill[id] < g_BotSkillCooldown) && is_user_bot(id))
		{
			return HAM_HANDLED
		}
		
		g_iLastBotSkill[id] = get_gametime()
		
		new skill_chance = random_num(0, 100)
		
		if ((is_user_bot(id) && skill_chance < 70) || !is_user_bot(id))
		{
			g_speed[id] = 1
			
			ArrayGetString(g_sound_raptor_sprint, random_num(0, ArraySize(g_sound_raptor_sprint) - 1), sound, charsmax(sound))
			emit_sound(id, CHAN_STREAM, sound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			
			set_task(g_SprintTimeRaptor, "normal", id)
			
			return HAM_HANDLED
		}
		
		return HAM_IGNORED
	}
	
	return HAM_IGNORED
}

public normal(id)
{
	g_speed[id] = 0
}

public client_prethink(id)
{
	if (!is_user_connected(id) || !is_user_alive(id) || zp_class_zombie_get_current(id) != g_ZombieRaptor || !zp_core_is_zombie(id) || zp_class_assassin_get(id) || zp_class_nemesis_get(id))
	{
		return HAM_IGNORED
	}
	
	if(g_speed[id] == 1)
	{
		cs_set_player_maxspeed_auto(id, g_SprintSpeedRaptor)
	}
	else if(g_speed[id] == 0)
	{
		cs_set_player_maxspeed_auto(id, g_DefaultSpeedRaptor)
	}
	
	return HAM_HANDLED
}

public roundStart()
{
	for (new i = 1; i <= g_maxplayers; i++)
	{
		g_speed[i] = 0
	}
}