#include <amxmodx>
#include <amxmisc>
#include <engine>

#define DEFAULT_TIME 190.0

enum (<<= 1) {
	GAG_CHAT = 1,
	GAG_TEAMSAY,
	GAG_VOICE
};

enum _:GagData {
	GAG_AUTHID[20],
	GAG_TIME,
	GAG_START,
	GAG_FLAGS
};

new g_szAuthid[33][20];
new g_iThinker, g_iGagged;
new Trie:g_tArrayPos, Array:g_aGagData;

public plugin_init()
{
	register_plugin("Amxx Gag", "1.2", "X");
	
	register_clcmd("say", "CmdSay");
	register_clcmd("say_team", "CmdTeamSay");
	
	register_concmd("amx_gag", "CmdGagPlayer", ADMIN_KICK, "<name>");
	register_concmd("amx_ungag", "CmdUnGagPlayer", ADMIN_KICK, "<name>");
	
	register_message(get_user_msgid("SayText"), "MessageSayText");
	
	new szClassname[] = "gag_thinker";
	
	register_think(szClassname, "FwdThink");
	
	g_tArrayPos = TrieCreate();
	g_aGagData  = ArrayCreate(GagData);
	
	g_iThinker  = create_entity("info_target");
	entity_set_string(g_iThinker, EV_SZ_classname, szClassname);
}

public plugin_end()
{
	TrieDestroy(g_tArrayPos);
	ArrayDestroy(g_aGagData);
}

public client_putinserver(id)
{
	if(CheckGagFlag(id, GAG_VOICE)) {
		set_speak(id, SPEAK_MUTED);
	}
}

public client_authorized(id)
{
	get_user_authid(id, g_szAuthid[id], 19);
}

public client_disconnect(id)
{
	if(TrieKeyExists(g_tArrayPos, g_szAuthid[id])) {
		new szName[32];
		get_user_name(id, szName, 31);
		
		new iPlayers[32], iNum, iPlayer;
		get_players(iPlayers, iNum, "ch");
		
		for(new i=0; i < iNum; i++) {
			iPlayer = iPlayers[i];
			
			if(get_user_flags(iPlayer) & ADMIN_KICK) {
				print(0, "^1* ^4[Gag]^1: ^4%s^1 has disconnected!", szName);
			}
		}
	}
	
	g_szAuthid[id][0] = '^0';
}

public client_infochanged(id)
{
	if(!CheckGagFlag(id,(GAG_CHAT | GAG_TEAMSAY)))
		return;
	
	static const name[] = "name";
	
	static szNewName[32], szOldName[32];
	get_user_info(id, name, szNewName, 31);
	get_user_name(id, szOldName, 31);
	
	if(!equal(szNewName, szOldName)) {
		client_print(id, print_console, "[GAG] Gagged players cannot change their names!");
		set_user_info(id, name, szOldName);
	}
}

public MessageSayText(iMsgId, iDest, iReceiver)
{
	static const Cstrike_Name_Change[] = "#Cstrike_Name_Change";
	
	static szMessage[sizeof(Cstrike_Name_Change) + 1];
	get_msg_arg_string(2, szMessage, sizeof(szMessage) - 1);
	
	if(equal(szMessage, Cstrike_Name_Change)) {
		static szName[32], id;
		
		for(new i = 3; i <= 4; i++) {
			get_msg_arg_string(i, szName, 31);
			id = get_user_index(szName);
			
			if(is_user_connected(id)) {
				if(CheckGagFlag(id, (GAG_CHAT | GAG_TEAMSAY)))
					return PLUGIN_HANDLED;
				
				break;
			}
		}
	}
	
	return PLUGIN_CONTINUE;
}

public FwdThink(iEntity)
{
	if(!g_iGagged)
		return;
	
	new Float:fGametime;
	fGametime = get_gametime();
	
	new data[GagData], id, szName[32];
	for(new i = 0; i < g_iGagged; i++)
	{
		ArrayGetArray(g_aGagData, i, data);
		
		if((Float:data[GAG_START] + Float:data[GAG_TIME] - 0.5) <= fGametime)
		{
			id = find_player("c", data[GAG_AUTHID]);
			
			if(is_user_connected(id)) {
				get_user_name(id, szName, 31);
				
				print(0, "^1* ^4[Gag]^1: ^4%s^1 is no longer gagged", szName);
			}
			
			DeleteGag(i);
			i--;
		}
	}
	
	if(!g_iGagged)
		return;
	
	new Float:flNextTime = 999999.9;
	for(new i = 0; i < g_iGagged; i++) {
		ArrayGetArray(g_aGagData, i, data);
		
		flNextTime = floatmin(flNextTime, Float:data[GAG_START] + Float:data[GAG_TIME]);
	}
	
	entity_set_float(iEntity, EV_FL_nextthink, flNextTime);
}

