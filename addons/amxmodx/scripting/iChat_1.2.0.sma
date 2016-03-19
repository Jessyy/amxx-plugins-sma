#include < amxmodx >
#include < amxmisc >
#include < hamsandwich >
#include < fakemeta >

#define ICHAT_VERSION "1.2.0"

#pragma semicolon 1

#define MAX_PLAYERS 32
#define TASK_NOTIFY 5987

#define FLAG_SPY ADMIN_LEVEL_A
#define FLAG_ADMIN ADMIN_LEVEL_B
#define FLAG_VIP ADMIN_LEVEL_C

new formatAllDefAlive[ 264 ], formatAllAdminAlive[ 264 ], formatAllVIPAlive[ 264 ];
new formatTeamDefAlive[ 264 ], formatTeamAdminAlive[ 264 ], formatTeamVIPAlive[ 264 ];
new formatAllDefDead[ 264 ], formatAllAdminDead[ 264 ], formatAllVIPDead[ 264 ];
new formatTeamDefDead[ 264 ], formatTeamAdminDead[ 264 ], formatTeamVIPDead[ 264 ];
new formatMe[ 264 ];
new formatTeamTags[ 4 ][ 36 ];

new removeOnSlash, userNotify, adminsSpy, Float:printRadiusAll, Float:printRadiusTeam, useCustomColor, iRed, iGreen, iBlue, iPunishment;
//new bool:isFirstSpawn[ 33 ];

new bool:g_bLocation;
new g_szLocation[ MAX_PLAYERS + 1 ][ 32 ];

new msgSayText, msgTeamInfo;
new allTalk;

public plugin_init( )
{
	register_plugin( "iChat", ICHAT_VERSION, "Kid" );
	
	msgSayText = get_user_msgid( "SayText" );
	msgTeamInfo = get_user_msgid( "TeamInfo" );
	
	//RegisterHam( Ham_Spawn, "player", "iChatPlayerSpawn", 1 );
	
	register_concmd( "amx_reload_ichat", "iChatConfig" );
	register_clcmd( "say", "iChatHookSayAll" );
	register_clcmd( "say_team", "iChatHookSayTeam" );
	
	new szModShortName[ 7 ];
	if ( get_modname( szModShortName, charsmax( szModShortName ) ) == 5
	&& equal( szModShortName, "czero" ) )
	{
		register_event( "Location", "iChatEventLocation", "be" );
	}
	
	register_dictionary( "iChat.txt" );
	
	new sutppCvar = register_cvar( "ichat_version", ICHAT_VERSION, FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_SPONLY );
	set_pcvar_string( sutppCvar, ICHAT_VERSION );
	
	iChatConfig( );
}

