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
local weaponCfg = Config.Weapon
local matchCfg = Config.Match
local modeCfg = Config.GameMode
local currencyCfg = Config.Currency

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local battleOptOutChanged = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("BattleOptOutChanged")

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
crosshair.Position = UDim2.new(0.5, weaponCfg.CROSSHAIR_OFFSET_X, 0.5, weaponCfg.CROSSHAIR_OFFSET_Y)
crosshair.Size = UDim2.fromOffset(6, 6)
crosshair.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
crosshair.BackgroundTransparency = 0.2
crosshair.BorderSizePixel = 0
crosshair.Parent = screenGui
local chCorner = Instance.new("UICorner")
chCorner.CornerRadius = UDim.new(1, 0)
chCorner.Parent = crosshair

-- Anuncio de partida / cuenta regresiva (centro de pantalla)
local matchStatus = Instance.new("TextLabel")
matchStatus.Name = "MatchStatus"
matchStatus.AnchorPoint = Vector2.new(0.5, 0.5)
matchStatus.Position = UDim2.new(0.5, 0, 0, 72)
matchStatus.Size = UDim2.fromOffset(420, 36)
matchStatus.BackgroundTransparency = 1
matchStatus.BorderSizePixel = 0
matchStatus.Text = ""
matchStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
matchStatus.Font = Enum.Font.GothamBold
matchStatus.TextSize = 24
matchStatus.TextStrokeTransparency = 0
matchStatus.Visible = false
matchStatus.Parent = screenGui

local roundOptions = Instance.new("Frame")
roundOptions.Name = "RoundOptions"
roundOptions.AnchorPoint = Vector2.new(1, 0)
roundOptions.Position = UDim2.new(1, -24, 0, 54)
roundOptions.Size = UDim2.fromOffset(250, 28)
roundOptions.BackgroundTransparency = 0.45
roundOptions.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
roundOptions.BorderSizePixel = 0
roundOptions.Parent = screenGui
local roundOptionsCorner = Instance.new("UICorner")
roundOptionsCorner.CornerRadius = UDim.new(0, 8)
roundOptionsCorner.Parent = roundOptions

local optOutButton = Instance.new("TextButton")
optOutButton.Name = "OptOutButton"
optOutButton.AnchorPoint = Vector2.new(0, 0.5)
optOutButton.Position = UDim2.fromOffset(8, 14)
optOutButton.Size = UDim2.fromOffset(14, 14)
optOutButton.BackgroundColor3 = Color3.fromRGB(50, 60, 75)
optOutButton.BorderSizePixel = 0
optOutButton.Text = ""
optOutButton.AutoButtonColor = false
optOutButton.Parent = roundOptions
local optOutCorner = Instance.new("UICorner")
optOutCorner.CornerRadius = UDim.new(0, 5)
optOutCorner.Parent = optOutButton

local optOutCheck = Instance.new("TextLabel")
optOutCheck.Name = "Check"
optOutCheck.Size = UDim2.fromScale(1, 1)
optOutCheck.BackgroundTransparency = 1
optOutCheck.Text = ""
optOutCheck.TextColor3 = Color3.fromRGB(20, 30, 40)
optOutCheck.Font = Enum.Font.GothamBold
optOutCheck.TextSize = 12
optOutCheck.Parent = optOutButton

local optOutLabel = Instance.new("TextLabel")
optOutLabel.Name = "OptOutLabel"
optOutLabel.AnchorPoint = Vector2.new(0, 0.5)
optOutLabel.Position = UDim2.fromOffset(28, 14)
optOutLabel.Size = UDim2.fromOffset(214, 18)
optOutLabel.BackgroundTransparency = 1
optOutLabel.BorderSizePixel = 0
optOutLabel.Text = "No entrar a la proxima batalla"
optOutLabel.TextColor3 = Color3.fromRGB(230, 235, 245)
optOutLabel.Font = Enum.Font.GothamMedium
optOutLabel.TextSize = 13
optOutLabel.TextXAlignment = Enum.TextXAlignment.Left
optOutLabel.Parent = roundOptions

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

-- Contador de monedas (arriba-derecha, visible solo en lobby)
local coinsLabel = Instance.new("TextLabel")
coinsLabel.Name = "CoinsLabel"
coinsLabel.AnchorPoint = Vector2.new(1, 0)
coinsLabel.Position = UDim2.new(1, -24, 0, 24)
coinsLabel.Size = UDim2.fromOffset(160, 24)
coinsLabel.BackgroundTransparency = 1
coinsLabel.BorderSizePixel = 0
coinsLabel.Text = "0 monedas"
coinsLabel.TextColor3 = Color3.fromRGB(255, 210, 60)
coinsLabel.Font = Enum.Font.GothamBold
coinsLabel.TextSize = 20
coinsLabel.TextXAlignment = Enum.TextXAlignment.Right
coinsLabel.Visible = false
coinsLabel.Parent = screenGui

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

