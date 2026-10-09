# ZERO BREACH — Visual Upgrade & Post-Processing

## ROL

Actuá como un Senior Roblox Technical Artist, Lighting Artist y desarrollador experto en Luau, especializado en entornos sci-fi, iluminación en tiempo real, optimización gráfica y postprocesado en Roblox Studio.

Estás trabajando sobre un proyecto existente llamado **ZERO BREACH**, un shooter competitivo de gravedad cero ambientado en una estación espacial.

Tenés que transformar la calidad visual del escenario existente sin reconstruirlo ni alterar sus mecánicas.

## OBJETIVO

Queremos pasar del estado visual actual a una estética futurista cinematográfica, similar a la imagen de referencia proporcionada.

**Estado actual:**
- Escenario 3D construido y funcional.
- Estructuras metálicas grises y oscuras.
- Portales de diferentes modos de juego.
- Maquinaria futurista y elementos tecnológicos.
- Iluminación plana y poco contraste.
- Materiales que no aprovechan suficientemente la iluminación.
- Poca presencia visual de los neones.

**Resultado esperado:**
- Estación espacial futurista con identidad visual propia.
- Iluminación azul/cian y magenta.
- Luces que realmente iluminen las superficies cercanas.
- Piso metálico con detalles luminosos.
- Materiales con mayor profundidad visual.
- Resplandor controlado en portales y maquinaria.
- Sombras que aporten volumen.
- Atmósfera espacial cinematográfica.
- Buena visibilidad para un shooter competitivo.

El objetivo NO es convertir todo en una discoteca de neones. Buscamos una estación espacial tecnológica, industrial, moderna y visualmente impactante.

---

## REGLA PRINCIPAL: PRESERVAR EL PROYECTO

No modificar:
- Geometría ni posición de las estructuras principales.
- Dimensiones del mapa.
- Colisiones.
- Scripts de combate.
- Sistemas de movimiento y gravedad cero.
- Teletransportes.
- ProximityPrompts.
- Funcionalidad de los portales.
- Interfaces existentes.
- Sistemas de matchmaking.
- Modelos y sus jerarquías, salvo cambios visuales controlados y justificados.

No destruir ni reemplazar elementos existentes sin autorización.

Trabajar de forma incremental y reversible.

## FASE 1 — AUDITORÍA DEL ESCENARIO

Si existe una conexión MCP con Roblox Studio, utilizarla para inspeccionar el proyecto real.

Identificar:

1. Configuración actual de Lighting.
2. Efectos de postprocesado existentes.
3. Luces PointLight, SpotLight y SurfaceLight.
4. Materiales de pisos, paredes y techos.
5. Partes que utilizan Material.Neon.
6. Portales y elementos tecnológicos.
7. Elementos visuales que pueden mejorarse sin alterar su funcionamiento.
8. Scripts que modifican Lighting o propiedades visuales durante la ejecución.

Antes de modificar, elaborar un diagnóstico breve.

No asumir nombres de objetos ni rutas que no se hayan verificado.

## FASE 2 — ILUMINACIÓN GLOBAL

Crear una configuración visual coherente utilizando las propiedades y tecnologías realmente disponibles en la versión actual de Roblox Studio.

Priorizar:
- Iluminación global equilibrada.
- Sombras suaves y legibles.
- Contraste cinematográfico.
- Luz ambiental fría.
- Control de exposición.
- Correcta separación entre estructuras y fondo.

Valores orientativos iniciales:

- ClockTime: 0
- Brightness: 2
- ExposureCompensation: -0.3
- Ambient: RGB(25, 30, 50)
- OutdoorAmbient: RGB(15, 20, 35)
- GlobalShadows: true

Estos valores son puntos de partida, no configuraciones obligatorias.

Comprobar compatibilidad de las propiedades y sistemas de iluminación actuales antes de aplicarlos.

Evitar que las zonas jugables queden excesivamente oscuras.

## FASE 3 — POSTPROCESADO

Configurar efectos nativos de Roblox.

### BloomEffect

Crear resplandor controlado alrededor de:
- Portales.
- Paneles tecnológicos.
- Luces del piso.
- Maquinaria.
- Estructuras energéticas.

Valores iniciales sugeridos:
- Intensity: 0.45
- Size: 30
- Threshold: 1.2

Evitar sobreexposición.

### ColorCorrectionEffect

Aplicar una corrección de color cinematográfica.

Valores orientativos:
- Contrast: 0.18
- Saturation: 0.1
- Brightness: 0

Conservar los colores distintivos de cada modo de juego.

### Otros efectos

Evaluar ColorGradingEffect, Atmosphere y otros recursos compatibles únicamente cuando aporten valor real.