public CmdSay(id)
{
	return CheckSay(id, 0);
}

public CmdTeamSay(id)
{
	return CheckSay(id, 1);
}

CheckSay(id, bTeam)
{
	static iArrayPos;
	if(TrieGetCell(g_tArrayPos, g_szAuthid[id], iArrayPos)) {
		static data[GagData];
		ArrayGetArray(g_aGagData, iArrayPos, data);
		
		static const iFlags[] = { GAG_CHAT, GAG_TEAMSAY };
		
		if(data[GAG_FLAGS] & iFlags[bTeam]) {
			static const szTeam[][] = {" ", " team "};
			client_print(id, print_center, "* You are gagged from%schat! *", szTeam[bTeam]);
			
			return PLUGIN_HANDLED;
		}
	}
	
	return PLUGIN_CONTINUE;
}

public CmdGagPlayer(id, iLevel, iCid)
{
	if(!cmd_access(id, iLevel, iCid, 2))
		return PLUGIN_HANDLED;
	
	new szArg[32];
	read_argv(1, szArg, 31);
	
	new iPlayer = cmd_target(id, szArg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_NO_BOTS);
	
	if(!iPlayer)
		return PLUGIN_HANDLED;
	
	new szName[20];
	get_user_name(iPlayer, szName, 19);
	
	if(TrieKeyExists(g_tArrayPos, g_szAuthid[iPlayer])) {
		console_print(id, "[Gag] User ^"%s^" is already gagged!", szName);
		
		return PLUGIN_HANDLED;
	}
	
	new szFlags[4], Float:flGagTime;
	read_argv(2, szArg, 31);
	
	if(!szArg[0]) { // No time entered
		flGagTime = DEFAULT_TIME;
		
		formatex(szFlags, 3, "abc");
	} else {
		if(is_str_num(szArg)) { // Seconds entered
			flGagTime = floatstr(szArg);
			
			if(flGagTime > 86400.0) {
				flGagTime = 86400.0;
			}
		} else {
			console_print(id, "[Gag] The value must be in seconds");
			
			return PLUGIN_HANDLED;
		}
		
		read_argv(3, szArg, 31);
		
		if(!szArg[0]) {
			formatex(szFlags, 3, "abc");
		} else {
			formatex(szFlags, 3, szArg);
		}
	}
	
	new iFlags = read_flags(szFlags);
	
	new data[GagData];
	data[GAG_START] = _:get_gametime();
	data[GAG_TIME] = _:flGagTime;
	data[GAG_FLAGS] = iFlags;
	copy(data[GAG_AUTHID], 19, g_szAuthid[iPlayer]);
	
	TrieSetCell(g_tArrayPos, g_szAuthid[iPlayer], g_iGagged);
	ArrayPushArray(g_aGagData, data);
	
	new szFrom[64];
	
	if(iFlags & GAG_CHAT) {
		formatex(szFrom, 63, "say");
	}
	
	if(iFlags & GAG_TEAMSAY) {
		if(!szFrom[0]) {
			formatex(szFrom, 63, "say_team");
		} else {
			format(szFrom, 63, "%s/say_team", szFrom);
		}
	}
	
	if(iFlags & GAG_VOICE) {
		set_speak(iPlayer, SPEAK_MUTED);
		
		if(!szFrom[0]) {
			formatex(szFrom, 63, "voicecomm");
		} else {
			format(szFrom, 63, "%s/voicecomm", szFrom);
		}
	}
	
	g_iGagged++;
	
	new Float:flGametime = get_gametime(), Float:flNextThink;
	flNextThink = entity_get_float(g_iThinker, EV_FL_nextthink);
	
	if(!flNextThink || flNextThink > (flGametime + flGagTime))
		entity_set_float(g_iThinker, EV_FL_nextthink, flGametime + flGagTime);
	
	new szInfo[32], szAdmin[20], iTime = floatround(flGagTime), iMinutes = iTime / 60, iSeconds = iTime % 60;
	get_user_name(id, szAdmin, 19);
	
	if(!iMinutes) {
		formatex(szInfo, 31, "%i sec", iSeconds);
	} else {
		formatex(szInfo, 31, "%i min & %i sec", iMinutes, iSeconds);
	}
	
	print(0, "^1* ^4[Gag]^1: ^4%s^1 has been gagged from speaking for^4[%s]^1 (%s)", szName, szInfo, szFrom);
	
	console_print(id, "[Gag] You have gagged ^"%s^" (%s)", szName, szFrom);
	
	log_amx("Gag: ^"%s<%s>^" has gagged ^"%s<%s>^" for%i minutes. (%s)", szAdmin, g_szAuthid[id], szName, g_szAuthid[iPlayer], floatround(flGagTime / 60), szFrom);
	
	return PLUGIN_HANDLED;
}

