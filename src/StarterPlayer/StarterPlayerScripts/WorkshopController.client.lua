-- Tipo: LocalScript
-- Ubicación: StarterPlayer/StarterPlayerScripts/WorkshopController
-- Contexto: Cliente

--[[
	WorkshopController
	Interfaz del "taller": tienda donde el jugador gasta monedas para:
	- Equipar un arma (Config.Weapons).
	- Cambiar el color del láser (Config.LaserColors).
	- Subir la estamina máxima (Config.StaminaUpgrade).

	El taller es un espacio físico en el lobby: al acercarse, un ProximityPrompt
	permite abrir la tienda con la tecla configurada (Config.Workshop.KEY).
	Envía peticiones al servidor por el RemoteEvent "WorkshopBuy".
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local modeCfg = Config.GameMode
local staminaCfg = Config.StaminaUpgrade
local workshopCfg = Config.Workshop

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local buyRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("WorkshopBuy")

-- ===== GUI base =====
local gui = Instance.new("ScreenGui")
gui.Name = "ZB_Taller"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

-- Panel principal
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.new(0.5, 0, 0.5, 0)
panel.Size = UDim2.fromOffset(360, 520)
panel.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui
local pCorner = Instance.new("UICorner")
pCorner.CornerRadius = UDim.new(0, 12)
pCorner.Parent = panel

-- Título
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Position = UDim2.new(0, 16, 0, 14)
title.Size = UDim2.new(1, -100, 0, 32)
title.BackgroundTransparency = 1
title.BorderSizePixel = 0
title.Text = "TALLER"
title.TextColor3 = Color3.fromRGB(90, 220, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

-- Botón cerrar
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.AnchorPoint = Vector2.new(1, 0)
closeButton.Position = UDim2.new(1, -16, 0, 14)
closeButton.Size = UDim2.fromOffset(32, 32)
closeButton.BackgroundColor3 = Color3.fromRGB(60, 30, 34)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.Parent = panel
local ccCorner = Instance.new("UICorner")
ccCorner.CornerRadius = UDim.new(0, 8)
ccCorner.Parent = closeButton

-- Monedas (dentro del panel)
local coinsLabel = Instance.new("TextLabel")
coinsLabel.Name = "Coins"
coinsLabel.Position = UDim2.new(0, 16, 0, 48)
coinsLabel.Size = UDim2.new(1, -32, 0, 22)
coinsLabel.BackgroundTransparency = 1
coinsLabel.BorderSizePixel = 0
coinsLabel.Text = "Monedas: 0"
coinsLabel.TextColor3 = Color3.fromRGB(255, 210, 60)
coinsLabel.Font = Enum.Font.GothamBold
coinsLabel.TextSize = 15
coinsLabel.TextXAlignment = Enum.TextXAlignment.Left
coinsLabel.Parent = panel

-- Área con scroll
local scroller = Instance.new("ScrollingFrame")
scroller.Name = "Scroller"
scroller.Position = UDim2.new(0, 8, 0, 74)
scroller.Size = UDim2.new(1, -16, 1, -82)
scroller.BackgroundTransparency = 1
scroller.BorderSizePixel = 0
scroller.ScrollingDirection = Enum.ScrollingDirection.Y
scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroller.CanvasSize = UDim2.new(0, 0, 0, 0)
scroller.ScrollBarThickness = 4
scroller.ScrollBarImageColor3 = Color3.fromRGB(90, 220, 255)
scroller.Parent = panel

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 6)
listLayout.Parent = scroller

-- ===== Utilidades =====
local function sectionHeader(text)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -4, 0, 22)
	l.BackgroundTransparency = 1
	l.BorderSizePixel = 0
	l.Text = text
	l.TextColor3 = Color3.fromRGB(160, 175, 190)
	l.Font = Enum.Font.GothamBold
	l.TextSize = 14
	l.TextXAlignment = Enum.TextXAlignment.Left
	return l
end

local function equippedWeaponId()
	return player:GetAttribute("WeaponId") or Config.Weapons[1].id
end

local function equippedColorId()
	local c = player:GetAttribute("LaserColor")
	if c == nil then return Config.LaserColors[1].id end
	for _, entry in ipairs(Config.LaserColors) do
		if entry.color == c then return entry.id end
	end
	return Config.LaserColors[1].id
end

-- ===== Construir secciones =====

-- ESTAMINA
local staminaHeader = sectionHeader("ESTAMINA")
staminaHeader.Parent = scroller

local staminaLabel = Instance.new("TextLabel")
staminaLabel.Size = UDim2.new(1, -4, 0, 18)
staminaLabel.BackgroundTransparency = 1
staminaLabel.BorderSizePixel = 0
staminaLabel.Text = "Estamina máxima: 100"
staminaLabel.TextColor3 = Color3.fromRGB(220, 225, 232)
staminaLabel.Font = Enum.Font.Gotham
staminaLabel.TextSize = 13
staminaLabel.TextXAlignment = Enum.TextXAlignment.Left
staminaLabel.Parent = scroller

local staminaButton = Instance.new("TextButton")
staminaButton.Size = UDim2.new(1, -4, 0, 34)
staminaButton.BackgroundColor3 = Color3.fromRGB(40, 46, 58)
staminaButton.BorderSizePixel = 0
staminaButton.Text = "+20 estamina (" .. tostring(staminaCfg.COST_PER_TIER) .. "c)"
staminaButton.TextColor3 = Color3.fromRGB(240, 240, 240)
staminaButton.Font = Enum.Font.GothamBold
staminaButton.TextSize = 14
staminaButton.Parent = scroller
local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 8)
sbCorner.Parent = staminaButton
staminaButton.Activated:Connect(function()
	buyRemote:FireServer("stamina", nil)
end)

