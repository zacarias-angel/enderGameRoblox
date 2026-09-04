# Progreso Diario — ZERO BREACH

Bitácora de avance por sesión. Entrada más reciente arriba.

---

## Sesion 28

**Objetivo:** endurecer el flujo Lobby -> cola -> Match, pulir combate y
estabilidad de entrada.

### Hecho
- Reemplazada la entrada por portales con los cinco stands fisicos:
  `standbasev1` a `standbasev4` para `1v1` a `4v4` y `standbase5` para
  `LIBRE`.
- Cada `frente` usa un prompt para confirmar entrada o salir. Al entrar en un
  formato competitivo el jugador queda dentro del stand; al salir se mueve 45
  studs fuera de la estructura para evitar una reincorporacion inmediata.
- Las colas competitivas esperan el cupo completo, inician una cuenta de 10
  segundos y no permiten cancelar durante el ultimo segundo.
- `LIBRE` conserva arena local y entrada inmediata; no usa teleport.
- El Match Place cancela una partida y devuelve a los jugadores restantes si
  una salida voluntaria deja el formato por debajo del minimo requerido.
- Desactivado el `MatchService.server` antiguo del Lobby: competia con
  `LobbyTeleportService` por los mismos remotos y podia dejar jugadores con
  atributos de cola/batalla inconsistentes.
- Agregado loop de disparo local rapido en ambos Places:
  `rbxassetid://100617431689640`.
- El Match Place aplica inmediatamente `WeaponId`, `LaserColorId` y
  `LaserColor` desde el perfil aunque no tenga `WorkshopService`.
- Aumentada la ondulacion del beam a `BEAM_WAVE_AMPLITUDE = 4.0` y mejoradas
  las salpicaduras de impacto.
- La punta de gancho ahora usa el rumbo horizontal de la camara, independiente
  de la trayectoria, con `Config.Hook.TIP_YAW_OFFSET = 0`.
- Agregado marcador temporal de modo libre sobre el hombro derecho: `❄ 0`.
  Suma una vez por congelacion total aplicada y resta una vez al ser congelado;
  el valor se conserva al reaparecer en libre y se limpia al salir manualmente.
- Distribuido el escaneo inicial de `GrabController` en bloques de 100
  descendientes y desactivados sus logs de depuracion para evitar tirones al
  entrar.
- Aclarada la iluminacion de Lobby y Match ajustando luz ambiente, exposicion
  y atmosfera.

### Verificado
- Ambos Places cargan sin errores nuevos de scripts en Studio.
- El marcador libre crea correctamente el `BillboardGui` y muestra `❄ 3` en
  una prueba de atributos.
- Los mensajes de `Assistant` y las desconexiones `127.0.0.1` provienen del
  plugin MCP/Roblox Assistant, no del juego.

### Pendiente
- Publicar ambos Places y probar con dos jugadores reales el flujo completo:
  stands, cuenta regresiva, teleport, cancelacion por salida y regreso.
- Confirmar visualmente con dos jugadores que el marcador `❄` cambia una sola
  vez por congelacion total y conserva la penalizacion al reingresar a libre.
- Ajustar iluminacion desde Roblox Player en caso de que la exposicion se vea
  distinta a Studio.

---

## Sesion 27

**Objetivo:** corregir el avance de misiones diarias y la recoleccion de
monedas.

### Hecho
- `LobbyTeleportService` registra `playMatches` al entrar a `LIBRE`.
- `MatchRuntimeService` incluye `MatchId` al devolver un jugador desde el
  Match Place.
- Al regresar al Lobby desde una partida competitiva identificada, se registra
  una vez el progreso de la mision `Jugar 1 partida`.
- `CurrencyService` crea monedas con `CanCollide = false` y `CanTouch = true`:
  no bloquean al personaje y se recogen al contacto.
- Corregido el limite de monedas simultaneas: `activeCoins` es un diccionario,
  por lo que ahora se cuenta con `pairs` en vez de usar el operador `#`.
- Verificado en Play del Lobby: 42 monedas activas, ninguna colisionable y todas
  con toque habilitado.

### Pendiente
- Publicar ambos Places y comprobar en Roblox Player que el retorno de una
  partida VS avanza la mision diaria.
- Probar la recoleccion de monedas con un jugador publicado, incluida la
  actualizacion inmediata del HUD y de la mision `Recolectar 25 monedas`.

---

## Sesion 26

**Objetivo:** corregir cierre de duelo, retorno de eliminados y balance del
rayo.

### Hecho
- Corregido el calculo de ganador de `1v1`: se comprueba el equipo del
  eliminado, no el equipo rival.
- En una eliminacion decisiva, solo los integrantes vivos del equipo ganador
  reciben `ENDING` y el cartel de victoria.
