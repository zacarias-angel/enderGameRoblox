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

## Diagnostico 2026-09-02

### Causas confirmadas en Match Place

- `GameModeService.server` iniciaba en `LOBBY` y aplicaba gravedad normal
  despues de que `MatchRuntimeService` habia puesto gravedad cero.
- La arena tenia 16 modelos de cobertura con 32 piezas sin uniones.
- El controlador del hook esperaba `HookVisual`, `HookTryConsume` y
  `HookDrainTick`; ahora los servicios correspondientes los crean al iniciar.

### Correcciones aplicadas

- Creado `ServerScriptService.MatchModeBootstrap.server`.
  - Solo actua en el Match Place.
  - Fuerza `workspace.Gravity = 0`.
  - Fuerza el modo `BATTLE` cuando `GameModeService` esta disponible.
- Creado `ServerScriptService.MatchArenaPhysics.server`.
  - Suelda las piezas de cada modelo con atributo `cubrirce = true`.
  - Conserva los modelos como ensamblajes fisicos.

### Verificacion aislada

```text
gravity=0
HookVisual=true
HookTryConsume=true
HookDrainTick=true
coverModels=16
welds=32
```

- `ZeroGSetup.client` crea `ZB_ThrustForce` y `ZB_AlignOrientation` cuando el
  jugador recibe `GameMode = BATTLE` y `BattleParticipant = true`.
- Play Solo del Match Place no puede simular `TeleportData`; el jugador local
  aparece con `REJECT_NO_TELEPORT_DATA`, lo cual es esperado.

### Pendiente

- Volver a abrir el Lobby Place para auditar ambos Places simultaneamente.
- Medir la carga real del Lobby y del Match Place en Roblox Player.
- Confirmar movimiento y hook con un jugador aceptado por teleport real.

## Diagnostico 2026-09-02 - Prueba de LIBRE

### Causa confirmada

- `LobbyTeleportService` cambiaba `GameMode` y `BattleParticipant` para
  `LIBRE`, pero no enviaba `GameModeChanged`.
- `GravityController` conservaba `currentMode = LOBBY` mientras
  `ZeroGSetup.client` creaba las fuerzas de BATTLE.
- El jugador podia terminar con las dos configuraciones de fisica activas:
  `ZB_LobbyGravityForce` y `ZB_ThrustForce`.

### Correccion aplicada

- `LobbyTeleportService` ahora llama a `GameMode.setMode(BATTLE)` al entrar en
  `LIBRE`.
- Al salir de `LIBRE`, llama a `GameMode.setMode(LOBBY)`.
- El cambio replica `GameModeChanged` y sincroniza los controladores del
  cliente.
- Se corrigio `workspace.Gravity` persistido del Lobby a `196.2`.

### Verificacion

```text
LIBRE: gravity=0 mode=BATTLE participant=true
Movimiento: el jugador cambia de posicion al mantener W
Salida: gravity=196.2 mode=LOBBY participant=false
Servidor despues de salir: lobbyForce=false thrust=false
```

### Match Place

- Arranca con `gravity=0`.
- `MatchRuntimeService` imprime `READY`.
- Estan presentes `HookVisual`, `HookTryConsume` y `HookDrainTick`.
- Play Solo sigue usando `REJECT_NO_TELEPORT_DATA`; el comportamiento con
  jugador aceptado debe probarse mediante teleport real.

## Verificacion cruzada 2026-09-02

Se probaron los dos caminos en Studio:

### Lobby / LIBRE

```text
gravity=0
mode=BATTLE
participant=true
```

- El jugador se mueve al mantener `W`.
- Al salir de `LIBRE` vuelve a:

  ```text
  gravity=196.2
  mode=LOBBY
  participant=false
  ```

- El servidor no conserva fuerzas de batalla despues de salir.

### Match Place / BATTLE simulado

```text
gravity=0
mode=BATTLE
participant=true
ZB_ThrustForce=true
ZB_AlignOrientation=true
HookVisual=true
HookTryConsume=true
HookDrainTick=true
```

- La misma configuracion 0g se activa para un jugador con atributos de
  partida, por lo que el problema no queda limitado a `LIBRE`.
