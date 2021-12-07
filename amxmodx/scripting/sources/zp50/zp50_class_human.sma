/*================================================================================
	
	-------------------------
	-*- [ZP ROTD] Class: Human -*-
	-------------------------
	
	This plugin is part of Zombie Plague Mod and is distributed under the
	terms of the GNU General Public License. Check ZP_ReadMe.txt for details.
	
================================================================================*/

#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <cstrike>
#include <hamsandwich>
#include <amx_settings_api>
#include <cs_player_models_api>
#include <cs_weap_models_api>
#include <cs_maxspeed_api>
#include <cs_weap_restrict_api>
#include <zp50_core>
#include <zp50_colorchat>
#include <zp50_class_human>
#include <zp50_class_human_const>
#include <zp50_class_sniper>
#include <zp50_class_survivor>

#define SetBit(%1,%2)      (%1 |= (1<<%2))
#define ClearBit(%1,%2)    (%1 &= ~(1<<%2))
#define CheckBit(%1,%2)    (%1 & (1<<%2))

// Human Classes file
new const ZP_HUMANCLASSES_FILE[] = "zp_humanclasses.ini"

// Settings file
new const ZP_SETTINGS_FILE[] = "zombieplague.ini"

#define MODEL_MAX_LENGTH 64

// Models
new g_model_vknife_human[MODEL_MAX_LENGTH] = "models/v_knife.mdl"

#define MAXPLAYERS 32

#define TASK_BOT_DROP_WEAPON 1500
#define ID_TASK_BOT_DROP_WEAPON (taskid - TASK_BOT_DROP_WEAPON)

#define HUMANS_DEFAULT_NAME "Human"
#define HUMANS_DEFAULT_DESCRIPTION "Default"
#define HUMANS_DEFAULT_HEALTH 100
#define HUMANS_DEFAULT_ARMOR 15
#define HUMANS_DEFAULT_SPEED 1.0
#define HUMANS_DEFAULT_GRAVITY 1.0

const XO_CWEAPONBOX = 4;
new const m_rgpPlayerItems_CWeaponBox[6] = {34, 35, ...}

/*new const weaponList[32][32] = {	"", 			"weapon_p228", 		"", 			"weapon_scout", 
				"weapon_hegrenade", 	"weapon_xm1014", 	"", 			"weapon_mac10", 
				"weapon_aug", 		"weapon_smokegrenade", 	"weapon_elite", 	"weapon_fiveseven", 
				"weapon_ump45", 	"weapon_sg550", 	"weapon_galil", 	"weapon_famas",
				"weapon_usp", 		"weapon_glock18", 	"weapon_awp", 		"weapon_mp5navy", 
				"weapon_m249", 		"weapon_m3", 		"weapon_m4a1", 		"weapon_tmp", 
				"weapon_g3sg1", 	"weapon_flashbang", 	"weapon_deagle", 	"weapon_sg552", 
				"weapon_ak47", 		"", 			"weapon_p90", 		""}*/

// CS Player PData Offsets (win32)
const OFFSET_CSMENUCODE = 205

// For class list menu handlers
#define MENU_PAGE_CLASS g_menu_data[id]
new g_menu_data[MAXPLAYERS+1]

enum _:TOTAL_FORWARDS
{
	FW_CLASS_SELECT_PRE = 0,
	FW_CLASS_SELECT_POST
}
new g_Forwards[TOTAL_FORWARDS]
new g_ForwardResult

new g_HumanClassCount
new Array:g_HumanClassRealName
new Array:g_HumanClassName
new Array:g_HumanClassDesc
new Array:g_HumanClassHealth
new Array:g_HumanClassArmor
new Array:g_HumanClassSpeed
new Array:g_HumanClassGravity
new Array:g_HumanClassWeaponRestrictsFile
new Array:g_HumanClassWeaponRestrictsHandle
new Array:g_HumanClassModelsFile
new Array:g_HumanClassModelsHandle
new g_HumanClass[MAXPLAYERS+1]
new g_HumanClassNext[MAXPLAYERS+1]
new g_AdditionalMenuText[32]

// CS Player CBase Offsets (win32)
const PDATA_SAFE = 2
const OFFSET_ACTIVE_ITEM = 373

// Weapon bitsums
const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)
const GRENADES_WEAPONS_BIT_SUM = (1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)

#define PRIMARY_ONLY 1
#define SECONDARY_ONLY 2
#define GRENADES_ONLY 4