- El eliminado retorna de inmediato al Lobby, incluso si decide la partida.
- Los ganadores retornan despues de tres segundos.
- Agregados hasta tres intentos de retorno con logs `RETURN_START` y
  `RETURN_ERROR`.
- La copia congelada del avatar se mantiene en la arena de VS.
- La copia congelada ahora es física, flotante, colisionable y agarrable como
  cobertura mediante el atributo `cubrirce`.
- Corregido `LIBRE`: eliminar a otro jugador no expulsa al superviviente de
  `BATTLE`; conserva gravedad 0 hasta salir voluntariamente.
- Agregado atributo persistente `Eliminations` para el total de bajas.
- Agregado guardia `syncFreeMode` para mantener 0g, `BATTLE` y físicas del
  superviviente mientras exista al menos un jugador en `LIBRE`.
- Triplicado el daño de congelamiento actual en Lobby y Match:
  Blaster `4.5`, Rifle `3.6`, Cañón `9` por tick.
- Conservado el drenaje del beam en `67.5/s`.
- Actualizados documentos de arquitectura, estructura, resumen, balance,
  checklist y bugs.

### Pendiente
- Verificar en produccion el retorno del perdedor de un `1v1`.
- Verificar que solamente el ganador vea el resultado.
- Verificar un cierre completo de `2v2`.

---

## Sesion 20

**Objetivo:** iniciar el `Match Place` de la Experience.

### Hecho
- Confirmado `MatchPlaceId = 108298899371591`.
- Creado `ReplicatedStorage.Shared.PlaceConfig` con ambos PlaceIds.
- Creado `ServerScriptService.MatchRuntimeService`.
- Agregada lectura y validacion de `TeleportData`.
- Agregados equipos `Azul` y `Rojo` en el Match Place.
- Creada una arena base local con `SpawnAzul` y `SpawnRojo`.
- Agregado retorno preparado mediante `ReturnToLobbyRequest`.
- Play Solo sin `TeleportData` se rechaza de forma segura.

### Pendiente
- Migrar Config, combate, congelamiento, movimiento, HUD y resultados al Match
  Place.
- Crear `LobbyMatchmakingService` con `TeleportAsync` y servidores reservados.
- Probar teleport real desde Roblox Player publicado.

## Sesion 21

**Objetivo:** conectar el Lobby con el Match Place.

### Hecho
- Confirmado que `Workspace.geodesica` y los spawns fueron copiados al Match
  Place.
- Creado `ReplicatedStorage.Shared.PlaceConfig` tambien en el Lobby.
- Creado `ServerScriptService.LobbyTeleportService`.
- Desactivado `ServerScriptService.MatchService.server`, que era el gestor
  local de arenas.
- El nuevo servicio conserva los remotos y la API esperada por los portales.
- Las colas competitivas esperan el grupo completo antes de llamar a
  `TeleportAsync`.
- `LIBRE` envia al jugador individualmente a un servidor reservado.
- Creado `StarterPlayer.StarterPlayerScripts.ReturnToLobbyController.client` en
  el Match Place.
- El Match Place asigna equipos, spawns y gravedad 0 al aceptar `TeleportData`.
- Ambos Places arrancan sin errores del sistema nuevo en Play Solo.

### Limitacion de prueba
- Studio Play Solo no ejecuta un teleport real entre Places. La prueba final
  requiere publicar la Experience y entrar desde Roblox Player.

### Pendiente
- Copiar los scripts de combate al Match Place.
- Copiar los remotos y assets de combate que esos scripts requieren.
- Publicar ambos Places y validar un `1v1` real.

## Sesion 22

**Objetivo:** dejar el Match Place con el conjunto minimo de combate.

### Hecho
- Copiados al Match Place los servicios y controladores de combate.
- Copiados `Config`, `FreezeMap` y `HookCosmeticAssets`.
- Eliminados del Match Place los servicios exclusivos del Lobby:
  matchmaking local, portales, taller, misiones, recompensas, economia y
  decoracion del Lobby.
- Eliminado el `MatchService` antiguo del Match Place.
- Creados los 13 `RemoteEvent` requeridos por los scripts copiados.
- Restaurado `MatchRuntimeService` despues de que la copia masiva lo
  sobrescribiera.
- Verificacion de estructura: arena, runtime, scripts requeridos y remotos
  presentes.

### Pendiente
- Reintentar Play en el Match Place; el controlador de Studio quedo con una
  operacion de inicio pendiente despues de un timeout del MCP.
- Probar teletransportes reales con la Experience publicada.

## Sesion 23

**Objetivo:** conservar `LIBRE` en el Lobby y separar solo los VS.

