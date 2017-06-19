/**
 *	New Style Stats - say_newstylestats.sma
 *
 *	Based on New Style Rank v1.0 by Alka from https://forums.alliedmods.net/showthread.php?p=710055
 *		@released: 06/11/2008 (dd/mm/yyyy)
 *
 *	Based on New CS Stats v1.0 by sb123 https://forums.alliedmods.net/showthread.php?t=64593
 *		@released: 11/03/2009 (dd/mm/yyyy)
 */
#include <amxmodx>
#include <csx>

#define PLUGIN_NAME		"New Style Stats"
#define PLUGIN_VERSION	"2017.06.18"
#define PLUGIN_AUTHOR	"X"

new g_szSound[] = "misc/antend.wav";

new g_szBodyParts[8][] = {
	"Whole Body",
	"Head",
	"Chest",
	"Stomach",
	"Left Arm",
	"Right Arm",
	"Left Leg",
	"Right Leg"
};

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	register_clcmd("say /rank", "Cmd@Rank", -1);
	register_clcmd("say_team /rank", "Cmd@Rank", -1);

	register_clcmd("say /top10", "Cmd@Top15", -1);
	register_clcmd("say_team /top10", "Cmd@Top15", -1);

	register_clcmd("say /top15", "Cmd@Top15", -1);
	register_clcmd("say_team /top15", "Cmd@Top15", -1);

	register_clcmd("say /topme", "Cmd@TopMe", -1);
	register_clcmd("say_team /topme", "Cmd@TopMe", -1);

	register_clcmd("say /statsme", "Cmd@StatsMe", -1);
	register_clcmd("say_team /statsme", "Cmd@StatsMe", -1);

	register_clcmd("say /rankstats", "Cmd@RankStats", -1);
	register_clcmd("say_team /rankstats", "Cmd@RankStats", -1);
}

public plugin_precache()
{
	if(get_cvar_num("sv_allowprecache")) {
		precache_sound(g_szSound);
	}
}

Float:acc(stats[8])
{
	if(!stats[4]) {
		return (0.0);
	}
	new Float:result;
	result = 100.0 * float(stats[5]) / float(stats[4]);
	return (result > 100.0) ? 100.0 : result;
}

Float:eff(stats[8])
{
	if(!stats[0]) {
		return (0.0);
	}
	new Float:result;
	result = 100.0 * float(stats[0]) / float(stats[0] + stats[1]);
	return (result > 100.0) ? 100.0 : result;
}

Float:ratio(stats[8])
{
	if(!stats[0]) {
		return (0.0);
	}
	new Float:result;
	result = float(stats[0]) / float(stats[1]);
	return result;
}

