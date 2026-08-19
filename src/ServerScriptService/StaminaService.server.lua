-- Tipo: Script
-- Ubicación: ServerScriptService/StaminaService
-- Contexto: Servidor

--[[
	StaminaService
	Fuente de verdad de la estamina de cada jugador (recurso que se gasta al
	disparar, como si fuese resistencia). La estamina se replica al cliente
	mediante el atributo "Stamina" y la máxima mediante "MaxStamina".

	- Regenera con el tiempo (Config.Energy.REGEN_PER_SEC).
	- Se gasta al disparar (ShootingService llama a Stamina.spend).
	- La máxima puede subirse en el taller (Stamina.upgradeMax).

	Expone API: _G.ZB.Stamina.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local energyCfg = Config.Energy
local upgradeCfg = Config.StaminaUpgrade

local maxStamina = {}  -- [player] = estamina máxima actual

local function getMax(player)
	-- Propósito: Estamina máxima actual del jugador (con mejoras).
	-- Precondiciones:
	--   1. player es un Player válido.
	-- Ubicación: ServerScriptService/StaminaService
	-- Retorna: number
	return maxStamina[player] or energyCfg.MAX
end

local Stamina = {}

function Stamina.getMax(player)
	-- Propósito: Exponer la estamina máxima de un jugador.
	-- Precondiciones: 1. player válido.
	-- Ubicación: ServerScriptService/StaminaService
	-- Retorna: number
	return getMax(player)
end

function Stamina.get(player)
	-- Propósito: Obtener la estamina actual (creándola si falta).
	-- Precondiciones: 1. player válido.
	-- Ubicación: ServerScriptService/StaminaService
	-- Retorna: number
	local value = player:GetAttribute("Stamina")
	if value == nil then
		value = getMax(player)
		player:SetAttribute("Stamina", value)
	end
	return value
end

function Stamina.spend(player, amount)
	-- Propósito: Gastar estamina si alcanza. Devuelve false si no hay suficiente.
	-- Precondiciones:
	--   1. player válido; amount > 0.
	-- Ubicación: ServerScriptService/StaminaService
	-- Retorna: boolean
	if not player or not player.Parent then return false end
	local current = Stamina.get(player)
	if current < amount then return false end
	player:SetAttribute("Stamina", current - amount)
	return true
end

function Stamina.upgradeMax(player)
	-- Propósito: Subir la estamina máxima (compra del taller). Recarga al tope.
	-- Precondiciones:
	--   1. player válido y no alcanzó el límite.
	-- Ubicación: ServerScriptService/StaminaService
	-- Retorna: boolean (true si se aplicó)
	if not player or not player.Parent then return false end
	local current = getMax(player)
	if current >= upgradeCfg.MAX_CAP then return false end

	local newMax = math.min(upgradeCfg.MAX_CAP, current + upgradeCfg.INCREASE)
	maxStamina[player] = newMax
	player:SetAttribute("MaxStamina", newMax)
	player:SetAttribute("Stamina", newMax)
	return true
end

-- Bucle de regeneración.
task.spawn(function()
	while true do
		task.wait(0.1)
		for _, player in ipairs(Players:GetPlayers()) do
			local mx = getMax(player)
			local current = player:GetAttribute("Stamina")
			if current == nil then
				player:SetAttribute("Stamina", mx)
			elseif current < mx then
				player:SetAttribute("Stamina", math.min(mx, current + energyCfg.REGEN_PER_SEC * 0.1))
			end
		end
	end
end)

Players.PlayerAdded:Connect(function(player)
	maxStamina[player] = energyCfg.MAX
	player:SetAttribute("MaxStamina", energyCfg.MAX)
	player:SetAttribute("Stamina", energyCfg.MAX)
end)

Players.PlayerRemoving:Connect(function(player)
	maxStamina[player] = nil
end)

_G.ZB = _G.ZB or {}
_G.ZB.Stamina = Stamina
