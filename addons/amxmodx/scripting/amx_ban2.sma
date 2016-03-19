#include <amxmodx>
#include <amxmisc>

#define CMDTARGET_BAN (CMDTARGET_OBEY_IMMUNITY | CMDTARGET_NO_BOTS | CMDTARGET_ALLOW_SELF)

new const bankey[] = "_ban";

public plugin_init()
{
	register_plugin("Ban Config", "1.0.0", "X");
	
	register_concmd("amx_ban2", "cmd_banconfig", ADMIN_BAN, "<name> <time>");
}

public cmd_banconfig(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;
	
	new target[32], minutes[10];
	read_argv(1, target, 31);
	read_argv(2, minutes, 9);
	
	new player = cmd_target(id, target, CMDTARGET_BAN);
	
	if(!player)
		return PLUGIN_HANDLED;
	
	new time = ((str_to_num(minutes) * 60) + get_systime());
	
	if(str_to_num(minutes) <= 0)
		time = 9999999999;
	
	new admin_name[32];
	get_user_name(id, admin_name, 31);
	
	new target_name[32];
	get_user_name(player, target_name, 31);
	
	show_activity(id, admin_name, "Has banned %s for IP dynamic", target_name);
	
	client_cmd(player, "developer 1;wait;setinfo ^"%s^" ^"%d^"", bankey, time);
	
	server_cmd("kick #%d ^"You have been banned from this server^"", get_user_userid(player));
	
	return PLUGIN_HANDLED;
}

public client_connect(id)
{
	new info[32];
	get_user_info(id, bankey, info, 31);
	
	if(strlen(info) > 0 && get_systime() < str_to_num(info)) {
		server_cmd("kick #%d ^"You are been banned from this server^"", get_user_userid(id));
	}
	
	return PLUGIN_CONTINUE;
}
