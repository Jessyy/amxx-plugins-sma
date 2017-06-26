/**
 *	Restart Server - amx_restartserver.sma
 *
 *	Based on Server Restart v2.2 by Hawk552 from https://forums.alliedmods.net/showthread.php?t=23826
 *		@released: 01/01/2006 (dd/mm/yyyy)
 */
#include <amxmodx>
#include <amxplus>

#define PLUGIN_NAME		"Restart Server"
#define PLUGIN_VERSION	"2017.06.17"
#define PLUGIN_AUTHOR	"X"

#define TASK_COUNTDOWN	(100)

enum
{
	SHUTDOWN = 0,
	RESTART = 1
}

new g_szSounds[11][] = {
	"fvox/one.wav",
	"fvox/two.wav",
	"fvox/three.wav",
	"fvox/four.wav",
	"fvox/five.wav",
	"fvox/six.wav",
	"fvox/seven.wav",
	"fvox/eight.wav",
	"fvox/nine.wav",
	"fvox/ten.wav",
	"fvox/warning.wav"
};

new g_iMode, g_iCountDown = 10;

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	register_concmd("amx_restart", "Cmd@RestartServer", ADMIN_RCON, "- restarts the server in 10 seconds");
	register_concmd("amx_shutdown", "Cmd@ShutdownServer", ADMIN_RCON, "- shuts down the server in 10 seconds");
}

public Cmd@RestartServer(id)
{
	return Func@Initiate(id, RESTART);
}

public Cmd@ShutdownServer(id)
{
	return Func@Initiate(id, SHUTDOWN);
}

public Func@Initiate(id, iMode)
{
	if(task_exists(TASK_COUNTDOWN)) {
		return PLUGIN_HANDLED;
	}

	new szText[MAX_INPUT];
	format(szText, charsmax(szText), "ALERTA! SERVER %s!", g_iMode ? "RESTART" : "SHUTDOWN");

	client_cmd(0, "spk %s", g_szSounds[10]);

	client_print(0, print_chat, szText);
	server_print(szText);

	g_iMode = iMode;
	set_task(1.0, "Func@Countdown", TASK_COUNTDOWN, _, _, "b", _);

	return PLUGIN_HANDLED;
}

public Func@Countdown()
{
	new szText[MAX_INPUT];
	switch(g_iCountDown)
	{
		case 1..10: {
			format(szText, charsmax(szText), "Server %s in %d...", g_iMode ? "restart" : "shutdown", g_iCountDown);

			client_cmd(0, "spk %s", g_szSounds[g_iCountDown - 1]);

			client_print(0, print_chat, szText);
			server_print(szText);
		}
		case 0: {
			format(szText, charsmax(szText), "Server %s Down...", g_iMode ? "restart" : "shutdown");

			client_print(0, print_chat, szText);
			server_print(szText);
		}
		default: {
			remove_task(TASK_COUNTDOWN);
			server_cmd((g_iMode)?("reload"):("quit"));
		}
	}

	g_iCountDown--;
}
