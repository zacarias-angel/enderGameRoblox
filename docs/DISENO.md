# ZERO BREACH — Diseño, resumen y arquitectura

> La gravedad desapareció. La estrategia no.

Consolidado el 2026-10-02. **Contrastado con ambos Studios el 2026-10-26**.
El corte siguiente prevalece sobre las descripciones históricas de abajo.
Normas en [REGLAS](REGLAS.md), pruebas en [CHECKLIST](CHECKLIST.md) e
incidentes en [BUGS](BUGS.md).

## 0. Estado real tras los cambios del equipo — 2026-10-26

### Integración posterior: nuevo arte del HUD (26/10)

Por pedido del usuario, ambos Places usan Barra arma.png/Barra gancho.png y el
marco HUD GENERAL BATALLA para los accesos, estado, monedas y encabezado VS.
Nuevo módulo compartido `BattleHudArtwork` y plantillas editables en
`ReplicatedStorage.UIAssets.BattleHud`. Reutiliza los Fill de HudController y los
botones originales; no cambia balance, energía, pagos ni autoridad de combate.
**Revisión por captura del usuario (B27):** se retira la segmentación del marco
general que producía uniones visibles. La fuente vigente es el PNG original
completo reducido a 1024×341 (`138592401278319`), en un ImageLabel Fit por control;
texto/iconos se encajan en el área real y los accesos se adaptan al alto de pantalla.
MobileHudLayout/AtlasUIController ceden esa presentación al nuevo módulo.
Los paneles interiores de mochila/tienda y calendario no se migraron ni se
sincronizaron a Match por este cambio de HUD. B24 sigue abierto.

QA: consumo real de arma/gancho en Libre y salida por botón; imágenes cargadas en
ambos, layout iPhone 17 Pro, respawn único. Match visualizado con estado local de
prueba (no VS real), Fill de 0/25/50/100 %. Corregida una realimentación de Position
entre layouts y la suposición de Symbol/Brand en el logo compacto del Lobby.
Rutas, IDs, respaldo y alcance exacto en UI_ASSETS; ejecución en CHECKLIST.
Ambos Places en Edit/default, sin publicar. La auditoría siguiente es el corte previo
a esta integración y conserva su evidencia original.

Auditoría de lectura en **Edit**: fuentes, jerarquías, atributos, assets, Lighting
y Output de ambos Places; captura del Lobby con su mochila de edición visible.
Lobby: `PlaceVersion=784`; Match: `PlaceVersion=205`; ambos pertenecen a
`GameId=10498600200`, propietario User `4575572102`. Son versiones informadas por
el DataModel abierto: no acreditan que los cambios Edit estén publicados.
No se ejecutó Play ni se verificaron teleports, compras o persistencia en esta revisión.
No se puede atribuir autor/fecha de cada cambio solo por inspeccionar el estado actual;
las fechas de los respaldos son referencias, no un historial de Team Create.

### Paridad actual: no copiar un Place entero sobre el otro

| Sistema | Lobby | Match | Adaptación pendiente |
|---|---|---|---|
| Mochila/tienda | Plantilla completa `EditableEquipment=true`, panel 1360×720, módulo `Shared.EquipmentDashboardLayout` | Acceso en StarterGui y panel construido por el controlador anterior; sin ese módulo | Migrar controlador + plantilla + layout como conjunto, preservando mochila sin ventas en Match |
| Imágenes de armas | Tres IDs asignados en `UIAssets.WeaponImages` | Las tres propiedades `Image` vacías | Asignar los mismos IDs; verificar tarjetas en Play |
| Ofertas de armas | `WeaponOffers`, Cañón pase 2039918698, Rifle sin pase; `AutoGrantPasses=true` | `WeaponOffers` ausente; datos de pases conservados por DataService | Decidir/sincronizar catálogo de presentación; Match sigue sin servicio de ventas |
| Empuñadura Rifle | `Templates.rifle.Handle.Grip.Position=(0,-0.2,0.9)` | `(0,0,0)` | Llevar el ajuste de Grip y comprobar montaje; escala 1.15 presente en ambos |
| Ranking del mundo | `Workspace.Rankings3D` y puente autoritativo | Sin paneles 3D | Sistema de exhibición exclusivo del Lobby; estadísticas VS continúan en Match |
| Interacción de botones | Controlador ampliado con sonido, configuración `Motion.Hover/Click` | Controlador anterior, solo escalado; sin esos Sounds | Sincronizar si se quiere el mismo feedback; no basta copiar IDs |
| Presentación de combate | Música, animaciones congeladas, impulso del ragdoll, lanzamiento visual del gancho | Mismos componentes compartidos | Revalidar en Player después de integrar cambios |
| Power-ups y aviso | Vida/respawn 10 s y aviso de escudo azul | Misma política y controlador de aviso | Probar ciclo temporal, inmunidad y limpieza en cada modo |

### Mochila editable: nueva fuente visual del Lobby

`StarterGui.ZB_EquipmentDashboard` contiene ahora `Panel`, `Backdrop`,
`OpenInventory`, `OpenWeaponOffer` y `Templates.CatalogCard`. El Panel contiene
`Sidebar` (Logo, PlayerProfile, Navigation y Wallet), `Header`, `Close`, `Summary`
(Card1..Card4), `Cards`, `Status`, Artwork, Interior y ResponsiveScale.
El controlador rellena el resumen y clona CatalogCard para el catálogo; no reconstruye
la estructura estática. Oculta Panel/Backdrop antes de esperar remotes al arrancar.
Los datos visibles en Edit son de muestra; no prueban saldo ni propiedad reales.

- `EditableEquipment=true` hace que AtlasUIController omita su layout/estilizado
  antiguo. El atributo heredado `PanelFrameSkin` ya no selecciona el arte de este Panel.
- El arte local de Panel/Sidebar/tarjetas usa `92094831612893`; no el MarcoHUD
  `106613197873068` de `UIAssets.Skins`. Guía de rutas y excepciones en UI_ASSETS.
- EquipmentDashboardLayout conserva la composición Edit en escritorio y adapta a
  980×450 en horizontal bajo (`ViewportSize.Y<500`) o 400×710 en vertical estrecho
  (`X<600` y `Y>X`). Ajusta UIScale con `ViewportMargin=18`, scroll y tarjetas.
- Compra/equipado siguen enviándose a los servicios existentes. Match todavía no
  usa este contrato; copiar solo el controlador produciría esperas por Panel/layout.
- Respaldo Lobby `ServerStorage.ZB_EditableEquipmentBackup_20261023`.

### Rankings 3D: presentación nueva con estadísticas existentes