public plugin_init()
{
	register_plugin("[ZP ROTD] Class: Human", ZP_VERSION_STRING, "ZP Dev Team + DRON12261")
	
	register_clcmd("say /hclass", "show_menu_humanclass")
	register_clcmd("say /class", "show_class_menu")
	
	register_event("HLTV", "roundStart", "a", "1=0", "2=0")
	
	RegisterHam(Ham_Touch, "weaponbox", "fw_TouchWeapon")
	
	RegisterHam(Ham_Item_AddToPlayer, "weapon_galil", "fw_ItemAddPostGALIL", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_famas", "fw_ItemAddPostFAMAS", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_m4a1", "fw_ItemAddPostM4A1", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_ak47", "fw_ItemAddPostAK47", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_sg552", "fw_ItemAddPostSG552", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_aug", "fw_ItemAddPostAUG", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_m3", "fw_ItemAddPostM3", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_xm1014", "fw_ItemAddPostXM1014", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_m249", "fw_ItemAddPostM249", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_mac10", "fw_ItemAddPostMAC10", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_ump45", "fw_ItemAddPostUMP45", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_mp5navy", "fw_ItemAddPostMP5NAVY", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_tmp", "fw_ItemAddPostTMP", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_p90", "fw_ItemAddPostP90", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_p228", "fw_ItemAddPostP228", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_glock18", "fw_ItemAddPostGLOCK18", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_usp", "fw_ItemAddPostUSP", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_deagle", "fw_ItemAddPostDEAGLE", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_fiveseven", "fw_ItemAddPostFIVESEVEN", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_elite", "fw_ItemAddPostELITE", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_awp", "fw_ItemAddPostAWP", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_sg550", "fw_ItemAddPostSG550", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_g3sg1", "fw_ItemAddPostG3SG1", true)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_scout", "fw_ItemAddPostSCOUT", true)
	
	g_Forwards[FW_CLASS_SELECT_PRE] = CreateMultiForward("zp_fw_class_human_select_pre", ET_CONTINUE, FP_CELL, FP_CELL)
	g_Forwards[FW_CLASS_SELECT_POST] = CreateMultiForward("zp_fw_class_human_select_post", ET_CONTINUE, FP_CELL, FP_CELL)
}

public plugin_cfg()
{
	// No classes loaded, add default human class
	if (g_HumanClassCount < 1)
	{
		ArrayPushString(g_HumanClassRealName, HUMANS_DEFAULT_NAME)
		ArrayPushString(g_HumanClassName, HUMANS_DEFAULT_NAME)
		ArrayPushString(g_HumanClassDesc, HUMANS_DEFAULT_DESCRIPTION)
		ArrayPushCell(g_HumanClassHealth, HUMANS_DEFAULT_HEALTH)
		ArrayPushCell(g_HumanClassArmor, HUMANS_DEFAULT_ARMOR)
		ArrayPushCell(g_HumanClassSpeed, HUMANS_DEFAULT_SPEED)
		ArrayPushCell(g_HumanClassGravity, HUMANS_DEFAULT_GRAVITY)
		ArrayPushCell(g_HumanClassWeaponRestrictsFile, false)
		ArrayPushCell(g_HumanClassWeaponRestrictsHandle, Invalid_Array)
		ArrayPushCell(g_HumanClassModelsFile, false)
		ArrayPushCell(g_HumanClassModelsHandle, Invalid_Array)
		g_HumanClassCount++
	}
}

public plugin_precache()
{
	// Load from external file, save if not found
	if (!amx_load_setting_string(ZP_SETTINGS_FILE, "Weapon Models", "V_KNIFE HUMAN", g_model_vknife_human, charsmax(g_model_vknife_human)))
		amx_save_setting_string(ZP_SETTINGS_FILE, "Weapon Models", "V_KNIFE HUMAN", g_model_vknife_human)
	
	// Precache models
	precache_model(g_model_vknife_human)
}

public plugin_natives()
{
	register_library("zp50_class_human")
	register_native("zp_class_human_get_current", "native_class_human_get_current")
	register_native("zp_class_human_get_next", "native_class_human_get_next")
	register_native("zp_class_human_set_next", "native_class_human_set_next")
	register_native("zp_class_human_get_max_health", "_class_human_get_max_health")
	register_native("zp_class_human_get_max_armor", "_class_human_get_max_armor")
	register_native("zp_class_human_register", "native_class_human_register")
	register_native("zp_class_human_register_model", "_class_human_register_model")
	register_native("zp_class_human_register_restricted_weapon", "_class_human_register_restricted_weapon")
	register_native("zp_class_human_get_id", "native_class_human_get_id")
	register_native("zp_class_human_get_name", "native_class_human_get_name")
	register_native("zp_class_human_get_real_name", "_class_human_get_real_name")
	register_native("zp_class_human_get_desc", "native_class_human_get_desc")
	register_native("zp_class_human_get_count", "native_class_human_get_count")
	register_native("zp_class_human_show_menu", "native_class_human_show_menu")
	register_native("zp_class_human_menu_text_add", "_class_human_menu_text_add")
	
	// Initialize dynamic arrays
	g_HumanClassRealName = ArrayCreate(32, 1)
	g_HumanClassName = ArrayCreate(32, 1)
	g_HumanClassDesc = ArrayCreate(32, 1)
	g_HumanClassHealth = ArrayCreate(1, 1)
	g_HumanClassArmor = ArrayCreate(1, 1)
	g_HumanClassSpeed = ArrayCreate(1, 1)
	g_HumanClassGravity = ArrayCreate(1, 1)
	g_HumanClassWeaponRestrictsFile = ArrayCreate(1, 1)
	g_HumanClassWeaponRestrictsHandle = ArrayCreate(1, 1)
	g_HumanClassModelsFile = ArrayCreate(1, 1)
	g_HumanClassModelsHandle = ArrayCreate(1, 1)
}

