#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>

static iPlayers[32], iCount, ii, gw, iw;
new izName[32], szName[32], sPlayer;
new wid[3], g_Buffer[64], gxWeapons[64], szammo[3][20];

new g_Weapons[][] = {
	"p228", "scout", "xm1014", "mac10", "aug", "elite", "fiveseven",
	"ump45", "sg550", "galil", "famas", "usp", "glock18", "awp",
	"mp5navy", "m249", "m3", "m4a1", "tmp", "g3sg1", "deagle",
	"sg552", "ak47", "p90", "hegrenade", "smokegrenade", "flashbang"
};

new g_Constants[] = {
	CSW_P228, CSW_SCOUT, CSW_XM1014, CSW_MAC10, CSW_AUG, CSW_ELITE, CSW_FIVESEVEN,
	CSW_UMP45, CSW_SG550, CSW_GALIL, CSW_FAMAS, CSW_USP, CSW_GLOCK18, CSW_AWP,
	CSW_MP5NAVY, CSW_M249, CSW_M3, CSW_M4A1, CSW_TMP, CSW_G3SG1, CSW_DEAGLE,
	CSW_SG552, CSW_AK47, CSW_P90, CSW_HEGRENADE, CSW_SMOKEGRENADE, CSW_FLASHBANG
};

public plugin_init()
{
	register_plugin("Give Weapons", "1.0.0", "X");
	
	register_concmd("amx_giveweapon", "cmdGiveWeapon", ADMIN_RCON, "<name or #userid/@t/@ct/@all> <arma-1> [arma-2] [arma-3]");
}

