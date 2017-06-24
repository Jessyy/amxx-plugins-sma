/*
 *	Multikll Sounds - gp_multikllsounds.sma
 *
 *	Based on Ultimate KillStreak Advanced v0.7 by Samurai from https://forums.alliedmods.net/showthread.php?t=416080
 *		@released: 07/04/2007 (dd/mm/yyyy)
 */
#include <amxmodx>
#include <amxplus>

#define PLUGIN_NAME		"Multikill Sounds"
#define PLUGIN_VERSION	"2017.06.24"
#define PLUGIN_AUTHOR	"X"

#define MAX_LEVELS		(7)

new g_szSounds[][] = {
	"misc/multikill.wav",
	"misc/ultrakill.wav",
	"misc/monsterkill.wav",
	"misc/killingspree.wav",
	"misc/rampage.wav",
	"misc/holyshit.wav",
	"misc/godlike.wav",
	"misc/headshot.wav",
	"misc/humiliation.wav",
	"misc/mkqclastplace.wav"
};

new g_iLevels[MAX_LEVELS] = {
	3,
	5,
	7,
	9,
	11,
	13,
	15
};

new g_szMessages[MAX_LEVELS][] = {
	"Multi-Kill: %s",
	"Ultra-Kill: %s",
	"Monster-Kill: %s",
	"Killing Spree: %s",
	"Rampage: %s",
	"Holy Shit: %s",
	"Godlike: %s"
};

enum _:E_INFOTYPE
{
	E_NAME[MAX_NAME_LENGTH],
	E_KILLS,
	E_DEATHS,
	E_HEALTH
};

new iData[MAX_PLAYERS][E_INFOTYPE];

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	register_event("DeathMsg", "Func@MultiKill", "a");
	register_event("DeathMsg", "Func@Headshot", "a", "3=1");
	register_event("DeathMsg", "Func@KnifeKill", "a", "4&kni");
	register_event("DeathMsg", "Func@GrenadeKill", "a", "4&gren");
	register_event("DeathMsg", "Func@LastStanding", "a");
}

public plugin_precache()
{
	if(is_precache_enabled()) {
		for(new i=0, j=sizeof(g_szSounds); i < j; i++) {
			precache_sound(g_szSounds[i]);
		}
	}
}

public client_connect(id)
{
	iData[id][E_KILLS] = 0;
	iData[id][E_DEATHS] = 0;
}

public Func@MultiKill(id)
{
	new iKiller = read_data(1);
	new iVictim = read_data(2);

	iData[iKiller][E_KILLS] += 1;
	iData[iKiller][E_DEATHS] = 0;

	iData[iVictim][E_KILLS] = 0;
	iData[iVictim][E_DEATHS] += 1;

	for(new i = 0; i < MAX_LEVELS; i++) {
		if(g_iLevels[i] == iData[iKiller][E_KILLS]) {
			get_user_name(iKiller, iData[iKiller][E_NAME], MAX_NAME_LENGTH - 1);

			set_hudmessage(0, 80, 220, 0.05, 0.55, 2, 0.02, 7.0, 0.01, 0.1, 2);
			show_hudmessage(0, g_szMessages[i], iData[iKiller][E_NAME]);

			client_cmd(iKiller, "spk %s", g_szSounds[i]);

			return PLUGIN_CONTINUE;
		}
	}

	return PLUGIN_CONTINUE;
}

public Func@Headshot(id)
{
	new iKiller = read_data(1);
	new iVictim = read_data(2);

	client_cmd(iKiller, "spk %s", g_szSounds[7]);
	client_print(iVictim, print_center, ">>> H.E.A.D - S.H.O.T <<<");

	return PLUGIN_CONTINUE;
}

public Func@KnifeKill(id)
{
	new iKiller = read_data(1);

	client_cmd(iKiller, "spk %s", g_szSounds[8]);

	return PLUGIN_CONTINUE;
}

public Func@GrenadeKill(id)
{
	new iKiller = read_data(1);
	new iVictim = read_data(2);

	if(iKiller == iVictim) {
		client_cmd(iVictim, "spk %s", g_szSounds[9]);
	}

	return PLUGIN_CONTINUE;
}

public Func@LastStanding()
{
	new iPlayersT[MAX_PLAYERS], iNumT, iPlayersCT[MAX_PLAYERS], iNumCT;

	get_players(iPlayersT, iNumT, "ae", "TERRORIST");
	get_players(iPlayersCT, iNumCT, "ae", "CT");

	if(iNumT == 1 && iNumCT == 1) {
		iNumT = iPlayersT[0];
		iNumCT = iPlayersCT[0];

		get_user_name(iNumT, iData[iNumT][E_NAME], MAX_NAME_LENGTH - 1);
		get_user_name(iNumCT, iData[iNumCT][E_NAME], MAX_NAME_LENGTH - 1);

		iData[iNumT][E_HEALTH] = get_user_health(iNumT);
		iData[iNumCT][E_HEALTH] = get_user_health(iNumCT);

		new szMessage[MAX_INPUT], iLenght;

		iLenght += format(szMessage[iLenght], charsmax(szMessage) - iLenght, "%s (%i HP)", iData[iNumT][E_NAME], iData[iNumT][E_HEALTH]);
		iLenght += format(szMessage[iLenght], charsmax(szMessage) - iLenght, "^n^n.V.S.^n^n");
		iLenght += format(szMessage[iLenght], charsmax(szMessage) - iLenght, "%s (%i HP)", iData[iNumCT][E_NAME], iData[iNumCT][E_HEALTH]);

		engclient_print(iNumT, engprint_center, szMessage);
		engclient_print(iNumCT, engprint_center, szMessage);
	}

	return PLUGIN_CONTINUE;
}
