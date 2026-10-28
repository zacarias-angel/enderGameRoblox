# UI — Buscar en Explorer y reemplazar

Actualizado: **2026-10-27**, contrastado en Edit de Lobby `125075465377023` y
Match `108298899371591`. El corte siguiente prevalece sobre el historial.

**Flujo vigente: seleccionar una instancia y editar Properties. No abrir scripts
para cambiar una imagen, un texto del manual o sus esquinas.**

## Calendario con marcos de la mochila actual — 27/10

**Aplicado y verificado en Studio en Lobby `125075465377023`; sin publicar.**
Match `108298899371591` no contiene ZB_DailyActivities; el calendario sigue siendo
una función del Lobby. No se agregó esa pantalla al Place de combate.

La plantilla `StarterGui.ZB_DailyActivities` conserva EditableCalendar y ahora
CalendarArtwork=true. Se retiró UIFrameSkin=panel_warning del panel y el skin
violeta de los botones de cobro. Las imágenes locales Artwork son editables:

| Instancia relativa a ZB_DailyActivities | Imagen / presentación |
|---|---|
| ActivitiesPanel.Artwork | `92094831612893`, panel azul/dorado de la mochila, SliceScale=.08 |
| ActivitiesPanel.Content.Calendar.Artwork | Mismo panel, SliceScale=.05 |
| Content.Details.RewardSection.Artwork | Mismo panel, SliceScale=.05 |
| Content.Details.MissionList.Row01..Row03.Artwork | Mismo panel, SliceScale=.04 |
| TodayButton / ClaimDailyButton / RowNN.Claim, hijo Artwork | `99022357719006`, SliceCenter=(180,70)–(840,125), SliceScale=.12 |
| PreviousMonth / NextMonth / CloseButton, hijo Artwork | `95844709202495`, Fit |

Los paneles usan SliceCenter=(300,220)–(724,548), como las fuentes actuales de
mochila. Cada marco es un ImageLabel nativo, sin composición ZBAtlas antigua.
Los botones originales conservan Activated/Active; su hijo Caption presenta el
texto real. DailyActivities enlaza texto, FontFace, TextSize y disponibilidad;
no cambia fechas, historial, remotes ni condiciones de cobro. Los slots de días
conservan sus colores de estado y el borde semántico de selección/fecha actual.

**QA:** captura desktop 1045×572; siguiente mes mostró NOVIEMBRE 2026 y se probó
VOLVER A HOY. Ocho Caption con TextFits=true, 14 Artwork y cero ZBAtlas_Background
en la pantalla. Simulador iPhone 17 Pro horizontal 750×381 y vertical 401×778:
marcos presentes, navegación/scroll vertical hasta las tres misiones y cierre
por botón oculta Panel/Backdrop y restablece CalendarButton. Sensor y
DeviceSafeInsets conservados. Output sin errores de UI; no se ejecutaron cobros.
Play detenido y simulador restablecido a default. No certifica touch físico.

Respaldo: `ServerStorage.ZB_CalendarArtworkBackup_20261027`, plantilla y
DailyActivities originales con OriginalPath; LocalScript del respaldo deshabilitado.

## Accesos compactos y retiro del cartel Libre — 27/10

Aplicado en **ambos Places en Studio; sin publicación**. Este ajuste sustituye
las medidas grandes de accesos de escritorio descritas en las secciones históricas.

- Tabla, cursor y salida/retorno: **180×60 px**, fuente máxima **11 px**,
  esquina inferior derecha, margen **12 px**, separación vertical **2 px**.
  El marco conserva la imagen completa con Fit y proporción 3:1; el grupo se
  reduce proporcionalmente si la ventana es muy baja.
- Textos: `TAB: CONGELAMIENTOS`, `ALT: LIBERAR CURSOR` / `ALT: VOLVER A APUNTAR`,
  `X: SALIR DE BATALLA` en Lobby y `L: VOLVER AL LOBBY` en Match.
- Plantillas: `StarterGui.ZB_BattleScoreboard.ScoreAccess`,
  `ZB_BattleCursor.CursorAction`, `ZB_BattleExit.LeaveButton` (Lobby),
  `ZB_ReturnToLobby.ReturnButton` (Match). Fuente: TextSize=11; texto alternativo
  del cursor: atributo FreeCursorText. El texto vivo del arte respeta TextSize.
- Layout en `Shared.BattleHudArtwork`; atributos editables de
  `ReplicatedStorage.UIAssets.BattleHud`: DesktopAccessWidth=180,
  DesktopAccessMargin=12, DesktopAccessGap=2.
- `HudController.client` deja MatchStatus vacío y oculto para Libre, tanto por
  payload como por el formato del participante. Se conservan avisos de cola,
  cuenta atrás, tiempo y resultado VS. El layout táctil conserva su distribución.

**QA Studio:** entrada real a Libre por JoinMatchRequest; captura sin cartel,
los tres accesos 180×60 y TextFits=true. Alt alternó el texto y Tab abrió el panel
al mantenerlo; click en salida devolvió GameMode=LOBBY y BattleParticipant=false.
Match: captura con estado visual local VS, tres accesos 180×60 y TextFits=true;
no equivale a teleport/VS real. Su Play aislado mantiene los rechazos esperados
REJECT_INVALID_TELEPORT_DATA y Request Context Failure al intentar retornar.
Lobby no registró errores de UI. Ambos quedaron con Play detenido.

Respaldo por Place: `ServerStorage.ZB_CompactBattleAccessBackup_20261027`, con
OriginalPath en módulo, controlador, configuración y tres ScreenGui originales.
No se publicaron los Places ni se repitió QA móvil en esta tarea.

## HUD de batalla con las imágenes nuevas — integración posterior del 26/10

**Corrección posterior al reporte del usuario:** la composición por segmentos
introducía cortes verticales visibles. Esa aceptación visual quedó rechazada.
El marco vigente usa **el PNG original completo**, reducido proporcionalmente a
1024×341, sin recortar el lienzo ni retirar píxeles del original. Un ImageLabel
Fit por control, ImageRectOffset/Size en cero y sin hijos de segmentación.
El marco anterior `104332063179973` queda solo como historial/respaldo.

**Aplicado en Lobby y Match**, por pedido del usuario; HUD de las referencias:
barras de arma/gancho, mochila, monedas, estado, tabla, cursor y salida/retorno.
También TeamScore del HUD VS usa el marco general. Las ventanas de mochila/tienda,
calendario y la placa completa del manual conservan sus fuentes independientes.

| Arte del usuario | Archivo preparado | ID | Fuente editable en ambos Places |
|---|---|---|---|
| Barra arma.png | `assets/ui/battle_weapon_bar.png`, 496×120 | `91629418883833` | `ReplicatedStorage.UIAssets.BattleHud.WeaponBar.Image` |
| Barra gancho.png | `assets/ui/battle_hook_bar.png`, 496×120 | `95575967228479` | `ReplicatedStorage.UIAssets.BattleHud.HookBar.Image` |
| HUD GENERAL BATALLA.png | `assets/ui/battle_general_frame_full.png`, 1024×341 | `138592401278319` | `ReplicatedStorage.UIAssets.BattleHud.GeneralFrame.Image` |

`prepare_battle_hud.py` conserva los originales y prepara recortes con alfa de
**las barras**: retira su gran espacio vacío, trazos externos y mate rojo. No dibuja
energía en el PNG. El marco general solo se reduce de tamaño, conservando el lienzo
completo. Coordenadas/medidas en battle_hud_manifest.json; IDs en battle_hud_asset_ids.json.
Las fuentes originales son 500×400 para cada barra y 2172×724 para el marco.

### Contrato y edición

- `Shared.BattleHudArtwork` enlaza el HUD existente. HudController conserva sus
  referencias a los **Fill reales**; solo pasan a ser hijos de
  `EnergyBar.ZBAtlas_BattleTrack` / `HookEnergyBar.ZBAtlas_BattleTrack`. No agrega
  otro productor de energía ni cambia consumo, regeneración, máximos o daño.
- Los títulos vienen incorporados en cada PNG. El icono se superpone en su hueco;
  el Fill usa color cian/violeta y conserva la alerta existente de recurso bajo.
- Hueco de relleno, en píxeles del recorte: (109,59)–(465,79). Attributes de
  WeaponBar/HookBar: FillX, FillY, FillWidth y FillHeight en escala 0..1.
  Al reemplazar arte con otra geometría, ajustar estos cuatro valores.
- El marco general usa una sola imagen completa con ScaleType.Fit. PixelWidth/
  Height=1024/341; RenderMode=FullImageFit. SliceCenter está vacío y no se usa.
  Texto e iconos se colocan dentro del área realmente dibujada, incluidos sus
  márgenes cuando el contenedor tiene otra proporción. Los accesos de escritorio
  reservan más alto para conservar la imagen; su grupo se reduce proporcionalmente
  en ventanas bajas para no superponerse al contador de monedas.
- Texto vivo e iconos son hijos separados. Los botones originales conservan
  Activated/atajos; se retira su UIFrameSkin anterior para evitar doble marco.
  En TeamScore se preservan score, ronda, avatares y señales; solo cambia el fondo
  y el orden visual de sus hijos. No copiar nombres/puntuaciones de una captura.
- `CoinsLabel.Icon` se **reutiliza**, conservando FeedbackScale y el destino de
  CoinBurstEffect. No sustituirlo por otro icono invisible para la lógica de monedas.
- Configuration `UIAssets.BattleHud`: DesktopBarWidth=390, MobileBarWidth=250,
  EdgeMargin=18. Desktop: barras abajo a la izquierda y accesos a la derecha;
  móvil: barras arriba a la izquierda, navegación compacta superior y acciones
  táctiles existentes libres. Los accesos interactivos móviles tienen 44 px de alto.
- MobileHudLayout cede las posiciones de los controles marcados BattleHudArtwork
  al módulo nuevo: no volver a ponerles el layout circular antiguo en cada evento.
  AtlasUIController omite el estilizado viejo de las barras. Los dos módulos de
  layout no deben alternar Position entre dos composiciones (ver BUGS B26).
- Lobby tenía ZB_EquipmentDashboard.Enabled=false; queda true para que el acceso
  MOCHILA pueda verse. Panel/Backdrop siguen cerrándose al arrancar por su controlador.
  En el layout compacto del menú se añadieron guardas para el Logo editado como
  ImageLabel: no exige Symbol/Brand si el diseñador los reemplazó.

### Verificaciones y límites

- Libre real solicitado por JoinMatchRequest: disparo con mouse, energía mínima
  58.6/100 y Fill=.586; gancho con Q, mínimo 83.5875 y Fill=.835875. Regeneran.
- Escritorio Lobby: captura final, B abre mochila, click en acceso de tabla abre
  ScorePanel, click en salida vuelve a LOBBY y oculta ambas barras. El primer
  intento de Tab no confirmó apertura; no presentarlo como validación del atajo.
- iPhone 17 Pro: viewport 750×381, Sensor y DeviceSafeInsets; capturas de ambos
  Places con tres acciones móviles sin superposición con las barras. B en el
  simulador abre mochila y oculta acciones; no acredita dedos físicos.
- Match: estado de combate **local de QA**, sin TeleportData válido. Captura de
  50 % de arma / 25 % de gancho y prueba de 0/100 % con Fill=0/1. Header VS con
  score/ronda visibles y marco nuevo, monedas separadas. No equivale a partida VS.
- Respawn real en Libre conservó un ZB_HUD, dos adornos de barra y el Icon de monedas
  visible. Las tres imágenes cargaron Success en ambos clientes.
- Tras corregir la reentrada de layout, el arranque final móvil de Lobby no mostró
  errores de estos controladores. Match aislado conserva REJECT_INVALID_TELEPORT_DATA
  y fallos HTTP de retorno propios de esa entrada; no se eliminan para probar UI.
- Fuente final tras retirar segmentos: BattleHudArtwork 13259 bytes / hash base31 1436495399;
  MobileHudLayout 7955 / 345823333; HudController.client 13380 / 1468298979.
  AtlasUIController conserva diferencias de Place; no se reemplazó por una copia global.

**Reversión:** en cada Place `ServerStorage.ZB_BattleHudArtworkBackup_20261026`
contiene las fuentes/plantillas originales por OriginalPath; Lobby también guarda
EquipmentDashboardLayout, Match VersusHud. Restaurar con Play detenido y retirar
Shared.BattleHudArtwork/UIAssets.BattleHud solo después de restaurar sus consumidores.
Las copias Script/LocalScript del respaldo están deshabilitadas.
Respaldo adicional de la composición rechazada: por Place
`ServerStorage.ZB_BattleHudFullFrameBackup_20261026` (módulo y BattleHud previos).
QA de la corrección: capturas Lobby escritorio/iPhone 17 Pro y Match escritorio
con estado local; cero ZBAtlas_Horizontal, todos los textos vivos de accesos con
TextFits=true y sin recorte interno. En Match de viewport bajo se comprobó además
que el contador termina antes de que comience el acceso de tabla. Ver BUGS B27.
Ambos Places quedan en Edit, simulador default y sin fixtures; servidor local de
subida cerrado. **Sin publicación**. Falta aceptación visual del usuario, teléfono
físico y recorrido VS publicado con estos cambios.