public iChatConfig( )
{
	new szCfgFile[ 128 ];
	get_configsdir( szCfgFile, charsmax( szCfgFile ) );
	formatex( szCfgFile, charsmax( szCfgFile ), "%s/ichat.cfg", szCfgFile );
	
	new fp = fopen( szCfgFile, "rt" );
	if ( !fp )
	{
		return;
	}
	
	new szLineData[ 364 ], szLineKey[ 96 ], szLineValue[ 264 ];
	while ( !feof( fp ) )
	{
		fgets( fp, szLineData, charsmax( szLineData ) );
		trim( szLineData );
		
		if ( szLineData[ 0 ] == ';' || szLineData[ 0 ] == '#' || ( szLineData[ 0 ] == '/' && szLineData[ 1 ] == '/' ) || !szLineData[ 0 ] )
		{
			continue;
		}
		
		parse( szLineData, szLineKey, charsmax( szLineKey ), szLineValue, charsmax( szLineValue ) );
		
		switch ( szLineKey[ 0 ] )
		{
			case 'F':
			{
				switch ( szLineKey[ 7 ] )
				{
					case 'D':
					{
						switch ( szLineKey[ 11 ] )
						{
							case 'A':
							{
								if ( equal( szLineKey, "FORMAT_DEF_ALIVE" ) )
								{
									copy( formatAllDefAlive, charsmax( formatAllDefAlive ), szLineValue );
								}
							}
							case 'D':
							{
								if ( equal( szLineKey, "FORMAT_DEF_DEAD" ) )
								{
									copy( formatAllDefDead, charsmax( formatAllDefDead ), szLineValue );
								}
							}
						}
					}
					case 'A':
					{
						switch ( szLineKey[ 13 ] )
						{
							case 'A':
							{
								if ( equal( szLineKey, "FORMAT_ADMIN_ALIVE" ) )
								{
									copy( formatAllAdminAlive, charsmax( formatAllAdminAlive ), szLineValue );
								}
							}
							case 'D':
							{
								if ( equal( szLineKey, "FORMAT_ADMIN_DEAD" ) )
								{
									copy( formatAllAdminDead, charsmax( formatAllAdminDead ), szLineValue );
								}
							}
						}
					}
					case 'V':
					{
						switch ( szLineKey[ 11 ] )
						{
							case 'A':
							{
								if ( equal( szLineKey, "FORMAT_VIP_ALIVE" ) )
								{
									copy( formatAllVIPAlive, charsmax( formatAllVIPAlive ), szLineValue );
								}
							}
							case 'D':
							{
								if ( equal( szLineKey, "FORMAT_VIP_DEAD" ) )
								{
									copy( formatAllVIPDead, charsmax( formatAllVIPDead ), szLineValue );
								}
							}
						}
					}
					case 'T':
					{
						switch ( szLineKey[ 12 ] )
						{
							case 'D':
							{
								switch ( szLineKey[ 16 ] )
								{
									case 'A':
									{
										if ( equal( szLineKey, "FORMAT_TEAM_DEF_ALIVE" ) )
										{
											copy( formatTeamDefAlive, charsmax( formatTeamDefAlive ), szLineValue );
										}
									}
									case 'D':
									{
										if ( equal( szLineKey, "FORMAT_TEAM_DEF_DEAD" ) )
										{
											copy( formatTeamDefDead, charsmax( formatTeamDefDead ), szLineValue );
										}
									}
								}
							}
							case 'A':
							{
								switch ( szLineKey[ 18 ] )
								{
									case 'A':
									{
										if ( equal( szLineKey, "FORMAT_TEAM_ADMIN_ALIVE" ) )
										{
											copy( formatTeamAdminAlive, charsmax( formatTeamAdminAlive ), szLineValue );
										}
									}
									case 'D':
									{
										if ( equal( szLineKey, "FORMAT_TEAM_ADMIN_DEAD" ) )
										{
											copy( formatTeamAdminDead, charsmax( formatTeamAdminDead ), szLineValue );
										}
									}
								}
							}
							case 'V':
							{
								switch ( szLineKey[ 16 ] )
								{
									case 'A':
									{
										if ( equal( szLineKey, "FORMAT_TEAM_VIP_ALIVE" ) )
										{
											copy( formatTeamVIPAlive, charsmax( formatTeamVIPAlive ), szLineValue );
										}
									}
									case 'D':
									{
										if ( equal( szLineKey, "FORMAT_TEAM_VIP_DEAD" ) )
										{
											copy( formatTeamVIPDead, charsmax( formatTeamVIPDead ), szLineValue );
										}
									}
								}
							}
						}
					}
					case 'M':
					{
						if ( equal( szLineKey, "FORMAT_ME" ) )
						{
							copy( formatMe, charsmax( formatMe ), szLineValue );
						}
					}
				}
			}
			case 'C':
			{
				switch ( szLineKey[ 5 ] )
				{
					case 'C':
					{
						if ( equal( szLineKey, "CHAT_CLCMD_REMOVE" ) )
						{
							removeOnSlash = str_to_num( szLineValue );
						}
					}
					case 'A':
					{
						switch ( szLineKey[ 6 ] )
						{
							case 'D':
							{
								if ( equal( szLineKey, "CHAT_ADMIN_SPY" ) )
								{
									adminsSpy = str_to_num( szLineValue );
								}
							}
							case 'L':
							{
								if ( equal( szLineKey, "CHAT_ALL_TALK" ) )
								{
									allTalk = str_to_num( szLineValue );
								}
							}
						}
					}
					case 'D':
					{
						if ( equal( szLineKey, "CHAT_DEFAULT_COLOR" ) )
						{
							new iColor = str_to_num( szLineValue );
							if ( iColor < 0 || iColor > 255255255 )
							{
								useCustomColor = 0;
							}
							else
							{
								useCustomColor = 1;
								iRed = iColor / 1000000;
								iColor %= 1000000;
								iGreen = iColor / 1000;
								iBlue = iColor % 1000;
							}
						}
					}
					case 'P':
					{
						if ( equal( szLineKey, "CHAT_PUNISHMENT" ) )
						{
							iPunishment = str_to_num( szLineValue );
							if ( iPunishment > 1 || iPunishment < 0 )
							{
								iPunishment = 1;
							}
						}
					}
					case 'N':
					{
						if ( equal( szLineKey, "CHAT_NOTIFY" ) )
						{
							userNotify = str_to_num( szLineValue );
						}
					}
					case 'R':
					{
						switch ( szLineKey[ 12 ] )
						{
							case 'A':
							{
								if ( equal( szLineKey, "CHAT_RADIUS_ALL" ) )
								{
									printRadiusAll = str_to_float( szLineValue );
								}
							}
							case 'T':
							{
								if ( equal( szLineKey, "CHAT_RADIUS_TEAM" ) )
								{
									printRadiusTeam = str_to_float( szLineValue );
								}
							}
						}
					}
					case 'T':
					{
						switch ( szLineKey[ 14 ] )
						{
							case '1':
							{
								if ( equal( szLineKey, "CHAT_TEAM_TAG_1" ) )
								{
									copy( formatTeamTags[ 1 ], charsmax( formatTeamTags[ ] ), szLineValue );
								}
							}
							case '2':
							{
								if ( equal( szLineKey, "CHAT_TEAM_TAG_2" ) )
								{
									copy( formatTeamTags[ 2 ], charsmax( formatTeamTags[ ] ), szLineValue );
								}
							}
							case '3':
							{
								if ( equal( szLineKey, "CHAT_TEAM_TAG_3" ) )
								{
									copy( formatTeamTags[ 3 ], charsmax( formatTeamTags[ ] ), szLineValue );
								}
							}
						}
					}
				}
			}
		}
	}
	fclose( fp );
}

