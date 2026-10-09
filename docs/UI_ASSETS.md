# UI — Buscar en Explorer y reemplazar

Actualizado: **2026-10-06**, revisión posterior al pedido de edición visual.
Aplica a Lobby `125075465377023` y Match `108298899371591`.

**Flujo vigente: seleccionar una instancia y editar Properties. No abrir scripts
para cambiar una imagen, un texto del manual o sus esquinas.**

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

Solo el último cobro diario está confirmado por los datos existentes; no hay
historial completo de misiones. Fechas anteriores sin registro y futuras tienen
su explicación; seleccionar una fecha no autoriza cobrarla. Pruebas en CHECKLIST.

## 0.1 Controles táctiles — agregado 2026-10-09

**Lobby y Match:** `StarterGui.ZB_MobileControls`, atributo `MobileControls=true`
(no lo reestiliza AtlasUIController). Contiene `Actions` con botones redondos;

```text
StarterGui.ZB_MobileControls
└─ Actions
   ├─ Fire  (Caption "DISPARAR", Icon weapon)
   ├─ Hook  (Caption "GANCHO", Icon hook)
   ├─ Up    (Caption "SUBIR", Arrow ▲)
   └─ Down  (Caption "BAJAR", Arrow ▼)
```

| Cambio visual | Seleccionar | Propiedad |
|---|---|---|
| Color del botón | Actions.Fire / Hook / Up / Down | BackgroundColor3 / UICorner / UIStroke |
| Etiqueta del botón | <botón>.Caption | Text |
| Icono | <botón>.Icon (o UIAssets.Icons.weapon/hook) | Image |

Accesos de menú y HUD móvil los distribuye `ReplicatedStorage.Shared.MobileHudLayout`
en tiempo de ejecución, tomando `UIAssets.Icons` para iconos redondos (bag, calendar,
info, trophy, close) y añadiendo una leyenda corta. No editar esos botones en
Properties esperando que persista: los posiciona el layout según viewport. La
lógica de intención vive en `Shared.LocalCombatInput` y `StarterPlayerScripts.MobileControls`.
Los controles solo aparecen con `TouchEnabled` en landscape y combate activo.

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

**Estado actual:** `bag.Image` está vacío. Su dibujo existe como Frames dentro de
`bag.Fallback`; no hay un PNG individual que se haya perdido. La carpeta local
`docs/assets/ui/` es el destino de entrega de futuros PNG, no una carpeta cargada
automáticamente por Roblox.

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

## 2. El manual está armado en Studio

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
| Rifle | `rifle` | `ui_rifle.png` | 256×256 | Tarjetas |
| Cañón | `cannon` | `ui_cannon.png` | 256×256 | Tarjetas |
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
a una pantalla que no la consume. Todos los campos Image comienzan vacíos.

**Estilo de paneles generados:** editar
`game.ReplicatedStorage.UIAssets.Styles.panel` o `card` o `button`, sus propiedades
de fondo y sus hijos UICorner/UIStroke. El tema copia esas propiedades a los
controles al construirlos. Los colores de selección/compra y el hover pueden
cambiar durante el juego porque expresan estado.

**Alcance real:** el manual completo está prearmado en StarterGui. Mochila/tienda,
HUD y actividades todavía construyen sus datos y controles dinámicos con sus
controladores; ahora consumen iconos/estilos editables. Su migración completa a
plantillas está desglosada en [SUGERENCIAS.md](SUGERENCIAS.md), no se presenta como terminada.

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
