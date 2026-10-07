# ZERO BREACH — Diseño, resumen y arquitectura

> La gravedad desapareció. La estrategia no.

Consolidado el 2026-10-02 a partir de la documentación hasta el 2026-09-30.
Describe el **último estado documentado**, pendiente de contrastar con el Studio
abierto. Normas en [REGLAS](REGLAS.md), pruebas en [CHECKLIST](CHECKLIST.md) e
incidentes en [BUGS](BUGS.md).

## 1. Identidad y ciclo jugable

### UI limpia y assets individuales — 2026-10-06 (vigente)

**Revisión de edición visual del mismo día:** la fuente de arte ahora es
`ReplicatedStorage.UIAssets`, un Folder con `Icons` (27 ImageLabels con Fallback
de Frames) y `Styles` (panel/card/button con UICorner/UIStroke). Reemplazar imágenes
mediante **Properties → Image**, sin editar un catálogo Lua.

`StarterGui.ZB_Intro` existe en ambos Places con Backdrop, Instructions, Title,
Subtitle, Logo, Rows.Row01..Row08 y Continue. El controlador enlaza los objetos
y aplica layout responsive; ya no destruye/recrea el contenido del manual.
Texto/color/esquinas son propiedades editables. Iconos con Image vacío usan la
plantilla compartida; Image explícito en el manual tiene prioridad local.

El catálogo Lua anterior se archivó en `ServerStorage.UIAssets_LegacyConfig`;
la plantilla anterior del Lobby, en `ServerStorage.ZB_Intro_BeforeEditableUI`.
No son fuentes activas de presentación. Mochila/tienda/HUD/actividades aún
construyen controles dinámicos, pero consumen las plantillas de arte/estilo.
Su migración completa y propuestas de monetización están en
[SUGERENCIAS.md](SUGERENCIAS.md); no se crearon ni activaron ventas con Robux.

- Se retira el atlas de la presentación: paneles/tarjetas/botones con esquinas y
  bordes nativos uniformes. Se conserva el PNG como referencia, no como dependencia.
- `ReplicatedStorage.UIAssets.Icons` centraliza 27 ImageLabels. Actualmente
  `Image` vacío usa trazos nativos; un ID individual activa imagen completa con `Fit`.
  Guía de reemplazo, rutas exactas y medidas: [UI_ASSETS.md](UI_ASSETS.md).
- `UITheme` conserva texto original de botones, sin etiquetas espejo; no sustituye
  los callbacks, datos o compras. `AtlasUIController` conserva su nombre histórico.
- Mochila/tienda: escritorio 940×500, horizontal bajo 740×320, vertical estrecho
  370×650 con navegación horizontal y una columna desplazable. Resize diferido
  después del controlador original para evitar que este vuelva a encoger el panel.
- Manual: 700×540, horizontal bajo 740×340, vertical 370×650. Actividades:
  540×420, horizontal bajo 600×330, vertical 370×550. Reorganización al rotar.
- Navegación de mochila/calendario/ayuda oculta mientras hay modal abierto para
  evitar botones de otra capa sobre el contenido. LED nativo, sin recorte del atlas.
- Manual Lobby reutiliza la copia de StarterGui en vez de crear un duplicado
  antes de la copia inicial; `ResetOnSpawn=false`. Match crea el manual si no hay plantilla.
- Cambios compartidos aplicados a ambos Places en Studio. Alcance de las pruebas
  y pendientes en CHECKLIST. No implica publicación ni validación touch real.

### Tema UI del atlas — 2026-10-02 (histórico; arte sustituido el 06/10)

- Atlas aportado: `Atlas HUD neon sci‑fi transparente.png` (1536×1024 original).
  Imagen subida: **`rbxassetid://105755219623216`**. Los recortes se ajustan a
  **2/3** de las coordenadas originales, factor verificado visualmente contra la
  imagen servida. El fondo visible del atlas se integra en paneles oscuros;
  no se presupone que todos sus recortes tengan alfa transparente.
- `ReplicatedStorage.Shared.UITheme` y
  `StarterPlayer.StarterPlayerScripts.AtlasUIController` son idénticos en ambos
  Places. Centralizan recortes, marcos, iconos, botones, hover, tipografía y layout.
- La presentación observa interfaces existentes y sus descendientes nuevos por
  eventos; conserva sus controladores, datos, callbacks y validaciones. No reactiva
  los dashboards antiguos deshabilitados ni consulta remotes de tienda en Match.
- Cobertura: HUD/LED/energía/gancho/congelamiento, mochila y tienda, calendario y
  misiones, carga, logros, resultados, eliminación, HUD VS, salida de batalla,
  instrucciones, placas RankGui, hologramas HoloGui y rótulo del taller.