### Hecho
- `LIBRE` ahora activa la arena normal local `Workspace.Arena`.
- `LIBRE` ya no llama a `TeleportAsync`.
- Salir de `LIBRE` devuelve al jugador al spawn normal del Lobby.
- Los formatos competitivos siguen entrando en cola para teleport reservado.
- Play Solo verifico `LIBRE` local y cola `1v1` sin errores del sistema nuevo.
- El `HTTP 403` observado solo corresponde al intento de teleport desde Studio.

### Pendiente
- Publicar la Experience y probar un `1v1` desde Roblox Player.
- Verificar que el Place secundario este configurado dentro de la misma
  Experience y que los permisos de teleport esten habilitados.

## Sesion 24

**Objetivo:** registrar fallos observados en produccion para continuar el
diagnostico manana.

- Creado `docs/BUGS_PRODUCCION_2026-08-26.md`.
- Registrados problemas de carga lenta en Lobby y Match Place.
- Registrados problemas de gravedad 0, movimiento, hook y bloques que se
  desarman.
- No se modifico el codigo durante esta sesion de diagnostico.

## Sesion 25

**Objetivo:** reparar la caida y la desincronizacion de gravedad en `LIBRE`.

- Confirmado que Lobby y Match Place estan conectados en Studio.
- Corregido `workspace.Gravity` persistido del Lobby a `196.2`.
- Sincronizado `LobbyTeleportService` con `GameModeService` al entrar y salir
  de `LIBRE`.
- Verificado movimiento con teclado en `LIBRE`.
- Verificado que el Lobby vuelve a gravedad normal y sin fuerzas de batalla al
  salir de `LIBRE`.
- Verificado que el Match Place inicia con gravedad 0 y remotos del hook.
- Documentado el diagnostico y las correcciones en el documento de bugs.

---

## Sesion 19

**Objetivo:** cambiar la estrategia de aislamiento de arenas a Places de la
Experience.

### Decision
- El sistema de arenas clonadas dentro de `Workspace` queda como prototipo
  local y no como solucion de produccion.
- La arquitectura oficial sera `Lobby Place` + `Match Place` con
  `TeleportService` y servidores reservados.
- El mismo `Match Place` recibira `GameMode`, `MatchId`, mapa y reglas mediante
  `TeleportData`.

### Documentacion
- Creado `ARQUITECTURA_PLACES_TELEPORT.md`.
- Actualizados `MATCHMAKING_MULTI_INSTANCIA.md`, `RUTA_CHECKLIST.md` y
  `ESTRUCTURA_STUDIO.md`.

### Bloqueo previo a codigo
- Identificados `LobbyPlaceId = 125075465377023` y
  `MatchPlaceId = 108298899371591`.
- Falta confirmar desde Creator Dashboard que ambos Places pertenecen a la
  misma Experience.
- No se debe reemplazar el teleport del Lobby hasta disponer de esos IDs y
  probar el retorno desde Roblox Player.

---

## Sesion 18

**Objetivo:** separar la escena normal de las escenas competitivas y eliminar
la penalizacion de peso por congelacion.

### Hecho
- `LIBRE` usa directamente `Workspace.geodesica`, la escena normal.
- Creada `ServerStorage.ArenaTemplates.CompetitiveArena` con geometria y
  marcadores `SpawnAzul` / `SpawnRojo`.
- Las partidas competitivas clonan su escena y la desplazan para no solaparse
  con `LIBRE` ni con otras partidas.
- Se evita destruir `Workspace.geodesica` al salir de `LIBRE`.
- `LEG_ONE_FROZEN_MULT` y `LEG_TWO_FROZEN_MULT` quedan en `1.0`; la congelacion
  ya no agrega peso ni reduce el movimiento.

### Validado
- `LIBRE` aparece dentro de `geodesica`, con gravedad individual 0g activa.
- Al salir, `geodesica` permanece intacta y no queda arena activa.
- La plantilla competitiva contiene geometria y ambos spawns.

### Pendiente
- Validar con dos clientes reales que dos `1v1` creen escenas separadas y no
  compartan jugadores, combate ni resultados.

---

## Sesion 17

**Objetivo:** retrasar el efecto de peso/perdida de empuje de la congelacion.

### Hecho
- `Config.Movement.FREEZE_EFFECT_THRESHOLD = 90`.
- `MovementController` conserva el estado visual y el progreso de congelacion,
  pero no reduce el empuje por piernas hasta alcanzar el `90%`.
- El valor puede subir a `95` si las pruebas de jugabilidad requieren una
  penalizacion aun mas tardia.

### Validado
- El umbral `90%` carga correctamente en cliente.
- El controlador contiene la validacion de progreso antes de aplicar la
  reduccion de empuje.

---

## Sesion 16

**Objetivo:** corregir la entrada a `LIBRE`, spawn y activacion del personaje.

