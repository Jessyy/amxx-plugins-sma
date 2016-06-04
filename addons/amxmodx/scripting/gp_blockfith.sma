/**
 *	Block Fire.In.The.Hole Audio/Msg - gp_blockfith.sma
 *	
 *	Based on FITH Blocker v1.0 by VEN from https://forums.alliedmods.net/showpost.php?p=250576&postcount=6
 *		@released: 03/06/2006 (dd/mm/yyyy)
 *	
 *	Based on Fire in the hole blocker v1.0 by xPaw from https://forums.alliedmods.net/showpost.php?p=1127588&postcount=4
 *		@released: 24/03/2010 (dd/mm/yyyy)
 */
#include <amxmodx>
#include <cstrike>
#include <amxmisc>

#define PLUGIN_NAME		"Block Fire.In.The.Hole Audio/Msg"
#define PLUGIN_VERSION	"2016.03.19"
#define PLUGIN_AUTHOR	"X"

enum _:CvarBits (<<=1) {
    BLOCK_RADIO = 1,
    BLOCK_MSG
};

/*
0 - Nothing is blocked.
1 - Radio is blocked.
2 - Message is blocked.
3 - Radio and message is blocked.
*/
new g_pCvar;

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	g_pCvar = register_cvar("sv_blockfith", "3");

	register_message(get_user_msgid("TextMsg"), "EventFnc_TextMsg");
	register_message(get_user_msgid("SendAudio"), "EventFnc_SendAudio");
}

public EventFnc_TextMsg()
{
	if(is_running("czero")) {
		if(get_msg_args() != 6 || get_msg_argtype(6) != ARG_STRING)
			return PLUGIN_CONTINUE;
		
		new arg6[20];
		get_msg_arg_string(6, arg6, 19);
		
		if(equal(arg6, "#Fire_in_the_hole"))
			return PLUGIN_HANDLED;
	}
	else {
		if(get_msg_args() != 5 || get_msg_argtype(5) != ARG_STRING)
			return PLUGIN_CONTINUE;
		
		new arg5[20];
		get_msg_arg_string(5, arg5, 19);
		
		if(equal(arg5, "#Fire_in_the_hole"))
			return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE;
}

public EventFnc_SendAudio()
{
	if(get_msg_args() != 3 || get_msg_argtype(2) != ARG_STRING)
		return PLUGIN_CONTINUE;
	
	new arg2[20];
	get_msg_arg_string(2, arg2, 19);
	
	if(equal(arg2[1], "!MRAD_FIREINHOLE"))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

bool:IsBlocked(const iType)
{
	return bool:(get_pcvar_num(g_pCvar) & iType);
}

GetReturnValue(iParam, const szString[])
{
	new szTemp[18];
	get_msg_arg_string(iParam, szTemp, 17);
	return(equal(szTemp, szString) ? PLUGIN_HANDLED : PLUGIN_CONTINUE);
}
