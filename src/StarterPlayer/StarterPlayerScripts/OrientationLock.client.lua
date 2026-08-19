-- Tipo: LocalScript
-- Ubicación: StarterPlayer/StarterPlayerScripts/OrientationLock
-- Contexto: Cliente

--[[
	OrientationLock
	Obliga a jugar en horizontal (landscape). Si la pantalla está en vertical
	(portrait), muestra una superposición a pantalla completa pidiendo girar
	el dispositivo, bloqueando la vista del juego hasta que se gira.
]]

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "ZB_Rotate"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 100
gui.Parent = playerGui

local bg = Instance.new("Frame")
bg.Size = UDim2.fromScale(1, 1)
bg.BackgroundColor3 = Color3.fromRGB(8, 10, 16)
bg.BorderSizePixel = 0
bg.Parent = gui

-- Icono de teléfono girado (rectángulo redondeado rotado 90°).
local icon = Instance.new("Frame")
icon.AnchorPoint = Vector2.new(0.5, 0.5)
icon.Position = UDim2.new(0.5, 0, 0.44, 0)
icon.Size = UDim2.fromOffset(90, 140)
icon.BackgroundColor3 = Color3.fromRGB(30, 36, 48)
icon.BorderSizePixel = 0
icon.Rotation = 90
icon.Parent = bg
local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(0, 16)
iconCorner.Parent = icon
local iconStroke = Instance.new("UIStroke")
iconStroke.Color = Color3.fromRGB(90, 220, 255)
iconStroke.Thickness = 2
iconStroke.Parent = icon
local iconScreen = Instance.new("Frame")
iconScreen.AnchorPoint = Vector2.new(0.5, 0.5)
iconScreen.Position = UDim2.new(0.5, 0, 0.5, 0)
iconScreen.Size = UDim2.fromScale(0.7, 0.8)
iconScreen.BackgroundColor3 = Color3.fromRGB(90, 220, 255)
iconScreen.BackgroundTransparency = 0.8
iconScreen.BorderSizePixel = 0
iconScreen.Parent = icon

local text = Instance.new("TextLabel")
text.AnchorPoint = Vector2.new(0.5, 0.5)
text.Position = UDim2.new(0.5, 0, 0.56, 0)
text.Size = UDim2.new(1, -40, 0, 50)
text.BackgroundTransparency = 1
text.Text = "Gira tu dispositivo para jugar"
text.TextColor3 = Color3.fromRGB(240, 240, 240)
text.Font = Enum.Font.GothamBold
text.TextSize = 26
text.TextWrapped = true
text.Parent = bg

local sub = Instance.new("TextLabel")
sub.AnchorPoint = Vector2.new(0.5, 0.5)
sub.Position = UDim2.new(0.5, 0, 0.62, 0)
sub.Size = UDim2.new(1, -40, 0, 30)
sub.BackgroundTransparency = 1
sub.Text = "Este juego solo se juega en horizontal"
sub.TextColor3 = Color3.fromRGB(160, 175, 190)
sub.Font = Enum.Font.Gotham
sub.TextSize = 16
sub.Parent = bg

gui.Enabled = false

RunService.RenderStepped:Connect(function()
	local cam = workspace.CurrentCamera
	if not cam then return end
	local vs = cam.ViewportSize
	gui.Enabled = vs.X < vs.Y
end)
