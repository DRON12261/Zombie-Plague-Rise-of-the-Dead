/*================================================================================
	
	--------------------------
	-*- [ZP ROTD] Leap/Longjump -*-
	--------------------------
	
	This plugin is part of Zombie Plague Mod and is distributed under the
	terms of the GNU General Public License. Check ZP_ReadMe.txt for details.
	
================================================================================*/

#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <zp50_gamemodes>
#define LIBRARY_NEMESIS "zp50_class_nemesis"
#include <zp50_class_nemesis>
#define LIBRARY_ASSASSIN "zp50_class_assassin"
#include <zp50_class_assassin>
#define LIBRARY_SURVIVOR "zp50_class_survivor"
#include <zp50_class_survivor>
#define LIBRARY_SNIPER "zp50_class_sniper"
#include <zp50_class_sniper>

#define MAXPLAYERS 32

new g_GameModeInfectionID
new Float:g_LeapLastTime[MAXPLAYERS+1]

new cvar_leap_zombie, cvar_leap_zombie_force, cvar_leap_zombie_height, cvar_leap_zombie_cooldown
new cvar_leap_nemesis, cvar_leap_nemesis_force, cvar_leap_nemesis_height, cvar_leap_nemesis_cooldown
new cvar_leap_assassin, cvar_leap_assassin_force, cvar_leap_assassin_height, cvar_leap_assassin_cooldown
new cvar_leap_survivor, cvar_leap_survivor_force, cvar_leap_survivor_height, cvar_leap_survivor_cooldown
new cvar_leap_sniper, cvar_leap_sniper_force, cvar_leap_sniper_height, cvar_leap_sniper_cooldown

public plugin_init()
{
	register_plugin("[ZP ROTD] Leap/Longjump", ZP_VERSION_STRING, "ZP Dev Team + DRON12261")
	
	cvar_leap_zombie = register_cvar("zp_leap_zombie", "3") // 1-all // 2-first only // 3-last only
	cvar_leap_zombie_force = register_cvar("zp_leap_zombie_force", "500")
	cvar_leap_zombie_height = register_cvar("zp_leap_zombie_height", "300")
	cvar_leap_zombie_cooldown = register_cvar("zp_leap_zombie_cooldown", "10.0")
	
	// Nemesis Class loaded?
	if (LibraryExists(LIBRARY_NEMESIS, LibType_Library))
	{
		cvar_leap_nemesis = register_cvar("zp_leap_nemesis", "1")
		cvar_leap_nemesis_force = register_cvar("zp_leap_nemesis_force", "500")
		cvar_leap_nemesis_height = register_cvar("zp_leap_nemesis_height", "300")
		cvar_leap_nemesis_cooldown = register_cvar("zp_leap_nemesis_cooldown", "5.0")
	}

	// Assassin Class loaded?
	if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library))
	{
		cvar_leap_assassin = register_cvar("zp_leap_assassin", "1")
		cvar_leap_assassin_force = register_cvar("zp_leap_assassin_force", "500")
		cvar_leap_assassin_height = register_cvar("zp_leap_assassin_height", "300")
		cvar_leap_assassin_cooldown = register_cvar("zp_leap_assassin_cooldown", "5.0")
	}
	
	// Survivor Class loaded?
	if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library))
	{
		cvar_leap_survivor = register_cvar("zp_leap_survivor", "0")
		cvar_leap_survivor_force = register_cvar("zp_leap_survivor_force", "500")
		cvar_leap_survivor_height = register_cvar("zp_leap_survivor_height", "300")
		cvar_leap_survivor_cooldown = register_cvar("zp_leap_survivor_cooldown", "5.0")
	}

	// Sniper Class loaded?
	if (LibraryExists(LIBRARY_SNIPER, LibType_Library))
	{
		cvar_leap_sniper = register_cvar("zp_leap_sniper", "0")
		cvar_leap_sniper_force = register_cvar("zp_leap_sniper_force", "500")
		cvar_leap_sniper_height = register_cvar("zp_leap_sniper_height", "300")
		cvar_leap_sniper_cooldown = register_cvar("zp_leap_sniper_cooldown", "5.0")
	}
	
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
}

public plugin_natives()
{
	set_module_filter("module_filter")
	set_native_filter("native_filter")
}
public module_filter(const module[])
{
	if (equal(module, LIBRARY_NEMESIS) || equal(module, LIBRARY_ASSASSIN) || equal(module, LIBRARY_SURVIVOR) || equal(module, LIBRARY_SNIPER))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}