- Recursos de combate abajo a la izquierda; gancho violeta, arma cian,
  congelamiento azul hielo. Saldo separado de mochila; Match usa InventoryCoins
  cuando no existe leaderstat. Opción de próxima batalla debajo de navegación,
  exclusiva del Lobby. Mira solo en batalla y sin menú abierto.
- Instrucciones: manual persistente, botón CONTINUAR y acceso de ayuda con icono
  de información. Incluye B/X y prompt E actualizado; el antiguo ZB_IntroCloser
  queda deshabilitado en Lobby, sin cierre automático a los 12 segundos.
- Con viewport bajo (<480 px), manual de dos columnas; dashboard compacto
  740×320 con sidebar y tarjetas desplazables; actividades 600×320 con recompensa
  y misiones en columnas. El layout de equipo sigue los cambios de viewport.
- Capas: carga 200, logros 140, manual 130, VS/feedback 120, actividades 115,
  equipo 110 y resultados 105. El backdrop del manual captura input; menús
  grandes actualizan ZB_MenuOpen para bloquear disparo local.
- CombatFeedback mantiene su halo degradado funcional, cámara y contornos; el
  tema no convierte los efectos de daño en una imagen opaca que tape la mira.
- Ajustes de UI asociados: DailyActivities declara refresh antes de callbacks
  de filas; HUD ya no trata countdown competitivo como ronda activa.
- Pruebas y pendientes específicos en CHECKLIST. Ambos Places modificados en
  Studio, sin publicación desde esta sesión.

Shooter competitivo Roblox R15 en gravedad cero, inspirado en la Battle Room de
*Ender's Game*, con identidad y reglamento propios. Dos escuadras de una estación
orbital se desplazan por inercia, usan coberturas flotantes y congelan al rival.

La arena es un cubo espacial sin piso útil: cubos, tubos, anillos, paneles,
contenedores y restos de naves permiten cubrirse, agarrarse y cambiar dirección.
Asalto, defensor, francotirador y movilidad son estilos de juego, no clases
implementadas con armamentos exclusivos. Escudos humanos, emboscadas verticales
y cadenas de impulso forman parte del diseño táctico.

| Formato | Flujo vigente |
|---|---|
| `LIBRE` | Arena local del Lobby; entrada inmediata, sin timer ni límite de bajas |
| `1v1` | Servidor reservado para 2 jugadores |
| `2v2` | Servidor reservado para 4 jugadores |
| `3v3` | Servidor reservado para 6 jugadores |
| `4v4` | Servidor reservado para 8 jugadores |

- Equipos competitivos Azul/Rojo. Cada jugador pertenece como máximo a una cola
  y a un `matchId`. Completar cupo es obligatorio; no mezclar formatos/grupos.
- Cinco stands físicos: `standbasev1..standbasev4` y `standbase5` para Libre.
  Su `frente` tiene `BattleFormat`, ocupación y ProximityPrompt. Usar el mismo
  stand alterna entrada/salida; otro cambia la cola. Rechazar cupo lleno antes
  de mover al jugador. Al salir del stand se lo desplaza 45 studs hacia fuera.
- Cuenta de cola documentada: 10 s al completar grupo; no se cancela en el
  último segundo. Es distinta del countdown de ronda de 5 s.
- VS: mejor de tres, primero a dos victorias. Eliminación de todo el equipo
  decide la ronda. `CombatActive=false` bloquea disparo, gancho y empuje durante
  countdown/transiciones sin perder `BattleParticipant` ni física 0g.
- Los eliminados VS permanecen en el Match hasta la siguiente ronda; su avatar
  real es un único ragdoll flotante, colisionable y agarrable, restaurable.
- En Libre, tras congelamiento total hay tarjeta/ragdoll durante 3 s y respawn
  en un punto seguro de `Arena.FreeSpawns`. Solo salir voluntariamente con `X` devuelve al Lobby.
- Atacante: `CONGELASTE A`; víctima: `TE CONGELO`; avatar y nombre durante 3 s.
  Preferir DisplayName y fallback Name; miniatura `rbxthumb` con reintento de
  GetUserThumbnailAsync. `VersusHud.DisplayOrder=120`.
- Resultado: ganador ve VICTORIA, rival DERROTA. Al cerrar VS, el grupo vuelve
  junto a un servidor reservado del Lobby después del resultado. Se documentan
  hasta tres reintentos de retorno.
- Una salida que deja VS incompleto cancela la partida. La cancelación no debe
  conceder recompensas de partida válida.

## 2. Movimiento, cámara y controles

