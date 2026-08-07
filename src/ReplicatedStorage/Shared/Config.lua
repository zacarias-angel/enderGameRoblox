-- Tipo: ModuleScript
-- Ubicación: ReplicatedStorage/Shared/Config
-- Contexto: Compartido

--[[
	Config
	Constantes globales de ZERO BREACH. Cliente y servidor leen de aquí.
	No contiene lógica de gameplay; solo valores. Ver ReglasRoblox.md §8.
]]

local Config = {}

-- ===== Física / Movimiento 0g =====
Config.Movement = {
	THRUST_FORCE = 2200,        -- Fuerza base de propulsor (studs/s^2 * masa aprox)
	BOOST_MULTIPLIER = 2.2,     -- Multiplicador de empuje al usar Boost
	MAX_SPEED = 75,             -- Velocidad máxima (studs/s) con clamp
	DRAG = 0.25,                -- Arrastre suave (bajo = más deriva/inercia)
	ACCEL_SMOOTHING = 8,        -- Rampa de aceleración (mayor = respuesta más rápida)
	VERTICAL_KEY_UP = Enum.KeyCode.Space,
	VERTICAL_KEY_DOWN = Enum.KeyCode.LeftControl,
	BOOST_KEY = Enum.KeyCode.LeftShift,
	-- Reducción de empuje por piernas congeladas
	LEG_ONE_FROZEN_MULT = 0.55, -- Una pierna congelada
	LEG_TWO_FROZEN_MULT = 0.15, -- Dos piernas congeladas (arrastre lento)
	-- En modo batalla el WASD es casi imperceptible (el movimiento real es con gancho y recoil)
	BATTLE_THRUST_MULT = 0.008, -- Solo 0.8% del empuje normal con WASD en batalla
}

-- ===== Orientación / Inclinación del cuerpo =====
Config.Orientation = {
	RESPONSIVENESS = 12,        -- Suavidad del giro hacia la cámara (bajo = más suave)
	MAX_TORQUE = 40000,         -- Torque máximo del AlignOrientation
	TILT_MAX_DEG = 22,          -- Inclinación máxima (banking) según velocidad
	TILT_SPEED_REF = 60,        -- Velocidad de referencia para inclinación completa
}

-- ===== Pose procedural de astronauta =====
Config.Pose = {
	-- Modo de animación de flotación:
	--   "swim"       = usa la animación oficial de natación de Roblox (recomendado)
	--   "procedural" = pose generada por código (Motor6D + ondas seno)
	MODE = "swim",
	SWIM_SPEED = 0.35,          -- Velocidad FIJA de las brazadas (baja = lento)
	SWIM_SPEED_HINT = 12,       -- Velocidad simulada para el Humanoid en modo swim
	BOB_SPEED = 1.6,            -- Velocidad del balanceo idle (rad/s)
	ARM_SWING_DEG = 14,         -- Amplitud del balanceo de brazos (idle)
	LEG_SWING_DEG = 10,         -- Amplitud del balanceo de piernas (idle)
	TORSO_BOB_DEG = 4,          -- Balanceo del torso (idle)
	ARM_SPREAD_DEG = 18,        -- Apertura base de brazos (pose flotante)
	MOVE_LEAN_DEG = 26,         -- Inclinación de brazos hacia atrás al acelerar
	SMOOTHING = 6,              -- Suavizado de la interpolación de la pose
}

-- ===== Energía / Boost =====
Config.Energy = {
	MAX = 100,
	BOOST_DRAIN_PER_SEC = 35,   -- Consumo al mantener Boost
	REGEN_PER_SEC = 20,         -- Regeneración cuando no se usa Boost
	MIN_TO_BOOST = 5,           -- Energía mínima para poder activar Boost
}

-- ===== Disparo =====
Config.Weapon = {
	MAX_RANGE = 500,            -- Alcance máximo del pulso (studs)
	FIRE_COOLDOWN = 0.18,       -- Cadencia mínima entre disparos (s)
	SERVER_RANGE_TOLERANCE = 1.15, -- Margen anti-desync en validación servidor
	-- Offset de la mira en pantalla (píxeles) respecto al centro.
	-- Debe coincidir con el usado por el HUD para que el rayo apunte a la mira.
	CROSSHAIR_OFFSET_X = 40,    -- Positivo = a la derecha
	CROSSHAIR_OFFSET_Y = -80,   -- Negativo = hacia arriba
	-- VFX del láser
	LASER_COLOR = Color3.fromRGB(90, 220, 255), -- Color neón del pulso
	LASER_WIDTH = 0.6,          -- Grosor del beam (studs)
	LASER_LIFETIME = 0.25,      -- Duración del beam con fade (s)
	MUZZLE_FLASH_TIME = 0.08,   -- Duración del destello de disparo (s)
	RECOIL_FORCE = 600,         -- Fuerza de retroceso al disparar (empuja fuerte hacia atrás)
}