public native_filter(const name[], index, trap)
{
	if (!trap)
		return PLUGIN_HANDLED;
		
	return PLUGIN_CONTINUE;
}

public plugin_cfg()
{
	g_GameModeInfectionID = zp_gamemodes_get_id("Infection Mode")
}

// Forward Player PreThink
public fw_PlayerPreThink(id)
{
	// Not alive
	if (!is_user_alive(id))
		return;
	
	// Don't allow leap if player is frozen (e.g. freezetime)
	if (get_user_maxspeed(id) == 1.0)
		return;
	
	static Float:cooldown, force, Float:height
	
	// Nemesis Class loaded?
	if (LibraryExists(LIBRARY_NEMESIS, LibType_Library) && zp_class_nemesis_get(id))
	{
		// Check if nemesis should leap
		if (!get_pcvar_num(cvar_leap_nemesis)) return;
		cooldown = get_pcvar_float(cvar_leap_nemesis_cooldown)
		force = get_pcvar_num(cvar_leap_nemesis_force)
		height = get_pcvar_float(cvar_leap_nemesis_height)
	}
	// Assassin Class loaded?
	else if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library) && zp_class_assassin_get(id))
	{
		// Check if assassin should leap
		if (!get_pcvar_num(cvar_leap_assassin)) return;
		cooldown = get_pcvar_float(cvar_leap_assassin_cooldown)
		force = get_pcvar_num(cvar_leap_assassin_force)
		height = get_pcvar_float(cvar_leap_assassin_height)
	}
	// Survivor Class loaded?
	else if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && zp_class_survivor_get(id))
	{
		// Check if survivor should leap
		if (!get_pcvar_num(cvar_leap_survivor)) return;
		cooldown = get_pcvar_float(cvar_leap_survivor_cooldown)
		force = get_pcvar_num(cvar_leap_survivor_force)
		height = get_pcvar_float(cvar_leap_survivor_height)
	}
	// Sniper Class loaded?
	else if (LibraryExists(LIBRARY_SNIPER, LibType_Library) && zp_class_sniper_get(id))
	{
		// Check if sniper should leap
		if (!get_pcvar_num(cvar_leap_sniper)) return;
		cooldown = get_pcvar_float(cvar_leap_sniper_cooldown)
		force = get_pcvar_num(cvar_leap_sniper_force)
		height = get_pcvar_float(cvar_leap_sniper_height)
	}
	else
	{
		// Not a zombie
		if (!zp_core_is_zombie(id))
			return;
		
		// Check if zombie should leap
		switch (get_pcvar_num(cvar_leap_zombie))
		{
			// Disabled
			case 0: return;
			// First zombie (only on infection rounds)
			case 2: if (!zp_core_is_first_zombie(id) || (zp_gamemodes_get_current() != g_GameModeInfectionID)) return;
			// Last zombie
			case 3: if (!zp_core_is_last_zombie(id)) return;
		}
		cooldown = get_pcvar_float(cvar_leap_zombie_cooldown)
		force = get_pcvar_num(cvar_leap_zombie_force)
		height = get_pcvar_float(cvar_leap_zombie_height)
	}
	
	static Float:current_time
	current_time = get_gametime()
	
	// Cooldown not over yet
	if (current_time - g_LeapLastTime[id] < cooldown)
		return;
	
	// Not doing a longjump (don't perform check for bots, they leap automatically)
	if (!is_user_bot(id) && !(pev(id, pev_button) & (IN_JUMP | IN_DUCK) == (IN_JUMP | IN_DUCK)))
		return;
	
	// Not on ground or not enough speed
	if (!(pev(id, pev_flags) & FL_ONGROUND) || fm_get_speed(id) < 80)
		return;
	
	static Float:velocity[3]
	
	// Make velocity vector
	velocity_by_aim(id, force, velocity)
	
	// Set custom height
	velocity[2] = height
	
	// Apply the new velocity
	set_pev(id, pev_velocity, velocity)
	
	// Update last leap time
	g_LeapLastTime[id] = current_time
}

// Get entity's speed (from fakemeta_util)
stock fm_get_speed(entity)
{
	static Float:velocity[3]
	pev(entity, pev_velocity, velocity)
	
	return floatround(vector_length(velocity));
}
