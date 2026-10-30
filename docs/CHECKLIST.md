# ZERO BREACH — Checklist, pruebas y progreso

Actualizado: 2026-10-29. Diseño en [DISENO](DISENO.md), normas en
[REGLAS](REGLAS.md), incidentes en [BUGS](BUGS.md).

## 1. Estado y prioridad inmediata

### VS: fotos pequeñas y final demasiado brusco — 29/10

- [x] Match: VersusScoreLayout concentra el tamaño del HUD; marco 560×150/fotos88
  en escritorio amplio, 420×112/fotos64 en compacto 1v1/2v2; 3v3/4v4 en fila o 2×2.
  Ronda dentro del marco y PNG completo sin deformar.
- [x] Guardas VersusLayoutOwned en MobileHudLayout (ambos Places) y AtlasUIController
  de Match para evitar que vuelvan a achicar/posicionar el marcador.
- [x] Plantilla editable ZB_VsMatchResult + controlador de Match: victoria/derrota,
  marcador, retratos, congelaciones, destacado y retorno con progreso; entrada .4 s.
  Cancelación diferenciada y resultado modal incluido en AtlasUIController.
- [x] MatchRuntime: FINALIZE_TIME=10 s, returnAt sincronizado; guardia impide regreso
  prematuro. Cancelación 3 s. Resumen diferido incluye el último freeze confirmado;
  no cambia la concesión idempotente ni el destino de retorno.
- [x] QA de presentación en Play: 1v1/4v4, victoria, derrota, cancelación,
  reintento, cuenta agotada y limpieza al COUNTDOWN; capturas de marcador/final.
  Laptop 1365×768: foto88 y marco560×150. iPhone17 Pro horizontal 750×381: 4v4
  foto44 y resultado visible. Sensor/DeviceSafeInsets; simulador restaurado.
- [x] Función real de guardia de retorno extraída en fixture aislado con grupo vacío:
  no consulta grupo antes del plazo y sí después. No ejecuta teleport ni premios.
- [x] Respaldos ZB_VersusFinalFeedbackBackup_20261029 (Match) y
  ZB_VersusScoreLayoutBackup_20261029 (guarda Lobby), Play detenido, fixtures retirados.
- [ ] Publicar Match y validar cierre VS multicuenta real, premios únicos,
  retorno al Lobby, aceptación visual y teléfono físico.

### Shift cambia cámara en producción e impide sprint — 29/10

- [x] Inspeccionar conflicto: Shift Lock nativo habilitado y sprint ignorando
  InputBegan procesado. Lobby: EnableMouseLockOption=false.
- [x] Acción ZB_LobbySprintShift prioridad 3020 con ambos Shift; Sink en Lobby,
  Pass fuera de Lobby; conservar guardas de menú/chat y servidor de velocidad.
- [x] Teclado Studio: izquierdo 16→26, derecho mantiene 26 al soltar izquierdo,
  soltar ambos 16. MouseBehavior.Default y DevEnableMouseLock=false.
- [x] B y TextBox cancelan/bloquean sprint; acción competidora prioridad 2000 no
  recibe Shift en Lobby y sí con participación de batalla simulada, sin sprint.
- [x] Respaldo ZB_SprintShiftLockBackup_20261029, Lobby en Edit, fixtures retirados.
  Match no requiere sprint y no se modificó.
- [ ] Publicar Lobby y comprobar Shift con preferencias de cámara en Roblox Player.

### Audio de compra/gancho, color de equipado y velocidad — 29/10

- [x] Ambos Places: Action dorado si equipado y celeste si no; no conservar el
  color del artículo ni gris por ausencia de callback. Mantener los dos layouts.
- [x] GameplayAudioFeedback + plantillas editables: compra `10066947742`, lanzamiento
  del usuario `115384381235257`, enrollado del usuario `78607765579739`.
  IDs finales cargan en ambos clientes; volumen .5/.45/.24, PlaybackSpeed=1.
- [x] Carrete tras aceptación de energía, una voz sin reiniciar en update/drain;
  parar al soltar/cancelar/menú/salir/respawn e invalidar arranques pendientes.
- [x] WorkshopResult.purchased (tercer argumento booleano) diferencia adquisición
  pagada de equipado/gratis/rechazo. Pase: PurchaseConfirmed solo tras éxito y
  concesión; no suena por propiedad al iniciar sesión. Compra Robux real pendiente.
- [x] Compra real Studio de rojo: 500→400, un sonido; reequipar no repite e ID
  inválido no suena. DataStore omitido en Studio; sin gasto de Robux.
- [x] Cinco equipados reales cyan/red/cyan/red/cyan en Lobby: atributo y Action
  correctos, un seleccionado. Match: snapshots rojo→cyan, color correcto.
- [x] Q real en fixture Lobby con audios del usuario: lanzamiento/carrete una vez,
  loop detenido al soltar. Match: confirmación de energía simulada prueba el loop.
- [x] FOV Boost 14→24, base 70; líneas Count32, Width3, Opacity1, Length1.45.
  Velocidad controlada 70 dio FOV≈94 en ambos; retorno a 70/overlay oculto.
  Captura Lobby confirma trazos periféricos mayores y centro libre.
- [x] Paridad de los dos controladores compartidos y respaldo
  ZB_PurchaseHookFeedbackBackup_20261029; ambos en Edit, fixtures retirados.
- [ ] Escucha/mezcla del usuario, recorrido de gancho real en VS, móvil y publicar.

### Números flotantes de daño — 29/10

- [x] Ambos Places: sustituir el «+ N%» de mira y los dos carteles de porcentaje
  por `Shared.FloatingDamageNumbers`, enlazado en CombatFeedback.
- [x] Números en punto de impacto con pop/ascenso/fade; normal crema, cabeza roja
  más grande con `!`/CABEZA, cierre celeste con CONGELADO. Puntos de congelación
  reales, sin sufijo `%`; balance y autoridad del servidor conservados.
- [x] Pool fijo 24, agrupación por objetivo/tipo durante 0.14 s y vida de 1.05 s;
  una conexión de render solo con efectos activos, sin tweens/tareas por impacto.
  Limpieza al reaparecer/salir; marcador de impacto con temporizador único.
- [x] ShootingService (beam/pulse) y adaptador legado de proyectiles envían delta
  aplicado, hitPosition, headshot y completedFreeze. Servicio de proyectiles
  permanece deshabilitado. Sin carteles duplicados en los otros controladores.
- [x] QA beam real contra clon R15 en ambos Places: 18 torso, 54 cabeza y 28 final
  hasta 100; posición Vector3 y completedFreeze confirmados desde el cliente.
- [x] QA controlada de presentación: 18+18=36; cabeza y congelado diferenciados;
  ráfagas de 100/60 mantienen pool 24, efectos expiran; cero, negativos, NaN e
  infinito rechazados; detrás de cámara oculto. Captura del Lobby confirmada.
- [x] Paridad de módulo y controladores, respaldo ZB_FloatingDamageBackup_20261029
  por Place, fixtures retirados, modo final beam, ambos Studios en Edit sin publicar.
  Match aislado conserva errores de retorno TeleportData/HTTP y esperas de GUI;
  sin errores del nuevo feedback. Pulse/proyectil sin prueba efectiva de disparo.
- [ ] Aceptación visual, móvil físico, VS real y publicación de ambos Places.

### Correr con Shift en Lobby — 28/10

- [x] Añadir LobbySprintController + LobbySprintService + LobbySprintIntent;
  configuración LobbyMovementSettings, caminar 16 y correr 26 manteniendo Shift.
- [x] Validación servidor: intención booleana, modo Lobby, no participante de batalla,
  avatar vivo, sin PlatformStand/ragdoll. Velocidad elegida por servidor.
- [x] Teclado real en Studio: Shift izquierdo/derecho activa 26 y soltar restaura 16,
  confirmado desde el servidor. Menú cancela; respawn real vuelve a 16/sprint=false.
- [x] Participación de combate simulada cancela/rechaza sprint; remote con número o
  tabla rechazado. No equivale a una entrada real a Libre.
- [x] Output limpio del sistema; Lobby en Edit, sin publicar. Solo objetos nuevos
  del Lobby; Match no requiere carrera en su arena VS.
- [ ] Aceptación de velocidad y prueba caminando/corriendo por el Lobby publicado;
  recorrido real Lobby→Libre→Lobby y pérdida de foco/chat.

### Líneas blancas de velocidad del gancho — revisión 28/10

- [x] Sustituir chispas azules por overlay local radial en Libre y VS:
  `HookSpeedCamera` → `PlayerGui.ZB_HookSpeedLines`, 28 líneas blancas degradadas
  alrededor del centro despejado, sincronizadas con la transición del FOV.
- [x] Configurar cantidad 28, opacidad .8 y grosor 1.8 px en PresentationSettings;
  respetar HookSpeedParticles y añadir HookSpeedLines como interruptor.
- [x] QA controlada en ambos clientes: 28 líneas blancas, FOV ≈74.886 al activar
  Hooking y sin ZB_HookSpeedEmitter. Match: desvanecido, retorno FOV 70 y menú oculta.
- [x] Captura Libre a velocidad simulada 70: trazos blancos periféricos. Al terminar,
  una GUI, líneas ocultas y FOV 70. Fixtures solo runtime, retirados al detener Play.
- [x] Paridad Edit: 5563 bytes/hash base31 3468477806, boost final 14 en ambos.
  Respaldo por Place ZB_HookWhiteLinesBackup_20261028. Ambos en Edit, sin publicar.
- [x] Output sin errores del efecto; Match aislado conserva rechazo de TeleportData
  y errores HTTP de retorno documentados.
- [ ] Aceptación visual del usuario con gancho real, VS publicado y teléfono físico.
  Esta QA usa atributos/velocidad simulados, no acredita una partida real.

### Efectos de combate: arma, daño, FOV y estela del gancho — 28/10

- [x] Partículas + luz en la boca del arma al disparar: versión de servidor replicada
  (`ZB_FiringFx`) y **emisor local en primera persona** (`ZB_FPMuzzleFx`) porque el
  arma real está oculta. Encendido en start/update y apagado en stop; verificado.
- [x] **Feedback para el tirador:** hitmarker en la cruz + “+ N%” del daño aplicado,
  enviado desde `TargetFreezeProgress.damage`. Verificado con +23% en pantalla.
  El feedback de recibir daño (borde rojo) queda como estaba; se retiró el flash
  extra agregado en esta sesión.
- [x] FOV del gancho configurable: HookFovBase=70, HookFovBoost=14 (admite negativo),
  HookFovResponse=9; acotado 40–110 y suavizado por velocidad.
- [x] Estela inicial (sustituida por líneas blancas en la revisión de arriba): emisor independiente 3.5 studs delante de la
  cámara (visible en FP) mientras Hooking y velocidad >2; verificado visible con
  Rate 99 y aceleración inversa.
- [x] QA Libre: start/stop de boca, FOV 70→74.9/78.9→70, hitmarker/+23% y estela;
  sin errores; Play detenido.
- [ ] VS real, observador remoto, teléfono físico y ajuste de intensidades.
  La estela del gancho es local del dueño; las partículas del arma sí se replican.

### Primera persona con brazos/arma (prototipo) — 28/10

- [x] `BattleCameraController`: cámara en la cabeza en batalla de escritorio con
  `FirstPersonMode`, manteniendo yaw/pitch y publicando `FirstPersonActive`; tercer
  persona y FOV del gancho intactos.
- [x] `FirstPersonArms` en ambos Places: **brazos falsos en bloque** (estilo de la
  referencia del usuario: manos/brazos postizos), oculta el avatar solo al dueño,
  monta el arma del `WeaponId` y pose fija con balanceo/retroceso.
- [x] Quitar animación de caminar/correr en primera persona: se detienen las pistas
  walk/run y se bloquean las nuevas mientras el modo está activo.
- [x] Alternar con V; valor inicial `PresentationSettings.FirstPersonDefault=true`;
  `FirstPersonScale=.8` y `FirstPersonEyeHeight=.35` editables.
- [x] Rayo local recolocado a la boca del viewmodel; servidor sin cambios.
- [x] Sin brazos: solo el arma, abajo a la derecha, **escala 70 %**
  (`FirstPersonWeaponScale`) e inclinación 16° (ángulo aprobado por el usuario).
- [x] **Causa del rayo desviado corregida:** `LocalCombatInput.aimOffsets()` usaba
  +40/−110 (mira de tercera) también en primera persona; ahora devuelve 0,0 con
  `FirstPersonActive`, por lo que el rayo de cámara pasa por la cruz y el beam nace
  en la boca del arma y termina en ese punto. Tercera persona intacta.
- [x] QA Studio: cámara en cabeza, cuerpo oculto, cruz centrada, arma 70 % arriba
  de la zona inferior derecha, aimOffsets=0,0 en FP, V alterna, sin errores.
- [ ] Revisar visualmente el ancho del tramo rayo→cruz al disparar y confirmar
  aceptación; VS real y teléfono físico pendientes.
- [ ] Revisar en VS real, respawn, cambio de arma y que la animación detenida no
  afecte la vista de terceros de forma no deseada.
- [ ] Teléfono físico: primera persona está desactivada en táctil (cámara sobre hombro).
- [x] Respaldo por Place ZB_FirstPersonBackup_20261028; Edit/default al terminar.

### Plan de precios: monedas para mejoras, Robux para armas/ganchos — 28/10

- [x] Definir y aplicar precios de mejoras: capacidad arma 80, recarga arma 140,
  capacidad gancho 100, recarga gancho 160 monedas por nivel (total ≈3580).
- [x] Mantener colores de láser con monedas (0/100/100/200/300).
- [x] Rifle pasa a pase de 10 R$ (pendiente de ID); Cañón conserva su pase 2039918698
  a 10 R$. SDR-Mk2 sigue gratis.
- [x] Crear `ReplicatedStorage.HookOffers` en ambos Places con Spike 10 R$, Heavy
  15 R$, Plasma 10 R$ y Dorada 15 R$; Punta Base y Cable Base gratis.
- [x] WorkshopService: bloqueo de compra con monedas para cosméticos de pase y API
  grantHook/ownsHook/isPassHook. MonetizationService resuelve pases de armas y gancho.
- [x] Tienda Lobby: lee ambos catálogos, muestra DESBLOQUEAR · N R$ cuando el pase
  está listo y PASE PRÓXIMAMENTE sin ID; no declara propiedad en cliente.
- [x] QA Studio: rechazos sin cobro (Rifle, Spike, Dorada), Punta Base gratis,
  mejora 500→420 y 100→120 (plan ×1), precios visibles, sin errores nuevos.
