# Estructura en Roblox Studio — ZERO BREACH

Crea esta jerarquía en Studio y pega cada script del proyecto (`src/`) en la
ubicación indicada. Sigue `ReglasRoblox.md` §1.

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
    └── MatchStateChanged   (RemoteEvent)     <- auto-creado

ServerScriptService/
├── PlayerStateService      (Script)          <- src/ServerScriptService/PlayerStateService.server.lua
├── FreezeService           (Script)          <- src/ServerScriptService/FreezeService.server.lua
├── ShootingService         (Script)          <- src/ServerScriptService/ShootingService.server.lua
├── GameModeService         (Script)          <- src/ServerScriptService/GameModeService.server.lua
├── MatchService            (Script)          <- src/ServerScriptService/MatchService.server.lua
└── RankService             (Script)          <- src/ServerScriptService/RankService.server.lua

StarterPlayer/
├── StarterPlayerScripts/
│   ├── MovementController   (LocalScript)    <- src/StarterPlayer/StarterPlayerScripts/MovementController.client.lua
│   ├── ShootingController   (LocalScript)    <- src/StarterPlayer/StarterPlayerScripts/ShootingController.client.lua
│   ├── GrabController       (LocalScript)    <- src/StarterPlayer/StarterPlayerScripts/GrabController.client.lua
│   ├── HudController        (LocalScript)    <- src/StarterPlayer/StarterPlayerScripts/HudController.client.lua
│   ├── GravityController    (LocalScript)    <- src/StarterPlayer/StarterPlayerScripts/GravityController.client.lua
│   ├── PortalController     (LocalScript)    <- src/StarterPlayer/StarterPlayerScripts/PortalController.client.lua
│   └── HookController       (LocalScript)    <- src/StarterPlayer/StarterPlayerScripts/HookController.client.lua
└── StarterCharacterScripts/
    ├── ZeroGSetup           (LocalScript)    <- src/StarterPlayer/StarterCharacterScripts/ZeroGSetup.client.lua
    ├── AstronautPose        (LocalScript)    <- src/StarterPlayer/StarterCharacterScripts/AstronautPose.client.lua
    └── WeaponSetup          (LocalScript)    <- src/StarterPlayer/StarterCharacterScripts/WeaponSetup.client.lua
```

## Pasos previos en Studio

1. **Gravedad automática**: NO pongas `Gravity = 0` manualmente. El
   `GameModeService` gestiona la gravedad según el modo. Por defecto arranca en
   LOBBY (gravedad normal 196.2). El `MatchService` cambia a 0g al iniciar la
   partida y vuelve a normal al terminar. Comandos de consola (servidor):
   ```
   _G.ZB.MatchService.forceStart()            -- Iniciar partida manualmente
   _G.ZB.GameMode.setMode(Config.GameMode.BATTLE)   -- Solo para debug
   _G.ZB.GameMode.setMode(Config.GameMode.LOBBY)
   ```
2. **Portal de batalla**: crea un `Part` en Workspace llamado `"Portal"` (puede
   ser una esfera, arco, lo que quieras). Agrégale un **Atributo** booleano
   `isPortal` = true. El `PortalController` crea automáticamente un
   **ProximityPrompt** (tecla **F**) para que los jugadores entren a la partida.
3. **Arena y spawns**: crea una carpeta `Arena` en Workspace. Dentro, pon 2
   **Parts** (NO SpawnLocation) llamadas **SpawnAzul** y **SpawnRojo**. El
   `MatchService` teleporta a los jugadores a estas posiciones al iniciar la
   partida. Asegurate de que estas Parts NO sean de tipo SpawnLocation, o los
   jugadores spawnearán directo en la arena sin pasar por el lobby.
4. **Lobby Spawn**: coloca un **SpawnLocation** en el área del lobby (fuera de
   la arena). Este es el punto donde aparecen los jugadores al unirse al
   servidor. Sin esto, Roblox puede spawnear jugadores en cualquier lado,
   incluso dentro de la arena.
5. **Placas de ranking**: crea una carpeta `placas` en Workspace. Dentro, añade
   3 Parts llamadas **Placa1**, **Placa2**, **Placa3**. A cada una ponle un
   **SurfaceGui** (Face = Front) con un **TextLabel** llamado `"RankLabel"`.
   El `RankService` actualiza automáticamente estas placas con el top 3.
6. **Arena de prueba**: crea un `Part` grande hueco o 6 paredes formando un
   cubo alrededor de los spawns. Añade cubos anclados flotando como coberturas.
7. **Objetos agarrables**: a los `Part`/`Model` de cobertura, agrégales un
   **Atributo** booleano `cubrirce` = true. El `GrabController` crea un
   **ProximityPrompt** (tecla **E**) en cada uno.
8. **Carpetas manuales**: solo necesitas crear `Shared` y `Modules` a mano en
   ReplicatedStorage. Los RemoteEvents se auto-crean.
9. Pega cada script en su lugar respetando el **nombre exacto** y el **tipo**.

## Orden de prueba

0. Añade `Config` + `FreezeMap` + `GameModeService` + `MatchService` +
   `RankService` en el servidor. El juego arranca en **LOBBY** con gravedad
   normal. Los jugadores caminan normalmente.
1. Añade `PortalController` → crea un `Part` "Portal" con atributo `isPortal`
   en Workspace. Al acercarte y pulsar **F**, te unís a la cola de partida.
2. Añade `GravityController` + `ZeroGSetup` + `MovementController`. En lobby
   caminas normal. Al iniciar partida (vía portal o `_G.ZB.MatchService.forceStart()`)
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
7. **Placas**: carpeta `placas` → Placa1/Placa2/Placa3 con SurfaceGui +
   TextLabel "RankLabel". El `RankService` actualiza el top 3 cada 3 s.
8. **Flujo completo**: jugador en lobby → pulsa F en el portal → cuenta
   regresiva → asignación de equipo balanceado → teleport a la arena → 0g
   activo → combate → 1 min de ventana para entrar → luego cerrado →
   aniquilación o tiempo → ganador → vuelta al lobby.

> Nota: las extensiones `.client.lua` / `.server.lua` son solo convención de
> nombre para saber el contexto. En Studio, el **tipo** de instancia
> (LocalScript / Script / ModuleScript) es lo que importa.
