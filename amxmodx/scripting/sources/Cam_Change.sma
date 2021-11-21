#include <amxmodx>
#include <engine>

public plugin_init()
{
	register_plugin("Cam Change","1.1","Bl0ck")
	
	register_cvar("cam_change","1")
	
	register_clcmd("say /cam","CamChange")
	register_clcmd("say /camera","CamChange")
        register_clcmd("say /cam_1st","CAMERA_NONE")
        register_clcmd("say /cam_upleft","CAMERA_UPLEFT")
        register_clcmd("say /cam_3rd","CAMERA_3RDPERSON")
        register_clcmd("say /cam_topdown","CAMERA_TOPDOWN")
	
	register_dictionary("cam_change.txt")
}

public plugin_precache()
{
	precache_model("models/rpgrocket.mdl")
}

public CamChange(id)
{	
	if(get_cvar_num("cam_change"))
		CamMenu(id)
}

public CamMenu(id) 
{	
	new szText[ 555 char ];
	formatex(szText, charsmax( szText ), "\y%L", id, "CAM_MENU");
	
	new menu = menu_create( szText, "cam_menu" )
	
	formatex( szText, charsmax( szText ), "%L", id, "CAM_3RD" )
	menu_additem(menu,szText,"1",0)
	
	formatex( szText, charsmax( szText ), "%L", id, "CAM_TOPDOWN" )
	menu_additem(menu,szText,"2",0)
	
	formatex( szText, charsmax( szText ), "%L", id, "CAM_UPLEFT" )
	menu_additem(menu,szText,"3",0)
	
	formatex( szText, charsmax( szText ), "%L", id, "CAM_1ST" )
	menu_additem(menu,szText,"4",0)
	
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id,menu,0)
	
	return PLUGIN_CONTINUE
}

public cam_menu( id, menu, item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu )
		return PLUGIN_HANDLED
	}
	
	new data[6], iName[64], access, callback
	
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback)

	new key = str_to_num( data )
	
	switch ( key ) {
		case 1: 
		{
			if(is_user_alive(id))
			{
				set_view(id,CAMERA_3RDPERSON)
			}
			else
			{
				client_print(id, print_chat, "[CAM] %L", id, "CAM_ONLY_ALIVE")
			}
		}
		case 2: 
		{
			if(is_user_alive(id))
			{
				set_view(id,CAMERA_TOPDOWN)
			}
			else
			{
				client_print(id, print_chat, "[CAM] %L", id, "CAM_ONLY_ALIVE")
			}
		}
		case 3: 
		{
			if(is_user_alive(id))
			{
				set_view(id,CAMERA_UPLEFT)
			}	
			else
			{
				client_print(id, print_chat, "[CAM] %L", id, "CAM_ONLY_ALIVE")
			}
		}
		case 4: 
		{
			if(is_user_alive(id))
			{
				set_view(id,CAMERA_NONE)
			}
			else
			{
				client_print(id, print_chat, "[CAM] %L", id, "CAM_ONLY_ALIVE")
			}
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