`Workspace.Rankings3D` reemplaza la referencia física a `Workspace.placas`
(ausente en ambos Places). Hay tres Models: Monedas, Congelados y Victorias,
cada uno con Panel y ProyectorHolografico. `Panel.RankingUI` es SurfaceGui
Face Front, CanvasSize 840×990 sobre panel 21×24.75 studs: proporción coincidente.

Flujo: `RankService.server` combina estadísticas actuales e histórico existente →
`Rankings3DAPI.SetRanking` → `Rankings3DServer` actualiza Fila1..Fila4.Jugador/Valor.
Mapa: coins→Monedas, limbsFrozen→Congelados, vsWins→Victorias. No crea otro store,
no convierte rondas en victorias y no sustituye BattleScoreboard/Tab.

- API solo de servidor: SetRanking, SetRankings, GetRanking, ClearRanking, Changed.
  Valida listas/nombres/valores finitos, conserva el orden recibido y copia hasta
  cuatro filas. Es memoria de presentación; la persistencia sigue en RankService/DataService.
- Prioridad del renderer: API → Config de ejemplo si DemoMode → leaderstats.
  `DemoMode=false`, `RefreshSeconds=5`; el puente publica antes de buscar las placas
  antiguas, por lo que no depende de que existan. El histórico se refresca cada 20 s
  y los cambios locales conservan debounce .2 s.
- StatName de fallback: Coins/Frozen/WinsVS. No equivale automáticamente a los
  atributos RankFreeFreezes/VSWins ni a leaderstats.Monedas: mantener el puente API.
- `Rankings3DEjemplo` está deshabilitado. Los nombres/puntuaciones de Config y las
  filas visibles en Edit son ejemplos; no son evidencia de clasificación real.
- **Diferencia estructural:** Congelados tiene marco y cuatro filas, pero carece de
  Cabecera y Estado, presentes en Monedas/Victorias. Registrar/restaurar presentación
  si corresponde; el renderer no crea esos elementos (BUGS B25).
- `HologramMotion` activo anima los paneles mediante TweenService. Ajustes en
  `Rankings3D.HologramConfig` Attributes: Movimiento_Activado=true, Amplitud=.55,
  Semiciclo=3, VariacionEntrePaneles=.15; Particulas_Activadas=true, 45/s por panel;
  Proyeccion_Activada=true, TransparenciaBase=.94. Se reaplican al cambiar atributos.
  Esto es independiente del antiguo Workspace.Hologramas, que sigue ausente.
- Respaldo del puente: `ServerStorage.ZB_Rankings3DBridgeBackup_20261023` en Lobby.

### Presentación y power-ups compartidos encontrados en ambos Places

- Controles móviles vigentes: **tres botones**, Fire rojo 112/96 px, Hook verde y
  Grab azul 80/68 px. Grab inicia agarre y cambia a IMPULSO; Hook es independiente.
  TouchAimSensitivity=.005625; cámara sobre hombro 2.6 lateral/.8 alto y
  MobileNavY=16. Las descripciones de dos/cuatro botones de abajo son históricas.
- `ReplicatedStorage.PresentationSettings` (Configuration): HookLaunchDuration=.18,
  FreezeKickSpeed=12, FreezeLiftSpeed=3, FreezeAngularImpulsePerMass=2,
  MusicFadeDuration=.6. Se editan como Attributes; no son estadísticas de arma.
- HookVisualService anima el destino visual desde el jugador hasta el ancla mediante
  Tween de .18 s (acotado .05–.35); usa ZB_Launching y conserva/limpia tween y listeners.
  No reemplaza la tracción local inmediata ni sus remotes de energía.
- `Shared.AnimationFreeze` pausa pistas guardando Speed; `FrozenAnimationController`
  observa personajes propios/remotos por ZB_Ragdoll. AstronautPose pausa swim durante
  ese estado. CombatRagdoll pausa/restaura pistas e invalida tareas con ZB_RagdollEpoch.
  A los .12 s aplica un impulso único alejándose del atacante (fallback hacia atrás),
  elevación y giro configurados; no es un cambio del umbral de congelamiento.
- `ZoneMusicController` selecciona música por BattleParticipant individual en Lobby
  y por Place en Match. `SoundService.ZB_Music.Lobby`: `134069101231435`, Volume=.25;
  Battle: `101240840700787`, Volume=.28; ambos Looped. Crossfade de .6 s y pausa
  de la pista saliente. No se certifican carga/permisos/mezcla en Player por leer los IDs.
- PowerUpService usa **LIFETIME=10 y RESPAWN_TIME=10**: sin recoger, al expirar se
  recoloca inmediatamente; recogido, queda oculto 10 s antes de reaparecer. Timers
  por generación evitan que callbacks viejos reaparezcan otra instancia. Expone
  PowerUpAvailable, SpawnGeneration, SpawnedAt, SpawnExpiresAt y NextSpawnAt.
- `PowerUpShield.grant` valida participante/combate/avatar vivo y concede 5 s de
  ForceField azul. PowerUpShieldUntil usa os.clock de servidor; PowerUpShieldEndsAt
  usa GetServerTimeNow para UI. Una renovación invalida el temporizador anterior;
  salida, cambio de personaje, eliminación o fin de combate limpian ambos relojes.
- SpawnProtectionController ahora presenta **ambos escudos**, priorizando el azul
  si coinciden. `Notice.ProtectionType` distingue PowerUp/Spawn; Banner.PowerUpMessage
  cambia el mensaje del azul a ESCUDO ACTIVO. Disparar cancela solo el de aparición.
  El texto antiguo «solo escudo de aparición» de abajo quedó sustituido.
- Respaldos compartidos encontrados: ZB_FeedbackPolishBackup_20261016 y
  ZB_PowerUpLifetimeShieldBackup_20261019. Su presencia no acredita QA publicada.

### Escena y rutas que ya cambiaron

- Piso Lobby conserva Position=(0,-.5,0), Orientation=(0,0,0), Size=(382,1,344).
  Spawn real en `The Spawn Point Light.SpawnLocation`, aproximadamente (-56.626,1,65.246).
- Vitrinas de armas movidas: Bases aproximadas de basearma1/2/3 en
  (-43.707,1.195,-128.871), (-9.336,1.195,-131.944), (-78.395,.997,-129.985).
  WeaponOfferPrompt ahora está bajo **Base**, no OfferPlate. Mover el conjunto.
- No existe basegancho1; basegancho2 ofrece default y basegancho3 heavy mediante
  HookOfferAttachment.HookOfferPrompt. Hay ocho FreeSpawns y quince puntosderefe.
- Match conserva dos SpawnCovers, cinco piezas ancladas por escudo en Edit. Su
  gravedad guardada es 196.2; el Script **MatchModeBootstrap > server** fuerza 0
  después de 1 s y en Heartbeat. No confundir valor Edit con 0g verificada en Play.