public roundStart()
{
	new maxplayers = get_maxplayers()
	
	for (new i = 1; i <= maxplayers; i++)
	{
		strip_weapons(i, PRIMARY_ONLY)
		strip_weapons(i, SECONDARY_ONLY)
		strip_weapons(i, GRENADES_ONLY)
	}
}

bool:CanUserPickupWeapon(weapon, player)
{
	new Array:weapon_restricts = ArrayGetCell(g_HumanClassWeaponRestrictsHandle, zp_class_human_get_current(player))
	
	if (weapon_restricts != Invalid_Array)
	{
		for (new i = 0; i < ArraySize(weapon_restricts); i++)
		{
			new weaponID = ArrayGetCell(weapon_restricts, i)
			if(weapon == weaponID)
			{
				return false
			}
		}
	}
	return true
}

public BotsHandle(taskid)
{
	if (!is_user_alive(ID_TASK_BOT_DROP_WEAPON) || !is_user_connected(ID_TASK_BOT_DROP_WEAPON) || zp_class_sniper_get(ID_TASK_BOT_DROP_WEAPON) || zp_class_survivor_get(ID_TASK_BOT_DROP_WEAPON) || zp_class_human_get_current(ID_TASK_BOT_DROP_WEAPON) == -1)
	{
		return
	}
	
	if (!CanUserPickupWeapon(get_user_weapon(ID_TASK_BOT_DROP_WEAPON), ID_TASK_BOT_DROP_WEAPON))
	{
		engclient_cmd(ID_TASK_BOT_DROP_WEAPON, "drop")
	}
}

cs_get_weaponbox_type(iWeaponBox)
{
    new iWeapon
    
    for(new i=1; i<=5; i++)
    {
        iWeapon = get_pdata_cbase(iWeaponBox, m_rgpPlayerItems_CWeaponBox[i], XO_CWEAPONBOX)
	
        if( iWeapon > 0 )
        {
            return cs_get_weapon_id(iWeapon)
        }
    }
    
    return 0
}

public fw_TouchWeapon(weapon, player)
{
	if (!is_user_alive(player) || zp_class_human_get_current(player) == -1)
	{
		return HAM_IGNORED
	}
	
	if(!CanUserPickupWeapon(cs_get_weaponbox_type(weapon), player))
	{
		return HAM_SUPERCEDE
	}
	
	return HAM_IGNORED
}

