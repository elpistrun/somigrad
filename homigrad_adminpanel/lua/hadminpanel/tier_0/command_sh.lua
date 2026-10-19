--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: My Garry's Mod Server (p2p:76561198879695295) <
    > File: addons/homigrad_adminpanel/lua/hadminpanel/tier_0/command_sh.lua <
    > Callstack: addons/homigrad_core/lua/shlib/loader.lua:149
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/shlib/loader.lua:157
addons/homigrad_core/lua/shlib/loader.lua:169
addons/homigrad_core/lua/autorun/shlib.lua:11 <
]]

-- "addons\\homigrad_adminpanel\\lua\\hadminpanel\\tier_0\\command_sh.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
AdminPanelCommands = AdminPanelCommands or {}
AdminPanelCommandsCategory = AdminPanelCommandsCategory or {}

local example = {}

function example:SetArgsType(argsType)
    local list = {}

    for i,argType in pairs(argsType) do
        if TypeID(argType) == TYPE_STRING then
            argType = {
                type = argType,
                desc = ""
            }
        end

        list[i] = argType
    end

    self.argsType = list
end

function example:SetType(value) self.typeCommand = value return self end
function example:SetDesc(value)
    self.desc = value
    AdminPanelCommandsCategory[self.category][self.name] = self.desc

    AdminPanelSuccessReg("command_" .. self.name,self.desc,self.category)

    return self
end

function example:SetCategory(value)
    if self.category != nil and AdminPanelCommandsCategory[self.category] then
        AdminPanelCommandsCategory[self.category][self.name] = nil
    end

    self.category = value

    AdminPanelCommandsCategory[value] = AdminPanelCommandsCategory[value] or {}
    AdminPanelCommandsCategory[value][self.name] = self.desc

    AdminPanelSuccessReg("command_" .. self.name,self.desc,self.category)

    return self
end

function example:SetDontShowGUI(value) self.dontShowGUI = value return self end

function AdminPanel_Command_Registry(cmdName,argsType,typeCommand,desc,category)
    local cmd = AdminPanelCommands[cmdName] or {}
    AdminPanelCommands[cmdName] = cmd

    cmd.name = cmdName

    for k,v in pairs(example) do cmd[k] = v end

    if argsType then cmd:SetArgsType(argsType) end
    if typeCommand then cmd:SetType(typeCommand) end

    cmd:SetCategory(category or cmd.category or "other")
    cmd:SetDesc(desc or cmd.desc or "no desc")

    local success = AdminPanelSuccessReg("command_" .. cmdName,cmd.desc,cmd.category)
    
    return cmd,success
end

function AdminPanel_Command_Create(cmdName,argsType,func,typeCommand,desc,category)
    local cmd,success = AdminPanel_Command_Registry(cmdName,argsType,typeCommand,desc,category)
    cmd.func = func

    return func,success
end

function COMMAND_GETARGS(args)
	local newArgs = {}
	local waitClose,waitCloseText

	for i,text in pairs(args) do
		if not waitClose and string.sub(text,1,1) == "\"" then
			waitClose = true

			if string.sub(text,#text,#text) == "\n" then
				newArgs[#newArgs + 1] = string.sub(text,2,#text - 1)

				waitClose = nil
			else
				waitCloseText = string.sub(text,2,#text)
			end

			continue
		end

		if waitClose then
			if string.sub(text,#text,#text) == "\"" then
				waitClose = nil

				newArgs[#newArgs + 1] = waitCloseText .. string.sub(text,1,#text - 1)
			else
				waitCloseText = waitCloseText .. string.sub(text,1,#text)
			end

			continue
		end

		newArgs[#newArgs + 1] = text
	end

	return newArgs
end

if SERVER then return end

hook.Add("OnPlayerChat","AdminPanel",function(ply,text)
    if ply != LocalPlayer() or string.sub(text,1,1) != "!" then return end

    local args = COMMAND_GETARGS(string.Split(string.sub(text,2,#text)," "))
    local cmdName = args[1]
    table.remove(args,1)

    local cmd = AdminPanelCommands[cmdName]
    if not cmd then return end

    if not ply:HasSuccess("command_" .. cmdName) then return end

    //у серверных команд func нет, их надо просто отправить на сервер
    if not cmd.func then
        AdminPanel_Command_SendServer(cmdName,args)

        return
    end

    cmd.func(args)
end)

concommand.Add("ulx",function(_,_,args)
    //голый "ulx" без аргументов открывает саму панель
    if not args[1] then
        RunConsoleCommand("adminpanel_menu")

        return
    end

    local cmd = AdminPanelCommands[args[1]]

    if cmd and cmd.func then
        local list = {}
        for i = 2,#args do list[#list + 1] = args[i] end

        cmd.func(list)
    else
        RunConsoleCommand("ulx_cmd",unpack(args))
    end
end)

function AdminPanel_Command_SendServer(cmdName,args)
    net.Start("adminpanel_command")
    net.WriteString(cmdName)
    net.WriteTable(args)
    net.SendToServer()
end

AdminPanel_Command_Registry("killallserver",{},nil,nil,"rcon")
