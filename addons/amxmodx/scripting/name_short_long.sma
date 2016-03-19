#include <amxmodx>
#include <amxmisc>

public MinLength = 3;
public MaxLength = 15;

new const ShortNameReason[] = "Numele tau e prea scurt! Mai lungestel";
new const BigNameReason[] = "Numele tau e prea lung! Mai scurteazal";

public plugin_init()
{
	register_plugin("Name Len Manager", "1.0.0", "X");
}

public client_connect(id)
{
	new szName[32];
	get_user_name(id, szName, sizeof szName - 1);
	
	new x;
	while(!equal(szName[x], "^0"))
		x++;
	
	if(x < MinLength) {
		server_cmd("kick #%i ^"%s^"", get_user_userid(id), ShortNameReason);
	}
	else if(x > MaxLength) {
		server_cmd("kick #%i ^"%s^"", get_user_userid(id), BigNameReason);
	}
	
	return PLUGIN_CONTINUE;
}

public client_infochanged(id)
{
	if(!is_user_connected(id))
		return PLUGIN_HANDLED;
	
	new szNewname[32], szOldname[32];
	get_user_name(id, szOldname, sizeof szOldname - 1);
	get_user_info(id, "name", szNewname, sizeof szNewname - 1);
	
	if(!equali(szNewname, szOldname))
	{
		new y;
		while(!equal(szNewname[y], "^0"))
			y++;
		
		if(y < MinLength) {
			server_cmd("kick #%i ^"%s^"", get_user_userid(id), ShortNameReason);
		}
		else if(y > MaxLength) {
			server_cmd("kick #%i ^"%s^"", get_user_userid(id), BigNameReason);
		}
	}
	
	return PLUGIN_CONTINUE;
}
