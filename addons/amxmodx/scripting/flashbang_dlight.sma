#include <amxmodx>
#include <fakemeta>
#include <cstrike>
#include <fun>

new enabled_cvar, radius_cvar, color_cvar, gmsgScreenFade, cvNoBlind, cvRefresh, maxPlayers;

public plugin_init()
{
	register_plugin("Flashbang Dynamic Light", "1.0.0", "X");
	register_forward(FM_EmitSound, "fw_emitsound");
	
	enabled_cvar = register_cvar("fbl_enabled", "1");
	radius_cvar = register_cvar("fbl_radius", "50");
	color_cvar = register_cvar("fbl_color", "255 255 255");
	
	cvNoBlind = register_cvar("fbl_noblind", "0");
	cvRefresh = register_cvar("fbl_refresh", "0.0");
	
	gmsgScreenFade = get_user_msgid("ScreenFade");
	register_event("ScreenFade", "event_flash", "be", "1>0", "2>0", "3=0", "4=255", "5=255", "6=255", "7>199");
	maxPlayers = get_maxplayers();
	
	set_task(10.0,"refresh_nades");
}

public event_flash(id)
{
	if(!get_pcvar_num(enabled_cvar) || !get_pcvar_num(cvNoBlind))
		return;
	
	message_begin(MSG_ONE, gmsgScreenFade, _, id);
	write_short(0);
	write_short(0);
	write_short(1<<2);
	write_byte(0);
	write_byte(0);
	write_byte(0);
	write_byte(0);
	message_end();
}

public refresh_nades(id)
{
	new Float:time = get_pcvar_float(cvRefresh);
	if(time <= 0.0 || !get_pcvar_num(enabled_cvar)) {
		set_task(30.0, "refresh_nades");
		return;
	}
	set_task(time, "refresh_nades");
	
	for(new i = 1; i <= maxPlayers; i++) {
		if(is_user_alive(i) && !cs_get_user_bpammo(i, CSW_FLASHBANG))
			give_item(i, "weapon_flashbang")
	}
}

public fw_emitsound(entity, channel, const sample[], Float:volume, Float:attenuation, fFlags, pitch)
{
	if(!get_pcvar_num(enabled_cvar))
		return FMRES_IGNORED;
	
	if(!equali(sample, "weapons/flashbang-1.wav") && !equali(sample, "weapons/flashbang-2.wav"))
		return FMRES_IGNORED;
	
	flashbang_explode(entity);
	
	return FMRES_IGNORED;
}

public flashbang_explode(greindex)
{
	if(!pev_valid(greindex))
		return;
	
	new Float:origin[3];
	pev(greindex, pev_origin, origin);
	
	new color[16];
	get_pcvar_string(color_cvar, color, 15);
	
	new redamt[5], greenamt[5], blueamt[5];
	parse(color, redamt, 4, greenamt, 4, blueamt, 4);
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(27);
	write_coord(floatround(origin[0]));
	write_coord(floatround(origin[1]));
	write_coord(floatround(origin[2]));
	write_byte(get_pcvar_num(radius_cvar));
	write_byte(str_to_num(redamt));
	write_byte(str_to_num(greenamt));
	write_byte(str_to_num(blueamt));
	write_byte(8);
	write_byte(60);
	message_end();
}
