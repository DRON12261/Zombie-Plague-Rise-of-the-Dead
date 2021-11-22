/*================================================================================
	
	----------------------------------
	-*- [ZP ROTD] Bot Improvements -*-
	----------------------------------
	
	This plugin is part of Zombie Plague Mod and is distributed under the
	terms of the GNU General Public License. Check ZP_ReadMe.txt for details.
	
================================================================================*/

#include <amxmodx>
#include <fakemeta>

#include <zp50_core>
#include <zp50_gamemodes>

new bool:is_Playing = false

public plugin_init()
{
	register_plugin("[ZP ROTD] Bot Improvements", ZP_VERSION_STRING, "ZP Dev Team + DRON12261")
	
	register_forward(FM_CmdStart , "fm_CmdStart");
}

public fm_CmdStart(id,Handle)
{
	new Buttons
	Buttons = get_uc(Handle,UC_Buttons)
	
	if(is_user_bot(id) && !is_Playing)
	{
		Buttons &= ~IN_ATTACK
		set_uc(Handle , UC_Buttons , Buttons)
		
		return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
} 

public zp_fw_gamemodes_start(game_mode_id)
{
	is_Playing = true
}

public zp_fw_gamemodes_end(game_mode_id)
{
	is_Playing = false
}