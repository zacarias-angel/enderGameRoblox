# Estructura en Roblox Studio — ZERO BREACH

Crea esta jerarquía en Studio y pega cada script del proyecto (`src/`) en la
ubicación indicada. Sigue `ReglasRoblox.md` §1.

> Esta estructura describe el Place actual de desarrollo. Para produccion, la
> separacion de partidas se hara entre `Lobby Place` y `Match Place` mediante
> `TeleportService`; ver `ARQUITECTURA_PLACES_TELEPORT.md`.

> Produccion actual: `LIBRE` usa el Lobby Place. Los formatos VS usan el Match
> Place, donde `MatchRuntimeService`, `MatchModeBootstrap` y
> `MatchArenaPhysics` controlan resultado, gravedad 0 y coberturas.

```
ReplicatedStorage/
├── Shared/
│   └── Config              (ModuleScript)   <- src/ReplicatedStorage/Shared/Config.lua
├── Modules/
│   └── FreezeMap           (ModuleScript)   <- src/ReplicatedStorage/Modules/FreezeMap.lua
└── RemoteEvents/           (AUTO-CREADA por el servidor al iniciar)
    ├── FireWeapon          (RemoteEvent)     <- auto-creado
    ├── StateChanged        (RemoteEvent)     <- auto-creado
    ├── GameModeChanged     (RemoteEvent)     <- auto-creado
    ├── JoinMatchRequest    (RemoteEvent)     <- auto-creado
    ├── LeaveMatchRequest   (RemoteEvent)     <- auto-creado
    ├── MatchStateChanged   (RemoteEvent)     <- auto-creado
    └── PowerUpEffect       (RemoteEvent)     <- impulso confirmado al cliente

ServerScriptService/
├── PlayerStateService      (Script)          <- src/ServerScriptService/PlayerStateService.server.lua
├── FreezeService           (Script)          <- src/ServerScriptService/FreezeService.server.lua
├── ShootingService         (Script)          <- src/ServerScriptService/ShootingService.server.lua
├── GameModeService         (Script)          <- src/ServerScriptService/GameModeService.server.lua
├── MatchRegistry            (ModuleScript)   <- registro de partidas por `matchId`
├── MatchService            (Script)          <- src/ServerScriptService/MatchService.server.lua
├── RankService             (Script)          <- src/ServerScriptService/RankService.server.lua
├── CurrencyService         (Script)          <- src/ServerScriptService/CurrencyService.server.lua
├── PowerUpService          (Script)          <- presente en Lobby y Match Place
└── HoloLevitation          (Script)          <- src/ServerScriptService/HoloLevitation.server.lua

ServerStorage/
└── ArenaTemplates/
    └── CompetitiveArena    (Model)           <- geometria + SpawnAzul/Rojo

StarterPlayer/
├── StarterPlayerScripts/
│   ├── MovementController   (LocalScript)    <- src/StarterPlayer/StarterPlayerScripts/MovementController.client.lua
│   ├── ShootingController   (LocalScript)    <- src/StarterPlayer/StarterPlayerScripts/ShootingController.client.lua
│   ├── GrabController       (LocalScript)    <- src/StarterPlayer/StarterPlayerScripts/GrabController.client.lua
│   ├── HudController        (LocalScript)    <- src/StarterPlayer/StarterPlayerScripts/HudController.client.lua
│   ├── GravityController    (LocalScript)    <- src/StarterPlayer/StarterPlayerScripts/GravityController.client.lua
│   ├── PortalController     (LocalScript)    <- src/StarterPlayer/StarterPlayerScripts/PortalController.client.lua
│   ├── HookController       (LocalScript)    <- src/StarterPlayer/StarterPlayerScripts/HookController.client.lua
│   ├── DailyActivities      (LocalScript)    <- calendario, daily y misiones (Lobby)
│   ├── CoinPickupVisuals    (LocalScript)    <- ocultacion local inmediata (Lobby)
│   ├── PowerUpEffects       (LocalScript)    <- impulso 0g confirmado por servidor
│   └── IntroTutorial        (LocalScript)    <- src/StarterPlayer/StarterPlayerScripts/IntroTutorial.client.lua
└── StarterCharacterScripts/
    ├── ZeroGSetup           (LocalScript)    <- src/StarterPlayer/StarterCharacterScripts/ZeroGSetup.client.lua
    ├── AstronautPose        (LocalScript)    <- src/StarterPlayer/StarterCharacterScripts/AstronautPose.client.lua
    └── WeaponSetup          (LocalScript)    <- src/StarterPlayer/StarterCharacterScripts/WeaponSetup.client.lua
```