### Problemas encontrados
- `activate()` no devolvia `true`; la arena se creaba, pero la entrada se
  cancelaba y el jugador regresaba al lobby.
- `MovementController` y `GravityController` sobrescribian `GameMode` en el
  cliente con `LOBBY`.
- `ZeroGSetup` y `AstronautPose` solo reaccionaban al modo global, no al estado
  individual del jugador.

### Hecho
- `MatchService` ahora crea `LIBRE` en estado inicial de lobby y la activa con
  retorno valido antes de insertar jugadores.
- Agregados logs `[ZB Match]` para inicializacion, eventos de entrada,
  activacion, creacion de arena, alta en `LIBRE` y salida.
- Añadida limpieza de referencias huerfanas en `MatchRegistry`.
- `GameMode` queda bajo autoridad del servidor por jugador.
- `ZeroGSetup`, `AstronautPose` y `GravityController` reaccionan a
  `BattleParticipant`.
- La gravedad global permanece normal y la compensacion 0g se aplica por
  personaje.

### Validado
- `LIBRE` crea `Arena_LIBRE_001` y posiciona al jugador dentro de la arena.
- El jugador recibe `GameMode=BATTLE`, `MatchId`, `ZB_MatchGravityForce` y
  `ZB_ThrustForce`.
- La animacion de flotacion, blaster y controlador del gancho cargan.
- Salir devuelve al jugador a `LOBBY` y destruye la arena vacia.
- No quedaron errores de sintaxis en los scripts corregidos.

### Pendiente
- Probar con dos clientes reales dos partidas `1v1` simultaneas.

---

## Sesion 15

**Objetivo:** implementar el primer corte funcional del matchmaking
multi-instancia.

### Hecho
- Creado `ServerScriptService/MatchRegistry`.
- Reescrito `MatchService` para usar colas por formato y partidas con `matchId`.
- Cada partida competitiva crea su propia arena dentro de
  `Workspace.ActiveArenas`.
- `LIBRE` usa una instancia abierta, sin temporizador y con entrada inmediata.
- Los eventos de estado se envian solo a los jugadores de su partida.
- La gravedad del servidor permanece normal; cada jugador en batalla recibe su
  propia compensacion 0g.
- Portales y HUD dejaron de depender de un estado global unico.
- Restaurado `BattleOptOutChanged` para evitar bloqueo del HUD.

### Validado
- `LIBRE` crea `LIBRE_001` y asigna al jugador correctamente.
- La gravedad global permanece en `196.2` y la fuerza 0g se aplica solo al
  personaje de batalla.
- `1v1` deja un jugador en cola `1/2` sin crear arena prematuramente.
- `MatchRegistry` forma dos grupos `1v1` independientes con cuatro jugadores
  de prueba.
- Los cinco portales persistentes cargan sin `BillboardGui` ni errores del
  gestor nuevo.

### Pendiente
- Probar dos clientes reales en Studio para confirmar dos arenas `1v1`
  simultaneas de extremo a extremo.
- Verificar combate, congelamiento, resultados y recompensas aislados por
  `matchId`.
- Reemplazar las ultimas lecturas globales de `GameModeService` en servicios de
  combate si alguna aparece durante la prueba multi-cliente.

---

## Sesion 14

**Objetivo:** reemplazar el gestor global por matchmaking multi-instancia.

### Diagnostico
- El `MatchService` actual mantiene un solo `formatId`, una sola cola, una
  sola arena y un solo temporizador para todo el servidor.
- El segundo jugador no puede entrar a `LIBRE` porque el portal intenta cambiar
  el formato mientras el estado global ya esta `ACTIVE`.
- Los portales se vuelven rojos juntos porque `PortalController` recibe un
  estado global, aunque solo haya una partida activa.
- `1v1` no puede crear partidas simultaneas: no existe un `matchId` por partida.
- `Workspace.Gravity` tambien es global y no puede separar lobby y varias arenas
  simultaneas por modo.

### Decision
- Se abandona el gestor global de rondas.
- Se adopta una cola por formato y un registro de partidas por `matchId`.
- `LIBRE` sera una instancia abierta sin temporizador hasta quedar vacia.
- Cada partida competitiva clonara y administrara su propia arena, equipos,
  estado, resultados y limpieza.

### Documentacion nueva
- `MATCHMAKING_MULTI_INSTANCIA.md` contiene el modelo, contratos, seguridad,
  gravedad y criterios de aceptacion del nuevo sistema.

### Pendiente
- Crear `MatchRegistry`.
- Migrar `MatchService` a colas y partidas independientes.
- Separar gravedad y movimiento por jugador, no por `Workspace.Gravity` global.
- Probar diez partidas `1v1` simultaneas con 20 jugadores.

---

## Sesion 13

