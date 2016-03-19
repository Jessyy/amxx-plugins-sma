#include <amxmodx>
#include <engine>
#include <fun>
#include <cstrike>
#include <amxmisc>

new g_c4timer, pointnum;
new bool:b_planted = false;

public plugin_init()
{
	register_plugin("C4 CountDown", "1.0.0", "X");
	
	pointnum = get_cvar_pointer("mp_c4timer");
	
	register_logevent("newRound", 2, "1=Round_Start");
	register_logevent("endRound", 2, "1=Round_End");
	register_logevent("endRound", 2, "1&Restart_Round_");
}

public newRound()
{
	g_c4timer = -1;
	remove_task(652450);
	b_planted = false;
}

public endRound()
{
	g_c4timer = -1;
	remove_task(652450);
}

public bomb_planted()
{
	b_planted = true;
	g_c4timer = get_pcvar_num(pointnum);
	dispTime();
	set_task(1.0, "dispTime", 652450, "", 0, "b");
}

public bomb_defused()
{
	if(b_planted) {
		remove_task(652450);
		b_planted = false;
	}
}

public bomb_explode()
{
	if(b_planted) {
		remove_task(652450);
		b_planted = false;
	}
}

public dispTime()
{
	if(!b_planted) {
		remove_task(652450);
		return;
	}
	
	if(g_c4timer >= 0) {
		if(g_c4timer == 30 || g_c4timer == 20) {
			new temp[48];
			num_to_word(g_c4timer, temp, 47);
			client_cmd(0, "spk ^"vox/%s seconds until explosion^"", temp);
		}
		
		if(g_c4timer < 11 && g_c4timer > 0) {
			new temp[48];
			num_to_word(g_c4timer, temp, 47);
			client_cmd(0, "spk ^"vox/%s^"", temp);
		}
		
		--g_c4timer;
	}
}
