#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <fakemeta>
#include <fakemeta_util>

public plugin_init() 
{
	register_plugin("AMX Transfer", "1.0", "X")
	
	register_concmd("amx_team", "cmd_transfer", ADMIN_SLAY, "<name> <T|CT|Spec>")
	register_concmd("amx_swap", "cmd_swap", ADMIN_SLAY, "<name> <name>")
	register_concmd("amx_teamswap", "cmd_teamswap", ADMIN_RCON, "Swaps two teams with eachother")
	register_clcmd("say /teamswap", "cmd_teamswap", ADMIN_RCON, "Swaps two teams with eachother")
}

public cmd_transfer(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2)) 
		return PLUGIN_HANDLED;
	
	new arg1[32], arg2[32], teamname[32]
	read_argv(1, arg1, 31); read_argv(2, arg2, 31)
	new player = cmd_target(id, arg1, 2)
	
	if(!player)
		return PLUGIN_HANDLED
	
	if(!strlen(arg2)) {
		if(fm_find_ent_by_owner(-1, "weapon_c4", player))
			{ new iTeammate = FindTeammate(player); fm_transfer_user_gun(player, iTeammate, CSW_C4); }
		
		cs_set_user_team(player, cs_get_user_team(player) == CS_TEAM_CT ? CS_TEAM_T:CS_TEAM_CT)
		teamname = cs_get_user_team(player) == CS_TEAM_CT ? "Counter-Terrorists" : "Terrorists"
	} else {
		if(equali(arg2, "T") || equali(arg2, "1")) {
			if(fm_find_ent_by_owner(-1, "weapon_c4", player))
				{ new iTeammate = FindTeammate(player); fm_transfer_user_gun(player, iTeammate, CSW_C4); }
			
			cs_set_user_team(player, CS_TEAM_T); teamname = "Terrorists"
		}
		else if(equali(arg2, "CT") || equali(arg2, "2")) {
			if(fm_find_ent_by_owner(-1, "weapon_c4", player))
				{ new iTeammate = FindTeammate(player); fm_transfer_user_gun(player, iTeammate, CSW_C4); }
			
			cs_set_user_team(player, CS_TEAM_CT); teamname = "Counter-Terrorists"
		}
		else if(equali(arg2, "SPEC") || equali(arg2, "3")) {
			if(fm_find_ent_by_owner(-1, "weapon_c4", player))
				{ new iTeammate = FindTeammate(player); fm_transfer_user_gun(player, iTeammate, CSW_C4); }
			
			user_silentkill(player); cs_set_user_team(player, CS_TEAM_SPECTATOR); teamname = "Spectator"
		}
		else {
			console_print(id, "[TeamTransfer] Invalid team specified! Valid teams are: T|1, CT|2 and Spec|3")
			return PLUGIN_HANDLED;
		}
	}
	
	static r, g, b
	if(cs_get_user_team(player) == CS_TEAM_T)
		{ r = 255; g = 0; b = 0; }
	else if(cs_get_user_team(player) == CS_TEAM_CT)
		{ r = 0; g = 0; b = 255; }
	else
		{ r = 255; g = 255; b = 255; }
	setScreenFlash(player, r, g, b, 100)
	
	new name[32];
	get_user_name(player, name, 31)
	
	console_print(id, "[TeamTransfer] You have Successfully transfered %s to the %s", name, teamname)
	print(player, "^1* ^4[TeamTransfer]^1: You have been transfered to the ^4%s^1", teamname)
	
	return PLUGIN_HANDLED;
}

