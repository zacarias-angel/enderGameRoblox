-- Tipo: Script
-- Ubicación: ServerScriptService/WorkshopService
-- Contexto: Servidor

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Config = require(ReplicatedStorage:WaitForChild('Shared'):WaitForChild('Config'))
local staminaCfg = Config.StaminaUpgrade
local hookEnergyUpgradeCfg = Config.HookEnergyUpgrade
local hookRegenUpgradeCfg = Config.HookRegenUpgrade

local function ensureRemote(name)
	local folder = ReplicatedStorage:FindFirstChild('RemoteEvents')
	if not folder then
		folder = Instance.new('Folder')
		folder.Name = 'RemoteEvents'
		folder.Parent = ReplicatedStorage
	end
	local remote = folder:FindFirstChild(name)
	if not remote then
		remote = Instance.new('RemoteEvent')
		remote.Name = name
		remote.Parent = folder
	end
	return remote
end

local buyRemote = ensureRemote('WorkshopBuy')

local ownedWeapons = {}
local ownedColors = {}
local ownedHookTips = {}
local ownedHookRopes = {}

local function getDefaultWeapon()
	return Config.Weapons[1]
end

local function getDefaultColor()
	return Config.LaserColors[1]
end

local function getDefaultHookTip()
	return Config.HookTipCosmetics[1]
end

local function getDefaultHookRope()
	return Config.HookRopeCosmetics[1]
end

local function ensureDefaultOwnership(player)
	ownedWeapons[player] = ownedWeapons[player] or {}
	ownedColors[player] = ownedColors[player] or {}
	local weapon = getDefaultWeapon()
	local color = getDefaultColor()
	if weapon then
		ownedWeapons[player][weapon.id] = true
		if player:GetAttribute('WeaponId') == nil then
			player:SetAttribute('WeaponId', weapon.id)
		end
	end
	if color then
		ownedColors[player][color.id] = true
		if player:GetAttribute('LaserColorId') == nil then
			player:SetAttribute('LaserColorId', color.id)
		end
		if player:GetAttribute('LaserColor') == nil then
			player:SetAttribute('LaserColor', color.color)
		end
	end
	ownedHookTips[player] = ownedHookTips[player] or {}
	ownedHookRopes[player] = ownedHookRopes[player] or {}
	local hookTip = getDefaultHookTip()
	local hookRope = getDefaultHookRope()
	if hookTip then
		ownedHookTips[player][hookTip.id] = true
		if player:GetAttribute('HookTipCosmeticId') == nil then
			player:SetAttribute('HookTipCosmeticId', hookTip.id)
		end
	end
	if hookRope then
		ownedHookRopes[player][hookRope.id] = true
		if player:GetAttribute('HookRopeCosmeticId') == nil then
			player:SetAttribute('HookRopeCosmeticId', hookRope.id)
		end
	end
end

local function findWeaponById(id)
	for _, w in ipairs(Config.Weapons) do
		if w.id == id then return w end
	end
	return nil
end

local function findColorById(id)
	for _, c in ipairs(Config.LaserColors) do
		if c.id == id then return c end
	end
	return nil
end

local function findHookTipById(id)
	for _, item in ipairs(Config.HookTipCosmetics) do
		if item.id == id then return item end
	end
	return nil
end

local function findHookRopeById(id)
	for _, item in ipairs(Config.HookRopeCosmetics) do
		if item.id == id then return item end
	end
	return nil
end

local function getCurrency()
	return _G.ZB and _G.ZB.CurrencyService
end

local function getStamina()
	return _G.ZB and _G.ZB.Stamina
end

local function canUseWorkshop(player)
	if _G.ZB and _G.ZB.GameMode then
		return not _G.ZB.GameMode.isZeroG()
	end
	return true
end

local function buyWeapon(player, id)
	local weapon = findWeaponById(id)
	if not weapon then return end
	ensureDefaultOwnership(player)
	if not ownedWeapons[player][id] then
		local currency = getCurrency()
		if weapon.cost > 0 then
			if not currency or not currency.spendCoins(player, weapon.cost) then return end
		end
		ownedWeapons[player][id] = true
	end
	player:SetAttribute('WeaponId', weapon.id)
end

local function buyColor(player, id)
	local entry = findColorById(id)
	if not entry then return end
	ensureDefaultOwnership(player)
	if not ownedColors[player][id] then
		local currency = getCurrency()
		if entry.cost > 0 then
			if not currency or not currency.spendCoins(player, entry.cost) then return end
		end
		ownedColors[player][id] = true
	end
	player:SetAttribute('LaserColor', entry.color)
	player:SetAttribute('LaserColorId', entry.id)
end

local function buyHookTip(player, id)
	local entry = findHookTipById(id)
	if not entry then return end
	ensureDefaultOwnership(player)
	if not ownedHookTips[player][id] then
		local currency = getCurrency()
		if entry.cost > 0 then
			if not currency or not currency.spendCoins(player, entry.cost) then return end
		end
		ownedHookTips[player][id] = true
	end
	player:SetAttribute('HookTipCosmeticId', entry.id)
end

local function buyHookRope(player, id)
	local entry = findHookRopeById(id)
	if not entry then return end
	ensureDefaultOwnership(player)
	if not ownedHookRopes[player][id] then
		local currency = getCurrency()
		if entry.cost > 0 then
			if not currency or not currency.spendCoins(player, entry.cost) then return end
		end
		ownedHookRopes[player][id] = true
	end
	player:SetAttribute('HookRopeCosmeticId', entry.id)
end

