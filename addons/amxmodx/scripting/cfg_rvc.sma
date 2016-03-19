#include <amxmodx>

public toggle_mode		= 6	//0/1/2/3/4/5/6	- Dezactivat / Activat cel in chat / Activat doar cel in hud / Amandoua activate(hud & chat) / Activat cel in chat [fara hostname] / Activat cel can Czero / Activat cel can Czero TimeLeft && NextMap
public toggle_rvc		= 2	//0/1/2		- Dezactivat / Activat simplu / Activat simplu + efect
public toggle_alternative	= 1	//0/1		- Dezactivat / Activat sunet alternativ precum FIGHT, PLAY (necesita descarcare)
public toggle_as		= 1	//1/2/3		- Activat doar sunet / Activat doar msg pe centru / Activate amandoua
public toggle_block		= 1	//0/1		- Dezactivat / Activat - Blocheaza sunetul de inceput de runda, cel automatic gen LOCKNLOAD, LETSGO
public toggle_alb		= 1	//0/1		- Dezactivat / Activat - Cand intra pe server i se schimba culoarea chatului in alb

#define TASK_MESSAGE 11100

new const msg[][] = {
	">>> PLAY <<<",
	"<<< FIGHT >>>",
	"<<< P.L.A.Y >>>"
};

new const sound[][] = {
	"misc/sexy_play",
	"misc/mkfight",
	"misc/ut/play"
};

new const startroundsounds[][] = {
	"%!MRAD_LOCKNLOAD",
	"%!MRAD_MOVEOUT",
	"%!MRAD_LETSGO",
	"%!MRAD_GO"
};

new Float:g_RoundStartTime, g_Round = 0;

public plugin_init() 
{
	register_plugin("Round Voice Counter", "1.0.0", "X")

	register_logevent("eRoundStart", 2, "1=Round_Start")
	register_message(get_user_msgid("SendAudio"), "msg_SendAudio")
	register_event("HLTV", "new_round", "a", "1=0", "2=0")
	register_event("TextMsg", "round_restart", "a", "2&#Game_C", "2&#Game_w")
}

public plugin_precache()
{
	precache_sound("misc/sexy_play.wav");
	precache_sound("misc/mkfight.wav");
	precache_sound("misc/ut/play.wav");
	
	precache_generic("gfx/career/icon_!.tga");
	precache_generic("gfx/career/icon_!-bigger.tga");
	precache_generic("gfx/career/icon_i.tga");
	precache_generic("gfx/career/icon_i-bigger.tga");
	precache_generic("gfx/career/icon_skulls.tga");
	precache_generic("gfx/career/round_corner_ne.tga");
	precache_generic("gfx/career/round_corner_nw.tga");
	precache_generic("gfx/career/round_corner_se.tga");
	precache_generic("gfx/career/round_corner_sw.tga");
	
	precache_generic("resource/tutorscheme.res");
	precache_generic("resource/UI/tutortextwindow.res");
}

public client_connect(id)
{
	if(toggle_alb != 0) {
		client_cmd(id, "con_color ^"255+255+255^"")
	}
}

