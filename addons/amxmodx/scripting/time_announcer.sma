#include <amxmodx>

/*
new g_str_min[4];
new g_str_sec[4];
new g_min;
new g_sec;
*/

public plugin_init() 
{ 
	register_plugin("Time Announcer", "1.0", "X");
	
	register_clcmd("say /thetime","handle_say1", 0);
	register_clcmd("say_team /thetime", "handle_say1", 0);
	
	register_clcmd("say thetime","handle_say1", 0);
	register_clcmd("say_team thetime", "handle_say1", 0);
	
	register_clcmd("say /timeleft","handle_say2", 0);
	register_clcmd("say_team timeleft", "handle_say2", 0);
	
	register_clcmd("say timeleft","handle_say2", 0);
	register_clcmd("say_team /timeleft", "handle_say2", 0);
	
//	set_task(1.0, "the_time", 0, "", 0, "b");
}

public handle_say1(user)
{
	new ctime[64];
	get_time("%H:%M:%S - %m/%d/%Y", ctime, 63);
	client_print(user, print_chat, "* [Info] The time: %s", ctime);
	
	return PLUGIN_HANDLED;
}

public handle_say2(user)
{
	new timeleft = get_timeleft();
	client_print(user, print_chat, "* [Info] Time Left: %d:%02d min.", timeleft / 60, timeleft % 60);
	
	return PLUGIN_HANDLED;
}

/*
public the_time()
{
	get_time("%M", g_str_min, 3);
	g_min = str_to_num(g_str_min);
	get_time("%S", g_str_sec, 3);
	g_sec = str_to_num(g_str_sec);
	
	if (g_min == 0 && g_sec == 0 || g_min == 15 && g_sec == 0 || g_min == 30 && g_sec == 0 || g_min == 45 && g_sec == 0) { 
		new ctime[64];
		get_time("%H:%M:%S - %m/%d/%Y", ctime, 63);
		client_print(0, print_chat, "* [Info] The time: %s", ctime);
	}
	
	return PLUGIN_HANDLED;
}
*/