- Hay rutas ambiguas en notación de puntos: en Lobby, FloatingRobloxBlocks y
  BattleFormatStations son Folders con Script `server`; en Match, MatchModeBootstrap
  y MatchArenaPhysics tienen la misma estructura. `DataService` es un Folder vacío
  en ambos, distinto del Script literal `DataService.server`. Usar Explorer/clase
  o acceso por corchetes según el nombre real al editar; no inferir rutas de GetFullName.

Pendientes de integración y aceptación: CHECKLIST, corte 26/10. Se conserva la
confirmación previa del usuario sobre VS/datos; no se atribuye esa prueba a esta
revisión ni se extiende automáticamente al nuevo aspecto de mochila/rankings.

## 1. Identidad y ciclo jugable

### Manual de inicio con placa completa — 2026-10-19 (Studio)

- `ZB_Intro` usa `FullArtIntro=true`: `Instructions.Artwork` muestra una placa
  1024×768 con marco, títulos e instrucciones incorporados; `Continue` es un
  ImageButton 1024×341 con el botón entero, superpuesto al borde inferior de la
  placa en la posición definida en Edit.
- `Logo`, `Title`, `Subtitle` y `Rows` quedan ocultos para no duplicar texto. El
  skin 9-slice anterior no se aplica al panel; `Skins.intro` se conserva como
  alternativa si se vuelve a un marco sin texto.
- `AtlasUIController` escala en conjunto el panel, la placa y el botón tomando
  como referencia su posición/tamaño en StarterGui; `IntroMaxWidth` limita el
  ancho. Así el botón conserva la colocación de Edit (superpuesto al borde
  inferior) en cualquier viewport. Si falta el arte, restaura el manual clásico
  en vez de quedar en blanco. `LoadingScreen.client` enciende el manual al
  terminar la carga.
- Aplicado en ambos Places; QA de escritorio, iPhone 17 Pro y Match con clic real
  en ENTENDIDO. Sin publicación. Guía y especificación en UI_ASSETS 0.9.

### Presentación de láseres y protección — 2026-10-19 (Studio)

- Los cinco colores de láser tienen imagen propia en `UIAssets.LaserImages`,
  incluido rojo `71886236630717`. Tienda/mochila consumen la plantilla de su color;
  no cambia el catálogo económico ni la lógica del disparo.
- El aviso de escudo de aparición es `StarterGui.ZB_SpawnProtection`: imagen
  `116492173393960` con texto incorporado, Fit y contador independiente. Nuevo
  SpawnProtectionController común a ambos Places, enlazado a `SpawnProtectionEndsAt`.
- Se muestra solo con plazo activo y participante, fuera de menús/eliminación;
  desaparece al expirar o recibir plazo cero. El estado de partida cede esa fila.
  No representa el escudo power-up azul ni concede protección al entrar en Match.
- FreeSpawnTransitionController de Lobby conserva su traslado local, sin construir
  un segundo aviso. Duración y cancelación por disparo siguen en servidor sin cambios.
- Edición/IDs, evidencia y límites de QA en UI_ASSETS 0.8 y CHECKLIST.

### Controles móviles vigentes — 2026-10-19 (Studio)

- Dos botones de combate: **DISPARAR** (112/96 px) y **GANCHO** (96/84 px).
  SUBIR/BAJAR retirados por pedido del usuario. Mantener fire/hook conserva su
  intención mientras el dedo arrastra fuera del botón; levantarlo la termina.
- La cámara orbital de combate ahora admite touch: arrastrar el dedo de fire/hook
  o un dedo adicional en la zona derecha libre. Joystick izquierdo y menús no
  reclaman arrastre de cámara. `Shared.MobileAimInput` acumula delta por dedo;
  BattleCameraController consume el delta sin depender del estado de disparo.
- Al agarrarse mediante un prompt, el botón GANCHO pasa a **IMPULSO**. Tocarlo
  libera y aplica la física existente: jugador en dirección inversa a la cámara,
  velocidad 90, e impacto hacia la cobertura por la ruta de servidor existente.
  La cancelación por estado/objetivo/salida no genera impulso.
- `LocalCombatInput.launch` transporta solo intención local. Daño/energía/impacto
  siguen validados por sus servicios. Los gestos se cancelan con menú, rotación,
  pérdida de foco, eliminación o salida. No se amplía soporte de gameplay vertical.
- Plantilla e imágenes en StarterGui/UIAssets; tamaños, márgenes y sensibilidad
  editables como Attributes de `ZB_MobileControls` (UI_ASSETS 0.1).
- Implementación igual en ambos Places. QA de simulador/controlada documentada en
  CHECKLIST/B21/B22; teléfono físico y multijugador publicado siguen pendientes.

### Apariencia de congelamiento — 2026-10-19 (vigente en Studio)

- El cuerpo progresa de azul claro RGB(140,210,255) a azul hielo RGB(75,180,255),
  con `Enum.Material.Ice`. Al 100 % se aplica a todas las partes corporales
  directas R15/R6, salvo HumanoidRootPart; armas/accesorios anidados se conservan.
- Valores en `ReplicatedStorage.Shared.Config.FreezeAppearance` (`PARTIAL_COLOR`,
  `FROZEN_COLOR`, `MATERIAL`), consumidos por `FreezeService.server` de ambos Places.
  La apariencia corporal ya no depende del rojo `LedColors.FROZEN` del HUD.
- Se conserva el guardado/restauración de color y material por pieza. No cambia
  daño, umbral, estado de eliminación, agarre ni ciclo de ronda/respawn.
- QA controlada R15 de parcial/total/reset y segundo ciclo en ambos Places;
  aceptación publicada multijugador pendiente. Respaldo
  `ServerStorage.ZB_IceAppearanceBackup_20261019` por Place.

### Ajustes tras QA publicada — 2026-10-09 (vigente en Studio)

- **Ranking:** primera placa CONGELADOS MODO LIBRE (`limbsFrozen`, valores anteriores
  conservados; nuevas acreditaciones solo Libre). Segunda VICTORIAS VS (`vsWins`,
  nuevo store v1). Tercera MONEDAS. Tab muestra congelamientos de la batalla actual
  en cualquier modo y es independiente de estas placas persistentes.
- VS completo suma una `matchesPlayed` a cada participante, una victoria al equipo
  ganador y premios configurados +15/+30 extra ganar. `completedVs` deduplica 64
  IDs recientes; MatchId generado por GUID. Anulación no entrega resultado completo.
  Progreso VS de misión se registra en Match al finalizar, no al regresar al Lobby.
  Libre mantiene el progreso de misión por entrada, sin producir victorias VS.