public fw_ItemAddPostGALIL(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) == -1)
	{
		return HAM_IGNORED
	}
	
	if (!CanUserPickupWeapon(CSW_GALIL, player))
	{
		client_cmd(player, "drop")
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public fw_ItemAddPostFAMAS(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) == -1)
	{
		return HAM_IGNORED
	}
	
	if (!CanUserPickupWeapon(CSW_FAMAS, player))
	{
		client_cmd(player, "drop")
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public fw_ItemAddPostM4A1(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) == -1)
	{
		return HAM_IGNORED
	}
	
	if (!CanUserPickupWeapon(CSW_M4A1, player))
	{
		client_cmd(player, "drop")
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public fw_ItemAddPostAK47(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) == -1)
	{
		return HAM_IGNORED
	}
		
	if (!CanUserPickupWeapon(CSW_AK47, player))
	{
		client_cmd(player, "drop")
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public fw_ItemAddPostSG552(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) == -1)
	{
		return HAM_IGNORED
	}
		
	if (!CanUserPickupWeapon(CSW_SG552, player))
	{
		client_cmd(player, "drop")
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public fw_ItemAddPostAUG(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) == -1)
	{
		return HAM_IGNORED
	}
		
	if (!CanUserPickupWeapon(CSW_AUG, player))
	{
		client_cmd(player, "drop")
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public fw_ItemAddPostM3(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) == -1)
	{
		return HAM_IGNORED
	}
	
	if (!CanUserPickupWeapon(CSW_M3, player))
	{
		client_cmd(player, "drop")
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public fw_ItemAddPostXM1014(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) == -1)
	{
		return HAM_IGNORED
	}

	if (!CanUserPickupWeapon(CSW_XM1014, player))
	{
		client_cmd(player, "drop")
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public fw_ItemAddPostM249(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) == -1)
	{
		return HAM_IGNORED
	}
	
	if (!CanUserPickupWeapon(CSW_M249, player))
	{
		client_cmd(player, "drop")
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public fw_ItemAddPostMAC10(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) == -1)
	{
		return HAM_IGNORED
	}

	if (!CanUserPickupWeapon(CSW_MAC10, player))
	{
		client_cmd(player, "drop")
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public fw_ItemAddPostUMP45(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) == -1)
	{
		return HAM_IGNORED
	}

	if (!CanUserPickupWeapon(CSW_UMP45, player))
	{
		client_cmd(player, "drop")
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public fw_ItemAddPostMP5NAVY(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) == -1)
	{
		return HAM_IGNORED
	}

	if (!CanUserPickupWeapon(CSW_MP5NAVY, player))
	{
		client_cmd(player, "drop")
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public fw_ItemAddPostTMP(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) == -1)
	{
		return HAM_IGNORED
	}

	if (!CanUserPickupWeapon(CSW_TMP, player))
	{
		client_cmd(player, "drop")
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public fw_ItemAddPostP90(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) == -1)
	{
		return HAM_IGNORED
	}

	if (!CanUserPickupWeapon(CSW_P90, player))
	{
		client_cmd(player, "drop")
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public fw_ItemAddPostP228(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) == -1)
	{
		return HAM_IGNORED
	}

	if (!CanUserPickupWeapon(CSW_P228, player))
	{
		client_cmd(player, "drop")
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public fw_ItemAddPostGLOCK18(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) == -1)
	{
		return HAM_IGNORED
	}

	if (!CanUserPickupWeapon(CSW_GLOCK18, player))
	{
		client_cmd(player, "drop")
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public fw_ItemAddPostUSP(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) == -1)
	{
		return HAM_IGNORED
	}

	if (!CanUserPickupWeapon(CSW_USP, player))
	{
		client_cmd(player, "drop")
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public fw_ItemAddPostDEAGLE(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) == -1)
	{
		return HAM_IGNORED
	}

	if (!CanUserPickupWeapon(CSW_DEAGLE, player))
	{
		client_cmd(player, "drop")
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public fw_ItemAddPostFIVESEVEN(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) == -1)
	{
		return HAM_IGNORED
	}

	if (!CanUserPickupWeapon(CSW_FIVESEVEN, player))
	{
		client_cmd(player, "drop")
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public fw_ItemAddPostELITE(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) == -1)
	{
		return HAM_IGNORED
	}

	if (!CanUserPickupWeapon(CSW_ELITE, player))
	{
		client_cmd(player, "drop")
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public fw_ItemAddPostAWP(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) == -1)
	{
		return HAM_IGNORED
	}

	if (!CanUserPickupWeapon(CSW_AWP, player))
	{
		client_cmd(player, "drop")
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public fw_ItemAddPostSG550(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) == -1)
	{
		return HAM_IGNORED
	}

	if (!CanUserPickupWeapon(CSW_SG550, player))
	{
		client_cmd(player, "drop")
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public fw_ItemAddPostG3SG1(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) == -1)
	{
		return HAM_IGNORED
	}

	if (!CanUserPickupWeapon(CSW_G3SG1, player))
	{
		client_cmd(player, "drop")
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public fw_ItemAddPostSCOUT(weapon, player)
{	
	if (!is_user_alive(player) || zp_class_human_get_current(player) == -1)
	{
		return HAM_IGNORED
	}

	if (!CanUserPickupWeapon(CSW_SCOUT, player))
	{
		client_cmd(player, "drop")
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public client_putinserver(id)
{
	g_HumanClass[id] = ZP_INVALID_HUMAN_CLASS
	g_HumanClassNext[id] = ZP_INVALID_HUMAN_CLASS
	
	if (is_user_bot(id))
	{
		set_task(0.1, "BotsHandle", id+TASK_BOT_DROP_WEAPON, _, _, "b");
	}
}

public client_disconnected(id)
{
	if (is_user_bot(id))
	{
		remove_task(id+TASK_BOT_DROP_WEAPON)
	}
	
	// Reset remembered menu pages
	MENU_PAGE_CLASS = 0
}

public show_class_menu(id)
{
	if (!zp_core_is_zombie(id))
		show_menu_humanclass(id)
}

public show_menu_humanclass(id)
{
	static menu[512], name[32], description[32], transkey[64]
	new menuid, itemdata[2], index
	
	formatex(menu, charsmax(menu), "%L\r", id, "MENU_HCLASS")
	menuid = menu_create(menu, "menu_humanclass")
	
	for (index = 0; index < g_HumanClassCount; index++)
	{
		// Additional text to display
		g_AdditionalMenuText[0] = 0
		
		// Execute class select attempt forward
		ExecuteForward(g_Forwards[FW_CLASS_SELECT_PRE], g_ForwardResult, id, index)
		
		// Show class to player?
		if (g_ForwardResult >= ZP_CLASS_DONT_SHOW)
			continue;
		
		ArrayGetString(g_HumanClassName, index, name, charsmax(name))
		ArrayGetString(g_HumanClassDesc, index, description, charsmax(description))
		
		// ML support for class name + description
		formatex(transkey, charsmax(transkey), "HUMANDESC %s", name)
		if (GetLangTransKey(transkey) != TransKey_Bad) formatex(description, charsmax(description), "%L", id, transkey)
		formatex(transkey, charsmax(transkey), "HUMANNAME %s", name)
		if (GetLangTransKey(transkey) != TransKey_Bad) formatex(name, charsmax(name), "%L", id, transkey)
		
		// Class available to player?
		if (g_ForwardResult >= ZP_CLASS_NOT_AVAILABLE)
			formatex(menu, charsmax(menu), "\d%s %s %s", name, description, g_AdditionalMenuText)
		// Class is current class?
		else if (index == g_HumanClassNext[id])
			formatex(menu, charsmax(menu), "\r%s \y%s \w%s", name, description, g_AdditionalMenuText)
		else
			formatex(menu, charsmax(menu), "%s \y%s \w%s", name, description, g_AdditionalMenuText)
		
		itemdata[0] = index
		itemdata[1] = 0
		menu_additem(menuid, menu, itemdata)
	}
	
	// No classes to display?
	if (menu_items(menuid) <= 0)
	{
		zp_colored_print(id, "%L", id, "NO_CLASSES")
		menu_destroy(menuid)
		return;
	}
	
	// Back - Next - Exit
	formatex(menu, charsmax(menu), "%L", id, "MENU_BACK")
	menu_setprop(menuid, MPROP_BACKNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_NEXT")
	menu_setprop(menuid, MPROP_NEXTNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_EXIT")
	menu_setprop(menuid, MPROP_EXITNAME, menu)
	
	// If remembered page is greater than number of pages, clamp down the value
	MENU_PAGE_CLASS = min(MENU_PAGE_CLASS, menu_pages(menuid)-1)
	
	// Fix for AMXX custom menus
	set_pdata_int(id, OFFSET_CSMENUCODE, 0)
	menu_display(id, menuid, MENU_PAGE_CLASS)
}

public menu_humanclass(id, menuid, item)
{
	// Menu was closed
	if (item == MENU_EXIT)
	{
		MENU_PAGE_CLASS = 0
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Remember class menu page
	MENU_PAGE_CLASS = item / 7
	
	// Retrieve class index
	new itemdata[2], dummy, index
	menu_item_getinfo(menuid, item, dummy, itemdata, charsmax(itemdata), _, _, dummy)
	index = itemdata[0]
	
	// Execute class select attempt forward
	ExecuteForward(g_Forwards[FW_CLASS_SELECT_PRE], g_ForwardResult, id, index)
	
	// Class available to player?
	if (g_ForwardResult >= ZP_CLASS_NOT_AVAILABLE)
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Make selected class next class for player
	g_HumanClassNext[id] = index
	
	new name[32], transkey[64]
	new Float:maxspeed = Float:ArrayGetCell(g_HumanClassSpeed, g_HumanClassNext[id])
	ArrayGetString(g_HumanClassName, g_HumanClassNext[id], name, charsmax(name))
	// ML support for class name
	formatex(transkey, charsmax(transkey), "HUMANNAME %s", name)
	if (GetLangTransKey(transkey) != TransKey_Bad) formatex(name, charsmax(name), "%L", id, transkey)
	
	// Show selected human class
	zp_colored_print(id, "%L: %s", id, "HUMAN_SELECT", name)
	zp_colored_print(id, "%L: %d %L: %d %L: %d %L: %.2fx", id, "ZOMBIE_ATTRIB1", ArrayGetCell(g_HumanClassHealth, g_HumanClassNext[id]), id, "ATTRIB_ARMOR", ArrayGetCell(g_HumanClassArmor, g_HumanClassNext[id]), id, "ZOMBIE_ATTRIB2", cs_maxspeed_display_value(maxspeed),  id, "ZOMBIE_ATTRIB3", Float:ArrayGetCell(g_HumanClassGravity, g_HumanClassNext[id]))
	
	// Execute class select post forward
	ExecuteForward(g_Forwards[FW_CLASS_SELECT_POST], g_ForwardResult, id, index)
	
	menu_destroy(menuid)
	return PLUGIN_HANDLED;
}

public zp_fw_core_cure_post(id, attacker)
{
	// Show human class menu if they haven't chosen any (e.g. just connected)
	if (g_HumanClassNext[id] == ZP_INVALID_HUMAN_CLASS)
	{
		if (g_HumanClassCount > 1)
			show_menu_humanclass(id)
		else // If only one class is registered, choose it automatically
			g_HumanClassNext[id] = 0
	}
	
	// Bots pick class automatically
	if (is_user_bot(id))
	{
		// Try choosing class
		new index, start_index = random_num(0, g_HumanClassCount - 1)
		for (index = start_index + 1; /* no condition */; index++)
		{
			// Start over when we reach the end
			if (index >= g_HumanClassCount)
				index = 0
			
			// Execute class select attempt forward
			ExecuteForward(g_Forwards[FW_CLASS_SELECT_PRE], g_ForwardResult, id, index)
			
			// Class available to player?
			if (g_ForwardResult < ZP_CLASS_NOT_AVAILABLE)
			{
				g_HumanClassNext[id] = index
				break;
			}
			
			// Loop completed, no class could be chosen
			if (index == start_index)
				break;
		}
	}
	
	// Set selected human class. If none selected yet, use the first one
	g_HumanClass[id] = g_HumanClassNext[id]
	if (g_HumanClass[id] == ZP_INVALID_HUMAN_CLASS) g_HumanClass[id] = 0
	
	// Apply human attributes
	set_user_health(id, ArrayGetCell(g_HumanClassHealth, g_HumanClass[id]))
	set_user_armor(id, ArrayGetCell(g_HumanClassArmor, g_HumanClass[id]))
	set_user_gravity(id, Float:ArrayGetCell(g_HumanClassGravity, g_HumanClass[id]))
	cs_set_player_maxspeed_auto(id, Float:ArrayGetCell(g_HumanClassSpeed, g_HumanClass[id]))
	
	// Apply human player model
	new Array:class_models = ArrayGetCell(g_HumanClassModelsHandle, g_HumanClass[id])
	if (class_models != Invalid_Array)
	{
		new index = random_num(0, ArraySize(class_models) - 1)
		new player_model[32]
		ArrayGetString(class_models, index, player_model, charsmax(player_model))
		cs_set_player_model(id, player_model)
	}
	else
	{
		// No models registered for current class, use default model
		cs_reset_player_model(id)
	}
	
	// Set custom knife model
	cs_set_player_view_model(id, CSW_KNIFE, g_model_vknife_human)
}

public zp_fw_core_infect(id, attacker)
{
	// Remove custom knife model
	cs_reset_player_view_model(id, CSW_KNIFE)
}

public native_class_human_get_current(plugin_id, num_params)
{
	new id = get_param(1)
	
	if (!is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP ROTD] Invalid Player (%d)", id)
		return ZP_INVALID_HUMAN_CLASS;
	}
	
	return g_HumanClass[id];
}

public native_class_human_get_next(plugin_id, num_params)
{
	new id = get_param(1)
	
	if (!is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP ROTD] Invalid Player (%d)", id)
		return ZP_INVALID_HUMAN_CLASS;
	}
	
	return g_HumanClassNext[id];
}

public native_class_human_set_next(plugin_id, num_params)
{
	new id = get_param(1)
	
	if (!is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP ROTD] Invalid Player (%d)", id)
		return false;
	}
	
	new classid = get_param(2)
	
	if (classid < 0 || classid >= g_HumanClassCount)
	{
		log_error(AMX_ERR_NATIVE, "[ZP ROTD] Invalid human class id (%d)", classid)
		return false;
	}
	
	g_HumanClassNext[id] = classid
	return true;
}

public _class_human_get_max_health(plugin_id, num_params)
{
	new id = get_param(1)
	
	if (!is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP ROTD] Invalid Player (%d)", id)
		return -1;
	}
	
	new classid = get_param(2)
	
	if (classid < 0 || classid >= g_HumanClassCount)
	{
		log_error(AMX_ERR_NATIVE, "[ZP ROTD] Invalid human class id (%d)", classid)
		return -1;
	}
	
	return ArrayGetCell(g_HumanClassHealth, classid);
}

public _class_human_get_max_armor(plugin_id, num_params)
{
	new id = get_param(1)
	
	if (!is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP ROTD] Invalid Player (%d)", id)
		return -1;
	}
	
	new classid = get_param(2)
	
	if (classid < 0 || classid >= g_HumanClassCount)
	{
		log_error(AMX_ERR_NATIVE, "[ZP ROTD] Invalid human class id (%d)", classid)
		return -1;
	}
	
	return ArrayGetCell(g_HumanClassArmor, classid);
}

public native_class_human_register(plugin_id, num_params)
{
	new name[32]
	get_string(1, name, charsmax(name))
	
	if (strlen(name) < 1)
	{
		log_error(AMX_ERR_NATIVE, "[ZP ROTD] Can't register human class with an empty name")
		return ZP_INVALID_HUMAN_CLASS;
	}
	
	new index, humanclass_name[32]
	for (index = 0; index < g_HumanClassCount; index++)
	{
		ArrayGetString(g_HumanClassRealName, index, humanclass_name, charsmax(humanclass_name))
		if (equali(name, humanclass_name))
		{
			log_error(AMX_ERR_NATIVE, "[ZP ROTD] Human class already registered (%s)", name)
			return ZP_INVALID_HUMAN_CLASS;
		}
	}
	
	new description[32]
	get_string(2, description, charsmax(description))
	new health = get_param(3)
	new armor = get_param(4)
	new Float:speed = get_param_f(5)
	new Float:gravity = get_param_f(6)
	
	// Load settings from human classes file
	new real_name[32]
	copy(real_name, charsmax(real_name), name)
	ArrayPushString(g_HumanClassRealName, real_name)
	
	// Name
	if (!amx_load_setting_string(ZP_HUMANCLASSES_FILE, real_name, "NAME", name, charsmax(name)))
		amx_save_setting_string(ZP_HUMANCLASSES_FILE, real_name, "NAME", name)
	ArrayPushString(g_HumanClassName, name)
	
	// Description
	if (!amx_load_setting_string(ZP_HUMANCLASSES_FILE, real_name, "INFO", description, charsmax(description)))
		amx_save_setting_string(ZP_HUMANCLASSES_FILE, real_name, "INFO", description)
	ArrayPushString(g_HumanClassDesc, description)
	
	// Models
	new Array:class_models = ArrayCreate(32, 1)
	amx_load_setting_string_arr(ZP_HUMANCLASSES_FILE, real_name, "MODELS", class_models)
	if (ArraySize(class_models) > 0)
	{
		ArrayPushCell(g_HumanClassModelsFile, true)
		
		// Precache player models
		new index, player_model[32], model_path[128]
		for (index = 0; index < ArraySize(class_models); index++)
		{
			ArrayGetString(class_models, index, player_model, charsmax(player_model))
			formatex(model_path, charsmax(model_path), "models/player/%s/%s.mdl", player_model, player_model)
			precache_model(model_path)
			// Support modelT.mdl files
			formatex(model_path, charsmax(model_path), "models/player/%s/%sT.mdl", player_model, player_model)
			if (file_exists(model_path)) precache_model(model_path)
		}
	}
	else
	{
		ArrayPushCell(g_HumanClassModelsFile, false)
		ArrayDestroy(class_models)
		amx_save_setting_string(ZP_HUMANCLASSES_FILE, real_name, "MODELS", "")
	}
	ArrayPushCell(g_HumanClassModelsHandle, class_models)
	
	// Health
	if (!amx_load_setting_int(ZP_HUMANCLASSES_FILE, real_name, "HEALTH", health))
		amx_save_setting_int(ZP_HUMANCLASSES_FILE, real_name, "HEALTH", health)
	ArrayPushCell(g_HumanClassHealth, health)
	
	// Armor
	if (!amx_load_setting_int(ZP_HUMANCLASSES_FILE, real_name, "ARMOR", armor))
		amx_save_setting_int(ZP_HUMANCLASSES_FILE, real_name, "ARMOR", armor)
	ArrayPushCell(g_HumanClassArmor, armor)
	
	// Speed
	if (!amx_load_setting_float(ZP_HUMANCLASSES_FILE, real_name, "SPEED", speed))
		amx_save_setting_float(ZP_HUMANCLASSES_FILE, real_name, "SPEED", speed)
	ArrayPushCell(g_HumanClassSpeed, speed)
	
	// Gravity
	if (!amx_load_setting_float(ZP_HUMANCLASSES_FILE, real_name, "GRAVITY", gravity))
		amx_save_setting_float(ZP_HUMANCLASSES_FILE, real_name, "GRAVITY", gravity)
	ArrayPushCell(g_HumanClassGravity, gravity)
	
	// Weapon Restrictions
	new Array:weapon_restricts = ArrayCreate(1, 1)
	amx_load_setting_int_arr(ZP_HUMANCLASSES_FILE, real_name, "WEAPON RESTRICTS", weapon_restricts)
	if (ArraySize(weapon_restricts) > 0)
	{
		ArrayPushCell(g_HumanClassWeaponRestrictsFile, true)
	}
	else
	{
		ArrayPushCell(g_HumanClassWeaponRestrictsFile, false)
		ArrayDestroy(weapon_restricts)
		amx_save_setting_string(ZP_HUMANCLASSES_FILE, real_name, "WEAPON RESTRICTS", "")
	}
	ArrayPushCell(g_HumanClassWeaponRestrictsHandle, weapon_restricts)
	
	g_HumanClassCount++
	return g_HumanClassCount - 1;
}

public _class_human_register_model(plugin_id, num_params)
{
	new classid = get_param(1)
	
	if (classid < 0 || classid >= g_HumanClassCount)
	{
		log_error(AMX_ERR_NATIVE, "[ZP ROTD] Invalid human class id (%d)", classid)
		return false;
	}
	
	// Player models already loaded from file
	if (ArrayGetCell(g_HumanClassModelsFile, classid))
		return true;
	
	new player_model[32]
	get_string(2, player_model, charsmax(player_model))
	
	new model_path[128]
	formatex(model_path, charsmax(model_path), "models/player/%s/%s.mdl", player_model, player_model)
	
	precache_model(model_path)
	
	// Support modelT.mdl files
	formatex(model_path, charsmax(model_path), "models/player/%s/%sT.mdl", player_model, player_model)
	if (file_exists(model_path)) precache_model(model_path)
	
	new Array:class_models = ArrayGetCell(g_HumanClassModelsHandle, classid)
	
	// No models registered yet?
	if (class_models == Invalid_Array)
	{
		class_models = ArrayCreate(32, 1)
		ArraySetCell(g_HumanClassModelsHandle, classid, class_models)
	}
	ArrayPushString(class_models, player_model)
	
	// Save models to file
	new real_name[32]
	ArrayGetString(g_HumanClassRealName, classid, real_name, charsmax(real_name))
	amx_save_setting_string_arr(ZP_HUMANCLASSES_FILE, real_name, "MODELS", class_models)
	
	return true;
}

public _class_human_register_restricted_weapon(plugin_id, num_params)
{
	new classid = get_param(1)
	
	if (classid < 0 || classid >= g_HumanClassCount)
	{
		log_error(AMX_ERR_NATIVE, "[ZP ROTD] Invalid human class id (%d)", classid)
		return false;
	}
	
	if (ArrayGetCell(g_HumanClassWeaponRestrictsFile, classid))
		return true;
	
	new weaponID = get_param(2)
	
	new Array:weapon_restricts = ArrayGetCell(g_HumanClassWeaponRestrictsHandle, classid)
	
	if (weapon_restricts == Invalid_Array)
	{
		weapon_restricts = ArrayCreate(1,1)
		ArraySetCell(g_HumanClassWeaponRestrictsHandle, classid, weapon_restricts)
	}
	ArrayPushCell(weapon_restricts, weaponID)
	
	new real_name[32]
	ArrayGetString(g_HumanClassRealName, classid, real_name, charsmax(real_name))
	amx_save_setting_int_arr(ZP_HUMANCLASSES_FILE, real_name, "WEAPON RESTRICTS", weapon_restricts)
	
	return true;
}

public native_class_human_get_id(plugin_id, num_params)
{
	new real_name[32]
	get_string(1, real_name, charsmax(real_name))
	
	// Loop through every class
	new index, humanclass_name[32]
	for (index = 0; index < g_HumanClassCount; index++)
	{
		ArrayGetString(g_HumanClassRealName, index, humanclass_name, charsmax(humanclass_name))
		if (equali(real_name, humanclass_name))
			return index;
	}
	
	return ZP_INVALID_HUMAN_CLASS;
}

public native_class_human_get_name(plugin_id, num_params)
{
	new classid = get_param(1)
	
	if (classid < 0 || classid >= g_HumanClassCount)
	{
		log_error(AMX_ERR_NATIVE, "[ZP ROTD] Invalid human class id (%d)", classid)
		return false;
	}
	
	new name[32]
	ArrayGetString(g_HumanClassName, classid, name, charsmax(name))
	
	new len = get_param(3)
	set_string(2, name, len)
	return true;
}

public _class_human_get_real_name(plugin_id, num_params)
{
	new classid = get_param(1)
	
	if (classid < 0 || classid >= g_HumanClassCount)
	{
		log_error(AMX_ERR_NATIVE, "[ZP ROTD] Invalid human class id (%d)", classid)
		return false;
	}
	
	new real_name[32]
	ArrayGetString(g_HumanClassRealName, classid, real_name, charsmax(real_name))
	
	new len = get_param(3)
	set_string(2, real_name, len)
	return true;
}

public native_class_human_get_desc(plugin_id, num_params)
{
	new classid = get_param(1)
	
	if (classid < 0 || classid >= g_HumanClassCount)
	{
		log_error(AMX_ERR_NATIVE, "[ZP ROTD] Invalid human class id (%d)", classid)
		return false;
	}
	
	new description[32]
	ArrayGetString(g_HumanClassDesc, classid, description, charsmax(description))
	
	new len = get_param(3)
	set_string(2, description, len)
	return true;
}

public native_class_human_get_count(plugin_id, num_params)
{
	return g_HumanClassCount;
}

public native_class_human_show_menu(plugin_id, num_params)
{
	new id = get_param(1)
	
	if (!is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP ROTD] Invalid Player (%d)", id)
		return false;
	}
	
	show_menu_humanclass(id)
	return true;
}

