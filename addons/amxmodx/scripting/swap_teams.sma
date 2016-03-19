#include <amxmodx>
#include <amxmisc>
#include <cstrike>

new g_Swapped = false;

public plugin_init()
{
	register_plugin("Swap Teams", "1.0", "Jessyy");
	
	register_logevent("eRoundEnd", 2, "1=Round_End");
	register_logevent("eEndRound", 2, "1&Restart_Round_");
	set_task(get_cvar_float("mp_timelimit") * 30, "eTaskTrue", 454500);
}

public plugin_precache()
{
	precache_generic("sound/misc/swap.mp3");
}

public eTaskTrue()
{
	g_Swapped = true;
}

public eRoundEnd()
{
	if(g_Swapped) {
		g_Swapped = false;
		
		for(new id = 1; id <= get_maxplayers(); id++) {
			if(is_user_connected(id) && (cs_get_user_team(id) != CS_TEAM_SPECTATOR)) {
				add_delay(id, "changeTeam");
			}
		}
		
		client_cmd(0, "mp3 play sound/misc/swap.mp3");
		print(0, "^1* ^4[SwapTeams]^1: The teams was successfully ^4swapped^1");
	}
}

public eEndRound()
{
	remove_task(454500);
	set_task(get_cvar_float("mp_timelimit") * 30, "eTaskTrue", 454500);
}

public changeTeam(id)
{
	switch(cs_get_user_team(id))
	{
		case CS_TEAM_CT: cs_set_user_team(id, CS_TEAM_T);
		case CS_TEAM_T: cs_set_user_team(id, CS_TEAM_CT);
	}
	
	static r, g, b;
	if(cs_get_user_team(id) == CS_TEAM_T)
		{r = 255; g = 0; b = 0;}
	else if(cs_get_user_team(id) == CS_TEAM_CT)
		{r = 0; g = 0; b = 255;}
	setScreenFlash(id, r, g, b, 100);
}

stock add_delay(id, const task[])
{
	switch(id)
	{
		case 1..7: set_task(0.1, task, id);
		case 8..15: set_task(0.2, task, id);
		case 16..23: set_task(0.3, task, id);
		case 24..32: set_task(0.4, task, id);
	}
}

stock setScreenFlash(id, r, g, b, alpha)
{
	message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0, 0, 0}, id);
	write_short(1<<10);
	write_short(1<<10);
	write_short(1<<12);
	write_byte(r);
	write_byte(g);
	write_byte(b);
	write_byte(alpha);
	message_end();
}

print(id, const message[], {Float, Sql, Result, _}:...)
{
	static g_msgSayText;
	g_msgSayText = get_user_msgid("SayText");
	
	new Buffer[191];
	vformat(Buffer, sizeof Buffer - 1, message, 3);
	
	if(id) {
		if(!is_user_connected(id))
			return;
		
		message_begin(MSG_ONE, g_msgSayText, _, id);
		write_byte(id);
		write_string(Buffer);
		message_end();
	} else {
		static players[32], count, index;
		get_players(players, count);
		
		for(new i = 0; i < count; i++) {
			index = players[i];
			
			if(!is_user_connected(index))
				continue;
			
			message_begin(MSG_ONE, g_msgSayText, _, index);
			write_byte(index);
			write_string(Buffer);
			message_end();
		}
	}
}
