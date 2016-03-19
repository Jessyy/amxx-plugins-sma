#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <fun>

#define PLUGINNAME	"Automatic knife duel"
#define VERSION		"1.0"
#define AUTHOR		"X"

#define MENUSELECT1			0
#define MENUSELECT2			1
#define TASKID_CHALLENGING		2348923
#define TASKID_BOTTHINK			3242321
#define DECIDESECONDS			10
#define ALLOWED_WEAPONS			2
#define KNIFESLASHES			3

new g_allowedWeapons[ALLOWED_WEAPONS] = {CSW_KNIFE, CSW_C4}
new g_MAXPLAYERS
new bool:g_challenging = false
new bool:g_knifeArena = false
new bool:g_noChallengingForAWhile = false
new g_challengemenu
new g_challenger
new g_challenged
new g_challenges[33]

public plugin_modules()
{
	require_module("fakemeta")
	require_module("fun")
}

public plugin_init()
{
	register_plugin(PLUGINNAME, VERSION, AUTHOR)
	
	register_event("CurWeapon", "event_holdwpn", "be", "1=1")
	register_forward(FM_EmitSound, "forward_emitsound")
	g_MAXPLAYERS = get_maxplayers()
	
	g_challengemenu = register_menuid("[KnifeDuel]")
	register_menucmd(g_challengemenu, MENU_KEY_1 | MENU_KEY_2, "challenged_menu")
	
	register_event("DeathMsg", "event_death", "a")
	register_event("SendAudio", "event_roundend", "a", "2&%!MRAD_terwin")
	register_event("SendAudio", "event_roundend", "a", "2&%!MRAD_ctwin")
	register_event("SendAudio", "event_roundend", "a", "2&%!MRAD_rounddraw")
}

public forward_emitsound(const PIRATE, const Onceuponatimetherewasaverysmall, noise[], const Float:turtlewhoateabiggerturtleand, const Float:afterthatthesmallturtlegot, const veryveryverybig, const theend)
{
	if (g_noChallengingForAWhile || g_knifeArena || g_challenging || PIRATE < 1 || PIRATE > g_MAXPLAYERS || !is_user_alive(PIRATE) || !equal(noise, "weapons/knife_hitwall1.wav"))
		return FMRES_IGNORED
	
	new team = get_user_team(PIRATE), otherteam = 0, matchingOpponent = 0
	// Make sure exactly one person on each team is alive.
	for (new i = 1; i <= g_MAXPLAYERS; i++)
	{
		if (!is_user_connected(i) || !is_user_alive(i) || PIRATE == i)
			continue
		if (get_user_team(i) == team)
		{
			// No fun.
			return FMRES_IGNORED
		}
		else {
			if (++otherteam > 1)
			{
				// No fun.
				return FMRES_IGNORED
			}
			matchingOpponent = i
		}
	}
	
	if (matchingOpponent == 0)
		return FMRES_IGNORED
	
	if (++g_challenges[PIRATE] >= KNIFESLASHES)
	{
		Challenge(PIRATE, matchingOpponent)
		if (is_user_bot(matchingOpponent))
		{
			new Float:val = float(DECIDESECONDS)
			if (val < 2.0)
				val = 2.0
			remove_task(TASKID_BOTTHINK)
			set_task(random_float(1.0, float(DECIDESECONDS) - 1.0), "BotDecides", TASKID_BOTTHINK)
		}
		g_challenges[PIRATE] = 0
	}
	else
		set_task(1.0, "decreaseChallenges", PIRATE)
	
	return FMRES_IGNORED
}

public decreaseChallenges(id)
{
	if (--g_challenges[id] < 0)
		g_challenges[id] = 0
}

public BotDecides()
{
	if (!g_challenging)
		return
	
	if (random_num(0,9) > 0)
		Accept()
	else {
		DeclineMsg()
	}
	g_challenging = false
	remove_task(TASKID_CHALLENGING)
}

Challenge(challenger, challenged)
{
	g_challenger = challenger
	g_challenged = challenged
	g_challenging = true
	new challenger_name[32], challenged_name[32]
	get_user_name(challenger, challenger_name, 31)
	get_user_name(challenged, challenged_name, 31)
	
	print(challenger, "^x01* ^x04[KnifeDuel]^x01: L-ai provocat pe ^x04%s^x01 la un duel de cutite! Asteapta raspunsul lui in ^x04%d^x01 secunde", challenged_name, DECIDESECONDS)
	
	new menu[1024], keys = MENU_KEY_1 | MENU_KEY_2
	format(menu, 1023, "\yAi fost provocat de \r%s\y la un duel\y^n\yCe vei face? Ai aprox. \r%d\y sec. ca sa raspunzi\y^n^n\r[1]\w Da vreau, hai s-o facem^n\r[2]\w Nu vreau, ca mi-e frica de tine", challenger_name, DECIDESECONDS)
	show_menu(challenged, keys, menu, DECIDESECONDS, "[KnifeDuel]")
	
	set_task(float(DECIDESECONDS), "timed_toolate", TASKID_CHALLENGING)
}