No agregar desenfoque de profundidad de campo permanente que perjudique la visibilidad competitiva.

No agregar efectos por el simple hecho de que existan.

## FASE 4 — ILUMINACIÓN LOCAL

Agregar iluminación estratégica alrededor de los elementos existentes.

Paleta principal:
- Azul eléctrico: #00BFFF
- Cian tecnológico: #00F0FF
- Magenta energético: #FF39DB
- Violeta: #8B5CF6
- Naranja industrial: #FF9A35

Aplicar las luces con criterio:

**Portales:** cada uno debe conservar su identidad cromática y proyectar luz suave sobre su entorno.

**Maquinaria:** luces técnicas localizadas que destaquen volumen, cables y componentes.

**Techo:** iluminación de apoyo para definir la arquitectura.

**Piso:** puntos luminosos y líneas energéticas que refuercen el diseño sin perjudicar la lectura del espacio.

No llenar el mapa de luces indiscriminadamente.

## FASE 5 — MATERIALES

Inspeccionar materiales existentes antes de modificarlos.

Objetivo:
- Piso metálico tecnológico.
- Paredes industriales con contraste.
- Estructuras principales de metal oscuro.
- Elementos energéticos con Material.Neon.
- Superficies que reaccionen visualmente a la iluminación.

Evaluar MaterialService, MaterialVariants y SurfaceAppearance cuando corresponda.

No asumir que Metal o Neon producen reflejos físicamente exactos.

No prometer reflejos en tiempo real que Roblox no soporte.

No modificar texturas personalizadas sin analizar primero su utilización.

## FASE 6 — OPTIMIZACIÓN

ZERO BREACH es un shooter competitivo.

La estética no debe perjudicar:
- FPS.
- Tiempo de carga.
- Legibilidad de jugadores.
- Identificación de equipos.
- Visibilidad de proyectiles.
- Respuesta de controles.

Diseñar tres perfiles visuales:

**HIGH:** iluminación y efectos completos.

**MEDIUM:** iluminación local reducida y postprocesado moderado.

**LOW:** iluminación simplificada, efectos costosos desactivados y elementos luminosos esenciales conservados.

Evitar cambios constantes de propiedades gráficas en RenderStepped.

Distinguir entre efectos controlables mediante scripts y opciones gráficas que dependen del motor o del dispositivo.

## FASE 7 — IMPLEMENTACIÓN

Organizar el sistema de forma mantenible.

Preferentemente:
- Configuración visual centralizada.
- Presets separados.
- Funciones reutilizables.
- Identificación de luces y efectos administrados por el sistema.
- Sin duplicar instancias en ejecuciones posteriores.
- Sin conflictos con otros scripts.

Cuando corresponda, usar CollectionService para identificar grupos de elementos.

Si se crean scripts, indicar exactamente dónde deben ubicarse dentro de Roblox Studio.

Distinguir claramente entre Script, LocalScript y ModuleScript.

No crear un sistema excesivamente complejo para una tarea que puede resolverse con configuración nativa.

## FASE 8 — VALIDACIÓN

Después de cada etapa:

1. Comprobar que no aparecieron errores.
2. Verificar que las mecánicas siguen funcionando.
3. Confirmar que no se duplicaron luces o efectos.
4. Comparar visualmente con la referencia.
5. Evaluar legibilidad y rendimiento.
6. Registrar los cambios realizados.

Si el MCP permite capturar imágenes del viewport, utilizarlas para comparar el antes y después.

No afirmar que el resultado visual fue verificado si no se pudo observar realmente.

---

## FORMA DE TRABAJO

Trabajaremos por etapas.

**Primera ejecución:**

1. Inspeccionar el proyecto.
2. Detectar la configuración gráfica existente.
3. Presentar un diagnóstico.
4. Preparar un plan de modificaciones.
5. Implementar únicamente la primera etapa de iluminación global y postprocesado.
6. Verificar el resultado.

No ejecutar todas las fases de una sola vez.

No sobrescribir configuraciones existentes sin registrar sus valores originales.

No modificar el mapa completo de forma automática.

Priorizar cambios pequeños, medibles y reversibles.

## CRITERIO FINAL

La estación debe sentirse como un entorno de combate orbital de alta tecnología.

La imagen de referencia es nuestra dirección artística, no una excusa para agregar efectos exagerados.

**Queremos mejorar la calidad visual del proyecto que ya existe, no construir otro juego.**

Comenzá auditando el proyecto mediante las herramientas disponibles y explicá qué encontraste antes de realizar cambios.

---

## Registro de ejecución — 2026-10-09

