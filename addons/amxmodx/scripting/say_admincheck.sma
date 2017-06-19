/**
 *	Admin Check - say_admincheck.sma
 *
 *	Based on Admin Check v1.51 by OneEyed from https://forums.alliedmods.net/showthread.php?p=230189
 *		@released: 12/04/2006 (dd/mm/yyyy)
 */
#include <amxmodx>
#include <amxplus>

#define PLUGIN_NAME		"Admin Check"
#define PLUGIN_VERSION	"2017.06.18"
#define PLUGIN_AUTHOR	"X"

new g_iMaxClients;

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	register_clcmd("say /admin", "Cmd@Admins", -1);
	register_clcmd("say_team /admin", "Cmd@Admins", -1);

	register_clcmd("say /admins", "Cmd@Admins", -1);
	register_clcmd("say_team /admins", "Cmd@Admins", -1);

	g_iMaxClients = get_maxplayers();
}

public Cmd@Admins(id)
{
	new szAdminName[MAX_PLAYERS][MAX_NAME_LENGTH], iCount;

	for(new i = 1; i <= g_iMaxClients; i++) {
		if(is_user_connected(i) && (get_user_flags(i) & ADMIN_KICK)) {
			get_user_name(i, szAdminName[iCount++], 31);
		}
	}

	new szMessage[MAX_STRING], iLenght;
	iLenght = format(szMessage, charsmax(szMessage), "^4ADMINS ONLINE: ");
	if(iCount > 0) {
		for(new i = 0; i < iCount; i++) {
			iLenght += format(szMessage[iLenght], charsmax(szMessage) - iLenght, "%s %s", szAdminName[i], i < (iCount - 1) ? ", " : "");

			if(iLenght > 96) {
				client_color_print(id, szMessage);
				iLenght = format(szMessage, charsmax(szMessage), "^4 ");
			}
		}
		client_color_print(id, szMessage);
	}
	else {
		iLenght += format(szMessage[iLenght], charsmax(szMessage) - iLenght, "No admins online");
		client_color_print(id, szMessage);
	}

	return PLUGIN_HANDLED;
}