**Objetivo:** cerrar el pulido del beam continuo y documentar la correccion.

### Hecho
- `ShootingService`: el porcentaje de congelamiento se replica tras cualquier
  impacto valido, incluidas extremidades.
- `ShootingController.client`: restaurado el VFX completo del beam local con haz
  exterior/interior, ondulacion, brillo y particulas de impacto.
- `ShootingService`: al agotar la estamina envia la señal de sobrecalentamiento y
  corta el beam; el cliente apaga el VFX y bloquea el disparo durante `0.5 s`.
- `ShootingService`: el rayo ignora vidrio decorativo transparente sin ignorar
  coberturas opacas.
- `Config`: consumo del beam ajustado a `30` por segundo para que la energia
  permita una rafaga continua utilizable.

### Pendiente
- Revalidar visualmente en una partida con dos jugadores el VFX y la barra de
  congelamiento sobre una extremidad y sobre el torso.

---

## Sesion 12

**Objetivo:** cerrar recompensas de combate y resultado de ronda con MVP.

### Hecho
- `MatchService`: al terminar la ronda envia `roundSummary` a cliente con ganador y resumen de participantes reales.
- `RankService`: snapshot por ronda para calcular MVP y estadisticas de esa partida.
- `RoundResultController.client`: ahora muestra MVP, eliminaciones, congelaciones y estadisticas locales de la ronda.
- Recompensas activas de combate:
  - jugar partida: `+15` monedas
  - ganar partida: `+30` monedas extra
  - congelar extremidad a un rival jugador: `+2` monedas
  - eliminar a un rival jugador: `+8` monedas
- Las recompensas no se entregan en `Partida invalida`.
- El dummy/NPC de prueba no da monedas.
- Primer logro implementado: `Cumpliste todas las misiones diarias`.
  - se desbloquea al reclamar todas las misiones del dia
  - recompensa unica: `+120` monedas
  - persistencia en `DataService`
  - toast visual en cliente con `AchievementController.client`
- Ajuste de balance del core jugable:
  - boost menos castigado (`drain 24`, regen general `18`)
  - disparo mas usable (`Blaster 24`, `Rifle 20`, `Cañon 55` de costo)
  - gancho mas sostenible (`use 18`, `drain 9`, regen `10`)
  - el gancho vuelve a mantenerse mientras `Q` siga presionada y no se corta solo al llegar al punto
- Pasada de estabilidad en Studio:
  - `ShootingService` reescrito para resolver impacto desde el muzzle hacia el punto apuntado, con debug `[ZB Shoot]` en Studio.
  - `HudController`: contador de countdown/partida ahora se recompone por tiempo local y no depende solo del ultimo evento recibido.
  - `HookController`: el gancho se corta si la tecla real `Q` deja de estar presionada aunque falle `InputEnded`.
- Cambio de sistema de disparo:
  - agregado `Config.WeaponSystem.MODE = "beam" | "pulse"`
  - modo activo actual: `beam`
  - `beam`: mantener click para disparo continuo, consumo continuo de estamina, raycast periodico en servidor y beam local/remoto
  - `pulse`: queda como backup seleccionable por config

### Nota
- El ranking historico ya quedo preparado para top 20, pero su validacion real depende de DataStore fuera de esta sesion de Studio.

---

## Sesion 11

**Objetivo:** cerrar regresiones del fin de ronda despues de la ultima actualizacion.

### Hecho
- `MatchService`: cuando ya solo queda un equipo con vida, la ronda termina de inmediato y anuncia ganador sin esperar `FINALIZE_TIME`.
- `MatchService`: si se agota el tiempo sin ventaja, la ronda ahora cierra como empate en vez de quedar activa indefinidamente.
- `MatchService`: el dummy de prueba ya no debe detectarse por "cualquier NPC"; ahora solo cuenta un `Model` marcado con `IsMatchDummy = true`.
- `ESTRUCTURA_STUDIO.md`: agregado el requisito del atributo `IsMatchDummy` para configurar el dummy correctamente en Studio.

### Pendiente
- Traer y comparar los scripts reales desde Roblox Studio para confirmar que esta correccion tambien quede aplicada en la experiencia publicada.
- Revalidar en Studio el flujo completo: ganador, panel de resultado, retorno al lobby y reset de estados al terminar la ronda.

---

## Sesión 10

**Objetivo:** persistencia real, recompensa diaria, misiones, gancho con energia propia y cierre del backup de codigo.