public cmdGiveWeapon(iPlayer, level, cid)
{
	if(!cmd_access(iPlayer, level, cid, 2))
		return PLUGIN_HANDLED;
	
	new arg1[32], sWeapon[3][15];
	read_argv(1, arg1, 31);
	read_argv(2, sWeapon[0], 14);
	read_argv(3, sWeapon[1], 14);
	read_argv(4, sWeapon[2], 14);
	
	if(equali(arg1, "@t"))
	{
		get_user_name(iPlayer, izName, 31);
		
		formatex(wid[0], 1, "");
		formatex(wid[1], 1, "");
		formatex(wid[2], 1, "");
		
		get_players(iPlayers, iCount);
		for(ii=0; ii < iCount; ii++) {
			sPlayer = iPlayers[ii];
			if(!is_user_connected(sPlayer) || !is_user_alive(sPlayer) || (cs_get_user_team(sPlayer) == CS_TEAM_SPECTATOR & CS_TEAM_CT))
				continue;
			
			for(gw=0; gw < sizeof(g_Weapons); gw++) {
				for(iw=0; iw < 3; iw++) {
					if(!strcmp(sWeapon[iw], g_Weapons[gw]) && (strlen(sWeapon[iw]) != 0)) {
						wid[iw] = g_Constants[gw];
						
						if(!user_has_weapon(sPlayer, wid[iw])) {
							formatex(g_Buffer, sizeof(g_Buffer), "weapon_%s", g_Weapons[gw]);
							fm_give_item(sPlayer, g_Buffer);
						}
						
						get_ammoname(wid[iw], szammo[iw], 19);
						fm_give_item(sPlayer, szammo[iw]);
					}
				}
			}
		}
		
		if(strlen(wid[0]) != 0)
			formatex(gxWeapons, sizeof(gxWeapons), "%s", sWeapon[0]);
		
		if(strlen(wid[1]) != 0)
			if(!gxWeapons[0])
				formatex(gxWeapons, sizeof(gxWeapons), "%s", sWeapon[1]);
			else
				formatex(gxWeapons, sizeof(gxWeapons), "%s / %s", gxWeapons, sWeapon[1]);
		
		if(strlen(wid[2]) != 0)
			if(!gxWeapons[0])
				formatex(gxWeapons, sizeof(gxWeapons), "%s", sWeapon[2]);
			else
				formatex(gxWeapons, sizeof(gxWeapons), "%s / %s", gxWeapons, sWeapon[2]);
		
		if(strlen(gxWeapons) != 0) {
			console_print(iPlayer, "[GIVE WEAPON]: Echpia T a primit ^"%s^"", gxWeapons);
			print(0, "^1ADMIN ^4%s^1: a dat ^4%s ^1la echipa ^4T", izName, gxWeapons);
		} else {
			console_print(iPlayer, "[GIVE WEAPON]: Invalid Weapons");
		}
	}
	else if(equali(arg1, "@ct"))
	{
		get_user_name(iPlayer, izName, 31);
		
		formatex(wid[0], 1, "");
		formatex(wid[1], 1, "");
		formatex(wid[2], 1, "");
		
		get_players(iPlayers, iCount);
		for(ii=0; ii < iCount; ii++) {
			sPlayer = iPlayers[ii];
			if(!is_user_connected(sPlayer) || !is_user_alive(sPlayer) || (cs_get_user_team(sPlayer) == CS_TEAM_SPECTATOR & CS_TEAM_T))
				continue;
			
			for(gw=0; gw < sizeof(g_Weapons); gw++) {
				for(iw=0; iw < 3; iw++) {
					if(!strcmp(sWeapon[iw], g_Weapons[gw]) && (strlen(sWeapon[iw]) != 0)) {
						wid[iw] = g_Constants[gw];
						
						if(!user_has_weapon(sPlayer, wid[iw])) {
							formatex(g_Buffer, sizeof(g_Buffer), "weapon_%s", g_Weapons[gw]);
							fm_give_item(sPlayer, g_Buffer);
						}
						
						get_ammoname(wid[iw], szammo[iw], 19);
						fm_give_item(sPlayer, szammo[iw]);
					}
				}
			}
		}
		
		if(strlen(wid[0]) != 0)
			formatex(gxWeapons, sizeof(gxWeapons), "%s", sWeapon[0]);
		
		if(strlen(wid[1]) != 0)
			if(!gxWeapons[0])
				formatex(gxWeapons, sizeof(gxWeapons), "%s", sWeapon[1]);
			else
				formatex(gxWeapons, sizeof(gxWeapons), "%s / %s", gxWeapons, sWeapon[1]);
		
		if(strlen(wid[2]) != 0)
			if(!gxWeapons[0])
				formatex(gxWeapons, sizeof(gxWeapons), "%s", sWeapon[2]);
			else
				formatex(gxWeapons, sizeof(gxWeapons), "%s / %s", gxWeapons, sWeapon[2]);
		
		if(strlen(gxWeapons) != 0)
		{
			console_print(iPlayer, "[GIVE WEAPON]: Echpia CT a primit ^"%s^"", gxWeapons);
			print(0, "^1ADMIN ^4%s^1: a dat ^4%s ^1la echipa ^4CT", izName, gxWeapons);
		} else {
			console_print(iPlayer, "[GIVE WEAPON]: Invalid Weapons");
		}
	}
	else if(equali(arg1, "@all"))
	{
		get_user_name(iPlayer, izName, 31);
		
		formatex(wid[0], 1, "");
		formatex(wid[1], 1, "");
		formatex(wid[2], 1, "");
		
		get_players(iPlayers, iCount);
		for(ii=0; ii < iCount; ii++)
		{
			sPlayer = iPlayers[ii];
			if(!is_user_connected(sPlayer) || !is_user_alive(sPlayer) || (cs_get_user_team(sPlayer) == CS_TEAM_SPECTATOR))
				continue;
			
			for(gw=0; gw < sizeof(g_Weapons); gw++) {
				for(new iw=0; iw < 3; iw++) {
					if(!strcmp(sWeapon[iw], g_Weapons[gw]) && (strlen(sWeapon[iw]) != 0)) {
						wid[iw] = g_Constants[gw];
						
						if(!user_has_weapon(sPlayer, wid[iw])) {
							formatex(g_Buffer, sizeof(g_Buffer), "weapon_%s", g_Weapons[gw]);
							fm_give_item(sPlayer, g_Buffer);
						}
						
						get_ammoname(wid[iw], szammo[iw], 19);
						fm_give_item(sPlayer, szammo[iw]);
					}
				}
			}
		}
		
		if(strlen(wid[0]) != 0)
			formatex(gxWeapons, sizeof(gxWeapons), "%s", sWeapon[0]);
		
		if(strlen(wid[1]) != 0)
			if(!gxWeapons[0])
				formatex(gxWeapons, sizeof(gxWeapons), "%s", sWeapon[1]);
			else
				formatex(gxWeapons, sizeof(gxWeapons), "%s / %s", gxWeapons, sWeapon[1]);
		
		if(strlen(wid[2]) != 0)
			if(!gxWeapons[0])
				formatex(gxWeapons, sizeof(gxWeapons), "%s", sWeapon[2]);
			else
				formatex(gxWeapons, sizeof(gxWeapons), "%s / %s", gxWeapons, sWeapon[2]);
		
		if(strlen(gxWeapons) != 0) {
			console_print(iPlayer, "[GIVE WEAPON]: Toata lumea a primit ^"%s^"", gxWeapons);
			print(0, "^1ADMIN ^4%s^1: a dat ^4%s ^1la ^4toata lumea", izName, gxWeapons);
		} else {
			console_print(iPlayer, "[GIVE WEAPON]: Invalid Weapons");
		}
	}
	else {
		sPlayer = cmd_target(iPlayer, arg1, 2);
		
		if(!sPlayer)
			return PLUGIN_HANDLED;
				
		get_user_name(iPlayer, izName, 31);
		get_user_name(sPlayer, szName, 31);
		
		if(!is_user_alive(sPlayer)) {
			console_print(iPlayer, "[GIVE WEAPON]: Jucatorul ^"%s^" trebuie sa fie in viata", szName);
			
			return PLUGIN_HANDLED;
		}
		
		formatex(wid[0], 1, "");
		formatex(wid[1], 1, "");
		formatex(wid[2], 1, "");
		
		for(gw=0; gw < sizeof(g_Weapons); gw++) {
			for(iw=0; iw < 3; iw++) {
				if(!strcmp(sWeapon[iw], g_Weapons[gw]) && (strlen(sWeapon[iw]) != 0)) {
					wid[iw] = g_Constants[gw];
					
					if(!user_has_weapon(sPlayer, wid[iw])) {
						formatex(g_Buffer, sizeof(g_Buffer), "weapon_%s", g_Weapons[gw]);
						fm_give_item(sPlayer, g_Buffer);
					}
					
					get_ammoname(wid[iw], szammo[iw], 19);
					fm_give_item(sPlayer, szammo[iw]);
				}
			}
		}
		
		if(strlen(wid[0]) != 0)
			formatex(gxWeapons, sizeof(gxWeapons), "%s", sWeapon[0]);
		
		if(strlen(wid[1]) != 0)
			if(!gxWeapons[0])
				formatex(gxWeapons, sizeof(gxWeapons), "%s", sWeapon[1]);
			else
				formatex(gxWeapons, sizeof(gxWeapons), "%s / %s", gxWeapons, sWeapon[1]);
		
		if(strlen(wid[2]) != 0)
			if(!gxWeapons[0])
				formatex(gxWeapons, sizeof(gxWeapons), "%s", sWeapon[2]);
			else
				formatex(gxWeapons, sizeof(gxWeapons), "%s / %s", gxWeapons, sWeapon[2]);
		
		if(strlen(gxWeapons) != 0) {
			console_print(iPlayer, "[GIVE WEAPON]: Jucatorul ^"%s^" a primit ^"%s^"", szName, gxWeapons);
			//print(0, "^1ADMIN ^4%s^1: ii da ^4%s ^1lui ^4%s", izName, gxWeapons, szName);
		} else {
			console_print(iPlayer, "[GIVE WEAPON]: Invalid Weapons");
		}
	}
	
	return PLUGIN_HANDLED;
}

