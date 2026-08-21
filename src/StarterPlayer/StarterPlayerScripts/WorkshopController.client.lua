-- Tipo: LocalScript
-- Ubicación: StarterPlayer/StarterPlayerScripts/WorkshopController
-- Contexto: Cliente

local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Config = require(ReplicatedStorage:WaitForChild('Shared'):WaitForChild('Config'))
local modeCfg = Config.GameMode
local staminaCfg = Config.StaminaUpgrade
local hookEnergyUpgradeCfg = Config.HookEnergyUpgrade
local hookRegenUpgradeCfg = Config.HookRegenUpgrade
local workshopCfg = Config.Workshop

local player = Players.LocalPlayer
local playerGui = player:WaitForChild('PlayerGui')
local buyRemote = ReplicatedStorage:WaitForChild('RemoteEvents'):WaitForChild('WorkshopBuy')

local gui = Instance.new('ScreenGui')
gui.Name = 'ZB_Taller'
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local panel = Instance.new('Frame')
panel.Name = 'Panel'
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(430, 430)
panel.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui
local panelCorner = Instance.new('UICorner')
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = panel

local title = Instance.new('TextLabel')
title.Position = UDim2.fromOffset(16, 12)
title.Size = UDim2.new(1, -80, 0, 28)
title.BackgroundTransparency = 1
title.Text = 'TALLER'
title.TextColor3 = Color3.fromRGB(90, 220, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local closeButton = Instance.new('TextButton')
closeButton.Name = 'CloseButton'
closeButton.AnchorPoint = Vector2.new(1, 0)
closeButton.Position = UDim2.new(1, -12, 0, 12)
closeButton.Size = UDim2.fromOffset(28, 28)
closeButton.BackgroundColor3 = Color3.fromRGB(70, 34, 40)
closeButton.BorderSizePixel = 0
closeButton.Text = 'X'
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.Parent = panel
local closeCorner = Instance.new('UICorner')
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

local coinsLabel = Instance.new('TextLabel')
coinsLabel.Position = UDim2.fromOffset(16, 42)
coinsLabel.Size = UDim2.new(1, -32, 0, 20)
coinsLabel.BackgroundTransparency = 1
coinsLabel.Text = 'Monedas: 0'
coinsLabel.TextColor3 = Color3.fromRGB(255, 210, 60)
coinsLabel.Font = Enum.Font.GothamBold
coinsLabel.TextSize = 14
coinsLabel.TextXAlignment = Enum.TextXAlignment.Left
coinsLabel.Parent = panel

local tabBar = Instance.new('Frame')
tabBar.Position = UDim2.fromOffset(12, 72)
tabBar.Size = UDim2.new(1, -24, 0, 34)
tabBar.BackgroundTransparency = 1
tabBar.Parent = panel
local tabLayout = Instance.new('UIListLayout')
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 6)
tabLayout.Parent = tabBar

local content = Instance.new('ScrollingFrame')
content.Position = UDim2.fromOffset(12, 114)
content.Size = UDim2.new(1, -24, 1, -126)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.CanvasSize = UDim2.new()
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = Color3.fromRGB(90, 220, 255)
content.Parent = panel
local contentLayout = Instance.new('UIListLayout')
contentLayout.Padding = UDim.new(0, 6)
contentLayout.Parent = content

local tabs = {
	{ id = 'base', label = 'Base' },
	{ id = 'armas', label = 'Armas' },
	{ id = 'laser', label = 'Laser' },
	{ id = 'gancho', label = 'Gancho' },
}

local currentTab = 'base'
local tabButtons = {}
local open = false

local function inLobby()
	local mode = player:GetAttribute('GameMode') or modeCfg.LOBBY
	return mode == modeCfg.LOBBY
end

local function clearContent()
	for _, child in ipairs(content:GetChildren()) do
		if child:IsA('GuiObject') then
			child:Destroy()
		end
	end
end

