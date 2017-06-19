/**
 *	Show IP - amx_showip.sma
 *
 *	Based on Amx Showip v1.0 by Vicious Vixen from https://forums.alliedmods.net/showthread.php?t=197662
 *		@released: 10/06/2012 (dd/mm/yyyy)
 */
#include <amxmodx>
#include <amxplus>

#define PLUGIN_NAME		"Show IP"
#define PLUGIN_VERSION	"2017.06.18"
#define PLUGIN_AUTHOR	"X"

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	register_concmd("amx_showip", "Cmd@ShowIp", ADMIN_KICK);
}

public Cmd@ShowIp(id)
{
	new iPlayers[MAX_PLAYERS], iCount;
	get_players(iPlayers, iCount);

	static szName[MAX_NAME_LENGTH], szIp[MAX_IP_LENGTH];

	console_print(id, "Lista de IP-uri:");
	for(new i = 0; i < iCount; i++) {
		get_user_ip(iPlayers[i], szIp, charsmax(szIp), 1);
		get_user_name(iPlayers[i], szName, charsmax(szName));

		console_print(id, "[%d] %-32.30s %-16.15s", i, szName, szIp);
	}

	return PLUGIN_HANDLED;
}
