#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <geoip>

new ip[32]
new finish

public plugin_init() 
{ 
	register_plugin("Ultimate SS", "1.0", "X")
	
	register_concmd("amx_ss", "concmd_screen", ADMIN_LEVEL_A, "<name> <screens>")
}

public concmd_screen(id, level, cid)
{
	if(!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED
	
	new arg1[24], arg2[4]
	read_argv(1, arg1, 23)
	read_argv(2, arg2, 3)
	
	new screens = str_to_num(arg2)
	
	if(screens > 5) {
		console_print(id, "[SS] Prea multe poze!")
		
		return PLUGIN_HANDLED
	}
	
	new player
	player = cmd_target(id, arg1, 1)
	
	if(!player)
		return PLUGIN_HANDLED
	
	finish = screens
	
	new Float:interval = 1.0
	new array[2]
	array[0] = id
	array[1] = player
	
	if(is_user_connected(player) && is_user_alive(player)) 	{ 
		set_task(interval, "ss_propriuzis", 0, array,2, "a", screens)
	} else {
		console_print(id, "[SS] Trebuie sa fie in viata ca sa-i faci Snapshot!")
	}
	
	return PLUGIN_HANDLED;
}

public ss_propriuzis(array[2])
{
	new player = array[1]
	new id = array[0]
	static szMessage[128]
	new timestamp[32], name[32], adminname[32], hostname[64], user_country[48], user_city[48]
	get_time("%m/%d/%Y - %H:%M:%S", timestamp, 31)
	get_user_name(player, name, 31)
	get_user_name(id, adminname, 31)
	get_user_ip(player, ip, 31)
	get_cvar_string("hostname",hostname,63)
	geoip_country(ip, user_country, 47)
	geoip_city(ip, user_city, 47)
	
	if(equal(user_country, "error")) {user_country = "Unknown";}
	if(equal(user_city, "error")) {user_city = "Unknown";}
	
	engclient_print(player, engprint_center, "Data: %s^n^nServar: %s^n^n[Snapshots]^n^nNume: %s^n^nIP: %s^n^nTara: %s | Oras: %s",timestamp,hostname,name,ip,user_country,user_city)
	formatex(szMessage, sizeof szMessage - 1, "^x04**^x01 Screenshot Taken on player ^''^x03%s^x01^'' by admin ^''^x04%s^x01^'' (%s) ^x04**^x01", name, adminname, timestamp)
	print_SayText(player, 0, szMessage)
	
	client_cmd(player, "wait;wait;wait;wait;wait;snapshot")
	console_print(id, "[SS] %s 's ip is %s!",name,ip)
	finish = finish - 1
	
	if(finish == 0) {
		set_task(1.0, "silentkill", 0, array, 2)
	}
	
	return PLUGIN_CONTINUE
}

public silentkill(array[2])
{
	new id = array[0]
	new player = array[1]
	
	user_silentkill(player)
	cs_set_user_team(player, CS_TEAM_SPECTATOR)
	
	if(cs_get_user_team(id) != CS_TEAM_SPECTATOR) {
		user_silentkill(id)
		cs_set_user_team(id, CS_TEAM_SPECTATOR)
	}
}

stock print_SayText(sender, receiver, const szMessage[])
{
	static MSG_type, id;
	
	if(receiver > 0) {
		MSG_type = MSG_ONE_UNRELIABLE;
		id = receiver;
	} else {
		MSG_type = MSG_BROADCAST;
		id = sender;
	}
	
	message_begin(MSG_type, get_user_msgid("SayText"), _, id);
	write_byte(sender);
	write_string(szMessage);
	message_end();
	
	return 1;
}
