/**
 *	C4 Blast - gp_c4blast.sma
 *	
 *	Based on Bomb Blast v0.4 by K.K.Lv from https://forums.alliedmods.net/showthread.php?p=1201074
 *		@released: 03/11/2010 (dd/mm/yyyy)
 */
#include <amxmodx>
#include <fakemeta>
#include <csx>

#define PLUGIN_NAME		"C4 Blast"
#define PLUGIN_VERSION	"2016.03.19"
#define PLUGIN_AUTHOR	"X"

new gSpriteCircle, gC4Timer;
new Float:fOrigin[3], iOrigin[3];

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	register_logevent("RoundEnd", 2, "1=Round_End");
	register_logevent("RoundEnd", 2, "1&Restart_Round_");
}

public plugin_precache()
{
	gSpriteCircle = precache_model("sprites/shockwave.spr");
}

public bomb_planted(planter)
{
	gC4Timer = get_cvar_num("mp_c4timer");
	
	set_task(1.0, "bomb_blast", 1987);
	set_task(1.0, "dist_time", 1990, "", 0, "b");
}

public bomb_blast()
{
	new c4 = -1;
	while((c4 = engfunc(EngFunc_FindEntityByString, c4, "classname", "grenade"))) {
		if(get_pdata_int(c4, 96)&(1 << 8)) {
			create_blast_circle(c4);
		}
	}
	
	set_task(0.5, "bomb_blast", 1987);
}

public dist_time()
{
	--gC4Timer;
}

public RoundEnd()
{
	remove_task(1987);
	remove_task(1990);
}

stock create_blast_circle(ent)
{
	pev(ent, pev_origin, fOrigin);
	FVecIVec(fOrigin, iOrigin);
	
	static r, g, b;
	if(gC4Timer ==  0)	{ r = 250; g = 0;   b = 0;   }
	else if(gC4Timer ==  1) { r = 250; g = 0;   b = 0;   }
	else if(gC4Timer ==  2) { r = 250; g = 0;   b = 0;   }
	else if(gC4Timer ==  3) { r = 250; g = 25;  b = 0;   }
	else if(gC4Timer ==  4) { r = 250; g = 50;  b = 0;   }
	else if(gC4Timer ==  5) { r = 250; g = 75;  b = 0;   }
	else if(gC4Timer ==  6) { r = 250; g = 100; b = 0;   }
	else if(gC4Timer ==  7) { r = 250; g = 125; b = 0;   }
	else if(gC4Timer ==  8) { r = 250; g = 150; b = 0;   }
	else if(gC4Timer ==  9) { r = 250; g = 175; b = 0;   }
	else if(gC4Timer == 10) { r = 250; g = 200; b = 0;   }
	else if(gC4Timer == 11) { r = 250; g = 225; b = 0;   }
	else			{ r = 255; g = 255; b = 255; }
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, iOrigin); 
	write_byte(TE_BEAMCYLINDER);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2] + 50 + gC4Timer);
	write_short(gSpriteCircle);
	write_byte(0);
	write_byte(1);
	write_byte(6);
	write_byte(8);
	write_byte(1);
	write_byte(r);
	write_byte(g);
	write_byte(b);
	write_byte(128);
	write_byte(5);
	message_end();
}
