/*================================================================================
	
	----------------------------
	-*- [ZP ROTD] Class: sniper -*-
	----------------------------
	
	This plugin is part of Zombie Plague Mod and is distributed under the
	terms of the GNU General Public License. Check ZP_ReadMe.txt for details.
	
================================================================================*/

#include <amxmodx>
#include <fun>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <amx_settings_api>
#include <cs_maxspeed_api>
#include <cs_player_models_api>
#include <cs_weap_models_api>
#include <cs_ham_bots_api>
#include <zp50_core>
#include <zp50_items>

// Settings file
new const ZP_SETTINGS_FILE[] = "zombieplague.ini"

// Default models
new const models_sniper_player[][] = { "leet", "sas" }

new Array:g_models_sniper_player

#define PLAYERMODEL_MAX_LENGTH 32
#define MODEL_MAX_LENGTH 64

new g_models_sniper_weapon[MODEL_MAX_LENGTH] = "models/v_awp.mdl"

#define TASK_AURA 100
#define ID_AURA (taskid - TASK_AURA)

#define flag_get(%1,%2) (%1 & (1 << (%2 & 31)))
#define flag_get_boolean(%1,%2) (flag_get(%1,%2) ? true : false)
#define flag_set(%1,%2) %1 |= (1 << (%2 & 31))
#define flag_unset(%1,%2) %1 &= ~(1 << (%2 & 31))

// CS Player CBase Offsets (win32)
const PDATA_SAFE = 2
const OFFSET_ACTIVE_ITEM = 373

// Weapon bitsums
const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)
const GRENADES_WEAPONS_BIT_SUM = (1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)

// Ammo Type Names for weapons
new const AMMOTYPE[][] = { "", "357sig", "", "762nato", "", "buckshot", "", "45acp", "556nato", "", "9mm", "57mm", "45acp",
			"556nato", "556nato", "556nato", "45acp", "9mm", "338magnum", "9mm", "556natobox", "buckshot",
			"556nato", "9mm", "762nato", "", "50ae", "556nato", "762nato", "", "57mm" }

// Max BP ammo for weapons
new const MAXBPAMMO[] = { -1, 52, -1, 90, 1, 32, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120,
			30, 120, 200, 32, 90, 120, 90, 2, 35, 90, 90, -1, 100 }

#define PRIMARY_ONLY 1
#define SECONDARY_ONLY 2
#define GRENADES_ONLY 4

new g_MaxPlayers
new g_IsSniper

new cvar_sniper_health, cvar_sniper_base_health, cvar_sniper_speed, cvar_sniper_gravity
new cvar_sniper_glow
new cvar_sniper_aura, cvar_sniper_aura_color_R, cvar_sniper_aura_color_G, cvar_sniper_aura_color_B
new cvar_sniper_weapon, cvar_sniper_weapon_block

public plugin_init()
{
	register_plugin("[ZP ROTD] Class: Sniper", ZP_VERSION_STRING, "ZP Dev Team + DRON12261")
	
	register_clcmd("drop", "clcmd_drop")
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	RegisterHamBots(Ham_TakeDamage, "fw_TakeDamage")
	RegisterHam(Ham_Touch, "weaponbox", "fw_TouchWeapon")
	RegisterHam(Ham_Touch, "armoury_entity", "fw_TouchWeapon")
	RegisterHam(Ham_Touch, "weapon_shield", "fw_TouchWeapon")
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	RegisterHamBots(Ham_Killed, "fw_PlayerKilled")
	register_forward(FM_ClientDisconnect, "fw_ClientDisconnect_Post", 1)
	
	g_MaxPlayers = get_maxplayers()
	
	cvar_sniper_health = register_cvar("zp_sniper_health", "0")
	cvar_sniper_base_health = register_cvar("zp_sniper_base_health", "100")
	cvar_sniper_speed = register_cvar("zp_sniper_speed", "0.95")
	cvar_sniper_gravity = register_cvar("zp_sniper_gravity", "0.75")
	cvar_sniper_glow = register_cvar("zp_sniper_glow", "1")
	cvar_sniper_aura = register_cvar("zp_sniper_aura", "1")
	cvar_sniper_aura_color_R = register_cvar("zp_sniper_aura_color_R", "200")
	cvar_sniper_aura_color_G = register_cvar("zp_sniper_aura_color_G", "200")
	cvar_sniper_aura_color_B = register_cvar("zp_sniper_aura_color_B", "0")
	cvar_sniper_weapon = register_cvar("zp_sniper_weapon", "weapon_awp")
	cvar_sniper_weapon_block = register_cvar("zp_sniper_weapon_block", "1")
}