public Cmd@Rank(id)
{
	new pos, g_Buffer[2048], stats[8], body[8], stats2[4], name[32];
	get_user_stats(id, stats, body);
	get_user_stats2(id, stats2);
	get_user_name(id, name, 31);

	pos = copy(g_Buffer, 2047, "<html><center>");
	pos += copy(g_Buffer[pos], 2047-pos, "<head><style type=^"text/css^"><!--body{background-color:#000000;font-family:Arial,sans-serif;color:#FFFFFF;margin-top:10px;}");

	if(get_user_team(id) == 1) {
		pos += copy(g_Buffer[pos], 2047-pos, "tr.header{font-weight:bold;background-color:#9C0000;}tr.one{background-color:#310000;}tr.two{background-color:#630000;}--></style></head>");
	} else if(get_user_team(id) == 2) {
		pos += copy(g_Buffer[pos], 2047-pos, "tr.header{font-weight:bold;background-color:#00009C;}tr.one{background-color:#000031;}tr.two{background-color:#000063;}--></style></head>");
	} else {
		pos += copy(g_Buffer[pos], 2047-pos, "tr.header{font-weight:bold;background-color:#737373;}tr.one{background-color:#3D3D3D;}tr.two{background-color:#565656;}--></style></head>");
	}

	pos += copy(g_Buffer[pos], 2047-pos, "<body scroll=^"no^">");
	pos += format(g_Buffer[pos], 2047-pos, "<font size=4><b>NEW STYLE RANK</b></font><p>%s<table>", name);

	pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"header^"><td>Rank<td>:<td>%d / %d", stats[7], get_statsnum());
	pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"one^"><td>Kills<td>:<td>%d", stats[0]);
	pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"two^"><td>Deaths<td>:<td>%d", stats[1]);
	pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"one^"><td>Head Shots<td>:<td>%d", stats[2]);
	pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"two^"><td>Shots<td>:<td>%d", stats[4]);
	pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"one^"><td>Hits<td>:<td>%d", stats[5]);
	pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"two^"><td>Damage<td>:<td>%d<tr><tr>", stats[6]);

	pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"one^"><td>Accuracy<td>:<td>%0.2f%%", acc(stats));
	pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"two^"><td>Efficiency<td>:<td>%0.2f%%<tr><tr>", eff(stats));

	pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"one^"><td>Bombs Defused<td>:<td>%d", stats2[1]);
	pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"two^"><td>Bombs Plants<td>:<td>%d", stats2[2]);
	pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"one^"><td>Bombs Explosions<td>:<td>%d", stats2[3]);

	copy(g_Buffer[pos], 2047-pos, "</table>");
	show_motd(id, g_Buffer, "Rank ...");
	Func@PlaySound(id)

	return PLUGIN_HANDLED;
}

public Cmd@Top15(id)
{
	new pos, g_Buffer[2048], stats[8], body[8], name[32], states[4];

	pos = copy(g_Buffer, 2047, "<html><center>");
	pos += copy(g_Buffer[pos], 2047-pos, "<head><style type=^"text/css^"><!--body{background-color:#000000;font-family:Arial,sans-serif;color:#FFFFFF;margin-top:10px;}");

	if(get_user_team(id) == 1) {
		pos += copy(g_Buffer[pos], 2047-pos, "tr.header{font-weight:bold;background-color:#9C0000;}tr.one{background-color:#310000;}tr.two{background-color:#630000;}--></style></head>");
	} else if(get_user_team(id) == 2) {
		pos += copy(g_Buffer[pos], 2047-pos, "tr.header{font-weight:bold;background-color:#00009C;}tr.one{background-color:#000031;}tr.two{background-color:#000063;}--></style></head>");
	} else {
		pos += copy(g_Buffer[pos], 2047-pos, "tr.header{font-weight:bold;background-color:#737373;}tr.one{background-color:#3D3D3D;}tr.two{background-color:#565656;}--></style></head>");
	}

	pos += copy(g_Buffer[pos], 2047-pos, "<body scroll=^"no^">");
	pos += copy(g_Buffer[pos], 2047-pos, "<font size=4><b>TOP 15 BEST PLAYERS</b></font><p><table>");

	pos += copy(g_Buffer[pos], 2047-pos, "<tr class=^"header^"><td>#<td width=^"200^">Nick<td>Kills<td>Deaths<td>Hs<td>Acc</tr>");

	new imax = get_statsnum();
	if(imax > 15) { imax = 15; }

	for(new i = 0; i < imax; ++i)
	{
		if(equal(states, "one"))
			copy(states, 3, "two");
		else
			copy(states, 3, "one");

		get_stats(i, stats, body, name, 31);

		pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"%s^"><td>%d<td>%s<td>%d<td>%d<td>%d<td>%0.2f%%", states, i+1, name, stats[0], stats[1], stats[2], acc(stats));
	}

	copy(g_Buffer[pos], 2047-pos, "</table>");
	show_motd(id, g_Buffer, "Top 15 ...");
	Func@PlaySound(id)

	return PLUGIN_HANDLED;
}