### Hecho
- `DataService.server`: perfil base, carga/guardado, autosave, `BindToClose` y modo seguro para Studio sin API Services.
- Persistencia conectada a monedas, taller, preferencias, estamina, energia del gancho y estadisticas de ranking.
- `DailyRewardService.server` + `DailyRewardController.client`: recompensa diaria con streak basica y UI en lobby.
- `MissionService.server` + `MissionController.client`: misiones diarias simples para jugar partida, juntar monedas y reclamar daily.
- `RoundResultController.client`: panel de resultado de ronda.
- Energia del gancho separada de la estamina de disparo:
  - `HookEnergyService.server`
  - barra propia en HUD
  - gasto al lanzar
  - gasto continuo mientras arrastra
  - regeneracion mas lenta
- Cosmeticos del gancho:
  - punta 3D reemplazable
  - cuerda configurable por color/grosor
  - compra/equipado en taller
- `WorkshopController.client` rehacido a panel compacto por pestañas: `Base`, `Armas`, `Laser`, `Gancho`.
- `REEMPLAZOS_STUDIO.md`: guia para reconstruir en Studio assets no versionados por git.
- `MatchService`: Play en Studio vuelve a iniciar en lobby; no entra automaticamente a arena.

### Bugs encontrados y correcciones
- `HookController.client`: error por parche parcial (`createTipModel` ausente). Se reescribio limpio.
- `WorkshopController.client`: errores de `refresh()` nil y cierre con `ScreenGui.InputBegan`. Se rehizo el flujo.
- `MatchService`: deteccion de dummy demasiado amplia. Ahora solo debe contar un NPC marcado explicitamente con `IsMatchDummy = true`.
- `FreezeService` / `GravityController`: se reforzo el reset para volver al lobby con color/material/salto normal.

### Pendiente de revalidar en Studio
- Confirmar en una partida completa que:
  - al perder aparece ganador sin esperar al timer,
  - al volver al lobby no queda ningun estado residual de congelado,
  - el ranking persiste y no depende solo de jugadores conectados.

---

## Sesión 9

**Objetivo:** sesión de diseño (sin código). Evaluar "empujar el cuerpo",
mira ADS y gravedad 0 por modos.

### Decisiones

> Esta decision de gravedad global queda superada por la arquitectura
> multi-instancia definida en la Sesion 14.

**Escudo humano (agarre de cuerpos):**
- **NO cancelar el giro** del cuerpo al agarrarlo: que siga girando es parte
  del feel/caos de 0g. Si resulta divertido, se queda (regla del proyecto).
- **SÍ anclaje fijo a la espalda del torso**: al agarrar un cuerpo eliminado,
  el punto de sujeción deja de ser "superficie más cercana"
  (`computeHoldCFrame`) y pasa a ser siempre la **espalda del torso**, para
  que el cuerpo quede entre el portador y el frente (cobertura real).
- **Carry completo (diseño A, llevar el cuerpo por delante):** queda en
  evaluación. Riesgos identificados: network ownership del cuerpo, colisiones
  con el mapa (collision groups), lock de portador en servidor (robo de
  cuerpo), soltar con inercia si eliminan al portador, validación
  anti-exploit de mover Models ajenos. Primero se prueba el anclaje a la
  espalda; si con eso ya es divertido, quizá el carry no haga falta.

**Mira / ADS:**
- Apuntar = **mantener click derecho**: zoom de FOV (lerp), mira en pantalla,
  sensibilidad reducida.
- Pendiente de definir: hipfire con dispersión vs. solo disparo en ADS;
  subir `Responsiveness` de orientación durante ADS; conflicto con la
  rotación de cámara default de Roblox (click derecho).

**Gravedad 0 por modos (decision anterior):**
- La gravedad 0 es del **modo batalla / modo duelo** (la arena). El lobby
  tiene gravedad normal.
- **Interruptor del lobby (opción B — global):** un switch en el lobby pone
  `Workspace.Gravity = 0` **para todos** como evento caótico/divertido. No
  afecta al modo batalla porque ese modo **ya está en 0g**.
- Nota técnica abierta: `Workspace.Gravity` es global; hay que definir cómo
  convive el lobby con gravedad normal y la arena en 0g (modo 0g por
  personaje al entrar a la arena vs. places separados). Se decide cuando se
  implemente el ciclo de modos.

### Próxima sesión (planificado)
- [ ] Implementar **anclaje a la espalda del torso** en `GrabController`
  (cuerpos-escudo; sin cancelar el giro).
- [ ] Prototipo de **ADS con click derecho** (FOV + mira + sensibilidad).
- [ ] Definir estructura lobby / modo batalla para la gravedad por modos +
  interruptor caótico del lobby.
- [ ] Pendientes que siguen de Sesión 8: limpiar `cubrirce` al
  revivir/reset, feedback en HUD del portador, `Config.Grab.DEBUG = false`,
  verificar reducción de empuje por piernas congeladas.

---

## Sesión 8

**Objetivo:** convertir a los cuerpos eliminados en escudos humanos (cobertura móvil).