-- ===== Gancho (grappling hook) =====
Config.Hook = {
	KEY = Enum.KeyCode.Q,               -- Tecla para lanzar/retraer el gancho
	MAX_RANGE = 250,                    -- Alcance máximo del gancho (studs)
	PULL_FORCE = 4200,                  -- Fuerza con la que tira hacia el punto de anclaje
	MAX_PULL_SPEED = 95,                -- Velocidad máxima al ser tirado por el gancho
	COOLDOWN = 0.5,                     -- Tiempo mínimo entre lanzamientos (s)
	CABLE_COLOR = Color3.fromRGB(90, 220, 255),  -- Color del cable
	CABLE_WIDTH = 0.15,                 -- Grosor del cable visual (studs)
	BREAK_DISTANCE = 2.5,               -- Distancia al anclaje a la que se suelta automáticamente
	DRIFT_RETENTION = 0.88,             -- Cuánta inercia se conserva al soltar (0..1)
}

-- ===== Estados de extremidad =====
Config.LimbState = {
	OK = "OK",
	FROZEN = "FROZEN",
}

-- ===== Resultados de impacto =====
Config.HitResult = {
	NONE = "NONE",
	FREEZE_LEFT_ARM = "FREEZE_LEFT_ARM",
	FREEZE_RIGHT_ARM = "FREEZE_RIGHT_ARM",
	FREEZE_LEFT_LEG = "FREEZE_LEFT_LEG",
	FREEZE_RIGHT_LEG = "FREEZE_RIGHT_LEG",
	ELIMINATE = "ELIMINATE",
}

-- ===== Claves de extremidad (estado por jugador) =====
Config.Limb = {
	LEFT_ARM = "leftArm",
	RIGHT_ARM = "rightArm",
	LEFT_LEG = "leftLeg",
	RIGHT_LEG = "rightLeg",
}

-- ===== Colores LED (HUD y traje) =====
Config.LedColors = {
	ACTIVE = Color3.fromRGB(85, 255, 127),   -- 🟢 Activo
	DAMAGED = Color3.fromRGB(255, 213, 79),  -- 🟡 Extremidad dañada
	FROZEN = Color3.fromRGB(255, 82, 82),    -- 🔴 Congelado / eliminado
	ICE_TINT = Color3.fromRGB(140, 210, 255) -- Tinte de extremidad congelada
}

-- ===== Modos de juego / Gravedad =====
Config.GameMode = {
	NORMAL_GRAVITY = 196.2,         -- Gravedad de Roblox por defecto
	ZERO_GRAVITY = 0,               -- Gravedad de la arena (batalla/duelo)
	LOBBY = "LOBBY",                -- Lobby con gravedad normal (correr, caminar)
	BATTLE = "BATTLE",              -- Modo batalla por equipos (0g)
	DUEL = "DUEL",                  -- Modo duelo 1v1 (0g)
	DEFAULT = "LOBBY",              -- Modo por defecto al iniciar el servidor
	MODE_CHANGE_FADE = 1.5,         -- Tiempo de transición entre modos (s)
	-- Para activar/desactivar desde consola o admin:
	-- _G.ZB.GameMode:setMode(Config.GameMode.BATTLE)
	-- _G.ZB.GameMode:setMode(Config.GameMode.LOBBY)
}

