-- Tipo: Script
-- Ubicacion: ServerScriptService/HookVisualService
-- Contexto: Servidor

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local function ensureRemote(name)
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

local hookVisual = ensureRemote("HookVisual")
local visuals = {}

local function destroyVisual(player)
	local visual = visuals[player]
	if not visual then return end
	visuals[player] = nil
	if visual.beam then visual.beam:Destroy() end
	if visual.targetAttachment then visual.targetAttachment:Destroy() end
	if visual.targetPart then visual.targetPart:Destroy() end
end

local function ensureVisual(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end

	destroyVisual(player)

	local rootAttachment = root:FindFirstChild("ZB_HookAttach")
	if not rootAttachment then
		rootAttachment = Instance.new("Attachment")
		rootAttachment.Name = "ZB_HookAttach"
		rootAttachment.Parent = root
	end

	local targetPart = Instance.new("Part")
	targetPart.Name = "ZB_HookTargetPart"
	targetPart.Anchored = true
	targetPart.CanCollide = false
	targetPart.CanQuery = false
	targetPart.Transparency = 1
	targetPart.Size = Vector3.new(0.2, 0.2, 0.2)
	targetPart.Parent = workspace

	local targetAttachment = Instance.new("Attachment")
	targetAttachment.Name = "ZB_HookTarget"
	targetAttachment.Parent = targetPart

	local beam = Instance.new("Beam")
	beam.Name = "ZB_HookRope"
	beam.Attachment0 = rootAttachment
	beam.Attachment1 = targetAttachment
	beam.Color = ColorSequence.new(Config.Hook.CABLE_COLOR)
	beam.Width0 = 0.35
	beam.Width1 = 0.22
	beam.Transparency = NumberSequence.new(0.1)
	beam.LightEmission = 0.6
	beam.Parent = workspace

	visuals[player] = {
		beam = beam,
		targetAttachment = targetAttachment,
		targetPart = targetPart,
	}
	return visuals[player]
end

local function spawnProjectile(fromPos, toPos)
	local distance = (toPos - fromPos).Magnitude
	if distance < 0.5 then return end

	local proj = Instance.new("Part")
	proj.Name = "ZB_HookProj"
	proj.Anchored = true
	proj.CanCollide = false
	proj.CanQuery = false
	proj.CastShadow = false
	proj.Material = Enum.Material.Neon
	proj.Color = Config.Hook.CABLE_COLOR
	proj.Transparency = 0.2
	proj.Size = Vector3.new(0.35, 0.35, distance)
	proj.CFrame = CFrame.lookAt(fromPos, toPos) * CFrame.new(0, 0, -distance / 2)
	proj.Parent = workspace
	Debris:AddItem(proj, 0.2)
end

hookVisual.OnServerEvent:Connect(function(player, action, payload)
	if type(action) ~= "string" then return end
	if type(payload) ~= "table" then payload = {} end

	if action == "release" then
		destroyVisual(player)
		return
	end

	local targetPos = payload.targetPos
	if typeof(targetPos) ~= "Vector3" then return end

	local visual = visuals[player]
	if action == "start" then
		visual = ensureVisual(player)
		if not visual then return end
		visual.targetPart.Position = targetPos
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root then
			spawnProjectile(root.Position, targetPos)
		end
		return
	end

	if action == "update" and visual then
		visual.targetPart.Position = targetPos
	end
end)

Players.PlayerRemoving:Connect(destroyVisual)

Players.PlayerAdded:Connect(function(player)
	player.CharacterRemoving:Connect(function()
		destroyVisual(player)
	end)
end)

for _, player in ipairs(Players:GetPlayers()) do
	player.CharacterRemoving:Connect(function()
		destroyVisual(player)
	end)
end
