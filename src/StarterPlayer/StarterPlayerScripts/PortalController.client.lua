-- Tipo: LocalScript
-- Ubicación: StarterPlayer/StarterPlayerScripts/PortalController
-- Contexto: Cliente

--[[
	PortalController
	Muestra el estado visual de la arena en el portal del lobby. Busca objetos
	con el atributo "isPortal" y escucha el estado de la partida desde el
	servidor (MatchStateChanged) para actualizar solo el color.

	La entrada ya no es manual: todos los jugadores conectados entran juntos al
	terminar la cuenta regresiva global.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local matchCfg = Config.Match
local portalCfg = Config.Portal

local portalParts = {}  -- [part] = { originalColor }
local setupPortalPart

local function findPortalParts()
	-- Propósito: Encontrar todas las partes con atributo isPortal en el workspace.
	-- Precondiciones: ninguna.
	-- Ubicación: StarterPlayerScripts/PortalController
	-- Retorna: nil
	for _, inst in ipairs(workspace:GetDescendants()) do
		if inst:IsA("BasePart") and inst:GetAttribute(portalCfg.ATTRIBUTE) then
			if not portalParts[inst] then
				setupPortalPart(inst)
			end
		end
	end
end

local function updatePortalPart(part, color)
	-- Propósito: Cambiar el color del portal.
	-- Precondiciones:
	--   1. part es una BasePart con ProximityPrompt.
	-- Ubicación: StarterPlayerScripts/PortalController
	-- Retorna: nil
	local data = portalParts[part]
	if not data then return end

	-- Guardar color original si no está.
	if not data.originalColor then
		data.originalColor = part.Color
	end

	-- Actualizar color de la parte.
	if color then
		part.Color = color
	end

end

setupPortalPart = function(part)
	-- Propósito: Registrar una parte portal para actualizar su color.
	-- Precondiciones:
	--   1. part es una BasePart con atributo isPortal.
	-- Ubicación: StarterPlayerScripts/PortalController
	-- Retorna: nil
	portalParts[part] = {
		originalColor = part.Color,
	}
end

local function onMatchStateChanged(payload)
	-- Propósito: Reaccionar a cambios de estado de la partida desde el servidor.
	-- Precondiciones:
	--   1. payload es una tabla con state, joinWindow, countdown, etc.
	-- Ubicación: StarterPlayerScripts/PortalController
	-- Retorna: nil
	if type(payload) ~= "table" then return end

	local state = payload.state

	-- Determinar color y texto según el estado.
	local color
	if state == matchCfg.STATE_LOBBY then
		color = matchCfg.PORTAL_OPEN
	elseif state == matchCfg.STATE_COUNTDOWN then
		color = matchCfg.PORTAL_OPEN
	elseif state == matchCfg.STATE_ACTIVE then
		color = matchCfg.PORTAL_CLOSED
	elseif state == matchCfg.STATE_LOCKED then
		color = matchCfg.PORTAL_CLOSED
	elseif state == matchCfg.STATE_ENDING then
		color = matchCfg.PORTAL_CLOSED
	elseif state == matchCfg.STATE_RESET then
		color = matchCfg.PORTAL_IDLE
	else
		color = matchCfg.PORTAL_IDLE
	end

	for part, _ in pairs(portalParts) do
		updatePortalPart(part, color)
	end
end

-- Conexiones
findPortalParts()

-- Escuchar nuevas partes agregadas al workspace (por si el portal se crea después).
workspace.DescendantAdded:Connect(function(inst)
	if inst:IsA("BasePart") and inst:GetAttribute(portalCfg.ATTRIBUTE) then
		setupPortalPart(inst)
	end
end)

local matchStateChanged = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("MatchStateChanged")
matchStateChanged.OnClientEvent:Connect(onMatchStateChanged)
