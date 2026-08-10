-- Tipo: LocalScript
-- Ubicacion: StarterPlayer/StarterPlayerScripts/IntroTutorial
-- Contexto: Cliente

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

print("[ZB Intro] Script iniciado")

local player = Players.LocalPlayer
if not player then
	warn("[ZB Intro] LocalPlayer es nil")
	return
end

local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then
	warn("[ZB Intro] PlayerGui no encontrado")
	return
end

print("[ZB Intro] Creando panel de bienvenida...")

-- Esperar a que la UI este completamente lista (camara, viewport, etc.)
task.wait(1.5)

print("[ZB Intro] PlayerGui listo, creando UI...")

local screen = Instance.new("ScreenGui")
screen.Name = "ZB_Intro"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.ZIndexBehavior = Enum.ZIndexBehavior.Global
screen.DisplayOrder = 10
screen.Parent = playerGui
print("[ZB Intro] ScreenGui parentado a PlayerGui. Visible = " .. tostring(screen.Enabled))

local bg = Instance.new("Frame")
bg.Size = UDim2.fromScale(1, 1)
bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bg.BackgroundTransparency = 0.75
bg.Parent = screen

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(480, 400)
panel.BackgroundColor3 = Color3.fromRGB(15, 17, 25)
panel.BackgroundTransparency = 0.15
panel.BorderSizePixel = 0
panel.Parent = screen
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(90, 220, 255)
stroke.Thickness = 2
stroke.Transparency = 0.5

local textColor = Color3.fromRGB(90, 220, 255)
local subColor = Color3.fromRGB(180, 200, 220)

local title = Instance.new("TextLabel", panel)
title.Size = UDim2.fromOffset(400, 40)
title.Position = UDim2.fromOffset(40, 20)
title.BackgroundTransparency = 1
title.Text = "ZERO BREACH"
title.TextColor3 = textColor
title.Font = Enum.Font.GothamBold
title.TextSize = 28
title.TextStrokeTransparency = 0.5

local subtitle = Instance.new("TextLabel", panel)
subtitle.Size = UDim2.fromOffset(400, 24)
subtitle.Position = UDim2.fromOffset(40, 56)
subtitle.BackgroundTransparency = 1
subtitle.Text = "CONTROLES"
subtitle.TextColor3 = subColor
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 16

local controls = {
	{ key = "W A S D", action = "Deriva (muy leve en batalla)" },
	{ key = "ESPACIO / CTRL", action = "Subir / Bajar" },
	{ key = "SHIFT", action = "Boost (consume energia)" },
	{ key = "Q", action = "Gancho (apunta con la mira)" },
	{ key = "E", action = "Agarrar coberturas / Impulsarse" },
	{ key = "CLICK IZQUIERDO", action = "Disparar (con retroceso)" },
	{ key = "F", action = "Portal (entrar a la arena)" },
}

local y = 90
for _, ctrl in ipairs(controls) do
	local row = Instance.new("Frame", panel)
	row.Size = UDim2.fromOffset(440, 32)
	row.Position = UDim2.fromOffset(20, y)
	row.BackgroundTransparency = 1

	local keyLabel = Instance.new("TextLabel", row)
	keyLabel.Size = UDim2.fromOffset(160, 30)
	keyLabel.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
	keyLabel.BorderSizePixel = 0
	keyLabel.Text = ctrl.key
	keyLabel.TextColor3 = textColor
	keyLabel.Font = Enum.Font.GothamBold
	keyLabel.TextSize = 15
	Instance.new("UICorner", keyLabel).CornerRadius = UDim.new(0, 5)
	local ks = Instance.new("UIStroke", keyLabel)
	ks.Color = textColor
	ks.Thickness = 1
	ks.Transparency = 0.6

	local actionLabel = Instance.new("TextLabel", row)
	actionLabel.Size = UDim2.fromOffset(260, 30)
	actionLabel.Position = UDim2.fromOffset(175, 0)
	actionLabel.BackgroundTransparency = 1
	actionLabel.Text = ctrl.action
	actionLabel.TextColor3 = Color3.fromRGB(200, 210, 225)
	actionLabel.Font = Enum.Font.Gotham
	actionLabel.TextSize = 14
	actionLabel.TextXAlignment = Enum.TextXAlignment.Left

	y = y + 38
end

local closed = false
local function close()
	if closed then return end
	closed = true
	screen:Destroy()
	print("[ZB Intro] Panel cerrado")
end

-- Pequena pausa para evitar que InputBegan cierre la UI al instante
task.wait(0.3)

task.delay(12, close)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not closed and not gameProcessed then close() end
end)

local dismiss = Instance.new("TextLabel", panel)
dismiss.Size = UDim2.fromOffset(400, 24)
dismiss.Position = UDim2.fromOffset(40, y + 10)
dismiss.BackgroundTransparency = 1
dismiss.Text = "Presiona cualquier tecla para continuar..."
dismiss.TextColor3 = Color3.fromRGB(120, 140, 160)
dismiss.Font = Enum.Font.Gotham
dismiss.TextSize = 13
