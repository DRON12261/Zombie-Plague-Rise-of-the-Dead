/*================================================================================
	
	----------------------------------
	-*- [ZP ROTD] Infection Lighting -*-
	----------------------------------
	
	This plugin is part of Zombie Plague Mod and is distributed under the
	terms of the GNU General Public License. Check ZP_ReadMe.txt for details.
	
================================================================================*/

#include <amxmodx>
#include <fakemeta>

#include <zp50_core>

new cvar_lighting_ptr
new cvar_infection_lighting, cvar_infection_lighting_delay

new bool:g_can

public plugin_init() 
{
	register_plugin("[ZP ROTD] Infection Lighting", ZP_VERSION_STRING, "ZP Dev Team + DRON12261")
	
	cvar_lighting_ptr = get_cvar_pointer("zp_lighting")
	cvar_infection_lighting = register_cvar("zp_infection_lighting","1")
	cvar_infection_lighting_delay = register_cvar("zp_infection_lighting_delay","10.0")
	
	register_logevent("logEventRoundStart", 2, "1=Round_Start")
}

public logEventRoundStart() 
{
	g_can = true
}
	
public zp_fw_core_infect_pre(id)
{
	if(g_can && get_pcvar_num(cvar_infection_lighting))
	{
		thunder()
		
		g_can = false
		set_task(get_pcvar_float(cvar_infection_lighting_delay),"can")
	}
}

public can() 
{
	g_can = true
}

public thunder()
{
	engfunc(EngFunc_LightStyle, 0, "v")
	client_cmd(0,"speak ambience/thunder_clap.wav")
	set_task(1.0,"lightning")
}

public lightning()
{
	static light[2]
	get_pcvar_string(cvar_lighting_ptr, light, 1)
	engfunc(EngFunc_LightStyle, 0, light)
}
