#include <amxmodx>
#include <amxmisc>
#include <zombieplague>
#include <fakemeta>

#define PLUGIN "Adaptive Music for Zombie Plague 4.3"
#define VERSION "1.0"
#define AUTHOR "DRON12261"

#define TASK_ID = 155

//Track states
enum {
	NO_PLAY = 0,
	LIGHT,
	MEDIUM,
	HARD,
	END
}

//Round states
enum {
	ENDED = 0,
	STARTED
}

//Zombie Plague 4.3 gamemodes
enum
{
	MODE_NONE = 0,
	MODE_INFECTION,
	MODE_NEMESIS,
	MODE_SURVIVOR,
	MODE_SWARM,
	MODE_MULTI,
	MODE_PLAGUE
}

//Tracks (all in cstrike/sound/[name]/[number 01 - 04].mp3)
new const ZP_OST_FILE[] = "AdaptiveMusicZP43.ini"

new g_TrackCount = 8
new Array:g_TrackList

new g_CurrentTrack = 0

new g_CurrentState = NO_PLAY
new g_RoundState = ENDED
new g_CurrentMode = MODE_NONE

new Float:OSTHardPercent = 70.0
new Float:OSTMediumPercent = 25.0

new cvar_zp_adaptiveOST_enable, cvar_zp_adaptiveOST_showinfo

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	loadTrackList()

	register_dictionary("AdaptiveMusicZP43.txt")
	
	cvar_zp_adaptiveOST_enable = register_cvar("zp_adaptiveOST_enable", "1")
	cvar_zp_adaptiveOST_showinfo = register_cvar("zp_adaptiveOST_showinfo", "0")
}

public loadTrackList() {
	g_TrackList = ArrayCreate(64, 1)
	
	new path[64]
	get_configsdir(path, charsmax(path))
	formatex(path, charsmax(path), "%s/%s", path, ZP_OST_FILE)
	
	if (!file_exists(path))
	{
		new error[100]
		formatex(error, charsmax(error), "%L %s!", LANG_PLAYER, "ZP_CANNOT_LOAD_OST_FILE", path)
		set_fail_state(error)
		return;
	}
	
	new file = fopen(path, "rt")
	new linedata[1024], key[64], value[960], section
	
	while (file && !feof(file)) {
		fgets(file, linedata, charsmax(linedata))
		
		replace(linedata, charsmax(linedata), "^n", "")
		
		if (!linedata[0] || linedata[0] == ';') continue;
		
		if (linedata[0] == '[')
		{
			section++
			continue;
		}
		
		strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
		
		trim(key)
		trim(value)
		
		switch (section) {
			case 1:
				if (equal(key, "TRACKLIST"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)
						
						ArrayPushString(g_TrackList, key)
					}
				}
		}
	}
	if (file) fclose(file)
}

public plugin_precache() {
	new buffer[64], i
	
	for (i = 0; i < ArraySize(g_TrackList); i++) {
		ArrayGetString(g_TrackList, i, buffer, charsmax(buffer))
		formatex(buffer, charsmax(buffer), "sound/music/%s/01.mp3", buffer)
		engfunc(EngFunc_PrecacheGeneric, buffer)
		ArrayGetString(g_TrackList, i, buffer, charsmax(buffer))
		formatex(buffer, charsmax(buffer), "sound/music/%s/02.mp3", buffer)
		engfunc(EngFunc_PrecacheGeneric, buffer)
		ArrayGetString(g_TrackList, i, buffer, charsmax(buffer))
		formatex(buffer, charsmax(buffer), "sound/music/%s/03.mp3", buffer)
		engfunc(EngFunc_PrecacheGeneric, buffer)
		ArrayGetString(g_TrackList, i, buffer, charsmax(buffer))
		formatex(buffer, charsmax(buffer), "sound/music/%s/04.mp3", buffer)
		engfunc(EngFunc_PrecacheGeneric, buffer)
	}
}

public client_connect(id) {
	if (!is_user_bot(id))
	{
		g_CurrentTrack = random_num(0, g_TrackCount - 1)
		set_task(0.1, "playMusic", id, _, _, "b")
	}
}

