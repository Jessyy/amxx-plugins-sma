#include <amxmodx>
#include <cstrike>
#include <amxmisc>

public plugin_init()
{
	register_plugin("Block Fire.In.The.Hole Audio/Msg", "1.0.0", "X");
	
	register_message(get_user_msgid("TextMsg"), "msg_TextMsg");
	register_message(get_user_msgid("SendAudio"), "msg_SendAudio");
}

public msg_TextMsg()
{
	if(is_running("czero")) {
		if(get_msg_args() != 6 || get_msg_argtype(6) != ARG_STRING)
			return PLUGIN_CONTINUE;
		
		new arg6[20];
		get_msg_arg_string(6, arg6, 19);
		
		if(equal(arg6, "#Fire_in_the_hole"))
			return PLUGIN_HANDLED;
	} else {
		if(get_msg_args() != 5 || get_msg_argtype(5) != ARG_STRING)
			return PLUGIN_CONTINUE;
		
		new arg5[20];
		get_msg_arg_string(5, arg5, 19);
		
		if(equal(arg5, "#Fire_in_the_hole"))
			return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE;
}

public msg_SendAudio()
{
	if(get_msg_args() != 3 || get_msg_argtype(2) != ARG_STRING)
		return PLUGIN_CONTINUE;
	
	new arg2[20];
	get_msg_arg_string(2, arg2, 19);
	
	if(equal(arg2[1], "!MRAD_FIREINHOLE"))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}