public _class_human_menu_text_add(plugin_id, num_params)
{
	static text[32]
	get_string(1, text, charsmax(text))
	format(g_AdditionalMenuText, charsmax(g_AdditionalMenuText), "%s%s", g_AdditionalMenuText, text)
}

// Strip primary/secondary/grenades
stock strip_weapons(id, stripwhat)
{
	// Get user weapons
	new weapons[32], num_weapons, index, weaponid
	get_user_weapons(id, weapons, num_weapons)
	
	// Loop through them and drop primaries or secondaries
	for (index = 0; index < num_weapons; index++)
	{
		// Prevent re-indexing the array
		weaponid = weapons[index]
		
		if ((stripwhat == PRIMARY_ONLY && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM))
		|| (stripwhat == SECONDARY_ONLY && ((1<<weaponid) & SECONDARY_WEAPONS_BIT_SUM))
		|| (stripwhat == GRENADES_ONLY && ((1<<weaponid) & GRENADES_WEAPONS_BIT_SUM)))
		{
			// Get weapon name
			new wname[32]
			get_weaponname(weaponid, wname, charsmax(wname))
			
			// Strip weapon and remove bpammo
			ham_strip_weapon(id, wname)
			cs_set_user_bpammo(id, weaponid, 0)
		}
	}
}

