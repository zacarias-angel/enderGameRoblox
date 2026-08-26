# Bugs de Produccion - 2026-08-26

## Estado

Incidente detectado durante la prueba en produccion despues de separar el
Lobby Place y el Match Place.

No corregir directamente sin reproducir primero. El objetivo de este

## Resumen

- La entrada al Lobby tarda demasiado.
- La entrada al Match Place tambien tarda demasiado.
- En el Lobby la experiencia de gravedad normal no esta funcionando como
  antes.
- En el Match Place no se activa correctamente la gravedad cero.
- El jugador no puede moverse en el Match Place.
- El hook no funciona.
- Los bloques se desarman o pierden su estructura fisica.
- La experiencia general quedo rota despues de la migracion a Places.

## Bug 1: Entrada lenta al Lobby

**Prioridad:** Critica

### Sintoma

Al entrar a la experiencia principal, la carga del Lobby tarda demasiado.

### Lugar

Lobby Place `125075465377023`.

### Revisar

- Tiempo hasta `PlayerAdded` y `CharacterAdded`.
- `DataService` y cualquier `DataStore` que bloquee el arranque.
- `LoadingScreen.client` y scripts que esperan remotos o instancias.
- Modelos y cantidad de partes cargadas al iniciar.
- Scripts copiados accidentalmente del Match Place al Lobby.
- Errores y warnings del servidor antes de que aparezca el personaje.

## Bug 2: Entrada lenta al Match Place

**Prioridad:** Critica

### Sintoma

El jugador tarda demasiado en llegar o comenzar a jugar en el Place de VS.

### Lugar

Match Place `108298899371591`.

### Revisar

- Tiempo de `TeleportAsync` y tiempo de carga del modelo `geodesica`.
- Scripts que ejecutan `WaitForChild` indefinidamente.
- Errores de `MatchRuntimeService` antes de `READY`.
- Scripts de Lobby que hayan quedado en el Match Place.
- Scripts de economia, misiones o recompensas que no corresponden al Match.
- Cantidad de partes y modelos no anclados de la arena.

## Bug 3: Gravedad cero no funciona

**Prioridad:** Critica

### Sintoma

En el Match Place el jugador no recibe correctamente la configuracion 0g.
El movimiento, las fuerzas y la orientacion no funcionan.

### Revisar

- Confirmar que `MatchRuntimeService` imprime:

  ```text
  [ZB MatchRuntime] READY place=108298899371591
  ```

- Confirmar que el servidor establece `workspace.Gravity = 0`.
- Confirmar que el jugador recibe estos atributos:

  ```text
  GameMode = BATTLE
  BattleParticipant = true
  MatchId = <valor>
  ```

- Confirmar que `ZeroGSetup.client` se ejecuta despues de recibir esos
  atributos.
- Confirmar que `MovementController.client` crea `ZB_ThrustForce` y
  `ZB_AlignOrientation`.
- Confirmar que existe `GameModeChanged` si los controladores esperan ese
  remoto.
- Revisar errores de `Config`, `GameModeService` y `ZeroGSetup`.
- Revisar si algun script posterior vuelve a establecer gravedad normal.

## Bug 4: El jugador no puede moverse

**Prioridad:** Critica

### Sintoma

En el Match Place el personaje aparece, pero no puede moverse.

### Revisar

- Estado del `Humanoid` despues de ejecutar `ZeroGSetup.client`.
- Existencia de `HumanoidRootPart`.
- Existencia y fuerza de `ZB_ThrustForce`.
- `WalkSpeed`, `JumpPower` y `PlatformStand`.
- Si `BattleParticipant` se establece demasiado tarde.
- Si `MovementController.client` esta esperando `StateChanged`.
- Si algun servicio de congelamiento marca al jugador como eliminado.
- Diferencias entre el rig del Lobby y el rig del Match Place.

## Bug 5: Hook no funciona

**Prioridad:** Alta

### Sintoma

El jugador puede entrar a la partida, pero el hook no dispara, no conecta o
no tira del jugador/objeto.

### Revisar

- Que `HookController.client` este en:

  ```text
  StarterPlayer.StarterPlayerScripts
  ```

- Que `HookEnergyService.server` y `HookVisualService.server` esten activos.
- Que existan `HookRequest` y `HookVfx` en:

  ```text
  ReplicatedStorage.RemoteEvents
  ```

- Que exista `HookCosmeticAssets.HookTips`.
- Que `Config.Hook` y `Config.HookEnergy` tengan todos sus campos.
- Revisar errores de `WaitForChild` del hook.
- Revisar si `BattleParticipant` o `GameMode` impiden dispararlo.

## Bug 6: Bloques se desarman

**Prioridad:** Alta

### Sintoma

Los bloques, modelos o elementos de la arena pierden su estructura fisica,
se separan o se comportan como piezas sueltas.

### Revisar

- Si los modelos fueron copiados completos o solo sus `MeshPart`.
- Si los modelos tienen `WeldConstraint`, `Weld` o uniones originales.
- Propiedades `Anchored`, `CanCollide`, `Massless` y `AssemblyRootPart`.
- Si algun script de movimiento/gravedad modifica todas las partes del
  Workspace.
- Si `FloatingRobloxBlocks` fue copiado al Match Place por error.
- Si `geodesica` contiene partes sueltas intencionalmente.
- Si la arena necesita estar anclada en el Match Place.

## Bug 7: Lobby y Match mezclados

**Prioridad:** Critica

### Revisar que el Lobby tenga solamente

- `LobbyTeleportService`.
- `BattleFormatStations`.
- Portales y `PortalController.client`.
- Servicios de economia, taller, misiones y recompensas.
- Gravedad normal.

### Revisar que el Match tenga solamente

- `MatchRuntimeService`.
- Servicios de combate, estado, congelamiento, disparos y hook.
- Controladores 0g, movimiento, disparo, hook, HUD y resultados.
- Arena `geodesica`, spawns y objetos de combate.
- Gravedad cero.

## Plan de diagnostico para manana

1. Abrir Output limpio en el Lobby y registrar desde el primer frame.
2. Abrir Output limpio en el Match Place y buscar el primer error, no el
   ultimo warning.
3. Confirmar atributos del jugador en ambos Places.
4. Confirmar gravedad y fuerzas fisicas con una inspeccion del personaje.
5. Probar movimiento sin hook.
6. Probar hook despues de validar movimiento.
7. Revisar un bloque de la arena y sus uniones.
8. Medir tiempos de carga antes de optimizar.
9. Probar primero en Studio cada Place por separado.
10. Probar teleport real solo despues de que ambos Places funcionen aislados.

## Informacion de la prueba

- Lobby Place: `125075465377023`.
- Match Place: `108298899371591`.
- El error `HTTP 403` de teleports en Play Solo no debe usarse como prueba de
  produccion.
- La prueba de produccion reportada aqui si debe investigarse como fallo
  real de arquitectura, carga o scripts.
