#include <amxmodx>

new bool:TOGGLESOUND = true
new bool:TOGGLEFADE = true

public plugin_init()
{
	register_plugin("Enhanced Death", "1.0.0", "X");
	
	register_event("DeathMsg", "msg_death", "a");
}

public msg_death()
{
	new victim = read_data(2);
	
	if(read_data(2)) {
		if(TOGGLESOUND) {
			client_cmd(victim, "spk fvox/flatline.wav");
		}
		
		if(TOGGLEFADE) {
			message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0, 0, 0}, victim);
			write_short(10<<12);
			write_short(10<<16);
			write_short(1<<1);
			write_byte(255);
			write_byte(0);
			write_byte(0);
			write_byte(255);
			message_end();
		}
	}
	
	return PLUGIN_CONTINUE;
}