## Corte de edición actual — 2026-10-26

Esta auditoría describe el estado anterior a la integración del HUD de arriba.
Sus diferencias de mochila/armas entre Places siguen pendientes salvo lo indicado
expresamente en esa integración.

**Lobby y Match no tienen la misma mochila.** Lobby usa la plantilla completa
`EditableEquipment=true`; Match mantiene el panel generado por su controlador.
Los marcos compartidos MarcoHUD siguen en UIAssets.Skins de ambos, pero ya no son
la fuente de arte del Panel nuevo del Lobby. No volver al constructor antiguo para
que una instrucción anterior de PanelFrameSkin vuelva a surtir efecto.

### Mochila/tienda editable de Lobby

```text
StarterGui.ZB_EquipmentDashboard  [EditableEquipment=true, ViewportMargin=18]
├─ OpenInventory
├─ OpenWeaponOffer (BindableEvent)
├─ Backdrop
├─ Panel (Frame, 1360×720; Visible=true para vista de edición)
│  ├─ Artwork / Interior / ResponsiveScale
│  ├─ Sidebar
│  │  ├─ Artwork / Interior / Logo / PlayerProfile
│  │  ├─ Navigation.Resumen / Armas / Láser / Gancho / Mejoras
│  │  └─ Wallet.Artwork / Coin / Amount / Caption
│  ├─ Header.Title / Subtitle
│  ├─ Close (ImageButton con Caption)
│  ├─ Summary (ScrollingFrame, Layout y Card1..Card4 prearmadas)
│  ├─ Cards (ScrollingFrame con Layout; catálogo de runtime)
│  └─ Status
└─ Templates.CatalogCard (TextButton)
   └─ Artwork / IconFrame / Icon / Title / Detail / Divider / Action / Interior
```

| Qué cambiar en Lobby | Instancia / propiedad | Valor observado |
|---|---|---|
| Marco principal | `Panel.Artwork.Image` | `rbxassetid://92094831612893` |
| Marco lateral | `Panel.Sidebar.Artwork.Image` | Mismo ID; edición local independiente |
| Marcos del resumen | `Panel.Summary.Card1..Card4.Artwork.Image` | Mismo ID |
| Marco de nuevas fichas | `Templates.CatalogCard.Artwork.Image` | Mismo ID |
| Arte de navegación | `Panel.Sidebar.Navigation.<categoría>.Artwork.Image` | `99022357719006`, Fit |
| Fondo del saldo | `Panel.Sidebar.Wallet.Artwork.Image` | `99022357719006`, Slice |
| Marco de avatar/iconos | `PlayerProfile.Frame` y `CardN.IconFrame.Image` | `95844709202495`, Fit |
| Cierre | `Panel.Close.Image` | `95844709202495`, Crop; conservar Caption y Activated |
| Logo local | `Panel.Sidebar.Logo.ImageLabel.Image` | `127685112771699` |
| Moneda local del saldo | `Panel.Sidebar.Wallet.Coin.Image` | `119594247613582`; independiente de Icons.coin |
| Títulos estáticos del resumen | `Panel.Summary.CardN.Title.Text` | Conservados por controlador |
| Estilo de fichas del catálogo | `Templates.CatalogCard` y sus hijos | Clonado al cambiar categoría |
| Miniatura de arma/láser/punta | `ReplicatedStorage.UIAssets.WeaponImages/LaserImages/HookTipImages.<id>` | El controlador copia Image/rect/color a CatalogCard.Icon |

Estos IDs se leyeron de Studio; **no se identificó su PNG fuente en los manifiestos
locales**. No asociar `92094831612893` con `marco_hud_roblox.png` sin evidencia.
SliceCenter del arte principal/lateral/tarjetas: Rect(300,220,724,548); SliceScale
respectivo .5/.2/.22. Wallet: Rect(180,70,840,125), escala .3. Son propiedades de la
composición actual, no cortes recomendados para cualquier imagen de reemplazo.

El controlador actualiza avatar, saldo, cantidades, equipado y acciones desde datos
reales. La captura Edit muestra datos de ejemplo; al iniciar oculta Panel/Backdrop.
`Shared.EquipmentDashboardLayout` conserva el escritorio Edit y adapta a 980×450
horizontal bajo / 400×710 vertical estrecho. AtlasUIController respeta
EditableEquipment. **PanelFrameSkin no cambia estos Artwork locales.**

Respaldo en Lobby: `ServerStorage.ZB_EditableEquipmentBackup_20261023` (controlador,
AtlasUIController y GUI anteriores; atributo CreatedLayoutModule identifica el módulo
nuevo). Cualquier reversión debe emparejar fuentes y plantilla.
**Match no tiene EditableEquipment, Panel persistente ni EquipmentDashboardLayout**:
su migración conjunta y QA siguen pendientes. No copiar solo el LocalScript nuevo.

### Rankings del mundo: dónde editar ahora

- Lobby: `Workspace.Rankings3D.Monedas/Congelados/Victorias.Panel.RankingUI`.
  SurfaceGui Face Front, CanvasSize 840×990; panel físico 21×24.75.
  Ya no existe Workspace.placas. La guía anterior de RankGui/Face Right 220×275
  corresponde a las placas retiradas, no a estos objetos.
- MarcoPanel.Image=`92094831612893`; Cabecera/FilaN.Atlas usan
  `119594247613582` con recortes. Conservar ImageRectOffset/Size al editar un atlas;
  no aplicarles los cortes del MarcoHUD compartido.
- Fila1..Fila4.Jugador/Valor son dinámicos: servidor RankService → Rankings3DAPI →
  Rankings3DServer. Config es demo, no datos persistentes; DemoMode=false.
- Monedas/Victorias contienen Cabecera y Estado. **Congelados no tiene esos dos
  objetos**; documentado como diferencia de presentación pendiente (BUGS B25).
- Movimiento/partículas/proyección: seleccionar `Rankings3D.HologramConfig` y editar
  Attributes de grupos Movimiento_, Particulas_ y Proyeccion_. No confundir este
  HologramMotion activo con el HoloLevitation antiguo retirado.
- Respaldo del puente en Lobby: ZB_Rankings3DBridgeBackup_20261023. Match no tiene
  Rankings3D ni necesita copiar estos paneles para conservar estadísticas VS.

### Feedback de botones, música y protección

- Lobby: `ReplicatedStorage.UIAssets.Motion` (Configuration), Enabled=true,
  SoundEnabled=true, HoverScale=1.025, PressScale=.965, Duration=.1;
  HoverSoundCooldown=.07, ClickSoundCooldown=.04. Sonidos hijos Hover
  `119464366209531` (Volume≈4.516) y Click `84127928422864` (Volume=.3).
  Editar SoundId/Volume en Properties y probar en una sesión nueva.
- UIInteractionController crea tres voces por sonido, precarga asíncrona, limita
  repetición y omite audio no cargado. Respeta Active/Interactable/UISkinDisabled,
  UIInteractionEnabled en ancestros y UIInteractionSoundEnabled en botón.
  Escala contenido de acciones móviles sin cambiar su hitbox; no crea el contorno
  de hover retirado. **Match aún tiene la versión anterior, sin audio ni Sounds.**
- Música en ambos: `SoundService.ZB_Music.Lobby` (`134069101231435`, .25) y
  `.Battle` (`101240840700787`, .28), Looped. ZoneMusicController elige por estado
  individual/Place; MusicFadeDuration=.6 en PresentationSettings. Los MP3 locales
  no se reproducen directamente desde disco. Permisos y mezcla Player pendientes.
- Protección en ambos: `ZB_SpawnProtection.Notice.Banner.PowerUpMessage` permite
  presentar el azul sin afirmar que disparar lo cancela. `ProtectionType` es
  PowerUp/Spawn; PowerUpShieldEndsAt tiene prioridad sobre SpawnProtectionEndsAt.
  No retirar ese hijo al reemplazar Banner. La sección 0.8 describe el primer aviso;
  su restricción antigua a aparición quedó superada.

### Paridad de assets comprobada en Edit

Icons, los cuatro Skins MarcoHUD, HookTipImages default/heavy y las cinco LaserImages
coinciden en ambos Places. WeaponImages **solo tiene IDs en Lobby**: Match mantiene
blaster/rifle/cannon vacíos. WeaponOffers también existe solo en Lobby. Esto sigue
pendiente de adaptación y no debe registrarse como sincronización terminada.

Alcance de esta revisión: lectura y captura Edit, sin Play, publicación ni carga de
assets en Player. Las QA de abajo corresponden a sus fechas, no a la composición
actual de Lobby. Respaldo de feedback: ZB_UIButtonFeedbackBackup_20261023 en Lobby.

## 0.9 Guía definitiva: cambiar CUALQUIER imagen sin equivocarse

### Las 6 reglas de oro

1. **Detené Play antes de editar el origen.** Los cambios hechos en
   `StarterGui` con una prueba en curso **no** llegan a la copia que ya está en
   `Players > [tu usuario] > PlayerGui`. Para una prueba puntual podés editar
   esa copia de `PlayerGui`, pero se pierde al detener Play. Los fondos de skin
   (`ZBAtlas_Background`) se clonan **una vez** al iniciar la pantalla: cambiar
   `Skins.intro.Image` con Play corriendo no actualiza la copia ya creada.
2. **Editá la plantilla compartida, no una copia generada.** Las tarjetas,
   botones y paneles crean copias en runtime (`ZBAtlas_Background`, `Card1`, etc.).
   Cambiar una copia en `PlayerGui` no cambia el juego.
3. **Mantené nombres, rutas y atributos.** Los controladores buscan por nombre
   (`WeaponOfferSign`, `HookOfferPrompt`, `Skins.intro`, etc.). Renombrar rompe
   el enlace aunque la imagen se vea.
4. **Un PNG por uso.** Icono: transparente, cuadrado, `ScaleType=Fit`. Marco:
   transparente, 9-slice, `ScaleType=Slice`. No uses un atlas recortado para
   reemplazar un panel completo.
5. **Sin texto quemado en la imagen**, salvo avisos que lo necesiten (por ejemplo,
   el banner de PROTEGIDO). El texto vivo va en TextLabel para poder traducir,
   escalar y editar.
6. **Probar en Play, después publicar.** Studio verifica el diseño; la publicación
   lleva el cambio a jugadores. Un ID publicado tarda en propagar caché.

### Mapa: qué instancia editar para cada imagen

| Qué querés cambiar | Instancia exacta | Propiedad / ajuste |
|---|---|---|
| Íconos de la UI (bolso, calendario, arma, gancho, etc.) | `ReplicatedStorage.UIAssets.Icons.<clave>` | `Image`; `ScaleType=Fit`; 256×256 |
| Imagen de un arma en tienda/mochila | `ReplicatedStorage.UIAssets.WeaponImages.<id>` | `Image`; 512×512 |
| Imagen de punta de gancho | `ReplicatedStorage.UIAssets.HookTipImages.<id>` | `Image`; 512×512 |
| Imagen de color de láser | `ReplicatedStorage.UIAssets.LaserImages.<id>` | `Image`; 512×512 |
| **Placa completa del manual de inicio** | **`StarterGui.ZB_Intro.Instructions.Artwork`** | `Image`; `ScaleType=Fit`; 1024×768 (arte con textos ya incluidos) |
| **Botón ENTENDIDO (imagen completa)** | **`StarterGui.ZB_Intro.Instructions.Continue`** | `Image`; `ScaleType=Fit`; 1024×341; es un ImageButton |
| Marco 9-slice alternativo (no usado ahora) | `ReplicatedStorage.UIAssets.Skins.intro` | `Image` + `SliceCenter` + `SliceScale` + `PixelWidth/PixelHeight` |
| Marco compartido de otros paneles | `ReplicatedStorage.UIAssets.Skins.panel` | Igual que `intro`; **afecta varios paneles** |
| Fondo/tarjeta compartida | `ReplicatedStorage.UIAssets.Skins.card` | Igual que `intro` |
| Botones (normal/hover/pressed) | `Skins.button_cyan_*` / `button_violet_*` | `Image`; el sistema elige el estado |
| Banner de protección | `StarterGui.ZB_SpawnProtection.Notice.Banner` | `Image`; `ScaleType=Fit` |
| Íconos del manual | `StarterGui.ZB_Intro.Instructions.Rows.RowNN.Icon` | `Image` propio; si está vacío usa `UIAssetKey` |
| Logo del manual | `StarterGui.ZB_Intro.Instructions.Logo` | `Image` propio o `UIAssetKey=emblem` |
| Textos del manual | `StarterGui.ZB_Intro.Instructions.*` | `Text`, `TextSize`, `TextColor3`; no tocar nombres |
| HUD y accesos móviles | `StarterGui.ZB_*` + `UIAssets.Icons` | Propiedades; `MobileHudLayout` reubica en Play |
| Placas de ranking | `RankGui` (SurfaceGui/BillboardGui) | `Image` del fondo; conservar nombres |

**El manual actual usa una placa completa, no un fondo 9-slice.** La imagen
`Instructions.Artwork` contiene el marco, los títulos y las instrucciones. El
contenido vivo viejo (`Logo`, `Title`, `Subtitle`, `Rows`) queda oculto para no
duplicar texto. El botón es una imagen completa (`Continue`, ImageButton) ubicada
sobre el borde inferior de la placa, en la posición editable que definiste en
Edit; no es un skin con texto encima.

