-- Tipo: LocalScript
-- Ubicación: StarterPlayer/StarterPlayerScripts/LoadingScreen
-- Contexto: Cliente

--[[
	LoadingScreen
	Pantalla de carga (intro) que se muestra al entrar al juego: título
	"ZERO BREACH" + "Cargando..." animado. Desaparece con un fade una vez
	que el personaje termina de cargar (con un tiempo mínimo de 2.5s).
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "ZB_Loading"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 10
gui.Parent = playerGui

local container = Instance.new("CanvasGroup")
container.Size = UDim2.fromScale(1, 1)
container.BackgroundColor3 = Color3.fromRGB(8, 10, 16)
container.BorderSizePixel = 0
container.Parent = gui

local title = Instance.new("TextLabel")
title.AnchorPoint = Vector2.new(0.5, 0.5)
title.Position = UDim2.new(0.5, 0, 0.42, 0)
title.Size = UDim2.new(1, 0, 0, 70)
title.BackgroundTransparency = 1
title.Text = "ZERO BREACH"
title.TextColor3 = Color3.fromRGB(90, 220, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 54
title.Parent = container

local subtitle = Instance.new("TextLabel")
subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
subtitle.Position = UDim2.new(0.5, 0, 0.48, 0)
subtitle.Size = UDim2.new(1, 0, 0, 28)
subtitle.BackgroundTransparency = 1
subtitle.Text = "GRAVEDAD CERO"
subtitle.TextColor3 = Color3.fromRGB(160, 175, 190)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 18
subtitle.Parent = container

local loading = Instance.new("TextLabel")
loading.AnchorPoint = Vector2.new(0.5, 0.5)
loading.Position = UDim2.new(0.5, 0, 0.6, 0)
loading.Size = UDim2.new(1, 0, 0, 30)
loading.BackgroundTransparency = 1
loading.Text = "Cargando"
loading.TextColor3 = Color3.fromRGB(200, 210, 220)
loading.Font = Enum.Font.Gotham
loading.TextSize = 16
loading.Parent = container

-- Puntos animados de "Cargando".
local dotsConn = RunService.RenderStepped:Connect(function()
	if not loading.Parent then return end
	local dots = math.floor((os.clock() * 2) % 4)
	loading.Text = "Cargando" .. string.rep(".", dots)
end)

-- Esperar a que cargue el personaje (mínimo 2.5s) y luego fundir.
local charLoaded = player.Character ~= nil
player.CharacterAdded:Connect(function()
	charLoaded = true
end)

task.spawn(function()
	local start = os.clock()
	while true do
		task.wait(0.1)
		local elapsed = os.clock() - start
		if charLoaded and elapsed >= 2.5 then break end
		if elapsed >= 10 then break end
	end

	dotsConn:Disconnect()

	-- Mostrar la pantalla de controles (ZB_Intro) después de la carga.
	local intro = playerGui:FindFirstChild("ZB_Intro")
	if intro then
		intro.Enabled = true
	end

	local tween = TweenService:Create(container, TweenInfo.new(0.7), { GroupTransparency = 1 })
	tween:Play()
	tween.Completed:Wait()
	gui:Destroy()
end)
