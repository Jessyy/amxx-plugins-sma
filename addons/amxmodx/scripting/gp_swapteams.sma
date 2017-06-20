/**
 *	Swap Teams - gp_swapteams.sma
 *
 *	Based on Auto Swap Teams v1.6 by Lo3 from https://forums.alliedmods.net/showthread.php?t=90898
 *		@released: 08/11/2012 (dd/mm/yyyy)
 */
#include <amxmodx>
#include <amxplus>
#include <cstrike>

#define PLUGIN_NAME		"Swap Teams"
#define PLUGIN_VERSION	"2017.06.18"
#define PLUGIN_AUTHOR	"X"

#define TASK_TEAMSWAP	(454500)

new g_szSound[] = "misc/swap.mp3";

new g_iMaxPlayers, g_bTeamSwap = false;

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	set_task(get_cvar_float("mp_timelimit") * 30, "Task@EnableSwap", TASK_TEAMSWAP);

	register_logevent("Event@RoundEnd", 2, "1=Round_End");
	register_logevent("Event@RestartRound", 2, "1&Restart_Round_");

	g_iMaxPlayers = get_maxplayers();
}

public plugin_precache()
{
	if(get_cvar_num("sv_allowprecache")) {
		precache_sound(g_szSound);
	}
}

public Task@EnableSwap()
{
	g_bTeamSwap = true;
}

public Event@RoundEnd()
{
	if(g_bTeamSwap) {
		for(new i = 1; i <= g_iMaxPlayers; i++) {
			if(is_user_connected(i) && (cs_get_user_team(i) != CS_TEAM_SPECTATOR)) {
				set_task(0.2, "Func@ChangeTeam", i);
			}
		}

		client_cmd(0, "mp3 play %s", g_szSound);

		client_color_print(0, "^1* ^4[SwapTeams]^1: The teams was successfully ^4swapped^1");

		g_bTeamSwap = false;
	}
}

public Event@RestartRound()
{
	remove_task(TASK_TEAMSWAP);
	set_task(get_cvar_float("mp_timelimit") * 30, "Task@EnableSwap", TASK_TEAMSWAP);
}

public Func@ChangeTeam(id)
{
	switch(cs_get_user_team(id))
	{
		case CS_TEAM_CT: {
			cs_set_user_team(id, CS_TEAM_T);
		}
		case CS_TEAM_T: {
			cs_set_user_team(id, CS_TEAM_CT);
		}
	}

	new iRed, iGreen, iBlue, iAlpha;
	if(cs_get_user_team(id) == CS_TEAM_T) {
		iRed = 255; iGreen = 0; iBlue = 0; iAlpha = 100;
	}
	else if(cs_get_user_team(id) == CS_TEAM_CT) {
		iRed = 0; iGreen = 0; iBlue = 255; iAlpha = 100;
	}
	Func@FlashScreen(id, iRed, iGreen, iBlue, iAlpha);
}

stock Func@FlashScreen(id, iRed, iGreen, iBlue, iAlpha)
{
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), {0, 0, 0}, id);
	write_short((1<<10));
	write_short((1<<10));
	write_short((1<<12));
	write_byte(iRed);
	write_byte(iGreen);
	write_byte(iBlue);
	write_byte(iAlpha);
	message_end();
}
