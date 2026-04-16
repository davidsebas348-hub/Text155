-- ======================
-- ROLE DETECTOR FINAL HYBRID
-- ======================

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

getgenv().ROLE_TABLE = getgenv().ROLE_TABLE or {}
local roleTable = getgenv().ROLE_TABLE

local playerData = {}

local GRAY = Color3.fromRGB(120,120,120)
local RED = Color3.fromRGB(255,0,0)
local BLUE = Color3.fromRGB(0,170,255)
local GREEN = Color3.fromRGB(0,255,0)

-- ======================
-- DETECTAR POR TOOL
-- ======================
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

-- ======================
-- DETECTOR HÍBRIDO
-- ======================
local function getRole(plr)
    local data = playerData[plr.Name]
    local dataRole = nil

    -- 1. playerData primero
    if data and data.Role then
        local role = tostring(data.Role)

        if role == "Murderer"
        or role == "Sheriff"
        or role == "Innocent" then
            dataRole = role
        end
    end

    -- 2. tool sobrescribe
    local toolRole = getRoleByTool(plr)

    if toolRole == "Murderer" or toolRole == "Sheriff" then
        return toolRole
    end

    -- 3. respaldo
    return dataRole or "Innocent"
end

-- ======================
-- REVISAR ROLES ACTIVOS
-- ======================
local function hasAnyMainRole()
    local hasMurder = false
    local hasSheriff = false

    for _, plr in ipairs(Players:GetPlayers()) do
        local alive = plr:GetAttribute("Alive")
        local role = getRole(plr)

        if alive == true then
            if role == "Murderer" then
                hasMurder = true
            elseif role == "Sheriff" then
                hasSheriff = true
            end
        end
    end

    return hasMurder, hasSheriff
end

-- ======================
-- COLOR
-- ======================
local function getFinalColor(role, gray)
    if gray then
        return GRAY
    end

    if role == "Murderer" then
        return RED
    elseif role == "Sheriff" then
        return BLUE
    else
        return GREEN
    end
end

-- ======================
-- UPDATE
-- ======================
local function updateAllPlayers()
    local hasMurder, hasSheriff = hasAnyMainRole()

    for _, plr in ipairs(Players:GetPlayers()) do
        local alive = plr:GetAttribute("Alive")
        local role = getRole(plr)

        local gray = false

        -- muerto o sin atributo
        if alive ~= true then
            gray = true
        end

        -- gris solo si no existe ninguno
        if not hasMurder and not hasSheriff then
            gray = true
        end

        roleTable[plr.Name] = {
            Role = role,
            Alive = alive,
            Color = getFinalColor(role, gray)
        }
    end
end

-- ======================
-- PLAYERDATA
-- ======================
RS:WaitForChild("Remotes")
    :WaitForChild("Gameplay")
    :WaitForChild("PlayerDataChanged")
    .OnClientEvent:Connect(function(data)

    playerData = data
    updateAllPlayers()
end)

-- ======================
-- PLAYERS
-- ======================
local function hookPlayer(plr)
    plr:GetAttributeChangedSignal("Alive"):Connect(function()
        updateAllPlayers()
    end)

    plr.CharacterAdded:Connect(function()
        task.wait(0.2)
        updateAllPlayers()
    end)
end

for _, plr in ipairs(Players:GetPlayers()) do
    hookPlayer(plr)
end

Players.PlayerAdded:Connect(function(plr)
    hookPlayer(plr)
    updateAllPlayers()
end)

Players.PlayerRemoving:Connect(function(plr)
    roleTable[plr.Name] = nil
end)

-- ======================
-- LOOP TIEMPO REAL
-- ======================
task.spawn(function()
    while true do
        updateAllPlayers()
        task.wait(0.1)
    end
end)
