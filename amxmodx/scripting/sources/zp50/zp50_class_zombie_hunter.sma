#include < amxmodx >

#include < zombieplague >
#include < hamsandwich >
#include <engine>
#include <xs>
#include < fakemeta >

#define PLUGIN  "[ZP] Class: Jumper"
#define VERSION "1.0"
#define AUTHOR  "Doomsday"

new Float:g_fDelay[33]
new g_ThermalOn[33]
new sprite_playerheat

new cvar_enable
new cvar_maxdistance
new cvar_updatedelay

new const zclass_name[] = { "Охотник" }
new const zclass_info[] = { "Бросается вперед" }
new const zclass_model[] = { "zp_hunter" }
new const zclass_clawmodel[] = { "zp_hunter_hands.mdl" }
const zclass_health = 400
const zclass_speed = 400
const Float:zclass_gravity = 1.0
const Float:zclass_knockback = 0.3

new const g_sound[] = { "zero_blood/jumper/jump.wav" }

new g_jumper

new bool:g_CanJumpAgain[33]

new Float:g_nextjump[33]

new g_able[33]

new bool: is_jumper[33] = false

enum cvar
{
	height,
	force,
	cool
}

static const PLUGIN_NAME[] 	= "Thermal Zombie"
static const PLUGIN_AUTHOR[] 	= "Cheap_Suit"
static const PLUGIN_VERSION[]	= "1.0"

new pcvar[cvar]


public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_forward(FM_CmdStart,"event_CmdStart")
	
	register_cvar(PLUGIN_NAME, PLUGIN_VERSION, FCVAR_SPONLY|FCVAR_SERVER)
	
	cvar_enable	 = register_cvar("amx_tig_enable", 	"1")
	cvar_maxdistance = register_cvar("amx_tig_distance", 	"2500")
	cvar_updatedelay = register_cvar("amx_tig_updatedelay", "0.1")
	
	register_event("NVGToggle", "Event_NVGToggle", "be")

	cvars()
}

public cvars()
{
	pcvar[height] = register_cvar("zp_jumper_jump_height", "500")
	pcvar[force]  = register_cvar("zp_jumper_jump_force", "600")
	pcvar[cool]   = register_cvar("zp_jumper_cooldown", "0.1")
}

public plugin_precache()
{
	g_jumper = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback)
	
	sprite_playerheat = precache_model("sprites/poison.spr")

	precache_sound(g_sound)
}

public plugin_natives() 
{ 
    	register_native("is_jumper", "check_jumper", 1) 
}  

public check_jumper(player) 
{ 
        return is_jumper[player]; 
}  

public client_putinserver(player)
{
	g_able[player] = false
		
	g_CanJumpAgain[player] = false
}

public client_disconnect(player)
{
	g_able[player] = false
		
	g_CanJumpAgain[player] = false
}

public zp_user_infected_post(player, infector)
{
        if (zp_get_user_zombie_class(player) == g_jumper)
	{
		g_able[player] = true
		
		g_CanJumpAgain[player] = true
		g_nextjump[player] = get_gametime()

		is_jumper[player] = true
	}    
	else
	{
		is_jumper[player] = false
	}
        
        return PLUGIN_CONTINUE
}

