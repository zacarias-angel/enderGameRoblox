-- Tipo: ModuleScript
-- Ubicación: ReplicatedStorage/Shared/Config
-- Contexto: Compartido

--[[
	Config
	Constantes globales de ZERO BREACH. Cliente y servidor leen de aquí.
	No contiene lógica de gameplay; solo valores. Ver ReglasRoblox.md §8.
]]

local Config = {}

Config.Movement = {
	THRUST_FORCE = 2200,
	BOOST_MULTIPLIER = 2.2,
	MAX_SPEED = 75,
	DRAG = 0.25,
	ACCEL_SMOOTHING = 8,
	VERTICAL_KEY_UP = Enum.KeyCode.Space,
	VERTICAL_KEY_DOWN = Enum.KeyCode.LeftControl,
	BOOST_KEY = Enum.KeyCode.LeftShift,
	LEG_ONE_FROZEN_MULT = 0.55,
	LEG_TWO_FROZEN_MULT = 0.15,
	BATTLE_THRUST_MULT = 0.008,
}

Config.Orientation = {
	RESPONSIVENESS = 12,
	MAX_TORQUE = 40000,
	TILT_MAX_DEG = 22,
	TILT_SPEED_REF = 60,
}

Config.Pose = {
	MODE = "swim",
	SWIM_SPEED = 0.35,
	SWIM_SPEED_HINT = 12,
	BOB_SPEED = 1.6,
	ARM_SWING_DEG = 14,
	LEG_SWING_DEG = 10,
	TORSO_BOB_DEG = 4,
	ARM_SPREAD_DEG = 18,
	MOVE_LEAN_DEG = 26,
	SMOOTHING = 6,
}

Config.Energy = {
	MAX = 100,
	SHOT_COST = 10,
	BOOST_DRAIN_PER_SEC = 35,
	REGEN_PER_SEC = 20,
	MIN_TO_BOOST = 5,
}

Config.Weapon = {
	MAX_RANGE = 500,
	FIRE_COOLDOWN = 0.18,
	SERVER_RANGE_TOLERANCE = 1.15,
	CROSSHAIR_OFFSET_X = 40,
	CROSSHAIR_OFFSET_Y = -80,
	LASER_COLOR = Color3.fromRGB(90, 220, 255),
	LASER_WIDTH = 0.6,
	LASER_LIFETIME = 0.25,
	MUZZLE_FLASH_TIME = 0.08,
	RECOIL_FORCE = 600,
}

Config.Weapons = {
	{ id = "blaster", name = "Blaster", cost = 0, fireCooldown = 0.18, shotCost = 30, laserWidth = 0.6, color = Color3.fromRGB(90, 220, 255) },
	{ id = "rifle", name = "Rifle", cost = 100, fireCooldown = 0.10, shotCost = 30, laserWidth = 0.4, color = Color3.fromRGB(255, 120, 130) },
	{ id = "cannon", name = "Cañon", cost = 250, fireCooldown = 0.55, shotCost = 70, laserWidth = 1.2, color = Color3.fromRGB(255, 200, 80) },
}

Config.LaserColors = {
	{ id = "cyan", name = "Cian", cost = 0, color = Color3.fromRGB(90, 220, 255) },
	{ id = "red", name = "Rojo", cost = 100, color = Color3.fromRGB(255, 90, 90) },
	{ id = "green", name = "Verde", cost = 100, color = Color3.fromRGB(120, 255, 120) },
	{ id = "purple", name = "Morado", cost = 200, color = Color3.fromRGB(190, 120, 255) },
	{ id = "gold", name = "Dorado", cost = 300, color = Color3.fromRGB(255, 215, 90) },
}

Config.StaminaUpgrade = {
	COST_PER_TIER = 50,
	INCREASE = 20,
	MAX_CAP = 300,
}

Config.Workshop = {
	ATTRIBUTE = "isTaller",
	KEY = Enum.KeyCode.F,
	PROMPT_ACTION = "Abrir taller",
	PROMPT_OBJECT = "Taller",
	MAX_DISTANCE = 12,
}

Config.Hook = {
	KEY = Enum.KeyCode.Q,
	MAX_RANGE = 250,
	PULL_FORCE = 1050,
	MAX_PULL_SPEED = 58,
	COOLDOWN = 0.5,
	CABLE_COLOR = Color3.fromRGB(90, 220, 255),
	CABLE_WIDTH = 0.15,
	BREAK_DISTANCE = 2.5,
	DRIFT_RETENTION = 0.88,
}

Config.HookEnergy = {
	MAX = 100,
	USE_COST = 25,
	PULL_DRAIN_PER_SEC = 12,
	REGEN_PER_SEC = 8,
	MIN_TO_USE = 25,
}

Config.HookEnergyUpgrade = {
	COST_PER_TIER = 60,
	INCREASE = 20,
	MAX_CAP = 260,
}

Config.HookRegenUpgrade = {
	COST_PER_TIER = 70,
	INCREASE = 4,
	MAX_CAP = 42,
}

Config.HookTipCosmetics = {
	{ id = "default", name = "Punta Base", cost = 0, color = Color3.fromRGB(90, 220, 255), material = Enum.Material.Neon, size = Vector3.new(0.35, 0.35, 0.9) },
	{ id = "spike", name = "Spike", cost = 120, color = Color3.fromRGB(255, 140, 90), material = Enum.Material.Neon, size = Vector3.new(0.3, 0.3, 1.2) },
	{ id = "heavy", name = "Heavy", cost = 220, color = Color3.fromRGB(255, 210, 60), material = Enum.Material.Metal, size = Vector3.new(0.45, 0.45, 1.0) },
}