### Retorno de Libre y apuntado del brazo — Lobby, 2026-10-07

- La salida local busca `Player.RespawnLocation` o un SpawnLocation anidado en
  Workspace; el actual está dentro de `The Spawn Point Light`. Ya no depende de
  que el spawn esté en la raíz. Nuevo evento `LobbyReturnTransition` y controlador
  `LobbyReturnController` confirman el traslado y recuperan locomoción/cámara/cursor.
- El avatar inspeccionado usa AnimationConstraint, no Motor6D. El disparo agrega
  IK analítico en hombro/codo/muñeca derechos después de Animator (PreSimulation),
  sin editar RigAttachments ni parar swim; al soltar restaura la pose animada.
  Rigs legacy conservan IKControl; su objetivo se actualiza en PreAnimation.
- Implementado en Lobby. Prueba de retorno con X y medición de pose moderna en
  Play Solo; sincronización al Match y disparo multijugador pendientes.

Movimiento con `VectorForce`, empuje e inercia, drag suave y clamp de velocidad;
no velocidad fija. El Config inspeccionado usa `BATTLE_THRUST_MULT=0.008` (0.8%
del empuje); las notas anteriores de 4% eran un balance anterior. Gancho, retroceso y
agarre/impulso son la movilidad principal.

| Acción | Control |
|---|---|
| Deriva | WASD |
| Subir/bajar en batalla | R / Ctrl |
| Boost | Shift |
| Gancho | Mantener Q o Espacio; continúa si cualquiera sigue presionada |
| Agarre | Mantener E; soltar impulsa jugador atrás y objeto hacia la cámara |
| Disparo continuo | Click izquierdo |
| Mochila | B o botón |
| Tienda | E en prompt físico del taller |
| Salir de Libre/batalla | X / acción de salida correspondiente |
| Tabla de congelamientos de la batalla | Mantener Tab / botón de tabla |
| Liberar cursor o volver a apuntar | Alt; los menús lo liberan automáticamente |

Espacio conserva el salto normal fuera de batalla. Durante combate de escritorio,
el mouse orienta la cámara sin mantener click derecho; Alt alterna cursor libre.
No disparar ni lanzar gancho sobre mochila, manual, tabla, chat o cursor liberado.

### Controles, avisos y spawn — actualización 2026-10-02

- `BattleCameraController` controla la cámara de tercera persona de escritorio
  durante batalla, con colisión y zoom 4–18; conserva FOV del gancho. CTA visible
  `ALT: LIBERAR CURSOR · B: MOCHILA`. Libera ante menú, tabla, chat, pausa,
  pérdida de foco o eliminación; restaura cámara/mouse al salir. El control
  táctil sigue usando la cámara estándar.
- Salida de batalla: fuerza `MouseBehavior=Default`, cursor visible y
  `ZB_CursorFree=true`, sin recuperar un bloqueo previo. La liberación reacciona
  inmediatamente a BattleParticipant=false y se mantiene en Lobby cuando no
  está presionado RMB; el giro normal de cámara con RMB sigue disponible.
- `CombatFeedback` admite esa cámara Scriptable mediante `ZB_BattleCamera`:
  conserva shake de disparo/eliminación. Q/Espacio usan ContextActionService;
  R es la nueva subida en batalla. Instrucciones actualizadas en ambos Places.
- `EnergyFeedback`: aviso de gancho vacío, gancho cargado, arma sin energía y
  arma cargada. Audio vacío `87519554692663`, listo `81933188942245`, volumen
  0.4, pitch distinto por recurso. Precarga asíncrona, antirrepetición 0.85 s,
  sin sonido por inicialización/mejora de máximo. Carga significa alcanzar 100%
  después de consumir; no suena cada tick de regeneración.
- `GameplaySounds` contiene prefabs EnergyEmpty/EnergyReady en ambos Places.
  BeamOverheated y HookEnergyResult cubren rechazos; el agotamiento final deja
  el atributo de energía en cero en vez de una fracción inutilizable.
- `BattleStats` (ModuleScript de servidor) y `BattleScoreboard` (cliente): atributo
  `BattleFreezes` independiente del ranking persistente. Solo ShootingService
  acredita un cruce confirmado a 100 sobre otro jugador de la misma batalla;
  no cuenta NPC ni autoimpacto. VS suma todas las rondas del match; LIBRE conserva
  el total al reaparecer y lo limpia al salir. Tab muestra jugadores de ese
  matchId, ordenados por congelamientos. No se añadió killfeed ni tabla de muertes.
