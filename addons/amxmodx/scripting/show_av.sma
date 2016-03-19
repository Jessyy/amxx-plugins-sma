#include <amxmodx>
#include <amxmisc>
#include <csstats> 
#include <cstrike>

new bool:SHOWVICTIMS	= true
new bool:SHOWATTACKERS	= true

new g_Buffer[2048];

public plugin_init() 
{
	register_plugin("Show Victims/Attackers", "1.0.0", "X");
	
	register_event("SendAudio", "eRoundEnd", "a", "2=%!MRAD_terwin", "2=%!MRAD_ctwin", "2=%!MRAD_rounddraw");
}

public client_death(killer, victim, wpnindex, hitplace, TK)
{
	if(SHOWVICTIMS && getVictims(victim)) {
		set_hudmessage(0, 80, 220, 0.75, 0.55, 0, 6.0, 15.0, 1.0, 2.0, 4);
		show_hudmessage(victim, "%s", g_Buffer);
	}
	if(SHOWATTACKERS && getAttackers(victim)) {
		set_hudmessage(220, 80, 0, 0.75, 0.25, 0, 6.0, 15.0, 1.0, 2.0, 3);
		show_hudmessage(victim, "%s", g_Buffer);
	}
}

public eRoundEnd()
{
	set_task(0.3, "eRoundEndTask");
}

public eRoundEndTask()
{
	new players[32], pnum;
	get_players(players, pnum, "a");
	
	for(new i = 0; i < pnum; ++i) {
		if(SHOWVICTIMS && getVictims(players[i])) {
			set_hudmessage(0, 80, 220, 0.75, 0.55, 0, 6.0, 15.0, 1.0, 2.0, 4);
			show_hudmessage(players[i], "%s", g_Buffer);
		}
		if(SHOWATTACKERS && getAttackers(players[i])) {
			set_hudmessage(220, 80, 0, 0.75, 0.25, 0, 6.0, 15.0, 1.0, 2.0, 3);
			show_hudmessage(players[i], "%s", g_Buffer);
		}
	}
}

stock getVictims(id)
{
	new name[32], stats[8], body[8], found=0;
	new amax = get_maxplayers();
	
	new pos = copy(g_Buffer, 2047, "Victims:^n----------------^n");
	for(new i=1; i<=amax; ++i) {
		if(get_user_vstats(id, i, stats, body)) {
			found = 1;
			get_user_name(i, name, 31);
			pos += format(g_Buffer[pos], 2047-pos, "%s --- Dmg: %d^n", name, stats[6]);
		}
	}
	
	return found;
}

stock getAttackers(id)
{
	new name[32], stats[8], body[8], found=0;
	new amax = get_maxplayers();
	
	new pos = copy(g_Buffer, 2047, "Attackers:^n----------------^n");
	for(new i = 1; i <= amax; ++i) {
		if(get_user_astats(id, i, stats, body)) {
			found = 1;
			get_user_name(i, name, 31);
			pos += format(g_Buffer[pos], 2047-pos, "%s --- Dmg: %d^n", name, stats[6]);
		}
	}
	
	return found;
}