Config.HookRopeCosmetics = {
	{ id = "default", name = "Cable Base", cost = 0, color = Color3.fromRGB(90, 220, 255), width0 = 0.35, width1 = 0.22 },
	{ id = "plasma", name = "Plasma", cost = 140, color = Color3.fromRGB(190, 120, 255), width0 = 0.4, width1 = 0.24 },
	{ id = "gold", name = "Dorado", cost = 240, color = Color3.fromRGB(255, 210, 60), width0 = 0.42, width1 = 0.26 },
}

Config.LimbState = {
	OK = "OK",
	FROZEN = "FROZEN",
}

Config.HitResult = {
	NONE = "NONE",
	FREEZE_LEFT_ARM = "FREEZE_LEFT_ARM",
	FREEZE_RIGHT_ARM = "FREEZE_RIGHT_ARM",
	FREEZE_LEFT_LEG = "FREEZE_LEFT_LEG",
	FREEZE_RIGHT_LEG = "FREEZE_RIGHT_LEG",
	ELIMINATE = "ELIMINATE",
}

Config.Limb = {
	LEFT_ARM = "leftArm",
	RIGHT_ARM = "rightArm",
	LEFT_LEG = "leftLeg",
	RIGHT_LEG = "rightLeg",
}

Config.LedColors = {
	ACTIVE = Color3.fromRGB(85, 255, 127),
	DAMAGED = Color3.fromRGB(255, 213, 79),
	FROZEN = Color3.fromRGB(255, 82, 82),
	ICE_TINT = Color3.fromRGB(140, 210, 255)
}

Config.GameMode = {
	NORMAL_GRAVITY = 196.2,
	ZERO_GRAVITY = 0,
	LOBBY = "LOBBY",
	BATTLE = "BATTLE",
	DUEL = "DUEL",
	DEFAULT = "LOBBY",
	MODE_CHANGE_FADE = 1.5,
}

Config.Match = {
	JOIN_WINDOW = 60,
	MATCH_DURATION = 300,
	COUNTDOWN = 60,
	RESET_TIME = 8,
	FINALIZE_TIME = 10,
	MIN_PLAYERS_TO_START = 2,
	OPT_OUT_ATTRIBUTE = "BattleOptOut",
	STATE_LOBBY = "LOBBY",
	STATE_COUNTDOWN = "COUNTDOWN",
	STATE_ACTIVE = "ACTIVE",
	STATE_LOCKED = "LOCKED",
	STATE_ENDING = "ENDING",
	STATE_RESET = "RESET",
	TEAM_AZUL = "Azul",
	TEAM_ROJO = "Rojo",
	PORTAL_OPEN = Color3.fromRGB(85, 255, 127),
	PORTAL_HURRY = Color3.fromRGB(255, 213, 79),
	PORTAL_CLOSED = Color3.fromRGB(255, 82, 82),
	PORTAL_IDLE = Color3.fromRGB(100, 100, 120),
	SPAWN_AZUL_NAME = "SpawnAzul",
	SPAWN_ROJO_NAME = "SpawnRojo",
	ARENA_SPAWN_BLUE_OFFSET = Vector3.new(-30, 0, 0),
	ARENA_SPAWN_RED_OFFSET = Vector3.new(30, 0, 0),
}

Config.Portal = {
	ATTRIBUTE = "isPortal",
	PROMPT_ACTION = "Estado de la arena",
	PROMPT_OBJECT = "Portal de Batalla",
	KEY = Enum.KeyCode.F,
	MAX_DISTANCE = 15,
	TEXT_OPEN = "Proxima partida automatica",
	TEXT_HURRY = "Partida en curso",
	TEXT_CLOSED = "Partida en curso",
	TEXT_WAITING = "Esperando jugadores...",
}

Config.Rank = {
	UPDATE_INTERVAL = 3,
	MAX_PLACES = 3,
	PLACA_NAMES = { "placas1", "placas2", "placas3" },
	CATEGORIES = {
		{ key = "eliminations", title = "CONGELADOS" },
		{ key = "matchesPlayed", title = "PARTIDAS" },
		{ key = "coins", title = "MONEDAS" },
	},
	POINTS_PER_ELIMINATION = 10,
	POINTS_PER_LIMB_FREEZE = 3,
	}

Config.Currency = {
	COIN_NAME = "ZB_Coin",
	COINS_PER_HOUR = 200,
	SPAWN_INTERVAL = 18,
	MAX_CONCURRENT_COINS = 50,
	INITIAL_COINS = 40,
	COIN_SIZE = Vector3.new(1.5, 1.5, 1.5),
	COIN_COLOR = Color3.fromRGB(255, 210, 60),
	COIN_VALUE = 1,
	SPAWN_HEIGHT = 5,
	STARTING_COINS = 500,
	LEADERSTAT = "Monedas",
}

Config.Grab = {
	KEY = Enum.KeyCode.E,
	ATTRIBUTE = "cubrirce",
	HOLD_OFFSET = 3.0,
	ATTACH_TIME = 0.25,
	POSE_ANIM_ID = "rbxassetid://133886935716379",
	POSE_FADE = 0.3,
	LAUNCH_SPEED = 90,
	LAUNCH_UP_BIAS = 0.05,
	MAX_ACTIVATION_DISTANCE = 12,
	HOLD_DURATION = 0,
	ACTION_TEXT = "Cubrirse",
	OBJECT_TEXT = "Cobertura",
	SHIELD_ACTION_TEXT = "Sujetar",
	SHIELD_OBJECT_TEXT = "Escudo",
	DEBUG = true,
}

return Config
