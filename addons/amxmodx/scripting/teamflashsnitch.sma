#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#define TEMPENTITY	"23"
#define BLINDED_FULLY	255
#define BLINDED_PARTLY	200
#define TASK_MESSAGE	11100

new Float:FLASH_TIMER = 1.52	// Time from throwing a FB to the bang (1.52 seconds)
new g_flasher = 0		// id of the flasher

public plugin_init()
{ 
	register_plugin("Team Flash Snitch", "1.1", "Tender")
	
	register_event("ScreenFade", "event_blinded", "be", "4=255", "5=255", "6=255", "7>199")
	register_event(TEMPENTITY, "event_flashsmokepuff", "a", "1=5", "6=25", "7=6")
	register_forward(FM_SetModel, "forward_setmodel")
}

public event_blinded(const ID)
{
	new alpha = read_data(7)
	if (alpha != BLINDED_FULLY && alpha != BLINDED_PARTLY || !is_user_alive(ID))
		return PLUGIN_CONTINUE
	
	if(get_user_team(ID) == get_user_team(g_flasher) && ID != g_flasher)
	{
		new szMsg[256], flasher[32], name[32], iType
		get_user_name(g_flasher, flasher, 31)
		get_user_name(ID, name, 31)
		
		format(szMsg, 127, "[Team Flash Snitch] You've been %steamflashed by %s", alpha == BLINDED_FULLY ? "totally " : "", flasher)
		if(get_user_team(ID) == 1) { iType = 2; } else if(get_user_team(ID) == 2) { iType = 4; }
		Create_TutorMsg(ID, szMsg, 0, 0, 0, iType)
	}
	else if(get_user_team(ID) != get_user_team(g_flasher) && ID != g_flasher)
	{
		new szMsg[256], flasher[32], name[32], iType
		get_user_name(g_flasher, flasher, 31)
		get_user_name(ID, name, 31)
		
		format(szMsg, 127, "[Team Flash Snitch] You've been %sflashed by %s", alpha == BLINDED_FULLY ? "totally " : "", flasher)
		if(get_user_team(g_flasher) == 1) { iType = 2; } else if(get_user_team(g_flasher) == 2) { iType = 4; }
		Create_TutorMsg(ID, szMsg, 0, 0, 0, iType)
	}
	
	return PLUGIN_CONTINUE
}

stock Create_TutorMsg(id, szMsg[], byte1, short1, short2, iType)
{
	message_begin(MSG_ONE, get_user_msgid("TutorClose"), {0, 0, 0}, id)
	message_end()
	
	message_begin(MSG_ONE, get_user_msgid("TutorText"), {0, 0, 0}, id)
	write_string(szMsg)
	write_byte(byte1)
	write_short(short1)
	write_short(short2)
	write_short(iType)
	message_end()
	
	remove_task(id + TASK_MESSAGE)
	set_task(8.0, "reset_message", id + TASK_MESSAGE)
}

public reset_message(id)
{
	id -= TASK_MESSAGE
	message_begin(MSG_ONE, get_user_msgid("TutorClose"), {0, 0, 0}, id)
	message_end()
}

public event_flashsmokepuff()
{
	set_task(0.05, "reset_flasher")
	return PLUGIN_CONTINUE
}

public reset_flasher()
{ 
	g_flasher = 0
}

public forward_setmodel(const ENTITY, model[])
{
	if (!equal(model, "models/w_flashbang.mdl"))
		return FMRES_IGNORED
	
	new owner = pev(ENTITY, pev_owner)
	if (owner == 0)
		return FMRES_IGNORED
	
	set_task(FLASH_TIMER,"get_flasher", 524627+owner)
	
	return FMRES_IGNORED
}

public get_flasher(id)
{
	g_flasher = (id - 524627)
}

public plugin_precached()
{
	precache_generic("resource/TutorScheme.res");
	precache_generic("resource/UI/TutorTextWindow.res");
	
	precache_generic("gfx/career/icon_!.tga");
	precache_generic("gfx/career/icon_i.tga");
	precache_generic("gfx/career/icon_skulls.tga");
	precache_generic("gfx/career/icon_!-bigger.tga");
	precache_generic("gfx/career/icon_i-bigger.tga");
	
	precache_generic("gfx/career/round_corner_ne.tga");
	precache_generic("gfx/career/round_corner_nw.tga");
	precache_generic("gfx/career/round_corner_se.tga");
	precache_generic("gfx/career/round_corner_sw.tga");
}