- **Retorno:** priorizar el mismo servidor de origen público (`OriginLobbyJobId`)
  para reunirse con quienes permanecieron. Origen reservado requiere acceso conocido.
  Si falta/falla la ruta de origen, un único reservado alternativo para el grupo.
  Cancelación voluntaria incluye al solicitante; fallo asíncrono reutiliza destino.
- Guardar perfiles antes de ambos viajes y serializar escrituras locales. Snapshots
  de estadísticas en atributos evitan ceros por orden de PlayerRemoving. No cambia
  nombre del DataStore ni implementa bloqueo de sesión distribuido completo.
- **Agarre:** CancelGrabForTarget y ZB_GrabEpoch invalidan sujeción antes de reset/
  retirada de avatar. Cancelar no impulsa. Prompts de cuerpo se retiran al restaurar;
  prompts generales quedan desactivados fuera de combate. El propietario del ciclo
  de vida se resuelve también para piezas de arma/accesorio anidadas.
- **Audio:** ZeroGFootsteps administra Running por estado 0g de cada avatar/gravedad
  global; restaura caminata en Lobby, sin intervención en audio de combate.
- Nuevos módulos de servidor: LobbyReturnRoute (Match), VsResultService (Match),
  DailyMissionCatalog (ambos). Nuevos campos persistentes: stats.vsWins/completedVs.
  Match conserva achievements del perfil al normalizar. Histórico anterior no se
  convierte automáticamente a victorias ni se puede separar por modo sin evidencias.
- Respaldo por Place `ServerStorage.ZB_ProductionFixBackup_20261009`: restaurar
  las fuentes originales con Play detenido; retirar/deshabilitar ZeroGFootsteps
  para revertir audio. Al revertir MissionService a la copia, deja de requerir
  DailyMissionCatalog; al revertir Runtime deja de requerir módulos nuevos de Match.
  Datos ya guardados no se revierten automáticamente al restaurar scripts.
- QA publicada previa reportada por usuario valida calendario, arma/apuntado remoto
  y flujo principal Libre/VS. Correcciones de esta sección todavía sin publicación;
  pruebas de revalidación de tres cuentas en CHECKLIST/B13–B16.

### Historial diario y colores del calendario — 2026-10-16 (vigente)

Desde el 16/10 el calendario distingue el estado de cada fecha con color:

- **Verde** = recompensa diaria cobrada ese día; **rojo** = día pasado sin cobrar;
  **ámbar** = disponible hoy; **gris** = sin datos/futuro; borde cian = hoy,
  dorado = selección. Colores editables como Attributes del ScreenGui
  (`ClaimedDayColor`, `MissedDayColor`, `AvailableDayColor`, `FutureDayColor`,
  `UnknownDayColor`); cada `Calendar.Grid.SlotNN` expone `ClaimState`/`ConfirmedClaim`.
- **Historial real:** `daily` en el perfil guarda `claimedDays` (mapa fecha→importe),
  `historyStartDay` y `historyVersion=1`. Un nuevo ModuleScript de servidor
  `ServerScriptService.DailyClaimHistory` normaliza y registra; `DailyRewardService`
  acredita saldo y fecha en la misma mutación de perfil (anti-doble-cobro), y
  `DataService` de ambos Places preserva el historial al cargar/capturar/guardar.
- **Límite deliberado:** los días anteriores al inicio del registro quedan como
  “sin datos”; **no** se pintan de rojo para no inventar historial. El perfil antiguo
  solo migra su último cobro confirmado. Match guarda el mismo historial para no
  perderlo en el teleport, aunque el calendario se muestra solo en Lobby.
- Implementación y QA detalladas en UI_ASSETS 0.7 y BUGS B20. No cambia el cobro,
  la racha ni la renovación 00:00 UTC; solo añade el historial y su presentación.

### Calendario mensual de actividades — 2026-10-09 (vigente)

En Lobby, `StarterGui.ZB_DailyActivities` es ahora una **plantilla completa**,
no una pantalla reconstruida por código. Estructura y edición en UI_ASSETS.
DailyActivities enlaza 42 slots de seis semanas, navegación de mes, hoy UTC,
selección de fecha, recompensa y tres misiones. `CalendarDates` en Shared calcula
fechas gregorianas reales (incluidos años bisiestos), comenzando semanas en lunes.

- Día/cobros/progreso son los del servidor. Solo hoy permite reclamar; otros días
  muestran futuro o ausencia de registro. Se marca únicamente el último cobro
  confirmado con `lastClaimDay`/`lastClaimReward` del snapshot, sin inventar historia.
- Mantiene reinicio B11 a 00:00 UTC, solicitud de snapshots y temporizador a 1 Hz.
  Al cambiar el día sigue hoy si el usuario estaba viéndolo; preserva navegación
  manual si estaba consultando otra fecha.
- Desktop: dos columnas, calendario y detalles. Teléfono vertical: una columna
  con scroll para consultar calendario y misiones sin reducir todo a miniatura.
  Panel modal/backdrop, cierre por botón/exterior, persistencia al respawn.
- `EditableCalendar=true` evita que AtlasUIController remaquete/estilice esta
  plantilla con el layout antiguo. Las guardas se sincronizan también en Match,
  pero calendario/misiones continúan siendo exclusivos del Lobby.
- Nombres de filas Row01..Row03 y slots Slot01..Slot42 estables; el controlador
  actualiza datos y estados. Configuración visual estática se edita en Properties.
- Respaldo Lobby `ServerStorage.ZB_CalendarBackup_20261009`: fuentes anteriores
  de DailyActivities, AtlasUIController y DailyRewardService, deshabilitadas.
  Para revertir con Play detenido, restaurar esas fuentes y retirar/archivar la
  nueva plantilla StarterGui para evitar duplicación con el constructor anterior.
  CalendarDates puede conservarse fuera de uso. Sin cambio de DataStore ni esquema de historial.

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
  junto al Lobby de origen después del resultado, con destino alternativo común
  si esa ruta no está disponible. Reintentos conservan la ruta; detalles B15.
- Una salida que deja VS incompleto cancela la partida. La cancelación no debe
  conceder recompensas de partida válida.

## 2. Movimiento, cámara y controles

### Arma base SDR-Mk2 y visual replicado — 2026-10-09 (vigente)

- El modelo que estaba en `Workspace.SDR-Mk2` se adapta como plantilla
  `ReplicatedStorage.WeaponAssets.Templates.blaster` en **Lobby y Match**.
  Nombre visible `SDR-Mk2`; ID persistente `blaster` conservado. Es el arma base
  gratuita existente: no cambia daño, cadencia, energía, precio ni propiedades guardadas.
- La plantilla tiene 18 BaseParts (14 MeshParts), `PrimaryPart=Handle`,
  `Handle.Grip` y `Barrel.Muzzle`. Pivote en Handle, frente hacia -Z; dimensiones
  aproximadas 0.463×1.430×2.240 studs. Se conservan mallas y colores originales.
