--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgamemode/roundsystem/levels/_special/construct/modules/team_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:117
addons/homigrad_core/lua/shlib/tier_1/oop/sh_tier_0_main.lua:150
addons/homigrad/lua/hgamemode/roundsystem/levels/_special/construct/init_tier_0_sh.lua:3
[C]:-1
addons/homigrad_core/lua/shlib/loader.lua:143
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:8 <
]]

-- "addons\\homigrad\\lua\\hgamemode\\roundsystem\\levels\\_special\\construct\\modules\\team_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local Level = oop.Get("level_construct")
if not Level then return end

Teams = Teams or {}

function Construct_FindTeamByID(plyID)
    for ownerID,team in pairs(Teams) do
        if team.members[plyID] then return team end
    end
end

function Construct_IsFriend(plyID1,plyID2)
    return Construct_FindTeamByID(plyID1) == Construct_FindTeamByID(plyID2)
end

local update

net.Receive("Construct team",function()
    for k in pairs(Teams) do Teams[k] = nil end
    for k,v in pairs(net.ReadTable()) do Teams[k] = v end

    update()
end)

friendRequest = friendRequest or {}

update = function()
    local i = 0

    for callerID,panel in pairs(friendRequest) do if IsValid(panel) then panel:Remove() end friendRequest[callerID] = nil end

    local lplyID = LocalPlayer():SteamID()

    for ownerID,team in pairs(Teams) do
        for plyID,callerID in pairs(team.wait) do
            if plyID ~= lplyID then continue end

            local panel = vgui.Create("DPanel")
            panel:SetSize(200,65)
            panel:SetPos(50,ScrH() - 70 - 70 * i - 10 * i)
    
            friendRequest[callerID] = panel
    
            local name = team.members[callerID]

            function panel:Paint(w,h)
                surface.SetDrawColor(0,0,0,200)
                surface.DrawRect(0,0,w,h)
    
                draw.SimpleText(name,"ChatFont",w / 2,5,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
                draw.SimpleText("Хочет добавить вас в зелёнку","ChatFont",w / 2,20,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
            end
            
            local accept = vgui.Create("DButton",panel)
            accept:SetSize(60,20)
            accept:SetPos(5,40)
            accept:SetText("Принять")
    
            function accept:DoClick()
                RunConsoleCommand("hg_construct_team_join",callerID)
    
                panel:Remove()
    
                friendRequest[callerID] = nil
                update()
            end
    
            local deaccept = vgui.Create("DButton",panel)
            deaccept:SetSize(60,20)
            deaccept:SetPos(200 - 60 - 5,40)
            deaccept:SetText("Отклонить")
    
            function deaccept:DoClick()
                RunConsoleCommand("hg_construct_team_cancel",callerID)
    
                panel:Remove()
    
                friendRequest[callerID] = nil
                update()
            end
    
            i = i + 1
        end
    end
end

local old,start,oldEnt

local function can(ply)
    local wep = ply:GetActiveWeapon()
    if IsValid(wep) and wep:GetClass() ~= "weapon_hands" then return end

    local trace = ply:EyeTrace(75)
    if not trace then return end

    local ent = trace.Entity
    if not IsValid(ent) or not ent:IsPlayer() or not ent:Alive() then return end
    
    local wep = ent:GetActiveWeapon()
    if IsValid(wep) and wep:GetClass() ~= "weapon_hands" then return end

    return not Construct_FindTeamByID(ent:SteamID()) and ent
end

function Level:DrawRequestTeam()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    
    local ent = can(ply)

    if ent ~= oldEnt then
        start = nil

        oldEnt = ent
    end

    if not ent then return end

    local value = ply:KeyDown(IN_USE)

    if value ~= old then
        if value then
            start = CurTime()
        else
            start = nil
        end

        old = value
    end

    if start then
        local k = math.max(start + 0.5 - CurTime(),0) / 3
        local anim_pos = math.max(0.25 - k,0) / 0.25

        if anim_pos > 0 then
            anim_pos = 1 - anim_pos

            local w,h = ScrW(),ScrH()

            surface.SetDrawColor(0,0,0,200)
            surface.DrawRect(w / 2 - 100,h / 2 - 5,200,10)

            surface.SetDrawColor(255,255,255,125)

            local width = anim_pos * 200
            surface.DrawRect(w / 2 - width / 2,h / 2 - 5,width,10)
        end

        if k <= 0 then
            RunConsoleCommand("hg_construct_team_request",ent:UserID())

            start = nil
        end
    end
end

local green = Color(0,255,0,125)
local green2 = Color(125,255,125,225)
local red = Color(255,0,0)
local white = Color(255,255,255)
local gray = Color(156,156,156)

local menu

concommand.Add("hg_teams_print",function()
    PrintTable(Teams)
end)

local disTrace = {}

local delay = 0

function Level:DrawTeams()
    local i = 0

    local team = Construct_FindTeamByID(LocalPlayer():SteamID())
    if not team then return end

    local time = CurTime()

    for plyID,name in pairs(team.members) do
        local y = ScrH() - 48 - i * 20

        surface.SetFont("H.18")

        if plyID == team.ownerID then name = "*" .. name end

        local w,h = surface.GetTextSize(name)
        local mx,my = gui.MouseX(),gui.MouseY()

        local ply = player.GetBySteamID(plyID)

        if IsValid(ply) and ply ~= LocalPlayer() then
            local dis = disTrace[ply]

            if not dis or delay < time then
                local tr = {
                    start = EyePos(),
                    endpos = ply:GetPos():Add(ply:OBBCenter()),
                    filter = LocalPlayer(),
                    mask = MASK_SHOT
                }

                if util.TraceLine(tr).Entity == ply then
                    dis = tr.start:Distance(tr.endpos)
                else
                    dis = nil
                end

                disTrace[ply] = dis
            end
            
            if dis and dis < 4000 then
                local pos = ply:LookupBone("ValveBiped.Bip01_Head1")
                
                local add = dis <= 128 and Vector(0,0,8) or Vector(0,0,12)
                local pos = pos and ply:GetBonePosition(pos):Add(add) or (ply:GetPos():Add(ply:OBBCenter()))
        
                pos = pos:ToScreen()
                
                if dis <= 512 then
                    draw.SimpleText(name,"ChatFont",pos.x,pos.y,green,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                else
                    draw.RoundedBox(4,pos.x - 2,pos.y - 2,4,4,green2)
                end
            end
        end

        if math.pointinbox(mx,my,32,y,w,h) then
            draw.SimpleText(name,"H.18",32,y,white)

            if not IsValid(menu) and input.IsMouseDown(MOUSE_LEFT) then
                menu = DermaMenu()
                menu:AddOption("Кикнуть",function() RunConsoleCommand("hg_construct_team_kick",plyID) end)
                menu:Open()
                menu:SetPos(mx,my)
            end
        else
            if not IsValid(ply) then
                draw.SimpleText(name,"H.18",32,y,gray)
            else
                draw.SimpleText(name,"H.18",32,y,ply:Alive() and green or red)
            end
        end
        
        i = i + 1
    end

    if delay < time then delay = time + 0.25 end
end
