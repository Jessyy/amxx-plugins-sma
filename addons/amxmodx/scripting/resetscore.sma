#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>

public TimeInterval = 210

new UserTime[33];

public plugin_init()
{
	register_plugin("Reset Score", "1.0.0", "X");
	
	register_clcmd("say /rs", "reset_score", -1);
	register_clcmd("say_team /rs", "reset_score", -1);
	
	register_clcmd("say /reset", "reset_score", -1);
	register_clcmd("say_team /reset", "reset_score", -1);
	
	register_clcmd("say /resetscore", "reset_score", -1);
	register_clcmd("say_team /resetscore", "reset_score", -1);
}

public reset_score(user)
{
	new GameTime, TimeCvar, Float:GamesTime;
	
	GamesTime = get_gametime();
	GameTime = floatround(GamesTime);
	TimeCvar = TimeInterval;
	
	if (UserTime[user] && (GameTime - UserTime[user] < TimeCvar)) {
		new a = TimeCvar - (GameTime - UserTime[user]);
		print(user, "^1* ^4[ResetScore]^1: Mai poti folosii comanda dupa^4 %d min^1 si^4 %02d sec^1", (a / 60), (a % 60));
		
		return PLUGIN_HANDLED;
	}
	
	if((get_user_frags(user) == 0) && (get_user_deaths(user) == 0)) {
		print(user, "^1* ^4[ResetScore]^1: Scorul tau este deja^4 0^1 -^4 0^1");
		
		return PLUGIN_HANDLED;
	}
	
	print(user, "^1* ^4[ResetScore]^1: Scorul tau este acum^4 0^1 -^4 0^1");
	UserTime[user] = GameTime;
	
	cs_set_user_deaths(user, 0);
	set_user_frags(user, 0);
	cs_set_user_deaths(user, 0);
	set_user_frags(user, 0);
	
	return PLUGIN_HANDLED;
}

print(id, const message[], {Float, Sql, Result, _}:...)
{
	static g_msgSayText;
	g_msgSayText = get_user_msgid("SayText");
	
	new Buffer[191];
	vformat(Buffer, sizeof Buffer - 1, message, 3);
	
	if(id) {
		if(!is_user_connected(id))
			return;
		
		message_begin(MSG_ONE, g_msgSayText, _, id);
		write_byte(id);
		write_string(Buffer);
		message_end();
	} else {
		static players[32], count, index;
		get_players(players, count);
		
		for(new i = 0; i < count; i++) {
			index = players[i];
			
			if(!is_user_connected(index))
				continue;
			
			message_begin(MSG_ONE, g_msgSayText, _, index);
			write_byte(index);
			write_string(Buffer);
			message_end();
		}
	}
}
