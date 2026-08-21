-- Tipo: LocalScript
-- Ubicación: StarterPlayer/StarterPlayerScripts/DailyRewardController
-- Contexto: Cliente

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local player = Players.LocalPlayer
local playerGui = player:WaitForChild('PlayerGui')
local remotes = ReplicatedStorage:WaitForChild('RemoteEvents')
local claimDailyReward = remotes:WaitForChild('ClaimDailyReward')
local dailyRewardState = remotes:WaitForChild('DailyRewardState')

local screenGui = Instance.new('ScreenGui')
screenGui.Name = 'ZB_DailyReward'
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local panel = Instance.new('Frame')
panel.Name = 'DailyPanel'
panel.AnchorPoint = Vector2.new(0, 0)
panel.Position = UDim2.fromOffset(24, 64)
panel.Size = UDim2.fromOffset(250, 110)
panel.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
panel.BackgroundTransparency = 0.15
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = screenGui
local panelCorner = Instance.new('UICorner')
panelCorner.CornerRadius = UDim.new(0, 10)
panelCorner.Parent = panel

local title = Instance.new('TextLabel')
title.Name = 'Title'
title.Position = UDim2.fromOffset(12, 10)
title.Size = UDim2.new(1, -24, 0, 22)
title.BackgroundTransparency = 1
title.Text = 'Recompensa diaria'
title.TextColor3 = Color3.fromRGB(255, 210, 60)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local subtitle = Instance.new('TextLabel')
subtitle.Name = 'Subtitle'
subtitle.Position = UDim2.fromOffset(12, 34)
subtitle.Size = UDim2.new(1, -24, 0, 18)
subtitle.BackgroundTransparency = 1
subtitle.Text = 'Dia 1/7'
subtitle.TextColor3 = Color3.fromRGB(230, 235, 245)
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextSize = 13
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = panel

local info = Instance.new('TextLabel')
info.Name = 'Info'
info.Position = UDim2.fromOffset(12, 54)
info.Size = UDim2.new(1, -24, 0, 20)
info.BackgroundTransparency = 1
info.Text = 'Reclama tu bono de hoy'
info.TextColor3 = Color3.fromRGB(160, 210, 255)
info.Font = Enum.Font.Gotham
info.TextSize = 13
info.TextXAlignment = Enum.TextXAlignment.Left
info.Parent = panel

local claimButton = Instance.new('TextButton')
claimButton.Name = 'ClaimButton'
claimButton.Position = UDim2.fromOffset(12, 80)
claimButton.Size = UDim2.new(1, -24, 0, 22)
claimButton.BackgroundColor3 = Color3.fromRGB(255, 210, 60)
claimButton.BorderSizePixel = 0
claimButton.Text = 'Reclamar'
claimButton.TextColor3 = Color3.fromRGB(20, 24, 34)
claimButton.Font = Enum.Font.GothamBold
claimButton.TextSize = 13
claimButton.Parent = panel
local buttonCorner = Instance.new('UICorner')
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = claimButton

local currentState = nil

local function inBattle()
	local mode = player:GetAttribute('GameMode')
	return mode == 'BATTLE' or mode == 'DUEL'
end

local function refreshUi()
	if not currentState then
		panel.Visible = false
		return
	end
	panel.Visible = not inBattle()
	subtitle.Text = 'Dia ' .. tostring(currentState.nextStreak or 1) .. '/' .. tostring(currentState.maxStreak or 7)
	if currentState.available then
		info.Text = 'Disponible: +' .. tostring(currentState.reward or 0) .. ' monedas'
		claimButton.Text = 'Reclamar +' .. tostring(currentState.reward or 0)
		claimButton.BackgroundColor3 = Color3.fromRGB(255, 210, 60)
		claimButton.TextColor3 = Color3.fromRGB(20, 24, 34)
		claimButton.Active = true
		claimButton.AutoButtonColor = true
	else
		info.Text = currentState.message or 'Ya reclamaste la recompensa de hoy'
		claimButton.Text = 'Reclamada'
		claimButton.BackgroundColor3 = Color3.fromRGB(60, 70, 85)
		claimButton.TextColor3 = Color3.fromRGB(220, 225, 235)
		claimButton.Active = false
		claimButton.AutoButtonColor = false
	end
end

dailyRewardState.OnClientEvent:Connect(function(payload)
	if type(payload) ~= 'table' then return end
	currentState = payload
	refreshUi()
end)

claimButton.MouseButton1Click:Connect(function()
	if currentState and currentState.available then
		claimDailyReward:FireServer()
	end
end)

player:GetAttributeChangedSignal('GameMode'):Connect(refreshUi)
refreshUi()