- `FreeSpawnService`: ocho Parts invisibles/anclados en Arena.FreeSpawns. Comprueba
  espacio corporal con GetPartsInPart (la arena hueca produce falsos positivos
  con bounding boxes), distancia a rivales, exposición y ocupación reciente.
  Penaliza repetir el punto anterior y sincroniza CFrame con el dueño de red
  mediante FreeSpawnTransition. También atiende CharacterAdded de participantes.
- LIBRE mantiene protección 5 s. `SpawnProtectionEndsAt` usa reloj sincronizado
  solo para el HUD; FreezeService conserva validación de servidor. Primer disparo
  válido termina el escudo de aparición y su contador, sin cancelar el orbe azul.
  Un token invalida respawns viejos al salir/reentrar; durante eliminación
  CombatActive=false. Respawn restaura estado, spawn y protección.
- Match: SpawnAzul/Rojo recolocados simétricamente a 90 studs del centro de arena.
  Slots por jugador separados 8 studs; cuatro slots despejados por equipo.
  Arena.SpawnCovers contiene dos modelos estáticos con barrera frontal y alas
  laterales, color de equipo y línea directa entre spawns bloqueada.
- **Palanca de gravedad del Lobby: Próximamente**, por indicación del usuario;
  no se activa ningún cambio de gravedad desde esta actualización.

La documentación antigua indicaba F para portales; las pruebas recientes usan
el prompt E. Confirmar `KeyboardKeyCode` del stand al probar.

### Balance de movilidad documentado

- Boost: multiplicador `2.0`, consumo `24/s`, regeneración general base `18/s`.
- Gancho: `USE_COST=10`, drenaje `18/s`, regeneración `10/s`, mínimo `25`.
- `PULL_FORCE=1000`, `MAX_PULL_SPEED=70`, retención de deriva al soltar `0.98`.
  El clamp suaviza tirón hacia el ancla y amortigua lateral; no frena todo al relanzar.
- Gancho inicia localmente de inmediato y mantiene mientras Q esté presionada,
  incluso al alcanzar el punto. `HookEnergyRequest`/`HookEnergyResult` validan
  energía asincrónicamente en servidor. No volver al InvokeServer por frame.
- `HookSpeedCamera` amplía FOV suavemente hasta 11° mientras tira y lo restaura.
- `Config.Movement.FREEZE_EFFECT_THRESHOLD=90` fue incorporado; posteriormente
  `LEG_ONE_FROZEN_MULT` y `LEG_TWO_FROZEN_MULT` se fijaron en `1.0`. No presentar
  pérdida de empuje por extremidad como mecánica vigente sin revisar Config.
- `Grabbing` coordina movimiento/pose. Agarre usa transición CFrame suave sobre
  root anclado mientras se sujeta; liberación limpia sujeción e impulsa.
- Objetos agarrables: atributo exacto `cubrirce=true`. No permitir autoagarre.
  Match usa `GrabLaunchService`; Lobby tenía la integración en `FloatingRobloxBlocks`.

### Presentación

- `CombatFeedback` controla bordes, sacudida, encuadre y contornos en ambos Places.
- Bordes rojos degradados al aumentar congelamiento confirmado por `StateChanged`.
  La versión documentada tiene shake leve al emitir beam, pulso por `WeaponFired`
  y shake breve una vez al pasar a eliminado.
- Quitar transformación previa antes de actualizar cámara; no alterar FOV del gancho.
- Zoom mínimo en batalla 4 studs; elevar suavemente punto observado hasta 1.8
  studs al acercar cámara. Restaurar zoom original al volver al Lobby.
- Mira elevada a offset vertical `-110 px`; disparo/gancho comparten Config.Weapon.
- Pose de brazo derecho durante beam: IKControl local R15, RightUpperArm a
  RightHand; limpiar al soltar, sobrecalentarse, eliminarse o reaparecer.
- Pose general soporta swim/procedural mediante Config.Pose.MODE y Animator.
  Arma visible soldada a mano derecha con Attachment `Muzzle`.
- VS: Highlight Azul/Rojo tenue con `DepthMode=Occluded`; X roja sobre foto del
  eliminado hasta reset del roster. El HUD conserva mira, energía, energía del
  gancho y estado; los viejos indicadores BI/BD/PI/PD se retiraron.
- LED conceptual: verde activo, ámbar daño parcial, rojo congelado.