**Modo arte completo** (`ZB_Intro.FullArtIntro = true`): `AtlasUIController`
toma como referencia el tamaño del panel, la placa y el botón **tal como los
dejaste en Edit**, y escala todo junto para el viewport. Así el botón conserva su
posición y tamaño relativo: en la versión actual queda **superpuesto al borde
inferior de la placa**, como en el editor. Si `Artwork` no existe o su `Image`
está vacía, vuelve automáticamente al manual clásico con las filas vivas. Ese
respaldo evita una pantalla en blanco.

Atributos de `ZB_Intro`:

| Atributo | Valor actual | Uso |
|---|---|---|
| `FullArtIntro` | `true` | Activa la placa completa |
| `IntroMaxWidth` | `980` | Ancho máximo en escritorio |

`IntroAspect`, `ContinueAspect`, `ContinueWidthScale` y `ContinueGapScale` quedan
como legado y ya no determinan la posición. El diseño se controla moviendo
`Artwork` y `Continue` en StarterGui. Valores actuales del botón: `Position`
`(0.5, 0.835913)`, `Size` `322×89`, `AnchorPoint` `(0.5, 1)`.

### Reemplazar la placa y el botón: paso a paso

1. **Detené Play.**
2. Dejá los archivos como `docs/assets/ui/intro_plate.png` y
   `docs/assets/ui/btn_entendido.png` (o pasámelos).
3. Subilos a Roblox y copiá los dos `rbxassetid://...`.
4. Seleccioná **`StarterGui.ZB_Intro.Instructions.Artwork`**, pegá el ID de la
   placa en **Image**. Debe ser `ScaleType = Fit`.
5. Seleccioná **`StarterGui.ZB_Intro.Instructions.Continue`**, pegá el ID del
   botón en **Image**. Es un **ImageButton**, `ScaleType = Fit`, sin texto.
6. Verificá que `ZB_Intro.Instructions` tenga `UIFrameSkin` **vacío** (sin skin
   encima) y que `Logo/Title/Subtitle/Rows` estén en `Visible = false`.
7. **Play** y comprobá:
   - La placa se ve nítida y el botón conserva la posición que le diste en Edit.
   - En la versión actual el botón se superpone al borde inferior, sin tapar la
     última fila.
   - `Artwork.IsLoaded = true` y `Continue.IsLoaded = true`.
   - Al tocar **ENTENDIDO**, `ZB_Intro.Enabled` pasa a `false`.
   - Probá **1365×768**, **750×381** y **370×650**.
8. **Stop** y **publicá ambos Places**.

**IDs aplicados el 19/10:** placa `98656833460778`; botón `106514786390752`.
Origen: `placa inicio.png` 1448×1086 y `btn entendido.png` 2172×724; versiones
optimizadas en `assets/ui/intro_plate.png` (1024×768) y `btn_entendido.png`
(1024×341). IDs en `assets/ui/intro_asset_ids.json`.

| Recurso | Formato | Tamaño | Fondo | Peso orientativo |
|---|---|---|---|---|
| Placa completa | PNG RGBA | 1024×768 (4:3) | Transparente fuera del marco; interior opaco | ~1 MB |
| Botón ENTENDIDO | PNG RGBA | 1024×341 (≈3:1) | Transparente alrededor | ~330 KB |

La placa no es 9-slice: es una ilustración completa con los textos incorporados.
Mantené la proporción 4:3 si la reemplazás; si cambiás el texto de una fila, hay
que editar la imagen (las filas vivas están ocultas). El botón también es una
imagen completa: no lleva TextLabel encima.

**Ojo:** el manual se habilita desde `LoadingScreen.client` al terminar la carga.
Poner `StarterGui.ZB_Intro.Enabled = false` **no lo oculta al entrar**: el loading
lo vuelve a encender. Para saltarlo hay que modificar ese flujo o eliminarlo; el
botón de ayuda del HUD lo reabre si existe.

### MarcoHUD y corrección de deformación — 2026-10-23

**Sustituye la primera integración del panel ámbar de abajo**, rechazada por el
usuario porque las franjas decoradas seguían alargándose. `ScaleType=Slice`
protege las esquinas, pero estira los adornos que estén dentro de los bordes.

Arte vigente: `assets/ui/MarcoHUD.png` (1329×1183), preparado sin cambiar proporción
como `marco_hud_roblox.png` (1024×912). ID `rbxassetid://106613197873068`.
Proceso reproducible: `assets/ui/prepare_marco_hud.py`; cortes y tamaño en
`marco_hud_manifest.json`; ID en `marco_hud_asset_ids.json`.

En ambos Places, `ReplicatedStorage.UIAssets.Skins.panel`, `card`,
`panel_violet` y `panel_warning` usan este arte. Se cubren panel principal,
tarjetas, lateral de mochila/tienda, calendario y ranking. Las claves se conservan
para mantener los enlaces de las pantallas. Selección del panel principal:
`StarterGui.ZB_EquipmentDashboard.PanelFrameSkin="panel_warning"`; calendario:
`StarterGui.ZB_DailyActivities.ActivitiesPanel.UIFrameSkin="panel_warning"`.

| Propiedad de las cuatro plantillas | Valor |
|---|---|
| Image | `rbxassetid://106613197873068` |
| PixelWidth / PixelHeight | `1024` / `912` |
| SliceCenter | `(276,246)–(748,666)` |
| SliceScale | `.12` |
| OriginalSourceFile | `MarcoHUD.png` |

**Render compuesto:** `Shared.UIFrameSkins` delega en `Shared.UIFrameArtwork`.
En vez de estirar el PNG completo con Slice, construye nueve zonas más cuatro
adornos centrados. Esquinas y adornos tienen la misma escala X/Y; solo relleno y
uniones de un píxel se extienden. Un degradado de transparencia funde el sombreado
interior de los recortes. Cada fondo reutiliza 13 ImageLabels; no hay un bucle de
actualización por frame. Los offsets se calculan en espacio local, compensando
UIScale para que el arte no reciba escalado móvil dos veces.

`ZBAtlas_Background` es ahora el contenedor ImageLabel del conjunto: su propia
imagen tiene `ImageTransparency=1`; las piezas hijas presentan el arte mediante
`ImageRectOffset/Size`. No volver a mostrar la imagen estirada del contenedor.
Las mismas reglas se aplican a los estados de botones.

**Borde fino celeste adicional:** el render deshabilita los UIStroke del objeto
enlazado, incluidos botones compactos y strokes insertados después del primer
enlace. `UIInteractionController` ya no crea `ZBAtlas_Motion/ZB_MotionOutline` ni
su tween: el hover anima únicamente la escala del arte y no dibuja otro rectángulo.
Si falla la imagen, se conserva el fondo nativo. El foco dorado de una oferta
(`ZBAtlas_OfferFocus`) es una indicación independiente de selección.
También se deshabilitan los diez UIStroke de las plantillas de miniaturas en
`UIAssets.WeaponImages`, `HookTipImages` y `LaserImages` de cada Place; quedan
respaldadas en `ZB_MarcoHUDBackup_20261023`.

**Ranking:** `AtlasUIController` hace coincidir CanvasSize con la cara física del
SurfaceGui. Las placas actuales tienen cara Right de 20×25: canvas 220×275,
en vez de 220×160. El error anterior deformaba también textos e iconos. La
corrección de proporción está en ambos controladores; las placas de Lobby también
quedan corregidas en Edit.

Respaldos por Place: `ServerStorage.ZB_FrameUndistortedBackup_20261023` (antes
del render compuesto) y `ServerStorage.ZB_MarcoHUDBackup_20261023` (antes del arte
nuevo y retiro de strokes). Para volver a la versión inicial, restaurar los
scripts y plantillas del primer respaldo, y las propiedades de las placas.
Para volver solo al arte anterior, restaurar Skins del segundo respaldo.

QA final: mochila en ambos Places, hover y cambio real a Armas en Lobby; tienda
y calendario en simulador iPhone 17 Pro horizontal (750×381). La inspección de
mochila/tienda confirma cero UIStroke extra activos (se excluye el foco dorado de
oferta) y cero objetos de contorno de hover. Las miniaturas se regeneraron en
runtime con la misma propiedad Enabled=false luego persistida en sus plantillas.
Sin errores nuevos de UI en Output; Match aislado mantiene el rechazo de
TeleportData y los errores HTTP de retorno. No se hicieron compras/cobros.
Ambos Places quedan en Edit, simulador restablecido y servidor local de subida
cerrado. Sin publicación; aceptación visual definitiva pendiente del usuario.

Paridad final en ambos Places (bytes / hash base31 módulo 2³²): UIFrameArtwork
3939 / 1007664111; UIFrameSkins 7517 / 2558559060; UIInteractionController
3890 / 3701533704.

### Primera integración del panel ámbar — 2026-10-23 (historial)

Se reutiliza `assets/ui/ui_panel_warning.png`, ya subido como
`rbxassetid://113491494447703`. No hace falta volver a subirlo.

| Propiedad | Valor |
|---|---|
| Plantilla editable en ambos Places | `ReplicatedStorage.UIAssets.Skins.panel_warning` |
| `ScaleType` | `Slice` |
| Fuente `PixelWidth` / `PixelHeight` | `512` / `456` |
| `SliceCenter` | `Rect.new(120, 110, 392, 346)` |
| `SliceScale` | `0.24` (el controlador puede reducirlo para que quepa) |
| Selector mochila/tienda, ambos Places | `StarterGui.ZB_EquipmentDashboard` → atributo `PanelFrameSkin="panel_warning"` |
| Selector calendario, Lobby | `StarterGui.ZB_DailyActivities.ActivitiesPanel` → `UIFrameSkin="panel_warning"` |

Mochila y tienda comparten el `Panel` dinámico de `EquipmentDashboard`. El
controlador le asigna `UIFrameSkin` **antes de parentarlo** a la GUI para que
el primer enlace del tema use el marco seleccionado. La imagen visible en Play
es `PlayerGui.ZB_EquipmentDashboard.Panel.ZBAtlas_Background`; en calendario,
`PlayerGui.ZB_DailyActivities.ActivitiesPanel.ZBAtlas_Background`.

Match tiene mochila; tienda y calendario siguen siendo funciones de Lobby.
Los selectores afectan al marco principal, no a las tarjetas internas.
El manual conserva su placa completa. Para editar el marco, cambiar la plantilla
`Skins.panel_warning` en Properties. Los cambios de StarterGui se comprueban en
una sesión Play nueva.

Verificación: capturas Play de mochila en ambos Places y calendario en escritorio;
tienda y calendario en iPhone 17 Pro horizontal (viewport 750×381), más calendario
vertical. El recurso carga al hacerse visible y conserva Slice/cortes/escala.
Las aperturas de tienda y calendario usaron BindableEvent/propiedades del cliente:
esto valida presentación, no compras, cobros ni touch físico. Output mostró avisos
de espera de plantillas durante el arranque; Match también rechazó TeleportData
ausente y registró errores de retorno en la prueba aislada.

Respaldo por Place: `ServerStorage.ZB_WarningPanelsBackup_20261023`, con
`OriginalPath` en cada clon. Ambos Places terminaron en Edit, simulador de Lobby
restablecido al viewport normal. Sin publicación.

Referencia: <https://create.roblox.com/docs/es-es/ui/9-slice>. Los cortes dejan
esquinas fijas, bordes escalados en un eje y centro escalado en ambos ejes.

### Si algún día usás un marco 9-slice en vez de la placa

El sistema anterior sigue disponible: `Skins.intro` existe para eso. Sirve cuando
el marco NO tiene texto ni filas adentro y querés que el contenido vivo se estire
dentro. Pasos: detener Play, poner `Instructions.UIFrameSkin="intro"`, reemplazar
`Skins.intro.Image`, configurar `ScaleType=Slice`, `SliceCenter` y `SliceScale`
según la especificación de abajo. No lo uses con la placa completa: el texto se
deformaría.

### Especificación para un marco 9-slice (opcional)

| Requisito | Valor |
|---|---|
| Formato | **PNG RGBA** (canal alfa real; nada de JPG ni damero pintado) |
| Lienzo recomendado | **1024 × 1024 px** (cuadrado; el panel se adapta con 9-slice) |
| Peso recomendado | **< 1 MB** (ideal 200–600 KB); evitar ruido/fotografía |
| Margen exterior de brillo | **32 px** desde el borde del lienzo |
| Zona de esquinas | **96 × 96 px** cada una; ahí va TODO el arte/curva/ornamento |
| Zona de bordes | 832 × 96 y 96 × 832; **patrón uniforme** (se estira en un eje) |
| Centro | 832 × 832; **liso/oscuro**, sin logos ni texto; se estira en ambos ejes |
| `SliceCenter` | **Rect(96, 96, 928, 928)** |
| `PixelWidth` / `PixelHeight` | **1024 / 1024** |
| Transparencia | Fondo **transparente**; el relleno oscuro va dentro del marco |
| Texto/logos | **Ninguno** (van como TextLabel/ImageLabel aparte) |
| Esquinas seguras | No poner detalles importantes a menos de 96 px del borde |
| Estilo | Bordes y esquinas consistentes con el HUD; evitar líneas de 1 px |
| Nombre de archivo | `intro_frame.png` (o variante clara: `intro_frame_v2.png`) |

