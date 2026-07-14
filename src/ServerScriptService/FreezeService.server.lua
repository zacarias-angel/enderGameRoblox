-- Tipo: Script
-- Ubicación: ServerScriptService/FreezeService
-- Contexto: Servidor

--[[
	FreezeService
	Aplica los efectos físicos/visuales de un resultado de impacto sobre el
	personaje objetivo: congelar extremidades (tinte + anclar visualmente) o
	eliminar (traje bloqueado, el cuerpo sigue flotando). La decisión de estado
	se delega a PlayerStateService; aquí se aplican los efectos al personaje.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local FreezeMap = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("FreezeMap"))

-- Partes R15 asociadas a cada extremidad, para el tinte de hielo.
local LIMB_PARTS = {
	[Config.Limb.LEFT_ARM] = { "LeftUpperArm", "LeftLowerArm", "LeftHand" },
	[Config.Limb.RIGHT_ARM] = { "RightUpperArm", "RightLowerArm", "RightHand" },
	[Config.Limb.LEFT_LEG] = { "LeftUpperLeg", "LeftLowerLeg", "LeftFoot" },
	[Config.Limb.RIGHT_LEG] = { "RightUpperLeg", "RightLowerLeg", "RightFoot" },
}

local FreezeService = {}

-- Estado por personaje (jugadores y dummies): [character] = { limbKey = state, eliminated }
local charStates = {}

local function freshCharState()
	-- Propósito: Estado inicial "todo activo" para un personaje.
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/FreezeService
	-- Retorna: table de estado.
	return {
		[Config.Limb.LEFT_ARM] = Config.LimbState.OK,
		[Config.Limb.RIGHT_ARM] = Config.LimbState.OK,
		[Config.Limb.LEFT_LEG] = Config.LimbState.OK,
		[Config.Limb.RIGHT_LEG] = Config.LimbState.OK,
		eliminated = false,
	}
end

local function getCharState(character)
	-- Propósito: Obtener/crear el estado de un personaje.
	-- Precondiciones:
	--   1. character es un Model con Humanoid.
	-- Ubicación: ServerScriptService/FreezeService
	-- Retorna: table de estado.
	if not charStates[character] then
		charStates[character] = freshCharState()
		-- Limpiar al destruirse el personaje.
		character.AncestryChanged:Connect(function(_, parent)
			if not parent then
				charStates[character] = nil
			end
		end)
	end
	return charStates[character]
end

local function tintLimb(character, limbKey)
	-- Propósito: Aplicar tinte de hielo a las partes de una extremidad.
	-- Precondiciones:
	--   1. character es un modelo R15 válido.
	--   2. limbKey es una clave de Config.Limb.
	-- Ubicación: ServerScriptService/FreezeService
	-- Retorna: nil
	local partNames = LIMB_PARTS[limbKey]
	if not partNames then return end
	for _, name in ipairs(partNames) do
		local part = character:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			part.Color = Config.LedColors.ICE_TINT
			part.Material = Enum.Material.Ice
		end
	end
end

local function eliminate(character)
	-- Propósito: Bloquear el traje: el cuerpo queda flotando sin control.
	-- Precondiciones:
	--   1. character es un modelo R15 válido con Humanoid y HumanoidRootPart.
	-- Ubicación: ServerScriptService/FreezeService
	-- Retorna: nil
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")

	-- Desactivar el empuje del jugador: neutraliza su VectorForce.
	if rootPart then
		local force = rootPart:FindFirstChild("ZB_ThrustForce")
		if force and force:IsA("VectorForce") then
			force.Force = Vector3.zero
		end
	end

	-- Tinte de traje congelado en el torso/cabeza.
	for _, name in ipairs({ "Head", "UpperTorso", "LowerTorso" }) do
		local part = character:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			part.Color = Config.LedColors.FROZEN
			part.Material = Enum.Material.Ice
		end
	end

	-- El humanoid no debe morir: el cuerpo permanece flotando en la arena.
	if humanoid then
		humanoid.PlatformStand = true
	end

	-- Escudo humano: marcar el cuerpo como agarrable para que los compañeros
	-- vivos puedan aferrarse a él como cobertura móvil (GrabController crea
	-- el ProximityPrompt en el cliente al detectar este atributo).
	character:SetAttribute(Config.Grab.ATTRIBUTE, true)
end

function FreezeService.apply(character, hitResult)
	-- Propósito: Aplicar estado + efectos según el resultado de impacto.
	-- Precondiciones:
	--   1. character es un Model con Humanoid (jugador o dummy).
	--   2. hitResult es un valor de Config.HitResult.
	--   3. Se ejecuta en el servidor.
	-- Ubicación: ServerScriptService/FreezeService
	-- Retorna: boolean (true si se aplicó algún efecto)
	if hitResult == Config.HitResult.NONE then return false end
	if not character or not character:FindFirstChildOfClass("Humanoid") then
		return false
	end

	local state = getCharState(character)
	local player = Players:GetPlayerFromCharacter(character)
	local PlayerState = _G.ZB and _G.ZB.PlayerState

	-- Ya eliminado: no aplicar más efectos.
	if state.eliminated then
		return false
	end

	if hitResult == Config.HitResult.ELIMINATE then
		state.eliminated = true
		eliminate(character)
		if player and PlayerState then
			PlayerState.eliminate(player)
		end
		return true
	end

	local limbKey = FreezeMap.limbKeyFromResult(hitResult)
	if not limbKey then return false end

	-- Extremidad ya congelada: sin cambios.
	if state[limbKey] == Config.LimbState.FROZEN then
		return false
	end

	state[limbKey] = Config.LimbState.FROZEN
	tintLimb(character, limbKey)
	if player and PlayerState then
		PlayerState.setLimb(player, limbKey, Config.LimbState.FROZEN)
	end
	return true
end

_G.ZB = _G.ZB or {}
_G.ZB.FreezeService = FreezeService
