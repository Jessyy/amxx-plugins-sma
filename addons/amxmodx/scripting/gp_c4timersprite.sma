/**
 *	C4 Timer Sprite - gp_c4timersprite.sma
 *	
 *	Based on C4 Timer Sprite v1.1 by cheap_suit from https://forums.alliedmods.net/showthread.php?t=55809?t=55809
 *		@released: 01/06/2007 (dd/mm/yyyy)
 */
#include <amxmodx>
#include <cstrike>
#include <amxmisc>

#define PLUGIN_NAME		"C4 Timer Sprite"
#define PLUGIN_VERSION	"2016.03.19"
#define PLUGIN_AUTHOR	"X"

new g_c4timer
new mp_c4timer

new g_msg_showtimer
new g_msg_roundtime
new g_msg_scenario

#define MAX_SPRITES 2
new const g_timersprite[MAX_SPRITES][] = { "bombticking", "bombticking1" }

public cvar_showteam = 3 // <0|1|3> - Off | T's only | CT's only | ALL (Default: 3)
public cvar_flash = 0 // <0|1> - Sprite Flashing   (Default: 0)
new cvar_sprite   // <0|1> - Czero | Cstrike

public plugin_init() 
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	mp_c4timer = get_cvar_pointer("mp_c4timer")
	
	g_msg_showtimer = get_user_msgid("ShowTimer")
	g_msg_roundtime = get_user_msgid("RoundTime")
	g_msg_scenario = get_user_msgid("Scenario")
	
	register_event("HLTV", "event_hltv", "a", "1=0", "2=0")
	register_logevent("logevent_defusedthebomb", 2, "1=Round_End")
	register_logevent("logevent_plantedthebomb", 3, "2=Planted_The_Bomb")
}

public event_hltv()
{
	g_c4timer = get_pcvar_num(mp_c4timer)
}

public logevent_plantedthebomb()
{
	new showtteam = cvar_showteam
	
	static players[32], num, i
	switch(showtteam)
	{
		case 1: get_players(players, num, "ace", "TERRORIST")
		case 2: get_players(players, num, "ace", "CT")
		case 3: get_players(players, num, "ac")
		default: return
	}
	for(i = 0; i < num; ++i) {
		set_task(1.0, "update_timer_start", players[i])
	}
}

public update_timer_start(id)
{
	if(is_running("cstrike"))
		{ cvar_sprite = 1; } else { cvar_sprite = 0; }
	
	message_begin(MSG_ONE_UNRELIABLE, g_msg_showtimer, _, id)
	message_end()
	
	message_begin(MSG_ONE_UNRELIABLE, g_msg_roundtime, _, id)
	write_short(g_c4timer)
	message_end()
	
	message_begin(MSG_ONE_UNRELIABLE, g_msg_scenario, _, id)
	write_byte(1)
	write_string(g_timersprite[clamp(cvar_sprite, 0, (MAX_SPRITES - 1))])
	write_byte(150)
	write_short(cvar_flash ? 20 : 0)
	message_end()
}

public logevent_defusedthebomb()
{
	new showtteam = cvar_showteam
	
	static players[32], num, i
	switch(showtteam)
	{
		case 1: get_players(players, num, "ace", "TERRORIST")
		case 2: get_players(players, num, "ace", "CT")
		case 3: get_players(players, num, "ac")
		default: return
	}
	for(i = 0; i < num; ++i) set_task(1.0, "update_timer_end", players[i])
}

public update_timer_end(id)
{
	message_begin(MSG_ONE_UNRELIABLE, g_msg_showtimer, _, id)
	message_end()
	
	message_begin(MSG_ONE_UNRELIABLE, g_msg_roundtime, _, id)
	write_short(1)
	message_end()
	
	message_begin(MSG_ONE_UNRELIABLE, g_msg_roundtime, _, id)
	write_short(1)
	message_end()
}
