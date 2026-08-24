-- Tipo: LocalScript
-- Ubicación: StarterPlayer/StarterPlayerScripts/MovementController
-- Contexto: Cliente

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local moveCfg = Config.Movement
local energyCfg = Config.Energy
local orientCfg = Config.Orientation
local modeCfg = Config.GameMode

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local PARTICIPANT_ATTRIBUTE = "BattleParticipant"

local character, humanoid, rootPart, thrustForce, alignOrient
local frozenLegs = { left = false, right = false }
local eliminated = false
local smoothedThrust = Vector3.zero
local zeroGActive = false

player:SetAttribute("GameMode", modeCfg.LOBBY)

local function cachePhysics()
	if not rootPart then return end
	thrustForce = rootPart:FindFirstChild("ZB_ThrustForce")
	alignOrient = rootPart:FindFirstChild("ZB_AlignOrientation")
end

local function bindCharacter(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	rootPart = char:WaitForChild("HumanoidRootPart")
	cachePhysics()

	rootPart.ChildAdded:Connect(function(child)
		if child.Name == "ZB_ThrustForce" then
			thrustForce = child
		elseif child.Name == "ZB_AlignOrientation" then
			alignOrient = child
		end
	end)

	frozenLegs.left = false
	frozenLegs.right = false
	eliminated = false
	smoothedThrust = Vector3.zero
end

local function getInputVector()
	local move = Vector3.zero
	local look = camera.CFrame.LookVector
	local right = camera.CFrame.RightVector
	local up = Vector3.new(0, 1, 0)

	if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += look end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= look end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += right end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= right end
	if UserInputService:IsKeyDown(moveCfg.VERTICAL_KEY_UP) then move += up end
	if UserInputService:IsKeyDown(moveCfg.VERTICAL_KEY_DOWN) then move -= up end

	if move.Magnitude > 0 then
		move = move.Unit
	end
	return move
end

local function legMultiplier()
	local count = 0
	if frozenLegs.left then count += 1 end
	if frozenLegs.right then count += 1 end
	if count >= 2 then
		return moveCfg.LEG_TWO_FROZEN_MULT
	elseif count == 1 then
		return moveCfg.LEG_ONE_FROZEN_MULT
	end
	return 1
end

local function updateOrientation(dt)
	if not alignOrient or not alignOrient.Parent or not rootPart then
		return
	end

	local camCFrame = camera.CFrame
	local lookFlat = camCFrame.LookVector
	local baseCFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + lookFlat)

	local velocity = rootPart.AssemblyLinearVelocity
	local speedRatio = math.clamp(velocity.Magnitude / orientCfg.TILT_SPEED_REF, 0, 1)
	local localVel = baseCFrame:VectorToObjectSpace(velocity)
	local maxTilt = math.rad(orientCfg.TILT_MAX_DEG) * speedRatio
	local pitch = -math.clamp(localVel.Z / orientCfg.TILT_SPEED_REF, -1, 1) * maxTilt
	local roll = -math.clamp(localVel.X / orientCfg.TILT_SPEED_REF, -1, 1) * maxTilt

	alignOrient.CFrame = baseCFrame * CFrame.Angles(pitch, 0, roll)
end

local function onHeartbeat(dt)
	if not rootPart or not thrustForce or not thrustForce.Parent then
		return
	end

	local currentMode = player:GetAttribute("GameMode") or modeCfg.LOBBY
	zeroGActive = (currentMode == modeCfg.BATTLE or currentMode == modeCfg.DUEL)
		and player:GetAttribute(PARTICIPANT_ATTRIBUTE) == true

	if not zeroGActive then
		thrustForce.Force = Vector3.zero
		smoothedThrust = Vector3.zero
		return
	end

	if eliminated then
		thrustForce.Force = Vector3.zero
		smoothedThrust = Vector3.zero
		return
	end

	if player:GetAttribute("Grabbing") then
		thrustForce.Force = Vector3.zero
		smoothedThrust = Vector3.zero
		return
	end

	if player:GetAttribute("Hooking") then
		updateOrientation(dt)
		smoothedThrust = Vector3.zero
		return
	end

	updateOrientation(dt)

	local boosting = UserInputService:IsKeyDown(moveCfg.BOOST_KEY)
	local direction = getInputVector()
	local velocity = rootPart.AssemblyLinearVelocity

	local battleMult = zeroGActive and moveCfg.BATTLE_THRUST_MULT or 1
	local thrustMag = moveCfg.THRUST_FORCE * legMultiplier() * battleMult
	if boosting then
		thrustMag *= moveCfg.BOOST_MULTIPLIER
	end
	local targetThrust = direction * thrustMag

	local alpha = math.clamp(moveCfg.ACCEL_SMOOTHING * dt, 0, 1)
	smoothedThrust = smoothedThrust:Lerp(targetThrust, alpha)
	local thrust = smoothedThrust

	local mass = rootPart.AssemblyMass
	local drag = -velocity * moveCfg.DRAG * mass

	if velocity.Magnitude > moveCfg.MAX_SPEED and direction.Magnitude > 0 then
		if velocity.Unit:Dot(direction) > 0 then
			thrust = Vector3.zero
		end
	end

	thrustForce.Force = thrust + drag
end

local function onStateChanged(state)
	if type(state) ~= "table" then return end
	frozenLegs.left = state[Config.Limb.LEFT_LEG] == Config.LimbState.FROZEN
	frozenLegs.right = state[Config.Limb.RIGHT_LEG] == Config.LimbState.FROZEN
	eliminated = state.eliminated == true
end

if player.Character then
	bindCharacter(player.Character)
end
player.CharacterAdded:Connect(bindCharacter)
RunService.Heartbeat:Connect(onHeartbeat)

local stateChanged = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("StateChanged")
stateChanged.OnClientEvent:Connect(onStateChanged)
