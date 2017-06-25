/**
 *	C4 Timer Sprite - gp_c4timersprite.sma
 *
 *	Based on C4 Timer Sprite v1.1 by cheap_suit from https://forums.alliedmods.net/showthread.php?t=55809
 *		@released: 01/06/2007 (dd/mm/yyyy)
 */
#include <amxmodx>
#include <amxplus>
#include <amxmisc>

#define PLUGIN_NAME		"C4 Timer Sprite"
#define PLUGIN_VERSION	"2017.06.25"
#define PLUGIN_AUTHOR	"X"

#define MAX_SPRITES		(2)

new const g_szSprite[MAX_SPRITES][] = {
	"bombticking",
	"bombticking1"
};

new g_pSpriteTimer, g_pSpriteFlash, g_pSpriteModel, g_pMsgShowTimer, g_pMsgRoundRime, g_pMsgScenario, g_pC4Timer;

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	g_pSpriteTimer = register_cvar("amx_sprite_timer", "3");	// <0/1/2/3> - off / t's only / ct's only / all
	g_pSpriteFlash = register_cvar("amx_sprite_flash", "0");	// <0/1> - turn on / off the sprite flashing
	g_pSpriteModel = register_cvar("amx_sprite_model", "1");	// <0/1> - sprite model

	g_pMsgShowTimer = get_user_msgid("ShowTimer");
	g_pMsgRoundRime = get_user_msgid("RoundTime");
	g_pMsgScenario = get_user_msgid("Scenario");

	register_logevent("Event@BombPlanted", 3, "2=Planted_The_Bomb");
	register_logevent("Event@RoundEnd", 2, "1=Round_End");

	g_pC4Timer = get_cvar_pointer("mp_c4timer");
}

public Event@BombPlanted()
{
	static iPlayers[MAX_PLAYERS], iCount;
	switch(get_pcvar_num(g_pSpriteTimer))
	{
		case 1: {
			get_players(iPlayers, iCount, "ace", "TERRORIST");
		}
		case 2: {
			get_players(iPlayers, iCount, "ace", "CT");
		}
		case 3: {
			get_players(iPlayers, iCount, "ac");
		}
		default: {
			return;
		}
	}

	for(new i = 0; i < iCount; i++) {
		set_task(0.5, "Timer@Start", iPlayers[i]);
	}
}

public Timer@Start(id)
{
	message_begin(MSG_ONE_UNRELIABLE, g_pMsgShowTimer, _, id);
	message_end();

	message_begin(MSG_ONE_UNRELIABLE, g_pMsgRoundRime, _, id);
	write_short(get_pcvar_num(g_pC4Timer));
	message_end();

	message_begin(MSG_ONE_UNRELIABLE, g_pMsgScenario, _, id);
	write_byte(1);
	write_string(g_szSprite[clamp(is_running("czero") ? 0 : get_pcvar_num(g_pSpriteModel), 0, MAX_SPRITES - 1)]);
	write_byte(150);
	write_short(get_pcvar_num(g_pSpriteFlash) ? 20 : 0);
	message_end();
}

public Event@RoundEnd()
{
	static iPlayers[MAX_PLAYERS], iCount;
	switch(get_pcvar_num(g_pSpriteTimer))
	{
		case 1: {
			get_players(iPlayers, iCount, "ace", "TERRORIST");
		}
		case 2: {
			get_players(iPlayers, iCount, "ace", "CT");
		}
		case 3: {
			get_players(iPlayers, iCount, "ac");
		}
		default: {
			return;
		}
	}

	for(new i = 0; i < iCount; i++) {
		set_task(0.5, "Timer@End", iPlayers[i]);
	}
}

public Timer@End(id)
{
	message_begin(MSG_ONE_UNRELIABLE, g_pMsgShowTimer, _, id);
	message_end();

	message_begin(MSG_ONE_UNRELIABLE, g_pMsgRoundRime, _, id);
	write_short(1);
	message_end();

	message_begin(MSG_ONE_UNRELIABLE, g_pMsgRoundRime, _, id);
	write_short(1);
	message_end();
}
