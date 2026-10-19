--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/optimization/lua/autorun/limit_phys.lua <
    > Callstack:  <
]]

-- "addons\\optimization\\lua\\autorun\\limit_phys.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
hook.Add("InitPostEntity","RemoveShittyHooks",function()
	local phys_settings = physenv.GetPerformanceSettings()

	phys_settings.LookAheadTimeObjectsVsObject = 0 -- 0.5
	phys_settings.LookAheadTimeObjectsVsWorld = 0.1 -- 1
	phys_settings.MaxAngularVelocity = 3600 -- 7272.7275390625
	phys_settings.MaxCollisionChecksPerTimestep = 100 -- 50000
	phys_settings.MaxCollisionsPerObjectPerTimestep = 1 -- 10
	phys_settings.MaxFrictionMass = 2500 -- 2500
	phys_settings.MaxVelocity = 4000 -- 4000
	phys_settings.MinFrictionMass = 100 -- 10

	physenv.SetPerformanceSettings(phys_settings)
end )
