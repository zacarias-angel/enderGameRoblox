-- Tipo: Script
-- Ubicación: ServerScriptService/HookVisualService
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
local hookVfx = ensureRemote("HookVfx")
local visuals = {}

local hookAssets = ReplicatedStorage:FindFirstChild("HookCosmeticAssets")
local hookTipsFolder = hookAssets and hookAssets:FindFirstChild("HookTips")

local function getTipAsset(player)
	local tipId = player:GetAttribute("HookTipCosmeticId") or "default"
	return hookTipsFolder and hookTipsFolder:FindFirstChild(tipId) or (hookTipsFolder and hookTipsFolder:FindFirstChild("default"))
end

local function getRopeConfig(player)
	local ropeId = player:GetAttribute("HookRopeCosmeticId") or "default"
	for _, entry in ipairs(Config.HookRopeCosmetics or {}) do
		if entry.id == ropeId then return entry end
	end
	return Config.HookRopeCosmetics and Config.HookRopeCosmetics[1] or nil
end

local function destroyVisual(player)
	local visual = visuals[player]
	if not visual then return end
	visuals[player] = nil
	if visual.beam then visual.beam:Destroy() end
	if visual.targetAttachment then visual.targetAttachment:Destroy() end
	if visual.targetPart then visual.targetPart:Destroy() end
	if visual.tipModel then visual.tipModel:Destroy() end
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
	local tipModel = nil
	local asset = getTipAsset(player)
	if asset and asset:IsA("Model") and asset.PrimaryPart then
		tipModel = asset:Clone()
		for _, part in ipairs(tipModel:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				part.CastShadow = false
			end
		end
		tipModel:PivotTo(CFrame.new(targetPart.Position))
		tipModel.Parent = workspace
	end
	local beam = Instance.new("Beam")
	beam.Name = "ZB_HookRope"
	beam.Attachment0 = rootAttachment
	beam.Attachment1 = targetAttachment
	local ropeCfg = getRopeConfig(player)
	beam.Color = ColorSequence.new((ropeCfg and ropeCfg.color) or Config.Hook.CABLE_COLOR)
	beam.Width0 = (ropeCfg and ropeCfg.width0) or 0.35
	beam.Width1 = (ropeCfg and ropeCfg.width1) or 0.22
	beam.Transparency = NumberSequence.new(0.1)
	beam.LightEmission = 0.6
	beam.Parent = workspace
	visuals[player] = { beam = beam, targetAttachment = targetAttachment, targetPart = targetPart, tipModel = tipModel }
	return visuals[player]
end

local function spawnProjectile(player, fromPos, toPos)
	local distance = (toPos - fromPos).Magnitude
	if distance < 0.5 then return end
	local asset = getTipAsset(player)
	if asset and asset:IsA("Model") and asset.PrimaryPart then
		local clone = asset:Clone()
		clone:PivotTo(CFrame.lookAt(fromPos, toPos) * CFrame.new(0, 0, -distance / 2))
		for _, part in ipairs(clone:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				part.CastShadow = false
			end
		end
		clone.Parent = workspace
		Debris:AddItem(clone, 0.25)
		return
	end
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
		if visual.tipModel and visual.tipModel.PrimaryPart then
			visual.tipModel:PivotTo(CFrame.new(targetPos))
		end
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root then spawnProjectile(player, root.Position, targetPos) end
	elseif action == "update" and visual then
		visual.targetPart.Position = targetPos
		if visual.tipModel and visual.tipModel.PrimaryPart then
			visual.tipModel:PivotTo(CFrame.new(targetPos))
		end
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