**Estado: primera etapa implementada y verificada visualmente en Studio en ambos
Places. Sin publicación ni validación multijugador/móvil.** Responsable: asistente
mediante MCP. Referencia utilizada: dirección artística de este documento; no se
recibió una imagen de referencia en esta sesión.

### Auditoría y diagnóstico

- Lobby `125075465377023`: ClockTime 14.5, Brightness 3, exposición +0.25,
  Ambient/OutdoorAmbient RGB(110,115,130), LightingStyle Soft y sombras activas.
  Bloom existente 1/24/2 (Intensity/Size/Threshold); Atmosphere Density 0.18,
  SunRays activo y DepthOfField desactivado. Sky espacial personalizado conservado.
- Match `108298899371591`: ClockTime 14, Brightness 2.5, exposición +0.25,
  Ambient/OutdoorAmbient RGB(130,135,150), LightingStyle Soft y sombras desactivadas.
  EnvironmentDiffuseScale/SpecularScale 0. Bloom existente 0/24/0.95;
  ColorGrading existente activo con TonemapperPreset Retro, conservado.
- Luces locales en Edit: Lobby 30 PointLights, Match 1 PointLight; todas sin sombras
  locales. Lobby contiene 1.366 piezas Neon, 662 Metal y 2.103 DiamondPlate;
  Match, 37 Neon y 22 Metal. Predominan también SmoothPlastic en Lobby y Plastic
  en Match. Ningún material, textura ni luz local fue modificado en esta etapa.
- Portales comprobados en `Workspace.BattlePortals` (Lobby); sus colores propios
  y los trims Azul/Rojo de `Workspace.Arena.SpawnCovers` (Match) se conservaron.
- Búsqueda en scripts sin coincidencias para Lighting ni escritores de ClockTime,
  ExposureCompensation, Ambient, BloomEffect o ColorCorrectionEffect.
- Capturas iniciales mostraban iluminación uniforme y baja separación de volúmenes;
  en Match, el Bloom de intensidad cero no aportaba resplandor.

### Configuración final de la primera etapa

Valores permanentes en **Lighting**, editables desde Properties; no se agregó
ningún script de ejecución ni controlador por frame.

| Propiedad | Lobby | Match |
|---|---|---|
| ClockTime | 14.5 | 14 |
| Brightness | 2 | 2 |
| ExposureCompensation | +0.25 | +0.2 |
| Ambient (RGB) | 150,160,180 | 145,155,175 |
| OutdoorAmbient (RGB) | 160,170,190 | 155,165,185 |
| GlobalShadows | true | true |
| ShadowSoftness | 0.35 | 0.35 |
| EnvironmentDiffuseScale | 0.6 | 0.6 |
| EnvironmentSpecularScale | 0.45 | 0.45 |
| LightingStyle | Realistic | Realistic |
| PrioritizeLightingQuality | true | true |
| Bloom existente: Intensity / Size / Threshold | 0.30 / 24 / 1.35 | 0.24 / 24 / 1.35 |
| ZB_StationColor: Contrast / Saturation / Brightness | 0.025 / 0.035 / 0.015 | 0.025 / 0.025 / 0.01 |
| ZB_StationColor: TintColor (RGB) | 250,252,255 | 245,250,255 |

`Lighting.ZB_StationColor` es el único ColorCorrectionEffect añadido, identificado
con el atributo `ZB_ManagedVisual=true`. Se reutilizó `Lighting.Bloom` y se desactivó
`Lighting.SunRays` en Lobby. Los restantes efectos originales se conservaron.
La primera captura nocturna del Lobby dejó el piso demasiado oscuro: se elevó
Ambient y se redujo Contrast. El usuario confirmó después que el conjunto seguía
demasiado oscuro; esa variante nocturna fue sustituida por la configuración
diurna y más luminosa de la tabla anterior.
No usar automáticamente los valores sugeridos RGB(25,30,50): sin iluminación
local adicional perjudicaban la lectura de este escenario.

### Respaldo y reversión

Existe en **cada Place** `ServerStorage.ZB_LightingBackup_20261009`:

- `OriginalProperties`: Configuration con atributos tipados de las 11 propiedades
  originales de Lighting modificadas. LightingStyle se guarda como nombre de enum.
- `OriginalChildren`: clones de todos los hijos originales de Lighting, fuera del
  servicio activo, para consulta/respaldo.
- `ModifiedEffects`: ObjectValues hacia los efectos reutilizados; sus atributos
  guardan Enabled y, para Bloom, Intensity/Size/Threshold originales.
