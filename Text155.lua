-- ======================
-- ROLE DETECTOR (SIEMPRE ACTIVO)
-- ======================

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

getgenv().ROLE_TABLE = getgenv().ROLE_TABLE or {}
local roleTable = getgenv().ROLE_TABLE

local playerData = {}

local function getRoleByTool(plr)
    if not plr then return nil end

    local backpack = plr:FindFirstChild("Backpack")
    local char = plr.Character

    if backpack then
        if backpack:FindFirstChild("Knife") then
            return "Murderer"
        end
        if backpack:FindFirstChild("Gun") then
            return "Sheriff"
        end
    end

    if char then
        if char:FindFirstChild("Knife") then
            return "Murderer"
        end
        if char:FindFirstChild("Gun") then
            return "Sheriff"
        end
    end

    return nil
end

local function updatePlayerRole(plr)
    if not plr then return end

    local role = getRoleByTool(plr)

    if not role and playerData[plr.Name] then
        role = playerData[plr.Name].Role
    end

    roleTable[plr.Name] = role or "Innocent"
end

local function removePlayer(plr)
    roleTable[plr.Name] = nil
end

for _, plr in ipairs(Players:GetPlayers()) do
    updatePlayerRole(plr)

    plr.CharacterAdded:Connect(function()
        task.wait(0.3)
        updatePlayerRole(plr)
    end)
end

Players.PlayerAdded:Connect(function(plr)
    updatePlayerRole(plr)

    plr.CharacterAdded:Connect(function()
        task.wait(0.3)
        updatePlayerRole(plr)
    end)
end)

Players.PlayerRemoving:Connect(removePlayer)

RS:WaitForChild("Remotes")
    :WaitForChild("Gameplay")
    :WaitForChild("PlayerDataChanged")
    .OnClientEvent:Connect(function(data)

    playerData = data

    for _, plr in ipairs(Players:GetPlayers()) do
        updatePlayerRole(plr)
    end
end)

task.spawn(function()
    while true do
        for _, plr in ipairs(Players:GetPlayers()) do
            updatePlayerRole(plr)
        end
        task.wait(0.2)
    end
end)