- El Match Place inicia con `MatchRuntimeService` y gravedad cero.
- El hook tiene sus remotos y servicios disponibles.

### Advertencia de assets

- Studio muestra fallos de carga para varias animaciones y meshes con
  `serverplaceid=0`. Son advertencias de carga de assets durante Play Solo;
  deben validarse en Roblox Player publicado, pero no explican la gravedad ni
  las fuerzas de movimiento.

### Pendiente de produccion

- Probar un jugador que llegue realmente con `TeleportData`.
- Probar dos jugadores en un `1v1` real.
- Ejecutar una prueba manual del hook apuntando a una superficie valida.

## Diagnostico de eliminaciones 2026-09-02

### Causas confirmadas

- El `FreezeService` llamaba a `onPlayerEliminated`, pero el Match Place no
  tenia un servicio expuesto en `_G.ZB.MatchService`.
- El Match Place no calculaba el equipo ganador despues de una eliminacion.
- El atacante no quedaba registrado en el objetivo, por lo que no se podia
  acreditar la eliminacion.
- En `1v1`, el jugador eliminado no tenia flujo de retorno ni finalizacion de
  partida.

### Correcciones aplicadas

- `MatchRuntimeService` ahora expone `onPlayerEliminated` y
  `finishIfWinner`.
- `ShootingService` registra `LastAttackerUserId` antes de aplicar dano en el
  Lobby y en el Match Place.
- `LIBRE` en el Lobby:
  - devuelve al eliminado al spawn del Lobby;
  - resetea su estado de congelamiento;
  - incrementa `RankService` del atacante.
- `1v1` y equipos en Match:
  - crea `EliminatedAvatars` con una copia anclada del avatar;
  - devuelve el jugador eliminado al Lobby;
  - incrementa la eliminacion del atacante;
  - declara ganador cuando el equipo contrario queda sin jugadores vivos;
  - envia estado `ENDING` y devuelve a los supervivientes despues de 3 s.

### Verificacion tecnica

```text
MatchRuntimeService: eliminationApi=true cloneApi=true rank=true
ShootingService: rastreo LastAttackerUserId presente en ambos Places
Match Place: gravity=0, movimiento 0g y remotos del hook presentes
```

### Pendiente

- Probar eliminacion real de un `1v1` con dos jugadores publicados.
- Probar eliminacion parcial y total de un `2v2`.
- Confirmar que la copia del avatar permanece flotando despues del teleport.
- Confirmar que el ranking persistido refleja la eliminacion al volver al
  Lobby.

## Correccion de resultado 1v1 y balance 2026-09-02

### Causa del resultado faltante

- El Match Place comprobaba por error si el equipo rival estaba vacio despues
  de una eliminacion. En un `1v1`, al eliminar Azul, se debia comprobar que
  Azul quedara sin jugadores y declarar ganador a Rojo.
- El jugador eliminado era enviado inmediatamente al Lobby, antes de que los
  dos clientes pudieran ver la pantalla de resultado.

### Correccion

- `MatchRuntimeService` ahora comprueba el equipo del eliminado.
- En una eliminacion final envia primero:

  ```text
  state=ENDING
  winner=Azul | Rojo
  ```

- `RoundResultController` muestra `VICTORIA` y `Gana el equipo Azul/Rojo`.
- En `1v1`, ambos jugadores permanecen tres segundos para ver el resultado y
  luego ambos vuelven al Lobby.
- En `2v2+`, un eliminado vuelve inmediatamente al Lobby; el resultado solo
  se anuncia cuando su equipo queda sin supervivientes.

### Balance del rayo

Aplicado en Lobby y Match Place:

```text
Beam stamina drain: 45 -> 67.5 (x1.5)
Blaster freeze: 1.0 -> 1.5 (x1.5)
Rifle freeze: 0.8 -> 1.2 (x1.5)
Cannon freeze: 2.0 -> 3.0 (x1.5)
```

Tambien se ajustaron los costos de disparo de cada arma a x1.5 para mantener
la misma relacion de dano y consumo si se usa el modo pulse.

### Verificacion

```text
beamDrain=67.5
freeze=1.5/1.2/3
shotCost=36/30/82.5
winnerUsesEliminatedTeam=true
endingBeforeReturn=true
```

