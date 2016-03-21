/**
 *	Restart Match - say_restart.sma
 *	
 *	Based on Round Restart v2.2 by Dorin from https://forums.alliedmods.net/showthread.php?p=798354
 *		@released: 22/05/2011 (dd/mm/yyyy)
 */
#include <amxmodx>
#include <engine>

#define PLUGIN_NAME		"Restart Match"
#define PLUGIN_VERSION	"2016.03.19"
#define PLUGIN_AUTHOR	"X"

#define WAITTIME	10.0

new Float:g_LastRestart[33];

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	register_clcmd("say /restart", "SayCmd_Restart");
}

public SayCmd_Restart(id) 
{
	if(!(get_user_flags(id) & ADMIN_SLAY)) {
		return PLUGIN_HANDLED;
	}
	
	new Float:Time = halflife_time();
	
	if(Time - g_LastRestart[id] < WAITTIME) {
		client_print(id, print_chat, "* [Info] You must wait before giving another restart!");
		return PLUGIN_CONTINUE;
	}
	
	g_LastRestart[id] = Time;
	
	server_cmd("sv_restart 1");
	
	client_print(0, print_chat, "[---------LIVE!---------]");
	client_print(0, print_chat, "[---------LIVE!---------]");
	client_print(0, print_chat, "[---------LIVE!---------]");
	client_print(0, print_chat, "[---------LIVE!---------]");
	client_print(0, print_chat, "[---------LIVE!---------]");
	client_print(0, print_chat, "[---------LIVE!---------]");
	
	set_hudmessage(255, 150, 0, 0.04, 0.47, 0, 6.0, 7.0);
	show_hudmessage(0, "Live ! Live ! Live ! GL & HF !" );
	show_hudmessage(0, "Live ! Live ! Live ! GL & HF !" );
	show_hudmessage(0, "Live ! Live ! Live ! GL & HF !" );
	show_hudmessage(0, "Live ! Live ! Live ! GL & HF !" );
	show_hudmessage(0, "Live ! Live ! Live ! GL & HF !" );
	
	return PLUGIN_CONTINUE;
}
