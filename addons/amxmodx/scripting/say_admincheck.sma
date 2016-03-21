/**
 *	Admin Check - say_admincheck.sma
 *	
 *	Based on Admin Check v1.51 by OneEyed from https://forums.alliedmods.net/showthread.php?p=230189
 *		@released: 12/04/2006 (dd/mm/yyyy)
 */
#include <amxmodx>

#define PLUGIN_NAME		"Admin Check"
#define PLUGIN_VERSION	"2016.03.19"
#define PLUGIN_AUTHOR	"X"

new g_iMaxClients;
static const COLOR[] = "^4";

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	register_clcmd("say /admin", "SayCmd_Admins");
	register_clcmd("say /admins", "SayCmd_Admins");
	
	g_iMaxClients = get_maxplayers();
}

public SayCmd_Admins(id)
{
	set_task(0.1, "print_adminlist", id);
	
	return PLUGIN_CONTINUE;
}

public print_adminlist(user)
{
	new adminnames[33][32], message[256], id, count, x, len;
	
	for(id = 1; id <= g_iMaxClients; id++) {
		if(is_user_connected(id)) {
			if(get_user_flags(id) & ADMIN_KICK) {
				get_user_name(id, adminnames[count++], 31);
			}
		}
	}
	
	len = format(message, 255, "%sADMINS ONLINE: ", COLOR);
	if(count > 0) {
		for(x = 0; x < count; x++) {
			len += format(message[len], 255-len, "%s %s", adminnames[x], x<(count-1) ? ", " : "");
			if(len > 96 ) {
				print_message(user, message);
				len = format(message, 255, "%s ", COLOR);
			}
		}
		print_message(user, message);
	}
	else {
		len += format(message[len], 255-len, "No admins online");
		print_message(user, message);
	}
}

print_message(id, msg[])
{
	static gmsgSayText;
	gmsgSayText = get_user_msgid("SayText");
	
	message_begin(MSG_ONE, gmsgSayText, {0, 0, 0}, id);
	write_byte(id);
	write_string(msg);
	message_end();
}
