-- Tipo: LocalScript
-- Ubicación: StarterPlayer/StarterPlayerScripts/PortalController
-- Contexto: Cliente

--[[
	PortalController
	Gestiona la interacción del jugador con el portal de batalla en el
	lobby. Busca objetos en el workspace con el atributo "isPortal", les
	coloca un ProximityPrompt y escucha el estado de la partida desde el
	servidor (MatchStateChanged) para actualizar el color y el texto.

	- Verde: partida abierta / cuenta regresiva → puede entrar.
	- Amarillo: partida en curso, ventana abierta → puede entrar (apurate).
	- Rojo: partida cerrada / ventana cerrada → no puede entrar.

	Al activar el prompt, envía JoinMatchRequest al servidor.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local matchCfg = Config.Match
local portalCfg = Config.Portal

local player = Players.LocalPlayer
local PROMPT_NAME = "ZB_PortalPrompt"

local portalParts = {}  -- [part] = { prompt, originalColor }

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

local function updatePortalPart(part, color, actionText, objectText)
	-- Propósito: Cambiar el color y texto de un portal.
	-- Precondiciones:
	--   1. part es una BasePart con ProximityPrompt.
	-- Ubicación: StarterPlayerScripts/PortalController
	-- Retorna: nil
	local data = portalParts[part]
	if not data or not data.prompt then return end

	-- Guardar color original si no está.
	if not data.originalColor then
		data.originalColor = part.Color
	end

	-- Actualizar color de la parte.
	if color then
		part.Color = color
	end

	-- Actualizar texto del prompt.
	if actionText then
		data.prompt.ActionText = actionText
	end
	if objectText then
		data.prompt.ObjectText = objectText
	end
end

local function setupPortalPart(part)
	-- Propósito: Crear el ProximityPrompt en una parte portal.
	-- Precondiciones:
	--   1. part es una BasePart con atributo isPortal.
	-- Ubicación: StarterPlayerScripts/PortalController
	-- Retorna: nil
	if part:FindFirstChild(PROMPT_NAME) then return end

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = PROMPT_NAME
	prompt.ActionText = portalCfg.PROMPT_ACTION
	prompt.ObjectText = portalCfg.PROMPT_OBJECT
	prompt.KeyboardKeyCode = portalCfg.KEY
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = portalCfg.MAX_DISTANCE
	prompt.RequiresLineOfSight = false
	prompt.Parent = part

	portalParts[part] = {
		prompt = prompt,
		originalColor = part.Color,
	}

	prompt.Triggered:Connect(function()
		local joinRequest = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("JoinMatchRequest")
		joinRequest:FireServer()
	end)
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
	local color, actionText
	if state == matchCfg.STATE_LOBBY then
		color = matchCfg.PORTAL_OPEN
		actionText = portalCfg.TEXT_OPEN
	elseif state == matchCfg.STATE_COUNTDOWN then
		color = matchCfg.PORTAL_OPEN
		actionText = portalCfg.TEXT_OPEN .. " (" .. tostring(payload.countdown or 0) .. "s)"
	elseif state == matchCfg.STATE_ACTIVE then
		color = matchCfg.PORTAL_HURRY
		actionText = portalCfg.TEXT_HURRY .. " (" .. tostring(payload.joinWindow or 0) .. "s)"
	elseif state == matchCfg.STATE_LOCKED then
		color = matchCfg.PORTAL_CLOSED
		actionText = portalCfg.TEXT_CLOSED
	elseif state == matchCfg.STATE_ENDING then
		color = matchCfg.PORTAL_CLOSED
		actionText = "Ganador: " .. (payload.winner or "---")
	elseif state == matchCfg.STATE_RESET then
		color = matchCfg.PORTAL_IDLE
		actionText = "Volviendo al lobby..."
	else
		color = matchCfg.PORTAL_IDLE
		actionText = portalCfg.TEXT_WAITING
	end

	for part, _ in pairs(portalParts) do
		updatePortalPart(part, color, actionText)
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