El marco debe verse bien en **700×540** (escritorio), **740×340** (pantalla baja)
y **370×650** (vertical). Por eso el centro y los bordes deben poder estirarse.
Si querés un marco con una forma muy distinta, avisá: hay que ajustar también la
posición de filas/botón, no solo la imagen.

Guía visual: **`docs/assets/ui/frame_9slice_guide.png`** (lienzo 1024×1024,
líneas rojas en 96/928, leyenda debajo).

### 9-slice: por qué y cómo (práctica recomendada por Roblox)

Roblox divide la imagen en nueve sub-imágenes:

| Región | Escalado |
|---|---|
| 1, 3, 7, 9 (esquinas) | ninguno |
| 2, 8 (bordes superior/inferior) | horizontal |
| 4, 6 (bordes izquierdo/derecho) | vertical |
| 5 (centro) | horizontal + vertical |

Referencia oficial: <https://create.roblox.com/docs/es-es/ui/9-slice>.
En Studio: seleccionar el ImageLabel → `ScaleType = Slice` → `SliceCenter` →
editor visual; los offsets son píxeles desde cada borde. Las esquinas nunca se
deforman; por eso todo el detalle debe vivir ahí.

### Diagnóstico rápido: “cambié la imagen y no se ve”

| Síntoma | Causa más probable | Solución |
|---|---|---|
| Sigue la placa/marco anterior | `Artwork.Image` no cambió, o editaste `PlayerGui` durante Play | Detené Play, cambiá `Artwork.Image` y volvé a probar |
| Se ve la placa pero no el botón | `Continue.Image` vacío, no carga o quedó detrás | Revisar `Continue.Image`, `IsLoaded`, `ZIndex=3` |
| Texto duplicado (viejo + placa) | `Logo/Title/Subtitle/Rows` visibles | Deben estar ocultos; con `FullArtIntro` se ocultan solas |
| Pantalla en blanco | `Artwork.Image` vacío o `FullArtIntro` mal | El controlador vuelve al manual clásico; si no, revisar el atributo |
| El botón no responde | `Continue` no es `ImageButton`/`Active=false` | Es `ImageButton`, `Active=true`, `Activated` conectado |
| No aparece al entrar | `LoadingScreen.client` hace `Enabled=true` | Es el flujo actual; para saltearlo hay que modificarlo |
| Esquinas estiradas/borrosas (solo 9-slice) | `SliceCenter` o `SliceScale` mal | Reabrir el editor de 9-rodajas |
| Aparece cuadrado sin bordes (solo 9-slice) | `ScaleType` no es `Slice` | Cambiar a `Slice` |
| Fondo blanco/damero | PNG sin alfa o damero pintado | Exportar RGBA transparente |
| Cambió también la tienda/calendario | Editaste `Skins.panel` | Restaurar `panel`; el manual usa `Artwork` |
| No cambia nada en el juego publicado | Falta publicar o el asset está en moderación | Publicar ambos Places; verificar ID/permiso |

### Para cambiar otras imágenes: mismo patrón

1. Detené Play.
2. Identificá la instancia en la tabla de arriba (nunca una copia `ZBAtlas_*`).
3. Reemplazá **solo `Image`**; conservá `Size`, `Position`, `ScaleType`,
   `SliceCenter`, atributos y nombre.
4. Si es icono o placa completa: `ScaleType=Fit`, PNG cuadrado/panorámico con alfa.
5. Si es marco 9-slice: `ScaleType=Slice`, `SliceCenter` + `PixelWidth/PixelHeight`.
6. Play → inspeccionar la copia en `PlayerGui` → captura → Stop → publicar.

**No hace falta tocar scripts para reemplazar arte.** Si una imagen no aparece,
el problema es la instancia/atributo/asset, no el código.

## Atlas integrados — 2026-10-13

**Aplicados y probados en Studio en Lobby y Match; sin publicar los Places.**
Las imágenes sí están subidas a Roblox y sus 28 IDs cargaron correctamente en ambos clientes.

### Archivos de entrega

- Fuentes del usuario en `docs/assets/`: hoja de iconos **1254×1254**, botones
  **1774×887**, marcos **1254×1254**. No coinciden con las medidas del prompt;
  se recortaron usando sus dimensiones reales, no coordenadas supuestas de 1024.
- `docs/assets/ui/`: **16 PNG de iconos, 8 PNG de estados de botones y 4 PNG de paneles**.
- [atlas_manifest.json](assets/ui/atlas_manifest.json): recortes, medidas reales y SliceCenter.
- [roblox_asset_ids.json](assets/ui/roblox_asset_ids.json): los 28 IDs empleados en ambos Places.
- [atlas_preview.jpg](assets/ui/atlas_preview.jpg): referencia local de recortes/transparencia.
- Iconos y botones ya tenían alfa. Los marcos tenían damero pintado, sin transparencia:
  se retiró el exterior neutro conservando el cuerpo y los biseles del marco.

### Dónde editar en Studio

| Recurso | Instancia | Propiedades |
|---|---|---|
| Iconos | `ReplicatedStorage.UIAssets.Icons.<clave>` | Image, ImageColor3; ScaleType=Fit |
| Marcos | `ReplicatedStorage.UIAssets.Skins.panel`, `card`, `panel_violet`, `panel_warning` | Image, SliceCenter, SliceScale |
| Botones | `ReplicatedStorage.UIAssets.Skins.button_cyan_<estado>` / `button_violet_<estado>` | Image, SliceCenter, SliceScale |
| Fondo/manual de inicio | `StarterGui.ZB_Intro.Instructions.Artwork` | Image; ScaleType=Fit (placa completa) |
| Botón ENTENDIDO | `StarterGui.ZB_Intro.Instructions.Continue` | Image; ScaleType=Fit (ImageButton) |
| Fondo de actividades | `StarterGui.ZB_DailyActivities.ActivitiesPanel` (Lobby) | UIFrameSkin=`panel_violet` |
| Botones de reclamación | ClaimDailyButton / Claim de la plantilla | UIFrameSkin=`button`, UISkinFamily=`violet` |

Estados: `normal`, `hover`, `pressed`, `disabled`. Gancho usa botones violeta;
el resultado de ronda usa marco ámbar. Los controles táctiles circulares mantienen
su forma nativa y reciben los nuevos iconos; no se les estira un botón rectangular.
Las claves de iconos sin dibujo en estos atlas conservan sus trazos anteriores.

### Protección contra deformación y comportamiento

- Iconos: PNG **256×256**, dibujo centrado dentro de 192×192; `Fit` conserva proporción.
- Botones: PNG **512×352**, SliceCenter `(120,115)–(392,237)`, SliceScale base **0.12**.
- Panel: **512×497**; card: **512×390**; violeta: **512×449**; aviso: **512×456**.
  SliceCenter `(120,110)–(392,alto−110)`, SliceScale base **0.24**.
- `Shared.UIFrameSkins` aplica 9-slice y reduce uniformemente la escala de las
  esquinas si falta espacio. Los segmentos centrales se alargan; las esquinas
  no se estiran en un solo eje. Botones cuadrados/estrechos mantienen el fondo nativo.
- `UIAssetSkinController` enlaza las plantillas marcadas y precarga sin bloquear UI.
  `UITheme` conecta los fondos del inventario y otras pantallas dinámicas.
- El fondo y el texto son elementos separados. `ZBAtlas_SkinText` sigue el Text,
  precio, fuente y color del control original; corrige texto muy oscuro sobre
  fondo oscuro. Editar el control original, no esa copia de runtime.
- Estados responden a hover/presión, Active/Interactable y atributos visuales
  UISkinSelected/UISkinDisabled. EquipmentDashboard solo recibió metadatos visuales.
- Si no carga un fondo, permanece el nativo; iconos recuperan Fallback si falta
  imagen o no se confirma carga. La precarga vuelve a sincronizar fondos/textos:
  no depende únicamente de señales IsLoaded del motor.

### Verificación y reversión

- **28/28** recursos con AssetFetchStatus.Success en ambos clientes; cero fallos de precarga.
- Capturas de manual y mochila de ambos Places en escritorio; botón presionado
  y seleccionado mediante mouse, navegación Gancho y regeneración de tarjetas.
- iPhone 17 Pro, viewport **750×381**: manual y mochila en horizontal, calendario
  horizontal y vertical. Marcos encajan y texto separado; contraste de Reclamar
  corregido y comprobado en escritorio. No certifica touch físico: parte de la
  apertura en simulador se hizo mediante propiedades y atajo B.
- StarterGui.ScreenOrientation sigue `Sensor`; las tres plantillas principales
  usan DeviceSafeInsets. La política de orientación del juego no se cambió.
- Prueba controlada: panel 940×500, violeta 370×650, aviso 460×250 y botones
  172×44 / 64×44 mantienen Slice; reaplicar no crea otro fondo y disabled usa su imagen.
- Respawn real: un manual, una mochila y ningún fondo duplicado en ambos Places.
  Navegación visual conservó 500 monedas y recursos 100/100; no se probó compra/cobro.
- Cinco fuentes compartidas compiladas e iguales entre Places. Sin errores nuevos
  de UI; Match aislado mantiene rechazo de TeleportData/HTTP, independiente del arte.
- Respaldo por Place: `ServerStorage.ZB_UIAtlasBackup_20261013`. Restaurar UIAssets,
  UITheme, AtlasUIController, EquipmentDashboard y las plantillas StarterGui guardadas;
  retirar UIFrameSkins y UIAssetSkinController para volver al tema previo.
- Fixtures retirados, servidor HTTP local cerrado, simuladores en `default` y ambos
  Places en Edit. Falta validar publicación, touch físico y carga bajo conexión móvil.

## 0. Calendario real editable — agregado 2026-10-09

**Lobby solamente:** seleccionar `StarterGui.ZB_DailyActivities`. El controlador
ya no construye esta pantalla. Su atributo `EditableCalendar=true` impide aplicar
el layout anterior del tema. Play detenido para modificarla; al iniciar se copia
una vez a PlayerGui y persiste al respawn.

```text
StarterGui.ZB_DailyActivities
├─ Backdrop
├─ CalendarButton
│  ├─ Icon
│  └─ PendingMarker
└─ ActivitiesPanel
   ├─ Title / Subtitle / CloseButton / ResetInfo / ResponsiveScale
   └─ Content (ScrollingFrame)
      ├─ Calendar
      │  ├─ PreviousMonth / MonthTitle / NextMonth / TodayButton / Legend
      │  ├─ Weekdays.Day1..Day7
      │  └─ Grid.Slot01..Slot42 (TextButtons con Number, Status y UIStroke)
      └─ Details
         ├─ SelectedDate / MissionsTitle / DateInfo
         ├─ RewardSection.Title / RewardInfo / ClaimDailyButton
         └─ MissionList.Row01..Row03 (Label, Progress, Claim)
```

| Cambio visual | Seleccionar | Propiedad |
|---|---|---|
| Título del calendario | ActivitiesPanel.Title | Text / FontFace / TextColor3 |
| Fondo de la ventana | ActivitiesPanel | BackgroundColor3 / UICorner |
| Fondo del mes | ActivitiesPanel.Content.Calendar | BackgroundColor3 |
| Textos de días de semana | Calendar.Weekdays.Day1..Day7 | Text / FontFace |
| Texto estático de recompensa | Details.RewardSection.Title | Text / TextColor3 |
| Icono de acceso | CalendarButton.Icon o UIAssets.Icons.calendar | Image |

Fechas, MonthTitle, SelectedDate, ResetInfo, saldo, progreso, precio y estado de
cobro son dinámicos: el servidor/controlador los actualiza. Colores de selección,
hoy y botones también representan estado. No renombrar hijos del contrato.
El layout adapta posiciones/tamaños; vertical usa scroll, desktop dos columnas.
La plantilla está protegida de la reconstrucción/estilizado antiguo de AtlasUIController.

Desde el 16/10 se guarda un historial diario por fecha (ver sección 0.7): verde
cobrado, rojo pasado sin cobrar, ámbar disponible y gris sin datos/futuro. Los días
anteriores al inicio del registro no se pintan de rojo para no inventar historial.
No hay historial completo de misiones; seleccionar una fecha no autoriza cobrarla.
Pruebas en CHECKLIST.

## 0.1 Controles táctiles — vigente 21/10, contrastado 26/10

**Lobby y Match:** `StarterGui.ZB_MobileControls`, atributo `MobileControls=true`
(no lo reestiliza AtlasUIController). Contiene `Actions` con botones redondos;

```text
StarterGui.ZB_MobileControls
└─ Actions
   ├─ Fire  (Caption "DISPARAR", Icon weapon, AbilityRing)
   ├─ Hook  (Caption "GANCHO", independiente del agarre)
   └─ Grab  (Caption "AGARRE" / "IMPULSO", icono grab)
```

