local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local V5 = {}
V5.__index = V5

function V5:equip(toolName)
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local backpack = player:WaitForChild("Backpack")

    local tool = backpack:FindFirstChild(toolName)
    if not tool then
        return false, "Tool not found in Backpack"
    end

    tool.Parent = character

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:EquipTool(tool)
        return true
    else
        return false, "Humanoid not found"
    end
end

function V5:unequip(toolName)
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local backpack = player:WaitForChild("Backpack")

    local tool = character:FindFirstChild(toolName)
    if not tool then
        return false, "Tool not found in Character"
    end

    tool.Parent = backpack
    return true
end

function V5:activate(toolName)
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()

    local tool = character:FindFirstChild(toolName)
    if not tool then
        return false, "Tool not found in Character"
    end

    if tool:FindFirstChild("Handle") or tool:IsA("Tool") then
        tool:Activate()
        return true
    else
        return false, "Tool cannot be activated"
    end
end

function V5:load(rawLink)
    local success, scriptText = pcall(function()
        return game:HttpGet(rawLink)
    end)
    if not success then
        return false, "Failed to fetch script: "..tostring(scriptText)
    end

    local func, err = loadstring(scriptText)
    if not func then
        local fixedFunc = loadstring("return function()\n"..scriptText.."\nend")
        if fixedFunc then
            func = fixedFunc()
        else
            return false, "Failed to compile script: "..tostring(err)
        end
    end

    local ok, runErr = pcall(func)
    if not ok then
        return false, "Script runtime error: "..tostring(runErr)
    end

    return true
end

local default = setmetatable({}, V5)
setmetatable(V5, {
    __index = function(_, k)
        return function(_, ...)
            return default[k](default, ...)
        end
    end
})

return V5