public plugin_precache()
{
	// Initialize arrays
	g_models_sniper_player = ArrayCreate(PLAYERMODEL_MAX_LENGTH, 1)
	
	// Load from external file
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Player Models", "SNIPER", g_models_sniper_player)
	
	// If we couldn't load from file, use and save default ones
	new index
	if (ArraySize(g_models_sniper_player) == 0)
	{
		for (index = 0; index < sizeof models_sniper_player; index++)
			ArrayPushString(g_models_sniper_player, models_sniper_player[index])
		
		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Player Models", "SNIPER", g_models_sniper_player)
	}
	
	// Load from external file, save if not found
	if (!amx_load_setting_string(ZP_SETTINGS_FILE, "Weapon Models", "V_WEAPON SNIPER", g_models_sniper_weapon, charsmax(g_models_sniper_weapon)))
		amx_save_setting_string(ZP_SETTINGS_FILE, "Weapon Models", "V_WEAPON SNIPER", g_models_sniper_weapon)
	
	
	// Precache models
	new player_model[PLAYERMODEL_MAX_LENGTH], model_path[128]
	for (index = 0; index < ArraySize(g_models_sniper_player); index++)
	{
		ArrayGetString(g_models_sniper_player, index, player_model, charsmax(player_model))
		formatex(model_path, charsmax(model_path), "models/player/%s/%s.mdl", player_model, player_model)
		precache_model(model_path)
		// Support modelT.mdl files
		formatex(model_path, charsmax(model_path), "models/player/%s/%sT.mdl", player_model, player_model)
		if (file_exists(model_path)) precache_model(model_path)
	}
	
	precache_model(g_models_sniper_weapon)
}

public plugin_natives()
{
	register_library("zp50_class_sniper")
	register_native("zp_class_sniper_get", "native_class_sniper_get")
	register_native("zp_class_sniper_set", "native_class_sniper_set")
	register_native("zp_class_sniper_get_count", "native_class_sniper_get_count")
}

public client_disconnected(id)
{
	if (flag_get(g_IsSniper, id))
	{
		// Remove sniper glow
		if (get_pcvar_num(cvar_sniper_glow))
			set_user_rendering(id)
		
		// Remove sniper aura
		if (get_pcvar_num(cvar_sniper_aura))
			remove_task(id+TASK_AURA)
	}
}

public fw_ClientDisconnect_Post(id)
{
	// Reset flags AFTER disconnect (to allow checking if the player was sniper before disconnecting)
	flag_unset(g_IsSniper, id)
}

public clcmd_drop(id)
{
	// Should sniper stick to his weapon?
	if (flag_get(g_IsSniper, id) && get_pcvar_num(cvar_sniper_weapon_block))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Ham Weapon Touch Forward
public fw_TouchWeapon(weapon, id)
{
	// Should sniper stick to his weapon?
	if (get_pcvar_num(cvar_sniper_weapon_block) && is_user_alive(id) && flag_get(g_IsSniper, id))
		return HAM_SUPERCEDE;
	
	return HAM_IGNORED;
}

// Ham Player Killed Forward
public fw_PlayerKilled(victim, attacker, shouldgib)
{
	if (flag_get(g_IsSniper, victim))
	{
		// Remove sniper aura
		if (get_pcvar_num(cvar_sniper_aura))
			remove_task(victim+TASK_AURA)
	}

	// When killed by a Sniper victim explodes
	if (flag_get(g_IsSniper, attacker))
	{
		new origin[3]
		get_user_origin(victim, origin)
		
		message_begin(MSG_PVS, SVC_TEMPENTITY, origin, 0)
		write_byte(TE_LAVASPLASH)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2] - 26)
	
		message_end()
	}
}