public iChatHookSayAll( id )
{
	new szSaid[ 128 ], iLen;
	iLen = charsmax( szSaid );
	read_args( szSaid, iLen );
	remove_quotes( szSaid );
	
	if ( iChatIsChatValid( szSaid ) )
	{
		iChatSendToHLSW( id, szSaid, 0 );
	}
	
	if ( contain( szSaid, "!me " ) == 0 )
	{
		iChatMeCommand( id, szSaid, iLen );
		return PLUGIN_HANDLED_MAIN;
	}
	
	if ( !is_user_connected( id )
	|| ( !szSaid[ 0 ] )
	|| ( ( removeOnSlash && ( szSaid[ 0 ] == '/' || szSaid[ 0 ] == '@' || szSaid[ 0 ] == '!' ) ) || szSaid[ 0 ] == ' ' ) )
	{
		return PLUGIN_HANDLED_MAIN;
	}
	
	new iAlive = is_user_alive( id );
	
	new szMessage[ 496 ], iColor[ 16 ], szTeam[ 16 ];
	get_user_team( id, szTeam, charsmax( szTeam ) );
	
	iChatFormatMessage( id, iAlive, 0, 0, szSaid, charsmax( szMessage ), szMessage, charsmax( iColor ), iColor );
	
	iChatChangeTeamInfo( id, iColor, allTalk );
	
	if ( allTalk )
	{
		iChatMessageAll( id, szMessage );
	}
	else
	{
		iChatMessageRest( id, iAlive, 0, szMessage );
	}
	
	iChatChangeTeamInfo( id, szTeam, allTalk );
	
	return PLUGIN_HANDLED_MAIN;
}