**Up/Down retirados por pedido del usuario.** Tres acciones: Fire rojo a la derecha,
Hook verde a la izquierda y Grab azul encima del disparo. Fire: 112/96 px;
Hook y Grab: 80/68 px en vista normal/baja. El joystick nativo permanece independiente.

Mientras se mantiene el disparo se puede arrastrar ese mismo dedo para apuntar,
incluso fuera del círculo, o usar otro dedo en la zona derecha libre. Grab inicia
agarre de una cobertura cercana priorizando la mira; levantar el dedo mantiene
la sujeción. Grab pasa a **IMPULSO** y la siguiente pulsación libera/impulsa.
Hook no cambia de función. El comportamiento de dos botones del 19/10 es histórico.

| Cambio visual | Seleccionar | Propiedad |
|---|---|---|
| Tamaños normales | ZB_MobileControls | Attributes: FireSize=112, HookSize=80, GrabSize=80 |
| Tamaños en pantalla baja | ZB_MobileControls | SmallFireSize=96, SmallHookSize=68, SmallGrabSize=68 |
| Márgenes seguros de acciones | ZB_MobileControls | ActionEdgeMargin=22, ActionBottomMargin=26 |
| Sensibilidad de arrastre | ZB_MobileControls | TouchAimSensitivity=0.005625; +25 % sobre la versión del 19/10 |
| Cámara sobre hombro | ZB_MobileControls | TouchCameraShoulderOffset=2.6; TouchCameraHeightOffset=.8 |
| Forma / anillo interior | Actions.Fire / Hook / Grab y AbilityRing | UICorner / UIStroke; MobileControls actualiza colores de estado |
| Estilo de etiqueta | <botón>.Caption | Font / TextSize; Grab cambia por estado |
| Iconos de acción | <botón>.Icon | Image; UIAssets.Icons.weapon/hook/grab como plantillas |

Accesos de menú y HUD móvil los distribuye `ReplicatedStorage.Shared.MobileHudLayout`
en tiempo de ejecución, tomando `UIAssets.Icons` para iconos redondos (bag, calendar,
info, trophy, close) y añadiendo una leyenda corta. Los accesos migrados del HUD
se editan en StarterGui según la sección 0.2; en móvil su tamaño/separación se
configuran mediante atributos y su distribución cambia según viewport. La
lógica de intención vive en `Shared.LocalCombatInput` y `StarterPlayerScripts.MobileControls`.
`Shared.MobileAimInput` acumula delta por dedo; `BattleCameraController` lo consume
en la cámara orbital de combate también en touch. `launch` es intención local;
`GrabController.client` conserva la validación de estado/objetivo y el impulso
existente al liberar. No modifica autoridad del servidor, daño, energía ni precios.
Los controles solo aparecen con `TouchEnabled` en landscape y combate activo.

Historial QA Studio 19/10 (versión anterior de dos botones): iPhone 17 Pro (viewport 750×381), Fire/Hook 112/96; Galaxy A06
(705×338), 96/84, capturas sin superposición de acciones y leyendas completas.
Disparo+arrastre comprobado con eventos Touch del simulador; liberación del botón
IMPULSO comprobada con impulso 90 studs/s. Múltiples dedos también se comprobaron
con intenciones simuladas, no con dedos físicos. Match usa estado local de QA al
no disponer de TeleportData; no es una partida VS real. Ambos Places en Edit y
simuladores restablecidos al viewport default; publicación/teléfono real pendientes.
Respaldo por Place: `ServerStorage.ZB_MobileAimReleaseBackup_20261019`.

QA del ajuste de tres botones/cámara del 21/10: ver CHECKLIST. Respaldos por Place
ZB_MobileThreeActionsBackup_20261021 y BattleCameraController_BeforeMobileShoulder_20261021.
El 26/10 se verificaron atributos y paridad de MobileControls/BattleCameraController/
GrabController; no se repitió input ni se probó teléfono físico.

## 0.2 Accesos del HUD editables en StarterGui — 2026-10-14

**Aplicado en Lobby `125075465377023` y Match `108298899371591`, sin publicar.**
Detener Play y seleccionar las siguientes instancias en Explorer. Los
controladores enlazan estas plantillas; ya no reconstruyen los cuatro accesos.

| Control | Instancia permanente | Place | Controlador en StarterPlayerScripts |
|---|---|---|---|
| MOCHILA [B] | `StarterGui.ZB_EquipmentDashboard.OpenInventory` | Ambos | `EquipmentDashboard` |
| TAB: VER CONGELAMIENTOS | `StarterGui.ZB_BattleScoreboard.ScoreAccess` | Ambos | `BattleScoreboard` |
| ALT: LIBERAR CURSOR · B: MOCHILA | `StarterGui.ZB_BattleCursor.CursorAction` | Ambos | `BattleCameraController` |
| SALIR DE LA BATALLA [X] | `StarterGui.ZB_BattleExit.LeaveButton` | Lobby | `BattleFormatController.client` |
| VOLVER AL LOBBY [L] | `StarterGui.ZB_ReturnToLobby.ReturnButton` | Match | `ReturnToLobbyController.client` |

### Qué editar en Properties

- **Texto, fuente y color:** `Text`, `TextSize`, `FontFace`, `TextColor3` del botón.
- **Posición/tamaño de escritorio:** `Position`, `AnchorPoint`, `Size` del botón.
- **Padding interior:** hijo `ContentPadding` (`UIPadding`), propiedades
  `PaddingLeft`, `PaddingRight`, `PaddingTop`, `PaddingBottom`.
- **Texto cuando el cursor está libre:** atributo `FreeCursorText` de `CursorAction`.
  Su `Text` define el mensaje al apuntar; el controlador alterna ambos mensajes.
- **Icono de mochila:** `OpenInventory.ZBAtlas_bag.Image`. Vacío sigue la plantilla
  compartida `ReplicatedStorage.UIAssets.Icons.bag`; una imagen local tiene prioridad.
- **Arte del fondo compartido:** `ReplicatedStorage.UIAssets.Skins.button_cyan_<estado>`.
  El atributo `UIFrameSkin=button` enlaza ese arte. El fondo nativo se edita en el
  botón y su `UICorner`; se usa también como respaldo si la imagen no carga.

Valores iniciales: mochila **200×52**, tabla/cursor **300×48**, salida/retorno
**260×48**; padding **16 px horizontal / 8 px vertical**. La mochila reserva
**52 px a la izquierda** para el icono. Margen derecho **32 px**, margen inferior
**32 px** y separación **16 px** entre los tres accesos inferiores.
`UIFrameSkins` compensa el padding al colocar el arte: el fondo cubre el botón
completo, mientras el texto conserva su espacio interior.

### Configuración móvil desde StarterGui

En `StarterGui.ZB_EquipmentDashboard`, editar estos **Attributes** en ambos Places:

| Atributo | Inicial | Efecto |
|---|---|---|
| `MobileButtonSize` | 52 | Diámetro de mochila, tabla y salida/retorno |
| `MobileEdgeMargin` | 20 | Margen derecho de esos accesos |
| `MobileGap` | 16 | Separación horizontal entre ellos |
| `MobileNavY` | 16 (ajuste 21/10) | Posición vertical del grupo durante batalla |

`Shared.MobileHudLayout` adapta los accesos a círculos en dispositivos táctiles;
reinicia el padding rectangular de la copia y coloca iconos/leyendas. Los cambios
de `Position`/`Size` del botón son para escritorio; en móvil usar estos atributos.
La visibilidad depende de batalla y menús. Los cuatro ScreenGui usan
`ResetOnSpawn=false` y `DeviceSafeInsets`. No renombrar los ScreenGui ni los botones.

**Retirada aplicada:** `HudController.client` ya no crea `RoundOptions`,
`OptOutButton`, `Check` ni `OptOutLabel`, ni conecta la opción «No entrar a la
próxima batalla». También se retiró su tratamiento de AtlasUIController y
MobileHudLayout. Los servicios/remotes históricos del servidor no se modificaron.

**Verificación:** una copia de cada acceso en PlayerGui, ausencia de RoundOptions,
fondos de tamaño completo y textos que caben. Capturas de escritorio **1211×593**
y iPhone 17 Pro horizontal **750×381** en ambos Places. Atajos B, Tab y Alt
comprobados en Lobby con fixture visual de batalla local; sin invocar la salida.
La revisión de Match usó un fixture visual local porque Play aislado rechaza
TeleportData e intenta retornar con un error HTTP preexistente. No certifica
teleports ni touch físico. En vertical **401×778** sigue el aviso existente de
girar el dispositivo; no se certifica gameplay vertical.
Ambos Studios quedaron en Edit y con viewport predeterminado.

Respaldo de los seis controladores por Place y MobileHudLayout:
`ServerStorage.ZB_HudEditableBackup_20261014`; los controladores incluyen
`OriginalPath`. No activar las copias como interfaces adicionales.

## 0.3 Monedas: dispersión y vuelo al contador — 2026-10-14

**Implementado en ambos Places, sin publicar.** El contador ahora permanece
visible también en batalla y tiene plantilla permanente:

```text
StarterGui.ZB_CoinFeedback (ScreenGui, ResetOnSpawn=false, DeviceSafeInsets)
├─ CoinsLabel (TextLabel: total actualizado por HudController)
│  └─ Icon (ImageLabel: UIAssetKey=coin)
│     └─ FeedbackScale (UIScale: pulso al llegar las monedas)
├─ SpriteTemplate (ImageLabel oculto, plantilla de moneda 24×24)
└─ Bursts (Frame transparente: sprites temporales durante Play)
```

| Cambio visual | Dónde editar |
|---|---|
| Fuente/color/posición/tamaño del total desktop | `StarterGui.ZB_CoinFeedback.CoinsLabel` |
| Icono destino | `CoinsLabel.Icon.Image`; vacío usa `UIAssets.Icons.coin` |
| Imagen/tamaño de las monedas animadas | `ZB_CoinFeedback.SpriteTemplate.Image` / `Size`; vacío usa `UIAssets.Icons.coin` |
| Número visual de monedas | Attribute `CoinsPerBurst` del ScreenGui: 9 |
| Límite simultáneo | Attribute `MaxActiveCoins`: 36 |
| Radio alrededor del personaje | Attribute `SpreadRadius`: 3.5 studs, proyectados a pantalla |
| Duración de dispersión | Attribute `SpreadDuration`: 0.22 s |
| Duración del vuelo | Attribute `FlightDuration`: 0.65 s |
| Escalonado entre monedas | Attribute `Stagger`: 0.035 s |

La dispersión utiliza sprites 2D proyectados alrededor del personaje. TweenService
los dispersa, luego los dirige por una curva al centro del icono del contador;
al llegar se encogen/desvanecen y el icono hace un pulso. No son pickups físicos.
El número de sprites no representa una cantidad de recompensa. El total muestra
monedas reales replicadas; la animación no paga ni modifica el saldo.

En móvil, `Shared.MobileHudLayout` coloca el contador arriba a la izquierda
(42,64; 132×20, TextSize=12), dejando libres los accesos de batalla. Posición y
tamaño desktop del contador no sustituyen esta adaptación móvil.

**Conexión:** `ServerScriptService.BattleStats.recordFullFreeze` emite
`ReplicatedStorage.RemoteEvents.FreezeCoinFeedback` solamente para el atacante
al acreditar el congelamiento completo de un jugador de la misma batalla.
`StarterPlayer.StarterPlayerScripts.CoinFeedbackController` consume el evento;
`ReplicatedStorage.Shared.CoinBurstEffect` implementa los tweens. El cliente
ignora secuencias repetidas/antiguas del encuentro y eventos de otra partida;
menús/tabla abierta no reproducen el burst. Salida, retirada de personaje o
cambio de viewport limpian las monedas. No se dispara por cobrar misiones o
recoger monedas normales. Los premios/economía existentes no se cambiaron.

**QA controlada Studio:** cuatro acreditaciones con objetivo simulado por Place,
sprites observados en desktop y móvil horizontal; saldo 500 intacto; autoimpacto
rechazado. Final: cero sprites y escala del icono 1. En Lobby, seis bursts rápidos
alcanzaron 36 sprites como máximo; los dos siguientes crearon cero, cancelar dejó
cero y las tareas diferidas no recrearon sprites. Tres fuentes nuevas/modificadas
CoinBurstEffect, CoinFeedbackController y BattleStats tienen bytes/hash iguales
entre Places. Sin errores nuevos de esos scripts; fixtures retirados y simuladores
default. Falta congelamiento real publicado con dos cuentas y touch físico.

**Reversión:** fuentes previas de HudController, AtlasUIController,
MobileHudLayout y BattleStats en `ServerStorage.ZB_VisualFeedbackBackup_20261014`
con `OriginalPath`. Restaurarlas y retirar ZB_CoinFeedback, CoinFeedbackController,
CoinBurstEffect y FreezeCoinFeedback para quitar esta integración completa.

## 0.4 Imágenes propias de las tres armas — 2026-10-14

**Plantillas aplicadas en Lobby y Match el 14/10. Imágenes reales cargadas en
Lobby el 16/10; Match pendiente porque su Studio no estaba conectado.**
Las tarjetas de armas de mochila/tienda ya no
insertan iconos genéricos weapon/rifle/cannon. Reservan un recuadro de **96×102**
unidades UI y usan una plantilla ImageLabel diferente por ID:

