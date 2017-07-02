/**
 *	C4 Sprite Timer - gp_c4spritetimer.sma
 *
 *	Based on C4 Timer Sprite v1.1 by cheap_suit from https://forums.alliedmods.net/showthread.php?t=55809
 *		@released: 01/06/2007 (dd/mm/yyyy)
 */
#include <amxmodx>
#include <amxplus>
#include <amxmisc>

#define PLUGIN_NAME		"C4 Sprite Timer"
#define PLUGIN_VERSION	"2017.07.02"
#define PLUGIN_AUTHOR	"X"

#define MAX_SPRITES		(2)

enum _:E_INFOTYPE
{
	E_SPRITETIMER,
	E_SPRITEFLASH,
	E_SPRITEMODEL,
	E_C4TIMER
};

new const g_szSprites[MAX_SPRITES][] = {
	"bombticking",
	"bombticking1"
};

new g_pSpriteTimer, g_pSpriteModel, g_pSpriteFlash, g_pMsgShowTimer, g_pMsgRoundRime, g_pMsgScenario, g_pC4Timer;
new g_iPlayers[MAX_PLAYERS], g_iCount;

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	g_pSpriteTimer = register_cvar("amx_sprite_timer", "3");	// <0/1/2/3> - off / t's only / ct's only / all
	g_pSpriteModel = register_cvar("amx_sprite_model", "1");	// <0/1> - sprite model
	g_pSpriteFlash = register_cvar("amx_sprite_flash", "0");	// <0/1> - turn on / off the sprite flashing

	g_pMsgShowTimer = get_user_msgid("ShowTimer");
	g_pMsgRoundRime = get_user_msgid("RoundTime");
	g_pMsgScenario = get_user_msgid("Scenario");

	register_logevent("Event@BombPlanted", 3, "2=Planted_The_Bomb");
	register_logevent("Event@RoundEnd", 2, "1=Round_End");

	g_pC4Timer = get_cvar_pointer("mp_c4timer");
}

public Event@BombPlanted()
{
	new iArgs[E_INFOTYPE];
	iArgs[E_SPRITETIMER] = get_pcvar_num(g_pSpriteTimer);

	switch(iArgs[E_SPRITETIMER])
	{
		case 1: {
			get_players(g_iPlayers, g_iCount, "ace", "TERRORIST");
		}
		case 2: {
			get_players(g_iPlayers, g_iCount, "ace", "CT");
		}
		case 3: {
			get_players(g_iPlayers, g_iCount, "ac");
		}
		default: {
			return;
		}
	}

	iArgs[E_SPRITEMODEL] = get_pcvar_num(g_pSpriteModel);
	iArgs[E_SPRITEFLASH] = get_pcvar_num(g_pSpriteFlash);
	iArgs[E_C4TIMER] = get_pcvar_num(g_pC4Timer);

	for(new i = 0; i < g_iCount; i++) {
		set_task(1.0, "Timer@Start", g_iPlayers[i], iArgs, sizeof(iArgs));
	}
}

public Event@RoundEnd()
{
	for(new i = 0; i < g_iCount; i++) {
		set_task(1.0, "Timer@End", g_iPlayers[i]);
	}
}

public Timer@Start(iParams[], iTask)
{
	message_begin(MSG_ONE_UNRELIABLE, g_pMsgShowTimer, _, iTask);
	message_end();

	message_begin(MSG_ONE_UNRELIABLE, g_pMsgRoundRime, _, iTask);
	write_short(iParams[E_C4TIMER]);
	message_end();

	message_begin(MSG_ONE_UNRELIABLE, g_pMsgScenario, _, iTask);
	write_byte(1);
	write_string(g_szSprites[clamp(is_running("czero") ? 0 : iParams[E_SPRITEMODEL], 0, MAX_SPRITES - 1)]);
	write_byte(150);
	write_short(iParams[E_SPRITEFLASH] ? 20 : 0);
	message_end();
}

public Timer@End(iTask)
{
	message_begin(MSG_ONE_UNRELIABLE, g_pMsgShowTimer, _, iTask);
	message_end();

	message_begin(MSG_ONE_UNRELIABLE, g_pMsgRoundRime, _, iTask);
	write_short(1);
	message_end();

	message_begin(MSG_ONE_UNRELIABLE, g_pMsgRoundRime, _, iTask);
	write_short(1);
	message_end();
}
