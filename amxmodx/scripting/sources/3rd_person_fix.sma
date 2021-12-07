#include <amxmodx>
#include <fakemeta>

#define VERSION "1.0"

public plugin_init ( )
{
	register_plugin ( "3rd_person_fix", VERSION, "Radiance" )
	register_forward ( FM_AddToFullPack, "Forward_HookAddToFullPackPost", 1 )
}

public Forward_HookAddToFullPackPost ( es_handle, e, ent, host, hostflags, player, pSet )
	if ( player && ( ent == host ) )
		set_es ( es_handle, ES_RenderMode, kRenderNormal )
