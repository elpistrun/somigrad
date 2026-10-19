if SERVER then
    util.AddNetworkString("homigrad_light_reset")

    function Homigrad_ResetLighting(target)
        -- Enforce standard bright daytime lightstyle
        engine.LightStyle(0, "m")

        for _, li in ipairs(ents.FindByClass("light_environment")) do
            if IsValid(li) then
                li:Fire("SetPattern", "m")
                li:Fire("FadeToPattern", "m")
            end
        end

        -- Ensure any active weather entities or fake skies are removed
        for _, ent in ipairs(ents.FindByClass("gw_t*")) do
            if IsValid(ent) then ent:Remove() end
        end
        for _, ent in ipairs(ents.FindByClass("gw_skypaint")) do
            if IsValid(ent) then ent:Remove() end
        end

        -- Reset gWeather if present
        if gWeather then
            if gWeather.AtmosphereReset then pcall(gWeather.AtmosphereReset, gWeather) end
            if gWeather.RemoveSky then pcall(gWeather.RemoveSky, gWeather) end
            if gWeather.RemoveFog then pcall(gWeather.RemoveFog, gWeather) end
            if gWeather.ResetMapLight then pcall(gWeather.ResetMapLight) end
        end

        -- Restore standard daylight parameters to native map skypaint
        for _, sky in ipairs(ents.FindByClass("env_skypaint")) do
            if IsValid(sky) then
                sky:SetTopColor(Vector(0.2, 0.5, 1.0))
                sky:SetBottomColor(Vector(0.8, 0.9, 1.0))
                sky:SetDuskColor(Vector(1.0, 0.2, 0.0))
                sky:SetSunColor(Vector(1.0, 0.9, 0.8))
                sky:SetSunSize(2)
                sky:SetDuskScale(1)
                sky:SetDuskIntensity(1)
                sky:SetFadeBias(1)
                sky:SetHDRScale(0.66)
                sky:SetDrawStars(false)
            end
        end

        -- Notify clients
        net.Start("homigrad_light_reset")
        if target and IsValid(target) then
            net.Send(target)
        else
            net.Broadcast()
        end

        -- Also trigger gWeather lightmap reload broadcast if supported
        if util.NetworkStringToID("gw_lightmaps") ~= 0 then
            net.Start("gw_lightmaps")
            if target and IsValid(target) then
                net.Send(target)
            else
                net.Broadcast()
            end
        end
    end

    hook.Add("Homigrad_RoundStart", "Homigrad_DaylightReset", function()
        Homigrad_ResetLighting()
    end)

    hook.Add("PlayerInitialSpawn", "Homigrad_DaylightOnSpawn", function(ply)
        timer.Simple(1, function()
            if IsValid(ply) then
                Homigrad_ResetLighting(ply)
            end
        end)
    end)

    hook.Add("InitPostEntity", "Homigrad_DaylightInit", function()
        timer.Simple(0.5, function()
            Homigrad_ResetLighting()
        end)
    end)

    concommand.Add("hg_daylight", function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end
        Homigrad_ResetLighting()
        print("[Homigrad] Освещение и скайбокс сброшены на яркий день!")
    end)

    concommand.Add("hg_resetlight", function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end
        Homigrad_ResetLighting()
        print("[Homigrad] Освещение и скайбокс сброшены на яркий день!")
    end)

    hook.Add("PlayerSay", "Homigrad_DaylightChatCmd", function(ply, text)
        local cmd = string.lower(string.Trim(text))
        if cmd == "!daylight" or cmd == "!light" or cmd == "/daylight" or cmd == "/light" then
            if not IsValid(ply) or ply:IsAdmin() then
                Homigrad_ResetLighting()
                if IsValid(ply) then ply:ChatPrint("[Homigrad] Освещение карты успешно восстановлено на дневное!") end
                return ""
            end
        end
    end)
end

if CLIENT then
    local function RestoreDaylightClient()
        -- 1. Restore native g_SkyPaint entity
        local sky = ents.FindByClass("env_skypaint")[1] or ents.FindByClass("edit_sky")[1]
        if IsValid(sky) then
            g_SkyPaint = sky
            if sky:GetTopColor():LengthSqr() < 0.001 then
                sky:SetTopColor(Vector(0.2, 0.5, 1.0))
            end
            if sky:GetBottomColor():LengthSqr() < 0.001 then
                sky:SetBottomColor(Vector(0.8, 0.9, 1.0))
            end
        end

        -- 2. Remove night / darkness color modification and moon hooks
        hook.Remove("RenderScreenspaceEffects", "gWeather.NightColorModify")
        hook.Remove("PostDraw2DSkyBox", "gWeather.Night.Moon")

        -- 3. Remove black fog hooks from gWeather
        hook.Remove("SetupWorldFog", "gWeather.Fog.WorldFog")
        hook.Remove("SetupSkyboxFog", "gWeather.Fog.SkyboxFog")

        if LocalPlayer().gWeather and LocalPlayer().gWeather.Fog then
            LocalPlayer().gWeather.Fog.CurrentDensity = 0
            LocalPlayer().gWeather.Fog.CurrentDistance = 100000
        end

        -- 4. Redownload all lightmaps to clear any dark lightstyle cache
        timer.Simple(0.1, function()
            render.RedownloadAllLightmaps(true, false)
        end)
    end

    net.Receive("homigrad_light_reset", function()
        RestoreDaylightClient()
    end)

    hook.Add("InitPostEntity", "Homigrad_DaylightClientInit", function()
        timer.Simple(1, function()
            RestoreDaylightClient()
        end)
    end)

    -- Guard against g_SkyPaint getting lost or nulled on client
    hook.Add("Think", "Homigrad_EnsureSkyPaint", function()
        if not IsValid(g_SkyPaint) then
            local sky = ents.FindByClass("env_skypaint")[1] or ents.FindByClass("edit_sky")[1]
            if IsValid(sky) then
                g_SkyPaint = sky
            end
        end
    end)

    concommand.Add("hg_daylight", function()
        RestoreDaylightClient()
        LocalPlayer():ChatPrint("[Homigrad] Клиентское освещение и небо обновлены!")
    end)

    concommand.Add("hg_resetlight", function()
        RestoreDaylightClient()
        LocalPlayer():ChatPrint("[Homigrad] Клиентское освещение и небо обновлены!")
    end)
end