stock ham_strip_weapon(index, const weapon[])
{
	// Get weapon id
	new weaponid = get_weaponid(weapon)
	if (!weaponid)
		return false;
	
	// Get weapon entity
	new weapon_ent = fm_find_ent_by_owner(-1, weapon, index)
	if (!weapon_ent)
		return false;
	
	// If it's the current weapon, retire first
	new current_weapon_ent = fm_cs_get_current_weapon_ent(index)
	new current_weapon = pev_valid(current_weapon_ent) ? cs_get_weapon_id(current_weapon_ent) : -1
	if (current_weapon == weaponid)
		ExecuteHamB(Ham_Weapon_RetireWeapon, weapon_ent)
	
	// Remove weapon from player
	if (!ExecuteHamB(Ham_RemovePlayerItem, index, weapon_ent))
		return false;
	
	// Kill weapon entity and fix pev_weapons bitsum
	ExecuteHamB(Ham_Item_Kill, weapon_ent)
	set_pev(index, pev_weapons, pev(index, pev_weapons) & ~(1<<weaponid))
	return true;
}

// Find entity by its owner (from fakemeta_util)
stock fm_find_ent_by_owner(entity, const classname[], owner)
{
	while ((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", classname)) && pev(entity, pev_owner) != owner) { /* keep looping */ }
	return entity;
}

// Get User Current Weapon Entity
stock fm_cs_get_current_weapon_ent(id)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return -1;
	
	return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM);
}
