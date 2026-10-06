# ZERO BREACH — Reglas de desarrollo

Actualizado: 2026-10-06. Estándar obligatorio del proyecto.

## Documentación y fuente de verdad

La documentación principal se mantiene en **seis archivos**:

- [REGLAS.md](REGLAS.md): normas de código, seguridad y UI.
- [DISENO.md](DISENO.md): resumen, mecánicas, balance, arquitectura y contratos.
- [CHECKLIST.md](CHECKLIST.md): estado, trabajo pendiente, pruebas y progreso resumido.
- [BUGS.md](BUGS.md): incidentes, causas, correcciones y regresiones que revisar.
- [UI_ASSETS.md](UI_ASSETS.md): catálogo y guía operativa de sustitución de imágenes,
  solicitada el 2026-10-06; rutas, nombres, medidas y cambios en ambos Places.
- [SUGERENCIAS.md](SUGERENCIAS.md): pasos futuros de UI, cosméticos, monetización,
  videos, publicidad y regalos de avatar; diferenciar rutas existentes de propuestas.

Actualizar estas páginas en lugar de crear una nueva por sesión. Separar siempre
**implementado**, **verificado en Studio**, **validado en producción** y **propuesto**.
Una prueba simulada no confirma multijugador, persistencia entre sesiones ni teleport.
Las decisiones vigentes sustituyen los prototipos históricos; no reactivar estos
últimos siguiendo una nota antigua.

El código real se modifica en Roblox Studio. A 2026-10-02 este repositorio contiene
documentación y configuración de OpenCode, pero **no contiene `src/`**. Las antiguas
instrucciones de pegar o sincronizar archivos desde `src/` no describen el checkout
actual. No afirmar que existe una copia local del código ni que se publicaron los
Places sin comprobarlo. Mantener sincronizadas las mecánicas compartidas de Lobby
y Match y registrar explícitamente cualquier Place pendiente.

## Estructura y responsabilidades

| Ruta | Contenido |
|---|---|
| `ReplicatedStorage.Models` | Modelos reutilizables |
| `ReplicatedStorage.Modules` | ModuleScripts compartidos |
| `ReplicatedStorage.RemoteEvents` | Comunicación cliente-servidor |
| `ReplicatedStorage.Shared` | Configuración, constantes y versiones |
| `ServerScriptService` | Lógica autoritativa de servidor |
| `StarterPlayer.StarterPlayerScripts` | Input, cámara, UI y efectos locales |
| `StarterPlayer.StarterCharacterScripts` | Animación y comportamiento por personaje |

- Visual puro: cliente. Gameplay real: servidor. Configuración compartida: ReplicatedStorage.
- UI: separar controlador, lógica y configuración; no mezclar economía o autoridad con presentación.
- Modularizar sistemas grandes; los módulos retornan tablas estructuradas.
- No introducir variables globales. La integración histórica `_G.ZB` se documenta
  como deuda existente, no como patrón para sistemas nuevos.

## Cabeceras y funciones

Cada script debe comenzar indicando tipo, ubicación exacta y contexto:

```lua
-- Tipo: LocalScript
-- Ubicación: StarterPlayer.StarterPlayerScripts.CombatFeedback
-- Contexto: Cliente
```

Cada función debe documentar dentro su propósito, precondiciones, ubicación y
retorno cuando corresponda:

```lua
local function ejemplo(valor)
    -- Propósito: Describir la operación.
    -- Precondiciones: Indicar datos y contexto requeridos.
    -- Ubicación: Ruta exacta del script.
    -- Retorna: Describir el resultado, si aplica.
end
```

## Seguridad y convenciones

- **El cliente nunca tiene autoridad** sobre daño, energía, saldo, propiedad,
  recompensas, captura, equipos, resultados ni asignación de partida.
- Validar en servidor existencia, tipos, rangos, números/vectores finitos,
  ownership, distancia, cadencia, permisos y estado individual del solicitante.