public iChatHookSayTeam( id )
{
	new szSaid[ 128 ];
	read_args( szSaid, charsmax( szSaid ) );
	remove_quotes( szSaid );
	
	if ( iChatIsChatValid( szSaid ) )
	{
		iChatSendToHLSW( id, szSaid, 1 );
	}
	
	if ( !is_user_connected( id )
	|| ( !szSaid[ 0 ] )
	|| ( ( removeOnSlash && ( szSaid[ 0 ] == '/' || szSaid[ 0 ] == '@' || szSaid[ 0 ] == '!' ) ) || szSaid[ 0 ] == ' ' ) )
	{
		return PLUGIN_HANDLED_MAIN;
	}
	
	new iAlive = is_user_alive( id );
	
	new szMessage[ 496 ], iColor[ 16 ], szTeam[ 16 ];
	get_user_team( id, szTeam, charsmax( szTeam ) );
	
	iChatFormatMessage( id, iAlive, 1, 0, szSaid, charsmax( szMessage ), szMessage, charsmax( iColor ), iColor );
	
	iChatChangeTeamInfo( id, iColor, 0 );
	
	iChatMessageRest( id, iAlive, 1, szMessage );
	
	iChatChangeTeamInfo( id, szTeam, 0 );
	
	return PLUGIN_HANDLED_MAIN;
}

public iChatMeCommand( id, szSaid[ ], iLen )
{
	new szMessage[ 496 ], iColor[ 16 ], szTeam[ 16 ];
	get_user_team( id, szTeam, charsmax( szTeam ) );
	replace_all( szSaid, iLen, "!me ", " " );
	
	iChatFormatMessage( id, 1, 0, 1, szSaid, charsmax( szMessage ) , szMessage, charsmax( iColor ), iColor );
	
	iChatChangeTeamInfo( id, iColor, 1 );
	
	iChatMessageAll( id, szMessage );
	
	iChatChangeTeamInfo( id, szTeam, 1 );
}

public iChatFormatMessage( id, iAlive, sayTeam, meCmd, const szSaid[ ], iLen, szMessage[ ], cLen, iColor[ ] )
{
	new iName[ 32 ], iSTEAMID[ 36 ], iLife, szLife[ 16 ], iTeam, iFlags;
	
	get_user_name( id, iName, charsmax( iName ) );
	get_user_authid( id, iSTEAMID, charsmax( iSTEAMID ) );
	iLife = get_user_health( id );
	num_to_str( iLife, szLife, charsmax( szLife ) );
	iTeam = get_user_team( id );
	
	if ( meCmd )
	{
		copy( szMessage, iLen, formatMe );
	}
	else
	{
		iFlags = get_user_flags( id );
		new modeFormat = 0;
		if ( iFlags & FLAG_ADMIN )
		{
			modeFormat = 1;
		}
		else if ( iFlags & FLAG_VIP )
		{
			modeFormat = 2;
		}
		
		switch ( modeFormat )
		{
			case 0:
			{
				if ( sayTeam )
				{
					if ( iAlive )
					{
						copy( szMessage, iLen, formatTeamDefAlive );
					}
					else
					{
						copy( szMessage, iLen, formatTeamDefDead );
					}
				}
				else
				{
					if ( iAlive )
					{
						copy( szMessage, iLen, formatAllDefAlive );
					}
					else
					{
						copy( szMessage, iLen, formatAllDefDead );
					}
				}
			}
			case 1:
			{
				if ( sayTeam )
				{
					if ( iAlive )
					{
						copy( szMessage, iLen, formatTeamAdminAlive );
					}
					else
					{
						copy( szMessage, iLen, formatTeamAdminDead );
					}
				}
				else
				{
					if ( iAlive )
					{
						copy( szMessage, iLen, formatAllAdminAlive );
					}
					else
					{
						copy( szMessage, iLen, formatAllAdminDead );
					}
				}
			}
			case 2:
			{
				if ( sayTeam )
				{
					if ( iAlive )
					{
						copy( szMessage, iLen, formatTeamVIPAlive );
					}
					else
					{
						copy( szMessage, iLen, formatTeamVIPDead );
					}
				}
				else
				{
					if ( iAlive )
					{
						copy( szMessage, iLen, formatAllVIPAlive );
					}
					else
					{
						copy( szMessage, iLen, formatAllVIPDead );
					}
				}
			}
		}
	}
	
	replace_all( szMessage, iLen, "%TEAMTAG%", formatTeamTags[ iTeam ] );
	
	replace_all( szMessage, iLen, "<default>", "^x01" );
	replace_all( szMessage, iLen, "<green>", "^x04" );
	
	
	if ( contain( szMessage, "<red>" ) != -1 )
	{
		copy( iColor, cLen, "TERRORIST" );
	}
	else if ( contain( szMessage, "<blue>" ) != -1 )
	{
		copy( iColor, cLen, "CT" );
	}
	else if ( contain( szMessage, "<grey>" ) != -1 )
	{
		copy( iColor, cLen, "SPECTATOR" );
	}
	else
	{
		new szTempTeam[ 16 ];
		get_user_team( id, szTempTeam, cLen );
		copy( iColor, cLen, szTempTeam );
	}
	replace_all( szMessage, iLen, "<team>", "^x03" );
	replace_all( szMessage, iLen, "<red>", "^x03" );
	replace_all( szMessage, iLen, "<blue>", "^x03" );
	replace_all( szMessage, iLen, "<grey>", "^x03" );
	
	replace_all( szMessage, iLen, "%STEAMID%", iSTEAMID );
	replace_all( szMessage, iLen, "%LIFE%", szLife );
	replace_all( szMessage, iLen, "%POS%", g_bLocation ? g_szLocation[ id ] : "" );
	
	new szTeamTemp[ 32 ], szLangOpt[ 16 ];
	formatex( szLangOpt, charsmax( szLangOpt ), "TEAM%i", iTeam );
	formatex( szTeamTemp, charsmax( szTeamTemp ), "%L", LANG_SERVER, szLangOpt );
	replace_all( szMessage, iLen, "%TEAM%", szTeamTemp );
	
	replace_all( szMessage, iLen, "%NAME%", iName );
	replace_all( szMessage, iLen, "%MESSAGE%", szSaid );
}

