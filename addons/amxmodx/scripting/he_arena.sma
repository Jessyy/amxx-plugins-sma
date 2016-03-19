#include <amxmodx>
#include <cstrike>
#include <amxmisc>
#include <engine>
#include <fun>

new bool:g_heArena = false

public plugin_init()
{
	register_plugin("HE Arena X", "1.0", "X")
	
	register_event("ResetHUD", "newround", "b")
	
	register_concmd("amx_hearena", "hearenatoggle", ADMIN_KICK, "<on/off>")
	register_event("CurWeapon", "holdwpn", "be", "1=1")
	
	register_clcmd("say /votehearena", "start123", -1)
	register_menucmd(register_menuid("Invite"), (1<<0)|(1<<1), "mvote_count")
	
	register_message(get_user_msgid("TextMsg"), "msg_text")
	register_message(get_user_msgid("SendAudio"), "msg_audio")
}

public plugin_modules()
{
	require_module("cstrike")
	require_module("fun")
	require_module("engine")
}

public hearenatoggle(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	
	if(read_argc() == 2) {
		new argument[10]
		read_argv(1,argument,9)
		
		if(equal(argument, "on") || equal(argument, "1")) {
			if(g_heArena)
				return PLUGIN_HANDLED
			else
				g_heArena = true
		}
		else if(equal(argument, "off") || equal(argument, "0")) {
			if(!g_heArena)
				return PLUGIN_HANDLED
			else
				g_heArena = false
		}
	} else {
		g_heArena = !g_heArena
	}
	
	if(g_heArena) {
		client_print(0,print_center,"HE Arena was enabled!")
		client_print(id,print_console,"[AMX] HE Arena was enabled!")
		server_print("[AMX] HE Arena was enabled!")
		
		server_cmd("amxx pause descriptive_fir")
		server_cmd("amxx pause realnadedrops")
		
		new playersList[32]
		new playersFound
		get_players(playersList,playersFound,"a")
		for(new i = 0;i < playersFound;i++) {
			giveheifnothas(playersList[i])
			engclient_cmd(playersList[i], "weapon_hegrenade")
		}
	} else {
		client_print(0,print_center,"HE Arena was disabled!")
		client_print(id,print_console,"[AMX] HE Arena was disabled!")
		server_print("[AMX] HE Arena was disabled!")
		
		server_cmd("amxx unpause descriptive_fir")
		server_cmd("amxx unpause realnadedrops")
	}
	
	return PLUGIN_HANDLED;
}

public holdwpn(id)
{
	if(!g_heArena)
		return PLUGIN_CONTINUE
	
	new weapontypeid = read_data(2)
	
	if(weapontypeid == CSW_HEGRENADE || weapontypeid == CSW_C4) {
		
	}
	else {
		giveheifnothas(id)
		engclient_cmd(id, "weapon_hegrenade")
	}
	
	return PLUGIN_CONTINUE
}

public newround(id)
{
	if(!g_heArena)
		return PLUGIN_CONTINUE
	
	giveheifnothas(id)
	engclient_cmd(id, "weapon_hegrenade")
	
	return PLUGIN_CONTINUE
}

public giveheifnothas(id)
{
	new nades = cs_get_user_bpammo(id, CSW_HEGRENADE)
	
	if(nades == 0) {
		give_item(id, "weapon_hegrenade")
		cs_set_user_bpammo(id, CSW_HEGRENADE, 1)
	}
	else if(nades == 1) {
		cs_set_user_bpammo(id, CSW_HEGRENADE, 1)
	}
	
	return PLUGIN_CONTINUE
}

new moption[2]
new votehearena[] = "\yAmx \r%s\y HE Arena^n^n\r[1]\w Yes^n\r[2]\w No"

public start123()
{
	set_task(0.1,"vote_he")
	
	return PLUGIN_HANDLED
}

public vote_he(id)
{
	new Float:voting = get_cvar_float("amx_last_voting")
	
	if(voting > get_gametime()) {
		client_print(id,print_chat,"There is already one voting...")
		return PLUGIN_HANDLED
	}
	
	if(voting && voting + get_cvar_float("amx_vote_delay") > get_gametime()) {
		client_print(id,print_chat,"Voting not allowed at this time ...")
		return PLUGIN_HANDLED
	}
	
	new menu_msg[256]
	format(menu_msg,255,votehearena,g_heArena ? "Disable" : "Enable")
	new Float:vote_time = get_cvar_float("amx_vote_time") + 2.0
	set_cvar_float("amx_last_voting",  get_gametime() + vote_time )
	show_menu(0,(1<<0)|(1<<1),menu_msg,floatround(vote_time),"Invite")
	set_task(vote_time,"check_mvotes")
	client_print(0, print_chat, "Voting for HE Arena has started ...")
	moption[0]=moption[1]=0
	
	return PLUGIN_CONTINUE
}

public mvote_count(id,key)
{
	if(get_cvar_float("amx_vote_answers")) {
		new name[32]
		get_user_name(id,name,31)
		client_print(0,print_chat,"%s voted %s.", name, key ? "against" : "for" )
	}
	++moption[key]
	return PLUGIN_HANDLED
}

public check_mvotes(id)
{
	if(moption[0] > moption[1]) {
		if(g_heArena)
			server_cmd("amx_hearena off")
		else if(!g_heArena)
			server_cmd("amx_hearena on")
		client_print(0,print_chat,"Voting results: (Yes ^''%d^'') (No ^''%d^''). The result: ''Yes''",moption[0],moption[1])
	} else{
		if(g_heArena)
			server_cmd("amx_hearena on")
		else if(!g_heArena)
			server_cmd("amx_hearena off")
		client_print(0,print_chat,"Voting results: (Yes ^''%d^'') (No ^''%d^''). The result: ''No''",moption[0],moption[1])
	}
	
	return PLUGIN_CONTINUE
}

public msg_text()
{
	if(g_heArena == false)
		return 0
		
	if(is_running("czero")) {
		if(get_msg_args() != 6 || get_msg_argtype(6) != ARG_STRING)
			return PLUGIN_CONTINUE
		
		new arg6[20]
		get_msg_arg_string(6, arg6, 19)
		if(equal(arg6, "#Fire_in_the_hole"))
			return PLUGIN_HANDLED
	} else {
		if(get_msg_args() != 5 || get_msg_argtype(5) != ARG_STRING)
			return PLUGIN_CONTINUE
		
		new arg5[20]
		get_msg_arg_string(5, arg5, 19)
		if(equal(arg5, "#Fire_in_the_hole"))
			return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

public msg_audio()
{
	if(g_heArena == false)
		return 0
		
	if(get_msg_args() != 3 || get_msg_argtype(2) != ARG_STRING)
		return PLUGIN_CONTINUE
	
	new arg2[20]
	get_msg_arg_string(2, arg2, 19)
	if(equal(arg2[1], "!MRAD_FIREINHOLE"))
		return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
}
