-- Tipo: LocalScript
-- Ubicación: StarterPlayer/StarterPlayerScripts/HookController
-- Contexto: Cliente

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local hookCfg = Config.Hook
local hookEnergyCfg = Config.HookEnergy
local moveCfg = Config.Movement
local modeCfg = Config.GameMode

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local remotes = ReplicatedStorage:WaitForChild("RemoteEvents")
local hookVisual = remotes:WaitForChild("HookVisual")
local hookTryConsume = remotes:WaitForChild("HookTryConsume")
local hookDrainTick = remotes:WaitForChild("HookDrainTick")
local hookVfx = remotes:WaitForChild("HookVfx")
local stateChanged = remotes:WaitForChild("StateChanged")
local PARTICIPANT_ATTRIBUTE = "BattleParticipant"

local hookAssets = ReplicatedStorage:WaitForChild("HookCosmeticAssets")
local hookTipsFolder = hookAssets:WaitForChild("HookTips")

local character, rootPart, thrustForce
local hookActive = false
local anchorPoint = Vector3.zero
local anchorTarget = nil
local ropeBeam = nil
local ropeAttach0 = nil
local ropeAttach1 = nil
local hookProjectile = nil
local tipModel = nil
local lastHookTime = 0
local lastHookVisualUpdate = 0
local lastHookDrainTime = 0
local eliminated = false

player:SetAttribute("Hooking", false)

local function getHookRopeConfig()
	local ropeId = player:GetAttribute("HookRopeCosmeticId") or "default"
	for _, entry in ipairs(Config.HookRopeCosmetics or {}) do
		if entry.id == ropeId then
			return entry
		end
	end
	return Config.HookRopeCosmetics and Config.HookRopeCosmetics[1] or nil
end

local function getHookTipAsset()
	local tipId = player:GetAttribute("HookTipCosmeticId") or "default"
	return hookTipsFolder:FindFirstChild(tipId) or hookTipsFolder:FindFirstChild("default")
end

local function destroyTipModel()
	if tipModel then
		tipModel:Destroy()
		tipModel = nil
	end
end

local function createTipModel(position)
	destroyTipModel()
	local asset = getHookTipAsset()
	if not asset or not asset:IsA("Model") or not asset.PrimaryPart then
		return
	end
	local clone = asset:Clone()
	for _, part in ipairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CastShadow = false
		end
	end
	clone:PivotTo(CFrame.new(position))
	clone.Parent = workspace
	tipModel = clone
end

local function destroyRope()
	if ropeBeam then
		ropeBeam:Destroy()
		ropeBeam = nil
	end
	if ropeAttach1 then
		ropeAttach1:Destroy()
		ropeAttach1 = nil
	end
	destroyTipModel()
	if hookProjectile then
		hookProjectile:Destroy()
		hookProjectile = nil
	end
end

local function createRope(toPos)
	destroyRope()
	if not rootPart then return end

	ropeAttach0 = rootPart:FindFirstChild("ZB_HookAttach")
	if not ropeAttach0 then
		ropeAttach0 = Instance.new("Attachment")
		ropeAttach0.Name = "ZB_HookAttach"
		ropeAttach0.Parent = rootPart
	end

	ropeAttach1 = Instance.new("Attachment")
	ropeAttach1.Name = "ZB_HookTarget"
	ropeAttach1.WorldPosition = toPos
	ropeAttach1.Parent = workspace
	createTipModel(toPos)

	ropeBeam = Instance.new("Beam")
	ropeBeam.Name = "ZB_HookRope"
	ropeBeam.Attachment0 = ropeAttach0
	ropeBeam.Attachment1 = ropeAttach1
	local ropeCfg = getHookRopeConfig()
	ropeBeam.Color = ColorSequence.new((ropeCfg and ropeCfg.color) or hookCfg.CABLE_COLOR)
	ropeBeam.Width0 = (ropeCfg and ropeCfg.width0) or 0.35
	ropeBeam.Width1 = (ropeCfg and ropeCfg.width1) or 0.22
	ropeBeam.Transparency = NumberSequence.new(0.1)
	ropeBeam.Texture = ""
	ropeBeam.TextureMode = Enum.TextureMode.Static
	ropeBeam.TextureLength = 1
	ropeBeam.LightEmission = 0.6
	ropeBeam.Parent = workspace
