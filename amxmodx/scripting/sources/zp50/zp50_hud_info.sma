/*================================================================================
	
	----------------------------
	-*- [ZP ROTD] HUD Information -*-
	----------------------------
	
	This plugin is part of Zombie Plague Mod and is distributed under the
	terms of the GNU General Public License. Check ZP_ReadMe.txt for details.
	
================================================================================*/

#include <amxmodx>
#include <fun>
#include <cstrike>
#include <fakemeta>
#include <reapi>
#include <zp50_class_human>
#include <zp50_class_zombie>
#define LIBRARY_NEMESIS "zp50_class_nemesis"
#include <zp50_class_nemesis>
#define LIBRARY_ASSASSIN "zp50_class_assassin"
#include <zp50_class_assassin>
#define LIBRARY_SURVIVOR "zp50_class_survivor"
#include <zp50_class_survivor>
#define LIBRARY_SNIPER "zp50_class_sniper"
#include <zp50_class_sniper>
#define LIBRARY_AMMOPACKS "zp50_ammopacks"
#include <zp50_ammopacks>

const Float:HUD_SPECT_X = -1.0
const Float:HUD_SPECT_Y = 0.15
const Float:HUD_STATS_X = 0.02
const Float:HUD_STATS_Y = 0.95

const HUD_STATS_ZOMBIE_R = 255
const HUD_STATS_ZOMBIE_G = 255
const HUD_STATS_ZOMBIE_B = 0

const HUD_STATS_HUMAN_R = 0
const HUD_STATS_HUMAN_G = 255
const HUD_STATS_HUMAN_B = 255

const HUD_STATS_SPEC_R = 0
const HUD_STATS_SPEC_G = 255
const HUD_STATS_SPEC_B = 0

#define TASK_SHOWHUD 100
#define ID_SHOWHUD (taskid - TASK_SHOWHUD)

const PEV_SPEC_TARGET = pev_iuser2

public plugin_init()
{
	register_plugin("[ZP ROTD] HUD Information", ZP_VERSION_STRING, "ZP Dev Team + DRON12261")
}

public plugin_natives()
{
	set_module_filter("module_filter")
	set_native_filter("native_filter")
}
public module_filter(const module[])
{
	if (equal(module, LIBRARY_NEMESIS) || equal(module, LIBRARY_ASSASSIN) || equal(module, LIBRARY_SURVIVOR) || equal(module, LIBRARY_SNIPER) || equal(module, LIBRARY_AMMOPACKS))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}