local function updateHud()
	-- Propósito: Refrescar barra de estamina (batalla) o contador de monedas (lobby).
	-- Precondiciones: ninguna.
	-- Ubicación: StarterPlayerScripts/HudController
	-- Retorna: nil
	local mode = player:GetAttribute("GameMode") or modeCfg.LOBBY
	local inBattle = (mode == modeCfg.BATTLE or mode == modeCfg.DUEL)

	if inBattle then
		energyBack.Visible = true
		coinsLabel.Visible = false

		local maxStamina = player:GetAttribute("MaxStamina") or energyCfg.MAX
		local stamina = player:GetAttribute("Stamina")
		if stamina == nil then stamina = maxStamina end
		local ratio = math.clamp(stamina / maxStamina, 0, 1)
		energyFill.Size = UDim2.fromScale(ratio, 1)
		if ratio < 0.15 then
			energyFill.BackgroundColor3 = Config.LedColors.FROZEN
		else
			energyFill.BackgroundColor3 = Color3.fromRGB(90, 220, 255)
		end
	else
		energyBack.Visible = false
		coinsLabel.Visible = true

		local coins = 0
		local stats = player:FindFirstChild("leaderstats")
		local coinsVal = stats and stats:FindFirstChild(currencyCfg.LEADERSTAT)
		if coinsVal then coins = coinsVal.Value end
		coinsLabel.Text = tostring(coins) .. " monedas"
	end
end

local function updateOptOutUi()
	local optedOut = player:GetAttribute(matchCfg.OPT_OUT_ATTRIBUTE) == true
	if optedOut then
		optOutButton.BackgroundColor3 = Color3.fromRGB(255, 213, 79)
		optOutCheck.Text = "X"
		optOutLabel.TextColor3 = Color3.fromRGB(255, 230, 150)
	else
		optOutButton.BackgroundColor3 = Color3.fromRGB(50, 60, 75)
		optOutCheck.Text = ""
		optOutLabel.TextColor3 = Color3.fromRGB(230, 235, 245)
	end
end

local stateChanged = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("StateChanged")
stateChanged.OnClientEvent:Connect(onStateChanged)
RunService.RenderStepped:Connect(updateHud)

-- ===== Anuncio de estado de partida (cuenta regresiva / ganador) =====
local function onMatchStateChanged(payload)
	-- Propósito: Mostrar en pantalla la cuenta regresiva de inicio, el
	--            anuncio del ganador y la cuenta para volver al lobby.
	-- Precondiciones:
	--   1. payload es una tabla con state, countdown, resetCountdown, winner.
	-- Ubicación: StarterPlayerScripts/HudController
	-- Retorna: nil
	if type(payload) ~= "table" then return end

	local state = payload.state

	if state == matchCfg.STATE_COUNTDOWN then
		matchStatus.Text = "La partida comienza en " .. tostring(payload.countdown or 0) .. "s"
		matchStatus.Visible = true
	elseif state == matchCfg.STATE_LOBBY then
		matchStatus.Text = "Esperando jugadores: " .. tostring(payload.eligiblePlayers or 0) .. "/" .. tostring(matchCfg.MIN_PLAYERS_TO_START)
		matchStatus.Visible = true
	elseif state == matchCfg.STATE_ACTIVE or state == matchCfg.STATE_LOCKED then
		local remaining = math.max(0, (payload.matchDuration or 0) - (payload.matchTimer or 0))
		matchStatus.Text = "Tiempo restante: " .. tostring(remaining) .. "s"
		matchStatus.Visible = true
	elseif state == matchCfg.STATE_ENDING then
		local winner = payload.winner
		if winner == "Partida invalida" then
			matchStatus.Text = "Partida invalida"
		elseif winner and winner ~= "Empate" then
			matchStatus.Text = "¡Gana el equipo " .. tostring(winner) .. "!"
		else
			matchStatus.Text = "Empate"
		end
		matchStatus.Visible = true
	else
		matchStatus.Text = ""
		matchStatus.Visible = false
	end
end

local matchStateChanged = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("MatchStateChanged")
matchStateChanged.OnClientEvent:Connect(onMatchStateChanged)

optOutButton.MouseButton1Click:Connect(function()
	local nextValue = not (player:GetAttribute(matchCfg.OPT_OUT_ATTRIBUTE) == true)
	battleOptOutChanged:FireServer(nextValue)
end)

player:GetAttributeChangedSignal(matchCfg.OPT_OUT_ATTRIBUTE):Connect(updateOptOutUi)
updateOptOutUi()
