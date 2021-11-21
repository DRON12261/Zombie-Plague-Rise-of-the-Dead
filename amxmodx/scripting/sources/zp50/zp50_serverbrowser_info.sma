/*================================================================================
	
	--------------------------------
	-*- [ZP ROTD] Server Broswer Info -*-
	--------------------------------
	
	This plugin is part of Zombie Plague Mod and is distributed under the
	terms of the GNU General Public License. Check ZP_ReadMe.txt for details.
	
================================================================================*/

#include <amxmodx>
#include <fakemeta>
#include <zp50_core>

new g_ModName[64]

public plugin_init()
{
	register_plugin("[ZP ROTD] Server Browser Info", ZP_VERSION_STRING, "ZP Dev Team + DRON12261")
	
	register_forward(FM_GetGameDescription, "fw_GetGameDescription")
	formatex(g_ModName, charsmax(g_ModName), "Zombie Plague: Rise of the Dead %s", ZP_VERSION_STR_LONG)
}

// Forward Get Game Description
public fw_GetGameDescription()
{
	// Return the mod name so it can be easily identified
	forward_return(FMV_STRING, g_ModName)
	
	return FMRES_SUPERCEDE;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
