-- Tipo: LocalScript
-- Ubicación: StarterPlayer/StarterPlayerScripts/HudController
-- Contexto: Cliente

--[[
	HudController
	Construye y actualiza el HUD: LED de estado (🟢🟡🔴), barra de energía de
	boost, mira central y panel de extremidades. Solo refleja el estado recibido
	del servidor (StateChanged) y la energía local; no decide gameplay.
	Ver UI_ASSET_SPEC.md y ReglasRoblox.md §7.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local energyCfg = Config.Energy

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ===== Construcción de UI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZB_HUD"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- LED de estado (círculo arriba-izquierda)
local led = Instance.new("Frame")
led.Name = "StatusLed"
led.Size = UDim2.fromOffset(28, 28)
led.Position = UDim2.fromOffset(24, 24)
led.BackgroundColor3 = Config.LedColors.ACTIVE
led.BorderSizePixel = 0
led.Parent = screenGui
local ledCorner = Instance.new("UICorner")
ledCorner.CornerRadius = UDim.new(1, 0)
ledCorner.Parent = led

-- Mira central
local crosshair = Instance.new("Frame")
crosshair.Name = "Crosshair"
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.Position = UDim2.fromScale(0.5, 0.5)
crosshair.Size = UDim2.fromOffset(6, 6)
crosshair.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
crosshair.BackgroundTransparency = 0.2
crosshair.BorderSizePixel = 0
crosshair.Parent = screenGui
local chCorner = Instance.new("UICorner")
chCorner.CornerRadius = UDim.new(1, 0)
chCorner.Parent = crosshair

-- Barra de energía (arriba-derecha)
local energyBack = Instance.new("Frame")
energyBack.Name = "EnergyBar"
energyBack.AnchorPoint = Vector2.new(1, 0)
energyBack.Position = UDim2.new(1, -24, 0, 24)
energyBack.Size = UDim2.fromOffset(220, 20)
energyBack.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
energyBack.BorderSizePixel = 0
energyBack.Parent = screenGui
local ebCorner = Instance.new("UICorner")
ebCorner.CornerRadius = UDim.new(0, 6)
ebCorner.Parent = energyBack

local energyFill = Instance.new("Frame")
energyFill.Name = "Fill"
energyFill.Size = UDim2.fromScale(1, 1)
energyFill.BackgroundColor3 = Color3.fromRGB(90, 220, 255)
energyFill.BorderSizePixel = 0
energyFill.Parent = energyBack
local efCorner = Instance.new("UICorner")
efCorner.CornerRadius = UDim.new(0, 6)
efCorner.Parent = energyFill

-- Panel de extremidades (abajo-izquierda)
local limbPanel = Instance.new("Frame")
limbPanel.Name = "LimbPanel"
limbPanel.AnchorPoint = Vector2.new(0, 1)
limbPanel.Position = UDim2.new(0, 24, 1, -24)
limbPanel.Size = UDim2.fromOffset(216, 44)
limbPanel.BackgroundTransparency = 1
limbPanel.Parent = screenGui
local limbLayout = Instance.new("UIListLayout")
limbLayout.FillDirection = Enum.FillDirection.Horizontal
limbLayout.Padding = UDim.new(0, 8)
limbLayout.Parent = limbPanel

local LIMB_ORDER = {
	{ key = Config.Limb.LEFT_ARM, label = "BI" },
	{ key = Config.Limb.RIGHT_ARM, label = "BD" },
	{ key = Config.Limb.LEFT_LEG, label = "PI" },
	{ key = Config.Limb.RIGHT_LEG, label = "PD" },
}

local limbIcons = {}
for _, info in ipairs(LIMB_ORDER) do
	local icon = Instance.new("TextLabel")
	icon.Name = info.key
	icon.Size = UDim2.fromOffset(48, 44)
	icon.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
	icon.BorderSizePixel = 0
	icon.Text = info.label
	icon.TextColor3 = Color3.fromRGB(240, 240, 240)
	icon.Font = Enum.Font.GothamBold
	icon.TextSize = 16
	icon.Parent = limbPanel
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = icon
	limbIcons[info.key] = icon
end

-- ===== Actualización =====
local function anyLimbFrozen(state)
	-- Propósito: Saber si al menos una extremidad está congelada.
	-- Precondiciones:
	--   1. state es una tabla de estado válida.
	-- Ubicación: StarterPlayerScripts/HudController
	-- Retorna: boolean
	for _, info in ipairs(LIMB_ORDER) do
		if state[info.key] == Config.LimbState.FROZEN then
			return true
		end
	end
	return false
end

local function onStateChanged(state)
	-- Propósito: Reflejar el estado del servidor en LED y panel de extremidades.
	-- Precondiciones:
	--   1. state es una tabla con extremidades y campo eliminated.
	-- Ubicación: StarterPlayerScripts/HudController
	-- Retorna: nil
	if type(state) ~= "table" then return end

	-- LED de estado.
	if state.eliminated then
		led.BackgroundColor3 = Config.LedColors.FROZEN
	elseif anyLimbFrozen(state) then
		led.BackgroundColor3 = Config.LedColors.DAMAGED
	else
		led.BackgroundColor3 = Config.LedColors.ACTIVE
	end

	-- Iconos de extremidad.
	for _, info in ipairs(LIMB_ORDER) do
		local icon = limbIcons[info.key]
		if icon then
			if state[info.key] == Config.LimbState.FROZEN then
				icon.BackgroundColor3 = Config.LedColors.ICE_TINT
				icon.TextColor3 = Color3.fromRGB(20, 40, 60)
			else
				icon.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
				icon.TextColor3 = Color3.fromRGB(240, 240, 240)
			end
		end
	end
end

local function updateEnergy()
	-- Propósito: Refrescar la barra de energía desde el atributo local.
	-- Precondiciones: ninguna.
	-- Ubicación: StarterPlayerScripts/HudController
	-- Retorna: nil
	local energy = player:GetAttribute("BoostEnergy") or energyCfg.MAX
	local ratio = math.clamp(energy / energyCfg.MAX, 0, 1)
	energyFill.Size = UDim2.fromScale(ratio, 1)
	if ratio < 0.15 then
		energyFill.BackgroundColor3 = Config.LedColors.FROZEN
	else
		energyFill.BackgroundColor3 = Color3.fromRGB(90, 220, 255)
	end
end

local stateChanged = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("StateChanged")
stateChanged.OnClientEvent:Connect(onStateChanged)
RunService.RenderStepped:Connect(updateEnergy)