public zp_fw_core_spawn_post(id)
{
	if (flag_get(g_IsSniper, id))
	{
		// Remove sniper glow
		if (get_pcvar_num(cvar_sniper_glow))
			set_user_rendering(id)
		
		// Remove sniper aura
		if (get_pcvar_num(cvar_sniper_aura))
			remove_task(id+TASK_AURA)
		
		// Remove sniper weapon model
		new weapon_name[32]
		get_pcvar_string(cvar_sniper_weapon, weapon_name, charsmax(weapon_name))
		new weapon_id = get_weaponid(weapon_name)
		cs_reset_player_view_model(id, weapon_id)
		
		// Remove sniper flag
		flag_unset(g_IsSniper, id)
	}
}

public zp_fw_core_infect(id, attacker)
{
	if (flag_get(g_IsSniper, id))
	{
		// Remove sniper glow
		if (get_pcvar_num(cvar_sniper_glow))
			set_user_rendering(id)
		
		// Remove sniper aura
		if (get_pcvar_num(cvar_sniper_aura))
			remove_task(id+TASK_AURA)
		
		// Remove sniper weapon model
		new weapon_name[32]
		get_pcvar_string(cvar_sniper_weapon, weapon_name, charsmax(weapon_name))
		new weapon_id = get_weaponid(weapon_name)
		cs_reset_player_view_model(id, weapon_id)
		
		// Remove sniper flag
		flag_unset(g_IsSniper, id)
	}
}

// Ham Take Damage Forward
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	// Non-player damage or self damage
	if (victim == attacker || !is_user_alive(attacker))
		return HAM_IGNORED;
	
	// Assassin attacking human
	if (flag_get(g_IsSniper, attacker) && zp_core_is_zombie(victim))
	{
		// Ignore assassin damage override if damage comes from a 3rd party entity
		// (to prevent this from affecting a sub-plugin's rockets e.g.)
		if (inflictor == attacker)
		{
			new plrWeapId, plrClip, plrAmmo    
			plrWeapId = get_user_weapon(attacker, plrClip, plrAmmo)
			
			if (plrWeapId == CSW_AWP) {
				//new att[64], vic[64]
				//get_user_name(attacker, att, 64)
				//get_user_name(victim, vic, 64)
				//client_print(0, print_chat, "[%s] DAMAGE [%s] as Sniper!", att, vic)
				SetHamParamFloat(4, 500.0)
				//ExecuteHamB(Ham_Killed, victim, attacker, 0)
			}
			
			return HAM_HANDLED;
		}
	}
	
	return HAM_IGNORED;
}

public zp_fw_core_cure_post(id, attacker)
{
	// Apply sniper attributes?
	if (!flag_get(g_IsSniper, id))
		return;
	
	// Health
	if (get_pcvar_num(cvar_sniper_health) == 0)
		set_user_health(id, get_pcvar_num(cvar_sniper_base_health) * GetAliveCount())
	else
		set_user_health(id, get_pcvar_num(cvar_sniper_health))
	
	// Gravity
	set_user_gravity(id, get_pcvar_float(cvar_sniper_gravity))
	
	// Speed (if value between 0 and 10, consider it a multiplier)
	cs_set_player_maxspeed_auto(id, get_pcvar_float(cvar_sniper_speed))

	// Apply sniper player model
	new player_model[PLAYERMODEL_MAX_LENGTH]
	ArrayGetString(g_models_sniper_player, random_num(0, ArraySize(g_models_sniper_player) - 1), player_model, charsmax(player_model))
	cs_set_player_model(id, player_model)

	// Apply sniper weapon model
	new weapon_name[32]
	get_pcvar_string(cvar_sniper_weapon, weapon_name, charsmax(weapon_name))
	new weapon_id = get_weaponid(weapon_name)
	cs_set_player_view_model(id, weapon_id, g_models_sniper_weapon)
	
	// sniper glow
	if (get_pcvar_num(cvar_sniper_glow))
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 25)
	
	// sniper aura task
	if (get_pcvar_num(cvar_sniper_aura))
		set_task(0.1, "sniper_aura", id+TASK_AURA, _, _, "b")
	
	// Strip current weapons and give sniper weapon
	strip_weapons(id, PRIMARY_ONLY)
	strip_weapons(id, SECONDARY_ONLY)
	strip_weapons(id, GRENADES_ONLY)
	give_item(id, weapon_name)
	ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[weapon_id], AMMOTYPE[weapon_id], MAXBPAMMO[weapon_id])
}

