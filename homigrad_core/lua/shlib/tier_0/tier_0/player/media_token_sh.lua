-- net.ReceiveMediaToken is declared by the CLIENT half of the data manager
-- (shlib/tier_3_data_manager/tier_0/tier_1_clientinterface/server_cl.lua), which is a
-- client-only file. Shared (_sh) files such as homigrad_adminpanel/tier_2/map_sh.lua and
-- the profile manager call it while they are being loaded, so on a dedicated server it was
-- nil and they hard-errored:
--     [homigrad_adminpanel] .../map_sh.lua:21: attempt to call field 'ReceiveMediaToken' (a nil value)
--
-- This file re-declares the exact same registry the author uses, so shared code can always
-- call it. On clients the real implementation in server_cl.lua loads later and takes over.
-- On servers the callbacks simply stay unused until the external database is available.

ReceiveMediaToken = ReceiveMediaToken or {}

function net.ReceiveMediaToken(name, callback)
	ReceiveMediaToken[name] = callback
end