local function buyStamina(player)
	local currency = getCurrency()
	local stamina = getStamina()
	if not currency or not stamina then return end
	if not currency.spendCoins(player, staminaCfg.COST_PER_TIER) then return end
	stamina.upgradeMax(player)
end

local function buyHookEnergy(player)
	local currency = getCurrency()
	local hookEnergy = _G.ZB and _G.ZB.HookEnergy
	if not currency or not hookEnergy then return end
	if not currency.spendCoins(player, hookEnergyUpgradeCfg.COST_PER_TIER) then return end
	hookEnergy.upgradeMax(player)
end

local function buyHookRegen(player)
	local currency = getCurrency()
	local hookEnergy = _G.ZB and _G.ZB.HookEnergy
	if not currency or not hookEnergy then return end
	if not currency.spendCoins(player, hookRegenUpgradeCfg.COST_PER_TIER) then return end
	hookEnergy.upgradeRegen(player)
end

local WorkshopService = {}

function WorkshopService.getProfile(player)
	ensureDefaultOwnership(player)
	local weaponIds = {}
	for weaponId, owned in pairs(ownedWeapons[player]) do
		if owned then table.insert(weaponIds, weaponId) end
	end
	table.sort(weaponIds)
	local colorIds = {}
	for colorId, owned in pairs(ownedColors[player]) do
		if owned then table.insert(colorIds, colorId) end
	end
	table.sort(colorIds)
	return {
		ownedWeapons = weaponIds,
		ownedColors = colorIds,
		ownedHookTips = (function() local ids = {} for id, owned in pairs(ownedHookTips[player]) do if owned then table.insert(ids, id) end end table.sort(ids) return ids end)(),
		ownedHookRopes = (function() local ids = {} for id, owned in pairs(ownedHookRopes[player]) do if owned then table.insert(ids, id) end end table.sort(ids) return ids end)(),
		equippedWeaponId = player:GetAttribute('WeaponId') or (getDefaultWeapon() and getDefaultWeapon().id),
		equippedLaserColorId = player:GetAttribute('LaserColorId') or (getDefaultColor() and getDefaultColor().id),
		equippedHookTipId = player:GetAttribute('HookTipCosmeticId') or (getDefaultHookTip() and getDefaultHookTip().id),
		equippedHookRopeId = player:GetAttribute('HookRopeCosmeticId') or (getDefaultHookRope() and getDefaultHookRope().id),
	}
end

function WorkshopService.applyProfile(player, profile)
	ownedWeapons[player] = {}
	ownedColors[player] = {}
	ownedHookTips[player] = {}
	ownedHookRopes[player] = {}
	if type(profile) == 'table' then
		for _, weaponId in ipairs(profile.ownedWeapons or {}) do
			ownedWeapons[player][weaponId] = true
		end
		for _, colorId in ipairs(profile.ownedColors or {}) do
			ownedColors[player][colorId] = true
		end
		for _, hookTipId in ipairs(profile.ownedHookTips or {}) do
			ownedHookTips[player][hookTipId] = true
		end
		for _, hookRopeId in ipairs(profile.ownedHookRopes or {}) do
			ownedHookRopes[player][hookRopeId] = true
		end
	end
	ensureDefaultOwnership(player)
	local equippedWeapon = findWeaponById(type(profile) == 'table' and profile.equippedWeaponId or nil) or getDefaultWeapon()
	local equippedColor = findColorById(type(profile) == 'table' and profile.equippedLaserColorId or nil) or getDefaultColor()
	local equippedHookTip = findHookTipById(type(profile) == 'table' and profile.equippedHookTipId or nil) or getDefaultHookTip()
	local equippedHookRope = findHookRopeById(type(profile) == 'table' and profile.equippedHookRopeId or nil) or getDefaultHookRope()
	if equippedWeapon then
		ownedWeapons[player][equippedWeapon.id] = true
		player:SetAttribute('WeaponId', equippedWeapon.id)
	end
	if equippedColor then
		ownedColors[player][equippedColor.id] = true
		player:SetAttribute('LaserColorId', equippedColor.id)
		player:SetAttribute('LaserColor', equippedColor.color)
	end
	if equippedHookTip then
		ownedHookTips[player][equippedHookTip.id] = true
		player:SetAttribute('HookTipCosmeticId', equippedHookTip.id)
	end
	if equippedHookRope then
		ownedHookRopes[player][equippedHookRope.id] = true
		player:SetAttribute('HookRopeCosmeticId', equippedHookRope.id)
	end
end

buyRemote.OnServerEvent:Connect(function(player, purchaseType, id)
	if not player or not player.Parent then return end
	if not canUseWorkshop(player) then return end
	if purchaseType == 'weapon' then
		buyWeapon(player, id)
	elseif purchaseType == 'color' then
		buyColor(player, id)
	elseif purchaseType == 'stamina' then
		buyStamina(player)
	elseif purchaseType == 'hookEnergy' then
		buyHookEnergy(player)
	elseif purchaseType == 'hookRegen' then
		buyHookRegen(player)
	elseif purchaseType == 'hookTip' then
		buyHookTip(player, id)
	elseif purchaseType == 'hookRope' then
		buyHookRope(player, id)
	end
end)

Players.PlayerAdded:Connect(function(player)
	ensureDefaultOwnership(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
	ensureDefaultOwnership(player)
end

Players.PlayerRemoving:Connect(function(player)
	ownedWeapons[player] = nil
	ownedColors[player] = nil
	ownedHookTips[player] = nil
	ownedHookRopes[player] = nil
end)

_G.ZB = _G.ZB or {}
WorkshopService.canUseWorkshop = canUseWorkshop
_G.ZB.Workshop = WorkshopService
