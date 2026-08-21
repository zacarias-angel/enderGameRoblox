-- Tipo: LocalScript
-- Ubicación: StarterPlayer/StarterPlayerScripts/MissionController
-- Contexto: Cliente

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild('RemoteEvents')
local missionState = remotes:WaitForChild('MissionState')
local claimMissionReward = remotes:WaitForChild('ClaimMissionReward')

local gui = Instance.new('ScreenGui')
gui.Name = 'ZB_Missions'
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild('PlayerGui')

local panel = Instance.new('Frame')
panel.Name = 'MissionPanel'
panel.AnchorPoint = Vector2.new(0, 0)
panel.Position = UDim2.fromOffset(24, 184)
panel.Size = UDim2.fromOffset(250, 150)
panel.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
panel.BackgroundTransparency = 0.15
panel.BorderSizePixel = 0
panel.Visible = true
panel.Parent = gui
local corner = Instance.new('UICorner')
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = panel

local title = Instance.new('TextLabel')
title.Position = UDim2.fromOffset(12, 10)
title.Size = UDim2.new(1, -24, 0, 22)
title.BackgroundTransparency = 1
title.Text = 'Misiones diarias'
title.TextColor3 = Color3.fromRGB(120, 255, 180)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local list = Instance.new('Frame')
list.Position = UDim2.fromOffset(12, 38)
list.Size = UDim2.new(1, -24, 1, -50)
list.BackgroundTransparency = 1
list.Parent = panel
local layout = Instance.new('UIListLayout')
layout.FillDirection = Enum.FillDirection.Vertical
layout.Padding = UDim.new(0, 6)
layout.Parent = list

local rows = {}
local stateCache = nil

local function inBattle()
	local mode = player:GetAttribute('GameMode')
	return mode == 'BATTLE' or mode == 'DUEL'
end

local function ensureRow(index)
	if rows[index] then return rows[index] end
	local row = Instance.new('Frame')
	row.Size = UDim2.new(1, 0, 0, 30)
	row.BackgroundColor3 = Color3.fromRGB(28, 34, 46)
	row.BackgroundTransparency = 0.1
	row.BorderSizePixel = 0
	row.Parent = list
	local rowCorner = Instance.new('UICorner')
	rowCorner.CornerRadius = UDim.new(0, 8)
	rowCorner.Parent = row
	local label = Instance.new('TextLabel')
	label.Name = 'Label'
	label.Position = UDim2.fromOffset(8, 0)
	label.Size = UDim2.new(1, -82, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(230, 235, 245)
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row
	local button = Instance.new('TextButton')
	button.Name = 'Claim'
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.new(1, -6, 0.5, 0)
	button.Size = UDim2.fromOffset(66, 22)
	button.BackgroundColor3 = Color3.fromRGB(255, 210, 60)
	button.BorderSizePixel = 0
	button.Text = 'Cobrar'
	button.TextColor3 = Color3.fromRGB(20, 24, 34)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 11
	button.Parent = row
	local buttonCorner = Instance.new('UICorner')
	buttonCorner.CornerRadius = UDim.new(0, 6)
	buttonCorner.Parent = button
	button.Activated:Connect(function()
		if stateCache and stateCache.entries and stateCache.entries[index] then
			claimMissionReward:FireServer(stateCache.entries[index].id)
		end
	end)
	rows[index] = row
	return row
end

local function refresh()
	panel.Visible = not inBattle()
	if not stateCache or type(stateCache.entries) ~= 'table' then return end
	for i, entry in ipairs(stateCache.entries) do
		local row = ensureRow(i)
		local label = row.Label
		local button = row.Claim
		label.Text = entry.title .. '  ' .. tostring(entry.progress) .. '/' .. tostring(entry.target)
		if entry.claimed then
			button.Text = 'Hecha'
			button.Active = false
			button.AutoButtonColor = false
			button.BackgroundColor3 = Color3.fromRGB(60, 70, 85)
		elseif entry.complete then
			button.Text = '+' .. tostring(entry.reward)
			button.Active = true
			button.AutoButtonColor = true
			button.BackgroundColor3 = Color3.fromRGB(255, 210, 60)
		else
			button.Text = tostring(entry.reward) .. 'c'
			button.Active = false
			button.AutoButtonColor = false
			button.BackgroundColor3 = Color3.fromRGB(50, 60, 75)
		end
	end
end

missionState.OnClientEvent:Connect(function(payload)
	if type(payload) ~= 'table' then return end
	stateCache = payload
	refresh()
end)

player:GetAttributeChangedSignal('GameMode'):Connect(refresh)
refresh()