- [x] **Precios ×10 (28/10):** capacidad arma 800, recarga arma 1400, capacidad
  gancho 1000, recarga gancho 1600; total ≈35 800. Verificado en Play con 500
  monedas: compra rechazada y tienda mostrando FALTAN 300/500/900/1100.
  Respaldo del plan ×1: ZB_PricingPlanX1Backup_20261028.
- [x] **29/10:** conectar Punta Heavy al pase `2058684037` (`hook_heavy`) en
  `ReplicatedStorage.HookOffers.heavy` de ambos Places; `PurchaseIntegrationReady=true`,
  precio de referencia 6 R$ confirmado con Marketplace. Cosmético, sin daño adicional.
- [ ] Crear en Creator Dashboard los pases Rifle, Spike, Plasma y Dorada;
  pegar PassId y poner PurchaseIntegrationReady=true; compra real con cuenta sin pase.
- [ ] Publicar y validar con Robux; confirmar propiedad tras reconexión y viaje.

Respaldo por Place `ZB_PricingPlanBackup_20261028`. Detalle y tabla en DISENO.

### Calendario: X dentro del panel y misiones a ancho completo — 28/10

- [x] Mover la X de la esquina al punto marcado en verde: dentro del panel,
  centrada a 108 px del borde derecho y 58 del superior (56 en vertical).
  Tamaño/glifo conservados; ya no choca con el adorno de la esquina.
- [x] Alinear las misiones al borde derecho: sin tope de 350/310 px, ocupan todo
  el ancho de la columna de detalles (414/384/338) e igualan el marco de recompensa.
  `MissionMaxWidth=0`/`MissionPortraitWidth=0` significan ancho completo.
- [x] Mantener textos a la izquierda, importes a la derecha, botones 56 y fuentes
  16/13/16; sin cambios en datos, fechas ni cobros.
- [x] Capturas escritorio 1087×629, iPhone horizontal 750×381 y vertical 401×778:
  X visible dentro del panel, misiones hasta el borde derecho y texto que cabe.
- [x] Cerrar por click: Panel/Backdrop ocultos, ZB_MenuOpen=false, acceso visible.
  Output sin errores de UI; sin cobros.
- [x] Respaldo ZB_CalendarRightAlignBackup_20261028; Edit/default al terminar.
  Fuente final 26453 bytes / hash base31 2003019411.
- [ ] Aceptación visual del usuario, teléfono físico y publicación.

### HUD: acceso MOCHILA cortado arriba en escritorio — 28/10

- [x] Reproducido en Play de ambos Places: `OpenInventory` quedaba en
  `AbsolutePosition.Y=-42` (offset 16 − 58 de área segura); el contador de monedas
  también se desplazaba. Causa: `IgnoreGuiInset=true` + `ScreenInsets=DeviceSafeInsets`
  aplican un desplazamiento superior que el layout no compensaba.
- [x] `BattleHudArtwork.pinTop` mide el desplazamiento real (AbsolutePosition − offset)
  y fija la Y visible; converge en un paso y no depende de un inset fijo.
  Aplicado a mochila, monedas y a la fila táctil de tabla/salida.
- [x] En móvil, MOCHILA/monedas del HUD nuevo se superponían con DIARIO/AYUDA.
  MobileHudLayout las baja a Y=102 bajo el contador, compensando también el área
  segura con `safeTop`; sin solapamientos.
- [x] Verificado sin solapes: escritorio 1087×629 (mochila 16–96, monedas 100–166);
  iPhone horizontal 750×381 (mochila 6–50, monedas 56–94, DIARIO/AYUDA 102–154);
  vertical 401×778 (todo dentro del viewport). Match con estado local de combate:
  fila SALIR/TABLA/MOCHILA en Y=6 y monedas debajo; cero intersecciones.
- [x] Capturas de Lobby y Match; Output sin errores de UI. Fixtures de QA solo en
  Play, restablecidos al detener. Ambos Places en Edit.
- [x] Paridad de módulos: BattleHudArtwork 14015 bytes/hash 4142698161;
  MobileHudLayout 8652 / 3734122656 en Lobby y Match.
- [x] Respaldo por Place ZB_HudSafeAreaBackup_20261028.
- [ ] Aceptación visual del usuario, teléfono físico (notch real) y publicación.

### Cierre y flechas grandes, misiones a la izquierda — 28/10

- [x] Agrandar y centrar el botón X: 44×44→**56×56**, glifo 14→26, AnchorPoint
  centrado en (1,−36, 36). Verificado: texto y arte centrados (desvío ≈0 px).
- [x] Agrandar y centrar `<` y `>`: 36×34→**52×52** (44 en horizontal bajo),
  glifo 26. El título del mes queda entre ambos, centrado y con TextFits=true.
- [x] Alinear a la izquierda MIS IONES DE HOY, el título de cada fila y su progreso
  al mismo margen X=12; botones de premio conservan su tamaño de 56×56.
- [x] Exponer CalendarCloseSize/CalendarNavSize/CalendarControlFontSize y
  reacomodar al cambiarlos; reservar alto para no montar los días sobre las flechas.
- [x] Navegación real de mes en ambos sentidos, capturas desktop 1087×629 y
  iPhone 17 Pro 750×381 / 401×778; sin recortes ni superposiciones.
- [x] Cerrar por click: Panel/Backdrop ocultos, ZB_MenuOpen=false, acceso visible.
  Output sin errores de UI; saldo 500 y sin cobros.
- [x] Respaldo ZB_CalendarNavigationBackup_20261028; Edit/default al terminar.
  Fuente final 25936 bytes / hash 3206220172.
- [ ] Aceptación visual del usuario, teléfono físico y versión publicada. Sin publicar.

Guía exacta en UI_ASSETS, sección de cierre/flechas del 28/10.

### Misiones: menor ancho y mayor tamaño de botones/fuente — 28/10

- [x] Responder al área señalada por el usuario: filas hasta 350 px en escritorio
  (antes 414), 310 en vertical; tarjetas de 72 px de alto y premios de 56×56.
- [x] Aumentar títulos a 16, progreso a 13 y premio a 16. Horizontal bajo:
  tarjeta 46, premio 40×40, fuentes 13/11/14. Separar texto y botón.
- [x] Exponer atributos MissionMaxWidth/MissionPortraitWidth/MissionButtonSize/
  MissionFontSize/MissionProgressFontSize; adaptar alto compacto y scroll vertical.
- [x] Capturas desktop 1087×629, iPhone 17 Pro 750×381 y 401×778; las nueve
  etiquetas de las tres misiones tienen TextFits=true. Comprobar scroll hasta la
  tercera y ✓ con estado de presentación local, restaurado sin cobrar.
- [x] Saldo de QA 500 conservado, Output sin errores de UI; Edit/default al cerrar.
  Respaldo ZB_CalendarMissionLayoutBackup_20261028; fuente 24342 bytes/hash 2078309751.
- [ ] Aceptación visual del usuario y teléfono físico. Sin publicación.

Medidas y propiedades de edición: UI_ASSETS, ajuste de misiones del 28/10.

### Revisión de cambios y calendario estilo mochila — 28/10

- [x] Leer el corte del 27/10 y contrastar ambos Studios: Lobby versión 811,
  Match 217; calendario solo Lobby. Accesos compactos/cartel Libre retirado ya
  coinciden con UI_ASSETS/CHECKLIST. Actualizar DISENO, que aún encabezaba el 26/10.
- [x] Usuario confirma «Mismo estilo de mochila». Respaldar GUI y DailyActivities
  en ZB_CalendarBackpackPolishBackup_20261028 antes de cambiar presentación.
- [x] Reforzar marcos de panel/calendario/recompensa/misiones y usar imágenes
  completas Fit en ocho botones. Añadir iconos de hoy y monedas; preservar Activated.
- [x] Ajustar anchura/fuente de Caption y estado ✓ de misión reclamada. En compacto,
  recompensa 130×40; hoy 168×32. En escritorio/vertical, botones principales 240×44.
- [x] Conservar 42 slots, ClaimState/ConfirmedClaim, colores e información por fecha.
  ShortDayMarkers=—/× y ocultar microtexto en horizontal bajo para evitar solapamientos.
- [x] Click real abrió calendario, siguiente mes mostró NOVIEMBRE y volver a hoy
  regresó a OCTUBRE. Cierre por botón recuperó acceso y dejó ZB_MenuOpen=false.
- [x] Desktop 1087×629 e iPhone 17 Pro 750×381 / 401×778: capturas, scroll hasta las
  tres misiones; ocho Caption con TextFits=true y cero estados de fecha desbordados
  en vertical. Sensor y DeviceSafeInsets conservados; no equivale a touch físico.
- [x] QA local y reversible de deshabilitado/RECLAMADA y HECHA/✓, sin enviar cobros;
  saldo 500 conservado. Output final sin errores de UI. 14 Artwork y cero fondos
  ZBAtlas_Background duplicados.
- [x] DailyActivities final 22933 bytes / hash 370268479. Lobby en Edit, simulador
  default y respaldo preservado; Match no se modificó en esta revisión del calendario.
- [ ] Aceptación visual del usuario, teléfono físico y versión publicada. Sin publicar.

Guía exacta de edición y revisión del contraste: UI_ASSETS y DISENO, corte 28/10.
Las verificaciones del 27/10 de abajo conservan sus fechas y diseños anteriores.

### Marco nuevo del calendario — 27/10

- [x] Sustituir marco antiguo y botones violetas en ZB_DailyActivities de Lobby
  por Artwork locales del estilo azul/dorado de mochila: panel, calendario,
  recompensa, tres misiones y ocho botones. Caption sigue datos reales del botón.
- [x] Conservar slots/colores de historial, fechas UTC, remotes y cobros existentes.
  Match no tiene calendario; no se agregó UI de Lobby a combate.
- [x] QA desktop 1045×572: siguiente mes, volver a hoy, textos completos;
  14 Artwork y cero ZBAtlas_Background antiguos en la pantalla.
- [x] iPhone 17 Pro 750×381 y 401×778: capturas, scroll vertical a las tres
  misiones y cierre. Sensor/DeviceSafeInsets conservados; sin errores de UI.
- [x] Respaldo Lobby ZB_CalendarArtworkBackup_20261027; Edit/default al terminar.
- [ ] Aceptación visual y prueba publicada/touch físico. Sin publicación ni
  cobros de QA en esta tarea. Rutas e imágenes en UI_ASSETS.

### Accesos Alt/Tab/salida compactos y cartel Libre retirado — 27/10

- [x] Aplicar en Lobby `125075465377023` y Match `108298899371591`:
  plantillas 180×60, fuente 11, margen inferior/derecho 12 y gap 2; textos cortos.
  Match conserva su retorno L. BattleHudArtwork sostiene el layout en ejecución.
- [x] Ocultar y vaciar MatchStatus en Libre, conservando mensajes de cola/VS.
- [x] Capturas Play desktop de ambos Places y TextFits=true en los tres accesos.
  Lobby: Libre real, Alt alterna texto, Tab mantenido abre tabla y click en salida
  retorna a LOBBY/BattleParticipant=false; cartel Libre permanece oculto.
- [x] Match con estado visual local de QA; sin TeleportData válido. Los errores
  de rechazo/retorno de su Play aislado coinciden con el comportamiento documentado.
  No se registraron errores de UI en Lobby.
- [x] Respaldos por Place ZB_CompactBattleAccessBackup_20261027; Play detenido
  en ambos. Detalle de rutas/atributos en UI_ASSETS.
- [ ] Aceptación visual del usuario y comprobación publicada. Sin publicación;
  no se repitió QA móvil ni se validó una partida VS real en esta tarea.

### Corrección del marco tras la captura del usuario — 26/10, B27

- [x] Reconocer que las uniones señaladas fueron introducidas al segmentar el marco;
  la QA visual de la primera composición no queda aceptada.
- [x] Preparar el original completo como battle_general_frame_full.png, 1024×341,
  sin recortar el lienzo; subir 138592401278319 y usarlo en ambos Places.
- [x] Retirar las cuatro subpiezas y usar un ImageLabel Fit con ImageRect en cero;
  encajar textos/iconos dentro de su superficie real y ajustar accesos en ventana baja.
- [x] Captura Lobby escritorio e iPhone 17 Pro 750×381; marcos continuos, sin uniones.
  Los accesos inspeccionados tienen TextFits=true y cero piezas de segmentación.
- [x] Match escritorio con estado local de QA: misma imagen, textos que caben,
  retorno propio y contador separado de tabla. No equivale a VS real.
- [x] Paridad final del módulo 13259 bytes / hash 1436495399; respaldo por Place
  ZB_BattleHudFullFrameBackup_20261026, Edit/default y servidor de subida cerrado.
- [ ] Confirmación visual del usuario y Player/teléfono físico. Sin publicación.

### Barras y marco del HUD de las referencias — integración del 26/10

- [x] Confirmar ambos Places como el mismo juego (Libre y VS) y aplicar al HUD
  mostrado en las referencias. Conservar los menús interiores y placa del manual.
- [x] Preparar tres PNG sin sobrescribir fuentes: barras 496×120 y marco 1024×275;
  subir IDs 91629418883833 / 95575967228479 / 104332063179973.
- [x] Respaldar fuentes y plantillas por Place en ZB_BattleHudArtworkBackup_20261026.
- [x] Integrar Shared.BattleHudArtwork y UIAssets.BattleHud, reutilizando Fill y
  botones existentes; marco también en TeamScore VS. Conservar CoinsLabel.Icon
  para el vuelo/pulso de monedas. Rehabilitar ScreenGui de mochila de Lobby.
- [x] Corregir conflicto móvil de dos layouts que alternaban Position: el viejo
  omite controles marcados. Guardas de logo compacto para ImageLabel sin Symbol/Brand.
- [x] Libre real por remote existente: mouse consumió arma 100→58.6, Fill mínimo
  .586; Q consumió gancho 100→83.5875, Fill mínimo .835875. Regeneración posterior.
- [x] B abrió mochila; click de acceso abrió tabla; click en salida devolvió LOBBY,
  BattleParticipant=false y barras ocultas. Intento de Tab no concluyente.
- [x] Respawn real Libre: un HUD, dos adornos de barra y coin Icon visible.
- [x] Match con estado local de QA, no teleport: Fill=.5/.25 y pruebas de 0/1;
  texto propio VOLVER AL LOBBY [L] y header VS conservados.
- [x] Tres imágenes Success en ambos; capturas desktop y iPhone 17 Pro 750×381,
  controles móviles/joystick sin solapamiento con barras y score/monedas separados.
  B del simulador abre mochila y oculta acciones; no es touch físico.
- [x] Arranque móvil final Lobby sin errores nuevos de UI; Match solo rechazos de
  TeleportData/HTTP esperados al abrirlo aislado. Corregidas las incidencias de QA B26.
