-- Tipo: LocalScript
-- Ubicación: StarterPlayer/StarterPlayerScripts/PortalController
-- Contexto: Cliente

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local matchCfg = Config.Match
local portalCfg = Config.Portal

local portalParts = {}
local setupPortalPart

local function findPortalParts()
	for _, inst in ipairs(workspace:GetDescendants()) do
		if inst:IsA("BasePart") and inst:GetAttribute(portalCfg.ATTRIBUTE) then
			if not portalParts[inst] then
				setupPortalPart(inst)
			end
		end
	end
end

local function updatePortalPart(part, color)
	if portalParts[part] and color then
		part.Color = color
	end
end

setupPortalPart = function(part)
	portalParts[part] = { originalColor = part.Color }
end

local function onMatchStateChanged(payload)
	if type(payload) ~= "table" then return end
	local state = payload.state
	local color = matchCfg.PORTAL_IDLE
	if state == matchCfg.STATE_LOBBY or state == matchCfg.STATE_COUNTDOWN then
		color = matchCfg.PORTAL_OPEN
	elseif state == matchCfg.STATE_ACTIVE or state == matchCfg.STATE_LOCKED or state == matchCfg.STATE_ENDING then
		color = matchCfg.PORTAL_CLOSED
	end
	for part in pairs(portalParts) do
		updatePortalPart(part, color)
	end
end

findPortalParts()
workspace.DescendantAdded:Connect(function(inst)
	if inst:IsA("BasePart") and inst:GetAttribute(portalCfg.ATTRIBUTE) then
		setupPortalPart(inst)
	end
end)
ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("MatchStateChanged").OnClientEvent:Connect(onMatchStateChanged)