| Arma / modelo | Instancia permanente | Image en Lobby | Archivo en assets/ui |
|---|---|---|---|
| SDR-Mk2 | `ReplicatedStorage.UIAssets.WeaponImages.blaster` | `rbxassetid://73825106772191` | `weapon_blaster.png` |
| Rifle / SM_Wep_SMG_01 | `ReplicatedStorage.UIAssets.WeaponImages.rifle` | `rbxassetid://74291139533144` | `weapon_rifle.png` |
| Cañón / SM_Wep_Laser_Gun_01 | `ReplicatedStorage.UIAssets.WeaponImages.cannon` | `rbxassetid://131349817623777` | `weapon_cannon.png` |

Detener Play, seleccionar la instancia y asignar una imagen importada o su
`rbxassetid://ID` en Properties. Repetir el mismo ID en ambos Places. Usar PNG
RGBA con la silueta completa del arma y margen. Los PNG actuales son **512×512**
con `ScaleType=Fit` e ImageRectOffset/ImageRectSize en cero. La fuente entregada
`assets/Íconos de armas futuristas en neón.png` mide realmente **2172×724**;
se separaron tres cuadros de 724×724, de izquierda a derecha blaster/rifle/cannon,
y se retiró el mate rojo exterior de los derivados, conservando el original.
Proceso reproducible en `assets/ui/prepare_weapon_images.py`; recortes/IDs en
[weapon_images_manifest.json](assets/ui/weapon_images_manifest.json).

Mientras `Image` esté vacío, el hijo `ZBAtlas_ImagePlaceholder` muestra **IMAGEN
DEL ARMA**. Se oculta al asignar Image a la copia del recuadro. No hay fallback
al icono SVG/genérico. Fondo, UICorner/UIStroke e imagen se editan en estas
plantillas; el texto de la tarjeta queda a partir de x=128 y conserva espacio
separado para nombre, estadísticas y acción.

`EquipmentDashboard` clona la plantilla por `WeaponPreviewId`, tanto en compra
como en equipado; `AtlasUIController` respeta ese layout. Las tarjetas siguen
siendo dinámicas: no editar `PlayerGui...Panel.Cards.CardN` para cambios permanentes.
Las copias toman propiedades al crearse; tras editar la fuente iniciar Play nuevo
o regenerar las tarjetas. Cambiar una imagen no cambia el modelo 3D del arma.

QA de las plantillas del 14/10: tres espacios sin iconos genéricos; textos que caben en desktop y iPhone 17
Pro horizontal **750×381** en ambos Places. Imagen temporal de prueba ocultó el
marcador y se retiró. Las tres armas se mostraron mediante snapshot visual de
inventario de QA; eso no concedió propiedad ni cobró monedas. En móvil la segunda
fila se consulta con scroll. Sin errores nuevos; ambos Studios en Edit/default.
Respaldo de los dos controladores y modelos previos al ajuste de presentación:
`ServerStorage.ZB_WeaponPresentationBackup_20261014`. Sin publicar.

## 0.5 Vitrinas físicas de armas y acceso compartido — Lobby, 2026-10-16

En `Workspace.WeaponDisplays` hay tres Models, clonando el contenedor de
`Workspace.basegancho1` y sustituyendo su gancho por el arma de exhibición:

| Modelo | WeaponId | Posición del pedestal |
|---|---|---|
| `basearma1` | `blaster` | (-110, 1.4504, -20) |
| `basearma2` | `rifle` | (-70, 1.4504, -20) |
| `basearma3` | `cannon` | (-30, 1.4504, -20) |

Cada modelo contiene:

```text
basearmaN
├─ Base (PrimaryPart; pedestal original)
│  ├─ Chamber (vidrio original)
│  └─ Rim (aro original)
├─ Weapon (clon de la plantilla; solo exhibición)
└─ OfferPlate
   ├─ WeaponOfferSign (SurfaceGui)
   │  ├─ WeaponImage
   │  ├─ Title
   │  └─ Access
   └─ WeaponOfferPrompt (ProximityPrompt, E: Ver arma)
```

Mover **el Model completo** para conservar juntos pedestal, vidrio, arma, cartel
y prompt. Los tres contenedores conservan la geometría del original; los originales
basegancho1/2/3 siguen intactos. Todas las piezas de los nuevos exhibidores están
ancladas; sus armas no tienen colisión ni se conceden por tocarlas. Los previews
se ajustaron a un tamaño máximo de 12 studs y centraron dentro del vidrio.
No son las plantillas de equipado: modificar aquí la escala no cambia el arma en mano.

**Edición visual:** textos en `OfferPlate.WeaponOfferSign.Title/Access`; imagen
del cartel en `WeaponImage.Image`. Su imagen inicial copia `UIAssets.WeaponImages`;
si se sustituye después, actualizar también el cartel. El prompt se edita en
`OfferPlate.WeaponOfferPrompt`. El arma base indica GRATIS PARA TODOS; las otras
indican PASE · PRÓXIMAMENTE.

**Acceso común:** `StarterPlayerScripts.WeaponDisplayController` escucha los
prompts del showroom y dispara el BindableEvent
`StarterGui.ZB_EquipmentDashboard.OpenWeaponOffer` en su copia PlayerGui.
EquipmentDashboard abre TIENDA / ARMAS, resalta la ficha y hace scroll hacia ella.
Es la misma tarjeta de la tienda, no otra ruta de cobro. Este evento es local,
solo abre UI y no concede saldo/propiedad. Su ausencia no bloquea el dashboard.

**Pases:** `ReplicatedStorage.WeaponOffers.blaster/rifle/cannon` son Configurations
con WeaponId, DisplayName, SaleMode, PassId, PassPriceRobux y PurchaseIntegrationReady.
blaster usa SaleMode=Free; rifle/cannon usan GamePass.

| Offer | SaleMode | PassId | Ready | Estado |
|---|---|---|---|---|
| `blaster` | Free | — | — | Gratis para todos |
| `rifle` | GamePass | 0 | false | Pase próximamente; sin compra con monedas |
| `cannon` | GamePass | 2039918698 | true | **Conectado**: pase de 10 R$ |

**Cañón conectado al pase (2026-10-16):** se compra **solo** con el pase; ya no se
compra con 250 monedas. Quienes ya lo poseían lo conservan y lo equipan gratis.

- `ServerScriptService.MonetizationService` (Lobby): al entrar consulta
  `UserOwnsGamePassAsync` por cada pass configurado y concede el arma con
  `_G.ZB.Workshop.grantWeapon` (sin cobrar monedas), registra el derecho en
  `profile.passes` y guarda. También escucha `PromptGamePassPurchaseFinished`
  para conceder tras una compra confirmada. El cliente **nunca** declara propiedad.
- `WorkshopService.grantWeapon/ownsWeapon` conceden/consultan propiedad; el
  `WorkshopBuy` de armas rechaza comprar con monedas un arma de pase que no se posee.
- `DataService` (Lobby y Match) guarda y conserva `profile.passes` para no perder
  el derecho al viajar. Match no tiene MonetizationService (no vende); refleja la
  posesión por el perfil ya persistido.
- Cliente `EquipmentDashboard`: si el arma es de pase, no poseída y Ready, muestra
  **DESBLOQUEAR · N R$** (precio real con `GetProductInfo`, respeta precios
  regionales) y al pulsar abre `PromptGamePassPurchase`. Sin PassId válido muestra
  PASE PRÓXIMAMENTE.

Rifle sigue con PassId=0 (PASE PRÓXIMAMENTE) hasta tener su pase. Cambiar
`rifle.PassId` + `PurchaseIntegrationReady=true` con un ID válido activa el mismo
flujo sin tocar código. No se modificó la economía de monedas de otras categorías.

**Cartel propio de cada vitrina (16/10):** el texto de la vitrina
(`OfferPlate.WeaponOfferSign.Access`) es **compartido** y no cambia por jugador;
decía "PASE · PRÓXIMAMENTE" a todos, incluso a quien ya tenía el Cañón. Ahora
`StarterPlayerScripts.WeaponDisplayController` crea un **BillboardGui local**
(`ZB_StandState`, 280×42, con fondo/UIStroke y `AlwaysOnTop=true` para que no lo
tape el pedestal, `MaxDistance=140`) sobre cada vitrina que muestra, **solo al
cliente**, el estado real: `LA TENÉS · EQUIPÁ` (posee), `DESBLOQUEAR · N R$` (pase
listo, precio real), `PASE · PRÓXIMAMENTE` (sin ID) o `GRATIS PARA TODOS`. Se
actualiza con `InventoryState`. Resuelve la contradicción "lo tengo en la mochila
pero la vitrina me lo ofrece". El Sign compartido queda como referencia estática;
el estado fiable es el Billboard del cliente. Nota: si el modelo aún no replicó su
`Base`, se espera con `WaitForChild('Base',5)` antes de crear el cartel (si no, no
se creaba por replicación tardía).

**"Ya tienes este objeto" al comprar:** si al pulsar DESBLOQUEAR Roblox responde
que ya se posee, la cuenta **ya tiene el pase**. Eso es esperado: no se puede
recomprar. Para probar la compra real hace falta una **cuenta que no posea el
pase**. `AutoGrantPasses=true` (valor de producción) hace que los dueños del pase
reciban el arma al entrar (ven LA TENÉS); el creador del pase siempre lo posee.

**Interruptor `AutoGrantPasses`:** `ReplicatedStorage.Monetization.AutoGrantPasses`
(BoolValue, **true en Lobby al inspeccionar el 26/10**) controla si `MonetizationService` concede el arma del
pase al entrar. En `false` no concede al entrar (para probar la compra); la compra
confirmada sigue concediendo. Ausente = `true`. **Subirlo a `true` antes de lanzar**
para que los dueños del pase recuperen el arma al reentrar.

> **Causa del reporte "todos tienen el Cañón":** la API de Roblox devolvió
> `UserOwnsGamePassAsync` **true para la cuenta creadora** del pase y **false** para
> otras (userId 1 y 156). Como el dueño del pase recibe el arma al entrar, y en
> Studio *multijugador* todos los jugadores son la misma cuenta, "todos" aparecían
> con el Cañón. Con `AutoGrantPasses=false` y el reset, los testers ven DESBLOQUEAR.
> Una cuenta que ya posee el pase no puede recomprarlo: para probar la compra real
> usar una cuenta sin el pase.

**Reset pre-lanzamiento del Cañón (16/10):** como el juego aún no es público y los
que tenían el Cañón son testers, `ServerScriptService.WeaponPassReset` (módulo en
ambos Places) quita **una vez** el Cañón de `workshop.ownedWeapons`, restaura el
equipado a `blaster` si hacía falta y limpia el registro `passes`, para que los
testers sin el pase vean **DESBLOQUEAR** y puedan probar la compra. Es idempotente
por perfil: guarda `migrations.weaponPassReset = VERSION`; para volver a ejecutarlo
se sube `WeaponPassReset.VERSION` y se republica. No afecta armas fuera de su lista
(p. ej. `rifle`). DataService lo aplica al normalizar el perfil en Lobby y Match.

**Caveat de prueba:** si la cuenta **ya posee el pase**, `MonetizationService` vuelve
a conceder el Cañón al entrar (comportamiento correcto); esa cuenta verá EQUIPAR y
no podrá comprar de nuevo. Para probar la compra real hay que usar una cuenta que
**no** posea el pase (y, en Studio, la compra externa consume Robux reales; conviene
probar en la experiencia publicada con una cuenta tester sin el pase).

**QA del pase del Cañón (16/10, Studio):** el pase 2039918698 ("cañon", 10 R$) está
a la venta. Con el pase poseído, `MonetizationService` concedió `cannon`
(`ownedWeapons=blaster,cannon`, `passes={"2039918698":true}`); la tarjeta mostró
EQUIPAR y el arma se equipó con 500 monedas intactas. Con el pase **no** poseído
(servicio desactivado solo para observar), la tarjeta mostró **DESBLOQUEAR · 10 R$**.
Intento de comprar el Rifle (de pase, sin ID) con monedas fue rechazado:
"Este arma se desbloquea con su pase; no se compra con monedas.", sin cobrar. No se
pudo probar la compra real con Robux ni un jugador distinto sin el pase dentro de
Studio; el prompt oficial quedó conectado. Sin errores de scripts; avisos
CorePackages del entorno. MonetizationService reactivado y fixtures retirados.
Respaldo Lobby: `ServerStorage.ZB_CannonPassBackup_20261016`.

**QA del 16/10:** 3/3 imágenes con AssetFetchStatus.Success; capturas de vitrinas
y tienda. E real en las tres vitrinas abrió su ficha correcta. Click en tarjeta
pendiente mantuvo 500 monedas y blaster equipado. Respawn: una GUI de equipo,
tres vitrinas, tres prompts y 38/38 piezas ancladas. Simulador iPhone 17 Pro,
750×381: la ficha de Cañón se enfoca y desplaza correctamente tras respawn; input
de prueba por teclado, no touch físico. Sin errores nuevos de los scripts del
proyecto; avisos FoundationProvider proceden de CorePackages. Fuentes de los tres
ganchos comparadas con respaldo y conservadas. Studio en Edit/default; servidor
HTTP local de subida cerrado. Sin publicar el Place.