### Hecho
- `FreezeService.eliminate`: al neutralizar a un personaje (jugador o dummy) le
  asigna el atributo `cubrirce = true`, marcándolo como agarrable.
- `GrabController`: nuevo watcher de personajes (`watchCharacter` /
  `scanCharacters`) que detecta cuando un Model con Humanoid queda marcado
  —incluso si el atributo se pone en runtime al morir— y crea **un solo**
  ProximityPrompt en su torso (`ensureShieldPrompt`). No permite aferrarse a
  uno mismo.
- `Config.Grab`: textos `SHIELD_ACTION_TEXT` ("Sujetar") / `SHIELD_OBJECT_TEXT`
  ("Escudo") para el prompt del cuerpo eliminado.

### Notas
- Reutiliza la mecánica de agarre existente: un vivo se aferra al cuerpo y lo
  usa de cobertura. **Empujar** el cuerpo (escudo activo por delante) es una
  mejora pendiente para una sesión futura.
- Probado con dummy R15: congelar extremidades / eliminar por torso-cabeza ya
  funciona; el prompt de escudo aparece sobre el cuerpo flotante.

### Próxima sesión (planificado)
- [ ] **Empujar el cuerpo (escudo activo):** que el vivo lleve el cuerpo
  congelado por delante y pueda desplazarlo, en vez de solo aferrarse.
  Definir si el empuje es cliente (feel) con validación de estado en servidor.
- [ ] **Limpiar el atributo al revivir/reset:** cuando el personaje respawnee o
  se reinicie la ronda, quitar `cubrirce` para que deje de ser agarrable.
- [ ] **Feedback en HUD del portador:** indicar cuándo estás sujetando un
  escudo (icono/estado).
- [ ] **Poner `Config.Grab.DEBUG = false`** antes de cerrar el pulido.
- [ ] Cerrar checklist MVP: verificar en Studio "reducción de empuje por piernas
  congeladas" (`MovementController` + `LEG_*_FROZEN_MULT`).
- [ ] Tras cerrar MVP, arrancar **Fase 2**: sistema de equipos Azul/Rojo
  (prerequisito de Puerta de Extracción y escudos por equipo).

---

## Sesión 7

**Objetivo:** arreglar temblor/empuje al cubrirse y suavizar el pegado.

### Problema
- Con `AlignPosition` + `MaxForce` alto, el constraint peleaba contra la
  colisión del personaje: temblor y sensación de alejarse del objeto.

### Hecho
- `GrabController` cambia de estrategia: **ancla** el HumanoidRootPart y lo
  posiciona por **CFrame con lerp suave** (easeOutQuad) hacia el punto de
  sujeción, siguiendo al objeto si se mueve. Sin jitter físico.
- Pose de agarre con crossfade (`POSE_FADE`).
- Impulso al soltar mantiene la dirección de cámara.
- **Logs de depuración** `[ZB Grab]` (Config.Grab.DEBUG = true) en: enlace de
  personaje, escaneo de agarrables, creación/activación de prompt, inicio/soltar
  de agarre y pérdida del objeto.
- `Config.Grab`: `ATTACH_TIME`, `POSE_FADE`, `HOLD_OFFSET` ajustable, `DEBUG`.

### Notas
- Si sigue el jitter, subir `ATTACH_TIME` o revisar que el objeto no tenga
  física activa (mejor `Anchored`).
- Poné `DEBUG = false` en producción.

---

## Sesión 6

**Objetivo:** arreglar el agarre y usar ProximityPrompt.

### Problema encontrado
- Error "Infinite yield on PlayerScripts:WaitForChild('Humanoid')": el script
  `GrabController` en Studio tenía pegado por error el código de `AstronautPose`
  (que usa `script.Parent` como personaje y va en StarterCharacterScripts).

### Hecho
- `GrabController` reescrito con **ProximityPrompt**: crea un prompt (tecla E)
  en cada objeto con atributo `cubrirce`, así aparece el hint al acercarte.
  Mantener E = agarrarse (pose), soltar E = impulso hacia la cámara.
- Detecta objetos nuevos en runtime (`workspace.DescendantAdded`).
- `Config.Grab`: parámetros de ProximityPrompt (distancia, textos, hold).

### Recordatorio Studio
- `GrabController` va en **StarterPlayerScripts**.
- `AstronautPose`, `ZeroGSetup`, `WeaponSetup` van en **StarterCharacterScripts**.
- Marcá coberturas con Atributo booleano `cubrirce = true`.

---

## Sesión 5

**Objetivo:** mecánica de "cubrirse / agarrarse" (grab & launch) estilo Ender.

