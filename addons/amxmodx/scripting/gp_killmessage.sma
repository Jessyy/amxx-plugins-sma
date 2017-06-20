/**
 *	Kill Message - gp_killmessage.sma
 *
 *	Based on Kill Message w/ VOX v2.7 by God@Dorin from https://forums.alliedmods.net/showthread.php?p=798314
 *		@released: 11/04/2015 (dd/mm/yyyy)
 */
#include <amxmodx>
#include <amxplus>

#define PLUGIN_NAME		"Kill Message"
#define PLUGIN_VERSION	"2017.06.19"
#define PLUGIN_AUTHOR	"X"

enum
{
	KILLER = 0,
	VICTIM = 1
};

enum _:E_INFOTYPE
{
	E_ID,
	E_NAME[MAX_NAME_LENGTH],
	E_HEALTH,
	E_ARMOR
};

new g_pMessageVictim, g_pMessageKiller, g_iMaxClients;

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	g_pMessageVictim = register_cvar("amx_message_victim", "0");
	g_pMessageKiller = register_cvar("amx_message_killer", "1");

	register_event("DeathMsg", "Event@Death", "a");

	g_iMaxClients = get_maxplayers();
}

public Event@Death()
{
	new iData[2][E_INFOTYPE];
	iData[KILLER][E_ID] = read_data(1);
	iData[VICTIM][E_ID] = read_data(2);

	if(!(1 <= iData[KILLER][E_ID] <= g_iMaxClients) || iData[KILLER][E_ID] == iData[VICTIM][E_ID]) {
		return PLUGIN_HANDLED;
	}

	get_user_name(iData[KILLER][E_ID], iData[KILLER][E_NAME], MAX_NAME_LENGTH - 1);
	get_user_name(iData[VICTIM][E_ID], iData[VICTIM][E_NAME], MAX_NAME_LENGTH - 1);

	iData[KILLER][E_HEALTH] = get_user_health(iData[KILLER][E_ID]);
	iData[KILLER][E_ARMOR] = get_user_armor(iData[KILLER][E_ID]);

	if(iData[KILLER][E_HEALTH] <= 0) {
		iData[KILLER][E_HEALTH] = iData[KILLER][E_ARMOR] = 0;
	}

	if(get_pcvar_num(g_pMessageVictim)) {
		client_color_print(iData[KILLER][E_ID], "^1* L-ai ucis pe: ^4%s^1", iData[VICTIM][E_NAME]);
	}

	if(get_pcvar_num(g_pMessageKiller)) {
		client_color_print(iData[VICTIM][E_ID], "^1* Assasin: ^4%s^1 - Hp: ^4%d^1 - Armura: ^4%d^1", iData[KILLER][E_NAME], iData[KILLER][E_HEALTH], iData[KILLER][E_ARMOR]);
	}

	return PLUGIN_CONTINUE;
}