local function addHeader(text)
	local label = Instance.new('TextLabel')
	label.Size = UDim2.new(1, -4, 0, 22)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(160, 175, 190)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = content
	return label
end

local function addInfo(text)
	local label = Instance.new('TextLabel')
	label.Size = UDim2.new(1, -4, 0, 18)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(220, 225, 232)
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = content
	return label
end

local function addButton(text, backgroundColor, textColor, callback)
	local btn = Instance.new('TextButton')
	btn.Size = UDim2.new(1, -4, 0, 34)
	btn.BackgroundColor3 = backgroundColor or Color3.fromRGB(40, 46, 58)
	btn.BorderSizePixel = 0
	btn.Text = text
	btn.TextColor3 = textColor or Color3.fromRGB(240, 240, 240)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.Parent = content
	local corner = Instance.new('UICorner')
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn
	btn.Activated:Connect(callback)
	return btn
end

local function coinsValue()
	local stats = player:FindFirstChild('leaderstats')
	local coinsVal = stats and stats:FindFirstChild(Config.Currency.LEADERSTAT)
	return coinsVal and coinsVal.Value or 0
end

local function equippedWeaponId()
	return player:GetAttribute('WeaponId') or Config.Weapons[1].id
end

local function equippedColorId()
	local colorId = player:GetAttribute('LaserColorId')
	return type(colorId) == 'string' and colorId or Config.LaserColors[1].id
end

local function equippedHookTipId()
	local tipId = player:GetAttribute('HookTipCosmeticId')
	return type(tipId) == 'string' and tipId or Config.HookTipCosmetics[1].id
end

local function equippedHookRopeId()
	local ropeId = player:GetAttribute('HookRopeCosmeticId')
	return type(ropeId) == 'string' and ropeId or Config.HookRopeCosmetics[1].id
end

local function renderTabButtons()
	for _, tab in ipairs(tabs) do
		local btn = tabButtons[tab.id]
		if btn then
			local active = tab.id == currentTab
			btn.BackgroundColor3 = active and Color3.fromRGB(50, 90, 70) or Color3.fromRGB(40, 46, 58)
			btn.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(210, 215, 225)
		end
	end
end

local function refresh()
	coinsLabel.Text = 'Monedas: ' .. tostring(coinsValue())
	clearContent()

	if currentTab == 'base' then
		addHeader('ESTADO')
		addInfo('Estamina maxima: ' .. tostring(player:GetAttribute('MaxStamina') or Config.Energy.MAX))
		addInfo('Carga gancho: ' .. tostring(player:GetAttribute('MaxHookEnergy') or Config.HookEnergy.MAX))
		addInfo('Regen gancho: ' .. tostring(player:GetAttribute('HookRegenPerSec') or Config.HookEnergy.REGEN_PER_SEC) .. '/s')
		addButton('+20 estamina (' .. tostring(staminaCfg.COST_PER_TIER) .. 'c)', nil, nil, function()
			buyRemote:FireServer('stamina', nil)
		end)
		addButton('+20 carga gancho (' .. tostring(hookEnergyUpgradeCfg.COST_PER_TIER) .. 'c)', nil, nil, function()
			buyRemote:FireServer('hookEnergy', nil)
		end)
		addButton('+regen gancho (' .. tostring(hookRegenUpgradeCfg.COST_PER_TIER) .. 'c)', nil, nil, function()
			buyRemote:FireServer('hookRegen', nil)
		end)
	elseif currentTab == 'armas' then
		addHeader('ARMAS')
		local current = equippedWeaponId()
		for _, weapon in ipairs(Config.Weapons) do
			local active = weapon.id == current
			addButton(
				weapon.name .. (active and '  (Equipada)' or '  (' .. tostring(weapon.cost) .. 'c)'),
				active and Color3.fromRGB(50, 90, 70) or Color3.fromRGB(40, 46, 58),
				nil,
				function() buyRemote:FireServer('weapon', weapon.id) end
			)
		end
	elseif currentTab == 'laser' then
		addHeader('COLOR DEL LASER')
		local current = equippedColorId()
		for _, entry in ipairs(Config.LaserColors) do
			addButton(
				entry.name .. (entry.id == current and '  (Equipado)' or '  (' .. tostring(entry.cost) .. 'c)'),
				entry.color,
				Color3.fromRGB(20, 20, 20),
				function() buyRemote:FireServer('color', entry.id) end
			)
		end
	elseif currentTab == 'gancho' then
		addHeader('PUNTA DEL GANCHO')
		local currentTip = equippedHookTipId()
		for _, entry in ipairs(Config.HookTipCosmetics) do
			addButton(
				entry.name .. (entry.id == currentTip and '  (Equipada)' or '  (' .. tostring(entry.cost) .. 'c)'),
				entry.id == currentTip and Color3.fromRGB(50, 90, 70) or Color3.fromRGB(40, 46, 58),
				entry.color,
				function() buyRemote:FireServer('hookTip', entry.id) end
			)
		end
		addHeader('CUERDA DEL GANCHO')
		local currentRope = equippedHookRopeId()
		for _, entry in ipairs(Config.HookRopeCosmetics) do
			addButton(
				entry.name .. (entry.id == currentRope and '  (Equipada)' or '  (' .. tostring(entry.cost) .. 'c)'),
				entry.color,
				Color3.fromRGB(20, 20, 20),
				function() buyRemote:FireServer('hookRope', entry.id) end
			)
		end
	end

	renderTabButtons()