## Correccion de retorno y visibilidad de victoria 2026-09-02

### Incidente en produccion

- En un `1v1` finalizado, solo el ganador regresaba al Lobby.
- El perdedor quedaba junto a su copia congelada en el Match Place.
- Ambos jugadores recibian el cartel de victoria, cuando el perdedor debe salir
  inmediatamente sin verlo.

### Correccion aplicada

- El eliminado inicia retorno al Lobby inmediatamente, tambien si su
  eliminacion decide la partida.
- `MatchRuntimeService` reintenta el retorno hasta tres veces y registra
  `RETURN_START` o `RETURN_ERROR` en Output.
- `ENDING` usa `FireClient` y solo se envia a los jugadores vivos del equipo
  ganador.
- Los ganadores ven `VICTORIA` durante tres segundos y luego regresan al Lobby.
- La copia del avatar ahora es un modelo físico congelado: no esta anclada,
  colisiona, conserva gravedad 0, tiene `cubrirce = true` y se puede agarrar
  como cobertura con `E`.

### Pendiente de prueba

- Confirmar en produccion que el eliminado genera `RETURN_START` y regresa al
  Lobby en un `1v1`.
- Confirmar que solo el ganador ve la pantalla de victoria.

## Correccion de LIBRE y eliminaciones 2026-09-02

### Incidente

- Al eliminar a otro jugador en `LIBRE`, el ganador perdia gravedad 0 y pose de
  flotacion. Esto ocurria incluso si seguia siendo el ultimo jugador activo.

### Causa y correccion

- La eliminacion de cualquier jugador de `LIBRE` cambiaba el modo global del
  Lobby a `LOBBY`.
- `LobbyTeleportService` ahora solo cambia a `LOBBY` cuando no queda ningun
  jugador dentro de `LIBRE`.
- Si queda un superviviente, conserva `GameMode = BATTLE`, gravedad 0, pose y
  movimiento hasta que decida salir.

### Contador de eliminaciones

- `RankService` ahora replica el total con el atributo `Eliminations`.
- Cada eliminacion lo incrementa, y `DataService` lo restaura desde el perfil
  guardado al entrar.
- El atributo queda disponible para HUD, misiones y ranking.

## Refuerzo de estado LIBRE 2026-09-02

### Ajuste adicional

- Agregado `syncFreeMode` a `LobbyTeleportService`.
- Cada `0.25 s`, mientras haya al menos un jugador en `LIBRE`, reafirma:

  ```text
  BattleParticipant = true
  GameMode = BATTLE
  workspace.Gravity = 0 mediante GameModeService
  ```

- Solo se restaura `LOBBY` cuando ya no queda ningun jugador en `LIBRE`.

### Verificacion sostenida en Studio

```text
gravity=0
mode=BATTLE
participant=true
thrust=true
align=true
```

### Pendiente

- Reprobar con dos jugadores publicados: eliminar a uno y confirmar que el
  superviviente conserva movimiento, pose y gravedad 0.

## Correccion de misiones y monedas 2026-09-02

### Incidentes

- La mision diaria `Jugar 1 partida` no recibia progreso al jugar `LIBRE` ni al
  volver de una partida competitiva.
- Las monedas se generaban con colision fisica y el limite de monedas activas
  nunca se aplicaba porque se usaba `#` sobre un diccionario.

### Correccion

- `LobbyTeleportService` registra `playMatches` al entrar en `LIBRE`.
- `MatchRuntimeService` devuelve `MatchId` en `TeleportData`; el Lobby registra
  `playMatches` una vez al recibir ese retorno.
- `CurrencyService` ahora crea monedas con `CanCollide = false` y
  `CanTouch = true`.
- El conteo de monedas activas usa `pairs(activeCoins)` para respetar
  `MAX_CONCURRENT_COINS`.

### Verificacion en Studio

```text
coins=42 collidable=0 touchDisabled=0
```

### Pendiente de produccion

- Confirmar desde Roblox Player que una partida VS retornada avanza la mision.
- Confirmar la recoleccion inmediata y el progreso de `Recolectar 25 monedas`.