public Cmd@TopMe(id)
{
	new pos, g_Buffer[2048], stats[8], body[8], name[32], states[4];
	new imax0 = get_statsnum(); new imax1 = get_user_stats(id, stats, body) - 1; new imax2 = imax1 + 15;
	if(imax0 > imax2) { imax0 = imax2; }

	pos = copy(g_Buffer, 2047, "<html><center>");
	pos += copy(g_Buffer[pos], 2047-pos, "<head><style type=^"text/css^"><!--body{background-color:#000000;font-family:Arial,sans-serif;color:#FFFFFF;margin-top:10px;}");

	if(get_user_team(id) == 1) {
		pos += copy(g_Buffer[pos], 2047-pos, "tr.header{font-weight:bold;background-color:#9C0000;}tr.one{background-color:#310000;}tr.two{background-color:#630000;}--></style></head>");
	} else if(get_user_team(id) == 2) {
		pos += copy(g_Buffer[pos], 2047-pos, "tr.header{font-weight:bold;background-color:#00009C;}tr.one{background-color:#000031;}tr.two{background-color:#000063;}--></style></head>");
	} else {
		pos += copy(g_Buffer[pos], 2047-pos, "tr.header{font-weight:bold;background-color:#737373;}tr.one{background-color:#3D3D3D;}tr.two{background-color:#565656;}--></style></head>");
	}

	pos += copy(g_Buffer[pos], 2047-pos, "<body scroll=^"no^">");
	pos += format(g_Buffer[pos], 2047-pos, "<font size=4><b>TOP %d-%d BEST PLAYERS</b></font><p><table>", imax1+1, imax0);

	pos += copy(g_Buffer[pos], 2047-pos, "<tr class=^"header^"><td>#<td width=^"200^">Nick<td>Kills<td>Deaths<td>Hs<td>Acc</tr>");

	for(new i = imax1; i < imax0; ++i)
	{
		if(equal(states, "one"))
			copy(states, 3, "two");
		else
			copy(states, 3, "one");

		get_stats(i, stats, body, name, 31);

		pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"%s^"><td>%d<td>%s<td>%d<td>%d<td>%d<td>%0.2f%%", states, i+1, name, stats[0], stats[1], stats[2], acc(stats));
	}

	copy(g_Buffer[pos], 2047-pos, "</table>");
	show_motd(id, g_Buffer, "Topme ...");
	Func@PlaySound(id)

	return PLUGIN_HANDLED;
}

public Cmd@StatsMe(id)
{
	new pos, g_Buffer[2048], name[32], stats[8], body[8], states[4];
	get_user_wstats(id, 0, stats, body);

	pos = copy(g_Buffer, 2047, "<html><center>");
	pos += copy(g_Buffer[pos], 2047-pos, "<head><style type=^"text/css^"><!--body{background-color:#000000;font-family:Arial,sans-serif;color:#FFFFFF;margin-top:10px;}");

	if(get_user_team(id) == 1) {
		pos += copy(g_Buffer[pos], 2047-pos, "tr.header{font-weight:bold;background-color:#9C0000;}tr.one{background-color:#310000;}tr.two{background-color:#630000;}--></style></head>");
	} else if(get_user_team(id) == 2) {
		pos += copy(g_Buffer[pos], 2047-pos, "tr.header{font-weight:bold;background-color:#00009C;}tr.one{background-color:#000031;}tr.two{background-color:#000063;}--></style></head>");
	} else {
		pos += copy(g_Buffer[pos], 2047-pos, "tr.header{font-weight:bold;background-color:#737373;}tr.one{background-color:#3D3D3D;}tr.two{background-color:#565656;}--></style></head>");
	}

	pos += copy(g_Buffer[pos], 2047-pos, "<body scroll=^"no^">");
	pos += copy(g_Buffer[pos], 2047-pos, "<font size=4><b>YOUR PERSONAL STATSME</b></font><p><table>");

	pos += copy(g_Buffer[pos], 2047-pos, "<tr class=^"header^"><td>Weapons<td>Shots<td>Hits<td>Damage<td>Kills<td>Deaths</tr>");

	for(new i = 1; i < 31; ++i)
	{
		if(get_user_wstats(id, i, stats, body)) {
			if (equal(states, "one"))
				copy(states, 3, "two");
			else
				copy(states, 3, "one");

			get_weaponname(i, name, 31);

			pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"%s^"><td>%s<td>%d<td>%d<td>%d<td>%d<td>%d", states, name[7], stats[4], stats[5], stats[6], stats[0], stats[1]);
		}
	}

	copy(g_Buffer[pos], 2047-pos, "</table>");
	show_motd(id, g_Buffer, "Statsme ...");
	Func@PlaySound(id)

	return PLUGIN_HANDLED;
}