- Nuevo **Script** `ServerScriptService.WeaponVisualService` monta el modelo en
  RightHand y lo replica. Clon en personaje mantiene el nombre técnico `ZB_Blaster`
  y la ruta `Barrel.Muzzle`, que ya usan cliente y servidor de disparo.
- `StarterPlayer.StarterCharacterScripts["WeaponSetup.client"]` queda deshabilitado:
  ya no construye las tres primitivas del prototipo. El servidor antes no tenía arma
  ni Muzzle y usaba root como origen alternativo; ahora dispone de la boca real.
- Uniones internas y montaje mediante WeldConstraint, sin Motor6D de arma que el
  ragdoll pueda convertir en articulaciones corporales. Todas las piezas son
  Massless, no ancladas y sin CanCollide/CanTouch/CanQuery.
- Respawn y cambio de WeaponId montan una sola arma. Rifle/Cañón conservan sus
  estadísticas y selección. Desde el 14/10 tienen plantillas propias SMG/láser,
  descritas a continuación; SDR-Mk2 queda como fallback si falta una plantilla.
  No se fuerza `blaster` sobre selecciones guardadas de jugadores.
- El ajuste de montaje se edita en el atributo CFrame `HandOffset` de la plantilla:
  actualmente `(0,-0.15,-0.1)` sin giro; Grip representa el punto que se coloca ahí.
  Para reemplazos, conservar nombre `blaster`, Handle/Grip y Barrel/Muzzle,
  piezas unidas, y repetir en ambos Places. Reiniciar Play/respawn para obtener clones nuevos.
- Respaldos por Place en `ServerStorage.ZB_WeaponBackup_20261009`:
  `WeaponSetup_Original` deshabilitado y `Config_Original`; Lobby además conserva
  `SDR_Mk2_Original` con posición y articulaciones originales. Para revertir, detener
  Play, deshabilitar WeaponVisualService, reactivar WeaponSetup.client y restaurar
  Config desde su copia. Para recuperar el modelo de escena, clonar SDR_Mk2_Original
  a Workspace y renombrarlo SDR-Mk2; la plantilla no se borra para revertir código.
- Verificado: montaje visible en capturas de ambos Places, una arma después de
  respawn en ambos, presencia de Muzzle en servidor/cliente, disparo real de Libre
  y Beam conectado a la nueva boca (36 muestras; dot mínimo 0.999809).
  QA controlado de cambio a rifle/restauración conserva una arma y energía
  30→31.8 por regeneración normal; apply/reset de ragdoll conserva el montaje.
- No publicado. Visibilidad entre dos cuentas, permisos de mallas en Player,
  combate VS real y rigs adicionales siguen pendientes. El IK moderno de Match
  se sincronizó después en B12 del 09/10: medición de pose en Studio confirmada;
  no equivale a validar disparo multijugador en VS.

### Rifle SMG y Cañón láser — modelos integrados 2026-10-14

**Implementados en Lobby y Match; sin publicar.** Reemplazan el visual compartido
de Rifle/Cañón, conservando los IDs, estadísticas, precios en monedas y selección
existentes. No se crearon pases ni cambió la modalidad de venta en esta integración.

| ID | Modelo visible | Plantilla permanente | Dimensiones aproximadas |
|---|---|---|---|
| `blaster` | SDR-Mk2 gratuita | `ReplicatedStorage.WeaponAssets.Templates.blaster` | 0.463×1.430×2.240 |
| `rifle` | SM_Wep_SMG_01 | `ReplicatedStorage.WeaponAssets.Templates.rifle` | 0.370×1.362×3.036 (ajuste +15 %) |
| `cannon` | SM_Wep_Laser_Gun_01 | `ReplicatedStorage.WeaponAssets.Templates.cannon` | 0.415×1.530×3.726 (ajuste +15 %) |

- Fuentes colocadas por el usuario en Workspace de Lobby: cada Model tenía dos
  MeshParts (cuerpo y gatillo). Longitudes originales 63.570 y 104.406 studs;
  escalas uniformes 0.04089995 para SMG y 0.03064951 para láser. Los originales
  están conservados en `ServerStorage.WeaponImportSources` del Lobby.
- **Revisión posterior del usuario:** el giro inicial de 180° en Y del SMG
  interpretaba el frente de la malla al revés. Corregido: mesh sin ese giro,
  desplazado alrededor de Handle para mantener el punto de empuñadura; caño real
  hacia -Z. Láser ya apuntaba hacia -Z. Ambos modelos aumentados uniformemente
  **15 %**, con Model.GetScale=1.15 y atributo PresentationScale=1.15.
  Ambas plantillas tienen `PrimaryPart=Handle`, `Handle.Grip` y `Barrel.Muzzle`.
  Handle/Barrel son marcadores transparentes; dos meshes visibles; tres welds
  internos y, al equipar, un cuarto `WeaponMount` a RightHand.
- Piezas sin anclaje/colisión/touch/query, Massless y sin CastShadow. Los modelos
  no traen scripts de disparo: usan WeaponVisualService y los servicios existentes.
- `HandOffset=(0,-0.15,-0.1)` como el arma base; Grip local identidad. Muzzle local
  del modelo vigente: Rifle `(0,0.6555,-0.897)`, Cañón `(0,0.667,-2.4495)`, ambos
  orientados -Z y situados al frente de la malla. Cuerpo/Muzzle tienen dot 1 en
  ambos Places. Las medidas anteriores al +15 % quedan en el respaldo de presentación.
  Montaje/escala/cuerpo se editan en la plantilla; repetir cambios en ambos Places
  y reequipar/respawn para renovar los clones.
- MeshIds de Rifle: cuerpo `76621132828690`, gatillo `113738827003683`.
  Cañón: cuerpo `122061092754289`, gatillo `80768984918661`.
  Textura de los cuerpos `96378986462286`; gatillos conservan textura vacía.
  IDs iguales en ambos Places; Match reconstruido desde los mismos assets.
- QA: capturas de montaje R15 en ambos Places; cinco cambios sucesivos entre
  blaster/rifle/cannon y respawn real dejan una sola arma. Cada nueva arma tiene
  cuatro piezas, todas sin colisión/anclaje y Massless, y Muzzle presente en cliente
  y servidor. Equipar con stamina 30 produjo 31.8 por regeneración, sin refill.
- Entrada Libre mediante el servicio real de Lobby. Disparo por mouse mostró
  consumo y solicitudes al servidor. Medición adicional con intención local
  controlada: dos beams conectados al Muzzle de cada modelo; energía 100→90.1,
  dot Muzzle/rayo de mira 0.99999964 (Rifle) / 0.99999982 (Cañón).
  Para esa medición se desactivaron cámara y MobileControls solo en runtime;
  los controles táctiles de escritorio limpian la intención simulada del bus.
  Estos ajustes/fixtures desaparecieron al detener Play; scripts Edit habilitados.
