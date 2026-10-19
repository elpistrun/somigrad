--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_core/lua/shlib/tier_2_world/render/playerdrawing_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:5 <
]]

-- "addons\\homigrad_core\\lua\\shlib\\tier_2_world\\render\\playerdrawing_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local function EnsureRenderOverride(ply)
    if not IsValid(ply) then return end
    ply:SetRenderBounds(-Vector(512,512,512),Vector(512,512,512))
    ply.RenderOverride = function(self,flags)
        event.Run("PlayerDraw",ply)
    end
end

event.Add("Player Spawn","RenderOverride",function(ply)
    EnsureRenderOverride(ply)
end)

-- Cover players already on the server when we load, or who never trigger "Player Spawn"
-- (FakeDeath players, players who joined before the local client, etc.)
local nextCheck = 0
hook.Add("Think","HG_EnsureAllPlayersRenderOverride",function()
    if CurTime() < nextCheck then return end
    nextCheck = CurTime() + 0.5
    for _,ply in ipairs(player.GetAll()) do
        if IsValid(ply) and not ply.RenderOverride then
            EnsureRenderOverride(ply)
        end
    end
end)

-- Also catch new players the moment they are created on the client
hook.Add("OnEntityCreated","HG_NewPlayerRenderOverride",function(ent)
    if not IsValid(ent) or not ent:IsPlayer() then return end
    timer.Simple(0,function()
        if IsValid(ent) and not ent.RenderOverride then
            EnsureRenderOverride(ent)
        end
    end)
end)

event.Add("PlayerDraw","Main",function(ply,tag,link)
    if ply.GetAimVector then ply:SetEyeTarget(ply:GetAimVector()) end
    
    ply:DrawModel()
    
    ply.renderFrame = FrameNumber()
end,10)

// блядь какая же это параша, по сути если последним отрисовать игрока то он должен перекрывать всё, но это не происходит МДАМММММ КРИЖН
// с костями тоже странно, если сетать матрицуу костей после отрисовки оружия то почему-то оружие будет рендерится нормально (как будто матрицу до отрисовки изменил)
// ваще такая ебанина со всем этим ладно...

event.Add("PlayerDraw","SetupBones",function(ply,tag)//ресетаеми кости
    ply:SetupBones()
end,-20)
