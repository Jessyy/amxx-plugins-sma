#include <amxmodx>
#include <cstrike>
#include <hamsandwich>

new bool:WarmUp
new Seconds = 60

public plugin_init()
{
	register_plugin("WarmUp/Respawn Round", "1.0", "X")
	
	RegisterHam(Ham_Killed, "player", "autorevive", 1)
	register_event("CurWeapon", "Current_Weapon", "be", "1=1", "2!29")
	WarmUp = true
	
	set_task(120.0, "RemoveWarmUp", 123)
	set_task(1.0, "ShowCountDown", 1234,_,_,"b",_)
}

public Current_Weapon(id)
{
	if(WarmUp) {
		engclient_cmd(id, "weapon_knife")
	}
}

public ShowCountDown()
{
	if(Seconds == 60) {
		server_cmd("amxx pause cfg_rvc")
	}
	engclient_print(0, engprint_center, "^nWarm Up Round^n^n[ %d ]",Seconds);
	
	Seconds--
	if(Seconds <= 0)
	{
		if(task_exists(1234))
			remove_task(1234)
		WarmUp = false
		server_cmd("sv_restart 1")
		server_cmd("amxx unpause cfg_rvc")
		return
	}
}

public RemoveWarmUp() WarmUp = false

public autorevive(id)
{
	if(!is_user_alive(id) && WarmUp) {
		if(get_user_team(id) == 1)
		{
			set_task(5.0,"respawn",id)
		}
		else if(get_user_team(id) == 2)
		{
			set_task(5.0,"respawn",id)
		}
		else if(get_user_team(id) == 3)
		{
			set_task(1.0,"autorevive",id)
		}
		else if(get_user_team(id) == 0)
		{
			set_task(1.0,"autorevive",id)
		}
		else
		{
			set_task(1.0,"autorevive",id)
		}
	}
}

public respawn(id)
{
	ExecuteHamB(Ham_CS_RoundRespawn, id)
}

public client_putinserver(id)
{
	if(WarmUp) {
		set_task(5.0,"autorevive",id)
	}
}
