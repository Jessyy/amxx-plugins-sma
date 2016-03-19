#include <amxmodx>

new SpecName[16], gmsg_TeamInfo;

public plugin_init()
{
	register_plugin("ShownDead Fix", "1.0.0", "X");
	
	new ModName[11];
	get_modname(ModName, 10);
	
	if(equal("cstrike", ModName, 10)) {
		copy(SpecName, 15, "SPECTATOR");
	}
	else if(equal("ns", ModName, 10)) {
		copy(SpecName, 15, "#spectatorteam");
	}
	else if(equal("tfc", ModName, 10)) {
		copy(SpecName, 15, "");
	}
	
	gmsg_TeamInfo = get_user_msgid("TeamInfo");
}

public client_connect(id)
{
	if(!(is_user_bot(id))) {
		message_begin(MSG_ALL, gmsg_TeamInfo);
		write_byte(id);
		write_string(SpecName);
		message_end();
	}
	
	return PLUGIN_CONTINUE;
} 
