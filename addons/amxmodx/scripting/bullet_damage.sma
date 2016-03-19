#include <amxmodx>

new g_iMaxPlayers;

public plugin_init()
{
	register_plugin("Bullet Damage", "1.0.0", "X");
	
	g_iMaxPlayers = get_maxplayers();
	register_event("Damage", "event_damage", "b", "2>0", "3=0");
}

public event_damage(iVictim)
{
	if(read_data(4) || read_data(5) || read_data(6)) {
		new id = get_user_attacker(iVictim);
		
		if((1 <= id <= g_iMaxPlayers) && is_user_connected(id) && !(id == iVictim) && is_user_alive(id)) {
			set_hudmessage(0, 220, 0, -1.0, 0.53, 0, 0.1, 1.0, 0.02, 0.02, 1);
			show_hudmessage(id, "%d", read_data(2));
		}
	}
	
	return PLUGIN_CONTINUE;
}
