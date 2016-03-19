#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#define PLUGIN	"Team Semiclip"
#define VERSION	"1.31"
#define AUTHOR	"X"

new bool:plrSolid[33]
new bool:plrRestore[33]
new plrTeam[33]

new maxplayers

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	maxplayers = get_maxplayers()
	register_forward(FM_PlayerPreThink, "preThink")
	register_forward(FM_PlayerPostThink, "postThink")
	register_forward(FM_AddToFullPack, "addToFullPack", 1)
}

public addToFullPack(es, e, ent, host, hostflags, player, pSet)
{
	if(player) {
		if(plrSolid[host] && plrSolid[ent] && plrTeam[host] == plrTeam[ent]) {
			set_es(es, ES_Solid, SOLID_NOT)
			set_es(es, ES_RenderMode, kRenderTransAlpha)
			set_es(es, ES_RenderAmt, 150)
		}
	}
}

FirstThink()
{
	for(new i = 1; i <= maxplayers; i++) {
		if(!is_user_alive(i)) {
			plrSolid[i] = false
			continue
		}
		
		plrTeam[i] = get_user_team(i)
		plrSolid[i] = pev(i, pev_solid) == SOLID_SLIDEBOX ? true : false
	}
}

public preThink(id)
{
	static i, LastThink
	
	if(LastThink > id) {
		FirstThink()
	}
	LastThink = id
	
	if(!plrSolid[id]) return
	
	for(i = 1; i <= maxplayers; i++) {
		if(!plrSolid[i] || id == i) continue
		
		if(plrTeam[i] == plrTeam[id]) {
			set_pev(i, pev_solid, SOLID_NOT)
			plrRestore[i] = true
		}
	}
}

public postThink(id)
{
	static i
	
	for(i = 1; i <= maxplayers; i++) {
		if(plrRestore[i]) {
			set_pev(i, pev_solid, SOLID_SLIDEBOX)
			plrRestore[i] = false
		}
	}
}