end

local function setOpen(value)
	open = value
	panel.Visible = value
	if value then
		refresh()
	end
end

for _, tab in ipairs(tabs) do
	local btn = Instance.new('TextButton')
	btn.Name = tab.id
	btn.Size = UDim2.fromOffset(94, 34)
	btn.BackgroundColor3 = Color3.fromRGB(40, 46, 58)
	btn.BorderSizePixel = 0
	btn.Text = tab.label
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	btn.TextColor3 = Color3.fromRGB(210, 215, 225)
	btn.Parent = tabBar
	local corner = Instance.new('UICorner')
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn
	btn.Activated:Connect(function()
		currentTab = tab.id
		refresh()
	end)
	tabButtons[tab.id] = btn
end
renderTabButtons()

closeButton.Activated:Connect(function()
	setOpen(false)
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.Escape and open then
		setOpen(false)
	end
end)

local PROMPT_NAME = 'ZB_TallerPrompt'
local function setupTaller(part)
	if part:FindFirstChild(PROMPT_NAME) then return end
	local prompt = Instance.new('ProximityPrompt')
	prompt.Name = PROMPT_NAME
	prompt.ActionText = workshopCfg.PROMPT_ACTION
	prompt.ObjectText = workshopCfg.PROMPT_OBJECT
	prompt.KeyboardKeyCode = workshopCfg.KEY
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = workshopCfg.MAX_DISTANCE
	prompt.RequiresLineOfSight = false
	prompt.Parent = part
	prompt.Triggered:Connect(function()
		if inLobby() then
			setOpen(true)
		end
	end)
end

for _, inst in ipairs(workspace:GetDescendants()) do
	if inst:IsA('BasePart') and inst:GetAttribute(workshopCfg.ATTRIBUTE) then
		setupTaller(inst)
	end
end
workspace.DescendantAdded:Connect(function(inst)
	if inst:IsA('BasePart') and inst:GetAttribute(workshopCfg.ATTRIBUTE) then
		setupTaller(inst)
	end
end)

local refreshTimer = 0
RunService.RenderStepped:Connect(function(dt)
	if not inLobby() and open then
		setOpen(false)
	end
	if open then
		refreshTimer += dt
		if refreshTimer >= 0.3 then
			refreshTimer = 0
			refresh()
		end
	end
end)
