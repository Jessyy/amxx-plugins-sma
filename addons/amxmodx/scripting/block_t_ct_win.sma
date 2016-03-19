#include <amxmodx>

public plugin_init()
{
	register_plugin("Block T/CT Win Sounds/Msg", "1.0.0", "X");
	
	register_message(get_user_msgid("TextMsg"), "message_textmsg");
	register_message(get_user_msgid("SendAudio"), "message_sendaudio");
}

public message_textmsg(msg_id, msg_dest, msg_entity)
{
	static message[3];
	get_msg_arg_string(2,message,sizeof message - 1);
	
	switch(message[1]) {
		// -- #CTs_Win ; #Terrorists_Win ; #Round_Draw
		case 'C', 'T', 'R' : return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public message_sendaudio(msg_id, msg_dest, msg_entity)
{
	static message[10];
	get_msg_arg_string(2,message,sizeof message - 1);
	
	switch(message[7]) {
		// -- %!MRAD_terwin ; %!MRAD_ctwin ; %!MRAD_rounddraw
		case 'c', 't', 'r' : return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}
