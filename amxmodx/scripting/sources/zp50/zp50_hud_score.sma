/*================================================================================
	
	----------------------------
	-*- [ZP ROTD] HUD Score -*-
	----------------------------
	
	This plugin is part of Zombie Plague Mod and is distributed under the
	terms of the GNU General Public License. Check ZP_ReadMe.txt for details.
	
================================================================================*/

#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <cstrike>
#include <hamsandwich>

#include <zp50_core>
#include <zp50_gamemodes>

new const mode_name[][] =
{
	"[Режим: Приготовиться...]",
	"[Режим: Нулевой пациент]",
	"[Режим: Множественное заражение]",
	"[Режим: Бойня]",
	"[Режим: НЕМЕЗИС]",
	"[Режим: ЧИСТИЛЬЩИК]",
	"[Режим: Чума]",
	"[Режим: АРМАГЕДДОН]",
	"[Режим: АССАСИН]",
	"[Режим: СНАЙПЕР]"
}

new g_winhuman , g_winzombie , g_roundhud  , g_Mode
new cvar_zp_cs_restartround, cvar_zp_score_show, cvar_zp_score_red, cvar_zp_score_green, cvar_zp_score_blue;
new g_maxplayers

#define TASK_SHOWHUD_ID = 110

#define SCORE_SPECT_X -1.0
#define SCORE_SPECT_Y 0.2
#define SCORE_ALIVE_X -1.0
#define SCORE_ALIVE_Y 0.0

public plugin_init()
{
	register_plugin("[ZP ROTD] HUD Score", ZP_VERSION_STRING, "ZP Dev Team + DRON12261")
	
	register_event("HLTV", "event_roundstart", "a", "1=0", "2=0")
	
	cvar_zp_cs_restartround = get_cvar_pointer("sv_restartround")
	cvar_zp_score_show = register_cvar("zp_score_show", "1")
	cvar_zp_score_red = register_cvar("zp_score_red", "0")
	cvar_zp_score_green = register_cvar("zp_score_green", "255")
	cvar_zp_score_blue = register_cvar("zp_score_blue", "0")
	
	g_maxplayers = get_maxplayers()
	g_roundhud = 0
}

public client_putinserver(id)
{
	if (!is_user_bot(id))
	{
		set_task (2.0,"showhud",id,_,_,"b")
	}
}

public fw_ClientDisconnect(id)
{
	remove_task(id)
}

public event_roundstart()
{
	g_Mode = 0
	g_roundhud += 1 
	
	if (g_roundhud == 1)
	{
		g_winhuman = 0
	}
}

public showhud(id)
{
	if (get_pcvar_num(cvar_zp_score_show) == 1)
	{	
		if(!is_user_alive(id))  
		{
			set_dhudmessage(get_pcvar_num(cvar_zp_score_red), get_pcvar_num(cvar_zp_score_green), get_pcvar_num(cvar_zp_score_blue), SCORE_SPECT_X, SCORE_SPECT_Y, 0, 6.0, 2.1, 0.0, 0.0)
			show_dhudmessage(0, "Людей [%d | День: %d | %d] Зомби^n[%d] Победы [%d]^n%s", fn_get_humans(),g_roundhud,fn_get_zombies(),g_winhuman,g_winzombie,mode_name[g_Mode])
		}
		else
		{
			set_dhudmessage(get_pcvar_num(cvar_zp_score_red), get_pcvar_num(cvar_zp_score_green), get_pcvar_num(cvar_zp_score_blue), SCORE_ALIVE_X, SCORE_ALIVE_Y, 0, 6.0, 2.1, 0.0, 0.0)
			show_dhudmessage(0, "Людей [%d | День: %d | %d] Зомби^n[%d] Победы [%d]^n%s", fn_get_humans(),g_roundhud,fn_get_zombies(),g_winhuman,g_winzombie,mode_name[g_Mode])
		}
	}
}

public zp_fw_gamemodes_start(game_mode_id) 
{
	g_Mode = game_mode_id + 1
	
	if(!(0 <= game_mode_id < (sizeof(mode_name) - 2)))
		g_Mode = sizeof(mode_name) - 1
}

public zp_fw_gamemodes_end(game_mode_id)
{
	if(get_pcvar_num(cvar_zp_cs_restartround))
	{
		for(new id=1;id<=g_maxplayers;id++)
		{
			g_roundhud = 0
			g_winzombie = 0
			g_winhuman = 0
			return PLUGIN_CONTINUE
		}
	}
	
	if (!zp_core_get_zombie_count())
		g_winhuman += 1
	else if (!zp_core_get_human_count())
		g_winzombie += 1 
	
	return PLUGIN_CONTINUE	
}

fn_get_humans()
{
	static iAlive, id
	iAlive = 0
	
	for (id = 1; id <= 32; id++)
	{
		if (is_user_alive(id) && !zp_core_is_zombie(id))
			iAlive++
	}
	
	return iAlive;
}

fn_get_zombies()
{
	static iAlive, id
	iAlive = 0
	
	for (id = 1; id <= 32; id++)
	{
		if (is_user_alive(id) && zp_core_is_zombie(id))
			iAlive++
	}
	
	return iAlive;
}

stock PlayersCount(){
	static count,i;count=0
	for(i=0;i<g_maxplayers;i++)
	if(is_user_connected(i)||is_user_bot(i))count++
	return count
}
stock infect_randomplayer(){
	static count,i,index[33];count=0
	for(i=0;i<g_maxplayers;i++)
	if(is_user_connected(i)||is_user_bot(i))
	if(!zp_get_user_zombie(i))index[count]=i,count++
	zp_infect_user(index[random_num(0,count-1)])
}
