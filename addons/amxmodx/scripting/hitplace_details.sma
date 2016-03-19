#include <amxmodx>
#include <csx>

new head_hit[32], chest_hit[32], leftarm_hit[32], rightarm_hit[32], leftleg_hit[32], rightleg_hit[32], stomach_hit[32];

public plugin_init()
{
	register_plugin("Death Hitplace Details", "1.0.0", "X");
	
	register_logevent("round_start", 2, "1=Round_Start");
}

public client_damage(attacker, victim, damage, weapon, hitplace, ta)
{
	if(hitplace == HIT_HEAD)
		head_hit[victim]++;
	
	else if(hitplace == HIT_CHEST)
		chest_hit[victim] ++;
	
	else if(hitplace == HIT_STOMACH)
		stomach_hit[victim]++;
	
	else if(hitplace == HIT_LEFTARM)
		leftarm_hit[victim]++;
	
	else if(hitplace == HIT_RIGHTARM)
		rightarm_hit[victim]++;
	
	else if(hitplace == HIT_LEFTLEG)
		leftleg_hit[victim]++;
	
	else if(hitplace == HIT_RIGHTLEG)
		rightleg_hit[victim]++;
	
	return PLUGIN_CONTINUE;
}

public client_death(killer, victim, weapon, hitplace, tk)
{
	set_hudmessage(0, 80, 220, -1.0, 0.15, 0, 6.0, 15.0, 1.0, 1.0, 1)
	show_hudmessage(victim, "Statistici:^n^n(%d)^n--%d--[%d]--%d--^n[%d]^n%d %d^n_/  \_",
		head_hit[victim], leftarm_hit[victim], chest_hit[victim], rightarm_hit[victim], stomach_hit[victim], leftleg_hit[victim], rightleg_hit[victim])
	
	return PLUGIN_CONTINUE;
}

public round_start()
{
	new player, players[32], num
	get_players(players, num)
	
	for(new i = 0; i < num; i++)
	{
		player = players[i]
		
		head_hit[player]	= 0;
		chest_hit[player]	= 0;
		stomach_hit[player]	= 0;
		leftarm_hit[player]	= 0;
		rightarm_hit[player]	= 0;
		leftleg_hit[player]	= 0;
		rightleg_hit[player]	= 0;
	}
	
	return PLUGIN_CONTINUE;
}