end

local function spawnProjectile(fromPos, toPos)
	if hookProjectile then
		hookProjectile:Destroy()
		hookProjectile = nil
	end

	local distance = (toPos - fromPos).Magnitude
	if distance < 0.5 then return end

	local asset = getHookTipAsset()
	if asset and asset:IsA("Model") and asset.PrimaryPart then
		local clone = asset:Clone()
		for _, part in ipairs(clone:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				part.CastShadow = false
			end
		end
		clone:PivotTo(CFrame.lookAt(fromPos, toPos) * CFrame.new(0, 0, -distance / 2))
		clone.Parent = workspace
		Debris:AddItem(clone, 0.2)
		hookProjectile = clone
		return
	end

	local proj = Instance.new("Part")
	proj.Name = "ZB_HookProj"
	proj.Anchored = true
	proj.CanCollide = false
	proj.CanQuery = false
	proj.CastShadow = false
	proj.Material = Enum.Material.Neon
	proj.Color = hookCfg.CABLE_COLOR
	proj.Transparency = 0.2
	proj.Size = Vector3.new(0.35, 0.35, distance)
	proj.CFrame = CFrame.lookAt(fromPos, toPos) * CFrame.new(0, 0, -distance / 2)
	proj.Parent = workspace

	local tween = TweenService:Create(proj, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0.7 })
	tween:Play()
	Debris:AddItem(proj, 0.2)
	hookProjectile = proj
end

local function bindCharacter(char)
	character = char
	rootPart = char:WaitForChild("HumanoidRootPart")
	thrustForce = rootPart:FindFirstChild("ZB_ThrustForce")
	rootPart.ChildAdded:Connect(function(child)
		if child.Name == "ZB_ThrustForce" then
			thrustForce = child
		end
	end)
end

local function raycastHook()
	if not camera or not character then return nil, nil end
	local viewport = camera.ViewportSize
	local screenX = viewport.X / 2 + Config.Weapon.CROSSHAIR_OFFSET_X
	local screenY = viewport.Y / 2 + Config.Weapon.CROSSHAIR_OFFSET_Y
	local ray = camera:ViewportPointToRay(screenX, screenY)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }
	local hit = workspace:Raycast(ray.Origin, ray.Direction.Unit * hookCfg.MAX_RANGE, params)
	if hit then
		return hit.Position, hit.Instance
	end
	return nil, nil
end

local function findCharacterModel(hitPart)
	local model = hitPart
	while model do
		if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") then
			return model
		end
		model = model.Parent
	end
	return nil
end

local function getAnchorPosition()
	if anchorTarget and anchorTarget.Parent then
		local targetRoot = anchorTarget:FindFirstChild("HumanoidRootPart")
		if targetRoot then
			return targetRoot.Position
		end
	end
	return anchorPoint
end

local function sendHookVisual(action)
	if not rootPart then return end
	hookVisual:FireServer(action, { targetPos = getAnchorPosition() })
end

local function fireHook()
	if hookActive then return false end
	local mode = player:GetAttribute("GameMode") or modeCfg.LOBBY
	if mode ~= modeCfg.BATTLE and mode ~= modeCfg.DUEL then return false end
	if player:GetAttribute(PARTICIPANT_ATTRIBUTE) ~= true then return false end
	if eliminated or player:GetAttribute("Grabbing") then return false end
	if not rootPart or not thrustForce or not thrustForce.Parent then return false end

	local now = os.clock()
	if (now - lastHookTime) < hookCfg.COOLDOWN then return false end
	local success, result = pcall(function()
		return hookTryConsume:InvokeServer()
	end)
	if not success or result ~= true then return false end
	lastHookTime = now

	local hitPos, hitPart = raycastHook()
	if not hitPos or not hitPart then return false end

	anchorPoint = hitPos
	anchorTarget = findCharacterModel(hitPart)
	hookActive = true
	lastHookDrainTime = os.clock()
	player:SetAttribute("Hooking", true)

	spawnProjectile(rootPart.Position, hitPos)
	task.wait(0.05)
	createRope(anchorPoint)
	sendHookVisual("start")

	local anchorPlayer = anchorTarget and Players:GetPlayerFromCharacter(anchorTarget) or nil
	hookVfx:FireServer("hook", anchorPoint, anchorPlayer)
	return true