public Cmd@RankStats(id)
{
	new pos, g_Buffer[2048], stats[8], body[8];
	get_user_stats(id, stats, body);

	pos = copy(g_Buffer, 2047, "<html><center>");
	pos += copy(g_Buffer[pos], 2047-pos, "<head><style type=^"text/css^"><!--body{background-color:#000000;font-family:Arial,sans-serif;color:#FFFFFF;margin-top:10px;}");

	if(get_user_team(id) == 1) {
		pos += copy(g_Buffer[pos], 2047-pos, "tr.header{font-weight:bold;background-color:#9C0000;}tr.one{background-color:#310000;}tr.two{background-color:#630000;}--></style></head>");
	} else if(get_user_team(id) == 2) {
		pos += copy(g_Buffer[pos], 2047-pos, "tr.header{font-weight:bold;background-color:#00009C;}tr.one{background-color:#000031;}tr.two{background-color:#000063;}--></style></head>");
	} else {
		pos += copy(g_Buffer[pos], 2047-pos, "tr.header{font-weight:bold;background-color:#737373;}tr.one{background-color:#3D3D3D;}tr.two{background-color:#565656;}--></style></head>");
	}

	pos += copy(g_Buffer[pos], 2047-pos, "<body scroll=^"no^">");
	pos += copy(g_Buffer[pos], 2047-pos, "<font size=4><b>YOUR PERSONAL RANKSTATS</b></font><p>");

	pos += format(g_Buffer[pos], 2047-pos, "<font size=4><b>Your rank is %d of %d</b></font><table>", stats[7], get_statsnum());
	pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"two^"><td>KD Ratio<td>:<td>%0.2f%%</tr>", ratio(stats));

//	pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"one^"><td>Kills<td>:<td>%d</tr>", stats[0]);
//	pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"two^"><td>Deaths<td>:<td>%d</tr>", stats[1]);
//	pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"one^"><td>Damage<td>:<td>%d</tr>", stats[6]);

	pos += format(g_Buffer[pos], 2047-pos, "</table><font size=4><b>Total hits on you</b></font><table>")
	pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"one^"><td>%s<td>:<td>%d</tr>", g_szBodyParts[1], body[1]);
	pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"two^"><td>%s<td>:<td>%d</tr>", g_szBodyParts[2], body[2]);
	pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"one^"><td>%s<td>:<td>%d</tr>", g_szBodyParts[3], body[3]);
	pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"two^"><td>%s<td>:<td>%d</tr>", g_szBodyParts[4], body[4]);
	pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"one^"><td>%s<td>:<td>%d</tr>", g_szBodyParts[5], body[5]);
	pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"two^"><td>%s<td>:<td>%d</tr>", g_szBodyParts[6], body[6]);
	pos += format(g_Buffer[pos], 2047-pos, "<tr class=^"one^"><td>%s<td>:<td>%d</tr>", g_szBodyParts[7], body[7]);

	copy(g_Buffer[pos], 2047-pos, "</table>");
	show_motd(id, g_Buffer, "RankStats ...");
	Func@PlaySound(id)

	return PLUGIN_HANDLED;
}

stock Func@PlaySound(id)
{
	if(!is_user_alive(id)) {
		client_cmd(id, "spk %s", g_szSound);
	}
}
