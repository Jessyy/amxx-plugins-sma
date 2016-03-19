#include <amxmodx>
#include <amxmisc>

public plugin_init()
{
	register_plugin("Server Shutdown", "1.0", "X")
	
	register_concmd("amx_shutdown", "shutdown", -1)
}

public shutdown(id)
{
	if(!(get_user_flags(id) & ADMIN_RCON))
		return PLUGIN_HANDLED;
	
	set_task(0.0,"alert")
	set_task(3.0,"ten")
	set_task(4.0,"nine")
	set_task(5.0,"eight")
	set_task(6.0,"seven")
	set_task(7.0,"six")
	set_task(8.0,"five")
	set_task(9.0,"four")
	set_task(10.0,"three")
	set_task(11.0,"two")
	set_task(12.0,"one")
	set_task(13.0,"zero")
	set_task(14.0,"exit_server")
	
	return PLUGIN_HANDLED;
}

public alert()
{
	client_print(0, print_chat,"***** ALERTA! SERVER SHUTDOWN! *****")
	server_print("***** ALERTA! SERVER SHUTDOWN! *****")
	
	client_cmd(0, "spk ^"fvox/warning.wav^"") 
}

public ten()
{
	client_print(0, print_chat,"Server Shutdown in 10....")
	server_print("Server Shutdown in 10....")
	
	client_cmd(0, "spk ^"fvox/ten.wav^"") 
}

public nine()
{
	client_print(0, print_chat,"Server Shutdown in 9....")
	server_print("Server Shutdown in 9....")
	client_cmd(0, "spk ^"fvox/nine.wav^"") 
}

public eight()
{
	client_print(0, print_chat,"Server Shutdown in 8....")
	server_print("Server Shutdown in 8....")
	
	client_cmd(0, "spk ^"fvox/eight.wav^"") 
}

public seven()
{
	client_print(0, print_chat,"Server Shutdown in 7....")
	server_print("Server Shutdown in 7....")
	
	client_cmd(0, "spk ^"fvox/seven.wav^"") 
}

public six()
{
	client_print(0, print_chat,"Server Shutdown in 6....")
	server_print("Server Shutdown in 6....")
	
	client_cmd(0, "spk ^"fvox/six.wav^"") 
}

public five()
{
	client_print(0, print_chat,"Server Shutdown in 5....")
	server_print("Server Shutdown in 5....")
	
	client_cmd(0, "spk ^"fvox/five.wav^"") 
}

public four()
{
	client_print(0, print_chat,"Server Shutdown in 4....")
	server_print("Server Shutdown in 4....")
	
	client_cmd(0, "spk ^"fvox/four.wav^"") 
}

public three()
{
	client_print(0, print_chat,"Server Shutdown in 3....")
	server_print("Server Shutdown in 3....")
	
	client_cmd(0, "spk ^"fvox/three.wav^"") 
}

public two()
{
	client_print(0, print_chat,"Server Shutdown in 2....")
	server_print("Server Shutdown in 2....")
	
	client_cmd(0, "spk ^"fvox/two.wav^"") 
}

public one()
{
	client_print(0, print_chat,"Server Shutdown in 1....")
	server_print("Server Shutdown in 1....")
	
	client_cmd(0, "spk ^"fvox/one.wav^"") 
}

public zero()
{
	client_print(0, print_chat,"Server Shutting Down....")
	server_print("Server Shutting Down!")
}

public exit_server()
{
	server_cmd("quit")
}