**Ajuste aplicado 2026-10-02 en Lobby y Match:** CombatFeedback usa amplitud
beam `0.009` (antes `0.0018`, ×5) y pulse `0.012` (antes `0.003`, ×4).
Halo superior/inferior de 20% de alto y laterales de 16% de ancho, con gradiente
rojo hacia transparencia y centro libre. Intensidad por impacto
`min(0.95, 0.65 + delta/100)`, sin rebajar un pulso activo más fuerte;
retención `0.12 s`, desvanecimiento `1.05/s`. Frames no capturan input.
Reset limpia pulso de daño/eliminación y respawn también el de disparo;
salir de batalla limpia todos. Disparo visual condicionado a batalla activa,
sin menú y sin eliminación. No cambia FOV del gancho ni amplitud de eliminación.
Verificado arranque y creación del overlay en ambos Places; sensación y daño
de extremo a extremo pendientes de prueba manual.

## 3. Disparo, congelamiento y protección

El arma activa es un beam continuo mientras se mantiene click. `pulse` permanece
como alternativa de configuración. El paquete experimental de proyectiles está
deshabilitado y no sustituye al beam.

| Parámetro | Valor documentado |
|---|---|
| `Config.WeaponSystem.MODE` | `beam` |
| `BEAM_TICK_RATE` | `0.1 s` |
| `BEAM_STAMINA_DRAIN_PER_SEC` | `67.5` |
| `BEAM_WAVE_AMPLITUDE` | `4.0` |
| `BEAM_HEAD_MULTIPLIER` | `3` |
| `FreezeProgress.MAX` | `100` |
| Blaster | `18%/tick`; coste pulse `36` |
| Rifle | `14.4%/tick`; coste pulse `30` |
| Cañón | `36%/tick`; coste pulse `82.5` |
| Alcance local/visual | `300 studs` |
| Límite de impacto del servidor | `500 studs` |
| Enfriamiento al agotar energía | `0.5 s` |

- Todos los impactos válidos de torso, extremidades, cabeza y accesorios
  resueltos a torso suman al **mismo porcentaje**. Se conserva al dejar de recibir.
- No congelar brazos/piernas binariamente: `FreezeService.addFreezeProgress`.
  La cabeza multiplica por tres; no hay regla especial de eliminación automática.
  Con Cañón, `36×3=108`, por lo que un tick puede alcanzar el umbral de 100.
- El servidor resuelve raycast desde muzzle hacia objetivo; atraviesa vidrio
  decorativo transparente, respeta cobertura opaca, valida cadencia y energía.
- Validar vectores finitos, origen a no más de 24 studs del root; cortar beam
  sin actualización durante más de 0.5 s.
- No disparar sin BattleParticipant/CombatActive ni localmente con `ZB_MenuOpen`.
  `ShootingController.client` publica `ZB_Firing` para efectos locales.
- `beamBlockedUntil=0` evita math.max(nil) al sobrecalentarse.
- Servidor escribe `LastAttackerUserId` antes de daño; acredita `fullFreeze`
  exclusivamente al cruzar de menos de 100 a 100, no por tick parcial.
- FreezeService soporta personajes con Humanoid, incluidos dummies. Un dummy no
  da monedas; `IsMatchDummy=true` era el contrato para contar NPC de pruebas.
- VFX local/remoto: doble haz, brillo, ondas, luz y partículas de impacto;
  RemoteVfx replica a otros. Audio de disparo documentado: `100617431689640`.

### Escudos y ragdoll

- Libre concede 5 s de protección al entrar/reaparecer: `SpawnShieldUntil` y
  ForceField `ZB_FreeSpawnShield`.
- Primer disparo válido con energía retira ese escudo y sale normalmente. Una
  petición inválida no lo cancela; el escudo azul permanece independiente.
- Orbe azul usa `PowerUpShieldUntil`. FreezeService comprueba ambas protecciones
  con reloj del servidor. Salir limpia atributos y visuales.
- `CombatRagdoll` es ModuleScript autoritativo reversible: deshabilita motores
  corporales y añade BallSocketConstraint/límites/autocolisión. No destruye
  Motor6D originales ni mata Humanoid; protege cuello y compensa gravedad de
  cada ensamblaje cuando corresponde.
- `FreezeService.reset` elimina temporales y restaura motores, colisiones,
  apariencia y movilidad. En VS `preserveEliminatedAvatar` conserva el cuerpo
  real, evitando el antiguo clon físico superpuesto.

## 4. Power-ups, economía e inventario

### Power-ups en Libre y VS

| Color | Efecto |
|---|---|
| Amarillo | Impulso inmediato de velocidad 180 en dirección de movimiento |
| Azul | Escudo visible e inmunidad a congelación durante 5 s |
| Rojo | Congelación total al atravesarlo |

Reaparecen tras 6 s. `Workspace.puntosderefe.Punto1..Punto15`: Parts anclados,
invisibles y con CanCollide/CanTouch/CanQuery=false. Selección por instancia,
evitando dos últimas ubicaciones y puntos ocupados, con fallback seguro. Ocultar
visual hasta ubicarlo. Servidor decide todo; `PowerUpEffect` permite al cliente
dueño de red aplicar inmediatamente el impulso confirmado.