public event_CmdStart(player, uc_handle, seed)
{
	static buttons, flags
	static Float:velocity[3]
	static Float:oldvelocity[3]
	
	if (!is_user_alive(player)) return FMRES_IGNORED
	if (!g_able[player]) return FMRES_IGNORED
	if (g_nextjump[player] > get_gametime()) return FMRES_IGNORED

	if(zp_get_user_zombie_class(player) != g_jumper)
		return FMRES_IGNORED

	if(!zp_get_user_zombie(player) || zp_get_user_nemesis(player))
		return FMRES_IGNORED
	
	flags = pev(player, pev_flags)
	
	if (!(g_CanJumpAgain[player]))
	{
		if(!(flags & FL_DUCKING) && (flags & FL_ONGROUND))
			g_CanJumpAgain[player] = true
		
		return FMRES_IGNORED
	}
	
	buttons = get_uc(uc_handle, UC_Buttons)
	
	pev(player, pev_velocity, oldvelocity)
	
	if ((flags & FL_ONGROUND) && (buttons & IN_JUMP) && (buttons & IN_DUCK) && g_CanJumpAgain[player])
	{
		g_CanJumpAgain[player] = false
		g_nextjump[player] = get_gametime() + get_pcvar_float(pcvar[cool])
		
		
		velocity_by_aim(player, get_pcvar_num(pcvar[force]) , velocity)
		velocity[0] += oldvelocity[0]*0.4
		velocity[1] += oldvelocity[1]*0.4
		velocity[2] += oldvelocity[2]*0.4
		if(velocity[2] < 0.0) velocity[2] = 0.0
		velocity[2] += get_pcvar_float(pcvar[height])
		set_pev(player, pev_velocity, velocity) 	
		//blast(player)
		emit_sound(player, CHAN_BODY, g_sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	
	return FMRES_IGNORED
}

public Event_NVGToggle(id)
	g_ThermalOn[id] = read_data(1)

public client_PostThink(id)
{
	if(!is_user_alive(id) || !zp_get_user_zombie(id)) return PLUGIN_CONTINUE
	if(zp_get_user_zombie_class(id) != g_jumper) return PLUGIN_CONTINUE
		
	if((g_fDelay[id] + get_pcvar_float(cvar_updatedelay)) > get_gametime())
		return PLUGIN_CONTINUE
	
	g_fDelay[id] = get_gametime()
	
	new Float:fMyOrigin[3]
	entity_get_vector(id, EV_VEC_origin, fMyOrigin)
	
	static Players[32], iNum
	get_players(Players, iNum, "a")
	for(new i = 0; i < iNum; ++i) if(id != Players[i])
	{
		new target = Players[i]
		
		new Float:fTargetOrigin[3]
		entity_get_vector(target, EV_VEC_origin, fTargetOrigin)
		
		if((get_distance_f(fMyOrigin, fTargetOrigin) > get_pcvar_num(cvar_maxdistance)) 
		|| !is_in_viewcone(id, fTargetOrigin))
			continue

		new Float:fMiddle[3], Float:fHitPoint[3]
		xs_vec_sub(fTargetOrigin, fMyOrigin, fMiddle)
		trace_line(-1, fMyOrigin, fTargetOrigin, fHitPoint)
								
		new Float:fWallOffset[3], Float:fDistanceToWall
		fDistanceToWall = vector_distance(fMyOrigin, fHitPoint) - 10.0
		normalize(fMiddle, fWallOffset, fDistanceToWall)
		
		new Float:fSpriteOffset[3]
		xs_vec_add(fWallOffset, fMyOrigin, fSpriteOffset)
		new Float:fScale, Float:fDistanceToTarget = vector_distance(fMyOrigin, fTargetOrigin)
		if(fDistanceToWall > 100.0)
			fScale = 8.0 * (fDistanceToWall / fDistanceToTarget)
		else
			fScale = 2.0
	
		te_sprite(id, fSpriteOffset, sprite_playerheat, floatround(fScale), 125)
	}
	return PLUGIN_CONTINUE
}

stock blast(player)
{
	static origin[3]
	get_user_origin(player, origin)

	message_begin(MSG_PVS, SVC_TEMPENTITY, origin, player)
	write_byte(TE_DLIGHT)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_byte(100)
	write_byte(72)
	write_byte(118)
	write_byte(255)
	write_byte(50)
	write_byte(200)
	message_end()


	message_begin(MSG_PVS, SVC_TEMPENTITY, origin, player)
	write_byte(TE_DLIGHT)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_byte(50)
	write_byte(72)
	write_byte(118)
	write_byte(255)
	write_byte(20)
	write_byte(200)
	message_end()
}

stock te_sprite(id, Float:origin[3], sprite, scale, brightness)
{
	message_begin(MSG_ONE, SVC_TEMPENTITY, _, id)
	write_byte(TE_SPRITE)
	write_coord(floatround(origin[0]))
	write_coord(floatround(origin[1]))
	write_coord(floatround(origin[2]))
	write_short(sprite)
	write_byte(scale) 
	write_byte(brightness)
	message_end()
}

stock normalize(Float:fIn[3], Float:fOut[3], Float:fMul)
{
	new Float:fLen = xs_vec_len(fIn)
	xs_vec_copy(fIn, fOut)
	
	fOut[0] /= fLen, fOut[1] /= fLen, fOut[2] /= fLen
	fOut[0] *= fMul, fOut[1] *= fMul, fOut[2] *= fMul
}