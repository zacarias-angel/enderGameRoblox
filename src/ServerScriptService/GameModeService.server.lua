-- Tipo: Script
-- Ubicación: ServerScriptService/GameModeService
-- Contexto: Servidor

--[[
	GameModeService
	Gestiona el modo de juego actual (LOBBY, BATTLE, DUEL) y controla la
	gravedad del workspace según el modo activo.
	- LOBBY  → gravedad normal (196.2), los jugadores caminan/corren
	- BATTLE → gravedad cero, arena de combate por equipos
	- DUEL   → gravedad cero, duelo 1v1
	Expone API vía _G.ZB.GameMode y replica cambios a clientes con RemoteEvent.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local modeCfg = Config.GameMode

local currentMode = modeCfg.DEFAULT

local function ensureRemote(name)
	-- Propósito: Obtener/crear un RemoteEvent en ReplicatedStorage/RemoteEvents.
	-- Precondiciones:
	--   1. name es un string no vacío.
	-- Ubicación: ServerScriptService/GameModeService
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

local modeChanged = ensureRemote("GameModeChanged")

local function isZeroG(mode)
	-- Propósito: Saber si un modo usa gravedad cero.
	-- Precondiciones:
	--   1. mode es un string de Config.GameMode.
	-- Ubicación: ServerScriptService/GameModeService
	-- Retorna: boolean
	return mode == modeCfg.BATTLE or mode == modeCfg.DUEL
end

local function applyGravity(mode)
	-- Propósito: Cambiar la gravedad del workspace según el modo.
	-- Precondiciones:
	--   1. mode es un string de Config.GameMode.
	-- Ubicación: ServerScriptService/GameModeService
	-- Retorna: nil
	if isZeroG(mode) then
		workspace.Gravity = modeCfg.ZERO_GRAVITY
	else
		workspace.Gravity = modeCfg.NORMAL_GRAVITY
	end
end

local GameMode = {}

function GameMode.getMode()
	-- Propósito: Obtener el modo de juego actual.
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/GameModeService
	-- Retorna: string (Config.GameMode.LOBBY / BATTLE / DUEL)
	return currentMode
end

function GameMode.isZeroG()
	-- Propósito: Saber si el modo actual es de gravedad cero.
	-- Precondiciones: ninguna.
	-- Ubicación: ServerScriptService/GameModeService
	-- Retorna: boolean
	return isZeroG(currentMode)
end

function GameMode.setMode(mode)
	-- Propósito: Cambiar el modo de juego y notificar a todos los clientes.
	-- Precondiciones:
	--   1. mode debe ser LOBBY, BATTLE o DUEL.
	-- Ubicación: ServerScriptService/GameModeService
	-- Retorna: nil
	if mode ~= modeCfg.LOBBY and mode ~= modeCfg.BATTLE and mode ~= modeCfg.DUEL then
		return
	end
	if mode == currentMode then return end

	local prevMode = currentMode
	currentMode = mode

	applyGravity(mode)
	modeChanged:FireAllClients(mode, prevMode)

	-- Notificar a otros servicios del cambio de modo.
	if _G.ZB then
		if _G.ZB.RankService and mode ~= modeCfg.LOBBY then
			_G.ZB.RankService.onModeStarted(mode)
		end
		if _G.ZB.PlayerState and mode == modeCfg.LOBBY then
			-- Al volver al lobby, resetear estados de todos los jugadores.
			for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
				_G.ZB.PlayerState.reset(player)
			end
		end
	end
end

-- Iniciar en modo lobby con gravedad normal.
applyGravity(currentMode)

_G.ZB = _G.ZB or {}
_G.ZB.GameMode = GameMode