- [x] Paridad de BattleHudArtwork/MobileHudLayout/HudController; Atlas conserva
  diferencias propias de Place. Retirar fixtures al detener, Edit/default en ambos,
  cerrar servidor local de subida. Guía y archivos/IDs en UI_ASSETS.
- [ ] Aceptación visual del usuario y prueba publicada/teléfono físico, incluido
  score/roster 4v4, touch real, latencia y permisos de imágenes en servidores nuevos.

Sin publicación. Las mediciones de energía proceden de la integración de Fill
actual; los ajustes posteriores fueron de marco, layout y compatibilidad del logo.

### Auditoría y adaptación a cambios del equipo — 2026-10-26

**Realizado: inspección estática en Edit de ambos Places**, lectura de los ocho
Markdown principales y README de assets/UI. Lobby PlaceVersion 784, Match 205,
GameId compartido 10498600200. Versiones de DataModel, sin certificar publicación
de cambios Edit. Captura del Lobby confirma la mochila editable visible en edición.

- [x] Inventariar scripts activos/deshabilitados y comparar fuentes/configuración
  de UI, combate y presentación. Leer implementaciones nuevas y sus consumidores.
- [x] Documentar mochila editable **solo Lobby**: Panel/Sidebar/Summary/Cards,
  Templates.CatalogCard, EquipmentDashboardLayout y guarda EditableEquipment.
- [x] Documentar Rankings3D, API, puente desde RankService, cuatro filas por panel,
  DemoMode=false y HologramMotion. No confundir ejemplos Edit con datos reales.
- [x] Registrar música por zona, pausa de animaciones congeladas/impulso de ragdoll,
  lanzamiento visual del gancho y PresentationSettings presentes en ambos Places.
- [x] Corregir la regla documentada de power-ups: vida 10 s, respawn tras recogida
  10 s, recolocación inmediata al expirar; aviso compartido para aparición y azul.
- [x] Actualizar rutas de vitrinas, tres acciones móviles vigentes y ausencia de
  placas/Hologramas antiguos. Congelados carece de Cabecera/Estado (B25).
- [x] Comprobar en Edit Lighting azul/violeta y ausencia de sombras locales/globales;
  consultar Output: Lobby solo entrada de edición; Match aviso de MaterialManager.
  No equivale a arranque limpio de scripts en Play.
- [x] Mantener las aceptaciones reportadas por el usuario el 21/10; no repetir el
  recorrido confirmado como si nunca se hubiera probado.

**Adaptación pendiente (B24):**

- [ ] Migrar mochila editable a Match como conjunto de plantilla, controlador y
  EquipmentDashboardLayout; conservar funciones de Match sin ventas/calendario.
- [ ] Asignar tres imágenes de WeaponImages en Match (actualmente vacías) y revisar
  WeaponOffers, ausente en Match. Persistencia de passes no demuestra paridad UI.
- [ ] Sincronizar el Grip corregido del Rifle: Lobby (0,-.2,.9), Match (0,0,0).
  No cambiar balance/escala al trasladar ese ajuste; volver a probar montaje/Muzzle.
- [ ] Si se busca feedback idéntico, llevar a Match UIInteractionController y
  Motion con Sounds/configuración; Match conserva la versión anterior sin audio.
- [ ] Revisar si restaurar Cabecera/Estado del ranking Congelados; verificar datos
  reales y aspecto de los tres paneles después de iniciar Play.

**QA de los cambios encontrados, todavía sin ejecutar en esta auditoría:**

- [ ] Nueva mochila: arranque oculta vista Edit, B/E/cierre, categorías, compra/equipado,
  datos reales, scroll, rotación, respawn y ausencia de duplicados tras la migración.
- [ ] Rankings: demostrar que Config/demo no reemplaza datos reales, fullFreeze Libre,
  victoria VS tras regreso, monedas y reconexión; top cuatro y actualización histórica.
- [ ] Power-ups: 10 s sin recoger→otro punto; recogida→10 s oculto; timers antiguos
  no duplican. Azul renovado dura 5 s, disparo no lo cancela y aviso distingue escudos.
- [ ] Congelamiento: animaciones propias/remotas pausadas, impulso único, reset/respawn
  restaura velocidades y cancela tareas viejas; gancho viaja visualmente y limpia al soltar.
- [ ] Música por participante (jugador en Lobby y otro en Libre), transición de Match,
  permisos de audios y volumen Hover≈4.516; comprobar mezcla en Player/teléfono.
- [ ] Revisar manual con texto incorporado para tres controles móviles; teléfono físico,
  casos específicos pendientes B13/B15/B19 y fallo de guardado/cambio de día UTC.
- [ ] Registrar versiones efectivamente publicadas y smoke test de los cambios nuevos.

Respaldos observados, no creados aquí: Lobby ZB_EditableEquipmentBackup_20261023,
ZB_Rankings3DBridgeBackup_20261023, ZB_UIButtonFeedbackBackup_20261023; ambos
ZB_FeedbackPolishBackup_20261016 y ZB_PowerUpLifetimeShieldBackup_20261019.
No se modificó Studio, inició Play ni publicó desde esta revisión documental.

#### Huellas de referencia leídas el 26/10

Longitud de Source en bytes / hash base31 módulo 2³². Sirven para comparar fuentes,
no certifican ejecución ni igualdad de plantillas, propiedades o comportamiento.

| Fuente | Lobby | Match |
|---|---|---|
| EquipmentDashboard | 23024 / 2677589399 | 22291 / 34353757 |
| EquipmentDashboardLayout | 10245 / 850543930 | Ausente |
| AtlasUIController | 21696 / 4147335155 | 21609 / 1326693876 |
| UIInteractionController | 11617 / 1629116197 | 3890 / 3701533704 |
| RankService.server | 14628 / 3379106746 | 12740 / 3786209 (responsabilidad distinta) |
| CombatRagdoll | 6221 / 2894033906 | Igual |
| AnimationFreeze | 2223 / 984481200 | Igual |
| FrozenAnimationController | 1240 / 4022265387 | Igual |
| HookVisualService.server | 7954 / 2768953496 | Igual |
| ZoneMusicController | 2221 / 2262914555 | Igual |
| PowerUpShield | 3007 / 3636150112 | Igual |
| SpawnProtectionController | 4719 / 1301181075 | Igual |
| MobileControls | 8921 / 193913164 | Igual |
| BattleCameraController | 8512 / 646660308 | Igual |
| GrabController.client | 18291 / 4155865169 | Igual |
| ShootingController.client | 23318 / 2990126624 | Igual |

Las fuentes de servidor específicas de Lobby/Match no se consideran regresión por
tener distinto hash. El corte 26/10 de DISENO/UI_ASSETS detalla contratos y rutas.

### Corrección de deformación y MarcoHUD — 2026-10-23

- [x] Reporte del usuario: rechaza el primer resultado porque los detalles de los
  bordes seguían estirados, también en ranking. No considerar aceptada aquella QA.
- [x] Ambos Places: nuevo `Shared.UIFrameArtwork`, nueve zonas y cuatro adornos
  con escala proporcional; solo relleno/uniones simples se extienden. Compensar
  UIScale local. `UIFrameSkins` reutiliza las piezas y los estados de botones.
- [x] Ranking: corregir proporción SurfaceGui según cara física. Lobby verifica
  tres CanvasSize 220×275, ratio .8 igual a la cara 20×25; antes 220×160.
- [x] Recibir `MarcoHUD.png`; preparar 1024×912 manteniendo proporción y subir
  `106613197873068`. Cuatro plantillas de panel/tarjeta en ambos Places usan el arte.
- [x] Deshabilitar el contorno UIStroke adicional de elementos enlazados, incluidos
  botones compactos y strokes agregados posteriormente. UIInteractionController
  deja de crear el segundo rectángulo/celeste de hover y su tween.
- [x] Deshabilitar diez contornos de miniaturas por Place en WeaponImages,
  HookTipImages y LaserImages. Respaldar sus plantillas.
- [x] Capturas finales de mochila en ambos Places y tienda/calendario en iPhone
  17 Pro horizontal (750×381); hover y click real a Armas en Lobby. Inspección
  final de mochila/tienda: cero contornos extra activos y cero objetos de borde
  de hover. Miniaturas regeneradas con Enabled=false en runtime, misma propiedad
  persistida en las plantillas de Edit. Sin errores nuevos de UI en Output.
- [x] Paridad por hash de UIFrameArtwork, UIFrameSkins y UIInteractionController;
  ambos Places en Edit, viewport normal y servidor de subida cerrado. Sin publicar.
- [x] Respaldos por Place `ZB_FrameUndistortedBackup_20261023` y
  `ZB_MarcoHUDBackup_20261023`. Proceso/IDs y arquitectura en UI_ASSETS.
- [ ] Aceptación visual final del usuario y prueba publicada/teléfono físico.

### Panel ámbar en mochila, tienda y calendario — 2026-10-23

Primera integración: sustituida por el ajuste MarcoHUD de arriba tras rechazo
visual del usuario; sus capturas no acreditaron ausencia de deformación.

- [x] Reutilizar `ui_panel_warning.png` / `113491494447703`, registrado en el
  catálogo; `ScaleType=Slice`, `SliceCenter=(120,110)–(392,346)`, escala base .24.
- [x] Ambos Places: `ZB_EquipmentDashboard.PanelFrameSkin="panel_warning"`;
  EquipmentDashboard declara el skin antes de insertar el Panel en la GUI.
- [x] Lobby: calendario `ActivitiesPanel.UIFrameSkin="panel_warning"`.
  Tienda comparte el panel de mochila; Match conserva únicamente su mochila.
- [x] Capturas Play: mochila en ambos Places, calendario escritorio, tienda y
  calendario iPhone 17 Pro horizontal (750×381), calendario vertical. Arte cargado
  y 9-slice activo. Tienda/calendario abiertos con evento/propiedades de cliente;
  no se probaron compras, cobros ni touch físico en esta tarea.
- [x] Respaldo `ServerStorage.ZB_WarningPanelsBackup_20261023` en ambos Places;
  guía/rutas en UI_ASSETS. Ambos en Edit, simulador restablecido, sin publicación.
- [ ] Revisión visual del usuario y validación publicada/teléfono físico.

### Confirmación de extensión y prueba VS — 2026-10-21

- [x] Usuario confirma extensión de siete días: entrega el **27/10/2026**.
  Sustituye las notas históricas que la describen como pendiente de aprobación.
- [x] Usuario confirma pruebas de **entrada y salida de VS con tres personas**.
  Evidencia: reporte del usuario; sin versiones ni registro individual de casos.
- [ ] Precisar si esa prueba también cubrió retorno al mismo servidor con un tercero
  esperando, abandono/anulación, segunda entrada/barreras y formato 2v2. No asumir
  esos resultados ni repetir el recorrido general como si no se hubiera probado.
- [x] Usuario confirma además saldo, misiones, ranking y equipado después de completar
  VS, viajar y reconectar, sin pagos duplicados. Se acepta ese recorrido por reporte
  del usuario; sustituye los pendientes históricos equivalentes de esta lista.
- [ ] Cambio de día UTC y fallos de guardado: casos específicos no incluidos en esta
  confirmación. La compra nueva con una cuenta sin pase mantiene su prueba aparte.

### Ajuste móvil y cámara sobre el hombro — 2026-10-21

- [x] Tres botones en ambos Places: Fire rojo (112/96 px), Hook verde (80/68 px)
  a la izquierda y Grab azul (80/68 px) encima del disparo. Grab cambia de AGARRE
  a IMPULSO; gancho independiente. Icono de agarre dedicado y navegación superior
  `MobileNavY=16` para evitar solapamiento con mochila.
- [x] Acción `grab` selecciona cobertura cercana priorizando la mira; siguiente
  pulsación en estado Grabbing usa `launch`. QA mediante LocalScript temporal en
  Match: se agarra, levantar no suelta y pulsar impulso libera/desancla. Prueba
  controlada de runtime, no teléfono físico ni partida VS completa.
- [x] Sensibilidad táctil .0045→.005625 (+25 %). MobileAimInput observa Position
  del dedo registrado y desconecta al finalizar/cancelar el gesto.
- [x] Cámara móvil sobre el hombro: desplazamiento lateral 2.6 studs y altura
  adicional .8, editables en ZB_MobileControls. Raycast del desplazamiento y de
  distancia para colisiones. Mismo controlador/configuración en ambos Places.
- [x] Simulador iPhone 17 Pro, viewport 750×381: cabeza por debajo/a la izquierda
  del centro; captura visual confirma mira despejada. Ambos Places en Edit y
  viewport normal tras QA; fixtures únicamente runtime, retirados al detener.
- [ ] Teléfono físico y versión publicada: disparar+arrastrar+joystick, gancho,
  agarre/impulso, cuerpos congelados, cámara junto a paredes, menús/foco y salida.
- [ ] Revisar/actualizar el arte del manual para los tres controles móviles.

Respaldos por Place: `ZB_MobileThreeActionsBackup_20261021` y
`BattleCameraController_BeforeMobileShoulder_20261021` en ServerStorage. Sin
publicación desde esta sesión. Las secciones de dos botones se conservan como historial.

### Marco del manual, placa y botón ENTENDIDO — 2026-10-19

- [x] Diagnóstico del reporte: el marco visible del manual no era el fondo de
  `Instructions`, sino `ZBAtlas_Background`, inyectado por `UIAssetSkinController`
  desde `UIAssets.Skins.panel` por `UIFrameSkin="panel"`. Además `LoadingScreen.client`
  vuelve a poner `ZB_Intro.Enabled=true` al terminar la carga, así que apagarlo
  en StarterGui no lo oculta al entrar.
- [x] Crear un template dedicado `UIAssets.Skins.intro` y verificar que cambiar
  solo su imagen afecta al manual y no a `Skins.panel`.
- [x] Recibir y preparar la placa `placa inicio.png` (1024×768 RGBA,
  `rbxassetid://98656833460778`) y el botón `btn entendido.png` (1024×341 RGBA,
  `rbxassetid://106514786390752`).
- [x] Implementar **modo arte completo** en ambos Places: `Artwork` muestra la
  placa con textos incorporados; `Continue` es un ImageButton con el botón entero;
  `Logo/Title/Subtitle/Rows` quedan ocultos; `UIFrameSkin` vacío en el panel.
- [x] `AtlasUIController` calcula placa+botón por proporción, los centra y deja
  el botón **debajo** sin tapar las filas. Atributos editables `FullArtIntro`,
  `IntroAspect`, `ContinueAspect`, `ContinueWidthScale`, `ContinueGapScale`,
  `IntroMaxWidth`.
- [x] Respaldo automático: si falta `Artwork` o su `Image` está vacía, vuelve al
  manual clásico con las filas vivas en vez de mostrar una pantalla en blanco.
