/**
 *	Grenade Trail - gp_grenadetrail.sma
 *	
 *	Based on Grenade Trail v1.0 by Jim from https://forums.alliedmods.net/showthread.php?p=429750
 *		@released: 21/01/2007 (dd/mm/yyyy)
 */
#include <amxmodx>
#include <csx>

#define PLUGIN_NAME		"Grenade Trail"
#define PLUGIN_VERSION	"2016.03.19"
#define PLUGIN_AUTHOR	"X"

new g_trail, g_cvar_tr, g_cvar_he, g_cvar_fb, g_cvar_sg;

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	g_cvar_tr = register_cvar("grenade_tr", "2");
	g_cvar_he = register_cvar("grenade_he", "255000000");
	g_cvar_fb = register_cvar("grenade_fb", "999999999");
	g_cvar_sg = register_cvar("grenade_sg", "000255000");
}

public plugin_precache()
{
	g_trail = precache_model("sprites/smoke.spr");
}

public grenade_throw(id, gid, wid)
{
	new gtm = get_pcvar_num(g_cvar_tr);
	if(!gtm) return;
	
	new r, g, b;
	switch(gtm)
	{
		case 1:
		{
			r = random(256);
			g = random(256);
			b = random(256);
		}
		case 2:
		{
			new nade, color[10];
			switch(wid)
			{
				case CSW_HEGRENADE:	nade = g_cvar_he;
				case CSW_FLASHBANG:	nade = g_cvar_fb;
				case CSW_SMOKEGRENADE:	nade = g_cvar_sg;
			}
			
			get_pcvar_string(nade, color, 9);
			new c = str_to_num(color);
			r = c / 1000000;
			c %= 1000000 ;
			g = c / 1000;
			b = c % 1000;
		}
		case 3:
		{
			switch(get_user_team(id))
			{
				case 1: r = 255;
				case 2: b = 255;
			}
		}
	}
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(gid);
	write_short(g_trail);
	write_byte(10);
	write_byte(5);
	write_byte(r);
	write_byte(g);
	write_byte(b);
	write_byte(192);
	message_end();
}