end

local function releaseHook(keepInertia)
	if not hookActive then return end
	hookActive = false
	player:SetAttribute("Hooking", false)
	anchorTarget = nil
	sendHookVisual("release")
	destroyRope()
	hookVfx:FireServer("release")
	if thrustForce and thrustForce:IsA("VectorForce") then
		thrustForce.Force = Vector3.zero
	end
	if keepInertia and rootPart then
		rootPart.AssemblyLinearVelocity = rootPart.AssemblyLinearVelocity * hookCfg.DRIFT_RETENTION
	elseif rootPart then
		rootPart.AssemblyLinearVelocity = Vector3.zero
	end
end

local function updateCableVisual()
	if not ropeAttach1 or not ropeAttach1.Parent then return end
	local pos = getAnchorPosition()
	ropeAttach1.WorldPosition = pos
	if tipModel and tipModel.PrimaryPart then
		tipModel:PivotTo(CFrame.new(pos))
	end
end

local function updateHook()
	local mode = player:GetAttribute("GameMode") or modeCfg.LOBBY
	if (mode ~= modeCfg.BATTLE and mode ~= modeCfg.DUEL) and hookActive then
		releaseHook(false)
		return
	end
	if not hookActive or not rootPart or not thrustForce or not thrustForce.Parent then return end

	local targetPos = getAnchorPosition()
	local toAnchor = targetPos - rootPart.Position
	local distance = toAnchor.Magnitude
	if (os.clock() - lastHookVisualUpdate) >= 0.08 then
		lastHookVisualUpdate = os.clock()
		sendHookVisual("update")
	end
	if distance < hookCfg.BREAK_DISTANCE then
		releaseHook(true)
		return
	end
	if anchorTarget and not anchorTarget.Parent then
		releaseHook(true)
		return
	end

	local now = os.clock()
	local elapsed = now - lastHookDrainTime
	if elapsed >= 0.2 then
		lastHookDrainTime = now
		local success, result = pcall(function()
			return hookDrainTick:InvokeServer(hookEnergyCfg.PULL_DRAIN_PER_SEC * elapsed)
		end)
		if not success or result ~= true then
			releaseHook(false)
			return
		end
	end

	local dir = toAnchor.Unit
	local forceMag = hookCfg.PULL_FORCE * math.clamp(distance / 30, 0.3, 1.2)
	local pullForce = dir * forceMag
	local velocity = rootPart.AssemblyLinearVelocity
	local mass = rootPart.AssemblyMass
	local drag = -velocity * moveCfg.DRAG * 1.8 * mass
	if velocity.Magnitude > hookCfg.MAX_PULL_SPEED then
		local velDir = velocity.Unit
		if velDir:Dot(dir) > 0 then
			thrustForce.Force = drag
			updateCableVisual()
			return
		end
	end
	thrustForce.Force = pullForce + drag
	updateCableVisual()
end

local function onInputBegan(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == hookCfg.KEY then
		fireHook()
	end
end

local function onInputEnded(input)
	if input.KeyCode == hookCfg.KEY then
		releaseHook(true)
	end
end

if player.Character then
	bindCharacter(player.Character)
end
player.CharacterAdded:Connect(bindCharacter)
UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputEnded:Connect(onInputEnded)
RunService.Heartbeat:Connect(updateHook)
stateChanged.OnClientEvent:Connect(function(state)
	if type(state) ~= "table" then return end
	eliminated = state.eliminated == true
	if eliminated then
		releaseHook(false)
	end
end)

local modeChanged = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("GameModeChanged")
modeChanged.OnClientEvent:Connect(function(mode)
	if mode ~= modeCfg.BATTLE and mode ~= modeCfg.DUEL then
		releaseHook(false)
	end
end)
