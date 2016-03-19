/**
 *	Say Admin Check - say_admins.sma
 *	
 *	Based on Kill Message w/ VOX v2.7 by God@Dorin from https://forums.alliedmods.net/showthread.php?p=798314
 *		@released: 11/04/2015 (dd/mm/yyyy)
 */
#include <amxmodx>
#include <amxmisc>

#define PLUGIN_NAME		"GamePlay Kill Message"
#define PLUGIN_VERSION	"2016.03.19"
#define PLUGIN_AUTHOR	"X"

new bool:SHOWTHEKILLER	= false
new bool:SHOWASSASIN	= true

new g_iMaxClients;

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	g_iMaxClients = get_maxplayers();
	register_event("DeathMsg", "Event_Death", "a");
}

public Event_Death()
{
	new killer = read_data(1);
	new victim = read_data(2);
	
	if(!(1 <= killer <= g_iMaxClients) || killer == victim)
		return PLUGIN_HANDLED;
	
	new vicname[32], killname[32];
	get_user_name(victim, vicname, 31);
	get_user_name(killer, killname, 31);
	new killarmor = get_user_armor(killer);
	new killhealth = get_user_health(killer);
	
	if(SHOWTHEKILLER) {
		print(killer, "^1* L-ai ucis pe:^3 %s^1 !", vicname);
	}
	
	if(SHOWASSASIN) {	
		if(killhealth > 0) {
			print(victim, "^1* Assasin:^4 %s^1 - Hp:^4 %d^1 - Armura:^4 %d^1", killname, killhealth, killarmor);
		} else {
			print(victim, "^1* Assasin:^4 %s^1 - Hp:^4 0^1 - Armura:^4 0^1", killname);
		}
	}
	
	return PLUGIN_CONTINUE;
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