public native_class_sniper_get(plugin_id, num_params)
{
	new id = get_param(1)
	
	if (!is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP ROTD] Invalid Player (%d)", id)
		return -1;
	}
	
	return flag_get_boolean(g_IsSniper, id);
}

public native_class_sniper_set(plugin_id, num_params)
{
	new id = get_param(1)
	
	if (!is_user_alive(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP ROTD] Invalid Player (%d)", id)
		return false;
	}
	
	if (flag_get(g_IsSniper, id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP ROTD] Player already a sniper (%d)", id)
		return false;
	}
	
	flag_set(g_IsSniper, id)
	zp_core_force_cure(id)
	return true;
}

public native_class_sniper_get_count(plugin_id, num_params)
{
	return GetsniperCount();
}

// sniper aura task
public sniper_aura(taskid)
{
	// Get player's origin
	static origin[3]
	get_user_origin(ID_AURA, origin)
	
	// Colored Aura
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_DLIGHT) // TE id
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	write_byte(20) // radius
	write_byte(get_pcvar_num(cvar_sniper_aura_color_R)) // r
	write_byte(get_pcvar_num(cvar_sniper_aura_color_G)) // g
	write_byte(get_pcvar_num(cvar_sniper_aura_color_B)) // b
	write_byte(2) // life
	write_byte(0) // decay rate
	message_end()
}

// Get Alive Count -returns alive players number-
GetAliveCount()
{
	new iAlive, id
	
	for (id = 1; id <= g_MaxPlayers; id++)
	{
		if (is_user_alive(id))
			iAlive++
	}
	
	return iAlive;
}

// Get sniper Count -returns alive sniper number-
GetsniperCount()
{
	new isnipers, id
	
	for (id = 1; id <= g_MaxPlayers; id++)
	{
		if (is_user_alive(id) && flag_get(g_IsSniper, id))
			isnipers++
	}
	
	return isnipers;
}

// Strip primary/secondary/grenades
stock strip_weapons(id, stripwhat)
{
	// Get user weapons
	new weapons[32], num_weapons, index, weaponid
	get_user_weapons(id, weapons, num_weapons)
	
	// Loop through them and drop primaries or secondaries
	for (index = 0; index < num_weapons; index++)
	{
		// Prevent re-indexing the array
		weaponid = weapons[index]
		
		if ((stripwhat == PRIMARY_ONLY && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM))
		|| (stripwhat == SECONDARY_ONLY && ((1<<weaponid) & SECONDARY_WEAPONS_BIT_SUM))
		|| (stripwhat == GRENADES_ONLY && ((1<<weaponid) & GRENADES_WEAPONS_BIT_SUM)))
		{
			// Get weapon name
			new wname[32]
			get_weaponname(weaponid, wname, charsmax(wname))
			
			// Strip weapon and remove bpammo
			ham_strip_weapon(id, wname)
			cs_set_user_bpammo(id, weaponid, 0)
		}
	}
}

stock ham_strip_weapon(index, const weapon[])
{
	// Get weapon id
	new weaponid = get_weaponid(weapon)
	if (!weaponid)
		return false;
	
	// Get weapon entity
	new weapon_ent = fm_find_ent_by_owner(-1, weapon, index)
	if (!weapon_ent)
		return false;
	
	// If it's the current weapon, retire first
	new current_weapon_ent = fm_cs_get_current_weapon_ent(index)
	new current_weapon = pev_valid(current_weapon_ent) ? cs_get_weapon_id(current_weapon_ent) : -1
	if (current_weapon == weaponid)
		ExecuteHamB(Ham_Weapon_RetireWeapon, weapon_ent)
	
	// Remove weapon from player
	if (!ExecuteHamB(Ham_RemovePlayerItem, index, weapon_ent))
		return false;
	
	// Kill weapon entity and fix pev_weapons bitsum
	ExecuteHamB(Ham_Item_Kill, weapon_ent)
	set_pev(index, pev_weapons, pev(index, pev_weapons) & ~(1<<weaponid))
	return true;
}

// Find entity by its owner (from fakemeta_util)
stock fm_find_ent_by_owner(entity, const classname[], owner)
{
	while ((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", classname)) && pev(entity, pev_owner) != owner) { /* keep looping */ }
	return entity;
}

// Get User Current Weapon Entity
stock fm_cs_get_current_weapon_ent(id)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return -1;
	
	return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM);
}
