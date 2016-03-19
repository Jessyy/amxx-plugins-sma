/* -= CVARS =-
* -------------------------
* amx_respawn_type	0/1/2/3	-	Dezactivat / Terrorists / Counter-Terrorists / Terrorists & Counter-Terrorists
* -------------------------
*/
#include <amxmodx>
#include <cstrike>
#include <hamsandwich>

#define	RESPAWN_DELAYTIME	5  // In seconds (In cate secunde va primi respawn)

new toggle_mode, RespawnDelay[33];

public plugin_init()
{
	register_plugin("Respawn Round", "1.0", "Jessyy")
	RegisterHam(Ham_Killed, "player", "Respawn_AutoRevive", 1)
	
	toggle_mode = register_cvar("amx_respawn_type", "3");
}

public Respawn_AutoRevive(id)
{
	if(is_user_alive(id) || !is_user_connected(id) || (get_user_team(id) == 3) || get_pcvar_num(toggle_mode) == 0)	// Dezactivat
		return HAM_HANDLED;

	if((get_user_team(id) == 1) && (get_pcvar_num(toggle_mode) == 1) || (get_pcvar_num(toggle_mode) == 3))			// Terrorists
	{
		RespawnDelay[id] = RESPAWN_DELAYTIME;
		Respawn_CountDown(id);
	}
	else if((get_user_team(id) == 2) && (get_pcvar_num(toggle_mode) == 2) || (get_pcvar_num(toggle_mode) == 3))     // Counter-Terrorists
	{
		RespawnDelay[id] = RESPAWN_DELAYTIME;
		Respawn_CountDown(id);
	}
	else if(get_user_team(id) == 3)     																			// Spectator
	{
		return HAM_IGNORED;
	}
	else
	{
		set_task(3.0, "Respawn_AutoRevive", id);
	}

	return HAM_IGNORED;
}

public Respawn_CountDown(id)
{
	if(is_user_alive(id) || !is_user_connected(id) || (get_user_team(id) == 3) || get_pcvar_num(toggle_mode) == 0)
		return PLUGIN_CONTINUE;

	if(RespawnDelay[id] > 0)
	{
		set_hudmessage(255, 255, 255, -1.0, 0.30, 0, 0.0, 1.1, 0.0, 0.0, -1);
		show_hudmessage(id, "You Will Respawn in %d seconds ...", RespawnDelay[id]);

		RespawnDelay[id]--;
		
		set_task(1.0, "Respawn_CountDown", id);
	}
	else
	{
		ExecuteHam(Ham_CS_RoundRespawn, id);
	}
	
	return PLUGIN_CONTINUE;
}

public client_putinserver(id)
{
	set_task(5.0, "Respawn_AutoRevive", id);
	
	return PLUGIN_CONTINUE;
}