```
Workspace/
├── standbasev1..standbasev4 (stands VS con frente y ProximityPrompt)
├── standbase5               (stand LIBRE)
├── puntosderefe/
│   └── Punto1..Punto15      (Parts anclados e invisibles para power-ups)
├── PowerUpBoost             (cilindro amarillo, runtime)
├── PowerUpShield            (cilindro azul, runtime)
├── PowerUpFreeze            (cilindro rojo, runtime)
├── Arena                   (Folder con marcadores normales)
└── ActiveArenas            (Folder, creada al ejecutar)
```

## Pasos previos en Studio

1. **Gravedad por jugador**: no uses `Workspace.Gravity` para cambiar entre
   lobby y batalla, porque su valor es global y hay varias arenas simultaneas.
   Mantenelo en gravedad normal y aplica compensacion 0g al personaje que tenga
   un `matchId` activo. Las pruebas deben hacerse desde los portales o mediante
   herramientas de test del servidor, no cambiando la gravedad global.
2. **Stands de batalla**: usa `standbasev1` a `standbasev4` para los formatos
   VS y `standbase5` para `LIBRE`. El Part frontal de cada stand lleva
   `BattleFormat`, conteos de cola y el `ProximityPrompt` de entrada/salida.
   `BattleFormatStations` mantiene esos atributos en servidor.
3. **Escenas y spawns**: `Workspace.geodesica` es la escena normal usada por
   `LIBRE`. `Workspace.Arena` conserva los marcadores normales. Para los modos
   competitivos, `ServerStorage.ArenaTemplates.CompetitiveArena` debe contener
   una copia de la geometria de arena y dos Parts (NO SpawnLocation) llamadas
   **SpawnAzul** y **SpawnRojo**. Cada partida clona esa plantilla y la coloca
   separada de las demas.
   Si usás un dummy de prueba dentro de la arena, marcá su `Model` con el
   atributo booleano `IsMatchDummy = true` para que el `MatchService` lo cuente
   como participante. No se cuentan NPCs sin esa marca.
4. **Lobby Spawn**: coloca un **SpawnLocation** en el área del lobby (fuera de
   la arena). Este es el punto donde aparecen los jugadores al unirse al
   servidor. Sin esto, Roblox puede spawnear jugadores en cualquier lado,
   incluso dentro de la arena.
5. **Placas de ranking**: carpeta `placas` en Workspace con 3 Parts estilo
   holograma (Neon, SurfaceGui Face=Right). Cada una muestra una categoría:
   - `placas1` = **CONGELADOS** (más enemigos congelados)
   - `placas2` = **PARTIDAS** (más partidas jugadas)
   - `placas3` = **MONEDAS** (más monedas recolectadas)
6. **Monedas**: el `CurrencyService` spawnea monedas doradas (Neon) en el lobby
   y la arena (~100/hora). Tocar una moneda suma al leaderstat "Monedas".
   Se crean sin colision (`CanCollide = false`) y con toque habilitado
   (`CanTouch = true`), por lo que no deben bloquear al personaje. El limite de
   monedas activas se calcula recorriendo el diccionario interno de monedas.
   Las monedas serviran para comprar/mejorar items.