- Límite: no certifica compra/equipado premium, teleports, combate VS con dos
  cuentas ni todos los rigs. Match aislado conserva rechazo de TeleportData.
- Respaldo por Place: `ServerStorage.ZB_WeaponModelsBackup_20261014`, carpeta
  `PreviousTemplates` y atributos CreatedRifle/CreatedCannon. No había plantillas
  propias anteriores: retirarlas devuelve el fallback SDR-Mk2 sin cambiar Config.
  Lobby también contiene copias originales en `ImportedSources`; no insertarlas
  además de los originales archivados. Ambos Places quedan en Edit, sin fixtures.

**Ajuste del montaje del Rifle (16/10):** el usuario reportó que el Rifle parecía
agarrarse desde el medio. La empuñadura real se calculó analizando la malla del
cuerpo (`AssetService:CreateEditableMeshAsync`): los vértices más bajos (el mango)
están al ~59 % desde el frente → Z≈+0.90 en el modelo. `Handle.Grip` pasó de
`(0,0,0)` a `(0,-0.2,0.9)`. El Cañón se verificó igual y su mango ya estaba en
Z≈+0.06, casi en el origen: no se tocó. Recalcular con la malla si se reemplaza el
modelo. Respaldo `ServerStorage.ZB_RifleGripBackup_20261016`.

**Aclaración de capturas del usuario (16/10):** `@whitechocolatediaz` tiene
equipado el **Rifle** (que compró antes con monedas) y **no** el Cañón; la mochila
(SDR-Mk2 + Rifle) y la tienda (Cañón DESBLOQUEAR) coinciden. No era una
inconsistencia de propiedad, sino el montaje del Rifle.

**QA de la revisión:** capturas R15 del Rifle corregido y Cañón ampliado en Match;
longitudes de cuerpo 2.99 / 3.68 studs, correspondientes a ×1.15. Un arma montada
y cambio con energía 30→31.8 sin refill. Espacios de imagen propios en las tarjetas,
sin SVG genérico y con texto separado, ver UI_ASSETS 0.4. Los dos controladores
UI coinciden byte/hash entre Places. Sin fixtures, ambos en Edit/default y sin
publicar. Respaldo `ServerStorage.ZB_WeaponPresentationBackup_20261014` contiene
los modelos y controladores previos; restaurarlos por OriginalPath para revertir.
La medición inicial de beam de arriba validó Muzzle/mira, pero no detectó el
frente invertido de la malla: no presentarla como aceptación visual definitiva.

### Showroom de armas — Lobby, 2026-10-16

- `Workspace.WeaponDisplays.basearma1/basearma2/basearma3`: clones del contenedor
  basegancho1, con SDR-Mk2/Rifle/Cañón de solo exhibición. Originales de ganchos
  preservados; piezas nuevas ancladas y previews sin colisión, máximo 12 studs.
- Fila en X=-110/-70/-30, Z=-20, altura del pedestal original. Consultas de
  intersección precisas previas sin colisión con estructuras en esas ubicaciones.
  Se conserva el PivotOffset del pedestal y se coloca por su GetPivot normalizado,
  no aplicando otra vez la rotación de su CFrame. Mover el Model completo en Edit.
- Cartel frontal con imagen, título y GRATIS PARA TODOS / PASE · PRÓXIMAMENTE.
  Prompt E abre TIENDA / ARMAS y enfoca esa ficha, sin conceder propiedad/cobrar.
  Rutas de edición, componentes e IDs en UI_ASSETS 0.4–0.5.
- `ReplicatedStorage.WeaponOffers.<id>`: SaleMode Free/GamePass, PassId,
  PassPriceRobux y PurchaseIntegrationReady. Gratis base; **Cañón con pase
  2039918698 conectado** (solo con pase, ya no por monedas). Rifle aún con
  PassId=0 (PASE PRÓXIMAMENTE). Propietarios existentes conservan equipo.
- Cliente nuevo WeaponDisplayController → BindableEvent OpenWeaponOffer de la
  plantilla ZB_EquipmentDashboard → renderer compartido de tienda. Handler opcional
  por eventos, sin espera bloqueante si falta el BindableEvent.
- **Pases:** `ServerScriptService.MonetizationService` (Lobby) resuelve
  `UserOwnsGamePassAsync` al entrar y tras `PromptGamePassPurchaseFinished`,
  concede el arma con `WorkshopService.grantWeapon` (sin cobrar), registra
  `profile.passes` y guarda. `DataService` de ambos Places conserva `passes`.
  La tienda muestra DESBLOQUEAR · N R$ y abre el prompt oficial; el cliente no
  prueba la propiedad. `WorkshopBuy` rechaza comprar con monedas un arma de pase
  no poseída. Match no vende; refleja la posesión por el perfil persistido.
  QA Studio: concede/equipa con el pase, DESBLOQUEAR sin él, y rechazo sin cobro.
  Compra real con Robux/multicuenta publicada pendiente. Detalle en UI_ASSETS 0.5.
- **Reset pre-lanzamiento:** `ServerScriptService.WeaponPassReset` quita una vez el
  Cañón de los testers (y limpia `passes`) para poder probar la compra; idempotente
  vía `migrations.weaponPassReset`; subir `VERSION` para repetir.
- **Estado por jugador en la vitrina:** el Sign de la vitrina es compartido; un
  BillboardGui local (`WeaponDisplayController`) muestra al cliente su estado real
  (LA TENÉS / DESBLOQUEAR · N R$ / PASE · PRÓXIMAMENTE / GRATIS), corrigiendo la
  contradicción entre la mochila (propiedad) y el cartel fijo. Solo hay un store
  activo: `EquipmentDashboard`; `StoreDashboard` y `WorkshopController.client` están
  deshabilitados.
- **`ReplicatedStorage.Monetization.AutoGrantPasses`** (BoolValue): si es false, no
  concede el arma del pase al entrar (pruebas pre-lanzamiento); la compra confirmada
  siempre concede; ausente = true. **Poner true antes de lanzar.** El reporte "todos
  tienen el Cañón" se debió a que la API devuelve propiedad true para la cuenta
  creadora del pase y, en Studio multijugador, todos son la misma cuenta. Para
  probar la compra real, usar una cuenta que no posea el pase.
- Imágenes de la fuente del usuario exportadas a tres PNG y subidas; 3/3 cargadas
  en Lobby. E en las tres vitrinas abrió su ficha correcta; saldo 500 y blaster
  intactos al pulsar una tarjeta pendiente. Respawn mantuvo tres vitrinas, tres
  prompts y una GUI. Capturas escritorio y móvil horizontal, foco/scroll a Cañón.
