#include <amxmodx>

new g_iMaxClients;
static const COLOR[] = "^4";

public plugin_init()
{
	register_plugin("Admin Check", "1.0.0", "X");
	
	register_clcmd("say /admin", "say_admins", -1);
	register_clcmd("say /admins", "say_admins", -1);
	
	g_iMaxClients = get_maxplayers();
}

public say_admins(id)
{
	set_task(0.1, "print_adminlist", id);
	
	return PLUGIN_HANDLED;
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
	
	len = format(message, 255, "%s ADMINS ONLINE: ", COLOR);
	if(count > 0) {
		for(x = 0; x < count; x++) {
			len += format(message[len], 255-len, "%s %s", adminnames[x], x<(count-1) ? ", " : "");
			if(len > 96 ) {
				print_message(user, message);
				len = format(message, 255, "%s ",COLOR);
			}
		}
		print_message(user, message);
	} else {
		len += format(message[len], 255-len, " No admins online");
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
