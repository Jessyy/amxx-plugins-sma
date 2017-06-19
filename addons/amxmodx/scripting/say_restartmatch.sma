/**
 *	Restart Match - say_restartmatch.sma
 *
 *	Based on Round Restart v2.2 by Dorin from https://forums.alliedmods.net/showthread.php?p=798354
 *		@released: 22/05/2011 (dd/mm/yyyy)
 */
#include <amxmodx>
#include <amxplus>

#define PLUGIN_NAME		"Restart Match"
#define PLUGIN_VERSION	"2016.03.19"
#define PLUGIN_AUTHOR	"X"

// How many seconds must pass before players can restart the round again
#define TIME_INTERVAL	(10)

new g_iLastRestart[MAX_PLAYERS];

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	register_clcmd("say /restart", "Cmd@RestartMatch", ADMIN_SLAY);
}

public Cmd@RestartMatch(id)
{
	new iCurrentTime = floatround(get_gametime());
	if(g_iLastRestart[id] && (iCurrentTime - g_iLastRestart[id] < TIME_INTERVAL)) {
		new iTime = TIME_INTERVAL - (iCurrentTime - g_iLastRestart[id]);
		client_color_print(id, "^1* ^4[Restart]^1: Mai poti folosii comanda dupa^4 %d min^1 si^4 %02d sec^1", (iTime / 60), (iTime % 60));

		return PLUGIN_HANDLED;
	}

	server_cmd("sv_restart 1");

	g_iLastRestart[id] = iCurrentTime;
	set_hudmessage(255, 150, 0, 0.04, 0.47, 0, 6.0, 7.0);
	for(new i = 0; i < 5; i++) {
		show_hudmessage(0, "Live ! Live ! Live ! GL & HF !" );
		client_print(0, print_chat, "[---------LIVE!---------]");
	}

	return PLUGIN_HANDLED;
}
