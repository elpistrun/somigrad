--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad/lua/hgame/tier_1/inv/tier_0_object/cl/ui_cl.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:162
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/z_shlib.lua:4 <
]]

-- "addons\\homigrad\\lua\\hgame\\tier_1\\inv\\tier_0_object\\cl\\ui_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
InvMoveSnd = {
    "physics/concrete/rock_impact_soft1.wav",
    "physics/concrete/rock_impact_soft2.wav",
    "physics/concrete/rock_impact_soft3.wav",

    "physics/concrete/rock_impact_soft1.wav",
    "physics/concrete/rock_impact_soft2.wav"
}

InvMoveSndGranade = {
    "physics/metal/metal_grenade_impact_hard1.wav",
    "physics/metal/metal_grenade_impact_hard1.wav",
    "physics/metal/metal_grenade_impact_hard1.wav"
}

InvMoveFastSnd = {
    "physics/concrete/rock_impact_soft1.wav",
    "physics/concrete/rock_impact_soft2.wav",
    "physics/concrete/rock_impact_soft3.wav",

    "physics/concrete/rock_impact_soft1.wav",
    "physics/concrete/rock_impact_soft2.wav"
}

InvMoveSndWeapon = {
    "physics/metal/weapon_impact_soft1.wav",
    "physics/metal/weapon_impact_soft2.wav",
    "physics/metal/weapon_impact_soft3.wav",

    "physics/metal/weapon_impact_soft1.wav",
    "physics/metal/weapon_impact_soft2.wav"
}

InvMoveSndPlastic = {
    "physics/plastic/plastic_box_impact_soft1.wav",
    "physics/plastic/plastic_box_impact_soft2.wav",

    "physics/plastic/plastic_box_impact_soft1.wav",
    "physics/plastic/plastic_box_impact_soft2.wav",
    "physics/plastic/plastic_box_impact_soft1.wav",--тупое унаследоваие, скажешь выдавай при инициализации. а я скажу тебе иди нахуй
}

InvMoveSndBody = {
    "physics/body/body_medium_impact_soft1.wav",
    "physics/body/body_medium_impact_soft2.wav",
    "physics/body/body_medium_impact_soft3.wav",
    "physics/body/body_medium_impact_soft4.wav",
    "physics/body/body_medium_impact_soft5.wav"
}

InvMoveSndAmmo = {
    "physics/metal/metal_grenade_impact_soft1.wav",
    "physics/metal/metal_grenade_impact_soft2.wav",
    "physics/metal/metal_grenade_impact_soft3.wav"
}

InvMoveSndWood = {
    "physics/wood/wood_furniture_impact_soft1.wav",
    "physics/wood/wood_furniture_impact_soft2.wav",
    "physics/wood/wood_furniture_impact_soft3.wav"
}

InvColorTypes = {
    weapon = Color(80,0,255),
    weaponSecondary = Color(80,80,200),
    knife = Color(0,160,40),
    melee = Color(0,160,40),
    other = Color(0,100,0),
    granade = Color(190,75,0),
    medical = Color(200,0,0),
    ["resource"] = Color(0,0,75),
    armor = Color(0,0,125),
    ammo = Color(125,125,0),

    poison = Color(220,30,30),
    mine = Color(255,125,200),
}

function InvPlaySnd(tbl,name,name2,default,pitch,volume)
    if not tbl then return end

    local snd = tbl ~= true and (tbl[name2] or tbl[name])
    if not snd and tbl.isWeapon then snd = InvMoveSndWeapon end

    LocalPlayer():EmitSound(
        (snd and TypeID(snd) == TYPE_TABLE and snd[math.random(1,#snd)] or snd) or default[math.random(1,#default)],
        75,
        math.random(99,101) + (pitch or 0),
        math.Rand(0.45,0.55) + (volume or 0)
    )
end

local size = 64

function InvCreate_Panel(inv)
    local slots = inv.slots
    local w,h = #slots,#slots[#slots]

    local panel = oop.CreatePanel("v_frame")
    panel:ad(function(self) self:setSize(w * size * ScreenSize,h * size * ScreenSize) end)
    panel:SetZPos(1000)
    panel:SetFocusTopLevel(true)
    
    local slots = {}
    panel.slots = slots

    for x = 1,w do
        slots[x] = {}

        for y = 1,h do
            local butt = oop.CreatePanel("v_inv_slot",panel)
            butt:ad(function(self) butt:setSize(size * ScreenSize,size * ScreenSize):setPos(self:W() * (x - 1),self:H() * (y - 1)) end)
            butt.slotX = x
            butt.slotY = y

            slots[x][y] = butt
        end
    end

    function panel:Error(x,y)
        slots[x][y].shake = CurTime() + 0.5
    end

    function panel:Close() self.closed = true end

    function panel:UpdateInv(inv)
        self.inv = inv
        self.closed = false--wtf?
        
        for i,child in pairs(self:GetChildren()) do
            child.inv = inv

            if child.UpdateInv then child:UpdateInv() end
        end
    end

    panel:UpdateInv(inv)

    if VRMODSELFENABLED then VRUIPopup(panel) end

    return panel
end

//if Initialize then InvPanelsReCreate() end