- `AddedColorCorrection`: referencia al efecto nuevo para retirarlo al revertir.
- Atributos de comprobación de Workspace y `VerifiedWorkspaceUnchanged=true`.

Con Play detenido, ejecutar en Command Bar del Place que se quiera revertir:

```lua
local lighting = game:GetService("Lighting")
local backup = game.ServerStorage:WaitForChild("ZB_LightingBackup_20261009")
assert(backup:GetAttribute("PlaceId") == game.PlaceId, "Respaldo de otro Place")
for property, value in pairs(backup.OriginalProperties:GetAttributes()) do
    lighting[property] = property == "LightingStyle"
        and Enum.LightingStyle[value] or value
end
for _, reference in ipairs(backup.ModifiedEffects:GetChildren()) do
    if reference.Value and reference.Value.Parent == lighting then
        for property, value in pairs(reference:GetAttributes()) do
            reference.Value[property] = value
        end
    end
end
local added = backup.AddedColorCorrection.Value
if added and added.Parent == lighting then
    added:Destroy()
end
```

No copiar `OriginalChildren` entero a Lighting: duplicaría efectos. El respaldo
se conserva tras la reversión. La operación inicial registró Undo en Studio;
los ajustes posteriores y la reversión exacta están cubiertos por el respaldo.

### Verificaciones realizadas

- [x] Capturas comparables antes/después con las mismas cámaras en Lobby y Match;
  capturas adicionales próximas al spawn del Lobby y dentro de la arena Match.
- [x] Ajuste de legibilidad del piso tras observar la primera variante nocturna.
- [x] Play Solo: un Bloom, un ColorCorrectionEffect y un efecto administrado por Place;
  ClockTime 0 y configuración nueva presentes también en el cliente.
- [x] Lobby: un `ZB_Intro`, cierre real mediante Continue, menú=false y desplazamiento
  con W de 16.103 studs. WalkSpeed 16, GameMode LOBBY y gravedad 196.2.
- [x] Match: gravedad 0. Rechazo esperado de TeleportData inválido y errores de retorno
  al abrirlo aislado en Studio; no constituyen una prueba de VS ni de teleport real.
- [x] Output consultado durante arranque: sin errores de iluminación observados.
- [x] Firma de Workspace antes/después idéntica: Lobby 3019184495 / 7.786 entradas;
  Match 2247488320 / 101 entradas. Incluye CFrame, Size, CanCollide/CanTouch/CanQuery,
  Material, Color y Anchored de BaseParts, fuentes de scripts bajo Workspace y
  Enabled/ActionText/KeyboardKeyCode de prompts. No es una auditoría de todo el gameplay.
- [x] Ambos Places terminan en Edit; atributo temporal de medición retirado.
- [ ] Prueba publicada con jugadores, combate, equipos, FPS/carga y móvil real.

### Siguientes etapas

1. Retomar bloqueantes de misiones/ranking del PLAN_10_DIAS; reproducir fallos antes
   de corregir y confirmar la regla compartida de partidas completas.
2. Iluminación local: revisar portales/maquinaria y sumar fuentes acotadas tras
   evaluar coste. La etapa global no hace que cada Neon ilumine por sí mismo.
3. Materiales selectivos y perfiles HIGH/MEDIUM/LOW: **pendientes**, no implementados.
  Realistic/PrioritizeLightingQuality expresan intención; no fijan el nivel gráfico
  efectivo de todos los dispositivos. Medir antes de prometer rendimiento.

### Corrección por revisión del usuario — 2026-10-09

- Reporte: «quedó muy oscuro todo», con captura del Lobby. La primera revisión
  visual de esta sesión no fue suficiente para aceptar la legibilidad general.
- Aplicado en ambos Places: recuperar ClockTime diurno, elevar Ambient/OutdoorAmbient
  y exposición, reducir contraste y ajustar respuesta difusa/especular del entorno.
  Tabla de configuración final actualizada; Bloom y colores de neones conservados.
- Capturas nuevas desde las mismas cámaras muestran el piso y la maquinaria del
  Lobby más claros y las estructuras del Match visibles. El cielo espacial original
  del Lobby se conserva. No se cambió el cielo original del Match.
- Respaldo original intacto. `BeforeReadabilityAdjustment`, dentro del respaldo de
  cada Place, conserva las propiedades previas a esta corrección y Contrast/Brightness
  del ColorCorrectionEffect. Cambio registrado con Undo en ambos Places.
- Verificación de esta corrección: visual en Edit; no se repitió Play Solo ni se
  midieron FPS. Las pruebas anteriores con ClockTime 0 describen la variante histórica.
- Ambos Places permanecen en Edit, sin publicar. Aprobación visual del usuario pendiente.
