#include <amxmodx>
#include <amxmisc>

#define MAX_GROUPS 7

new g_groupNames[MAX_GROUPS][] = {
	"-=Gods=-",
	"-=Semi-Gods=-",
	"-=Mods=-",
	"-=Semi-Mods=-",
	"-=Administrator=-",
	"-=Semi-Administrator=-",
	"-=SlotS=-"
};

new g_groupFlags[MAX_GROUPS][] = {
	"abcdefghijklmnopqrstu",
	"abcdefghijkmnopqrstu",
	"abcdefgijkmnopqrstu",
	"abcdefgijmnopqrstu",
	"abcdefijmnopqrstu",
	"aceijmnopqrstu",
	"abc"
};

new g_groupFlagsValue[MAX_GROUPS];

public plugin_init()
{
	register_plugin("Show Who", "1.0.0", "X");
	
	register_concmd("admin_who", "cmdWho", -1);
	for(new i = 0; i < MAX_GROUPS; i++) {
		g_groupFlagsValue[i] = read_flags(g_groupFlags[i]);
	}
}

public cmdWho(id)
{
	new player, players[32], name[32], inum;
	get_players(players, inum);
	
	console_print(id, "=====Admini Online======");
	for(new i = 0; i < MAX_GROUPS; i++) {
		console_print(id, "[%d] %s", i+1, g_groupNames[i]);
		for(new j = 0; j < inum; ++j) {
			player = players[j];
			
			get_user_name(player, name, 31);
			if(get_user_flags(player) == g_groupFlagsValue[i]) {
				console_print(id, "%s", name);
			}
		}
	}
	console_print(id, "=====Made by The-X=====");
	
	return PLUGIN_HANDLED;
}
