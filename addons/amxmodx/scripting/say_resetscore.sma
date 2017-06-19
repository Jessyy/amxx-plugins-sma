/**
 *	Reset Score - say_resetscore.sma
 *
 *	Based on Reset Score v1.1 by Silenttt from https://forums.alliedmods.net/showthread.php?t=74207
 *		@released: 19/11/2011 (dd/mm/yyyy)
 *
 *	Based on Reset Score v3.3 by Ex3cuTioN from https://www.extreamcs.com/forum/pluginuri-extream/reset-score-t50602.html
 *		@released: 05/06/2013 (dd/mm/yyyy)
 */
#include <amxmodx>
#include <amxplus>
#include <cstrike>
#include <fun>

#define PLUGIN_NAME		"Reset Score"
#define PLUGIN_VERSION	"2017.06.18"
#define PLUGIN_AUTHOR	"X"

// How many seconds must pass before players can reset their score again
#define TIME_INTERVAL	(210)

new g_iLastReset[MAX_PLAYERS];

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	register_clcmd("say /rs", "Cmd@ResetScore", -1);
	register_clcmd("say_team /rs", "Cmd@ResetScore", -1);

	register_clcmd("say /reset", "Cmd@ResetScore", -1);
	register_clcmd("say_team /reset", "Cmd@ResetScore", -1);

	register_clcmd("say /resetscore", "Cmd@ResetScore", -1);
	register_clcmd("say_team /resetscore", "Cmd@ResetScore", -1);
}

public Cmd@ResetScore(id)
{
	if((get_user_frags(id) == 0) && (get_user_deaths(id) == 0)) {
		client_color_print(id, "^1* ^4[ResetScore]^1: Scorul tau este deja^4 0^1 -^4 0^1");

		return PLUGIN_HANDLED;
	}

	new iCurrentTime = floatround(get_gametime());
	if(g_iLastReset[id] && (iCurrentTime - g_iLastReset[id] < TIME_INTERVAL)) {
		new iTime = TIME_INTERVAL - (iCurrentTime - g_iLastReset[id]);
		client_color_print(id, "^1* ^4[ResetScore]^1: Mai poti folosii comanda dupa^4 %d min^1 si^4 %02d sec^1", (iTime / 60), (iTime % 60));

		return PLUGIN_HANDLED;
	}

	// These both need to be done twice, otherwise your frags wont until the next round
	cs_set_user_deaths(id, 0);
	set_user_frags(id, 0);
	cs_set_user_deaths(id, 0);
	set_user_frags(id, 0);

	g_iLastReset[id] = iCurrentTime;
	client_color_print(id, "^1* ^4[ResetScore]^1: Scorul tau este acum^4 0^1 -^4 0^1");

	return PLUGIN_HANDLED;
}