public CmdUnGagPlayer(id, iLevel, iCid)
{
	if(!cmd_access(id, iLevel, iCid, 2))
		return PLUGIN_HANDLED;
	
	new szArg[32];
	read_argv(1, szArg, 31);
	
	if(equali(szArg, "@all")) {
		if(!g_iGagged) {
			console_print(id, "[Gag] No gagged players");
			
			return PLUGIN_HANDLED;
		}
		
		while(g_iGagged) DeleteGag(0); // Excellent by Exolent
		
		if(entity_get_float(g_iThinker, EV_FL_nextthink) > 0.0) {
			entity_set_float(g_iThinker, EV_FL_nextthink, 0.0);
		}
		
		console_print(id, "[Gag] You have ungagged all players!");
		
		new szAdmin[32];
		get_user_name(id, szAdmin, 31);
		
		print(0, "^1* ^4[Gag]^1: All players has been ungagged");
		
		log_amx("UnGag: ^"%s<%s>^" has ungagged all players.", szAdmin, g_szAuthid[id]);
		
		return PLUGIN_HANDLED;
	}
	
	new iPlayer = cmd_target(id, szArg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_NO_BOTS);
	
	if(!iPlayer)
		return PLUGIN_HANDLED;
	
	new szName[32];
	get_user_name(iPlayer, szName, 31);
	
	new iArrayPos;
	if(!TrieGetCell(g_tArrayPos, g_szAuthid[iPlayer], iArrayPos)) {
		console_print(id, "[Gag] User ^"%s^" is not gagged!", szName);
		
		return PLUGIN_HANDLED;
	}
	
	DeleteGag(iArrayPos);
	
	new szAdmin[32];
	get_user_name(id, szAdmin, 31);
	
	print(0, "^1* ^4[Gag]^1: ^4%s^1 has been ungagged.", szName);
	
	console_print(id, "[Gag] You have ungagged ^"%s^"", szName);
	
	log_amx("UnGag: ^"%s<%s>^" has ungagged ^"%s<%s>^"", szAdmin, g_szAuthid[id], szName, g_szAuthid[iPlayer]);
	
	return PLUGIN_HANDLED;
}

CheckGagFlag(const id, const iFlag)
{
	static iArrayPos;
	if(TrieGetCell(g_tArrayPos, g_szAuthid[id], iArrayPos)) {
		new data[GagData];
		ArrayGetArray(g_aGagData, iArrayPos, data);
		
		return (data[GAG_FLAGS] & iFlag);
	}
	
	return 0;
}

DeleteGag(iArrayPos)
{
	static data[GagData];
	ArrayGetArray(g_aGagData, iArrayPos, data);
	
	if(data[GAG_FLAGS] & GAG_VOICE) {
		new iPlayer = find_player("c", data[GAG_AUTHID]);
		if(is_user_connected(iPlayer)) {
			set_speak(iPlayer, SPEAK_NORMAL);
		}
	}
	
	TrieDeleteKey(g_tArrayPos, data[GAG_AUTHID]);
	ArrayDeleteItem(g_aGagData, iArrayPos);
	g_iGagged--;
	
	for(new i = iArrayPos; i < g_iGagged; i++) {
		ArrayGetArray(g_aGagData, i, data);
		TrieSetCell(g_tArrayPos, data[GAG_AUTHID], i);
	}
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