public iChatMessageAll( id, const szMessage[ ] )
{
	message_begin( MSG_BROADCAST, msgSayText );
	write_byte( id );
	write_string( szMessage );
	message_end( );
}

public iChatMessageRest( id, iAlive, teamMessage, const szMessage[ ] )
{
	new iTeam = get_user_team( id );
	
	new iPlayers[ MAX_PLAYERS ], iNum, tid, i;
	get_players( iPlayers, iNum );
	for ( i = 0; i < iNum; i++ )
	{
		tid = iPlayers[ i ];
		new tAlive = is_user_alive( tid ), tTeam, teamCheck, radiusCheck;
		if ( teamMessage )
		{
			tTeam = get_user_team( tid );
		}
		
		teamCheck = ( !teamMessage || ( iTeam == tTeam ) );
		radiusCheck = iChatIsInRadius( id, tid, teamMessage, iAlive, tAlive );
		
		if ( ( ( allTalk || ( iAlive && tAlive ) ) && teamCheck && radiusCheck )
		|| ( ( allTalk || ( !iAlive && !tAlive ) ) && teamCheck && radiusCheck )
		|| ( adminsSpy && ( get_user_flags( tid ) & FLAG_SPY ) )
		|| ( is_user_hltv( tid ) ) )
		{
			message_begin( MSG_ONE, msgSayText, _, tid );
			write_byte( id );
			write_string( szMessage );
			message_end( );
		}
	}
}

public iChatIsInRadius( iSender, iReceiver, teamMessage, iSenderAlive, iReceiverAlive )
{
	new Float:fliSenderOrigin[ 3 ], Float:fliRecieverOrigin[ 3 ], Float:fliDistance, Float:maxRadius;
	pev( iSender, pev_origin, fliSenderOrigin );
	pev( iReceiver, pev_origin, fliRecieverOrigin );
	fliDistance = get_distance_f( fliSenderOrigin, fliRecieverOrigin );
	
	if ( teamMessage )
	{
		maxRadius = printRadiusTeam;
	}
	else
	{
		maxRadius = printRadiusAll;
	}
	
	if ( fliDistance <= maxRadius || maxRadius <= 0 || !iSenderAlive || !iReceiverAlive )
	{
		return 1;
	}
	return 0;
}