### Persistencia, recompensas y ranking

- DataService: perfil por jugador, carga/normalización, guardado periódico,
  PlayerRemoving y BindToClose. Aplicar atributos disponibles al instante;
  reintentar servicios en segundo plano sin esperas secuenciales largas.
- Guardar monedas, armas, láser equipado, estamina, mejoras de gancho, estadísticas,
  `BattleOptOut`, ownedHookTips/ownedHookRopes y sus selecciones. Reparar propiedad
  para incluir cosmético equipado al normalizar perfiles antiguos.
- `Eliminations` replica total persistente. `CONGELADOS` cuenta solo fullFreeze;
  combina jugadores conectados con ranking histórico. Refresco por evento con
  debounce 0.2 s; consulta histórica OrderedDataStore cada 20 s en segundo plano.
- Placas holográficas: `placas1` CONGELADOS, `placas2` PARTIDAS, `placas3` MONEDAS;
  SurfaceGui Face Right con RankLabel según configuración de escena.
- Monedas Neon (~100/hora documentadas): sin colisión, con toque; ocultación
  local inmediata, entrega validada por servidor. Contar diccionario con pairs.
- Recompensas históricas configuradas: jugar +15, ganar +30 extra, congelar
  extremidad +2, eliminar rival jugador +8; no recompensar NPC ni partida inválida.
  Revalidar rutas vigentes de pago VS y la de extremidades tras migración a porcentaje.
- Daily por día UTC: LastDailyClaimDay, DailyStreak y escalera de siete días;
  política final de pérdida/reinicio de racha y versionado de datos pendientes.
- Misiones: jugar, recoger 25 monedas y reclamar daily. Libre registra playMatches
  al entrar; retorno VS usa MatchId para registrar una sola vez.
- Logro único: reclamar todas las misiones del día, +120 monedas persistentes.
- DailyActivities agrupa calendario/misiones, marca `!` si hay cobro; botones
  Cobrando/Reclamando, bloqueo por jugador y notificación antes del guardado
  asíncrono. Recuperación de botón tras 5 s sin respuesta.
- `FreeFreezeScore`: +1 por congelar, -1 al ser congelado, mínimo 0; conserva
  durante respawn Libre, se limpia al salir; marcador de hombro `❄`.
- QABadgeService: insignia `1747288132288007`, reserva atómica global de 10 UserId
  únicos; no duplicar cupos. Studio `STUDIO_DISABLED`, sin gastar cupos reales.

### Tienda y mochila vigentes

- `EquipmentDashboard` en ambos Places: ScreenGui `ZB_EquipmentDashboard`, base
  940×500 adaptable a ancho/alto, barra lateral, dos columnas y scroll. Avatar,
  saldo, colección, equipado, niveles/precios/límites y feedback de compra.
- Match solo mochila; no esperar remotes ni servicios exclusivos de tienda Lobby.
- Armas y láser no se equipan durante batalla; punta/cuerda sí por ser cosméticos.
- Servidor valida propiedad, perfil cargado, categoría, saldo, límite y GameMode
  **del comprador**. Nunca usar modo global para bloquear el taller de todos.
- Cerrar por X, exterior o Escape si Roblox no consume input; cerrar tienda al
  abandonar Lobby. `ZB_MenuOpen` evita disparos sobre tarjetas.
- Deshabilitados: InventoryDashboard, StoreDashboard, InventoryController y
  WorkshopController.client antiguos. No activarlos junto al controlador nuevo.
- Match obtiene `profile.workshop`, no raíz. Equipar no reaplica todo el perfil
  ni rellena energía. Guardado captura equipados de atributos; `InventoryCoins`
  muestra saldo cuando no existe leaderstat de monedas.

**Recarga rápida permanente:** `Config.StaminaRegenUpgrade`, base 18/s,
+6/s por nivel, 80 monedas, tope 48/s (cinco niveles). Atributo
`StaminaRegenPerSec`, campo raíz persistente `staminaRegenPerSec`.
StaminaService usa tasa autoritativa; perfiles anteriores reciben base, sin
cambiar nombre del DataStore. Es independiente de regeneración del gancho.

Contratos UI:

```text
WorkshopBuy("stamina" | "staminaRegen" | "hookEnergy" | "hookRegen")
WorkshopBuy("weapon" | "color" | "hookTip" | "hookRope", itemId)
WorkshopResult(ok, message)
InventoryRequest / InventoryState / InventoryEquip
```

### Assets reemplazables

