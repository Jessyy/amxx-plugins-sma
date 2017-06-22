#include <amxmodx>
#include <amxplus>

#define LEVELS 7

new stksounds[7][] = {
	"misc/multikill",
	"misc/ultrakill",
	"misc/monsterkill",
	"misc/killingspree",
	"misc/rampage",
	"misc/holyshit",
	"misc/godlike"
};

new stkmessages[7][] = {
	"Multi-Kill: %s",
	"Ultra-Kill: %s",
	"Monster-Kill: %s",
	"Killing Spree: %s",
	"Rampage: %s",
	"Holy Shit: %s",
	"Godlike: %s"
};

new kills[33] = {0, ...};
new deaths[33] = {0, ...};
new levels[7] = {3, 5, 7, 9, 11, 13, 15};

public plugin_init()
{
	register_plugin("Multi Kill Sound", "1.0.0", "X");

	register_event("DeathMsg", "Headshot", "a", "3=1");
	register_event("DeathMsg", "Knifekill", "a", "4&kni");
	register_event("DeathMsg", "Hekill", "a", "4&gren");
	register_event("DeathMsg", "Last_ct_t_1", "a");
	register_event("DeathMsg", "Multikill", "a");
}

public plugin_precache()
{
	if(is_precache_enabled()) {
		precache_sound("misc/multikill.wav");
		precache_sound("misc/ultrakill.wav");
		precache_sound("misc/monsterkill.wav");
		precache_sound("misc/killingspree.wav");
		precache_sound("misc/rampage.wav");
		precache_sound("misc/holyshit.wav");
		precache_sound("misc/godlike.wav");
		precache_sound("misc/headshot.wav");
		precache_sound("misc/humiliation.wav");
		precache_sound("misc/mkqclastplace.wav");
	}
}

public Headshot(id)
{
	new killer = read_data(1);
	new victim = read_data(2);

	client_print(victim, print_center, ">>> H.E.A.D - S.H.O.T <<<");
	client_cmd(killer, "spk misc/headshot");

	return PLUGIN_CONTINUE;
}

public Knifekill(id)
{
	new killer = read_data(1);
	client_cmd(killer, "spk misc/humiliation");

	return PLUGIN_CONTINUE;
}

public Hekill(id)
{
	new killer = read_data(1);
	new victim = read_data(2);

	if (victim == killer) {
		client_cmd(victim, "spk misc/mkqclastplace");
	}

	return PLUGIN_CONTINUE;
}

public Last_ct_t_1()
{
	new players_ct[32], players_t[32], ict, ite;
	get_players(players_ct, ict, "ae", "CT");
	get_players(players_t, ite, "ae", "TERRORIST");

	if(ict == 1 && ite == 1) {
		new name1[32], name2[32];
		get_user_name(players_t[0], name1, 32);
		get_user_name(players_ct[0], name2, 32);

		set_task(1.0, "Last_ct_t_2", 0, "", 0, "a", 3);
		engclient_print(players_t[0], engprint_center, "^x04%s (%i HP)^n^n.V.S.^n^n%s (%i HP)", name1, get_user_health(players_t[0]), name2, get_user_health(players_ct[0]));
		engclient_print(players_ct[0], engprint_center, "^x04%s (%i HP)^n^n.V.S.^n^n%s (%i HP)", name1, get_user_health(players_t[0]), name2, get_user_health(players_ct[0]));
	}

	return PLUGIN_CONTINUE;
}

public Last_ct_t_2()
{
	new players_ct[32], players_t[32], ict, ite;
	get_players(players_ct, ict, "ae", "CT");
	get_players(players_t, ite, "ae", "TERRORIST");

	if(ict == 1 && ite == 1) {
		new name1[32], name2[32];
		get_user_name(players_t[0], name1, 32);
		get_user_name(players_ct[0], name2, 32);

		engclient_print(players_t[0], engprint_center, "^x04%s (%i HP)^n^n.V.S.^n^n%s (%i HP)", name1, get_user_health(players_t[0]), name2, get_user_health(players_ct[0]));
		engclient_print(players_ct[0], engprint_center, "^x04%s (%i HP)^n^n.V.S.^n^n%s (%i HP)", name1, get_user_health(players_t[0]), name2, get_user_health(players_ct[0]));
	}

	return PLUGIN_CONTINUE;
}

public Multikill(id)
{
	new killer = read_data(1);
	new victim = read_data(2);

	kills[killer] += 1;
	kills[victim] = 0;
	deaths[killer] = 0;
	deaths[victim] += 1;

	for(new i = 0; i < LEVELS; i++) {
		if(kills[killer] == levels[i]) {
			announce(killer, i);

			return PLUGIN_CONTINUE;
		}
	}

	return PLUGIN_CONTINUE;
}

announce(killer, level)
{
	new name[32];
	get_user_name(killer, name, 31);

	set_hudmessage(0, 80, 220, 0.05, 0.55, 2, 0.02, 7.0, 0.01, 0.1, 2);
	show_hudmessage(0, stkmessages[level], name);

	client_cmd(killer, "spk %s", stksounds[level]);
}

public client_connect(id)
{
	kills[id] = 0;
	deaths[id] = 0;
}