- Respaldo Lobby `ZB_WeaponShowroomBackup_20261016`. Fuente de las imágenes y
  archivos/IDs en assets/ui/weapon_images_manifest.json. Sin fixtures ni publicación;
  Lobby en Edit/default. **Match no estaba conectado:** sincronizar imágenes,
  WeaponOffers y dashboard/plantilla cuando se abra; las vitrinas son solo de Lobby.

### Cable del gancho: apariencia genérica 3D — 2026-10-16

- Alcance confirmado: estética, misma mecánica y personalización existentes.
  Navidad fue un ejemplo futuro, no una skin a implementar ni un consumible.
- Una plantilla `ReplicatedStorage.HookCosmeticAssets.RopeSkins.Generic`:
  cuerpo cilíndrico Fabric oscuro y refuerzos, con tintado suave del color equipado.
- Cliente HookRopeRenderer sigue los Attachments ya replicados, oculta el Beam
  anterior localmente y muestra geometría sin colisión/query. No crea RopeConstraint
  ni altera fuerzas, energía, alcance, velocidades, precios o inventario.
- Resuelve un Model por HookRopeCosmeticId si existe; fallback Generic para las
  tres entradas heredadas de color/grosor. Hoy hay una sola plantilla visual.
- Misma fuente/plantilla en ambos Places. Código de HookController y
  HookVisualService sin cambios; prueba controlada del gancho en Libre y fixtures
  de geometría/limpieza en Studio. El intento de Q físico no fue concluyente;
  multicuenta/touch/FPS y VS real siguen pendientes.
- Edición, límites y QA en UI_ASSETS 0.6; respaldo por Place
  `ZB_GenericHookRopeBackup_20261016`. Ambos Places en Edit, sin publicar.

### Retorno de Libre y apuntado del brazo — Lobby, 2026-10-07

**Actualización 09/10 — B12:** ShootingController Match ahora comparte exactamente
la solución de apuntado del Lobby. Comparación controlada de pose moderna antes:
dot mínimo 0.351407; después: 0.9999065 en 105 muestras/tres direcciones.
Fuentes iguales, 22375 bytes/hash 2798386865. Respaldar/restaurar Match desde
`ServerStorage.ZB_CalendarAndAimBackup_20261009["ShootingController.client"]`
si se necesita revertir. Rigs adicionales/observador remoto/VS real pendientes.

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
| Disparar (móvil) | Mantener DISPARAR; arrastrar permite apuntar |
| Gancho (móvil) | Mantener GANCHO, acción independiente |
| Agarre/impulso (móvil) | Pulsar AGARRE; siguiente pulsación IMPULSO libera |
| Subir/bajar (móvil) | Sin botones dedicados (retirados) |
| Deriva (móvil) | Joystick nativo del motor |

Espacio conserva el salto normal fuera de batalla. Durante combate de escritorio,
el mouse orienta la cámara sin mantener click derecho; Alt alterna cursor libre.
No disparar ni lanzar gancho sobre mochila, manual, tabla, chat o cursor liberado.

### Controles táctiles — 2026-10-09 (historial; sustituidos por tres acciones)

`ReplicatedStorage.Shared.LocalCombatInput` es un bus de **intención local**
(no autoridad): registra por acción la pulsación de varios dedos/botones y expone
`isHeld/set/clear` y `Changed`. Soltar un dedo no interrumpe otro que siga pulsado.
`aimOffsets()` devuelve los offsets de mira de escritorio o `(0,0)` en táctil.

- `StarterGui.ZB_MobileControls` (atributo `MobileControls=true`) contiene los
  botones redondos DISPARAR, GANCHO, SUBIR y BAJAR; iconos de `UIAssets.Icons`,
  `UICorner` redondo y `UIStroke`. Editables en Explorer/Properties.
- `StarterPlayer.StarterPlayerScripts.MobileControls` es un LocalScript: muestra
  los controles solo con `TouchEnabled` y landscape, asocia cada dedo al botón que
  inició el gesto, y cancela al perder foco, abrir teclado/menú/scoreboard, cambiar
  de estado o de viewport. No se reactivan al cerrar un menú. Consulta
  `PlayerModule:GetControls()` para el joystick.
- `ShootingController.client` y `HookController.client` consumen el bus: mismo
  beam/energía/cooldown/IK que mouse y teclado. El disparo táctil mantiene el
  botón; la liberación limpia el beam. `ZB_CursorFree` deja de bloquear input
  cuando `TouchEnabled`.
- `MovementController.client` usa `GetMoveVector()` del joystick en 0g y los
  botones SUBIR/BAJAR como R/Ctrl, conservando WASD y la caminata del Lobby.
- `ReplicatedStorage.Shared.MobileHudLayout` distribuye accesos redondos (mochila,
  diario, ayuda, tabla, salir), librería de recursos, monedas, LED y encabezado VS
  en `DeviceSafeInsets`, con leyendas cortas y ajuste a viewport corto.
  `AtlasUIController` no reestiliza estos accesos (`MobileControls`/`ZB_MobileRound`).
- Alcance: verificado en Studio con funciones exactas y capturas. **No valida
  dedos/touch reales, multitáctil físico ni FPS móvil.** Respaldo
  `ServerStorage.ZB_MobileBackup_20261009` por Place; sin publicación.

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
- Durante el gancho sigue disponible el prompt de agarre: E inicia la sujeción
  voluntaria y `Grabbing` retira la tracción/visual del gancho sin escribir la
  velocidad del agarre. Soltar gancho después no borra el impulso; mantenerlo
  pulsado no produce un relanzamiento automático. B17, QA controlada Studio 13/10.
- Objetos agarrables: atributo exacto `cubrirce=true`. No permitir autoagarre.
  Match usa `GrabLaunchService`; Lobby tenía la integración en `FloatingRobloxBlocks`.

### Arte UI — atlas integrados el 13/10

- Fuentes separadas del usuario para iconos, botones y paneles, recortadas en
  `docs/assets/ui/`; 28 recursos subidos y compartidos por Lobby/Match.
- `UIAssets.Icons`: 16 imágenes Fit; claves sin dibujo mantienen Fallback.
  `UIAssets.Skins`: cuatro marcos y ocho estados de botón, editables en Properties.
- `Shared.UIFrameSkins` y `StarterPlayerScripts.UIAssetSkinController` enlazan
  fondos 9-slice con texto independiente y respaldo nativo. UITheme los aplica
  a pantallas dinámicas; UIFrameSkin identifica los de las plantillas.
