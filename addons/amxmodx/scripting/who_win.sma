#include <amxmodx>
#include <amxmisc>

stock const t_messages[][] = {
	"^4Echipa T a castigat!",
	"^1Echipa ^4T ^1a castigat!",
	"^3Echipa T a castigat!"
};

stock const ct_messages[][] = {
	"^4Echipa CT a castigat!",
	"^1Echipa ^4CT ^1a castigat!",
	"^3Echipa CT a castigat!"
};

public plugin_init() 
{
	register_plugin("Who Win T/CT", "1.0", "Jessyy");
	
	register_event("SendAudio", "t_win", "a", "2=%!MRAD_terwin");
	register_event("SendAudio", "ct_win", "a", "2=%!MRAD_ctwin");
}

public t_win()
{
	for(new i; i < sizeof(t_messages); i++) {
		print(0, "%s", t_messages[i])
	}
	
	return PLUGIN_CONTINUE;
}

public ct_win()
{
	for(new i; i < sizeof(ct_messages); i++) {
		print(0, "%s", ct_messages[i])
	}
	
	return PLUGIN_CONTINUE;
}

print(id,const message[], {Float,Sql,Result,_}:...)
{
	static g_msgsaytext;
	g_msgsaytext = get_user_msgid("SayText");
	
	new Buffer[191];
	vformat(Buffer, sizeof Buffer - 1, message, 3);
	
	if(id) {
		if(!is_user_connected(id))
			return;
		
		message_begin(MSG_ONE, g_msgsaytext, _, id);
		write_byte(id);
		write_string(Buffer);
		message_end();
	} else {
		static players[32]; new count, index;
		get_players(players, count);
		
		for(new i = 0; i < count; i++) {
			index = players[i];
			if(!is_user_connected(index))
				continue;
			
			message_begin(MSG_ONE, g_msgsaytext, _, index);
			write_byte(index);
			write_string(Buffer);
			message_end();
		}
	}
}
