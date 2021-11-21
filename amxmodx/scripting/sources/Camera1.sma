#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define VERSION "0.0.2"

#define MAX_PLAYERS    32

#define USE_TOGGLE 3

new g_iPlayerCamera[MAX_PLAYERS+1]

new g_iMaxPlayers

public plugin_init()
{
    register_plugin("Camera View AUTOMATIC", VERSION, "ConnorMcLeod")

    RegisterHam(Ham_Spawn, "player", "CBasePlayer_Spawn_Post", 1)
    register_forward(FM_SetView, "SetView")
    RegisterHam(Ham_Think, "trigger_camera", "Camera_Think")

    g_iMaxPlayers = get_maxplayers()
}

public CBasePlayer_Spawn_Post( id )
{
    if( !is_user_alive(id) )
    {
        return
    }

    new iEnt = g_iPlayerCamera[id]
    if( !pev_valid(iEnt) )
    {
        static iszTriggerCamera
        if( !iszTriggerCamera )
        {
            iszTriggerCamera = engfunc(EngFunc_AllocString, "trigger_camera")
        }
        iEnt = engfunc(EngFunc_CreateNamedEntity, iszTriggerCamera)
        set_kvd(0, KV_ClassName, "trigger_camera")
        set_kvd(0, KV_fHandled, 0)
        set_kvd(0, KV_KeyName, "wait")
        set_kvd(0, KV_Value, "999999")
        dllfunc(DLLFunc_KeyValue, iEnt, 0)

        set_pev(iEnt, pev_spawnflags, SF_CAMERA_PLAYER_TARGET|SF_CAMERA_PLAYER_POSITION)
        set_pev(iEnt, pev_flags, pev(iEnt, pev_flags) | FL_ALWAYSTHINK)

        dllfunc(DLLFunc_Spawn, iEnt)

        g_iPlayerCamera[id] = iEnt
 //   }

        new Float:flMaxSpeed, iFlags = pev(id, pev_flags)
        pev(id, pev_maxspeed, flMaxSpeed)

        ExecuteHam(Ham_Use, iEnt, id, id, USE_TOGGLE, 1.0)

        set_pev(id, pev_flags, iFlags)
        // depending on mod, you may have to send SetClientMaxspeed here.
        // engfunc(EngFunc_SetClientMaxspeed, id, flMaxSpeed)
        set_pev(id, pev_maxspeed, flMaxSpeed)
    }
}

public SetView(id, iEnt)
{
    if( is_user_alive(id) )
    {
        new iCamera = g_iPlayerCamera[id]
        if( iCamera && iEnt != iCamera )
        {
            new szClassName[16]
            pev(iEnt, pev_classname, szClassName, charsmax(szClassName))
            if( !equal(szClassName, "trigger_camera") ) // should let real cams enabled
            {
                engfunc(EngFunc_SetView, id, iCamera) // shouldn't be always needed
                return FMRES_SUPERCEDE
            }
        }
    }
    return FMRES_IGNORED
}

public client_disconnect(id)
{
    new iEnt = g_iPlayerCamera[id]
    if( pev_valid(iEnt) )
    {
        engfunc(EngFunc_RemoveEntity, iEnt)
    }
    g_iPlayerCamera[id] = 0
}

public client_putinserver(id)
{
    g_iPlayerCamera[id] = 0
}

get_cam_owner(iEnt)
{
    static id
    for(id = 1; id<=g_iMaxPlayers; id++)
    {
        if( g_iPlayerCamera[id] == iEnt )
        {
            return id
        }
    }
    return 0
}

public Camera_Think( iEnt )
{
    static id
    if( !(id = get_cam_owner( iEnt )) )
    {
        return
    }

    static Float:fVecPlayerOrigin[3], Float:fVecCameraOrigin[3], Float:fVecAngles[3], Float:fVecBack[3]

    pev(id, pev_origin, fVecPlayerOrigin)
    pev(id, pev_view_ofs, fVecAngles)
    fVecPlayerOrigin[2] += fVecAngles[2]

    pev(id, pev_v_angle, fVecAngles)

    // See player from front ?
    //fVecAngles[0] = 15.0
    //fVecAngles[1] += fVecAngles[1] > 180.0 ? -180.0 : 180.0

    angle_vector(fVecAngles, ANGLEVECTOR_FORWARD, fVecBack)

    //Move back to see ourself (150 units)
    fVecCameraOrigin[0] = fVecPlayerOrigin[0] + (-fVecBack[0] * 150.0)
    fVecCameraOrigin[1] = fVecPlayerOrigin[1] + (-fVecBack[1] * 150.0)
    fVecCameraOrigin[2] = fVecPlayerOrigin[2] + (-fVecBack[2] * 150.0)

    engfunc(EngFunc_TraceLine, fVecPlayerOrigin, fVecCameraOrigin, IGNORE_MONSTERS, id, 0)
    static Float:flFraction
    get_tr2(0, TR_flFraction, flFraction)
    if( flFraction != 1.0 ) // adjust camera place if close to a wall
    {
        flFraction *= 150.0
        fVecCameraOrigin[0] = fVecPlayerOrigin[0] + (-fVecBack[0] * flFraction)
        fVecCameraOrigin[1] = fVecPlayerOrigin[1] + (-fVecBack[1] * flFraction)
        fVecCameraOrigin[2] = fVecPlayerOrigin[2] + (-fVecBack[2] * flFraction)
    }

    set_pev(iEnt, pev_origin, fVecCameraOrigin)
    set_pev(iEnt, pev_angles, fVecAngles)
} 
