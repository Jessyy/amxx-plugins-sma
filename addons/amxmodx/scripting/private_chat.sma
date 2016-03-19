#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <xs>

#define PLUGIN	"Private Chat[Room]"
#define VERSION	"1.0"
#define AUTHOR	"X"

#define NO_PRIVACY		0
#define CHAT_LEN_MAX	106
#define MAX_CHAT_ROOMS	5

#define TASK_MESSAGE	11100

new g_iPrivateChat[33];
new g_iPrivateRoom[33];
new g_iRoomOwner[MAX_CHAT_ROOMS + 1];
new g_iInviter[33];
new vote_time	= 12
new g_iMaxPlayers;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_clcmd("say", "clcmdHandleSay", -1);
	register_clcmd("say_team", "clcmdHandleSayTeam", -1);
	
	register_menucmd(register_menuid("Invite"), 1<<0|1<<1, "InviteMenu_Handle");
	
	g_iMaxPlayers = get_maxplayers();
	g_iMaxPlayers = global_get(glb_maxClients);
}

public client_connect(id)
{
	g_iPrivateChat[id] = NO_PRIVACY;
	g_iPrivateRoom[id] = NO_PRIVACY;
}

public client_disconnect(id)
{
	if(g_iRoomOwner[g_iPrivateRoom[id]] == id) {
		ResetChaters(g_iPrivateRoom[id]);
		g_iRoomOwner[g_iPrivateRoom[id]] = 0;
	}
}