**Respaldo Lobby:** `ServerStorage.ZB_WeaponShowroomBackup_20261016`, con imágenes,
EquipmentDashboard y plantilla StarterGui anteriores; `OriginalHookStands` conserva
las tres fuentes. Reversión: restaurar por OriginalPath y retirar WeaponDisplays,
WeaponOffers y WeaponDisplayController. No insertar OriginalHookStands en Workspace
además de los originales existentes.

**Match pendiente:** copiar/reemplazar UIAssets.WeaponImages con los mismos tres
IDs, WeaponOffers y EquipmentDashboard; conservar/añadir OpenWeaponOffer en su
plantilla para paridad. El handler visual está limitado a Lobby. Las vitrinas y
WeaponDisplayController son decoración/acceso del Lobby y no necesitan copiarse
a la arena Match. Probar mochila/carga de imágenes y equipado al sincronizar.

## 0.6 Cuerda genérica con volumen — Lobby y Match, 2026-10-16

**Implementado en ambos Places, sin publicar. Alcance confirmado por el usuario:
solo personalización estética del sistema actual.** Se creó una única apariencia
genérica. La cuerda de Navidad era un ejemplo de una posible actualización futura;
no se creó una skin navideña, usos, caducidad ni otro sistema de consumibles.

```text
ReplicatedStorage.HookCosmeticAssets.RopeSkins
└─ Generic (Model)
   ├─ Core (Part Cylinder, Material Fabric)
   └─ Decorations
      └─ Rib (Part Cylinder, refuerzo del cable)
```

| Qué modificar | Instancia / propiedad |
|---|---|
| Grosor del cable | `Generic.Core.Size.Y` y `.Z` (inicial 0.18, mantener iguales para sección circular) |
| Color/material del cuerpo | `Generic.Core.Color` / `.Material` |
| Forma/color del refuerzo | `Generic.Decorations.Rib`, Size / Color / Material |
| Separación de refuerzos | Attribute `Generic.Spacing` (2.5 studs) |
| Cantidad máxima de refuerzos | Attribute `Generic.MaxDecorations` (24) |
| Mezcla con el color equipado | Attributes CoreTintStrength=0.10 / DecorationTintStrength=0.35 |
| Límite de cables visibles | Attribute `RopeSkins.MaxRenderedRopes` (12; máximo 6 táctil) |
| Distancia de visibilidad | MaxViewDistance=350 / DecorationViewDistance=180 |

La longitud del Core se adapta al gancho; su Size.X es solo una referencia de
edición. El eje local X corre a lo largo del cable. Los adornos se definen con
CFrame relativo al Core y se repiten entre extremos. Editar las plantillas en
Edit, repetir los cambios en ambos Places y relanzar el gancho/iniciar Play para
obtener copias nuevas. No editar `Workspace.ZB_HookRopeCosmetics` para guardar arte.

**Render:** `StarterPlayer.StarterPlayerScripts.HookRopeRenderer` lee los dos
Attachments del Beam `ZB_HookRope` ya replicado. Oculta ese Beam solo en el cliente
y dibuja un cilindro 3D opaco con refuerzos, anclado y sin colisión/touch/query.
No es RopeConstraint, no mueve al jugador ni modifica fuerzas, energía, alcance,
raycast, compras o datos. HookController.client y HookVisualService.server se
compararon contra el respaldo y están intactos. El Beam anterior sigue siendo
el fallback si se retira el renderizador y se reinicia Play.

El render usa un Model que coincida con HookRopeCosmeticId si existe y, en caso
contrario, Generic. Hoy solo existe Generic: las entradas de color/grosor ya
presentes en Config usan esta misma geometría. No se registraron artículos nuevos
ni se cambiaron precios o propiedad. Modelos específicos para futuros cosméticos
se conectarán al catálogo autorizado existente cuando haya arte y contenido.

Límites para Generic: hasta 24 refuerzos más Core por cable en desktop, 12 más
Core en táctil; prioridad al cable propio y ocultación de geometría lejana.
Son límites de instancias/dibujo, no una medición de FPS.

**QA Studio:** horizontal de 18 studs y vertical de 26 correctos; eje de cilindro
alineado, longitud actualizada, Beam plano oculto. A 150 studs, 25 piezas como
máximo; extremos coincidentes ocultan todo y destruir el marcador deja cero cables.
En Lobby, entrada real a Libre e intención de gancho controlada por el bus actual:
Hooking=true, un cable del dueño de 198.54 studs, fuerza existente aplicada y energía
100→88.40; soltar dejó Hooking=false y cero cables. Para esa medición se desactivaron
cámara/MobileControls solo en runtime. El intento de teclado Q no fue concluyente.
Match: marcador de prueba de 16 studs, un cable de siete piezas y limpieza completa;
no simula un VS válido. Renderer idéntico: 7973 bytes / hash base31 `1816714824`.
Fuerza base 1000, velocidad máxima 70 y alcance 250 conservados. Sin errores nuevos
del renderer; avisos CorePackages y rechazo de TeleportData de Match son del entorno.
Fixtures retirados y ambos Places en Edit. Falta observador remoto/touch real/FPS.

**Reversión:** retirar HookRopeRenderer y RopeSkins con Play detenido, reiniciar
para recuperar el Beam anterior. `ServerStorage.ZB_GenericHookRopeBackup_20261016`
de cada Place conserva las fuentes originales sin modificar como evidencia.
No hace falta restaurar datos, inventario ni configuración de movimiento.

## 0.7 Estados de color del calendario — 2026-10-16

**Aplicado en Lobby (calendario) y con datos guardados también desde Match, sin
publicar.** Cada fecha de `StarterGui.ZB_DailyActivities` se pinta por su estado.
Colores editables como **Attributes** del ScreenGui (valores iniciales RGB):

| Attribute | Estado | Color inicial | Etiqueta |
|---|---|---|---|
| `ClaimedDayColor` | Cobrado (verde) | 22,85,53 | ✓ |
| `MissedDayColor` | Día pasado sin cobrar (rojo) | 92,33,43 | SIN COBRO |
| `AvailableDayColor` | Disponible hoy (ámbar) | 112,78,24 | COBRAR |
| `FutureDayColor` | Futuro (neutro) | 17,29,46 | (vacío) |
| `UnknownDayColor` | Sin datos (gris) | 26,35,48 | SIN DATOS |

Hoy conserva su borde cian y la selección dorado; `IsToday`, `ConfirmedClaim` y
`ClaimState` (claimed/missed/available/future/unknown) quedan como atributos de
cada `Calendar.Grid.SlotNN` para inspección. La leyenda del calendario explica
los colores; su texto se edita en `Content.Calendar.Legend.Text`.

**Historial:** antes solo se guardaba el último cobro. Ahora `daily` incluye
`claimedDays` (mapa fecha→importe), `historyStartDay` y `historyVersion=1`.
El nuevo ModuleScript de servidor `ServerScriptService.DailyClaimHistory`
normaliza y registra esas fechas; `DailyRewardService.server` acredita saldo y
fecha en la **misma** mutación de perfil, y `DataService.server` (Lobby y Match)
las conserva al cargar, capturar y guardar.

**Límite honesto:** los días anteriores a que cada jugador empezara este registro
quedan como `SIN DATOS` (gris); **no se pintan de rojo** porque no hay forma
fiable de saber si se reclamaron. El perfil antiguo solo migra su último cobro
confirmado. Desde que el registro empieza, cada día pasado sin cobrar sí queda rojo.

QA (con reloj de prueba en memoria, no la medianoche real): migración de perfil
antiguo `lastClaimDay=base-2,streak=2` conservó ese cobro; dos cobros de UI
(base y base+2) dieron saldo 500→550→600; el día intermedio base+1 quedó **missed**
en rojo; hoy disponible en ámbar; futuros neutros; tres solicitudes repetidas no
pagaron dos veces; captura/guardado preservó 3 fechas, el hueco y el saldo 600.
Smoke test con reloj real: hoy `available`, 18 días previos `unknown`, 23 futuros.
Avisos CorePackages y rechazo de TeleportData de Match son del entorno, no del código.
Sin fixtures; ambos Places en Edit. Respaldo `ServerStorage.ZB_DailyHistoryBackup_20261016`.
Falta validación publicada de medianoche/reconexión y el gasto real del cobro.

## 0.8 Láser rojo y aviso de protección — 19/10, contrato contrastado 26/10

Aplicados en Lobby y Match, sin publicar desde esta sesión.

| Recurso | Archivo preparado | Roblox ID | Fuente editable en Studio |
|---|---|---|---|
| Láser rojo | `assets/ui/laser_red.png`, RGBA 512×512 | `71886236630717` | `ReplicatedStorage.UIAssets.LaserImages.red.Image` |
| Protegido / disparar cancela el escudo | `assets/ui/spawn_protection.png`, RGBA 1536×249 | `116492173393960` | `StarterGui.ZB_SpawnProtection.Notice.Banner.Image` |

Fuentes originales: `assets/Láserrojo.png` y `assets/ui protegido.png`.
`prepare_extra_ui_images.py` elimina el exterior sobrante del marco rojo sin
recortar el rayo, y recorta el margen transparente del aviso conservando el brillo.
Manifiesto en `extra_ui_images_manifest.json`; IDs en `laser_asset_ids.json`
(ahora cinco colores) y `status_asset_ids.json`.

- Rojo usa la misma tarjeta de tienda/mochila que los demás láseres; no cambia
  coste, propiedad ni comportamiento del rayo. Carga real en tarjeta comprobada.
- `ZB_SpawnProtection` es una plantilla persistente de StarterGui. `Notice`
  contiene `Banner`, `Timer` y texto `Fallback`. Reemplazar el PNG en Banner.Image,
  sin editar código ni reutilizar el fondo 9-slice de un botón.
- `SpawnProtectionController` usa `SpawnProtectionEndsAt` y `PowerUpShieldEndsAt` del servidor y
  `BattleParticipant`; oculta al quedar el plazo en cero o expirar, al salir,
  eliminarse, cambiar personaje o abrir menús. El HUD omite temporalmente su
  MatchStatus para que no se superponga. La cuenta atrás se actualiza a 10 Hz.
- **Aparición y azul:** la imagen base indica que disparar cancela aparición;
  `Banner.PowerUpMessage` presenta ESCUDO ACTIVO para el azul y evita esa indicación
  incorrecta. El azul tiene prioridad si ambos plazos están activos; `Notice`
  expone ProtectionType=PowerUp/Spawn. Instalar UI no concede protección: el azul
  depende de PowerUpShield.grant y su duración de cinco segundos.
- En Lobby, FreeSpawnTransitionController conserva únicamente la confirmación
  del traslado del personaje. Ya no crea el antiguo TextLabel/ScreenGui en runtime.
- Attributes de `ZB_SpawnProtection`: `DesktopWidth=620`, `MobileWidth=520`,
  `MobileTop=0`, `ImageAspectRatio=1536/249`. ScreenInsets=DeviceSafeInsets,
  ScaleType=Fit; banner aproximado 620×100 en escritorio y 520×84 en iPhone.
- Mantener ImageTransparency=0 también durante la carga. El fallback se dibuja
  encima hasta IsLoaded; esconder la imagen por transparencia impedía completar
  IsLoaded en la primera prueba. Precarga asíncrona sin bloquear UI/combate.

**QA:** aviso visible tras entrada real Libre (4.8 s restantes); pruebas de
presentación controladas con plazo cero, expiración y menú pasan. Ambos recursos
cargan con Success; captura móvil del rojo en tienda y del aviso, captura de
escritorio en Match mediante atributos locales de QA. Los plazos largos de esas
capturas son fixtures visuales locales, no un aumento de la duración del escudo.
Un intento de disparo mediante intención programada no confirmó cancelación de
servidor; esa aceptación con disparo manual y jugador remoto sigue pendiente.
Reglas de daño/duración/cancelación del servidor conservadas sin cambios.

Respaldo: `ServerStorage.ZB_RedLaserProtectionUIBackup_20261019` por Place. Para
revertir el aviso, detener Play, restaurar fuentes respaldadas y retirar la nueva
plantilla/SpawnProtectionController. El controlador antiguo del Lobby vuelve a
crear su aviso; no dejar ambos constructores activos. Ambos Places quedaron en
Edit y el simulador usado se restableció al viewport default.

## 1. «Cambiá la mochila por un bolso»

1. Detener Play.
2. Abrir **Explorer → ReplicatedStorage → UIAssets → Icons → bag**.
3. Seleccionar **bag**, que es un **ImageLabel** real.
4. En **Properties → Image**, elegir la nueva imagen importada o pegar su
   `rbxassetid://ID_REAL`. Dejar **ScaleType = Fit**.
5. Hacer lo mismo en el otro Place, o copiar la instancia `bag` sustituyendo
   la anterior **sin dejar dos objetos con el mismo nombre**.
6. Iniciar Play nuevo. El botón de mochila y el icono compartido del manual usan
   esa imagen; el dibujo alternativo se oculta automáticamente.

**Para volver al icono de trazos:** vaciar `Image`. No borrar la carpeta `Fallback`.
Un ID que no carga no activa automáticamente el fallback: vaciarlo explícitamente.