-- ===== Partida / Portal / Equipos =====
Config.Match = {
	JOIN_WINDOW = 60,               -- Tiempo desde inicio de partida para poder entrar (s)
	MATCH_DURATION = 300,           -- Duración máxima de partida (s)
	COUNTDOWN = 10,                 -- Cuenta regresiva antes de iniciar partida (s)
	RESET_TIME = 8,                 -- Tiempo entre partidas para volver al lobby (s)
	MIN_PLAYERS_TO_START = 1,       -- Mínimo de jugadores para arrancar (1 = debug)
	-- Estados de la partida (interno del servidor)
	STATE_LOBBY = "LOBBY",          -- No hay partida, aceptando jugadores
	STATE_COUNTDOWN = "COUNTDOWN",  -- Cuenta regresiva antes de empezar
	STATE_ACTIVE = "ACTIVE",        -- Partida en curso, ventana de entrada abierta
	STATE_LOCKED = "LOCKED",        -- Partida en curso, ventana de entrada cerrada
	STATE_ENDING = "ENDING",        -- Partida terminando (resultado)
	STATE_RESET = "RESET",          -- Volviendo al lobby
	-- Equipos
	TEAM_AZUL = "Azul",
	TEAM_ROJO = "Rojo",
	-- Colores de portal según estado
	PORTAL_OPEN = Color3.fromRGB(85, 255, 127),     -- Verde: abierto
	PORTAL_HURRY = Color3.fromRGB(255, 213, 79),    -- Amarillo: partida empezó, apurate
	PORTAL_CLOSED = Color3.fromRGB(255, 82, 82),    -- Rojo: cerrado
	PORTAL_IDLE = Color3.fromRGB(100, 100, 120),    -- Gris: esperando jugadores
	-- Spawns (los busca en Workspace > Arena > SpawnAzul / SpawnRojo)
	-- Si no existen, usa offsets desde el portal.
	SPAWN_AZUL_NAME = "SpawnAzul",
	SPAWN_ROJO_NAME = "SpawnRojo",
	ARENA_SPAWN_BLUE_OFFSET = Vector3.new(-30, 0, 0),
	ARENA_SPAWN_RED_OFFSET = Vector3.new(30, 0, 0),
}

Config.Portal = {
	ATTRIBUTE = "isPortal",         -- Atributo que marca el portal en el workspace
	PROMPT_ACTION = "Entrar a la arena",
	PROMPT_OBJECT = "Portal de Batalla",
	KEY = Enum.KeyCode.F,           -- Tecla para activar el portal
	MAX_DISTANCE = 15,              -- Distancia para mostrar el prompt
	-- Labels según estado
	TEXT_OPEN = "Unirse a la partida",
	TEXT_HURRY = "Partida en curso - Unirse",
	TEXT_CLOSED = "Partida cerrada",
	TEXT_WAITING = "Esperando jugadores...",
}

-- ===== Ranking / Placas =====
Config.Rank = {
	UPDATE_INTERVAL = 3,            -- Cada cuántos segundos se actualizan las placas (s)
	MAX_PLACES = 3,                 -- Número de placas (1º, 2º, 3º)
	-- Nombres de las placas en workspace/placas/
	PLACA_NAMES = { "Placa1", "Placa2", "Placa3" },
	-- Los puntos se ganan así:
	POINTS_PER_ELIMINATION = 10,    -- Por eliminar a un enemigo
	POINTS_PER_LIMB_FREEZE = 3,     -- Por congelar una extremidad
	-- Las placas se encuentran en Workspace > placas > Placa1 / Placa2 / Placa3
	-- Cada placa debe ser un Part con un SurfaceGui (Face = Front) que tenga
	-- un TextLabel llamado "RankLabel". El servicio actualiza el texto.
}

-- ===== Agarre / Cobertura (grab & launch) =====
Config.Grab = {
	KEY = Enum.KeyCode.E,           -- Tecla del ProximityPrompt (mantener)
	ATTRIBUTE = "cubrirce",         -- Atributo que marca objetos agarrables
	HOLD_OFFSET = 3.0,              -- Distancia del centro del cuerpo a la superficie
	ATTACH_TIME = 0.25,             -- Duración del lerp suave al pegarse (s)
	POSE_ANIM_ID = "rbxassetid://133886935716379", -- Pose de agarre
	POSE_FADE = 0.3,                -- Crossfade de la pose de agarre (s)
	LAUNCH_SPEED = 90,              -- Velocidad de impulso al soltar (studs/s)
	LAUNCH_UP_BIAS = 0.05,          -- Sesgo hacia arriba en el impulso (0..1)
	-- ProximityPrompt
	MAX_ACTIVATION_DISTANCE = 12,   -- Distancia a la que aparece el prompt (studs)
	HOLD_DURATION = 0,              -- Tiempo de mantener para activar (0 = inmediato)
	ACTION_TEXT = "Cubrirse",       -- Texto de acción del prompt
	OBJECT_TEXT = "Cobertura",      -- Texto del objeto del prompt
	SHIELD_ACTION_TEXT = "Sujetar", -- Prompt al aferrarse a un cuerpo eliminado
	SHIELD_OBJECT_TEXT = "Escudo",  -- Texto del objeto (compañero neutralizado)
	-- Depuración
	DEBUG = true,                   -- true = imprime logs [ZB Grab] en el Output
}

return Config