- [x] Corregir la diferencia Edit/Play reportada: el layout ahora escala la
  posición y tamaño del botón definidos en Edit, en vez de forzarlo debajo con
  una separación. El botón queda superpuesto al borde inferior de la placa.
- [x] QA Lobby escritorio: placa/botón cargados, sin contenido viejo superpuesto;
  botón superpuesto como en Edit; clic en ENTENDIDO cierra el manual. QA iPhone
  17 Pro 750×381: placa 373 px de ancho, texto legible; clic cierra. Match: misma
  placa/botón al habilitar el manual, ambos recursos `Success`; clic cierra.
- [x] Guía definitiva en UI_ASSETS 0.9: reglas de oro, mapa de cualquier imagen,
  placa completa, botón, 9-slice opcional, especificación PNG y diagnóstico.
  `assets/ui/frame_9slice_guide.png` creado para futuros marcos.
- [x] Confirmar que `PlayerGui.ZB_Intro.Enabled=false` oculta el manual en Play;
  editar `StarterGui` con Play en curso no cambia la copia activa.
- [ ] Publicar ambos Places y repetir en teléfono físico. La aceptación visual
  definitiva del arte queda a revisión del usuario.
- [ ] Si se quiere ocultar el manual al entrar, modificar `LoadingScreen.client`
  (hoy lo enciende) o retirar el flujo; no basta `Enabled=false`.

Sin respaldo adicional de gameplay: el cambio es de presentación. Guía y
especificación en UI_ASSETS 0.9; incidente B23.

### Láser rojo y cartel de escudo — 2026-10-19

- [x] Procesar/subir el PNG rojo y agregar `UIAssets.LaserImages.red` en ambos
  Places. Se completa el catálogo de cinco imágenes; tarjeta roja cargada y
  comprobada visualmente en tienda móvil, sin modificar precio/propiedad.
- [x] Procesar el aviso «PROTEGIDO / DISPARAR CANCELA EL ESCUDO» sin margen
  transparente excesivo. Plantilla `StarterGui.ZB_SpawnProtection` en ambos Places,
  ImageLabel Fit, cuenta atrás y fallback de texto; tamaños editables por atributos.
- [x] Nuevo SpawnProtectionController presenta solo `SpawnProtectionEndsAt`
  activo para un participante. No concede inmunidad ni cambia los servicios de daño.
  MatchStatus cede su fila mientras el aviso está visible; menús lo ocultan.
- [x] Retirar el constructor viejo del aviso en FreeSpawnTransitionController de
  Lobby conservando su confirmación de CFrame. Una plantilla, un controlador.
- [x] Entrada real a Libre muestra protección con 4.8 s restantes. QA visual con
  atributos controlados pasa para cero/expiración/menú; imagen cargada y fallback
  oculto. Match verifica UI con estado local de prueba, no con una ronda real.
- [x] Carga de los dos recursos Success en ambos clientes; capturas de aviso móvil
  520×84 y escritorio 620×100, sin aplastamiento ni superposición del estado.
- [x] Respaldos y paridad de controlador/HUD; fixtures solo runtime, ambos Places
  en Edit, simulador usado restablecido. IDs y edición en UI_ASSETS 0.8.
- [ ] Disparo manual durante protección y observador remoto en Player; el intento
  programado de disparo no confirmó la cancelación del servidor en esta QA.
- [ ] Validar permisos/carga publicados y teléfono físico.

Respaldo: `ZB_RedLaserProtectionUIBackup_20261019` por Place. Sin publicación.

### Móvil: apuntar disparando y soltar con impulso — 2026-10-19

- [x] Retirar Up/Down de `StarterGui.ZB_MobileControls` y sus bindings de
  MobileControls. Dos acciones circulares ampliadas, anillos e iconos: disparo
  112/96 px y gancho 96/84 px según altura segura. Joystick conservado.
- [x] Añadir `Shared.MobileAimInput`: delta por dedo sin confundir joystick,
  botones o UI. Arrastre del mismo dedo de disparo/gancho y otro dedo derecho
  libre; cámara de combate también activa en touch. Teclado/mouse conservados.
- [x] Acción local `launch`: Hook se convierte en IMPULSO mientras `Grabbing`.
  La pulsación llama al mismo `finishGrab(true)` del teclado. Prompts se ocultan
  mientras está sujeto; touch no depende de `PromptButtonHoldEnded`/soltar E.
- [x] QA Lobby: entrada Libre por remote real; intención sostenida de disparo y
  dos gestos controlados giran la cámara sin cortar fire. Eventos Touch del
  simulador también verificaron disparo+arrastre (dot inicial/final ≈0.982).
- [x] Agarre contra pieza temporal mediante E; liberación tocando IMPULSO en el
  simulador: `Grabbing=false`, root desanclado, velocidad inicial **90**, producto
  escalar **1** con la dirección inversa de cámara y retorno de Caption a GANCHO.
  El intento `InputHoldBegin` del fixture no activó el prompt; no se toma como
  prueba de la pulsación inicial de agarre en touch físico.
- [x] Abrir menú cancela intención de disparo y delta; cerrar no vuelve a disparar.
- [x] Match/Galaxy A06: estado local de combate para QA, cámara con fire y segundo
  gesto pasa (dot ≈0.981), cancelación por menú pasa. No equivale a VS/teleport real.
- [x] Capturas iPhone 17 Pro 750×381 y Galaxy A06 705×338, sin acciones encimadas;
  textos completos, Fire/Hook cargados en Lobby. ScreenOrientation=Sensor y
  controles de combate solo landscape; DeviceSafeInsets conservado.
- [x] Cinco fuentes compartidas iguales por bytes/hash entre Places; dos botones
  por plantilla. Fixtures y puntos de depuración retirados; Edit/default en ambos.
- [ ] Teléfono físico: joystick+disparo+arrastre, segundo dedo de cámara, gancho→
  prompt táctil de agarre→IMPULSO, cuerpos congelados, pérdida de foco y salida.
- [ ] Publicar ambos Places y repetir en Libre/VS, con observador remoto y latencia.

Respaldo por Place: `ZB_MobileAimReleaseBackup_20261019`. QA controlada y de
simulador, sin publicación. Guía editable en UI_ASSETS 0.1. Incidentes B21/B22.

### Corte preentrega — 2026-10-19

