#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <geoip>

new user_ip[48];

new bool:CONNECT	= false
new bool:PUTINSERVER	= true
new bool:DISCONNECT	= true

public plugin_init()
{
	register_plugin("Connect Country-City", "1.0.0", "X");
}

public client_connect(id)
{
	if(!CONNECT)
		return PLUGIN_HANDLED;
	
	static user_name[32], user_country[48], user_city[48];
	
	get_user_name(id, user_name, 31);
	get_user_ip(id, user_ip, 47, 1);
	
	geoip_country(user_ip, user_country, 47);
	geoip_city(user_ip, user_city, 47);
	
	if(equal(user_country, "error")) { user_country = "Unknown"; }
	if(equal(user_city, "error")) { user_city = "Unknown"; }
	
	print(0, "^1* ^4%s^1 - Tara: ^''^4%s^1^'' | Oras: ^''^4%s^1^'' se conecteaza", user_name, user_country, user_city);
	server_print("[AMXX] Player: %s - Tara: ^''%s^'' | Oras: ^''%s^'' se conecteaza", user_name, user_country, user_city);
	
	return PLUGIN_CONTINUE;
}

public client_putinserver(id)
{
	if(!PUTINSERVER)
		return PLUGIN_HANDLED;
	
	static user_name[32], user_country[48], user_city[48];
	
	get_user_name(id, user_name, 31);
	get_user_ip(id, user_ip, 47, 1);
	
	geoip_country(user_ip, user_country, 47);
	geoip_city(user_ip, user_city, 47);
	
	if(equal(user_country, "error")) { user_country = "Unknown"; }
	if(equal(user_city, "error")) { user_city = "Unknown"; }
	
	print(0, "^1* ^4%s^1 - Tara: ^''^4%s^1^'' | Oras: ^''^4%s^1^'' s-a conectat", user_name, user_country, user_city);
	server_print("[AMXX] Player: %s - Tara: ^''%s^'' | Oras: ^''%s^'' s-a conectat", user_name, user_country, user_city);
	
	return PLUGIN_CONTINUE;
}

public client_disconnect(id)
{
	if(!DISCONNECT)
		return PLUGIN_HANDLED;
	
	static user_name[32];
	get_user_name(id, user_name, 31);
	
	print(0, "^1* ^4%s^1 a iesit de pe servar", user_name);
	server_print("[AMXX] Player: %s a iesit de pe servar", user_name);
	
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
