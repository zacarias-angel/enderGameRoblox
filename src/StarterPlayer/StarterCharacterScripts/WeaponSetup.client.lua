-- Tipo: LocalScript
-- Ubicación: StarterPlayer/StarterCharacterScripts/WeaponSetup
-- Contexto: Cliente

--[[
	WeaponSetup
	Construye un blaster procedural (sin assets externos) y lo suelda a la mano
	derecha del personaje. Expone un Attachment "Muzzle" en la punta del cañón,
	que ShootingController usa como origen del láser. Es visual/local; el
	gameplay del disparo se valida en el servidor (ReglasRoblox.md §5).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local player = Players.LocalPlayer
local character = script.Parent

local WEAPON_NAME = "ZB_Blaster"
local MUZZLE_NAME = "Muzzle"

local function getWeaponCfg()
	-- Propósito: Config del arma equipada por el jugador.
	-- Precondiciones: ninguna.
	-- Ubicación: StarterCharacterScripts/WeaponSetup
	-- Retorna: table de Config.Weapons (o la primera por defecto)
	local id = player:GetAttribute("WeaponId")
	for _, w in ipairs(Config.Weapons) do
		if w.id == id then return w end
	end
	return Config.Weapons[1]
end

local function makePart(name, size, color, material)
	-- Propósito: Crear una BasePart base para el blaster.
	-- Precondiciones:
	--   1. size es Vector3; color es Color3.
	-- Ubicación: StarterCharacterScripts/WeaponSetup
	-- Retorna: Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = material or Enum.Material.Metal
	part.CanCollide = false
	part.CanQuery = false
	part.Massless = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	return part
end

local function weld(a, b)
	-- Propósito: Soldar rígidamente la parte b a la parte a.
	-- Precondiciones:
	--   1. a y b son BaseParts con CFrame ya posicionado.
	-- Ubicación: StarterCharacterScripts/WeaponSetup
	-- Retorna: WeldConstraint
	local w = Instance.new("WeldConstraint")
	w.Part0 = a
	w.Part1 = b
	w.Parent = a
	return w
end

local function buildBlaster(hand)
	-- Propósito: Ensamblar el blaster y soldarlo a la mano derecha.
	-- Precondiciones:
	--   1. hand es la RightHand del rig R15.
	-- Ubicación: StarterCharacterScripts/WeaponSetup
	-- Retorna: Model (el blaster) o nil
	if character:FindFirstChild(WEAPON_NAME) then
		return character:FindFirstChild(WEAPON_NAME)
	end

	local weapon = getWeaponCfg()

	local model = Instance.new("Model")
	model.Name = WEAPON_NAME

	-- CFrame de referencia: sobre la palma, cañón hacia adelante del personaje.
	local baseCF = hand.CFrame * CFrame.new(0, -0.4, -0.4)

	-- Cuerpo principal (empuñadura/receiver).
	local body = makePart("Body", Vector3.new(0.35, 0.5, 1.0), Color3.fromRGB(45, 48, 58))
	body.CFrame = baseCF
	body.Parent = model

	-- Cañón (el grosor escala con el arma).
	local barrel = makePart("Barrel", Vector3.new(weapon.laserWidth, weapon.laserWidth, 1.1), Color3.fromRGB(30, 32, 40))
	barrel.CFrame = baseCF * CFrame.new(0, 0.12, -0.9)
	barrel.Parent = model

	-- Núcleo de energía (neón, color del arma).
	local core = makePart("Core", Vector3.new(0.14, 0.14, 0.5), weapon.color, Enum.Material.Neon)
	core.CFrame = baseCF * CFrame.new(0, 0.12, -0.6)
	core.Parent = model

	model.PrimaryPart = body

	-- Attachment del muzzle en la punta del cañón.
	local muzzle = Instance.new("Attachment")
	muzzle.Name = MUZZLE_NAME
	muzzle.CFrame = barrel.CFrame:ToObjectSpace(baseCF * CFrame.new(0, 0.12, -1.5))
	muzzle.Parent = barrel

	model.Parent = character

	-- Soldar todas las partes al cuerpo y el cuerpo a la mano.
	weld(body, barrel)
	weld(body, core)
	weld(hand, body)

	return model
end

local function setup()
	-- Propósito: Esperar la mano derecha y construir el blaster.
	-- Precondiciones:
	--   1. character es un rig R15 con RightHand.
	-- Ubicación: StarterCharacterScripts/WeaponSetup
	-- Retorna: nil
	character:WaitForChild("Humanoid")
	local hand = character:WaitForChild("RightHand", 8)
	if not hand then return end
	task.wait(0.1)
	buildBlaster(hand)
end

setup()