- Entrega original **20/10**. Solicitar extensión mínima de siete días, propuesta
  **27/10**; **sin confirmar**. Plan vigente y criterios beta en
  [PLAN_10_DIAS](PLAN_10_DIAS.md#replanificación-vigente--19102026-beta-y-extensión-solicitada).
- **Prioridad del usuario para hoy 19/10 y mañana 20/10:** cambios de móvil y,
  cuando corresponda, de UI/assets. Revisar controles, multitáctil, apuntado,
  menús/scroll, salida, orientación, zonas seguras y rendimiento en teléfono real;
  usar simulador solo como verificación visual complementaria.
- **Propuesto para la extensión:** colección premium completa, capa global y
  video, junto con cierre de QA pendiente. Informe de anuncios preparable durante
  esa semana; **activación sin fecha comprometida** hasta cumplir elegibilidad.
  El usuario reporta insuficientes jugadores activos; comprobar modalidad y
  requisitos en Dashboard, sin dar por verificado un umbral concreto.
- [x] Congelamiento azul en ambos Places: nuevo `Config.FreezeAppearance`,
  parcial RGB(140,210,255), total RGB(75,180,255), material `Ice`. Al 100 % afecta
  las partes corporales directas (R15/R6), excluyendo HumanoidRootPart.
- [x] QA controlada con clon R15 y el FreezeService real en cada Place: daño
  parcial→total, **15 partes** azules/Ice, armas/accesorios anidados intactos,
  reset de todos los colores/materiales y segundo ciclo/reset idempotente.
  Fixtures solo en Play; retirados al detener. Ambos Places quedan en Edit.
- Respaldo: `ServerStorage.ZB_IceAppearanceBackup_20261019` por Place. No publicado
  por el asistente. Falta QA entre jugadores reales y visibilidad remota.
- [x] Sesiones previas de esta conversación: intro actualizada en ambos Places;
  carteles flotantes de estado de armas retirados; dos ganchos activos con cartel,
  imagen y E; hologramas/HoloLevitation retirados; BillboardGui limitados a 20 studs.
- [x] Cinco imágenes de láser integradas en ambos catálogos UI. Las primeras
  cuatro se verificaron anteriormente; rojo entregado e integrado posteriormente
  el 19/10, con carga y captura de su tarjeta. Detalle en la sección de arriba.
- [x] Cartelera de Libre integrada en `AnimationIconSign`, cuatro notificaciones
  recientes con fotos/nombres/cruz y caducidad 90 s; presentación/filtro probados
  con datos simulados. No equivale a acreditar un congelamiento multijugador real.
- [ ] QA publicada prioritaria: datos/pagos únicos, retorno con tercero en Lobby,
  encuentro completo/anulado, segunda entrada VS, cuerpos/respawn y móvil real.
- [ ] Resolver evidencia de compra real del Cañón y paridad del catálogo/derechos
  en Match. Inspección actual Lobby: `AutoGrantPasses=true`, Cañón conectado,
  Rifle sin PassId válido. Las notas antiguas de false describen estados previos.
- [ ] Autorizar/publicar candidata de ambos Places, registrar versiones y probar
  en servidores nuevos. No dar por cerrado el sprint ni el contenido externo
  por los cambios de presentación.

Las secciones anteriores al 19/10 se conservan como historial. Sus descripciones
de hologramas, controles del manual y carteles dinámicos de armas quedaron
sustituidas por este corte; no reactivarlas siguiendo una nota antigua.

### Montaje del Rifle corregido — 2026-10-16

- [x] Reporte del usuario: el Rifle se agarra desde el medio. Se calculó la
  empuñadura real con la malla (vértices más bajos → Z≈+0.90) y se movió
  `Handle.Grip` de `(0,0,0)` a `(0,-0.2,0.9)`.
- [x] Verificado que el Cañón no lo necesitaba (su mango está en Z≈+0.06).
- [x] Aclaradas las capturas: `@whitechocolatediaz` tiene el **Rifle** (comprado
  antes con monedas) y no el Cañón; mochila y tienda coinciden.
- [ ] Confirmar visualmente el montaje en juego (la captura del asistente no pudo
  mover la cámara del Lobby).

Respaldo: `ServerStorage.ZB_RifleGripBackup_20261016`.

### Pase del Cañón conectado — Lobby (+derecho en Match), 2026-10-16

- [x] Confirmar con el usuario: el Cañón pasa a ser **solo con el pase**; se quita
  la compra con 250 monedas. Quienes ya lo poseían lo conservan.
- [x] Configurar `WeaponOffers.cannon`: PassId=2039918698, PassPriceRobux=10,
  PurchaseIntegrationReady=true.
- [x] `WorkshopService.grantWeapon/ownsWeapon` y bloqueo de compra con monedas
  para armas de pase no poseídas.
- [x] `MonetizationService` (Lobby): verifica `UserOwnsGamePassAsync` al entrar,
  concede el arma, registra `profile.passes` y guarda; concede tras
  `PromptGamePassPurchaseFinished`. El cliente no declara propiedad.
- [x] DataService (Lobby y Match) guarda y conserva `profile.passes`.
- [x] Cliente: tarjeta **DESBLOQUEAR · N R$** con precio real (`GetProductInfo`)
  y `PromptGamePassPurchase`; rifle sin ID sigue PASE PRÓXIMAMENTE.
- [x] QA: con el pase, concede y equipa el Cañón (500 monedas intactas,
  `passes={"2039918698":true}`); sin el pase, tarjeta DESBLOQUEAR · 10 R$;
  compra con monedas de un arma de pase rechazada sin cobrar. Sin errores.
- [x] Reset pre-lanzamiento: `WeaponPassReset` (módulo, ambos Places) quita una vez
  el Cañón de los testers y limpia `passes` para poder probar la compra; idempotente
  por `migrations.weaponPassReset`; no toca otras armas. Probado con perfiles
  simulados (quita Cañón, respeta Rifle, segunda pasada sin cambios).
- [x] Diagnosticar el reporte "todos tienen el Cañón": `UserOwnsGamePassAsync`
  devuelve **true para la cuenta creadora** y false para otras (userId 1/156); en
  Studio multijugador todos son la misma cuenta. No era un fallo del reset.
- [x] Interruptor `ReplicatedStorage.Monetization.AutoGrantPasses` (hoy false):
  no concede al entrar; la compra confirmada sí concede. **Poner true antes de
  lanzar.** Verificado en Studio: el Cañón muestra DESBLOQUEAR · 10 R$.
- [x] Corregir la contradicción "lo tengo en la mochila pero la vitrina lo ofrece":
  el cartel de la vitrina era texto fijo. `WeaponDisplayController` ahora crea un
  BillboardGui **por jugador** (con fondo, `AlwaysOnTop` y tamaño legible) con el
  estado real (LA TENÉS / DESBLOQUEAR · 10 R$ / PASE · PRÓXIMAMENTE / GRATIS).
  Verificado: con el Cañón poseído muestra LA TENÉS; sin poseerlo, DESBLOQUEAR · 10 R$.
  Solo un store activo (EquipmentDashboard); los otros dos (`StoreDashboard`,
  `WorkshopController.client`) están deshabilitados.
- [x] `AutoGrantPasses` restaurado a **true** (producción). El error "Ya tienes este
  objeto" al pulsar DESBLOQUEAR confirma que la cuenta **ya posee el pase**; para
  probar la compra real usar una cuenta que no lo posea.
- [ ] Compra real con Robux usando una cuenta tester **sin** el pase (la que ya lo
  posee ve EQUIPAR y no puede recomprar); cancelación/reconexión y viaje
  Lobby→Match→Lobby publicados.
- [ ] Crear y conectar el pase del Rifle; documentar precio/contenido.

Respaldo Lobby: `ServerStorage.ZB_CannonPassBackup_20261016`. Guía en UI_ASSETS 0.5.
`WeaponPassReset.VERSION=1`; subirlo para re-ejecutar el reset.

### Historial y colores del calendario — Lobby (+datos en Match), 2026-10-16

- [x] Confirmar objetivo del usuario: verde=cobrado, rojo=sin cobrar, otro=disponible.
- [x] Crear `ServerScriptService.DailyClaimHistory`; `daily` guarda `claimedDays`,
  `historyStartDay` y `historyVersion=1`. DailyRewardService acredita saldo y fecha
  en la misma mutación, con guarda anti-doble-cobro.
- [x] DataService (Lobby y Match) normaliza y preserva el historial al cargar,
  capturar y guardar; no se pierde al viajar. Módulos idénticos por hash.
- [x] Calendario pinta estado por color; colores editables como Attributes del
  ScreenGui y leyenda actualizada. Atributos ClaimState/ConfirmedClaim por slot.
- [x] Días previos sin registro quedan gris "SIN DATOS"; no se pintan de rojo para
  no inventar historial. El perfil antiguo solo migra su último cobro confirmado.
- [x] QA reloj de prueba: migración conserva cobro; 500→550→600 por dos cobros;
  día intermedio missed; repetidas no duplican; guardado preserva 3 fechas y el
  hueco. Match conserva 2 fechas al capturar/guardar.
- [x] Smoke test con reloj real: hoy available, 18 unknown, 23 futuros. Sin fixtures;
  respaldos y ambos Places en Edit.
- [ ] Publicar y validar medianoche real, reconexión y cruce Lobby→Match→Lobby;
  gasto/persistencia del cobro con DataStore real.

Respaldo: `ServerStorage.ZB_DailyHistoryBackup_20261016`. Guía en UI_ASSETS 0.7.

### Cable genérico 3D — Lobby y Match, 2026-10-16

- [x] Confirmar alcance con el usuario: una apariencia genérica, solo estética;
  Navidad era un ejemplo futuro, sin skins estacionales/consumibles nuevos.
- [x] Crear RopeSkins.Generic con cuerpo cilíndrico Fabric y refuerzos editables.
- [x] HookRopeRenderer sigue los extremos replicados y oculta el Beam plano solo
  localmente; partes sin colisión/query. Sin cambiar física ni compras/inventario.
- [x] QA de geometría horizontal/vertical, máximo 25 piezas a 150 studs, extremos
  coincidentes, retiro de marcador y limpieza de cero cables.
- [x] Lobby: gancho real por intención controlada, cuerpo 3D del dueño, fuerza y
  consumo existentes; liberación limpia. No certifica teclado Q ni touch físico.
- [x] Match: fixture visual de 16 studs y limpieza; renderer igual en ambos Places.
- [x] HookController y HookVisualService intactos contra respaldo; fuerza 1000,
  velocidad 70, alcance 250 y catálogo de tres entradas heredadas conservados.
- [x] Retirar fixtures, dejar ambos Places en Edit y documentar edición/reversión.
- [ ] Prueba publicada multicuenta, visibilidad remota, touch y FPS.

Respaldo por Place: `ZB_GenericHookRopeBackup_20261016`. Sin publicar. UI_ASSETS 0.6.

### Imágenes y vitrinas de armas — Lobby, 2026-10-16

- [x] Separar fuente 2172×724 en tres PNG RGBA 512×512; subir/aplicar imágenes
  blaster/rifle/cannon y verificar carga 3/3. IDs/proceso en UI_ASSETS 0.4.
- [x] Clonar tres contenedores iguales al de basegancho1 en WeaponDisplays;
  montar modelos estáticos centrados, carteles con imágenes y prompts E.
- [x] Conservar basegancho1/2/3: comparación con respaldo sin cambios.
- [x] Abrir la misma TIENDA / ARMAS desde cada vitrina, con foco/scroll hacia
  su ficha. Crear WeaponOffers con PassId=0 y venta GamePass pendiente para dos.
- [x] E real de las tres vitrinas; tarjeta pendiente no cobra/equipa. Respawn
  deja una GUI, tres vitrinas, tres prompts y 38 piezas ancladas; saldo 500 intacto.
- [x] Capturas desktop/móvil horizontal y scroll al Cañón; sin errores nuevos
  del proyecto. Sin fixtures; Edit/default y servidor HTTP de subida cerrado.
- [ ] Sincronizar imágenes/catálogo/controlador/plantilla de armas a Match;
  se abrió después para el cable genérico, pero esa UI sigue pendiente.
- [ ] Crear/configurar los dos pases y conectar compra oficial, derechos de servidor,
  propiedad anterior, cancelación, persistencia y teleport. Venta no activada.
- [ ] Publicar y comprobar dispositivos reales/multicuenta.

Respaldo Lobby: `ServerStorage.ZB_WeaponShowroomBackup_20261016`. Guía en UI_ASSETS 0.5.

### Revisión de armas e imágenes propias — 2026-10-14

- [x] Corregir el frente invertido del SMG/Rifle señalado en la captura del usuario;
  mantener punto de empuñadura y ubicar Muzzle en el extremo correcto.
- [x] Aumentar Rifle y Cañón uniformemente un 15 % en ambos Places; longitudes de
  cuerpo 2.99 y 3.68, escala 1.15, alineación cuerpo/Muzzle dot 1.
- [x] Crear `UIAssets.WeaponImages.blaster/rifle/cannon`, ImageLabels editables
  con Fit, recuadro 96×102 y marcador mientras Image está vacío.
- [x] Conectar tarjetas por WeaponPreviewId; retirar iconos genéricos de las
  tarjetas de armas y separar imagen de nombre/estadísticas/acción.
- [x] Capturas del montaje revisado, tarjetas desktop/móvil horizontal en ambos
  Places, textos que caben y marcador oculto al asignar imagen temporal.
- [x] Respaldo de modelos/controladores, paridad UI y retiro de fixtures;
  ambos Studios en Edit y simulador default. Guía en UI_ASSETS 0.4 y DISENO.
- [x] Asignar imágenes reales en Lobby el 16/10; IDs y evidencia en UI_ASSETS 0.4.
- [ ] Sincronizar esas imágenes a Match cuando esté abierto.
- [ ] Publicar y repetir montaje/apuntado con dos cuentas y touch real.

Respaldo: `ServerStorage.ZB_WeaponPresentationBackup_20261014`. Sin publicación.

### Modelos Rifle SMG y Cañón láser — 2026-10-14

- [x] Revisar modelos SM_Wep_SMG_01 y SM_Wep_Laser_Gun_01 importados en Lobby;
  respaldar y conservar originales en ServerStorage.WeaponImportSources.
- [x] Adaptar escala/orientación, Handle/Grip y Barrel/Muzzle; plantillas rifle/cannon
  en ambos Places, conservando blaster gratuito e IDs/estadísticas/precios actuales.
- [x] Dos meshes y dos marcadores por arma, welds, sin colisión/anclaje ni masa extra;
  montaje y Muzzle replicados visibles en capturas de ambos Places.
- [x] Cinco cambios de arma y respawn real por Place: una sola arma. Cambio con
  energía 30→31.8 por regeneración, sin refill.
- [x] Libre real en Lobby y prueba de beam controlada para ambos modelos:
  dos beams desde Muzzle, 100→90.1 energía; alineación de mira >0.999999.
- [x] Mismos MeshIds/textura en ambos Places, fixtures retirados, controles Edit
  habilitados y ambos Places en Edit. Contrato y reversión en DISENO.
- [ ] Publicar y comprobar observador remoto, VS real y rigs adicionales.
- [ ] Conectar los dos modelos de pago con pases Robux y derechos en servidor;
  esta adaptación conserva las compras con monedas existentes.

Respaldo: `ServerStorage.ZB_WeaponModelsBackup_20261014` por Place. Sin publicación.

### B19 — barreras de spawn desancladas en VS, 2026-10-14

- [x] Reproducir MatchArenaPhysics desanclando SpawnShieldRojo/Azul: 0/10 piezas
  ancladas y trims convertidos a colisionables en Play.
- [x] Respaldar script/modelos en Match y excluir `SpawnCover=true` de weldModel.
- [x] Dos arranques Play consecutivos: 10/10 ancladas, trims sin colisión,
  desplazamiento cero tras impulsos; 16 coberturas dinámicas con física conservada.
- [x] Consultar Output, detener Play y documentar causa/alcance/reversión en BUGS B19.
- [ ] Publicar Match y repetir dos entradas 1v1 con cuentas reales, verificando
  estabilidad de los escudos en servidores nuevos y agarre contra ellos.

Respaldo Match: `ServerStorage.ZB_SpawnCoverBackup_20261014`. Sin publicación.

### Postprocesado y feedback de monedas — 2026-10-14

- [x] Reutilizar ZB_StationColor en ambos Places: tinte RGB(226,219,255), saturación
  0.045, contraste 0.035, brillo 0.015. Sombras globales/locales desactivadas.
- [x] Contador de monedas editable en StarterGui.ZB_CoinFeedback, visible también
  en batalla y adaptado por MobileHudLayout.
- [x] Evento visual de BattleStats al acreditar fullFreeze; nueve sprites con
  dispersión, Tween curvo hacia el icono y pulso de llegada, sin cambiar pagos.
- [x] QA Studio con acreditaciones/objetivo simulados en ambos Places; capturas
  desktop/móvil horizontal, autoimpacto rechazado, saldo intacto, limpieza final.
- [x] Comprobar límite de 36 sprites y cancelación de tareas diferidas en Lobby;
  paridad de CoinBurstEffect/CoinFeedbackController/BattleStats entre Places.
- [x] Respaldar y documentar en luces/UI_ASSETS; retirar fixtures y dejar Edit/default.
- [ ] Congelamiento real publicado con dos cuentas y revisión de sensación/FPS/touch.

Respaldo: `ServerStorage.ZB_VisualFeedbackBackup_20261014`; sin publicación.

### Accesos del HUD editables y padding — 2026-10-14

- [x] Migrar mochila, acceso de tabla y cursor a plantillas StarterGui en Lobby
  y Match; salida X en Lobby y retorno L en Match. Controladores enlazan los botones.
- [x] Aumentar padding interior y separación de accesos; ContentPadding editable
  y atributos de tamaño/margen/separación móvil en ZB_EquipmentDashboard.
- [x] Compensar padding del fondo 9-slice para conservar el tamaño del contenedor.
- [x] Retirar del HUD la opción antigua de próxima batalla y sus conexiones UI.
- [x] Verificar copia única, ausencia de RoundOptions, texto que cabe y capturas
  desktop 1211×593/móvil horizontal 750×381 en ambos Places. B, Tab y Alt en Lobby
  con fixture visual local; no se invocó salida/teleport para esta prueba.
- [x] Documentar rutas/edición en UI_ASSETS (0.2); comprobar icono compartido bag;
  respaldar controladores/layout móvil y dejar ambos Places en Edit, simulador default.
- [ ] Publicar y validar estos accesos con touch físico y flujo de batalla real.

Sin publicación. Respaldo: `ServerStorage.ZB_HudEditableBackup_20261014`.
Este cierre cubre accesos y presentación; paneles internos siguen dinámicos.

### Atlas de UI integrados — 2026-10-13

- [x] Recortar fuentes reales a 16 iconos, 8 estados de botones y 4 paneles;
  retirar damero pintado de marcos. PNG, manifiesto e IDs en `docs/assets/ui/`.
- [x] Subir recursos y usar los mismos IDs en Lobby y Match; 28/28 cargados en ambos.
- [x] Iconos Fit; paneles/botones Slice con esquinas escaladas uniformemente,
  texto independiente y fondos nativos de respaldo.
- [x] Manual, inventario y calendario con el arte; violeta para gancho/actividades,
  ámbar para resultados. Controles redondos mantienen forma y usan iconos nuevos.
- [x] Mouse desktop: Continue, mochila, calendario, presión y selección de navegación.
  Simulador iPhone 17 Pro: horizontal y calendario vertical; no equivale a touch físico.
- [x] Contraste de Reclamar, reaplicación sin otro fondo, disabled, regeneración
  de tarjetas y respawn sin duplicados. Cinco fuentes iguales/compiladas.
- [x] Respaldo `ServerStorage.ZB_UIAtlasBackup_20261013`; fixtures retirados,
  simuladores default y ambos Places en Edit.
- [ ] Publicar y probar carga/touch físico, compra/cobro y flujos VS multicuenta.

Guía de edición, coordenadas y reversión en UI_ASSETS. No se publicaron los Places.

### B17/B18 — agarre con gancho y manual sin espera, 2026-10-13

- [x] Respaldar GrabController, HookController y AtlasUIController por Place en
  `ServerStorage.ZB_GrabHookBackup_20261013`.
- [x] Agarre disponible durante Hooking, activación voluntaria y relevo que retira
  tracción sin borrar el impulso. Registro fuerte de prompts con limpieza al destruir.
- [x] QA controlada de avisos: Lobby 61 / Match 58 antes/durante/después de gancho;
  menú/scoreboard/countdown deshabilitan, reactivación restaura.
- [x] Funciones exactas con transporte simulado: sujeción, fuerza cero, liberación
  a 90 y liberación tardía de gancho sin borrar impulso; cancelación sin impulso.
- [x] AtlasUIController inicia sin ZB_Intro; manual tardío enlazado por eventos,
  sin fallback vacío. Mouse abre/cierra ayuda y respawn conserva una copia en ambos Places.
- [x] Compilación/paridad de tres fuentes, fixtures retirados y ambos Places en Edit.
- [ ] Player: trayecto físico Q/E y touch; cobertura móvil, visual remoto/energía,
  cuerpo congelado y restauración B13. Intento de teclado con fixture no concluyente.
- [ ] Publicar ambos Places y repetir B15/B16 con grupo/reconexión reales.

Detalles y límites en BUGS. Sin publicación desde esta sesión.

### Controles táctiles y UI móvil — 2026-10-09

- [x] `ReplicatedStorage.Shared.LocalCombatInput`: bus de intención local con
  soporte de múltiples dedos por acción; no concede autoridad de daño/energía.
- [x] `StarterGui.ZB_MobileControls` en ambos Places: botones redondos
  DISPARAR (mantener), GANCHO (mantener), SUBIR y BAJAR. Iconos de UIAssets,
  UICorner redondo y UIStroke; atributo `MobileControls=true`.
- [x] `StarterPlayer.StarterPlayerScripts.MobileControls`: solo visible con
  `TouchEnabled` y landscape; asocia cada dedo al botón, suelta al perder foco,
  abrir teclado, abrir menú o cambiar de estado, sin reactivarse al cerrar UI.
- [x] HookController y ShootingController consumen el bus: mismo disparo/energía
  (beam), gancho y cooldown que teclado/mouse; mira centrada en táctil.
- [x] MovementController: lee el joystick nativo (`GetMoveVector`) en 0g y usa
  SUBIR/BAJAR como R/Ctrl; conserva teclado y preserva caminata del Lobby.
- [x] `MobileHudLayout`: accesos redondos redistribuidos (mochila, diario, ayuda,
  tabla, salir), librería de recursos, monedas, LED y encabezado VS adaptados.
  Insets `DeviceSafeInsets`; rota bien en teléfono pequeño y con roster 4v4.
- [x] Guardas en AtlasUIController para no reestilar los accesos redondos
  (`MobileControls`/`ZB_MobileRound`).
- [x] QA controlada con funciones exactas (sin dedos reales): disparo sostenido,
  dos pulsaciones simultáneas no se interrumpen, liberación limpia, bloqueo al
  abrir mochila, gancho táctil, SUBIR/BAJAR y dirección del joystick. Capturas
  en iPhone 17 Pro y iPhone 7; portrait oculta acciones. Paridad de las seis
  fuentes (mismos bytes/hash) y sin fixtures.
- [ ] Touch real en teléfono: pulsación simultánea disparo+gancho+joystick,
  multitáctil físico, primera persona y desempeño (FPS/carga).
- [ ] Validar `StarterGui.ScreenOrientation`: sigue en `Sensor`; el juego exige
  landscape (`OrientationLock.client`). Confirmar política final en móvil.
- Sin publicación. Respaldo `ServerStorage.ZB_MobileBackup_20261009` por Place.

### B13–B16 — correcciones del reporte publicado, 2026-10-09

- [x] Respaldar fuentes en `ServerStorage.ZB_ProductionFixBackup_20261009` por Place.
- [x] Agarre: invalidación antes de restaurar, cancelación sin impulso, epoch,
  limpieza de prompts y guardas de combate; caso de arma/pieza anidada verificado.
- [x] Pasos: Running=0 en Libre/Match, positivo en Lobby y restauración al salir.
- [x] Retorno: Job de origen en contrato, anulación incluye solicitante en el grupo,
  destino alternativo único y reintentos asíncronos con afinidad.
- [x] QA de Runtime con transporte simulado: final/anulación de dos jugadores,
  tercero representado por Job de origen, reintento de uno y fallback compartido.
- [x] VICTORIAS VS por encuentro ganado; partida completa para ambos, deduplicación
  por MatchId y misión al finalizar. Cancelación no entrega esos resultados.
- [x] CONGELADOS MODO LIBRE solo acredita nuevas bajas Libre válidas; Tab VS conserva
  su conteo de batalla. Rótulos correctos y sin recorte en inspección del cliente.
- [x] QA en memoria: resultado ganador/perdedor/duplicado, pagos configurados,
  progreso, recursos sin refill, logro persistido en perfil y snapshot tras limpiar caché.
- [x] Guardado antes de viajes y escrituras serializadas; no enviar grupo si falla
  guardado. Compilar, retirar fixtures y finalizar ambos Places en Edit.
- [ ] Publicar ambos Places y entrar a **un servidor nuevo de Lobby** para usar
  el contrato de origen actualizado; los servidores viejos no reciben el código nuevo.
- [ ] Tres cuentas: A/B juegan y C permanece; A/B vuelven al mismo Job donde está C.
- [ ] Repetir abandono tras primera eliminación: partida anulada y retorno de A/B
  al origen común, sin victoria/partida completa/premio de final.
- [ ] A se sujeta a B congelado: comprobar liberación antes de restauración/respawn,
  sin impulso ni traslado del portador; etiqueta ausente después de reset/X/retorno.
- [ ] Escuchar pasos en flotación y primera persona; caminar en Lobby conserva audio.
- [ ] Final VS: ganador +1 victoria, ambos +1 partida, misión una vez; anotar saldo
  antes/después. Reconectar y comprobar conservación; probar fallos reales de guardado/teleport.

Los arreglos nuevos están verificados en Studio, no publicados desde esta sesión.
No reconstruir ganadores históricos a partir del viejo contador de partidas.

### Prueba publicada reportada por el usuario — 2026-10-09

Evidencia: reporte del usuario, no una nueva observación del asistente. Versión,
UserIds, dispositivos y capturas/F9 no proporcionados. Juan/Pedro/Roberto son
nombres de ejemplo para describir el retorno, no cuentas QA identificadas.

- [x] Calendario: fecha UTC, navegación, volver a hoy, futuro sin cobro,
  daily/misión y pulsaciones repetidas; cerrar/reabrir conserva estado y saldo.
- [x] SDR-Mk2 visible para el otro jugador, montaje, brazo/Beam y daño/congelamiento.
- [x] Libre: feedback, respawn protegido, salida X al spawn/cámara, superviviente
  conserva 0g y reentrada sin duplicados.
- [x] VS 1v1: mismo Match, countdown bloquea acciones, apuntado observado por ambos,
  ronda/reset/resultado y mejor de tres correctos.
- [x] Abandono después de la primera eliminación produce partida anulada.
- [ ] Retorno normal: grupo llega a otro Lobby, dejando separado al tercero que
  permaneció en el servidor de origen.
- [ ] Retorno de partida anulada: participantes llegan a servidores distintos.
- [ ] Agarre de cuerpo congelado: sigue sujeto cuando el objetivo reaparece;
  etiqueta de agarre puede persistir al regresar.
- [ ] Pasos audibles durante flotación/primera persona.
- [ ] Contadores VS/partidas no avanzan. Decisión delegada al asistente:
  ranking VICTORIAS VS y CONGELADOS MODO LIBRE; resultados completos sin rondas/cancelaciones.
- [ ] Reconexión, fallos de guardado, medianoche real, móvil/touch y rigs alternativos
  no quedan validados por este reporte.

### Calendario mensual editable y B12 de apuntado Match — 2026-10-09

- [x] Crear `StarterGui.ZB_DailyActivities` en Lobby: plantilla completa editable,
  backdrop, navegación mensual, 42 fechas, detalles, tres filas de misión y cobros.
- [x] Migrar DailyActivities de constructor a controlador de plantilla; protegerla
  del antiguo layout/estilizado del tema. Guardas compartidas en ambos AtlasUIController.
- [x] Fechas gregorianas reales, lunes–domingo, hoy UTC, selección y último cobro
  confirmado. Otras fechas no reutilizan progreso de hoy ni habilitan cobros.
- [x] Navegación mediante clicks: octubre→noviembre, selección 4/11 y volver a hoy.
  Febrero de 2028=29 días; febrero de 2026=28; octubre=31.
- [x] Click diario +50 y misión asociada +40: saldo 500→590, RECLAMADA/HECHA y ✓
  en hoy. Reinicio controlado al 10/10: progreso cero, daily +75, saldo 590;
  seleccionar 9/10 muestra cobro confirmado +50 y ausencia de historial de misiones.
- [x] Capturas desktop e iPhone 17 Pro horizontal/vertical. Portrait con UIScale 1,
  scroll y detalles accesibles; sin textos truncados detectados. Ajustar leyenda
  para no superponer botón de hoy. Apertura/scroll móviles inspeccionados mediante
  propiedades del cliente: no equivalen a input touch real.
- [x] Respawn: un calendario, 42 slots y arma SDR-Mk2 conservada.
- [x] B12 reproducido en Match moderno: 15 AnimationConstraint, dot mínimo 0.351407
  con el apuntado anterior (35 muestras).
- [x] Sincronizar solución moderna de Lobby: restauración PreAnimation, IK analítico
  PreSimulation y limpieza. QA posterior: 105 muestras/3 direcciones, dot mínimo
  0.9999065; guardia ragdoll no escribe Transform. Fuentes ShootingController
  iguales: 22375 bytes / hash 2798386865 en ambos Places.
- [x] Retirar fixtures/mediciones; ambos Places en Edit, simulador default.
- [ ] B12 en Player: apuntado/disparo de extremo a extremo, observador remoto,
  rigs Motor6D y eliminación/ragdoll/respawn en VS real.
- [ ] Calendario publicado, persistencia del cobro por reconexión y touch real.
- Respaldos: Lobby `ServerStorage.ZB_CalendarBackup_20261009`; Match
  `ServerStorage.ZB_CalendarAndAimBackup_20261009`. Sin publicación.

### B11 — renovación diaria en sesión abierta — 2026-10-09

- [x] Reproducir con reloj controlado: el nuevo día dejaba UI con datos anteriores.
- [x] Respaldar MissionService, DailyRewardService, DailyActivities y DataService
  Lobby; DataService Match en `ServerStorage.ZB_DailyRolloverBackup_20261009`.
- [x] Centralizar reloj de servidor en DailyClock: reinicio a 00:00 UTC.
- [x] Renovar y comunicar misiones/daily en un máximo de 2 s, sin exigir acción/reentrada.
- [x] Recuperar snapshots al iniciar/abrir y mostrar cuenta atrás UTC a 1 Hz.
- [x] Separar actualización de actividades de reaplicación de recursos; API de
  metadatos en ambos Places, sin recargas (30→30 en QA de Lobby y Match).
- [x] Panel abierto: progreso reiniciado y daily +75; cerrado/salto de dos días:
  progreso cero y daily +50 según regla de racha existente. Respawn: una GUI.
- [x] Solicitudes repetidas en sesión no duplican daily; cobro de misión anterior
  rechazado. Saldo 500→630→705, sin pagos por la renovación sola.
- [x] Compilar fuentes; retirar fixtures y probar arranque con reloj real, 3 filas
  y cuenta atrás. Ambos Places terminan en Edit, sin publicar.
- [ ] Publicar/validar medianoche UTC, reconexión y teleport con datos reales.
- [ ] Cerrar persistencia/idempotencia ante fallo de guardado y cómputo de ranking.
- B11 **cerrado en Studio**. No equivale a cerrar el bloque completo de misiones
  del PLAN_10_DIAS. Las pruebas de cobro usaron el bypass DataStore de Studio.

### SDR-Mk2 como arma base y fix de Muzzle — 2026-10-09

- [x] Confirmar prototipo local: arma en cliente pero ausente del servidor.
- [x] Respaldar modelo original del Lobby y Config/WeaponSetup de ambos Places.
- [x] Adaptar SDR-Mk2 a `ReplicatedStorage.WeaponAssets.Templates.blaster` en ambos:
  Handle/Grip, Barrel/Muzzle, pivote y montaje; 18 piezas, 14 mallas.
- [x] Crear WeaponVisualService replicado; deshabilitar constructor procedural;
  nombre visible SDR-Mk2, ID blaster y balance conservados.
- [x] Compilar servicio y Config; fuentes del servicio idénticas (4532 bytes,
  hash 946261481) y mismos 14 MeshIds en ambas plantillas.
- [x] Play Solo: arma/Muzzle presentes en servidor y cliente; montaje capturado
  visualmente en ambos Places, sin piezas ancladas, colisión ni masa adicional.
- [x] Libre mediante JoinMatchRequest real: disparo con mouse, Beam desde Muzzle,
  36 muestras de apuntado con dot mínimo 0.999809; salida X con una arma.
- [x] Respawn real en ambos Places mantiene una sola arma.
- [x] QA controlado WeaponId rifle→original: una arma; energía 30→31.8 por
  regeneración normal, sin refill. apply/reset de ragdoll conserva WeaponMount.
- [x] Retirar fixture/atributos de QA; ambos Places en Edit, plantilla seleccionada.
- [ ] Probar con dos cuentas en Player, mallas/permisos, VS y rigs adicionales.
- [x] Sincronizar IK moderno de Match en tarea posterior del 09/10; QA de pose B12
  arriba. Disparo multicuenta/rigs adicionales siguen pendientes.
- Aviso ZB_Intro no reproducido en este arranque; sigue pendiente, sin cambios.
- Sin publicación. Contrato de reemplazo y reversión en DISENO.

### Iluminación global y postprocesado — 2026-10-09

- [x] Leer documentación completa, priorizando PLAN_10_DIAS y luces.md actualizado.
- [x] Auditar Lighting, efectos, luces locales, materiales y posibles escritores
  de iluminación en ambos Places; diagnóstico y valores en [luces.md](luces.md).
- [x] Respaldar originales en `ServerStorage.ZB_LightingBackup_20261009` por Place.
- [x] Aplicar LightingStyle Realistic, ambiente frío, noche y Bloom moderado;
  agregar una corrección de color por Place, sin scripts runtime nuevos.
- [x] Capturar antes/después; corregir oscuridad excesiva inicial del piso Lobby.
- [x] Revisión posterior del usuario: la variante nocturna seguía demasiado oscura.
  Recuperar luz diurna y elevar ambiente/exposición en ambos Places; nuevas capturas
  en Edit muestran más detalle en piso y maquinaria. Valores vigentes en luces.md.
- [x] Play Solo: efectos únicos, Lobby con Continue y desplazamiento W (~16 studs),
  gravedad Lobby 196.2 / Match 0. Match aislado conserva rechazo de TeleportData.
- [x] Comprobar firma de Workspace sin cambios de geometría, materiales, colisiones
  ni propiedades de prompts incluidas; ambos Places finalizan en Edit.
- [ ] Validar combate publicado, legibilidad de jugadores/equipos, FPS y móvil.
- [ ] Confirmar aceptación visual del ajuste más luminoso con el usuario.
- [ ] Etapas locales/materiales y perfiles HIGH/MEDIUM/LOW siguen pendientes.
- Próximo bloque del plan: reproducir misiones/ranking, acordar cómputo de partidas
  y corregir renovación/cobro/persistencia. No cerrados por esta mejora visual.
- Sin publicación. Reversión y configuración exacta documentadas en luces.md.

### Libre: retorno al Lobby y apuntado — 2026-10-07

- [x] Reproducir salida sin traslado: spawn anidado no encontrado por búsqueda directa.
- [x] Corregir `LobbyTeleportService`; añadir transición dirigida y
  `StarterPlayerScripts.LobbyReturnController` para sincronizar el dueño de red.
- [x] Probar X en Play Solo: LOBBY, participante=false, root a 3.881 studs sobre
  spawn, caminar 16, AutoRotate=true, PlatformStand=false, cámara Custom,
  MouseBehavior.Default y fuerza local de empuje retirada.
- [x] Detectar avatar con AnimationConstraint en lugar de Motor6D; adaptar
  `ShootingController.client` con IK de dos segmentos para hombro/codo/muñeca.
- [x] Comprobar capa moderna con funciones exactas en LocalScript de QA temporal:
  37 muestras, dot mínimo arma/dirección 0.9999974 y pista swim con peso 1.
  Las pruebas de mouse posteriores fueron bloqueadas por foco CoreGui; esta
  medición valida la pose, no un click de disparo de extremo a extremo.
- [x] Segunda salida mediante LeaveMatchRequest real del cliente: traslado y
  locomoción correctos; fixture y atributos de medición eliminados con la prueba.
- [x] Compilar los tres scripts modificados/creados; terminar Lobby en Edit.
- [ ] Repetir disparo manual con mouse enfocado, respawn/ragdoll, rigs Motor6D y
  dos clientes; aplicar apuntado al Match cuando se confirme ese alcance.
- [ ] Resolver espera independiente de ZB_Intro; sigue registrada en Output.
- Cambios aplicados solo en Lobby; no publicados.

### Orientación, centrado y colocación 3D — 2026-10-07

- [x] Confirmar con el usuario alcance: Gravedad CERO/Lobby, existentes y nuevos.
- [x] Realinear estructura principal a ejes mundiales; origen en superficie central
  del piso `(0, 0, 0)`, `piso.Position=(0, -0.5, 0)` y Orientation cero.
- [x] Normalizar pivotes de 58 modelos no pertenecientes a personajes.
- [x] Comparar posiciones de 628 piezas con la transformación global esperada:
  error máximo `0.0000211` studs. Piso enderezado adicionalmente; Terrain excluido.
- [x] Crear `Arena.BlockSpawnRegion` y adaptar límites/slots del servidor de bloques.
- [x] Crear `ServerStorage.Editor3D` y verificar normalización sin desplazamiento,
  enderezado por referencia y colocación con base en Y=0 sobre un fixture temporal.
  Fixture eliminado tras comprobar; 58 pivotes de modelos verificados en ejes mundiales.
- [x] Play Solo Lobby: personaje aparece en spawn trasladado, 16 bloques con
  PrimaryPart y fuerza de flotación; power-ups aparecen en puntos trasladados.
  Script de bloques compila. Captura posterior de la escena; Studio termina en Edit.
- [x] Documentar uso en Command Bar y respaldo `ServerStorage.Editor3D_AlignmentBackup`.
- [ ] Validar manualmente recorridos, colas y Libre tras realineación; no se probó
  una partida completa ni teleport. Match no realineado; no se publicó.
- [ ] Revisar aviso observado en Play: `AtlasUIController`, línea 242, espera
  `PlayerGui.ZB_Intro` con `Infinite yield possible`. No corregido en esta tarea 3D.

### Revisión: edición visual y sugerencias — 2026-10-06

- [x] Crear `ReplicatedStorage.UIAssets.Icons`: 27 ImageLabels, cada uno con
  Fallback de Frames y metadatos de entrega. Image se cambia desde Properties.
- [x] Crear `.Styles.panel/card/button` como Frames con UICorner y UIStroke.
- [x] Manual completo en `StarterGui.ZB_Intro` en ambos Places; Title, Subtitle,
  Logo, Rows.Row01..Row08 y Continue con nombres estables.
- [x] UITheme clona esas plantillas; AtlasUIController enlaza el manual sin
  destruir sus textos y Frames. Layout responsive conservado.
- [x] Archivar catálogo Lua anterior y conservar backup de la plantilla Lobby.
- [x] Verificación visual: manual escritorio Lobby, manual vertical Match y
  mochila Lobby con nuevos iconos/estilos; Continue y B siguen funcionando.
- [x] Prueba funcional de edición visual en Lobby: solo propiedades Image de
  Icons.bag, Text de Title y CornerRadius. Nueva sesión mostró título editado,
  radio 20, imagen en botón y manual, IsLoaded=true, Fit y fallback oculto.
  Restaurados Image vacío, título ZERO BREACH y radio 12 después de la prueba.
- [x] Reescribir UI_ASSETS.md con reemplazo por Explorer/Properties.
- [x] Crear SUGERENCIAS.md con nueve cosméticos propuestos, rutas existentes y
  rutas por crear, pases/productos, recibos, videos, anuncios y regalos globales.
- [x] Verificación final: compilación correcta y fuentes iguales en ambos Places:
  UITheme 11733 bytes / hash 467807235; AtlasUIController 18964 bytes / hash 612955664.
  Árbol visual de 454 instancias, 27 iconos y 8 filas; firma de estructura y
  propiedades principales 3097890407 en ambos Places.
- [x] Output sin errores nuevos de UI; Match aislado mantiene rechazo de TeleportData
  ausente. Ambos Places en Edit, viewport default y `UIAssets.Icons.bag` seleccionado
  para encontrar fácilmente el campo Image. Sin publicación ni gastos.
- [ ] Migrar por completo otras pantallas estáticas a StarterGui; pasos en SUGERENCIAS.
- [ ] Implementar las propuestas de monetización/cosméticos/UGC tras decidir
  contenido, IDs y presupuesto. Ninguna venta ni gasto fue activado en esta tarea.

Las verificaciones de la sección siguiente describen la versión previa del mismo
día. Su antiguo ModuleScript UIAssets ya no es la fuente vigente; ver UI_ASSETS.md.

### UI limpia y guía de sustitución — 2026-10-06

- [x] Reproducir la deformación visual del atlas; retirar sus marcos y recortes.
- [x] Paneles y botones nativos; texto original en lugar de etiquetas espejo.
- [x] 27 claves en `ReplicatedStorage.Shared.UIAssets`: trazos nativos actuales y
  campo Image para futuros PNG individuales con Fit, sin recortes ni estiramiento.
- [x] Mochila/tienda en una columna para viewport vertical estrecho; manual y
  actividades reorganizados al rotar. Resize diferido para no perder el UIScale.
- [x] Ocultar accesos de calendario/ayuda/mochila con modal abierto.
- [x] Manual único en Lobby y Match; esperar copia de StarterGui cuando existe;
  plantilla Lobby y GUI runtime con ResetOnSpawn=false.
- [x] Crear [UI_ASSETS.md](UI_ASSETS.md), catálogo y caso «mochila por bolso»:
  rutas locales y Studio, nombres, tamaños, IDs, carga, prueba y reversión.
- [x] Definir `docs/assets/ui/` para entrega de futuros PNG; aclarar que todavía
  no hay imágenes individuales exportadas, porque el acabado actual es nativo.

**Verificado en Studio:**

- Escritorio, simulador Laptop promedio: viewport 1365×768. Manual, mochila y
  tienda con bordes uniformes, iconos completos y texto sin la deformación del atlas.
- Lobby: abrir mochila con B; tienda con E junto al prompt real de `Workspace.Taller`.
  Para llegar al taller se colocó el personaje allí durante Play; no se cambió el spawn.
- Match: mochila con B y cambio a categoría Armas por click; tarjetas regeneradas
  mantienen el nuevo acabado y el estado EQUIPADO.
- iPhone 17 Pro: mochila horizontal Lobby (viewport 750×361), manual y actividades
  verticales Lobby (401×778), actividades horizontales y mochila vertical Match.
  Tras girar en Match, panel 370×650 y escala 1; antes quedaba incorrectamente en 0.39255.
- Algunas pantallas móviles se abrieron/ocultaron por propiedades del cliente
  para inspección visual. No afirmar que esto valida input touch real.
- Tras la corrección final: exactamente un `ZB_Intro` en cada Place. En Lobby,
  click en CONTINUAR deja menú=false y recupera accesos; ayuda reabre el mismo
  manual, pone menú=true y oculta accesos. Respawn real mediante LoadCharacterAsync
  mantiene un único manual, persistente y con su estado de apertura.
- Cero ImageLabels del atlas antiguo en la inspección del PlayerGui; inspección
  previa del runtime Lobby tampoco encontró consumidores del atlas en el mundo.
- Arranque final sin errores de UIAssets/UITheme/AtlasUIController en ambos Places.
  Match aislado rechaza TeleportData ausente y falla el retorno de prueba, como
  corresponde a ese entorno; no es una validación de VS publicado.
- Compilación y paridad de las tres fuentes compartidas, después del último cambio:

  | Script | Bytes | Hash de comprobación (h×31 + byte, módulo 2³²) |
  |---|---:|---:|
  | UIAssets | 4023 | 976538978 |
  | UITheme | 11858 | 3452018274 |
  | AtlasUIController | 20239 | 534430835 |

- Ambos Places terminan en Edit y con viewport default; sin fixtures añadidos.
  No se publicó desde esta sesión.

**Pendiente de validación fuera de esta tarea:**

- [ ] Roblox Player y touch real, incluida la política existente de orientación.
  `StarterGui.ScreenOrientation=Sensor`, pero Match tiene `OrientationLock.client`
  con aviso de girar el dispositivo: adaptar los menús no habilita por sí solo
  todo el gameplay vertical.
- [ ] VS publicado: resultados, roster y feedback con jugadores reales tras el cambio visual.
- [ ] Al entregar un PNG nuevo: comprobar carga, permisos y legibilidad en ambos Places.
  Ningún PNG individual fue activado en esta sesión.
- Compras/cobros/persistencia no se revalidaron en esta sesión: se verificó su
  presentación y se conservaron sus controladores y contratos existentes.

### Controles, energía, tabla y spawns — 2026-10-02

- [x] Corrección posterior de cursor al salir, aplicada a ambos Places:
  no restaurar MouseBehavior/Icon antiguos. Prueba local de transición simulada
  con bloqueo previo: Scriptable→Custom, mouse Default, icono visible y cursor
  libre. Lobby detenido en Edit tras la prueba; sin fixtures persistentes.

- [x] Q/Espacio para gancho y R/Ctrl para deriva vertical; salto del Lobby conservado.
- [x] Cuatro avisos locales de vacío/listo con audio precargado en ambos Places.
- [x] Cámara de escritorio sin RMB, Alt/cursor libre y CTA de mochila.
- [x] Tabla Tab de congelamientos de la batalla, con contador autoritativo separado.
- [x] Ocho puntos de spawn Libre, selección segura y protección 5 s con contador.
- [x] Invalidar callbacks de respawn antiguos y atender reset físico en Libre.
- [x] Recolocar spawns VS, separar compañeros y añadir coberturas frente a ambos.
- Palanca Lobby: **Próximamente**; no funcional por decisión del usuario.

Verificaciones locales realizadas:

- Entrada real mediante API de LobbyTeleportService en fixture temporal:
  BattleParticipant=true, ubicación LibreSpawn válida y escudo rechaza daño parcial.
- Mouse giró cámara ~39° con botón derecho sin presionar; Space activó gancho y
  consumió energía. Alt dejó MouseBehavior=Default; B abrió mochila con cursor libre.
- Cuatro Sounds IsLoaded=true; las cuatro notificaciones vacío/listo se emitieron
  al simular cambios de atributos desde el servidor.
- Snapshot servidor de BattleFreezes=10 se reflejó en la fila de tabla. Esto
  comprueba presentación; acreditación entre dos jugadores sigue pendiente.
- Eliminación real vía FreezeService en QA: LibreSpawn3→LibreSpawn1, progreso
  restablecido, CombatActive=true, escudo nuevo válido y contador limpio al salir.
- BattleStats rechaza objetivo NPC/nil y autoimpacto en comprobación aislada.
- Salida X: BattleParticipant=false, BattleFreezes=0, cámara Custom, mouse Default
  y root vertical (`UpVector·Y=1`).
- Geometría VS: GetPartsInPart comprueba 4/4 slots despejados de Azul y Rojo;
  raycast directo entre spawns golpea cobertura estática en ambos sentidos.
- Ambos Places arrancaron sin errores nuevos; Match sin TeleportData sigue siendo
  rechazado. Fixture GameplayQA_TEMP y sus atributos retirados; ambos en Edit.

Pendientes antes de dar por validada la versión publicada:

- [ ] Dos cuentas: incrementar BattleFreezes con impactos reales, mantener total
  entre rondas/respawns y resetear al salir; comprobar aislamiento de partidas.
- [ ] Probar Q/Espacio simultáneos, chat, pérdida de foco y regreso de cursor en Player.
- [ ] Confirmar mix/volumen y permisos de ambos audios en versión publicada.
- [ ] VS 2v2–4v4 real: spawns, salidas/flanqueo de las nuevas coberturas y cámaras.
- [ ] Probar resets físicos repetidos de Libre y salida/reentrada durante eliminación.

### Rediseño UI con atlas — 2026-10-02

- [x] Importar pack aportado como `105755219623216` y corregir recortes a factor 2/3.
- [x] Tema/controlador compartidos en ambos Places; comparar longitud/hash de fuentes.
- [x] Aplicar presentación a UI de pantalla, instrucciones, ranks, hologramas y taller.
- [x] Conservar compra/equipado/cobro en sus controladores originales.
- [x] Comprobar mochila B, categorías y tarjetas regeneradas en Lobby; mochila Match.
- [x] Abrir tienda con E y comprar recarga: 500→420 monedas, 18→24/s, confirmación.
- [x] Cobrar daily +50 y misión asociada +40: saldo 590, Reclamada/Hecha.
- [x] Capturar placas de ranking con nuevo marco y fila del jugador actualizada.
- [x] Manual de instrucciones con iconos, CONTINUAR y reapertura; ZB_MenuOpen se
  activa al abrir manual/actividades y vuelve a false al cerrar.
- [x] QA de presentación VS: HUD de recursos, score, roster, X, countdown, derrota
  y resultado mediante snapshots enviados por un Script temporal en Studio.
- [x] Retirar `AtlasUI_QA_TEMP`; ningún fixture ni atributo de QA queda en Edit.
- [x] Simulador iPhone 17 Pro horizontal: revisar manual, equipo y actividades;
  corregir composición compacta y prioridad de capas detectadas.
- [x] Detener Play en ambos Places y restaurar simulador a viewport default.
- [x] Arranque final sin errores de UITheme/AtlasUIController en Output de ambos.
- [ ] Publicar y confirmar carga/permisos del atlas en Roblox Player.
- [ ] VS publicado multicuenta: datos reales, feedback de ambos jugadores y resultados.
- [ ] Probar touch real, portrait y dispositivos de gama baja; el juego conserva
  `ScreenOrientation=Sensor`. El simulador horizontal no valida estas condiciones.

Evidencia del tema: fuentes idénticas en ambos Places al cerrar:
UITheme 10409 bytes/hash 3270847715 y AtlasUIController 17194 bytes/hash 503860922,
verificados después de los ajustes finales de capas y menús.
Recompensas y compras comprobadas solo en Play local, no persistencia
publicada. Match aislado continúa rechazando TeleportData ausente como corresponde.
El intento de entrar a Libre por el stand en esta QA no confirmó transición;
el HUD de batalla se comprobó con snapshots de servidor, no como un VS real.

En la consolidación del 02/10 la documentación quedó en cuatro Markdown; el 06/10
se agregó UI_ASSETS.md por pedido del usuario y el README de la carpeta de entrega.

- [x] Leer los 13 documentos presentes, incluida la bitácora completa.
- [x] Consolidar en cuatro archivos y distinguir decisiones actuales de prototipos.
- [x] Detectar referencias obsoletas a `src/`: no existe en el checkout actual.
- [x] Abrir el Lobby y Match en Studio; bloqueo inicial de Place cerrado resuelto.
- [x] Leer CombatFeedback de ambos Places y localizar productores de freezeProgress.
- [x] Aumentar amplitud de shake beam ×5/pulse ×4, conservando retirada de transformación previa.
- [x] Reforzar halo rojo confirmado, ampliar gradiente y mantener centro libre.
- [x] Aplicar los mismos diez cambios en Match; valores registrados en DISENO.
- [ ] Probar disparo, daño repetido, protección, reset, respawn y salida al Lobby.

La documentación de 2026-09-30 ya describe shake leve y cuatro bordes rojos en
CombatFeedback. El pedido actual se implementó reforzando ese mismo sistema.

### Verificación 2026-10-02

- Lobby y Match ejecutaron Play y crearon `ZB_CombatFeedback` con cuatro Frames
  DamageEdge1..4, medidas 20%/16%, Active=false y transparencia inicial 1.
- Output no mostró errores de CombatFeedback. Match mostró los rechazos/retornos
  esperados al entrar sin TeleportData en Play aislado.
- La inyección de daño de QA no pudo ejecutarse: MCP rechazó FireClient de
  StateChanged y la inserción del fixture por restricciones de Capabilities.
  Otro intento de diagnóstico no tuvo acceso a `_G`; esos errores son del
  comando de prueba, no evidencia de fallo del script de feedback.
- No se validaron todavía intensidad percibida, daño real, disparo sostenido ni
  reset completo en combate. Mantener abierta la matriz A.
- Ambos Places quedaron en Edit. No se publicó. `git diff --check` sin errores;
  docs contiene exactamente cuatro archivos.

## 2. Implementado según las sesiones anteriores

- [x] Movimiento 0g con inercia, drag, boost, límite y compensación individual Libre.
- [x] Gancho inmediato con energía propia y remotes asíncronos, FOV y cosméticos.
- [x] Agarre E, impulso inverso del jugador y empuje del objeto.
- [x] Beam autoritativo, progreso acumulado, cabeza x3, VFX replicado y overheat.
- [x] Lobby + Libre local; VS por reservado Match con lista exacta autorizada.
- [x] Stands y colas separadas, capacidad previa, CombatActive y countdown por ronda.
- [x] Mejor de tres, eliminados permanecen entre rondas, retorno grupal reservado.
- [x] Feedback atacante/víctima con avatar y 3 s; X en roster y colores ocluidos.
- [x] Ragdoll reversible real, sin copia superpuesta en VS.
- [x] Respawn Libre en arena con 5 s de escudo cancelable por primer disparo válido.
- [x] Power-ups amarillo/azul/rojo y 15 puntos persistentes en ambos Places.
- [x] Perfiles, autosave/cierre, monedas, taller, estadísticas y cosméticos persistentes.
- [x] Daily, misiones, logro único de +120 y resultados con MVP/estadísticas.
- [x] Ranking reactivo con histórico en segundo plano y Elimination total replicado.
- [x] EquipmentDashboard común; mochila B, tienda E exclusiva del Lobby.
- [x] Recarga permanente +6/s por 80 monedas, base 18/s, máximo 48/s.
- [x] Inventario Match lee workshop; cosméticos no rellenan energía.
- [x] Insignia QA limitada a 10 UserId; entregas deshabilitadas en Studio.
- [x] Limpieza de orientación, pose, cámara y fuerzas al volver al Lobby.

Estas marcas representan implementación documentada; no equivalen a una nueva
auditoría del código ni a validación publicada de todas las características.

## 3. Evidencia existente y límites

### Producción registrada el 2026-09-14

- Libre volvió a mostrar feedback para ambos participantes sin bloqueo prolongado.
- VS recuperó movimiento, 0g y transiciones de ronda durante la prueba publicada.
- No extender esa evidencia a cambios posteriores de ragdoll, UI o recarga.

### Studio registrado el 2026-09-30

- Compilación y arranque de scripts modificados en ambos Places.
- Mochila B y tienda E inspeccionadas visualmente; compra 500→420 monedas y
  recarga 18→24/s, reflejada en perfil de memoria.
- Match: perfil de prueba 30/s regeneró 18 puntos en seis ticks/~0.65 s;
  guardó 30/s en memoria y replicó InventoryCoins.
- Compras sin saldo/al máximo rechazadas sin cobrar ni entregar.
- Disparo real canceló solo escudo de aparición; escudo azul conservado.
- Protección rechazó daño; daño parcial generó borde rojo con desvanecimiento.
- Ragdoll R15: 14 articulaciones físicas, Humanoid vivo, reset de motores;
  respawn Libre y activación/reset aislados en Match.
- Roster simulado: X en eliminación/resultado y limpieza en siguiente ronda;
  contornos con oclusión.
- Salida X: root vertical (`UpVector·Y=1`), sin fuerzas/orientación de combate,
  AutoRotate=true, cámara Custom y zoom restaurado. W/D giró avatar ~90°;
  reentrada recreó física.
- Arrastre automatizado del mouse no cambió mediblemente cámara: **giro de cámara
  no validado**. Viewports Studio no equivalen a prueba móvil real.
- Fixtures solo durante Play. Ambos Places terminaron en Edit; no se publicaron
  desde esa sesión. Persistencia en memoria no demuestra reconexión/teleport.

## 4. Matriz de aceptación pendiente

### Próxima sesión — prueba publicada con dos jugadores

**Preparada, no ejecutada.** Cuentas A/B en Roblox Player; entrar al Lobby
`125075465377023` y confirmar que comparten servidor. Match `108298899371591`
se alcanza mediante la cola, no por entrada directa. Registrar versiones y
publicar ambos Places antes de comenzar, conservando versiones anteriores.

| Caso | Pasos con A/B | Resultado / evidencia |
|---|---|---|
| P01 Calendario | Abrir calendario; navegar mes/fecha futura; volver a hoy | Fecha UTC correcta; otras fechas sin cobro; captura de cada cuenta |
| P02 Cobro | Registrar saldo/estado antes; reclamar daily y misión disponible; volver a pulsar | Una entrega; ✓/RECLAMADA/HECHA; registrar si la cuenta ya había cobrado |
| P03 Persistencia | A sale y reconecta mientras B permanece | Mismo saldo y cobro conservado; no confundir Studio en memoria con esta prueba |
| P04 Libre | Ambos entran; disparar alternando atacante/víctima; usar gancho y eliminar/reaparecer | SDR-Mk2 visible desde la otra cuenta, brazo/muzzle/beam alineados, feedback y 0g correctos |
| P05 Salida | A sale con X mientras B sigue en Libre; A reentra | A vuelve al spawn/cámara; B conserva 0g; sin duplicados de arma ni UI |
| P06 VS 1v1 | Salir de Libre y completar cola juntos; mejor de tres | Mismo reservado, countdown sin combate, apuntado de ambos, reset por ronda y resultado correcto |
| P07 Retorno | Finalizar VS y volver al Lobby | Retorno conjunto; saldos/equipado/cobros conservados; una arma por avatar |
| P08 Estadísticas | Anotar partidas/victorias/eliminaciones antes y después de P06/P07 | Comparar misión y ranking; registrar desvíos. Contadores/ranking aún no cerrados por B11/B12 |

Registrar por caso: cuentas, fecha UTC, dispositivo, Place/versión, pasos,
esperado/observado, captura y primer error de Output/F9. Si hay un fallo, anotar
la reproducción y repetir ese caso después del arreglo. Móvil real requiere
además apertura/cierre, navegación y scroll con touch.

### A. Feedback de cámara y daño — pendiente de validación

- [ ] Mantener click: shake visible y sostenido; soltar/overheat lo detiene.
- [ ] Pulse, si se habilita: shake por disparo confirmado, sin doble aplicación.
- [ ] No iniciar efectos de disparo en menú, Lobby o countdown.
- [ ] Impactos parciales confirmados activan halo; repetidos renuevan el efecto.
- [ ] Protección sin daño y reset/disminución del porcentaje no generan falso hit.
- [ ] Congelamiento total dispara feedback una vez; respawn limpia todo.
- [ ] Sin deriva acumulada de cámara, sin conflicto con FOV de gancho/zoom.
- [ ] Halo adaptable al viewport, sin bloquear input ni tapar mira.
- [ ] Salida X, W/D, giro de cámara con mouse y reentrada siguen funcionando.

### B. Publicación y multijugador real

- [ ] Publicar ambos Places tras verificar sus versiones y repetir con dos cuentas.
- [ ] Dos grupos 1v1 llegan a reservados distintos; Libre sigue local e independiente.
- [ ] Tercero no entra al stand 1v1 lleno; no duplicar colas ni estados Teleporting.
- [ ] Rechazar lista inválida/duplicada, cupo incorrecto y UserId no autorizado.
- [ ] Countdown 5 s bloquea combate/movimiento; 0g se mantiene entre rondas.
- [ ] Mejor de tres termina al ganar dos; victoria/derrota correctas, empate/cancelación seguros.
- [ ] Avatar real eliminado agarrable durante ronda, sin segundo cuerpo ni autorresurrección.
- [ ] Roster X, colores ocluidos y reset completos; tarjeta víctima visible 3 s.
- [ ] Retorno de todos al mismo Lobby reservado; recuperar fallo de teleport hasta reintentos.
- [ ] Retorno VS avanza misión una vez; reconexión conserva eliminaciones y ranking.
- [ ] Segundo jugador Libre entra aunque otro ya esté activo; dueño de red coincide con servidor.
- [ ] Eliminar/reaparecer en Libre mantiene 0g de supervivientes y salto de quienes están en Lobby.
- [ ] Comparar gancho de ambos clientes con latencia real, energía/VFX y ausencia de duplicados.
- [ ] Validar 2v2–4v4 y cancelación por salida, además de 1v1.

### C. Combate, física y economía

- [ ] Brazo/torso/pierna suman al mismo porcentaje; cabeza x3; eliminación solo a 100.
- [ ] Vaciar stamina sin math.max(nil); soltar/retomar limpia y recrea Beam/VFX.
- [ ] Vidrio decorativo no bloquea; cobertura opaca sí; revisar alcance visual 300 vs servidor 500.
- [ ] Spawn shield cede al disparo válido, no al inválido; orbe azul independiente.
- [ ] Agarre libera root y conserva dirección/intensidad correctas; cuerpos reset dejan de ser agarrables.
- [ ] Power-ups conservan 15 marcadores, no se superponen, rotan puntos y respawn 6 s.
- [ ] Monedas se recogen sin colisión; límite activo y misión de 25 correctos.
- [ ] Dos cuentas compran/equipan ganchos distintos, reconectan y recuperan su propiedad.
- [ ] Recarga comprada persiste al reconectar y viajar Lobby→Match; no refill al equipar cosmético.
- [ ] Pagos por jugar/ganar/eliminar llegan una vez; verificar ruta histórica de recompensa por extremidad.
- [ ] Daily/misiones responden rápido y no permiten doble cobro; logro único persistente.
- [ ] Solo primeros 10 UserId reciben badge QA; repetidos no consumen cupos.
- [ ] Medir carga real de ambos Places antes de optimizar; revisar assets fallidos en Player.
- [ ] Revisión final anti-exploit de remotes y FPS/input/UI en dispositivos de gama baja.

## 5. Roadmap activo

- [ ] Versionado/migración explícita de datos y política final de reinicio de racha.
- [ ] Balance conjunto stamina, gancho, cooldowns y recoil a partir de juego real.
- [ ] VFX/SFX adicionales y onboarding/tutorial.
- [ ] Beneficios de Libre por permanencia y congelamientos.
- [ ] Feedback del portador de cuerpo-escudo; evaluar anclaje trasero/carry y ADS.
- [ ] Puerta de Extracción: definir formatos compatibles/ocupantes distintos antes de implementar.
- [ ] Más coberturas, arenas, cosméticos, objetivos secundarios o segundo modo.
- [ ] Granadas: alcance por definir.
- Campo de tiro/Training: **aplazado por el usuario**.
- Armas de proyectiles: experimento conservado deshabilitado; reactivación no acordada.

## 6. Progreso consolidado

| Etapa | Resultado y decisiones que conservar |
|---|---|
| Sesiones 1–4 | MVP R15, fuerzas 0g, beam/arma procedural, Freeze por personaje/dummies, poses swim/procedural |
| Sesiones 5–9 | Agarre E, corrección de script mal ubicado y jitter, cuerpos-escudo; ADS/carry propuestos |
| Sesiones 10–13 | Perfil/daily/misiones, energía y cosméticos de gancho, resultados/MVP, beam continuo y overheat |
| Sesiones 14–18 | Prototipo MatchRegistry y arenas clonadas, estado por jugador; posteriormente sustituido |
| Sesiones 19–23 | Lobby/Match separados con PlaceConfig y teleport; Libre finalmente queda local |
| Sesiones 24–27 / 2026-09-02 | Diagnóstico gravedad, uniones, eliminaciones, resultado, retorno, misiones y monedas |
| Sesiones 28–29 / 2026-09-07 | Stands, cuenta de cola, HUD/daily, compensación individual Libre, tres power-ups/15 puntos |
| Sesión 30 / 2026-09-09 | Cupo exacto autorizado, mejor de tres, countdown 5 s, HUD VS y retorno grupal |
| Sesiones 31–32 / 2026-09-11 | Entrada del segundo cliente, transición dirigida, feedback de víctima, inicio local del gancho |
| Sesiones 33–36 / 2026-09-14 | Remotes asíncronos sin InvokeServer, HUD cacheado, CombatActive, ranking no bloqueante; estabilidad validada en producción |
| Sesiones 37–39 | FullFreeze y placas reactivas, daily sin bloqueo, paridad feedback Lobby/Match |
| Sesiones 40–41 | Importación de Package de proyectiles y posterior desactivación; beam restaurado como único activo |
| Sesiones 42–44 | Impulso inverso E, daño beam ×4 hasta 18/14.4/36, persistencia gancho y ranking corregidos |
| Sesión 45 / 2026-09-16 | Mochila, tienda por prompt, badge de 10, gancho fuerza 1000/velocidad 70/FOV +11 |
| Sesión 46 / 2026-09-21 | IK de apuntado, respawn Libre protegido dentro de arena, mochila Match, mira -110 y alcance local 300 |
| Sesión 47 / 2026-09-30 | CombatFeedback, ragdoll reversible, roster X, escudos separados, recarga de tienda, EquipmentDashboard y corrección de orientación Lobby |
| 2026-10-02 | Documentación consolidada en cuatro páginas; shake/halo reforzados en Lobby y Match; overlay comprobado en Play, combate manual pendiente |

### Procedencia de la consolidación

- REGLAS integra `ReglasRoblox.md` y la referencia GUI de `SKILL.md`.
- DISENO integra resumen, disparo/congelamiento, captura, arquitectura de Places,
  estructura, reemplazos y contratos de combate/UI.
- CHECKLIST integra ruta, verificaciones del sprint y progreso diario resumido.
- BUGS integra incidentes de producción y correcciones descritas en la bitácora/sprint.
- Matchmaking por arenas clonadas se conserva como decisión histórica sustituida,
  no como instrucciones activas.
- Se preservaron los cambios locales existentes al extraer su contenido; la
  eliminación previa de `UI_ASSET_SPEC.md` no se revirtió. No se creó un commit.