- Colores de arte: manual/inventario cian, actividades y gancho violeta, resultado
  ámbar. Presión/hover/disabled/selección son visuales; contratos de gameplay intactos.
- QA Studio desktop, simulador horizontal/vertical y respawn; sin publicación.
  Medidas, IDs, límites y reversión en UI_ASSETS.

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

Vida disponible 10 s; al expirar sin recoger se recolocan inmediatamente. Tras
recogerlos reaparecen en 10 s (corte verificado por código el 26/10).
`Workspace.puntosderefe.Punto1..Punto15`: Parts anclados,
invisibles y con CanCollide/CanTouch/CanQuery=false. Selección por instancia,
evitando dos últimas ubicaciones y puntos ocupados, con fallback seguro. Ocultar
visual hasta ubicarlo. Servidor decide todo; `PowerUpEffect` permite al cliente
dueño de red aplicar inmediatamente el impulso confirmado.

### Persistencia, recompensas y ranking

**Renovación diaria vigente desde 2026-10-09 (B11):** `ServerScriptService.DailyClock`
es un ModuleScript de servidor que devuelve día/hora Unix/próximo reinicio a
**00:00 UTC**. En Lobby, MissionService y DailyRewardService verifican el cambio
cada 2 s y envían snapshots nuevos a sesiones abiertas. No se reinician las misiones
en cada consulta: si el día ya coincide, se lee/normaliza una copia para el estado.

`RequestDailyActivitiesState` (RemoteEvent) solicita snapshots al entrar o abrir
calendario; cada servicio limita solicitudes a una por segundo/jugador. Respuestas
MissionState/DailyRewardState incluyen `day`, `serverTime`, `nextResetAt` y `timeZone`.
DailyActivities muestra `Reinicio UTC en HH:MM:SS` y actualiza texto a 1 Hz,
sin cambiar autoridad ni depender de la fecha del dispositivo. Conserva una GUI al respawn.

Actualizaciones de actividades usan `DataService.updateProfile(player, mutator,
{applyProfile=false})`: conserva recursos/equipado, actualizando InventoryCoins y
CurrencyService solo cuando corresponde al saldo. API disponible en Lobby y Match;
las llamadas de dos argumentos siguen reaplicando el perfil como antes. No cambia
el DataStore ni implementa aún guardado transaccional/idempotencia entre servidores.
Match no incorpora servicios/GUI de misiones: siguen siendo responsabilidad del Lobby.

Respaldos en `ServerStorage.ZB_DailyRolloverBackup_20261009`: para revertir con Play
detenido, restaurar Source de los scripts correspondientes desde sus copias y
restaurar DailyActivities en Lobby. Después puede retirarse DailyClock si ya no
tiene consumidores. Las copias de scripts del respaldo están deshabilitadas.
Pruebas y límites en B11 de BUGS/CHECKLIST; sin publicación.

- DataService: perfil por jugador, carga/normalización, guardado periódico,
  PlayerRemoving y BindToClose. Aplicar atributos disponibles al instante;
  reintentar servicios en segundo plano sin esperas secuenciales largas.
- Guardar monedas, armas, láser equipado, estamina, mejoras de gancho, estadísticas,
  `BattleOptOut`, ownedHookTips/ownedHookRopes y sus selecciones. Reparar propiedad
  para incluir cosmético equipado al normalizar perfiles antiguos.
- `Eliminations` replica total persistente. `CONGELADOS MODO LIBRE` acredita nuevos
  fullFreeze válidos únicamente en Libre;
  combina jugadores conectados con ranking histórico. Refresco por evento con
  debounce 0.2 s; consulta histórica OrderedDataStore cada 20 s en segundo plano.
- Presentación física actual: `Workspace.Rankings3D.Congelados/Victorias/Monedas`,
  cuatro filas y SurfaceGui Face Front, alimentados por el puente de RankService.
  Las antiguas placas1/2/3 y su Face Right ya no existen en la escena inspeccionada.
- Monedas Neon (~100/hora documentadas): sin colisión, con toque; ocultación
  local inmediata, entrega validada por servidor. Contar diccionario con pairs.
- Recompensas históricas configuradas: jugar +15, ganar +30 extra, congelar
  extremidad +2, eliminar rival jugador +8; no recompensar NPC ni partida inválida.
  Revalidar rutas vigentes de pago VS y la de extremidades tras migración a porcentaje.
- Daily por día UTC: LastDailyClaimDay, DailyStreak y escalera de siete días;
  política final de pérdida/reinicio de racha y versionado de datos pendientes.
- Misiones: jugar, recoger 25 monedas y reclamar daily. Libre registra playMatches
  al entrar; VS completo registra playMatches y su MatchId al finalizar en Match.
  Retorno/cancelación no registran por sí solos otra misión.
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
- Cuerdas: Config.HookRopeCosmetics (`id`, `name`, `color`, `width0`, `width1`)
  conserva el Beam replicado; HookRopeRenderer presenta RopeSkins.Generic en 3D.
- UI puede reemplazarse por arte propio conservando remotes, estado y cierre.
- Hologramas antiguos: Workspace.Hologramas/HoloLevitation retirados. El sistema
  actual de rankings usa Workspace.Rankings3D/HologramMotion; ver corte 26/10.
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
| ReplicatedStorage.Shared | Config, PlaceConfig, UITheme, CalendarDates (Lobby), LocalCombatInput, MobileAimInput, MobileHudLayout, AnimationFreeze, UIFrameSkins, UIFrameArtwork; EquipmentDashboardLayout solo Lobby |
| ReplicatedStorage.Modules | FreezeMap |
| ServerScriptService, compartidos | PlayerStateService, FreezeService, ShootingService, CombatRagdoll, DataService, StaminaService, RankService, InventoryService, HookEnergyService, HookVisualService, PowerUpService, WeaponVisualService, BattleStats, DailyClock |
| Servidor Lobby | LobbyTeleportService, BattleFormatStations, CurrencyService, WorkshopService, MissionService, DailyRewardService, QABadgeService, FloatingRobloxBlocks |
| Servidor Match | MatchRuntimeService, MatchModeBootstrap, MatchArenaPhysics, GrabLaunchService, WeaponVisualService, LobbyReturnRoute, VsResultService, DailyMissionCatalog |
| StarterPlayerScripts, compartidos | MovementController, ShootingController, HookController, HookSpeedCamera, GrabController, GravityController, HudController, RemoteVfx, CombatFeedback, EquipmentDashboard, PowerUpEffects, VersusHud/resultados según Place, MobileControls, ZeroGFootsteps |
| StarterGui | ZB_Intro, ZB_DailyActivities (Lobby), ZB_MobileControls, accesos HUD, ZB_CoinFeedback, ZB_SpawnProtection; ZB_EquipmentDashboard completo solo Lobby |
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
