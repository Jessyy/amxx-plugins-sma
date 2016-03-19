#include <amxmodx>
#include <fakemeta>

#define PLUGIN	"HudTextArgs Blocker"
#define VERSION	"1.1"
#define AUTHOR	"X"

const NextHudTextArgsOffset = 198
const HintMaxLen = 38

new Hints[][HintMaxLen] = 
{
	"hint_win_round_by_killing_enemy",
	"hint_press_buy_to_purchase",
	"hint_spotted_an_enemy",
	"hint_use_nightvision",
	"hint_lost_money",
	"hint_removed_for_next_hostage_killed",
	"hint_careful_around_hostages",
	"hint_careful_around_teammates",
	"hint_reward_for_killing_vip",
	"hint_win_round_by_killing_enemy",
	"hint_try_not_to_injure_teammates",
	"hint_you_are_in_targetzone",
	"hint_hostage_rescue_zone",
	"hint_terrorist_escape_zone",
	"hint_ct_vip_zone",
	"hint_terrorist_vip_zone",
	"hint_cannot_play_because_tk",
	"hint_use_hostage_to_stop_him",
	"hint_lead_hostage_to_rescue_point",
	"hint_you_have_the_bomb",
	"hint_you_are_the_vip",
	"hint_out_of_ammo",
	"hint_spotted_a_friend",
	"hint_spotted_an_enemy",
	"hint_prevent_hostage_rescue",
	"hint_rescue_the_hostages",
	"hint_press_use_so_hostage_will_follow",
	"Spec_Duck"
}

new HintsDefaultStatus[sizeof Hints] = 
{
	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 // 1,1,1,0,1,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0
}

new Trie:HintsStatus

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_message(get_user_msgid("HudTextArgs"),"hudTextArgs")
}

public plugin_cfg()
{
	HintsStatus = TrieCreate()
	
	for(new i=0, statusString[2]; i<sizeof Hints; i++)
	{
		statusString[0] = HintsDefaultStatus[i] + 48
		
		if(get_pcvar_num(register_cvar(Hints[i],statusString)))
			TrieSetCell(HintsStatus,Hints[i][5],true)
	}
}

public hudTextArgs(msgid, msgDest, msgEnt)
{
	static hint[HintMaxLen + 1]
	get_msg_arg_string(1,hint,charsmax(hint))
	
	if(TrieKeyExists(HintsStatus,hint[6]))
	{
		set_pdata_float(msgEnt,NextHudTextArgsOffset,0.0)
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE 
}
