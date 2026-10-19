-- Shared gamemode entry point.
--
-- GMod loads gamemode/init.lua on BOTH the server and the client; cl_init.lua only on the
-- client and sv_init.lua only on the server. The leaked copy of this gamemode shipped
-- cl_init.lua + shared.lua but no init.lua, so the server never derived the gamemode at all
-- (which is also why "Couldn't change active gamemode" showed up in the boot log).

include("shared.lua")
