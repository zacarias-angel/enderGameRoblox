-- Tipo: Script
-- Ubicación: ServerScriptService/WorkshopService
-- Contexto: Servidor

--[[
	WorkshopService
	"Taller" donde el jugador gasta monedas para:
	- Equipar un arma (Config.Weapons).
	- Cambiar el color del láser (Config.LaserColors).
	- Subir la estamina máxima (Config.StaminaUpgrade).

	Recibe peticiones del cliente por el RemoteEvent "WorkshopBuy" con
	{ type, id }. Solo funciona en LOBBY (fuera de partida).

	El estado se replica al cliente vía atributos:
	- WeaponId   (string)
	- LaserColor (Color3)
	- MaxStamina (number, lo maneja StaminaService)

	Expone API: _G.ZB.Workshop.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local staminaCfg = Config.StaminaUpgrade

local function ensureRemote(name)
	-- Propósito: Obtener/crear un RemoteEvent en ReplicatedStorage/RemoteEvents.
	-- Precondiciones:
	--   1. name es un string no vacío.
	-- Ubicación: ServerScriptService/WorkshopService
	-- Retorna: RemoteEvent
	local folder = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "RemoteEvents"
		folder.Parent = ReplicatedStorage
	end
	local remote = folder:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
	end
	return remote
end

local buyRemote = ensureRemote("WorkshopBuy")

-- Propiedad por sesión (no se repite el pago por item).
local ownedWeapons = {}  -- [player] = { [weaponId] = true }
local ownedColors = {}   -- [player] = { [colorId] = true }

local function getCurrency()
	-- Propósito: Obtener CurrencyService.
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/WorkshopService
	-- Retorna: CurrencyService o nil
	return _G.ZB and _G.ZB.CurrencyService
end

local function getStamina()
	-- Propósito: Obtener StaminaService.
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/WorkshopService
	-- Retorna: StaminaService o nil
	return _G.ZB and _G.ZB.Stamina
end

local function canUseWorkshop(player)
	-- Propósito: El taller solo se usa en lobby (gravedad normal).
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/WorkshopService
	-- Retorna: boolean
	if _G.ZB and _G.ZB.GameMode then
		return not _G.ZB.GameMode.isZeroG()
	end
	return true
end

local function buyWeapon(player, id)
	-- Propósito: Comprar/equipar un arma.
	-- Precondiciones: 1. id es un id de Config.Weapons.
	-- Ubicación: ServerScriptService/WorkshopService
	-- Retorna: nil
	local weapon = nil
	for _, w in ipairs(Config.Weapons) do
		if w.id == id then
			weapon = w
			break
		end
	end
	if not weapon then return end

	ownedWeapons[player] = ownedWeapons[player] or {}
	if not ownedWeapons[player][id] then
		local currency = getCurrency()
		if weapon.cost > 0 then
			if not currency or not currency.spendCoins(player, weapon.cost) then
				return
			end
		end
		ownedWeapons[player][id] = true
	end
	player:SetAttribute("WeaponId", weapon.id)
end

local function buyColor(player, id)
	-- Propósito: Comprar/cambiar el color del láser.
	-- Precondiciones: 1. id es un id de Config.LaserColors.
	-- Ubicación: ServerScriptService/WorkshopService
	-- Retorna: nil
	local entry = nil
	for _, c in ipairs(Config.LaserColors) do
		if c.id == id then
			entry = c
			break
		end
	end
	if not entry then return end

	ownedColors[player] = ownedColors[player] or {}
	if not ownedColors[player][id] then
		local currency = getCurrency()
		if entry.cost > 0 then
			if not currency or not currency.spendCoins(player, entry.cost) then
				return
			end
		end
		ownedColors[player][id] = true
	end
	player:SetAttribute("LaserColor", entry.color)
end

local function buyStamina(player)
	-- Propósito: Comprar más estamina máxima.
	-- Precondiciones: 1. player válido.
	-- Ubicación: ServerScriptService/WorkshopService
	-- Retorna: nil
	local currency = getCurrency()
	local stamina = getStamina()
	if not currency or not stamina then return end
	if not currency.spendCoins(player, staminaCfg.COST_PER_TIER) then return end
	stamina.upgradeMax(player)
end

buyRemote.OnServerEvent:Connect(function(player, purchaseType, id)
	if not player or not player.Parent then return end
	if not canUseWorkshop(player) then return end

	if purchaseType == "weapon" then
		buyWeapon(player, id)
	elseif purchaseType == "color" then
		buyColor(player, id)
	elseif purchaseType == "stamina" then
		buyStamina(player)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	ownedWeapons[player] = nil
	ownedColors[player] = nil
end)

_G.ZB = _G.ZB or {}
_G.ZB.Workshop = {
	canUseWorkshop = canUseWorkshop,
}
