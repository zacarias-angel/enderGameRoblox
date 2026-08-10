-- Tipo: LocalScript
-- Ubicación: StarterPlayer/StarterPlayerScripts/IntroTutorial
-- Contexto: Cliente

--[[
	IntroTutorial
	Muestra un panel de bienvenida con los controles al entrar al juego.
	Desaparece al presionar cualquier tecla o después de 10 segundos.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Solo mostrar una vez por sesión
local SHOWN_KEY = "ZB_IntroShown"
if player:GetAttribute(SHOWN_KEY) then return end
player:SetAttribute(SHOWN_KEY, true)

local screen = Instance.new("ScreenGui")
screen.Name = "ZB_Intro"
screen.ResetOnSpawn = true
screen.IgnoreGuiInset = true
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.DisplayOrder = 999
screen.Parent = playerGui

-- Fondo oscuro
local bg = Instance.new("Frame")
bg.Name = "Background"
bg.Size = UDim2.fromScale(1, 1)
bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bg.BackgroundTransparency = 0.75
bg.Parent = screen

-- Panel central
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(480, 400)
panel.BackgroundColor3 = Color3.fromRGB(15, 17, 25)
panel.BackgroundTransparency = 0.15
panel.BorderSizePixel = 0
panel.Parent = screen

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel

-- Borde neón
local border = Instance.new("Frame")
border.Name = "Border"
border.Size = UDim2.fromScale(1, 1)
border.BackgroundTransparency = 1
border.BorderSizePixel = 0
border.Parent = panel
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(90, 220, 255)
stroke.Thickness = 2
stroke.Transparency = 0.5
stroke.Parent = border

-- Título
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.fromOffset(400, 40)
title.Position = UDim2.fromOffset(40, 20)
title.BackgroundTransparency = 1
title.Text = "ZERO BREACH"
title.TextColor3 = Color3.fromRGB(90, 220, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 28
title.TextStrokeTransparency = 0.5
title.Parent = panel

-- Subtítulo
local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
title.Size = UDim2.fromOffset(400, 24)
subtitle.Position = UDim2.fromOffset(40, 56)
subtitle.BackgroundTransparency = 1
subtitle.Text = "CONTROLES"
subtitle.TextColor3 = Color3.fromRGB(180, 200, 220)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 16
subtitle.Parent = panel

-- Controles
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
	local row = Instance.new("Frame")
	row.Size = UDim2.fromOffset(440, 32)
	row.Position = UDim2.fromOffset(20, y)
	row.BackgroundTransparency = 1
	row.Parent = panel

	local keyLabel = Instance.new("TextLabel")
	keyLabel.Size = UDim2.fromOffset(160, 30)
	keyLabel.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
	keyLabel.BorderSizePixel = 0
	keyLabel.Text = ctrl.key
	keyLabel.TextColor3 = Color3.fromRGB(90, 220, 255)
	keyLabel.Font = Enum.Font.GothamBold
	keyLabel.TextSize = 15
	keyLabel.Parent = row

	local keyCorner = Instance.new("UICorner")
	keyCorner.CornerRadius = UDim.new(0, 5)
	keyCorner.Parent = keyLabel

	local keyStroke = Instance.new("UIStroke")
	keyStroke.Color = Color3.fromRGB(90, 220, 255)
	keyStroke.Thickness = 1
	keyStroke.Transparency = 0.6
	keyStroke.Parent = keyLabel

	local actionLabel = Instance.new("TextLabel")
	actionLabel.Size = UDim2.fromOffset(260, 30)
	actionLabel.Position = UDim2.fromOffset(175, 0)
	actionLabel.BackgroundTransparency = 1
	actionLabel.Text = ctrl.action
	actionLabel.TextColor3 = Color3.fromRGB(200, 210, 225)
	actionLabel.Font = Enum.Font.Gotham
	actionLabel.TextSize = 14
	actionLabel.TextXAlignment = Enum.TextXAlignment.Left
	actionLabel.Parent = row

	y = y + 38
end

-- Mensaje "presiona cualquier tecla"
local dismiss = Instance.new("TextLabel")
dismiss.Name = "Dismiss"
dismiss.Size = UDim2.fromOffset(400, 24)
dismiss.Position = UDim2.fromOffset(40, y + 10)
dismiss.BackgroundTransparency = 1
dismiss.Text = "Presiona cualquier tecla para continuar..."
dismiss.TextColor3 = Color3.fromRGB(120, 140, 160)
dismiss.Font = Enum.Font.Gotham
dismiss.TextSize = 13
dismiss.Parent = panel

-- Auto-cerrar después de 12 segundos
local closed = false
local function close()
	if closed then return end
	closed = true
	screen:Destroy()
end

task.delay(12, close)

-- Cerrar al presionar cualquier tecla
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not closed then
		close()
	end
end)