### Hecho
- Nuevo `GrabController` (StarterPlayerScripts): manteniendo **E** cerca de un
  objeto con atributo `cubrirce`, el jugador se aferra a su superficie con una
  pose (`Config.Grab.POSE_ANIM_ID = 133886935716379`), puede mirar con la
  cámara, y al soltar E se **impulsa** hacia donde mira.
  - Anclado con `AlignPosition` a un attachment fijo en el objeto (sigue al
    objeto si se mueve).
  - Expone atributo `Grabbing` en el jugador para coordinar.
- `MovementController`: ignora el empuje mientras `Grabbing` (deja mandar al
  agarre) y mantiene la orientación con la cámara.
- `AstronautPose`: silencia el nado durante `Grabbing` y permite la pista de la
  pose de agarre (no la detiene el guardia).
- `Config.Grab`: parámetros de radio, offset, velocidad de impulso, etc.

### Uso en Studio
- Marcá coberturas con Atributo booleano `cubrirce = true`.

---

## Sesión 4

**Objetivo:** probar la animación oficial de natación como flotación en 0g.

### Hecho
- `AstronautPose` ahora soporta dos modos vía `Config.Pose.MODE`:
  - `"swim"` (por defecto): reproduce las animaciones oficiales de natación de
    Roblox (swim + swimidle) con crossfade por velocidad, vía Animator.
  - `"procedural"`: la pose por código anterior (Motor6D + ondas seno).
- Se reproducen por el `Animator` para funcionar aunque el Humanoid esté en
  estado `Physics`.

### Notas / decisiones
- Para comparar, cambiar `Config.Pose.MODE` entre "swim" y "procedural".
- Si Roblox cambia los IDs oficiales, ajustar `SWIM_ANIM_ID`/`SWIM_IDLE_ANIM_ID`
  en `AstronautPose`.

---

## Sesión 3

**Objetivo:** hacer que el sistema de disparo detecte cualquier personaje con
Humanoid (dummies), no solo jugadores.

### Hecho
- `ShootingService`: `characterFromPart` ahora devuelve el Model del personaje
  (sin exigir Player); `validateAndResolve`/`onFire` operan por personaje.
- `FreezeService`: reescrito **character-centric**. Mantiene estado por
  personaje (`charStates`) para dummies y jugadores. Si el personaje pertenece
  a un Player, además sincroniza con `PlayerStateService` (HUD/LED).
- Resultado: los dummies R15 ahora reciben congelación por extremidad y
  eliminación.

### Próximo
- Probar en Studio disparando al dummy R15.
- Fase 2: equipos, Puerta de Extracción, escudos humanos.

---

## Sesión 2

**Objetivo:** arreglar feel de movimiento, añadir arma visible y láser, y pose
de astronauta.

### Hecho
- **Flotación fluida**: `AlignOrientation` ahora sigue la cámara con
  responsiveness bajo + inclinación (banking) según velocidad; drag reducido y
  rampa de aceleración suave en `MovementController`.
- **Pose astronauta procedural** (`AstronautPose`): desactiva `Animate` y anima
  los Motor6D (hombros/caderas/cintura) con ondas seno; brazos hacia atrás al
  acelerar.
- **Blaster** (`WeaponSetup`): modelo procedural soldado a la mano derecha con
  Attachment `Muzzle`.
- **Láser visible** (`ShootingController`): beam neón desde el muzzle con fade,
  muzzle flash + luz e impacto (chispa).
- `Config` ampliado: bloques `Orientation`, `Pose` y VFX de láser en `Weapon`.

### Próximo
- Probar en Studio y ajustar valores (drag, tilt, amplitudes de pose).
- Fase 2: equipos, Puerta de Extracción, escudos humanos.

### Notas / decisiones
- Animación y arma: **procedural en código** (sin assets subidos).
- Carpetas `RemoteEvents` se auto-crean; solo crear `Shared` y `Modules`.

---

## Sesión 1

**Objetivo:** arranque del proyecto (documentación + MVP núcleo).

### Hecho
- Documentación de diseño completa:
  - `RESUMEN_JUEGO_ACTUALIZADO.md` — diseño general de ZERO BREACH.
  - `sistema_captura_y_economia.md` — Puerta de Extracción (Fase 2).
  - `UI_ASSET_SPEC.md` — HUD, LED y assets.
   - `RUTA_CHECKLIST.md` — roadmap por fases.

### En curso
- MVP: movimiento 0g + disparo + congelación por zona.

### Próximo
- Guía de estructura de carpetas en Studio.
- Scripts: Config, FreezeMap, ZeroGSetup, MovementController.

### Notas / decisiones
- MVP en todos-contra-todos; equipos en Fase 2.
- Personaje R15 estándar.
- Movimiento por inercia (VectorForce), no velocidad fija.
- Controles: WASD + Espacio (subir) + Ctrl (bajar) + Shift (boost) + Click.