-- ARMAS
local weaponHeader = sectionHeader("ARMAS")
weaponHeader.Parent = scroller

local weaponButtons = {}
for _, weapon in ipairs(Config.Weapons) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -4, 0, 34)
	btn.BackgroundColor3 = Color3.fromRGB(40, 46, 58)
	btn.BorderSizePixel = 0
	btn.Text = weapon.name
	btn.TextColor3 = Color3.fromRGB(240, 240, 240)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.Parent = scroller
	local bCorner = Instance.new("UICorner")
	bCorner.CornerRadius = UDim.new(0, 8)
	bCorner.Parent = btn
	btn.Activated:Connect(function()
		buyRemote:FireServer("weapon", weapon.id)
	end)
	weaponButtons[weapon.id] = btn
end

-- COLORES
local colorHeader = sectionHeader("COLOR DEL LÁSER")
colorHeader.Parent = scroller

local colorButtons = {}
for _, entry in ipairs(Config.LaserColors) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -4, 0, 34)
	btn.BackgroundColor3 = entry.color
	btn.BorderSizePixel = 0
	btn.Text = entry.name
	btn.TextColor3 = Color3.fromRGB(20, 20, 20)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.Parent = scroller
	local bCorner = Instance.new("UICorner")
	bCorner.CornerRadius = UDim.new(0, 8)
	bCorner.Parent = btn
	btn.Activated:Connect(function()
		buyRemote:FireServer("color", entry.id)
	end)
	colorButtons[entry.id] = btn
end

-- ===== Apertura / cierre =====
local open = false

local function refresh()
	local stats = player:FindFirstChild("leaderstats")
	local coinsVal = stats and stats:FindFirstChild(Config.Currency.LEADERSTAT)
	local coins = coinsVal and coinsVal.Value or 0
	coinsLabel.Text = "Monedas: " .. tostring(coins)

	local maxStamina = player:GetAttribute("MaxStamina") or Config.Energy.MAX
	staminaLabel.Text = "Estamina máxima: " .. tostring(maxStamina)

	local wId = equippedWeaponId()
	for _, weapon in ipairs(Config.Weapons) do
		local btn = weaponButtons[weapon.id]
		if btn then
			if weapon.id == wId then
				btn.Text = weapon.name .. "  (Equipada)"
				btn.BackgroundColor3 = Color3.fromRGB(50, 90, 70)
			else
				btn.Text = weapon.name .. "  (" .. tostring(weapon.cost) .. "c)"
				btn.BackgroundColor3 = Color3.fromRGB(40, 46, 58)
			end
		end
	end

	local cId = equippedColorId()
	for _, entry in ipairs(Config.LaserColors) do
		local btn = colorButtons[entry.id]
		if btn then
			if entry.id == cId then
				btn.Text = entry.name .. "  (Equipado)"
			else
				btn.Text = entry.name .. "  (" .. tostring(entry.cost) .. "c)"
			end
			btn.BackgroundColor3 = entry.color
		end
	end
end

local function setOpen(value)
	open = value
	panel.Visible = value
	if value then refresh() end
end

local function inLobby()
	local mode = player:GetAttribute("GameMode") or modeCfg.LOBBY
	return mode == modeCfg.LOBBY
end

closeButton.Activated:Connect(function()
	setOpen(false)
end)

-- ===== ProximityPrompt en el taller físico =====
local PROMPT_NAME = "ZB_TallerPrompt"

local function setupTaller(part)
	if part:FindFirstChild(PROMPT_NAME) then return end

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = PROMPT_NAME
	prompt.ActionText = workshopCfg.PROMPT_ACTION
	prompt.ObjectText = workshopCfg.PROMPT_OBJECT
	prompt.KeyboardKeyCode = workshopCfg.KEY
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = workshopCfg.MAX_DISTANCE
	prompt.RequiresLineOfSight = false
	prompt.Parent = part

	prompt.Triggered:Connect(function()
		if inLobby() then setOpen(true) end
	end)
end

for _, inst in ipairs(workspace:GetDescendants()) do
	if inst:IsA("BasePart") and inst:GetAttribute(workshopCfg.ATTRIBUTE) then
		setupTaller(inst)
	end
end
workspace.DescendantAdded:Connect(function(inst)
	if inst:IsA("BasePart") and inst:GetAttribute(workshopCfg.ATTRIBUTE) then
		setupTaller(inst)
	end
end)

-- Cerrar automáticamente si empieza la partida y refrescar la tienda.
local lastRefresh = 0
RunService.RenderStepped:Connect(function(dt)
	if not inLobby() and open then
		setOpen(false)
	end
	if open then
		lastRefresh = lastRefresh + dt
		if lastRefresh >= 0.3 then
			lastRefresh = 0
			refresh()
		end
	end
end)