- No confiar en un formato, `matchId` o resultado elegido por cliente.
- Validar remotes en `ServerScriptService`; alojarlos en `ReplicatedStorage.RemoteEvents`.
- Compras y recompensas nunca se conceden desde un LocalScript.
- Validación compartida no sustituye revalidación en servidor.
- Variables `camelCase`, módulos `PascalCase`, constantes `MAYUSCULAS`.
- Usar `task.wait` y `task.spawn`, no las versiones globales antiguas.
- Sin prints innecesarios en producción; usar depuración controlada.
- No bloquear input, Heartbeat, feedback o eliminación esperando red/DataStore.
- Evitar escanear todo Workspace en cada frame; cachear y reaccionar a eventos.
- Si un exploit puede abusar de la operación, la implementación está incompleta.

## Referencia práctica de GUI

| Contenedor | Uso |
|---|---|
| `ScreenGui` en `PlayerGui` | HUD, menús y overlays de pantalla |
| `SurfaceGui` sobre BasePart | Carteles/pantallas del mundo; configurar Face y resolución |
| `BillboardGui` con Part/Adornee | Nombres, porcentajes y marcadores sobre personajes |

- Esperar `LocalPlayer:WaitForChild("PlayerGui")` antes de insertar interfaces.
- `ResetOnSpawn=false` para UI persistente; reconectar estado del personaje al
  reaparecer y desconectar listeners del anterior.
- `UDim2.new(xScale, xOffset, yScale, yOffset)`: escala relativa y píxeles.
  `fromScale` sirve para tamaño adaptable; `fromOffset` para medidas base.
- Centrar con `AnchorPoint=Vector2.new(0.5,0.5)` y posición `(0.5,0.5)`.
  Barra inferior: ancla `(0.5,1)` y posición inferior con margen.
- Usar `UIScale`, `UIAspectRatioConstraint`, límites de tamaño/texto, padding,
  listas y scroll. No asumir que el viewport de escritorio representa móvil.
- Animar Size/Position/transparencia con TweenService; `Text` no es tweenable.
  Cancelar/reemplazar animaciones en conflicto y dejar un estado final definido.
- `AutomaticSize` para altura dinámica; `CanvasSize` según contenido de listas.
- `AbsoluteSize` puede ser cero antes del primer layout; leer tras defer/render.
- `BillboardGui.AlwaysOnTop=false` cuando deba respetar paredes. SurfaceGui:
  revisar `LightInfluence`, Face y geometría al investigar visibilidad/parpadeo.
- Definir `DisplayOrder` y `ZIndexBehavior` para overlays/resultados. Los paneles
  interactivos deben consumir input según corresponda; un efecto de daño no debe
  bloquear controles ni tapar el centro de la mira.
- Usar ImageLabel/ImageButton y `rbxassetid://...` para arte propio; documentar
  nombre lógico, ID, tamaño base y uso.
- Iconos individuales con alfa real y `ScaleType.Fit`; nunca estirar un atlas
  para convertirlo en paneles de otra proporción. Si una imagen no queda bien,
  mantener la alternativa nativa. Plantillas compartidas:
  `ReplicatedStorage.UIAssets.Icons` (ImageLabels) y `.Styles` (Frames).
- Priorizar edición visual en Explorer/Properties: pantallas estáticas en StarterGui,
  componentes repetibles en ReplicatedStorage.UIAssets. Los controladores enlazan
  objetos y datos; no deben destruir y reconstruir una plantilla editable al iniciar.
- `StarterGui.ZB_Intro` ya es una plantilla completa. No afirmar que el resto de
  pantallas ya está migrado: el plan pendiente está en SUGERENCIAS.
- Probar respawn, diferentes viewports, cierre de menú y conexiones duplicadas.

## Checklist de entrega

- [ ] Tipo, ubicación y contexto correctos; funciones documentadas.
- [ ] Validaciones autoritativas completas; remotes y datos del cliente revisados.
- [ ] Código modular, nombres consistentes y depuración controlada.
- [ ] Cámara, UI, conexiones y física se limpian al salir/reaparecer.
- [ ] Mecánicas compartidas sincronizadas en ambos Places.
- [ ] Verificaciones registradas con su alcance real en CHECKLIST.
- [ ] Diseño y bugs actualizados, sin duplicar documentación por sesión.
