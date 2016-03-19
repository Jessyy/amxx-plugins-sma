#include <amxmodx>
#include <engine>

new Float:g_LastRestart[33];

public plugin_init()
{
	register_plugin("Say Restart", "1.0.0", "X");
	
	register_clcmd("say /restart", "say_restart", -1);
}

public say_restart(id) 
{
	if(!(get_user_flags(id) & ADMIN_SLAY))
		return PLUGIN_HANDLED;
	
	new Float:Time = halflife_time();
	
	if(!(Time - g_LastRestart[id] < 10.0)) {
		g_LastRestart[id] = Time;
		
		server_cmd("sv_restart 1");
		
		client_print(0, print_chat, "[---------LIVE!---------]");
		client_print(0, print_chat, "[---------LIVE!---------]");
		client_print(0, print_chat, "[---------LIVE!---------]");
		client_print(0, print_chat, "[---------LIVE!---------]");
		client_print(0, print_chat, "[---------LIVE!---------]");
		client_print(0, print_chat, "[---------LIVE!---------]");
		
		set_hudmessage(255,150, 0, 0.04, 0.47, 0, 6.0, 7.0);
		show_hudmessage(0, "Live ! Live ! Live ! GL & HF !" );
		show_hudmessage(0, "Live ! Live ! Live ! GL & HF !" );
		show_hudmessage(0, "Live ! Live ! Live ! GL & HF !" );
		show_hudmessage(0, "Live ! Live ! Live ! GL & HF !" );
		show_hudmessage(0, "Live ! Live ! Live ! GL & HF !" );
	}
	
	return PLUGIN_HANDLED;
}