public get_ammoname(wid, szzammo[], len)
{
	switch(wid)
	{
		case CSW_USP, CSW_MAC10, CSW_UMP45:
			copy(szzammo, len, "ammo_45acp");
		
		case CSW_ELITE, CSW_GLOCK18, CSW_MP5NAVY, CSW_TMP:
			copy(szzammo, len, "ammo_9mm");
		
		case CSW_FIVESEVEN, CSW_P90:
			copy(szzammo, len, "ammo_57mm");
		
		case CSW_DEAGLE:
			copy(szzammo, len, "ammo_50ae");
		
		case CSW_P228:
			copy(szzammo, len, "ammo_357sig");
		
		case CSW_SCOUT, CSW_G3SG1, CSW_AK47:
			copy(szzammo, len, "ammo_762nato");
		
		case CSW_XM1014, CSW_M3:
			copy(szzammo, len, "ammo_buckshot");
		
		case CSW_AUG, CSW_SG550, CSW_GALIL, CSW_FAMAS, CSW_M4A1:
			copy(szzammo, len, "ammo_556nato");
		
		case CSW_AWP:
			copy(szzammo, len, "ammo_338magnum");
		
		case CSW_M249:
			copy(szzammo, len, "ammo_556natobox");
		
		case CSW_SG552:
			copy(szzammo, len, "ammo_556nato");
		
		default:
			copy(szzammo, len, "");
	}
}

fm_give_item(id, const item[])
{
	static ent, save, Float:originF[3];
	
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, item));
	if(!pev_valid(ent))
		return;
	
	pev(id, pev_origin, originF);
	
	set_pev(ent, pev_origin, originF);
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn, ent);
	
	save = pev(ent, pev_solid);
	dllfunc(DLLFunc_Touch, ent, id);
	
	if(pev(ent, pev_solid) != save)
		return;
	
	engfunc(EngFunc_RemoveEntity, ent);
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
