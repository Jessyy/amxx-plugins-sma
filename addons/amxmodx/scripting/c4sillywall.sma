#include <amxmodx>
#include <amxplus>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <csx>
#include <xs>

new bool:NUMBERS	= true	// false/true | Random numbers while defusing
new bool:WALLPLANT	= true	// false/true | Allows you to plant on walls
new bool:RESTRICT	= true	// false/true | Walking speed while planting/defusing the bomb

new szMsg[128]
new g_NumberID = 0
new g_iRandomNumbers[11]
new g_Defusing[MAX_PLAYERS+1]
new Float:g_fDelay[MAX_PLAYERS+1]
new DEFUSING_SOUND[] = "weapons/c4_click.wav"

public plugin_init()
{
	register_plugin("C4 Silly", "1.0", "X")

	register_event("BarTime", "Event_BarTime", "b", "1=0")
}

public plugin_precache()
{
	if(is_precache_enabled()) {
		precache_sound(DEFUSING_SOUND);
	}
}

public Event_BarTime(id) if(g_Defusing[id])
{
	g_NumberID = 0
	g_Defusing[id] = 0
}

public bomb_defused(id)
{
	g_NumberID = 0
	g_Defusing[id] = 0
}

public bomb_defusing(id)
{
	if(RESTRICT)
		entity_set_float(id, EV_FL_maxspeed, 240.0)

	g_Defusing[id] = 1
}

public bomb_planting(id) if(RESTRICT)
{
	entity_set_float(id, EV_FL_maxspeed, 240.0)
}

public bomb_planted(id)
{
	if(!WALLPLANT)
		return

	g_NumberID = 0
	for(new i = 0; i < 11; ++i)
		g_iRandomNumbers[i] = rn()

	new Float:fOrigin[3]
	entity_get_vector(id, EV_VEC_origin, fOrigin)

	new Float:fVelocity[3]
	VelocityByAim(id, 54, fVelocity)

	if(fVelocity[2] < -28.0)
		return

	new Float:fTraceEnd[3]
	xs_vec_add(fVelocity, fOrigin, fTraceEnd)

	new Float:fTraceResult[3]
	trace_line(id, fOrigin, fTraceEnd, fTraceResult)

	new Float:fNormal[3]
	if(trace_normal(id, fOrigin, fTraceEnd, fNormal) < 1)
		return

	new c4 = -1
	while((c4 = find_ent_by_model(c4, "grenade", "models/w_c4.mdl"))) {
		if(entity_get_int(c4, EV_INT_movetype) == MOVETYPE_FLY || (get_entity_flags(c4) & FL_ONGROUND))
			continue

		entity_set_int(c4, EV_INT_movetype, MOVETYPE_FLY)

		new Float:fNewOrigin[3]
		fNewOrigin[0] = fTraceResult[0] + (fNormal[0] * -0.01)
		fNewOrigin[1] = fTraceResult[1] + (fNormal[1] * -0.01)
		fNewOrigin[2] = fTraceResult[2] +  fNormal[2] + 8.000

		entity_set_origin(c4, fNewOrigin)

		new Float:fAngles[3]
		vector_to_angle(fNormal, fAngles)
		fAngles[0] -= 180.0, fAngles[1] -= 90.0, fAngles[2] -= 90.0
		entity_set_vector(c4, EV_VEC_angles, fAngles)
	}
}

public client_PreThink(id)
{
	if(!NUMBERS || !is_user_alive(id) || !g_Defusing[id])
		return PLUGIN_CONTINUE

	if(g_fDelay[id] + get_delay(id) < get_gametime()) {
		g_NumberID += 1
		client_cmd(id, "spk %s", DEFUSING_SOUND)
		g_fDelay[id] = get_gametime()
	}

	switch(g_NumberID)
	{
		case 0: format(szMsg, 127, "^n^n%d%d%d%d%d%d%d%d%d%d%d", rn(), rn(), rn(), rn(), rn(), rn(), rn(), rn(), rn(), rn(), rn())
		case 1: format(szMsg, 127, "^n^n%d%d%d%d%d%d%d%d%d%d%d", n(0), rn(), rn(), rn(), rn(), rn(), rn(), rn(), rn(), rn(), rn())
		case 2: format(szMsg, 127, "^n^n%d%d%d%d%d%d%d%d%d%d%d", n(0), n(1), rn(), rn(), rn(), rn(), rn(), rn(), rn(), rn(), rn())
		case 3: format(szMsg, 127, "^n^n%d%d%d%d%d%d%d%d%d%d%d", n(0), n(1), n(2), rn(), rn(), rn(), rn(), rn(), rn(), rn(), rn())
		case 4: format(szMsg, 127, "^n^n%d%d%d%d%d%d%d%d%d%d%d", n(0), n(1), n(2), n(3), rn(), rn(), rn(), rn(), rn(), rn(), rn())
		case 5: format(szMsg, 127, "^n^n%d%d%d%d%d%d%d%d%d%d%d", n(0), n(1), n(2), n(3), n(4), rn(), rn(), rn(), rn(), rn(), rn())
		case 6: format(szMsg, 127, "^n^n%d%d%d%d%d%d%d%d%d%d%d", n(0), n(1), n(2), n(3), n(4), n(5), rn(), rn(), rn(), rn(), rn())
		case 7: format(szMsg, 127, "^n^n%d%d%d%d%d%d%d%d%d%d%d", n(0), n(1), n(2), n(3), n(4), n(5), n(6), rn(), rn(), rn(), rn())
		case 8: format(szMsg, 127, "^n^n%d%d%d%d%d%d%d%d%d%d%d", n(0), n(1), n(2), n(3), n(4), n(5), n(6), n(7), rn(), rn(), rn())
		case 9: format(szMsg, 127, "^n^n%d%d%d%d%d%d%d%d%d%d%d", n(0), n(1), n(2), n(3), n(4), n(5), n(6), n(7), n(8), rn(), rn())
		case 10:format(szMsg, 127, "^n^n%d%d%d%d%d%d%d%d%d%d%d", n(0), n(1), n(2), n(3), n(4), n(5), n(6), n(7), n(8), n(9), rn())
		case 11:format(szMsg, 127, "^n^n%d%d%d%d%d%d%d%d%d%d%d", n(0), n(1), n(2), n(3), n(4), n(5), n(6), n(7), n(8), n(9),n(10))
		default:format(szMsg, 127, "^n^n%d%d%d%d%d%d%d%d%d%d%d", n(0), n(1), n(2), n(3), n(4), n(5), n(6), n(7), n(8), n(9),n(10))
	}
	engclient_print(id, engprint_center, szMsg)

	return PLUGIN_CONTINUE
}

stock rn() return random_num(0, 9);
stock n(value) return g_iRandomNumbers[value];
stock Float:get_delay(id) return cs_get_user_defuse(id) ? 0.4999 : 0.9999;
