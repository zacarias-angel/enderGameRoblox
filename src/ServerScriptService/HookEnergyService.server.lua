-- Tipo: Script
-- Ubicación: ServerScriptService/HookEnergyService
-- Contexto: Servidor

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Config = require(ReplicatedStorage:WaitForChild('Shared'):WaitForChild('Config'))
local hookEnergyCfg = Config.HookEnergy
local hookUpgradeCfg = Config.HookEnergyUpgrade
local hookRegenCfg = Config.HookRegenUpgrade

local function ensureRemoteFunction(name)
	local folder = ReplicatedStorage:FindFirstChild('RemoteEvents')
	if not folder then
		folder = Instance.new('Folder')
		folder.Name = 'RemoteEvents'
		folder.Parent = ReplicatedStorage
	end
	local remote = folder:FindFirstChild(name)
	if not remote then
		remote = Instance.new('RemoteFunction')
		remote.Name = name
		remote.Parent = folder
	end
	return remote
end

local hookTryConsume = ensureRemoteFunction('HookTryConsume')
local hookDrainTick = ensureRemoteFunction('HookDrainTick')

local hookMax = {}
local hookRegen = {}

local function getMax(player)
	return hookMax[player] or hookEnergyCfg.MAX
end

local function getRegen(player)
	return hookRegen[player] or hookEnergyCfg.REGEN_PER_SEC
end

local HookEnergy = {}

function HookEnergy.get(player)
	local value = player:GetAttribute('HookEnergy')
	if value == nil then
		value = getMax(player)
		player:SetAttribute('HookEnergy', value)
	end
	return value
end

function HookEnergy.getMax(player)
	return getMax(player)
end

function HookEnergy.getRegen(player)
	return getRegen(player)
end

function HookEnergy.setProfile(player, maxValue, regenValue, refillCurrent)
	if not player or not player.Parent then return false end
	local safeMax = math.clamp(math.floor(tonumber(maxValue) or hookEnergyCfg.MAX), hookEnergyCfg.MAX, hookUpgradeCfg.MAX_CAP)
	local safeRegen = math.clamp(math.floor(tonumber(regenValue) or hookEnergyCfg.REGEN_PER_SEC), hookEnergyCfg.REGEN_PER_SEC, hookRegenCfg.MAX_CAP)
	hookMax[player] = safeMax
	hookRegen[player] = safeRegen
	player:SetAttribute('MaxHookEnergy', safeMax)
	player:SetAttribute('HookRegenPerSec', safeRegen)
	local current = player:GetAttribute('HookEnergy')
	if refillCurrent ~= false or current == nil then
		player:SetAttribute('HookEnergy', safeMax)
	else
		player:SetAttribute('HookEnergy', math.clamp(current, 0, safeMax))
	end
	return true
end

function HookEnergy.getProfile(player)
	return {
		maxHookEnergy = getMax(player),
		hookRegenPerSec = getRegen(player),
	}
end

function HookEnergy.trySpend(player, amount)
	if not player or not player.Parent then return false end
	local safeAmount = math.max(0, tonumber(amount) or 0)
	local current = HookEnergy.get(player)
	if current < safeAmount or current < hookEnergyCfg.MIN_TO_USE then
		return false
	end
	player:SetAttribute('HookEnergy', current - safeAmount)
	return true
end

function HookEnergy.drainWhilePulling(player, amount)
	if not player or not player.Parent then return false end
	local safeAmount = math.clamp(tonumber(amount) or 0, 0, hookEnergyCfg.PULL_DRAIN_PER_SEC * 0.5)
	if safeAmount <= 0 then return true end
	local current = HookEnergy.get(player)
	if current <= 0 or current < safeAmount then
		return false
	end
	player:SetAttribute('HookEnergy', current - safeAmount)
	return true
end

function HookEnergy.upgradeMax(player)
	if not player or not player.Parent then return false end
	local currentMax = getMax(player)
	if currentMax >= hookUpgradeCfg.MAX_CAP then return false end
	return HookEnergy.setProfile(player, math.min(hookUpgradeCfg.MAX_CAP, currentMax + hookUpgradeCfg.INCREASE), getRegen(player), true)
end

function HookEnergy.upgradeRegen(player)
	if not player or not player.Parent then return false end
	local currentRegen = getRegen(player)
	if currentRegen >= hookRegenCfg.MAX_CAP then return false end
	return HookEnergy.setProfile(player, getMax(player), math.min(hookRegenCfg.MAX_CAP, currentRegen + hookRegenCfg.INCREASE), false)
end

hookTryConsume.OnServerInvoke = function(player)
	return HookEnergy.trySpend(player, hookEnergyCfg.USE_COST)
end

hookDrainTick.OnServerInvoke = function(player, amount)
	return HookEnergy.drainWhilePulling(player, amount)
end

task.spawn(function()
	while true do
		task.wait(0.1)
		for _, player in ipairs(Players:GetPlayers()) do
			local maxValue = getMax(player)
			local current = player:GetAttribute('HookEnergy')
			if current == nil then
				player:SetAttribute('HookEnergy', maxValue)
			elseif current < maxValue then
				player:SetAttribute('HookEnergy', math.min(maxValue, current + getRegen(player) * 0.1))
			end
		end
	end
end)

Players.PlayerAdded:Connect(function(player)
	HookEnergy.setProfile(player, hookEnergyCfg.MAX, hookEnergyCfg.REGEN_PER_SEC, true)
end)

Players.PlayerRemoving:Connect(function(player)
	hookMax[player] = nil
	hookRegen[player] = nil
end)

_G.ZB = _G.ZB or {}
_G.ZB.HookEnergy = HookEnergy