public native_filter(const name[], index, trap)
{
	if (!trap)
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

public client_putinserver(id)
{
	if (!is_user_bot(id))
	{
		// Set the custom HUD display task
		set_task(1.0, "ShowHUD", id+TASK_SHOWHUD, _, _, "b")
	}
}

public client_disconnected(id)
{
	remove_task(id+TASK_SHOWHUD)
}

// Show HUD Task
public ShowHUD(taskid)
{
	
	new player = ID_SHOWHUD
	
	set_member(player, m_iHideHUD, get_member(player, m_iHideHUD) | HIDEHUD_TIMER | HIDEHUD_HEALTH);
	
	// Player dead?
	if (!is_user_alive(player))
	{
		// Get spectating target
		player = pev(player, PEV_SPEC_TARGET)
		
		// Target not alive
		if (!is_user_alive(player))
			return;
	}
	
	// Format classname
	static class_name[32], transkey[64]
	new red, green, blue
	
	if (zp_core_is_zombie(player)) // zombies
	{
		red = HUD_STATS_ZOMBIE_R
		green = HUD_STATS_ZOMBIE_G
		blue = HUD_STATS_ZOMBIE_B
		
		// Nemesis Class loaded?
		if (LibraryExists(LIBRARY_NEMESIS, LibType_Library) && zp_class_nemesis_get(player))
			formatex(class_name, charsmax(class_name), "%L", ID_SHOWHUD, "CLASS_NEMESIS")
			
		// Assassin Class loaded?
		else if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library) && zp_class_assassin_get(player))
			formatex(class_name, charsmax(class_name), "%L", ID_SHOWHUD, "CLASS_ASSASSIN")
		else
		{
			zp_class_zombie_get_name(zp_class_zombie_get_current(player), class_name, charsmax(class_name))
			
			// ML support for class name
			formatex(transkey, charsmax(transkey), "ZOMBIENAME %s", class_name)
			if (GetLangTransKey(transkey) != TransKey_Bad) formatex(class_name, charsmax(class_name), "%L", ID_SHOWHUD, transkey)
		}
	}
	else // humans
	{
		red = HUD_STATS_HUMAN_R
		green = HUD_STATS_HUMAN_G
		blue = HUD_STATS_HUMAN_B
		
		// Survivor Class loaded?
		if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && zp_class_survivor_get(player))
			formatex(class_name, charsmax(class_name), "%L", ID_SHOWHUD, "CLASS_SURVIVOR")

		// Sniper Class loaded?
		else if (LibraryExists(LIBRARY_SNIPER, LibType_Library) && zp_class_sniper_get(player))
			formatex(class_name, charsmax(class_name), "%L", ID_SHOWHUD, "CLASS_SNIPER")
		else
		{
			zp_class_human_get_name(zp_class_human_get_current(player), class_name, charsmax(class_name))
			
			// ML support for class name
			formatex(transkey, charsmax(transkey), "HUMANNAME %s", class_name)
			if (GetLangTransKey(transkey) != TransKey_Bad) formatex(class_name, charsmax(class_name), "%L", ID_SHOWHUD, transkey)
		}
	}
	
	// Spectating someone else?
	if (player != ID_SHOWHUD)
	{
		new player_name[32]
		get_user_name(player, player_name, charsmax(player_name))
		
		// Show name, health, class, and money
		set_dhudmessage(HUD_STATS_SPEC_R, HUD_STATS_SPEC_G, HUD_STATS_SPEC_B, HUD_SPECT_X, HUD_SPECT_Y, 0, 6.0, 1.1, 0.0, 0.0)
		
		if (LibraryExists(LIBRARY_AMMOPACKS, LibType_Library))
			show_dhudmessage(ID_SHOWHUD, "[%L - %d]   [%L - %d]   [%L - %s]   [%L - %d]", ID_SHOWHUD, "ZOMBIE_ATTRIB1", get_user_health(player), ID_SHOWHUD, "ATTRIB_ARMOR", get_user_armor(player), ID_SHOWHUD, "CLASS_CLASS", class_name, ID_SHOWHUD, "AMMO_PACKS1", zp_ammopacks_get(player))
		else
			show_dhudmessage(ID_SHOWHUD, "[%L - %d]   [%L - %d]   [%L - %s]   [%L - $%d]", ID_SHOWHUD, "ZOMBIE_ATTRIB1", get_user_health(player), ID_SHOWHUD, "ATTRIB_ARMOR", get_user_armor(player), ID_SHOWHUD, "CLASS_CLASS", class_name, ID_SHOWHUD, "MONEY1", cs_get_user_money(player))
	}
	else
	{
		// Show health, class
		set_dhudmessage(red, green, blue, HUD_STATS_X, HUD_STATS_Y, 0, 6.0, 1.1, 0.0, 0.0)
		
		if (LibraryExists(LIBRARY_AMMOPACKS, LibType_Library))
			show_dhudmessage(ID_SHOWHUD, "[%L - %d]   [%L - %d]   [%L - %s]   [%L - %d]", ID_SHOWHUD, "ZOMBIE_ATTRIB1", get_user_health(ID_SHOWHUD), ID_SHOWHUD, "ATTRIB_ARMOR", get_user_armor(ID_SHOWHUD), ID_SHOWHUD, "CLASS_CLASS", class_name, ID_SHOWHUD, "AMMO_PACKS1", zp_ammopacks_get(ID_SHOWHUD))
		else
			show_dhudmessage(ID_SHOWHUD, "[%L - %d]   [%L - %d]   [%L - %s]   [%L - $%d]", ID_SHOWHUD, "ZOMBIE_ATTRIB1", get_user_health(ID_SHOWHUD), ID_SHOWHUD, "ATTRIB_ARMOR", get_user_armor(ID_SHOWHUD), ID_SHOWHUD, "CLASS_CLASS", class_name, ID_SHOWHUD, "MONEY1", cs_get_user_money(player))
	}
}
