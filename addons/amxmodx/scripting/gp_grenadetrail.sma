/**
 *	Grenade Trail - gp_grenadetrail.sma
 *
 *	Based on Grenade Trail v1.0 by Jim from https://forums.alliedmods.net/showthread.php?p=429750
 *		@released: 21/01/2007 (dd/mm/yyyy)
 */
#include <amxmodx>
#include <csx>

#define PLUGIN_NAME		"Grenade Trail"
#define PLUGIN_VERSION	"2017.06.24"
#define PLUGIN_AUTHOR	"X"

new g_trail, g_pTrailTR, g_pTrailHE, g_pTrailFB, g_pTrailSG;

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	g_pTrailTR = register_cvar("amx_grenade_tr", "2");				// <0/1/2/3> - Disabled / Random Colors / Nade Specific / Team Specific
	g_pTrailHE = register_cvar("amx_grenade_he", "255000000");		// <RRRGGGBBB> - Set the trail color of Hegrenade
	g_pTrailFB = register_cvar("amx_grenade_fb", "999999999");		// <RRRGGGBBB> - Set the trail color of Flashbang
	g_pTrailSG = register_cvar("amx_grenade_sg", "000255000");		// <RRRGGGBBB> - Set the trail color of Smokegrenade
}

public plugin_precache()
{
	g_trail = precache_model("sprites/smoke.spr");
}

public grenade_throw(id, gid, wid)
{
	new iMode = get_pcvar_num(g_pTrailTR);
	if(!iMode || iMode > 3) {
		return PLUGIN_CONTINUE;
	}

	new iRed, iGreen, iBlue;
	switch(iMode)
	{
		case 1: {
			iRed = random(256);
			iGreen = random(256);
			iBlue = random(256);
		}
		case 2: {
			new iNade, szColor[10], iColor;
			switch(wid)
			{
				case CSW_HEGRENADE: {
					iNade = g_pTrailHE;
				}
				case CSW_FLASHBANG: {
					iNade = g_pTrailFB;
				}
				case CSW_SMOKEGRENADE: {
					iNade = g_pTrailSG;
				}
			}

			get_pcvar_string(iNade, szColor, charsmax(szColor));
			iColor = str_to_num(szColor);
			iRed = iColor / 1000000;
			iColor %= 1000000;
			iGreen = iColor / 1000;
			iBlue = iColor % 1000;
		}
		case 3: {
			switch(get_user_team(id))
			{
				case 1: {
					iRed = 255;
					iGreen = 0;
					iBlue = 0;
				}
				case 2: {
					iRed = 0;
					iGreen = 0;
					iBlue = 255;
				}
			}
		}
	}

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(gid);
	write_short(g_trail);
	write_byte(10);
	write_byte(5);
	write_byte(iRed);
	write_byte(iGreen);
	write_byte(iBlue);
	write_byte(192);
	message_end();

	return PLUGIN_CONTINUE;
}
