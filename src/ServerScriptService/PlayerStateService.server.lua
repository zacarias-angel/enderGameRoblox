-- Tipo: Script
-- Ubicación: ServerScriptService/PlayerStateService
-- Contexto: Servidor

--[[
	PlayerStateService
	Fuente de verdad del estado de combate de cada jugador: extremidades
	congeladas y si está eliminado. Expone una API (vía _G.ZB.PlayerState y
	BindableFunction interno) para que FreezeService y ShootingService la usen,
	y replica el estado al cliente mediante StateChanged.
	Toda mutación de estado ocurre aquí, en el servidor. Ver ReglasRoblox.md §4.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local function ensureRemote(name)
	-- Propósito: Obtener/crear un RemoteEvent en ReplicatedStorage/RemoteEvents.
	-- Precondiciones:
	--   1. name es un string no vacío.
	-- Ubicación: ServerScriptService/PlayerStateService
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

local stateChanged = ensureRemote("StateChanged")

-- Estado por jugador: [player] = { leftArm, rightArm, leftLeg, rightLeg, eliminated }
local states = {}

local PlayerState = {}

local function freshState()
	-- Propósito: Construir un estado inicial "todo activo".
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/PlayerStateService
	-- Retorna: table de estado.
	return {
		[Config.Limb.LEFT_ARM] = Config.LimbState.OK,
		[Config.Limb.RIGHT_ARM] = Config.LimbState.OK,
		[Config.Limb.LEFT_LEG] = Config.LimbState.OK,
		[Config.Limb.RIGHT_LEG] = Config.LimbState.OK,
		eliminated = false,
	}
end

function PlayerState.get(player)
	-- Propósito: Obtener el estado actual de un jugador (creándolo si falta).
	-- Precondiciones:
	--   1. player es un Player válido.
	-- Ubicación: ServerScriptService/PlayerStateService
	-- Retorna: table de estado.
	if not states[player] then
		states[player] = freshState()
	end
	return states[player]
end

function PlayerState.reset(player)
	-- Propósito: Restablecer el estado de un jugador a "todo activo".
	-- Precondiciones:
	--   1. player es un Player válido.
	-- Ubicación: ServerScriptService/PlayerStateService
	-- Retorna: nil
	states[player] = freshState()
	PlayerState.replicate(player)
end

function PlayerState.isAlive(player)
	-- Propósito: Indicar si el jugador no está eliminado.
	-- Precondiciones:
	--   1. player es un Player válido.
	-- Ubicación: ServerScriptService/PlayerStateService
	-- Retorna: boolean
	return not PlayerState.get(player).eliminated
end

function PlayerState.setLimb(player, limbKey, limbState)
	-- Propósito: Cambiar el estado de una extremidad y replicar.
	-- Precondiciones:
	--   1. player válido; limbKey es una clave de Config.Limb.
	--   2. limbState es un valor de Config.LimbState.
	-- Ubicación: ServerScriptService/PlayerStateService
	-- Retorna: nil
	local state = PlayerState.get(player)
	if state[limbKey] == nil then return end
	state[limbKey] = limbState
	PlayerState.replicate(player)
end

function PlayerState.eliminate(player)
	-- Propósito: Marcar al jugador como eliminado (traje bloqueado) y replicar.
	-- Precondiciones:
	--   1. player es un Player válido.
	-- Ubicación: ServerScriptService/PlayerStateService
	-- Retorna: nil
	local state = PlayerState.get(player)
	state.eliminated = true
	PlayerState.replicate(player)
end

function PlayerState.replicate(player)
	-- Propósito: Enviar el estado actual al cliente dueño.
	-- Precondiciones:
	--   1. player es un Player válido y conectado.
	-- Ubicación: ServerScriptService/PlayerStateService
	-- Retorna: nil
	if not player or not player.Parent then return end
	stateChanged:FireClient(player, PlayerState.get(player))
end

Players.PlayerAdded:Connect(function(player)
	PlayerState.reset(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.2)
		PlayerState.reset(player)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	states[player] = nil
end)

-- Exponer API a otros servicios del servidor.
_G.ZB = _G.ZB or {}
_G.ZB.PlayerState = PlayerState