public clcmdHandleSay(id)
{
	new szArgs[CHAT_LEN_MAX], szCommand[16], szRoom[8];
	read_args(szArgs, charsmax(szArgs));
	remove_quotes(szArgs);
	
	if(!strlen(szArgs))
		return PLUGIN_CONTINUE;
	
	parse(szArgs, szCommand, charsmax(szCommand), szArgs, charsmax(szArgs), szRoom, charsmax(szRoom));
	
	if(equal(szCommand, "/private") || equal(szCommand, "/pm"))
	{
		if(equal(szArgs, "room"))
		{
			new iRoom = str_to_num(szRoom);
			if(!(1 <= iRoom <= MAX_CHAT_ROOMS))
			{
				print(id, "^x01* ^x04[Private]^x01: Invalid room number");
				return PLUGIN_HANDLED;
			}
			
			if(g_iRoomOwner[iRoom] != id && g_iRoomOwner[iRoom] > 0)
			{
				print(id, "^x01* ^x04[Private]^x01: Someone else is the owner of this chat room. To enter, ask for invitaion");
				return PLUGIN_HANDLED;
			}
			else if(!g_iRoomOwner[iRoom] && (g_iPrivateChat[id] == NO_PRIVACY))
			{
				g_iPrivateRoom[id] = iRoom;
				g_iRoomOwner[iRoom] = id;
				
				print(id, "^x01* ^x04[Private]^x01: You are entering private chat ^x04Room #%d^x01. To invite someone type ''^x04/invite [name]^x01''", iRoom);
			}
		}
		else
		{
			if(g_iPrivateChat[id] != NO_PRIVACY)
			{
				print(id, "^x01* ^x04[Private]^x01: You are already in a Private Conversation");
				return PLUGIN_HANDLED;
			}
			
			if(g_iPrivateRoom[id] != NO_PRIVACY)
			{
				print(id, "^x01* ^x04[Private]^x01: You are already in a Private Room Conversation");
				return PLUGIN_HANDLED;
			}
			
			new iPlayer = cmd_target(id, szArgs, 8);
			if(!iPlayer)
			{
				print(id, "^x01* ^x04[Private]^x01: Invalid player name");
				return PLUGIN_HANDLED;
			}
			else
			{
				new szPlName[32];
				get_user_name(iPlayer, szPlName, charsmax(szPlName));
				
				if(g_iPrivateChat[iPlayer] != NO_PRIVACY)
				{	
					print(id, "^x01* ^x04[Private]^x01: ^x04%s^x01 is already in a Private Conversation", szPlName);
					return PLUGIN_HANDLED;
				}
				else if(g_iPrivateRoom[iPlayer] != NO_PRIVACY)
				{
					print(id, "^x01* ^x04[Private]^x01: ^x04%s^x01 is already in a Private Room Conversation", szPlName);
					return PLUGIN_HANDLED;
				}
				else
				{
					print(id, "^x01* ^x04[Private]^x01: You invited ^x04%s^x01 to a Private Room Conversation", szPlName);
					RequestInvitation(id, iPlayer, 0);
				}
			}
		}
		return PLUGIN_HANDLED;
	}
	else if(equal(szCommand, "/unprivate") || equal(szCommand, "/unpm"))
	{
		if(g_iPrivateRoom[id] != NO_PRIVACY)
		{
			if(!g_iPrivateRoom[id])
			{
				print(id, "^x01* ^x04[Private]^x01: You are not in any private^x04 Chat^x01");
				return PLUGIN_HANDLED;
			}
			else
			{
				if(g_iRoomOwner[g_iPrivateRoom[id]] == id)
				{
					ResetChaters(g_iPrivateRoom[id]);
					
					g_iRoomOwner[g_iPrivateRoom[id]] = 0;
					g_iPrivateRoom[id] = 0;
				}
				else
				{
					new szName[32];
					get_user_name(id, szName, sizeof szName - 1);
					
					for(new i = 1 ; i <= g_iMaxPlayers ; i++)
					{
						if(g_iPrivateRoom[i] != g_iPrivateRoom[id] || i == id)
							continue;
						
						print(i, "^x01* ^x04[Room #%i]^x01: ^x03%s^x01 has left the chat room", g_iPrivateRoom[i], szName);
					}
					g_iPrivateRoom[id] = 0;
				}
			}
		}
		else
		{
			new iPlayer = g_iPrivateChat[id];
			
			if(!iPlayer)
			{
				print(id, "^x01* ^x04[Private]^x01: You are not in any private ^x04Chat Room^x01");
				return PLUGIN_HANDLED;
			}
			else
			{
				new szPlName[32];
				get_user_name(iPlayer, szPlName, sizeof szPlName - 1);
				
				if(g_iPrivateChat[iPlayer] != NO_PRIVACY)
				{
					new szName[32];
					get_user_name(id, szName, sizeof szName - 1);
					
					g_iPrivateChat[id] = NO_PRIVACY;
					g_iPrivateChat[iPlayer] = NO_PRIVACY;
					
					print(id, "^x01* ^x04[Private]^x01: You have left the Private Conversation with ^x04%s^x01", szPlName);
					print(iPlayer, "^x01* ^x04[Private]^x01: You have left the Private Conversation with ^x04%s^x01", szName);
				}
			}
		}
		return PLUGIN_HANDLED;
	}
	else if(equali(szCommand, "/invite"))
	{
		if(!g_iPrivateRoom[id])
		{
			print(id, "^x01* ^x04[Private]^x01: You must be in a Private Room Conversation to use this command");
			return PLUGIN_HANDLED;
		}
		if(g_iRoomOwner[g_iPrivateRoom[id]] != id)
		{
			print(id, "^x01* ^x04[Private]^x01: You can't invite someone if your not the owner of ^x04Chat Room^x01");
			return PLUGIN_HANDLED;
		}
		else
		{
			new iPlayer = cmd_target(id, szArgs, 8);
			if(!iPlayer)
			{
				print(id, "^x01* ^x04[Private]^x01: Invalid player name");
				return PLUGIN_HANDLED;
			}
			
			new szPlName[32];
			get_user_name(iPlayer, szPlName, sizeof szPlName - 1);
			
			if(g_iPrivateChat[iPlayer] != NO_PRIVACY)
			{				
				print(id, "^x01* ^x04[Private]^x01: ^x04%s^x01 is already in a Private Conversation", szPlName);
				return PLUGIN_HANDLED;
			}
			if(g_iPrivateRoom[iPlayer] != NO_PRIVACY)
			{
				print(id, "^x01* ^x04[Private]^x01: ^x04%s^x01 is already in a Private Room Conversation", szPlName);
				return PLUGIN_HANDLED;
			}
			print(id, "^x01* ^x04[Private]^x01: You invited ^x04%s^x01 to a Private Room Conversation", szPlName);
			RequestInvitation(id, iPlayer, g_iPrivateRoom[id]);
		}
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public clcmdHandleSayTeam(id)
{
	new szArgs[CHAT_LEN_MAX];
	read_args(szArgs, charsmax(szArgs));
	remove_quotes(szArgs);
	
	if(!strlen(szArgs))
		return PLUGIN_CONTINUE;
	
	if(g_iPrivateChat[id] != NO_PRIVACY)
	{
		new szName[32];
		get_user_name(id, szName, charsmax(szName));
		
		static szMessage[128];
		formatex(szMessage, sizeof szMessage - 1, "^x04 (Private)^x01 ^x03%s^x01 : %s", szName, szArgs);
		print_SayText(id, id, szMessage);
		print_SayText(id, g_iPrivateChat[id], szMessage);
		
		return PLUGIN_HANDLED;
	}
	
	if(g_iPrivateRoom[id] != NO_PRIVACY)
	{
		new szName[32];
		get_user_name(id, szName, charsmax(szName));
		
		static szMessage[128];
		formatex(szMessage, sizeof szMessage - 1, "^x04 (Room #%i)^x01 ^x03%s^x01 : %s",g_iPrivateRoom[id],szName, szArgs);
		
		for(new i = 1 ; i <= g_iMaxPlayers ; i++)
		{
			if(g_iPrivateRoom[i] != g_iPrivateRoom[id])
				continue;
				
			print_SayText(id, i, szMessage);
		}
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public InviteMenu_Handle(id, key)
{
	new iInviter = g_iInviter[id];
	new szName[2][32];
	
	switch(key)
	{
		case 0:
		{
			if(!g_iPrivateRoom[iInviter])
			{
				g_iPrivateChat[id] = iInviter;
				g_iPrivateChat[iInviter] = id;
				
				get_user_name(iInviter, szName[0], charsmax(szName[]));
				get_user_name(id, szName[1], charsmax(szName[]));
				
				print(iInviter, "^x01* ^x04[Private]^x01: You are entering in a Private Conversation with ^x04%s^x01", szName[1]);
				print(id, "^x01* ^x04[Private]^x01: You are entering in a Private Conversation with ^x04%s^x01", szName[0]);
				print(id, "^x01* ^x04[Private]^x01: Use your ^x04say_team key^x01 - usually ''^x04U^x01'' to chat");
			}
			else
			{
				g_iPrivateRoom[id] = g_iPrivateRoom[iInviter];
				
				get_user_name(iInviter, szName[0], charsmax(szName[]));
				
				for(new i = 1 ; i <= g_iMaxPlayers ; i++)
				{
					if(g_iPrivateRoom[i] != g_iPrivateRoom[id] || i == id)
						continue;
					print(i, "^x01* ^x04[Room %i]^x01: ^x04%s^x01 has entered the Chat Room", g_iPrivateRoom[i], szName[0]);
				}
				print(id, "^x01* ^x04[Private]^x01: You are entering private Chat Room ^x04#%d^x01 by invitation", g_iPrivateRoom[id]);
				print(id, "^x01* ^x04[Private]^x01: Use your ^x04say_team key^x01 - usually ''^x04U^x01'' to chat");
			}
		}
		case 1:
		{
			new szName[32];
			get_user_name(id, szName, charsmax(szName));
			
			print(iInviter, "^x01* ^x04[Private]^x01: ^x04%s^x01 has denied your invitation",szName);
		}
	}
	
	remove_task(id - TASK_MESSAGE)
	
	return PLUGIN_HANDLED;
}

stock ResetChaters(iRoom)
{
	for(new i = 1 ; i <= g_iMaxPlayers ; i++)
	{
		if(g_iPrivateRoom[i] != iRoom)
			continue;
		
		g_iPrivateRoom[i] = 0;
		print(i, "^x01* ^x04[Private]^x01: The owner of chat room has left. You are no longer in this chat room");
	}
}

stock RequestInvitation(inviter, target, room=0)
{
	new szMenu[128], iLen;
	new szName[32];
	get_user_name(inviter, szName, charsmax(szName));
	
	if(!room)
	{
		iLen = formatex(szMenu, charsmax(szMenu), "\yPrivate Conversation from \r%s\y^n^n", szName);
	}
	else
	{
		iLen = formatex(szMenu, charsmax(szMenu), "\yInvitation to Chat Room \r%d\y from \r%s\y^n^n", g_iPrivateRoom[inviter], szName);
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1]\w Accept^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2]\w Decline^n");
	show_menu(target, 1<<0|1<<1, szMenu, vote_time, "Invite");
	
	g_iInviter[target] = inviter;
	
	set_task(float(vote_time), "toolate_accept", target + TASK_MESSAGE)
}

public toolate_accept(id)
{
	id -= TASK_MESSAGE
	new iInviter = g_iInviter[id];	new szName[32]
	get_user_name(id, szName, charsmax(szName))
	print(iInviter, "^x01* ^x04[Private]^x01: ^x04%s^x01 didn't answer fast enough", szName);
	
}

stock print_SayText(sender, receiver, const szMessage[])
{
	static MSG_type, id;
	
	if(receiver > 0)
	{
		MSG_type = MSG_ONE_UNRELIABLE;
		id = receiver;
	}
	else
	{
		MSG_type = MSG_BROADCAST;
		id = sender;
	}
	
	message_begin(MSG_type, get_user_msgid("SayText"), _, id);
	write_byte(sender);
	write_string(szMessage);
	message_end();
	
	return 1;
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
		static players[32], count, index;
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
