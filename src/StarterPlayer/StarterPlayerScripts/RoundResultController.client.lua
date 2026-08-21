-- Tipo: LocalScript
-- Ubicación: StarterPlayer/StarterPlayerScripts/RoundResultController
-- Contexto: Cliente

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local player = Players.LocalPlayer
local gui = Instance.new('ScreenGui')
gui.Name = 'ZB_RoundResult'
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild('PlayerGui')

local overlay = Instance.new('Frame')
overlay.Name = 'Overlay'
overlay.Size = UDim2.fromScale(1, 1)
overlay.BackgroundColor3 = Color3.fromRGB(5, 8, 12)
overlay.BackgroundTransparency = 0.35
overlay.Visible = false
overlay.Parent = gui

local card = Instance.new('Frame')
card.Name = 'Card'
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Position = UDim2.fromScale(0.5, 0.5)
card.Size = UDim2.fromOffset(420, 180)
card.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
card.BorderSizePixel = 0
card.Parent = overlay
local corner = Instance.new('UICorner')
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = card

local title = Instance.new('TextLabel')
title.Size = UDim2.new(1, -32, 0, 34)
title.Position = UDim2.fromOffset(16, 18)
title.BackgroundTransparency = 1
title.Text = 'RESULTADO'
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 28
title.Parent = card

local body = Instance.new('TextLabel')
body.Size = UDim2.new(1, -32, 0, 50)
body.Position = UDim2.fromOffset(16, 66)
body.BackgroundTransparency = 1
body.Text = ''
body.TextColor3 = Color3.fromRGB(230, 235, 245)
body.Font = Enum.Font.GothamMedium
body.TextSize = 24
body.TextWrapped = true
body.Parent = card

local footer = Instance.new('TextLabel')
footer.Size = UDim2.new(1, -32, 0, 24)
footer.Position = UDim2.fromOffset(16, 132)
footer.BackgroundTransparency = 1
footer.Text = 'La siguiente ronda empezará pronto'
footer.TextColor3 = Color3.fromRGB(150, 165, 180)
footer.Font = Enum.Font.Gotham
footer.TextSize = 16
footer.Parent = card

local matchStateChanged = ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('MatchStateChanged')

matchStateChanged.OnClientEvent:Connect(function(payload)
	if type(payload) ~= 'table' then return end
	if payload.state == 'ENDING' then
		overlay.Visible = true
		if payload.winner == 'Empate' or payload.winner == nil then
			title.Text = 'EMPATE'
			title.TextColor3 = Color3.fromRGB(255, 210, 60)
			body.Text = 'Nadie logró cerrar la ronda con ventaja.'
		elseif payload.winner == 'Partida invalida' then
			title.Text = 'PARTIDA INVALIDA'
			title.TextColor3 = Color3.fromRGB(255, 120, 120)
			body.Text = 'No quedaron suficientes jugadores activos.'
		else
			title.Text = 'VICTORIA'
			title.TextColor3 = Color3.fromRGB(90, 220, 255)
			body.Text = 'Gana el equipo ' .. tostring(payload.winner)
		end
		return
	end
	if payload.state == 'LOBBY' or payload.state == 'COUNTDOWN' or payload.state == 'ACTIVE' or payload.state == 'LOCKED' then
		overlay.Visible = false
	end
end)