| Dato | Valor exacto |
|---|---|
| Objeto permanente que editar | `game.ReplicatedStorage.UIAssets.Icons.bag` |
| Clase / propiedad | `ImageLabel.Image` |
| Nombre que debe conservar | `bag` |
| Archivo de entrega | `ui_bag.png`, incluso si el nuevo dibujo es un bolso |
| Ruta local | `C:\Users\Usuario\Desktop\experiencias\mcp\docs\assets\ui\ui_bag.png` |
| Exportación | **256×256 px**, PNG RGBA, fondo transparente |
| Margen | 32 px por lado; dibujo dentro del centro de 192×192 |
| Caja visible | 32×32 unidades UI antes de escalado |
| Botón durante Play | `Players.<jugador>.PlayerGui.ZB_EquipmentDashboard.OpenInventory.ZBAtlas_bag` |
| Icono del manual en Studio | `game.StarterGui.ZB_Intro.Instructions.Rows.Row08.Icon` |

**Estado actual:** `bag.Image` usa `rbxassetid://105198427655513`, procedente del atlas
de iconos del 13/10. `bag.Fallback` conserva los Frames originales para carga fallida
o Image vacío. `docs/assets/ui/ui_bag.png` es el recorte local de entrega; Roblox
no carga automáticamente esa carpeta.

### Si todavía no está importado el PNG

1. Exportar el archivo en la ruta anterior.
2. Importarlo desde **Asset Manager / Administrador de recursos** de Studio o
   Creator Dashboard, como imagen y bajo el propietario correcto de la experiencia.
3. Esperar la subida/moderación y copiar el ID del recurso de **imagen**, no un
   ID de Model, Place, pase o miniatura web.
4. Asignarlo a `Image` en Properties. Reutilizar el mismo ID en ambos Places.

Guardar un PNG en Windows no cambia el juego. No editar la copia bajo PlayerGui
para cambios permanentes. Reiniciar Play tras modificar una plantilla; las copias
ya creadas no se sincronizan automáticamente. Publicar ambos Places cuando se
quiera desplegar; editar en Studio no publica.

## 2. Estructura clásica del manual (fallback, no arte visible actual)

En FullArtIntro=true se muestran Artwork y Continue (ImageButton); los textos
Logo/Title/Subtitle/Rows de abajo quedan ocultos. Este árbol y sus instrucciones
de Text corresponden al fallback clásico. Para la presentación actual usar 0.9.

```text
StarterGui
└─ ZB_Intro (ScreenGui)
   ├─ Backdrop (TextButton)
   └─ Instructions (Frame)
      ├─ UICorner
      ├─ UIStroke
      ├─ ResponsiveScale (UIScale)
      ├─ Logo (ImageLabel)
      ├─ Title (TextLabel)
      ├─ Subtitle (TextLabel)
      ├─ Rows (Frame)
      │  ├─ Row01 (Frame)
      │  │  ├─ Icon (ImageLabel)
      │  │  ├─ Control (TextLabel)
      │  │  └─ Description (TextLabel)
      │  └─ Row02 … Row08, con los mismos tres hijos
      └─ Continue (TextButton)
         ├─ UICorner
         └─ UIStroke
```

| Quiero cambiar… | Seleccionar en Explorer | Propiedad |
|---|---|---|
| Título | `StarterGui.ZB_Intro.Instructions.Title` | `Text`, `TextColor3`, `FontFace` |
| Subtítulo | `StarterGui.ZB_Intro.Instructions.Subtitle` | `Text` |
| Explicación del gancho | `StarterGui.ZB_Intro.Instructions.Rows.Row04.Description` | `Text` |
| Texto de controles B/X/Tab/Alt | `StarterGui.ZB_Intro.Instructions.Rows.Row08.Control` | `Text` |
| Texto del botón | `StarterGui.ZB_Intro.Instructions.Continue` | `Text` |
| Fondo | `StarterGui.ZB_Intro.Instructions` | `BackgroundColor3`, `BackgroundTransparency` |
| Esquinas | `StarterGui.ZB_Intro.Instructions.UICorner` | `CornerRadius` |
| Borde | `StarterGui.ZB_Intro.Instructions.UIStroke` | `Color`, `Thickness`, `Transparency` |
| Logo solo en el manual | `StarterGui.ZB_Intro.Instructions.Logo` | `Image` |

Filas: **01** deriva; **02** subir/bajar; **03** boost; **04** gancho;
**05** agarre; **06** disparo; **07** stand/taller; **08** mochila/salir/tabla/cursor.

Para previsualizar, activar temporalmente `ZB_Intro.Enabled` en Edit y volver a
dejarlo **false** al terminar. Su apertura en el juego la controla la lógica
existente. `ResetOnSpawn=false` conserva un solo manual al reaparecer.

El controlador **ya no destruye y reconstruye** sus Frames y textos al iniciar.
Enlaza el botón y reorganiza el layout. Textos, colores, fuentes y esquinas se
conservan. Posiciones/tamaños se adaptan a escritorio y móvil; no son posiciones
fijas inmutables. No renombrar ni borrar los hijos que aparecen en el árbol.

### Imagen compartida frente a imagen exclusiva del manual

- Un `Icon` o `Logo` con **Image vacío** toma la plantilla indicada por su atributo
  `UIAssetKey`, por ejemplo `bag` o `emblem`.
- Un **Image no vacío en el manual** es una sustitución local: tiene prioridad y
  solo cambia ese lugar. Para volver al recurso compartido, vaciarlo.
- Los trazos compartidos se editan en `ReplicatedStorage.UIAssets.Icons.<clave>.Fallback`.
  En Edit pueden seguir viéndose hasta iniciar Play; para previsualizar una imagen
  asignada directamente, ocultar temporalmente `Fallback.Visible`.

## 3. Iconos y estilos como instancias

```text
ReplicatedStorage
└─ UIAssets (Folder; no ModuleScript)
   ├─ Icons
   │  ├─ bag (ImageLabel)
   │  │  └─ Fallback (Frame)
   │  │     ├─ Square (UIAspectRatioConstraint)
   │  │     └─ Stroke01 … (Frames editables)
   │  └─ otros 26 ImageLabels
   └─ Styles
      ├─ panel (Frame + UICorner + UIStroke)
      ├─ card (Frame + UICorner + UIStroke)
      └─ button (Frame + UICorner + UIStroke)
```

**Todos los iconos:** seleccionar `game.ReplicatedStorage.UIAssets.Icons.<clave>`
y editar **Image**. Cada instancia incluye atributos informativos `SourceFile`,
`ExportPixels` y `UIAssetKey`. Los dos primeros documentan la entrega; no suben archivos.

| Elemento | Clave / nombre de ImageLabel | PNG en `docs/assets/ui/` | Tamaño | Uso |
|---|---|---|---|---|
| Mochila/bolso | `bag` | `ui_bag.png` | 256×256 | Botón y manual |
| Tienda | `shop` | `ui_shop.png` | 256×256 | Taller y manual |
| Energía | `energy` | `ui_energy.png` | 256×256 | HUD, tarjetas, manual |
| Gancho | `hook` | `ui_hook.png` | 256×256 | HUD, tarjetas, manual |
| Agarre | `grab` | `ui_grab.png` | 256×256 | Manual |
| Impulso/movimiento | `boost` | `ui_boost.png` | 256×256 | Manual |
| Congelamiento | `freeze` | `ui_freeze.png` | 256×256 | HUD y ranking |
| Blaster/arma | `weapon` | `ui_weapon.png` | 256×256 | Tarjetas y manual |
| Rifle | `rifle` | `ui_rifle.png` | 256×256 | Icono legado/reserva; tarjetas actuales usan WeaponImages.rifle |
| Cañón | `cannon` | `ui_cannon.png` | 256×256 | Icono legado/reserva; tarjetas actuales usan WeaponImages.cannon |
| Láser | `laser` | `ui_laser.png` | 256×256 | Tarjetas |
| Recarga | `regen` | `ui_regen.png` | 256×256 | Tarjetas |
| Moneda | `coin` | `ui_coin.png` | 256×256 | Saldo y ranking |
| Calendario | `calendar` | `ui_calendar.png` | 256×256 | Actividades |
| Ayuda | `info` | `ui_info.png` | 256×256 | Acceso al manual |
| Trofeo | `trophy` | `ui_trophy.png` | 256×256 | Resultados y ranking |
| Emblema | `emblem` | `ui_emblem.png` | **512×512** | Carga y manual |
| Escudo | `shield` | `ui_shield.png` | 256×256 | Reserva |
| Misión | `mission` | `ui_mission.png` | 256×256 | Reserva |
| Regalo | `gift` | `ui_gift.png` | 256×256 | Reserva |
| Ranking | `rank` | `ui_rank.png` | 256×256 | Reserva |
| Cerrar | `close` | `ui_close.png` | 256×256 | Reserva; cierres actuales usan X de texto |
| Confirmar | `check` | `ui_check.png` | 256×256 | Reserva |
| Candado | `lock` | `ui_lock.png` | 256×256 | Reserva |
| Victoria | `victory` | `ui_victory.png` | 256×256 | Reserva |
| Derrota | `defeat` | `ui_defeat.png` | 256×256 | Reserva |
| Recompensa | `reward` | `ui_reward.png` | 256×256 | Reserva |

Reserva significa que la plantilla existe, pero cambiarla no agrega un nuevo icono
a una pantalla que no la consume. Los campos Image se crearon vacíos; el 13/10 se
asignaron los 16 iconos disponibles en el atlas. El resto conserva Fallback.

**Estilo de paneles generados:** editar
`game.ReplicatedStorage.UIAssets.Styles.panel` o `card` o `button`, sus propiedades
de fondo y sus hijos UICorner/UIStroke. El tema copia esas propiedades a los
controles al construirlos. Los colores de selección/compra y el hover pueden
cambiar durante el juego porque expresan estado.

Desde el 13/10 esos estilos son también el fondo nativo de respaldo. Para cambiar
el arte visible de marcos/botones, editar `UIAssets.Skins`, según la sección de atlas.

**Alcance real:** el manual, calendario de Lobby, controles táctiles y accesos
del HUD de la sección 0.2 tienen plantillas en StarterGui. El panel interior de
mochila/tienda, marcador de jugadores y barras del HUD aún se construyen con
controladores y consumen iconos/estilos editables. Su migración restante está
desglosada en [SUGERENCIAS.md](SUGERENCIAS.md), no se presenta como terminada.

## 4. Exportación y aceptación

- PNG RGBA individual; **256×256**, o **512×512** para emblema.
- Alfa real, no damero pintado; margen del 12.5% por lado.
- Un solo dibujo por archivo. Sin texto del botón ni fondo incorporado.
- Dibujo centrado; no deformarlo para llenar el lienzo. `Fit` conserva proporciones.
- Comprobar reconocimiento a 26–44 px, no solo a tamaño grande.
- Si se ve mal, dejar `Image` vacío y usar los trazos hasta corregir el PNG.
- Mantener nombres y claves aunque cambie el arte. Actualizar ambos Places.

Avatares de jugadores siguen usando `rbxthumb` dinámico; no son PNG del catálogo.
La mira, barras y LED son Frames; el halo de daño pertenece a CombatFeedback.
Los controles de `TouchGui` pertenecen a Roblox.

## 5. Historial y archivos que no editar para el flujo nuevo

- `docs/Atlas HUD neon sci‑fi transparente.png`, 1536×1024 e ID
  `105755219623216`: referencia histórica, sin uso en el tema actual.
- `game.ServerStorage.UIAssets_LegacyConfig`: antiguo catálogo Luau, archivado;
  **no es la fuente de las imágenes vigentes**.
- `game.ServerStorage.ZB_Intro_BeforeEditableUI`: copia de seguridad de la plantilla
  anterior del Lobby. No activar como otra interfaz.
- `ReplicatedStorage.Shared.UITheme` y `StarterPlayer.StarterPlayerScripts.AtlasUIController`
  conectan plantillas y comportamiento; no editarlos para reemplazos normales.

Prueba realizada en Studio: cambiar únicamente Image de `Icons.bag`, Text del
título y CornerRadius del manual se reflejó en Play. Botón y manual recibieron
la imagen, `IsLoaded=true`, `ScaleType.Fit` y fallback oculto. Cambios de prueba
restaurados después. No se publicó.

Registrar futuros reemplazos aquí:

| Fecha | Instancia | Archivo | ID anterior | ID nuevo | Lobby probado/publicado | Match probado/publicado |
|---|---|---|---|---|---|---|
| 2026-10-06 | UIAssets y ZB_Intro | Instancias nativas | Catálogo en script | Image vacío + Fallback | Studio / no | Studio / no |
| 2026-10-13 | UIAssets.Icons / Skins y plantillas | 28 PNG en assets/ui | Iconos vacíos y estilos nativos | roblox_asset_ids.json | Studio / no | Studio / no |
| 2026-10-14 | StarterGui: accesos de mochila, tabla, cursor y salida/retorno | Plantillas nativas + ContentPadding | Accesos creados por scripts y opción antigua | Accesos editables; opción antigua retirada | Studio desktop/móvil / no | Studio desktop/móvil / no |