- Taller físico: BasePart con `isTaller=true`.
- `ReplicatedStorage.HookCosmeticAssets.HookTips`: Models `default`, `spike`,
  `heavy`, con PrimaryPart, piezas sin colisión; tamaño sugerido 0.9–1.2 de largo
  y 0.3–0.45 de ancho/alto. Orientación eje Z; `TIP_YAW_OFFSET=0` documentado.
  Mantener nombre igual al ID de Config. Punta persistente y visual de lanzamiento;
  no reintroducir el duplicado local eliminado, el visual se replica por servicio.
- Cuerdas: Config.HookRopeCosmetics (`id`, `name`, `color`, `width0`, `width1`),
  sin modelo 3D.
- UI puede reemplazarse por arte propio conservando remotes, estado y cierre.
- Hologramas: Workspace.Hologramas, Neon/SurfaceGui Face Right; HoloLevitation.
- Pose de agarre documentada: `133886935716379`.

## 5. Arquitectura Multi-Place y estructura

### Referencia de edición 3D del Lobby — 2026-10-07

- Escena del Lobby trasladada tomando la superficie central de `piso` como origen:
  antes `(151.171005, 113.937920, -63.318596)`, ahora `(0, 0, 0)`.
- Rotación global de `-7.663°` sobre Y para alinear la estructura principal;
  piso enderezado adicionalmente a Orientation `(0, 0, 0)`. El resto de piezas
  conserva su disposición relativa bajo la transformación global.
- 58 modelos no pertenecientes a personajes con pivotes centrados y ejes mundiales.
  La normalización de pivotes no endereza individualmente la geometría decorativa.
- `ServerStorage.Editor3D`: normalizar pivotes, colocar selección por punto de
  apoyo y enderezar importaciones mediante una pieza de referencia. Uso en REGLAS.
- `Arena.BlockSpawnRegion` sustituye límites mundiales fijos en
  `ServerScriptService.FloatingRobloxBlocks.server`, incluidos slots de fallback.
- Estado anterior de CFrames/PivotOffsets registrado por referencias en
  `ServerStorage.Editor3D_AlignmentBackup`; no es una segunda escena activa.
- Implementado y comprobado en Studio solo en Lobby; sin publicación ni cambio
  de coordenadas del Match.

| Place | ID | Responsabilidad |
|---|---|---|
| Lobby | `125075465377023` | Colas, Libre local, tienda, economía, misiones y daily |
| Match | `108298899371591` | VS reservado, combate, equipos, rondas y resultados |
| Training | Futuro | Tutorial/práctica; campo de tiro aplazado |

Ambos IDs deben pertenecer a la misma Experience. El teleport muestra la carga
normal de Roblox. **VS no clona arenas en Workspace.ActiveArenas**: MatchRegistry,
MatchService antiguo y CompetitiveArena describen el prototipo superado.

### Contrato y seguridad del viaje

```lua
{
    Schema = 1,
    MatchId = "1v1_0001",
    GameMode = "1v1",
    PlayerCount = 2,
    PlayerUserIds = {123, 456},
    Map = "Default",
    RoundTime = 300,
    LobbyPlaceId = 125075465377023,
}
```

- LobbyTeleportService forma grupo completo, marca Teleporting y llama una vez
  `TeleportAsync(MATCH_PLACE_ID, players, options)` con ShouldReserveServer=true
  y SetTeleportData. Un reservado por grupo, no por jugador.
- MatchRuntimeService lee Player:GetJoinData().TeleportData, valida esquema,
  formato, cupo exacto/lista sin duplicados, UserId autorizado y capacidad.
- MatchId se genera en servidor; dinero/progreso no se confían a datos del cliente.
- Ante fallo limpiar Teleporting y recuperar cola/lobby; cierre sin resultado
  devuelve jugadores. Retorno grupal lleva MatchId para misión sin duplicados.
- Play Solo no valida TeleportService real; REJECT_NO_TELEPORT_DATA es esperado
  al abrir Match directamente. HTTP 403 de ese entorno no confirma fallo publicado.

### Gravedad y transición

- Lobby global `Workspace.Gravity=196.2`, también mientras Libre esté activo.
  `ZB_MatchGravityForce` compensa individualmente a participantes. Durante ragdoll
  se desactiva esa fuerza única y se compensa cada ensamblaje.
- Match global 0g; MatchModeBootstrap impide que el antiguo GameModeService lo
  revierta a Lobby. MatchArenaPhysics suelda modelos de cobertura `cubrirce=true`.
- Atributos: GameMode=BATTLE, BattleParticipant=true, MatchId válido;
  CombatActive distingue participación de permiso para actuar.