public iChatEventLocation( id )
{
	g_bLocation = true;
	if ( read_data( 1 ) == id )
	{
		read_data( 2, g_szLocation[ id ], charsmax( g_szLocation[ ] ) );
	}
}

public client_putinserver( id )
{
	if ( userNotify )
	{
		set_task( 15.0, "iChatNotify", id + TASK_NOTIFY );
	}
	//isFirstSpawn[ id ] = true;
}

public client_connect( id )
{
	if ( useCustomColor && is_user_connected( id ) && !is_user_bot( id ) )
	{
		client_cmd( id, "con_color ^"%i %i %i^"", iRed, iGreen, iBlue );
	}
}
/*
public iChatPlayerSpawn( id )
{
	if ( useCustomColor && is_user_connected( id ) && !is_user_bot( id ) && isFirstSpawn[ id ] )
	{
		iChatAskChangeCvar( id );
	}
	isFirstSpawn[ id ] = false;
}

public iChatAskChangeCvar( id )
{
	new menuFormat[ 164 ], iLen = charsmax( menuFormat );
	formatex( menuFormat, iLen, "%L", id, "MENU_TITLE", iRed, iGreen, iBlue );
	new askMenu = menu_create( menuFormat, "iChatAskMenuHandler" );
	new menuAction[ 16 ];
	formatex( menuAction, charsmax( menuAction ), "MENU_ACTION%i", iPunishment );
	formatex( menuFormat, iLen, "%L %L", id, "MENU_NO", id, menuAction );
	menu_additem( askMenu, menuFormat );
	formatex( menuFormat, iLen, "%L", id, "MENU_YES" );
	menu_additem( askMenu, menuFormat );
	
	menu_setprop( askMenu, MPROP_EXIT, MEXIT_NEVER );
	menu_display( id, askMenu );
}

public iChatAskMenuHandler( id, menu, item )
{
	if ( ( item == MENU_EXIT || item == 0 ) && iPunishment )
	{
		new userId = get_user_userid( id );
		server_cmd( "kick #%d ^"%L^"", userId, id, "KICK_REASON" );
	}
	else
	{
		client_cmd( id, "con_color ^"%i %i %i^"", iRed, iGreen, iBlue );
	}
}
*/
public iChatIsChatValid( const szChat[ ] )
{
	new c, i;
	while ( ( c = szChat[ i++ ] ) != EOS )
	{
		if ( c != ' ' )
		{
			return 1;
		}
	}
	return 0;
}

public iChatSendToHLSW( id, const szSaid[ ], teamMessage )
{
	new szName[ 32 ], szAuthid[ 32 ], szTeam[ 10 ];
	get_user_name( id, szName, charsmax( szName ) );
	get_user_team( id, szTeam, charsmax( szTeam ) );
	get_user_authid( id, szAuthid, charsmax( szAuthid ) );
	if( szTeam[ 0 ] == 'U' )
	{
		szTeam[ 0 ] = EOS;
	}
	log_message( "^"%s<%d><%s><%s>^" %s ^"%s^"%s", szName, get_user_userid( id ), szAuthid, szTeam, ( teamMessage ? "say_team" : "say" ), szSaid, is_user_alive( id ) ? "" : " (dead)" );
}

public iChatChangeTeamInfo( id, const iColor[ ], toAll )
{
	message_begin( toAll ? MSG_BROADCAST : MSG_ONE, msgTeamInfo, _, id );
	write_byte( id );
	write_string( iColor );
	message_end( );
}

public iChatNotify( id )
{
	id -= TASK_NOTIFY;
	
	message_begin( MSG_ONE, msgSayText, _, id );
	write_byte( id );
	write_string( "^x04[iChat]^x01 This server is using ^x03iChat^x01 by ^x03Kid^x01. Download link in your console." );
	message_end( );
	client_print( id, print_console, "[iChat] Download 'iChat' by Kid at 'https://forums.alliedmods.net/showthread.php?t=173113'." );
	client_print( id, print_console, "[iChat] Or on GitHub at 'https://github.com/Kid-/iChat'" );
}
