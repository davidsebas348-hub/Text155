-- ======================
-- ESP SOLO SHERIFF (TOGGLE POR EJECUCIÓN)
-- ======================

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ======================
-- TOGGLE GLOBAL
-- ======================
_G.SheriffESP = not _G.SheriffESP

-- ======================
-- FUNCIÓN LIMPIAR TODO
-- ======================
local function ClearESP()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character then
			local h = plr.Character:FindFirstChild("SheriffESP")
			if h then h:Destroy() end
		end
	end
end

-- ======================
-- SI SE DESACTIVA
-- ======================
if not _G.SheriffESP then
	if _G.SheriffESPConnection then
		_G.SheriffESPConnection:Disconnect()
		_G.SheriffESPConnection = nil
	end
	ClearESP()
	warn("❌ ESP SHERIFF DESACTIVADO")
	return
end

warn("✅ ESP SHERIFF ACTIVADO")

-- ======================
-- FUNCIONES
-- ======================
local function hasGun(player)
	if not player then return false end
	local function check(container)
		if not container then return false end
		for _, t in ipairs(container:GetChildren()) do
			if t:IsA("Tool") and (t.Name == "Gun" or t.Name == "Pistol") then
				return true
			end
		end
	end
	return check(player.Character) or check(player:FindFirstChild("Backpack"))
end

local function applyESP(player)
	if not player.Character then return end
	if player.Character:FindFirstChild("SheriffESP") then return end

	local h = Instance.new("Highlight")
	h.Name = "SheriffESP"
	h.Adornee = player.Character
	h.FillColor = Color3.fromRGB(0,0,255)
	h.OutlineColor = Color3.fromRGB(0,0,255)
	h.FillTransparency = 0.5
	h.OutlineTransparency = 0
	h.Parent = player.Character
end

-- ======================
-- LOOP ÚNICO Y CONTROLADO
-- ======================
_G.SheriffESPConnection = RunService.RenderStepped:Connect(function()
	if not _G.SheriffESP then return end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
			if plr.Character.Humanoid.Health <= 0 then
				local h = plr.Character:FindFirstChild("SheriffESP")
				if h then h:Destroy() end
			else
				if hasGun(plr) then
					applyESP(plr)
				else
					local h = plr.Character:FindFirstChild("SheriffESP")
					if h then h:Destroy() end
				end
			end
		end
	end
end)