- GameModeChanged dirigido a cada jugador y BattleTransition sincronizan modo,
  CFrame, velocidades, root liberado y CameraSubject con el cliente dueño de red.
- Salir limpia ZB_ThrustForce/ZB_AlignOrientation/ZB_ThrustAttachment, endereza
  root, velocidades cero, AutoRotate=true, PlatformStand=false, caminar/salto,
  cámara Custom/mouse normal y pose. Reintentos 0g comprueban estado actual.
- CombatFeedback solo habilita orientación en batalla y fuera de ragdoll;
  ZeroGSetup recrea objetos de física al reentrar.

### Inventario de sistemas documentados

| Ubicación | Sistemas |
|---|---|
| ReplicatedStorage.Shared | Config, PlaceConfig |
| ReplicatedStorage.Modules | FreezeMap |
| ServerScriptService, compartidos | PlayerStateService, FreezeService, ShootingService, CombatRagdoll, DataService, StaminaService, RankService, InventoryService, HookEnergyService, HookVisualService, PowerUpService |
| Servidor Lobby | LobbyTeleportService, BattleFormatStations, CurrencyService, WorkshopService, MissionService, DailyRewardService, QABadgeService, FloatingRobloxBlocks |
| Servidor Match | MatchRuntimeService, MatchModeBootstrap, MatchArenaPhysics, GrabLaunchService |
| StarterPlayerScripts, compartidos | MovementController, ShootingController, HookController, HookSpeedCamera, GrabController, GravityController, HudController, RemoteVfx, CombatFeedback, EquipmentDashboard, PowerUpEffects, VersusHud/resultados según Place |
| Cliente Lobby | PortalController, BattleTransitionController, DailyActivities, CoinPickupVisuals, IntroTutorial |
| Cliente Match | ReturnToLobbyController, VersusHud, RoundResultController |
| StarterCharacterScripts | ZeroGSetup, AstronautPose, WeaponSetup |

Los nombres pueden conservar sufijos `.client`/`.server`; verificar ruta exacta
en Studio. El tipo de instancia, no el sufijo, determina ejecución.

Remotes creados por servidor: FireWeapon, StateChanged, WeaponFired,
GameModeChanged, JoinMatchRequest, LeaveMatchRequest, MatchStateChanged,
BattleTransition, FreezeFeedback, PowerUpEffect, HookVisual,
HookEnergyRequest/Result, inventario y WorkshopResult. HookTryConsume y
HookDrainTick aparecen como contratos históricos de compatibilidad; no volver
a usarlos para bloquear input. Preservar BattleOptOutChanged si HUD lo requiere.

Escena: Workspace.geodesica, Arena.SpawnAzul/SpawnRojo (Parts de posición),
SpawnLocation del Lobby fuera de arena, stands, puntosderefe y coberturas unidas.
PowerUpBoost/Shield/Freeze se crean en runtime. No copiar solo MeshParts de un
modelo perdiendo sus uniones.

Paquete experimental conservado: `ReplicatedStorage.ZeroBreachProjectileWeapons`
(`82859396390305`, Enabled=false), runtime ReplicatedStorage.Blaster/utilidades,
ProjectileWeaponService y ProjectileShotReplication deshabilitados; Blaster y
AutoBlaster en `ServerStorage.DisabledProjectileWeapons`, fuera de StarterPack.
Su adaptador validaba spherecasts/cadencia/munición y convertía impactos a Freeze,
no TakeDamage. Audio World/UI mínimo; ejemplos TDM del paquete deshabilitados.

## 6. Diseño futuro: Puerta de Extracción y pendientes

**No implementada como condición vigente.** Cada puerta tiene cuatro sensores
A/B/C/D, ocupados simultáneamente por atacantes vivos del mismo equipo durante
3–5 s continuos (propuesta: CAPTURE_TIME=4, SENSOR_RADIUS=6, SENSOR_COUNT=4).
Si se libera uno, reset a cero. Servidor CaptureService valida ocupación/vida/
equipo/timer; cliente recibe CaptureProgress para iluminación y progreso.
Busca coordinación, no captura solitaria. Falta definir adaptación para 1v1–3v3
y exigir ocupantes distintos para que el objetivo cumpla ese propósito.

También pendientes: ADS manteniendo botón derecho (FOV, sensibilidad y conflicto
con cámara Roblox), anclaje de cuerpo-escudo a espalda del torso sin cancelar giro,
carry por delante con ownership/colisiones/bloqueo de portador y liberación segura,
feedback del portador, onboarding, arenas/cosméticos adicionales y granadas por
definir. Campo de tiro expresamente aplazado. El interruptor de gravedad global
caótico fue una idea antigua, no una característica implementada.
