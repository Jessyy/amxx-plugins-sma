#include <amxmodx> 
#include <amxmisc> 

#define MAX_AUTHID_LENGTH 22
#define CMDTARGET_BLIND (CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_ONLY_ALIVE | CMDTARGET_NO_BOTS)

new bool:g_bBlind[33], gmsgScreenFade;

public plugin_init()
{
	register_plugin("AMX Blind", "1.0.0", "X");
	
	register_concmd("amx_blind", "amx_blind", ADMIN_KICK, "<nick>");
	register_concmd("amx_unblind", "amx_unblind", ADMIN_KICK, "<nick>");
	
	gmsgScreenFade = get_user_msgid("ScreenFade");
	register_event("ScreenFade", "Event_ScreenFade", "b");
}

public client_putinserver(id)
{
	g_bBlind[id] = false;
}

public amx_blind(id, level, cid)
{ 
	if(!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;
	
	new arg[32];
	read_argv(1, arg, 31);
	
	new user = cmd_target(id, arg, CMDTARGET_BLIND);
	
	if(!user)
		return PLUGIN_HANDLED;
	
	new id_name[32], id_authid[MAX_AUTHID_LENGTH];
	get_user_authid(id, id_authid, charsmax(id_authid));
	get_user_name(id, id_name, 31);
	
	new user_name[32], user_authid[MAX_AUTHID_LENGTH];
	get_user_authid(user, user_authid, charsmax(user_authid));
	get_user_name(user, user_name, 31);
	
	if(g_bBlind[user]) {
		console_print(id, "[BLIND] Client ^"%s^" is already blind", user_name);
	}
    else {
		console_print(id, "[BLIND] Client ^"%s^" blinded", user_name);
		g_bBlind[user] = true;
		Fade_To_Black(user);
	}
	
	return PLUGIN_HANDLED;
}

public amx_unblind(id, level, cid)
{ 
	if(!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;
	
	new arg[32];
	read_argv(1, arg, 31);
	
	new user = cmd_target(id, arg, CMDTARGET_BLIND);
	
	if(!user)
		return PLUGIN_HANDLED;
	
	new id_name[32], id_authid[MAX_AUTHID_LENGTH];
	get_user_authid(id, id_authid, charsmax(id_authid));
	get_user_name(id, id_name, 31);
	
	new user_name[32], user_authid[MAX_AUTHID_LENGTH];
	get_user_authid(user, user_authid, charsmax(user_authid));
	get_user_name(user, user_name, 31);
	
	if(g_bBlind[user]) {
		console_print(id, "[BLIND] Client ^"%s^" unblinded", user_name);
		g_bBlind[user] = false;
		Reset_Screen(user);
	} else {
		console_print(id, "[BLIND] Client ^"%s^" is already unblind", user_name);
	}
	
	return PLUGIN_HANDLED;
}

public Event_ScreenFade(id)
{
	if(g_bBlind[id]) {
		Fade_To_Black(id);
	}
}

Fade_To_Black(id)
{
	message_begin(MSG_ONE_UNRELIABLE, gmsgScreenFade, _, id);
	write_short((1<<3)|(1<<8)|(1<<10));
	write_short((1<<3)|(1<<8)|(1<<10));
	write_short((1<<0)|(1<<2));
	write_byte(0);
	write_byte(0);
	write_byte(0);
	write_byte(255);
	message_end();
}

Reset_Screen(id)
{
	message_begin(MSG_ONE_UNRELIABLE, gmsgScreenFade, _, id);
	write_short(1<<2);
	write_short(0);
	write_short(0);
	write_byte(0);
	write_byte(0);
	write_byte(0);
	write_byte(0);
	message_end();
}
