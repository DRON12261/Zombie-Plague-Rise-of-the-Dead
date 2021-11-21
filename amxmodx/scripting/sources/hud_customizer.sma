/*#include <amxmodx>

new g_msgHideWeapon;

public plugin_init() {
    register_event("ResetHUD", "eResetHUD", "be");

    g_msgHideWeapon = get_user_msgid("HideWeapon");
}

public eResetHUD(id) {
    if(!is_user_bot(id)) {
        message_begin(MSG_ONE_UNRELIABLE, g_msgHideWeapon, _, id);
        write_byte((1 << 3 | 1 << 4));
        message_end();
    }
}*/

/*#include <amxmodx>
#include <amxmisc>
#include <reapi>

const HIDEHUD_BITS = (1<<1);

public plugin_init()
{
	register_plugin("HideHUD Test", "1.0", "Crazy");

	register_message(get_user_msgid("ResetHUD"), "messageResetHUD");
}

public messageResetHUD(iMsdId, iMsgDest, pevEntity)
{
	if (!is_user_connected(pevEntity))
		return PLUGIN_CONTINUE;
	
	new iHideFlags = GetHudHideFlags()
	if(iHideFlags)
	{
		message_begin(MSG_ONE, g_msgHideWeapon, _, id)
		write_byte(iHideFlags)
		message_end()
	}
	applyCVars()
	
	//set_member(pevEntity, m_iHideHUD, HIDEHUD_BITS);
	//set_member(pevEntity, m_iClientHideHUD, HIDEHUD_BITS);
	return PLUGIN_CONTINUE;
}*/


#include <amxmodx>
#include <reapi>
public plugin_init() RegisterHookChain(RG_CBasePlayer_Spawn, "CBasePlayer_Spawn_Post", true);
public CBasePlayer_Spawn_Post(const id) set_member(id, m_iHideHUD, get_member(id, m_iHideHUD) | HIDEHUD_TIMER | HIDEHUD_HEALTH);
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
