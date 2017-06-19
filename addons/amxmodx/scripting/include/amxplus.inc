/**
 *	AMX Mod X Plus- amxplus.sma
 *	
 *	This file is provided as is (no warranties).
 */

#if defined _amxplus_included
	#endinput
#endif
#define _amxplus_included

/**
 *
 */
#define MAX_PLAYERS			(32)

/**
 *
 */
#define MAX_NAME_LENGTH		(32)

/**
 *
 */
#define MAX_IP_LENGTH		(22)

/**
 *
 */
#define MAX_INPUT			(128)

/**
 *
 */
#define MAX_STRING			(256)

/**
 *	Sends colored chat messages to clients.
 *	Feature to add from https://forums.alliedmods.net/showthread.php?t=277343
 */
stock client_color_print(iPlayer, const szMessage[], {Float, Sql, Result, _}:...)
{
	static g_msgSayText;
	g_msgSayText = get_user_msgid("SayText");
	
	new Buffer[191];
	vformat(Buffer, sizeof Buffer - 1, szMessage, 3);
	
	if(iPlayer) {
		if(!is_user_connected(iPlayer)) {
			return;
		}
		
		message_begin(MSG_ONE, g_msgSayText, _, iPlayer);
		write_byte(iPlayer);
		write_string(Buffer);
		message_end();
	}
	else {
		static players[32], count, index;
		get_players(players, count);
		
		for(new i = 0; i < count; i++) {
			index = players[i];
			
			if(!is_user_connected(index)) {
				continue;
			}
			
			message_begin(MSG_ONE, g_msgSayText, _, index);
			write_byte(index);
			write_string(Buffer);
			message_end();
		}
	}
}