public new_round()
{
	++g_Round;
	
	switch(toggle_mode)
	{
		case 0: // Dezactivat
		{
			return PLUGIN_CONTINUE;
		}
		
		case 1: // Activat cel in chat
		{
			new mapname[32], hostname[64];
			get_mapname(mapname, 31);
			get_cvar_string("hostname", hostname, 63);
			
			new players = get_playersnum();
			new maxplayers = get_maxplayers();
			
			print(0, "^1-<[Round:^4 %d^1]>---<[Hostname:^3 %s^1]>---<[Map:^4 %s^1]>---<[Players:^4 %d/%d^1]>-", g_Round, hostname, mapname, players, maxplayers);
		}
		
		case 2: //Activat doar cel in hud
		{
			set_hudmessage(255, 0, 0, -1.0, 0.18, 2, 0.01, 12.0, 0.01, 0.01, 5);
			show_hudmessage(0, "Prepare to Fight^nRound %d", g_Round);
		}
		
		case 3: // Amandoua activate(hud & chat)
		{
			new mapname[32], hostname[64];
			get_mapname(mapname, 31);
			get_cvar_string("hostname", hostname, 63);
			
			new players = get_playersnum();
			new maxplayers = get_maxplayers();
			
			print(0, "^1-<[Round:^4 %d^1]>---<[Hostname:^4 %s^1]>---<[Map:^4 %s^1]>---<[Players:^4 %d/%d]^1>-", g_Round, hostname, mapname, players, maxplayers);
			
			set_hudmessage(0, 255, 0, -1.0, 0.12, 2, 0.01, 12.0, 0.01, 0.01, 3);
			show_hudmessage(0, "Prepare to Fight^nRound %d", g_Round);
		}
		
		case 4: // Activat cel in chat [fara hostname]
		{
			new mapname[32];
			get_mapname(mapname, 31);
			
			new players = get_playersnum();
			new maxplayers = get_maxplayers();
			
			print(0, "^1*^4 [RoundStart]^1: -<[Round:^4 %d^1]>---<[Map:^4 %s^1]>---<[Players:^4 %d/%d^1]>-", g_Round, mapname, players, maxplayers);
		}
		case 5: // Activat cel can Czero
		{
			new mapname[32];
			get_mapname(mapname, 31);
			
			new players = get_playersnum();
			new maxplayers = get_maxplayers();
			
			printe(0, "Round Start: %d | Map: %s | Players: %d/%d", g_Round, mapname, players, maxplayers);
		}
		
		case 6: // Activat cel can Czero cu Time Left && Next Map
		{
			new mapname[32], nextmap[32];
			get_mapname(mapname, 31);
			get_cvar_string("amx_nextmap", nextmap, 31);
			
			new timeleft = get_timeleft();
			new players = get_playersnum();
			new maxplayers = get_maxplayers();
			
			if(timeleft > 0) {
				printe(0, "Round Start: %d | Map: %s | Players: %d/%d^nTime Left: %d:%02d min | Next Map: %s", g_Round, mapname, players, maxplayers, timeleft/60, timeleft%60, nextmap);
			} else {
				printe(0, "Round Start: %d | Map: %s | Players: %d/%d^nNo Time Limit | Next Map: %s", g_Round, mapname, players, maxplayers, nextmap);
			}
		}
	}
	
	switch(toggle_rvc)
	{
		case 0:
		{
			return PLUGIN_CONTINUE;
		}
		
		case 1:
		{
			new rvc[32];
			num_to_word(g_Round, rvc, 31);
			client_cmd(0, "spk ^"vox/round %s^"", rvc);
		}
		
		case 2:
		{
			new rvc[32];
			num_to_word(g_Round, rvc, 31);
			client_cmd(0, "spk ^"vox/round %s^" ", rvc);
			client_cmd(0, "spk ^"ambience/3dmstart.wav^"");
		}
	}
	
	if(toggle_alternative != 0) {
		set_task(2.0, "alternative_sound");
		set_cvar_string("mp_freezetime", "2");
	}
	
	return PLUGIN_CONTINUE;
}

public alternative_sound()
{
	switch(toggle_as)
	{
		case 1:
		{
			new w = random_num(0, sizeof sound -1);
			client_cmd(0, "spk %s", sound[w]);
		}
		
		case 2:
		{
			new q = random_num(0, sizeof msg - 1);
			client_print(0,print_center, msg[q]);
		}
		
		case 3:
		{
			new q = random_num(0, sizeof msg - 1);
			client_print(0,print_center, msg[q]);
			new w = random_num(0, sizeof sound -1);
			client_cmd(0, "spk %s", sound[w]);
		}
	}
}

public round_restart()
{
	g_Round = 0;
}

public eRoundStart()
{
	g_RoundStartTime = get_gametime();
}

public msg_SendAudio(msg_id, msg_dest, msg_entity)
{
	if(get_gametime() != g_RoundStartTime || toggle_block == 0)
		return PLUGIN_CONTINUE;
	
	new arg2[18];
	get_msg_arg_string(2, arg2, 17);
	
	for(new i = 0; i < 4; i++) {
		if(equal(arg2, startroundsounds[i]))
			return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
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

printe(id, const szMsg[], {Float, Sql, Result, _}:...)
{
	new Buffer[191];
	vformat(Buffer, sizeof Buffer -1, szMsg, 3);
	
	if(id) {
		if(!is_user_connected(id))
			return;
		
		message_begin(MSG_ONE, get_user_msgid("TutorClose"), {0, 0, 0}, id);
		message_end();
		
		message_begin(MSG_ONE, get_user_msgid("TutorText"), {0, 0, 0}, id);
		write_string(Buffer);
		write_byte(0);
		write_short(0);
		write_short(0);
		write_short(16);
		message_end();
		
		remove_task(id + TASK_MESSAGE);
		set_task(8.0, "reset_message", id + TASK_MESSAGE);
	} else {
		static players[32], count, index;
		get_players(players, count);
		
		for(new i = 0; i < count; i++)
		{
			index = players[i];
			
			if(!is_user_connected(index))
				continue;
			
			message_begin(MSG_ONE, get_user_msgid("TutorClose"), {0, 0, 0}, index);
			message_end();
			
			message_begin(MSG_ONE, get_user_msgid("TutorText"), {0, 0, 0}, index);
			write_string(Buffer);
			write_byte(0);
			write_short(0);
			write_short(0);
			write_short(16);
			message_end();
			
			remove_task(index + TASK_MESSAGE);
			set_task(8.0, "reset_message", index + TASK_MESSAGE);
		}
	}
}

public reset_message(id)
{
	id -= TASK_MESSAGE;
	message_begin(MSG_ONE, get_user_msgid("TutorClose"), {0, 0, 0}, id);
	message_end();
}