7. **Power-ups**: `puntosderefe` debe contener exactamente los marcadores
   `Punto1` a `Punto15`. Deben tener `Anchored = true`, `Transparency = 1`,
   `CanCollide = false`, `CanTouch = false` y `CanQuery = false`. El servicio
   crea impulso amarillo, escudo azul de 5 s y congelacion roja. Cada uno evita
   sus dos ultimos puntos y no comparte punto con otro power-up activo.
8. **Hologramas de controles**: crea una carpeta `Hologramas` en Workspace.
   Paneles Neon flotantes con SurfaceGui (Face = Right) mostrando los controles.
   El script `HoloLevitation` los hace levitar suavemente.
9. **Arena de prueba**: crea un `Part` grande hueco o 6 paredes formando un
   cubo alrededor de los spawns. Añade cubos anclados flotando como coberturas.
10. **Objetos agarrables**: a los `Part`/`Model` de cobertura, agregales un
   **Atributo** booleano `cubrirce` = true. El `GrabController` crea un
   **ProximityPrompt** (tecla **E**) en cada uno.
11. **Carpetas manuales**: solo necesitas crear `Shared` y `Modules` a mano en
   ReplicatedStorage. Los RemoteEvents se auto-crean.
12. Pega cada script en su lugar respetando el **nombre exacto** y el **tipo**.

## Orden de prueba

0. Añade `Config` + `FreezeMap` + `GameModeService` + `MatchService` +
   `RankService` en el servidor. El juego arranca en **LOBBY** con gravedad
   normal. Los jugadores caminan normalmente.
1. Verifica los cinco stands permanentes. Al acercarte al frente y confirmar el
   prompt, entras o sales de la cola del formato correspondiente.
2. Añade `GravityController` + `ZeroGSetup` + `MovementController`. En lobby
   caminas normal. Al completar una cola competitiva o entrar a `LIBRE`
   → deberías **volar** con WASD/Espacio/Ctrl y **boost** con Shift.
3. Añade `AstronautPose` + `WeaponSetup` → pose flotante de astronauta y el
   blaster soldado a la mano derecha.
4. Añade los 3 servicios de combate + `ShootingController` → en la partida
   dispara: láser desde el cañón + destello + impacto, congelación/eliminación.
   Los puntos se suman al ranking (placas). En LOBBY no se puede disparar.
5. Añade `GrabController` + un cubo con atributo `cubrirce` → acercate y
   **mantené E** para aferrarte, mirá con la cámara y **soltá E** para
   impulsarte hacia donde mirás.
6. Añade `HudController` → LED, energía y mira.
   En el Match Place, `VersusHud` agrega avatares de ambos equipos, marcador de
   rondas, countdown y feedback de congelamiento.
7. **Placas**: carpeta `placas` → Placa1/Placa2/Placa3 con SurfaceGui +
   TextLabel "RankLabel". El `RankService` actualiza el top 3 cada 3 s.
8. **Flujo completo**: jugador en lobby -> confirma un stand -> cola propia
   del formato → cupo exacto → `matchId` y lista autorizada → servidor Match →
   countdown de 5 s → mejor de 3 → retorno grupal al mismo servidor reservado
   del Lobby. `LIBRE` entra inmediatamente y no tiene temporizador.

> Nota: las extensiones `.client.lua` / `.server.lua` son solo convención de
> nombre para saber el contexto. En Studio, el **tipo** de instancia
> (LocalScript / Script / ModuleScript) es lo que importa.

## Flujo de eliminacion en produccion

- `LobbyTeleportService` maneja la eliminacion de `LIBRE` y devuelve al jugador
  al spawn del Lobby.
- `MatchRuntimeService` maneja eliminaciones competitivas, clona un avatar
  físico con atributo `cubrirce = true` y conserva al eliminado en el servidor
  hasta reiniciar la ronda.
- El estado `ENDING` se envia exclusivamente a los jugadores vivos del equipo
  ganador; el rival recibe `DEFEAT`.
- La primera escuadra que gana dos rondas cierra el match. Tres segundos despues
  del resultado, todos regresan juntos al Lobby mediante teleport grupal.
