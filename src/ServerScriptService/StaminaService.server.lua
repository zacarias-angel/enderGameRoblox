-- Tipo: Script
-- Ubicación: ServerScriptService/StaminaService
-- Contexto: Servidor

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Config = require(ReplicatedStorage:WaitForChild('Shared'):WaitForChild('Config'))
local energyCfg = Config.Energy
local upgradeCfg = Config.StaminaUpgrade

local maxStamina = {}

local function getMax(player)
	return maxStamina[player] or energyCfg.MAX
end

local Stamina = {}

function Stamina.getMax(player)
	return getMax(player)
end

function Stamina.get(player)
	local value = player:GetAttribute('Stamina')
	if value == nil then
		value = getMax(player)
		player:SetAttribute('Stamina', value)
	end
	return value
end

function Stamina.spend(player, amount)
	if not player or not player.Parent then return false end
	local current = Stamina.get(player)
	if current < amount then return false end
	player:SetAttribute('Stamina', current - amount)
	return true
end

function Stamina.setMax(player, amount, refillCurrent)
	if not player or not player.Parent then return false end
	local safeAmount = math.clamp(math.floor(tonumber(amount) or energyCfg.MAX), energyCfg.MAX, upgradeCfg.MAX_CAP)
	maxStamina[player] = safeAmount
	player:SetAttribute('MaxStamina', safeAmount)
	if refillCurrent ~= false then
		player:SetAttribute('Stamina', safeAmount)
	else
		local current = player:GetAttribute('Stamina')
		if current == nil then current = safeAmount end
		player:SetAttribute('Stamina', math.clamp(current, 0, safeAmount))
	end
	return true
end

function Stamina.upgradeMax(player)
	if not player or not player.Parent then return false end
	local current = getMax(player)
	if current >= upgradeCfg.MAX_CAP then return false end
	local newMax = math.min(upgradeCfg.MAX_CAP, current + upgradeCfg.INCREASE)
	return Stamina.setMax(player, newMax, true)
end

task.spawn(function()
	while true do
		task.wait(0.1)
		for _, player in ipairs(Players:GetPlayers()) do
			local mx = getMax(player)
			local current = player:GetAttribute('Stamina')
			if current == nil then
				player:SetAttribute('Stamina', mx)
			elseif current < mx then
				player:SetAttribute('Stamina', math.min(mx, current + energyCfg.REGEN_PER_SEC * 0.1))
			end
		end
	end
end)

Players.PlayerAdded:Connect(function(player)
	maxStamina[player] = energyCfg.MAX
	player:SetAttribute('MaxStamina', energyCfg.MAX)
	player:SetAttribute('Stamina', energyCfg.MAX)
end)

Players.PlayerRemoving:Connect(function(player)
	maxStamina[player] = nil
end)

_G.ZB = _G.ZB or {}
_G.ZB.Stamina = Stamina