public cmd_swap(id, level, cid) 
{
	if(!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED;
	
	new arg1[32], arg2[32]
	
	read_argv(1, arg1, 31)
	read_argv(2, arg2, 31)
	
	new player1 = cmd_target(id, arg1, 2)
	new player2 = cmd_target(id, arg2, 2)
	
	if(!player1 || !player2)
		return PLUGIN_HANDLED
	
	new CsTeams:team1 = cs_get_user_team(player1)
	new CsTeams:team2 = cs_get_user_team(player2)
	
	if(team1 == team2) {
		console_print(id, "[TeamTransfer] You can't swap players that are on the same team")
		return PLUGIN_HANDLED
	}
	
	if(team1 == CS_TEAM_UNASSIGNED || team2 == CS_TEAM_UNASSIGNED) {
		console_print(id, "[TeamTransfer] You can't swap players that are not in a team")
		return PLUGIN_HANDLED
	}
	
	if(team1 == CS_TEAM_SPECTATOR) {
		user_silentkill(player2)
	}
	else if(team2 == CS_TEAM_SPECTATOR) {
		user_silentkill(player1)
	}
	
	if(fm_find_ent_by_owner(-1, "weapon_c4", player1))
		{ new iTeammate = FindTeammate(player1); fm_transfer_user_gun(player1, iTeammate, CSW_C4); }
	else if(fm_find_ent_by_owner(-1, "weapon_c4", player2))
		{ new iTeammate = FindTeammate(player2); fm_transfer_user_gun(player2, iTeammate, CSW_C4); }
	
	static r1, g1, b1; static r2, g2, b2
	
	cs_set_user_team(player1, team2)
	if(cs_get_user_team(player1) == CS_TEAM_T)
		{ r1 = 255; g1 = 0; b1 = 0; }
	else if(cs_get_user_team(player1) == CS_TEAM_CT)
		{ r1 = 0; g1 = 0; b1 = 255; }
	else
		{ r1 = 255; g1 = 255; b1 = 255; }
	setScreenFlash(player1, r1, g1, b1, 100)
	
	cs_set_user_team(player2, team1)
	if(cs_get_user_team(player2) == CS_TEAM_T)
		{ r2 = 255; g2 = 0; b2 = 0; }
	else if(cs_get_user_team(player2) == CS_TEAM_CT)
		{ r2 = 0; g2 = 0; b2 = 255; }
	else
		{ r2 = 255; g2 = 255; b2 = 255; }
	setScreenFlash(player2, r2, g2, b2, 100)
	
	new name1[32], name2[32]
	get_user_name(player1, name1, 31)
	get_user_name(player2, name2, 31)
	
	console_print(id, "[TeamTransfer] Successfully swapped %s with %s", name1, name2)
	print(player1, "^1* ^4[TeamTransfer]^1: You have been swapped with ^4%s^1", name2)
	print(player2, "^1* ^4[TeamTransfer]^1: You have been swapped with ^4%s^1", name1)
	
	return PLUGIN_HANDLED;
}

public cmd_teamswap(id, level, cid)
{
	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED;
	
	new players[32], num
	get_players(players, num)
	
	new player
	for(new i = 0; i < num; i++)
	{
		player = players[i]
		
		if(cs_get_user_team(player) != CS_TEAM_SPECTATOR) {
			if(fm_find_ent_by_owner(-1, "weapon_c4", player))
				{ new iTeammate = FindTeammate(player); fm_transfer_user_gun(player, iTeammate, CSW_C4); }
			
			add_delay(player, "changeTeam")
		}
	}
	
	console_print(id, "[TeamTransfer] You have successfully swapped the teams")
	
	print(0, "^1* ^4[TeamTransfer]^1: The teams was successfully ^4swapped^1")
	
	return PLUGIN_HANDLED
}

public changeTeam(id)
{
	switch(cs_get_user_team(id))
	{
		case CS_TEAM_CT: cs_set_user_team(id, CS_TEAM_T)
		case CS_TEAM_T: cs_set_user_team(id, CS_TEAM_CT)
	}
	
	static r, g, b
	if(cs_get_user_team(id) == CS_TEAM_T)
		{ r = 255; g = 0; b = 0; }
	else if(cs_get_user_team(id) == CS_TEAM_CT)
		{ r = 0; g = 0; b = 255; }
	else
		{ r = 255; g = 255; b = 255; }
	setScreenFlash(id, r, g, b, 100)
}

public FindTeammate(id)
{
	new Float: fOriginBomb1[3]
	new Float: fOriginBomb2[3]
	new Float: fMinDist = 99999.0
	new Float: fDist
	new iTeammate
	
	new iPlayers[32]
	new iPlayersNum
	new iPlayer
	
	pev(id, pev_origin, fOriginBomb1)
	get_players(iPlayers, iPlayersNum)
	if (!iPlayersNum)
		return 0
	
	for(new i = 0; i < iPlayersNum; i++)
	{
		iPlayer = iPlayers[i]
		
		if ((get_user_team(iPlayer) == 1) && is_user_alive(iPlayer) && (iPlayer != id))
		{
			pev(iPlayer, pev_origin, fOriginBomb2)
			fDist = get_distance_f(fOriginBomb1 , fOriginBomb2)
			if(fDist < fMinDist)
			{
				fMinDist = fDist
				iTeammate = iPlayer
			}
		}
	}
	return iTeammate
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

stock setScreenFlash(id, r, g, b, alpha)
{
	message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0, 0, 0}, id)
	write_short(1<<10)
	write_short(1<<10)
	write_short(1<<12)
	write_byte(r)
	write_byte(g)
	write_byte(b)
	write_byte(alpha)
	message_end()
}

stock add_delay(id, const task[])
{
	switch(id)
	{
		case 1..7: set_task(0.1, task, id)
		case 8..15: set_task(0.2, task, id)
		case 16..23: set_task(0.3, task, id)
		case 24..32: set_task(0.4, task, id)
	}
}
