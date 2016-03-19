#include <amxmodx>
#include <amxmisc>

enum PlayerInfo {
	PLAYER_NAME[32],
	PLAYER_SOUND[128]
};

//http://downloads.laleagane.ro/cs/sound/ambience/
//Pluginul vede numele de forma "aaa" idendic ci cel de forma "AAA"
//Ultima persoana din lista dupa "}" nu trebuie sa aibe "," restul trebuie sa aibe.
new const ListOfNames[][PlayerInfo] = {
	{"aaa", "ambience/cat1.wav"},
	{"AAA", "ambience/doorbell.wav"},
	{"Jessyy", "ambience/crow.wav"},
	{"cioara", "ambience/sheep.wav"}
};

new g_iMaxClients;

public plugin_init()
{
	register_plugin("Cioara", "2.0", "X");
	
	g_iMaxClients = get_maxplayers();
	register_event("DeathMsg", "Event_Death", "a");
}

public plugin_precache()
{
	for(new i=0; i < sizeof(ListOfNames); i++) {
		precache_sound(ListOfNames[i][PLAYER_SOUND]);
	}
}

public plugin_modules()
{
	require_module("amxmisc");
}

public Event_Death()
{
	new killer = read_data(1);
	new victim = read_data(2);
	
	if(!(1 <= killer <= g_iMaxClients) || killer == victim)
		return PLUGIN_HANDLED;
	
	new vicName[32], phraseIdx;
	get_user_name(victim, vicName, 31);
	
	if(IsNameOnList(vicName, phraseIdx)) {
		client_cmd(0, "spk %s", ListOfNames[phraseIdx][PLAYER_SOUND]);
	}
	
	return PLUGIN_CONTINUE;
}

public IsNameOnList(const playerName[], &phraseIdx)
{
	for(new i=0; i < sizeof(ListOfNames); i++) {
		if( equali(playerName, ListOfNames[i][PLAYER_NAME]) ) {
			phraseIdx = i;
			return true;
		}
	}
	return false;
}