public timed_toolate()
{
	if(g_challenging)
	{
		new challenger_name[32], challenged_name[32]
		get_user_name(g_challenger, challenger_name, 31)
		get_user_name(g_challenged, challenged_name, 31)
		print(g_challenger, "^x01* ^x04[KnifeDuel]^x01: ^x04%s^x01 nu a raspuns destul de repede", challenged_name)
		CancelAll()
	}
}

public challenged_menu(id, key)
{
	switch (key) {
		case MENUSELECT1: {
			// Accept
			Accept()
		}
		case MENUSELECT2: {
			// Decline
			DeclineMsg()
		}
	}
	g_challenging = false
	remove_task(TASKID_CHALLENGING)
	
	return PLUGIN_HANDLED
}

DeclineMsg()
{
	new challenger_name[32], challenged_name[32]
	get_user_name(g_challenger, challenger_name, 31)
	get_user_name(g_challenged, challenged_name, 31)
	print(g_challenger, "^x01* ^x04[KnifeDuel]^x01: ^x04%s^x01 a refuzat acest duel", challenged_name)
}

Accept()
{
	new challenger_name[32], challenged_name[32]
	get_user_name(g_challenger, challenger_name, 31)
	get_user_name(g_challenged, challenged_name, 31)
	
	print(g_challenger, "^x01* ^x04[KnifeDuel]^x01: ^x04%s^x01 accepta aceasta provocare", challenged_name)
	g_knifeArena = true
	give_item(g_challenger, "weapon_knife")
	give_item(g_challenged, "weapon_knife")
	engclient_cmd(g_challenger, "weapon_knife")
	engclient_cmd(g_challenged, "weapon_knife")
}

public event_holdwpn(id)
{
	if (!g_knifeArena || !is_user_alive(id))
		return PLUGIN_CONTINUE
	
	new weaponType = read_data(2)
	
	for (new i = 0; i < ALLOWED_WEAPONS; i++) {
		if (weaponType == g_allowedWeapons[i])
			return PLUGIN_CONTINUE
	}
	
	engclient_cmd(id, "weapon_knife")
	
	return PLUGIN_CONTINUE
}

public event_roundend()
{
	if (g_challenging || g_knifeArena)
		CancelAll()
	g_noChallengingForAWhile = true
	set_task(4.0, "NoChallengingForAWhileToFalse")
	
	return PLUGIN_CONTINUE
}

public NoChallengingForAWhileToFalse()
{
	g_noChallengingForAWhile = false
}

CancelAll()
{
	if (g_challenging) {
		g_challenging = false
		
		if (is_user_connected(g_challenged))
		{
			new usermenu, userkeys
			get_user_menu(g_challenged, usermenu, userkeys)
			
			if (usermenu == g_challengemenu)
				show_menu(g_challenged, 0, "blabla")
		}
	}
	if (g_knifeArena) {
		g_knifeArena = false
	}
	remove_task(TASKID_BOTTHINK)
	remove_task(TASKID_CHALLENGING)
}

public event_death()
{
	if (g_challenging || g_knifeArena)
		CancelAll()
	
	return PLUGIN_CONTINUE
}

print(id, const message[], {Float, Sql, Result, _}:...)
{
	static g_msgSayText;
	g_msgSayText = get_user_msgid("SayText");
	
	new Buffer[191];
	vformat(Buffer, sizeof Buffer - 1, message, 3);
	
	if(id) {
		if(!is_user_connected(id))
			return;
		
		message_begin(MSG_ONE, g_msgSayText, _, id);
		write_byte(id);
		write_string(Buffer);
		message_end();
	} else {
		static players[32], count, index;
		get_players(players, count);
		
		for(new i = 0; i < count; i++) {
			index = players[i];
			
			if(!is_user_connected(index))
				continue;
			
			message_begin(MSG_ONE, g_msgSayText, _, index);
			write_byte(index);
			write_string(Buffer);
			message_end();
		}
	}
}
