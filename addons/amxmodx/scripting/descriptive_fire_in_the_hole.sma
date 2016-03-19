#include <amxmodx>

enum grenade {
	GRENADE_HE,
	GRENADE_FLASH,
	GRENADE_SMOKE
};

new const g_grenade_description[_:grenade][] = {
	"[- HE -]",
	"[- FB -]",
	"[- SG -]"
};

enum color {
	COLOR_NORMAL,
	COLOR_RED,
	COLOR_BLUE,
	COLOR_GRAY,
	COLOR_GREEN
};

new const g_grenade_desccolor[_:grenade] = {
	COLOR_RED,
	COLOR_GRAY,
	COLOR_GREEN
};

new const g_grenade_weaponid[_:grenade] = {
	CSW_HEGRENADE,
	CSW_FLASHBANG,
	CSW_SMOKEGRENADE
};

#define COLORCODE_NORMAL 0x01
#define COLORCODE_TEAM 0x03
#define COLORCODE_LOCATION 0x04

new const g_color_code[_:color] = {
	COLORCODE_NORMAL,
	COLORCODE_TEAM,
	COLORCODE_TEAM,
	COLORCODE_TEAM,
	COLORCODE_LOCATION
};

new const g_color_teamname[_:color][] = {
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR",
	""
};

#define RADIOTEXT_MSGARG_NUMBER 5

enum radiotext_msgarg {
	RADIOTEXT_MSGARG_PRINTDEST = 1,
	RADIOTEXT_MSGARG_CALLERID,
	RADIOTEXT_MSGARG_TEXTTYPE,
	RADIOTEXT_MSGARG_CALLERNAME,
	RADIOTEXT_MSGARG_RADIOTYPE,
};

new const g_required_radiotype[] = "#Fire_in_the_hole";
new const g_radiotext_template[] = "^x04%s^x01 (RADIO): Da-te ca arunc cu ";

new g_msgid_saytext, g_msgid_teaminfo;

public plugin_init()
{
	register_plugin("[- HE-FB-SG -]", "1.0.0", "X");
	
	register_message(get_user_msgid("TextMsg"), "message_text");
	
	g_msgid_saytext = get_user_msgid("SayText");
	g_msgid_teaminfo = get_user_msgid("TeamInfo");
}

public message_text(msgid, dest, id)
{
	if(get_msg_args() != RADIOTEXT_MSGARG_NUMBER || get_msg_argtype(RADIOTEXT_MSGARG_RADIOTYPE) != ARG_STRING)
		return PLUGIN_CONTINUE;
	
	static arg[32];
	get_msg_arg_string(RADIOTEXT_MSGARG_RADIOTYPE, arg, sizeof arg - 1);
	if(!equal(arg, g_required_radiotype))
		return PLUGIN_CONTINUE;
	
	get_msg_arg_string(RADIOTEXT_MSGARG_CALLERID, arg, sizeof arg - 1);
	new caller = str_to_num(arg);
	if(!is_user_alive(caller))
		return PLUGIN_CONTINUE;
	
	new clip, ammo, weapon;
	weapon = get_user_weapon(caller, clip, ammo);
	for (new i; i < sizeof g_grenade_weaponid; ++i) {
		if(g_grenade_weaponid[i] == weapon) {
			static text[192];
			new pos = 0;
			text[pos++] = g_color_code[COLOR_NORMAL];
			
			get_msg_arg_string(RADIOTEXT_MSGARG_CALLERNAME, arg, sizeof arg - 1);
			pos += formatex(text[pos], sizeof text - pos - 1, g_radiotext_template, arg);
			copy(text[++pos], sizeof text - pos - 1, g_grenade_description[i]);
			
			new desccolor = g_grenade_desccolor[i];
			if((text[--pos] = g_color_code[desccolor]) == COLORCODE_TEAM) {
				static teamname[12];
				get_user_team(id, teamname, sizeof teamname - 1);
				
				if(!equal(teamname, g_color_teamname[desccolor])) {
					msg_teaminfo(id, g_color_teamname[desccolor]);
					msg_saytext(id, text);
					msg_teaminfo(id, teamname);
					
					return PLUGIN_HANDLED;
				}
			}
			
			msg_saytext(id, text);
			
			return PLUGIN_HANDLED;
		}
	}
	
	return PLUGIN_CONTINUE;
}

msg_teaminfo(id, teamname[])
{
	message_begin(MSG_ONE, g_msgid_teaminfo, _, id);
	write_byte(id);
	write_string(teamname);
	message_end();
}

msg_saytext(id, text[])
{
	message_begin(MSG_ONE, g_msgid_saytext, _, id);
	write_byte(id);
	write_string(text);
	message_end();
}