public client_disconnect(id) {
	remove_task(id)
	
	engclient_cmd(id, "mp3 stop")
}

public zp_round_started(gamemode, id) {
	g_CurrentMode = gamemode
	g_RoundState = STARTED
	
	g_CurrentTrack = random_num(0, g_TrackCount - 1)
}

public zp_round_ended(winteam) {
	g_CurrentMode = MODE_NONE
	g_RoundState = END
}

public playMusic(id) {
	if (get_pcvar_num(cvar_zp_adaptiveOST_enable) == 1 && !is_user_connecting(id))
	{
		new newCurrentState = g_CurrentState
		
		new aliveZombiesCount = zp_get_zombie_count()
		new aliveHumansCount = zp_get_human_count()
		new alivePlayersCount = aliveZombiesCount + aliveHumansCount
		
		new Float:zombiesPercent
		if (alivePlayersCount != 0) {
			zombiesPercent = aliveZombiesCount * 100.0 / alivePlayersCount
		}
		else {
			zombiesPercent = 0.0
		}
		
		if (g_RoundState == 1) {
			if (g_CurrentMode == MODE_INFECTION || g_CurrentMode == MODE_MULTI) {
				if (zombiesPercent >= OSTHardPercent) {
					newCurrentState = HARD
				}
				else if (zombiesPercent >= OSTMediumPercent) {
					newCurrentState = MEDIUM
				}
				else {
					newCurrentState = LIGHT
				}
				if (aliveHumansCount == 1)
				{
					newCurrentState = HARD
				}
			}
			if (g_CurrentMode == MODE_NEMESIS || g_CurrentMode == MODE_SURVIVOR) {
				newCurrentState = HARD
			}
			if (g_CurrentMode == MODE_SWARM || g_CurrentMode == MODE_PLAGUE) {
				newCurrentState = MEDIUM
			}
		}
		else {
			newCurrentState = END
		}
		
		if (newCurrentState != g_CurrentState) {
			g_CurrentState = newCurrentState
			
			new buffer[64]
			ArrayGetString(g_TrackList, g_CurrentTrack, buffer, charsmax(buffer))
			
			if (g_CurrentState == NO_PLAY) {
				if (get_pcvar_num(cvar_zp_adaptiveOST_showinfo) == 1)
				{
					client_print(0, print_chat, "[Adaptive Music for Zp 4.3] %L %s.", id, "ZP_AOST_NO_PLAY", buffer)
				}
				client_cmd(0, "mp3 stop")
			}
			if (g_CurrentState == LIGHT) {
				if (get_pcvar_num(cvar_zp_adaptiveOST_showinfo) == 1)
				{
					client_print(0, print_chat, "[Adaptive Music for Zp 4.3] %L %s.", id, "ZP_AOST_LIGHT", buffer)
				}
				client_cmd(0, "mp3 loop sound/music/%s/01.mp3", buffer)
			}
			if (g_CurrentState == MEDIUM) {
				if (get_pcvar_num(cvar_zp_adaptiveOST_showinfo) == 1)
				{
					client_print(0, print_chat, "[Adaptive Music for Zp 4.3] %L %s.", id, "ZP_AOST_MEDIUM", buffer)
				}
				client_cmd(0, "mp3 loop sound/music/%s/02.mp3", buffer)
			}
			if (g_CurrentState == HARD) {
				if (get_pcvar_num(cvar_zp_adaptiveOST_showinfo) == 1)
				{
					client_print(0, print_chat, "[Adaptive Music for Zp 4.3] %L %s.", id, "ZP_AOST_HEAVY", buffer)
				}
				client_cmd(0, "mp3 loop sound/music/%s/03.mp3", buffer)
			}
			if (g_CurrentState == END) {
				if (get_pcvar_num(cvar_zp_adaptiveOST_showinfo) == 1)
				{
					client_print(0, print_chat, "[Adaptive Music for Zp 4.3] %L %s.", id, "ZP_AOST_END", buffer)
				}
				client_cmd(0, "mp3 play sound/music/%s/04.mp3", buffer)
			}
		}
	}
	else {
		g_CurrentState = NO_PLAY
		client_cmd(0, "mp3 stop")
	}
}
