# Sugerencias — UI editable, cosméticos y monetización

Actualizado: **2026-10-26**. Documento de trabajo: añadir pasos, decisiones y
resultados aquí. Guía rápida de imágenes: [UI_ASSETS.md](UI_ASSETS.md).

## 0. Qué existe y qué falta

### Base contrastada con Studio — 2026-10-26

- Mochila/tienda de **Lobby ya migrada** a plantilla completa con
  EditableEquipment=true, Summary y Templates.CatalogCard. No proponer construirla
  de nuevo. El siguiente trabajo de UI es adaptar ese contrato a Match, que aún
  conserva su constructor anterior. Guía de edición local de Artwork en UI_ASSETS.
- Ranking físico nuevo implementado en Lobby: Workspace.Rankings3D, API de servidor
  y puente desde RankService; no crear otra persistencia ni otro productor de estadísticas.
- Música por zona ya implementada en ambos mediante ZoneMusicController y
  SoundService.ZB_Music. No confundir música con el video promocional pendiente.
- Pase del Cañón conectado en Lobby, AutoGrantPasses=true; Rifle sigue PassId=0.
  Match conserva datos de propiedad, pero no tiene WeaponOffers y sus tres imágenes
  de armas siguen vacías. Compra nueva y paridad visual siguen pendientes.
- Cable genérico **ya tiene renderer 3D** RopeSkins.Generic, además del Beam
  replicado. No proponer implementarlo como si todavía solo existiera el Beam plano.
- Colecciones Aurora/Plasma/Solar, categorías nuevas de skins/entitlements, productos
  repetibles/ProcessReceipt, video/ads y premio global siguen siendo propuestas.
  No se identificaron VideoFrame/AdGui en Workspace durante esta inspección; no se
  comprobó Dashboard ni material externo. Presencia de modelos decorativos, como
  space_man_mark, no certifica una skin equipable/persistente ni la colección completa.

Priorizar compatibilidad B24 y presentación B25 antes de ampliar contenido. Evidencia
de esta revisión: Edit/fuentes/captura, no nuevas pruebas Player ni publicación.

**Implementado (base histórica, con las actualizaciones de arriba):** iconos/estilos como instancias en
`ReplicatedStorage.UIAssets`, manual prearmado en `StarterGui.ZB_Intro`, tienda
con monedas del juego, inventario y cosméticos de punta/cuerda de gancho.
Desde el 09/10 también `StarterGui.ZB_DailyActivities` en Lobby: calendario mensual
real editable con misiones/cobros; contrato en UI_ASSETS. La lista siguiente de
migraciones es propuesta salvo las pantallas marcadas como implementadas.

**Propuesto, todavía NO implementado como entrega de este documento:** las nueve
skins, packs, procesamiento de recibos para productos repetibles, videos/anuncios
y reclamación de UGC. La venta Robux del Cañón **sí está conectada** por pase;
no usa ProcessReceipt. Crear un pase en la web no conecta por sí solo la recompensa.

Todas las rutas señaladas **POR CREAR** son el contrato propuesto de organización:
no hay que buscarlas esperando que ya existan. No se crearon productos, pases,
campañas ni recursos pagos desde esta sesión.

### Orden recomendado

**Avance real del 16/10 — venta del Cañón por pase conectada:**
Lobby tiene tres vitrinas en `Workspace.WeaponDisplays`, imágenes propias y
accesos que abren la misma sección de armas de la tienda. SDR-Mk2 es gratuita.
El catálogo de estas armas es `ReplicatedStorage.WeaponOffers.blaster/rifle/cannon`.

- **Cañón:** pase `2039918698` ("cañon", 10 R$) **conectado**. `MonetizationService`
  (Lobby) verifica `UserOwnsGamePassAsync`, concede el arma con `grantWeapon`,
  registra el derecho en `profile.passes` y guarda; también concede tras
  `PromptGamePassPurchaseFinished`. El Cañón es **solo con el pase**: ya no se
  compra con 250 monedas (quienes lo tenían lo conservan). La tienda muestra
  **DESBLOQUEAR · 10 R$** y abre el prompt oficial.
- **Rifle:** sigue PASE PRÓXIMAMENTE (`PassId=0`). Al poner un ID válido y
  `PurchaseIntegrationReady=true` usa el mismo flujo sin tocar código.

Pendientes: probar la compra real con Robux, un segundo jugador sin pase y el
viaje Lobby→Match→Lobby publicado; cancelación/reconexión; y crear el pase del
Rifle. Guía y pruebas en UI_ASSETS 0.4–0.5. No se publicó el Place.
Las rutas de packs del apartado 3 siguen siendo propuestas distintas, no pases ya creados.

1. [x] Cambiar imágenes y texto del manual desde Explorer/Properties.
2. [ ] Adaptar la mochila editable de Lobby a Match y migrar las pantallas restantes,
   conservando callbacks. Lobby/calendario ya tienen plantilla completa.
3. [ ] Preparar y probar las nueve skins, sin venta todavía.
4. [ ] Implementar derechos/persistencia/visuales compartidos de cosméticos.
5. [ ] Crear tres pases de packs y conectar su entrega autoritativa.
6. [ ] Añadir un producto repetible y su procesador de recibos, si se decide vender monedas.
7. [ ] Preparar video promocional propio y pantalla de Lobby.
8. [ ] Evaluar anuncios según elegibilidad real del Dashboard.
9. [ ] Publicar una mochila UGC si se decide financiar un regalo de inventario global.

## 1. UI: que el diseñador encuentre el objeto y lo cambie

### Ya disponible

| Cambio | Ruta exacta | Acción |
|---|---|---|
| Mochila por bolso | `ReplicatedStorage.UIAssets.Icons.bag` | Cambiar `Image` |
| Emblema compartido | `ReplicatedStorage.UIAssets.Icons.emblem` | Cambiar `Image` |
| Fondo de paneles generados | `ReplicatedStorage.UIAssets.Styles.panel` | Cambiar `BackgroundColor3` |
| Esquinas de esos paneles | `ReplicatedStorage.UIAssets.Styles.panel.UICorner` | Cambiar `CornerRadius` |
| Placa visible del manual | `StarterGui.ZB_Intro.Instructions.Artwork` | Cambiar `Image`; contiene textos incorporados |
| Título/instrucción del fallback clásico | `Instructions.Title` / `Instructions.Rows.Row04.Description` | Cambiar `Text`; ocultos con FullArtIntro=true |
| Marco de mochila nueva (Lobby) | `StarterGui.ZB_EquipmentDashboard.Panel.Artwork` | Cambiar `Image`; no el PanelFrameSkin heredado |

Trabajar con Play detenido. Repetir o copiar el objeto al otro Place. Los IDs
de imagen se suben una vez y se reutilizan. No dejar duplicados con el mismo nombre.

### Próxima migración de pantallas completas — POR HACER

Manual, calendario Lobby y mochila Lobby ya siguen el flujo visual. Para el resto,
migrar una pantalla a la vez:

| Plantilla propuesta | Contenido visual | Controlador que debe enlazarla |
|---|---|---|
| `StarterGui.ZB_EquipmentDashboard` — implementado Lobby; Match pendiente | Backdrop, OpenInventory, Panel completo, resumen y navegación | EquipmentDashboard + Shared.EquipmentDashboardLayout |
| `StarterGui.ZB_EquipmentDashboard.Templates.CatalogCard` — implementado Lobby | TextButton con Artwork, IconFrame/Icon, Title, Detail, Divider y Action | EquipmentDashboard clona para cada artículo; no crear Components.EquipmentCard duplicado |
| `StarterGui.ZB_DailyActivities` — implementado 09/10 en Lobby | Calendario mensual, detalles, recompensa y tres filas estáticas; sin reconstrucción runtime | `StarterPlayer.StarterPlayerScripts.DailyActivities` |
| `ReplicatedStorage.UIAssets.Components.MissionRow` — propuesta | La GUI vigente ya tiene Row01..Row03 en su plantilla; componente compartido todavía no creado | DailyActivities |
| `StarterGui.ZB_HUD` | Barras, etiquetas y mira | `StarterPlayer.StarterPlayerScripts["HudController.client"]` |

Pasos por pantalla:
1. Crear la plantilla en Edit, con nombres estables y propiedades visibles.
2. Cambiar el controlador para buscar esos objetos en PlayerGui; retirar su
   constructor equivalente. No mantener dos productores de la misma interfaz.
3. Conservar conexiones de compra, cobro, equipado y cierre. El servidor sigue
   decidiendo saldo, propiedad y recompensas.
4. Los textos dinámicos —saldo, precio, estado— seguirán siendo actualizados por
   código. El diseñador controla su fuente, color y distribución, no su valor real.
5. Probar desktop/móvil, apertura/cierre, listas regeneradas y respawn en ambos Places.

## 2. Nueve cosméticos: tres skins, tres ganchos y tres skins de armas

Propuesta de **tres colecciones**, cada una con skin de personaje, gancho y arma.
Son cambios de aspecto: no alteran daño, cadencia, energía, alcance ni velocidad.

| Colección | Skin de personaje | Skin de gancho | Skin de arma |
|---|---|---|---|
| Aurora | `avatar_aurora`: blanco/cian | `hook_aurora`: punta cristalina cian | `weapon_aurora`: acabado blanco/cian |
| Plasma | `avatar_plasma`: gris/violeta | `hook_plasma`: punta violeta | `weapon_plasma`: acabado violeta |
| Solar | `avatar_solar`: negro/dorado | `hook_solar`: punta dorada | `weapon_solar`: acabado negro/dorado |

Los tres nombres de arma son **skins**, no tres armas de balance nuevas.
`Config.Weapons` ya contiene `blaster`, `rifle` y `cannon` con estadísticas distintas.
No añadir una skin allí como si fuera un arma más potente.

### 2.1 Qué hay hoy realmente

| Elemento actual | Ruta exacta | Cómo funciona |
|---|---|---|
| Puntas de gancho | `ReplicatedStorage.HookCosmeticAssets.HookTips.default`, `.spike`, `.heavy` | Models con PrimaryPart; servidor clona la punta elegida |
| Catálogo de puntas | `ReplicatedStorage.Shared.Config` → `Config.HookTipCosmetics` | IDs, nombre, coste en monedas y datos visuales |
| Cuerdas | Config.HookRopeCosmetics + `ReplicatedStorage.HookCosmeticAssets.RopeSkins.Generic` | Beam replicado y renderer 3D local genérico; no cambia física ni propiedad |
| Visual del gancho | `ServerScriptService["HookVisualService.server"]` | Usa `HookTipCosmeticId` y `HookRopeCosmeticId` |
| Armas actuales (contrastado 26/10) | `ReplicatedStorage.WeaponAssets.Templates.blaster`, `.rifle`, `.cannon` y `ServerScriptService.WeaponVisualService` | SDR-Mk2 gratuita, Rifle SMG y Cañón láser replicados. Cañón por pase en Lobby; Rifle sin pase conectado. Grip de Rifle difiere entre Places (B24); montaje/QA en DISENO |
| Inventario/compra | `ServerScriptService.InventoryService`, `ServerScriptService["WorkshopService.server"]` | Integración existente de propiedad/equipado y compras con monedas |
| Datos persistentes | `ServerScriptService["DataService.server"]` | Debe ampliarse para las categorías nuevas |

Los nombres con punto final `.client`/`.server` son parte del nombre de instancia;
en Luau usar corchetes como arriba, no interpretarlos como una carpeta hija.

### 2.2 Rutas de entrega propuestas — POR CREAR / CONECTAR

Base local propuesta: `C:\Users\Usuario\Desktop\experiencias\mcp\docs\assets\cosmetics\`.
Usar **estos nombres exactos** y conservar el ID al reemplazar su arte.

| ID | Archivo fuente propuesto | Destino exacto propuesto en Studio |
|---|---|---|
| avatar_aurora | `avatars/avatar_aurora.fbx` | `ReplicatedStorage.CosmeticAssets.Avatars.avatar_aurora` |
| avatar_plasma | `avatars/avatar_plasma.fbx` | `ReplicatedStorage.CosmeticAssets.Avatars.avatar_plasma` |
| avatar_solar | `avatars/avatar_solar.fbx` | `ReplicatedStorage.CosmeticAssets.Avatars.avatar_solar` |
| hook_aurora | `hooks/hook_aurora.fbx` | `ReplicatedStorage.HookCosmeticAssets.HookTips.hook_aurora` |
| hook_plasma | `hooks/hook_plasma.fbx` | `ReplicatedStorage.HookCosmeticAssets.HookTips.hook_plasma` |
| hook_solar | `hooks/hook_solar.fbx` | `ReplicatedStorage.HookCosmeticAssets.HookTips.hook_solar` |
| weapon_aurora | `weapons/weapon_aurora.fbx` | `ReplicatedStorage.CosmeticAssets.Weapons.weapon_aurora` |
| weapon_plasma | `weapons/weapon_plasma.fbx` | `ReplicatedStorage.CosmeticAssets.Weapons.weapon_plasma` |
| weapon_solar | `weapons/weapon_solar.fbx` | `ReplicatedStorage.CosmeticAssets.Weapons.weapon_solar` |

Los `.fbx` son fuentes del artista. Después de validar el modelo en Studio,
guardar también un `.rbxm` con el mismo nombre, para conservar Attachments,
welds y propiedades en un reemplazo futuro. No son archivos que el juego lea de Windows.

### Especificaciones de entrega del proyecto

- **Miniatura por skin:** `previews/<id>.png`, 512×512 RGBA, dibujo centrado con
  margen; destino propuesto `ReplicatedStorage.UIAssets.CosmeticPreviews.<id>`
  como ImageLabel con Fit. Los nueve ImageLabels están por crear.
- **Texturas:** `<id>_color.png`, preferentemente 1024×1024. Si hay PBR, entregar
  también mapas normal/roughness/metalness alineados al mismo UV. En Studio
  reemplazar las propiedades de `SurfaceAppearance` de la malla correspondiente.
  1024×1024 es una recomendación de este proyecto, no un requisito universal de Roblox.
- **Personaje:** ajustar accesorios/ropa a un R15 de referencia, sin sustituir el
  Humanoid, rig o colisiones de combate. Definir primero qué piezas cosméticas
  forman la skin. No existe una medida única en studs válida para toda la ropa.
- **Punta de gancho nueva:** Model con `PrimaryPart=Handle`; largo orientado al
  eje Z, tamaño visual objetivo 0.9–1.2 studs de largo y 0.3–0.45 de ancho/alto.
  Piezas sin colisión, sin scripts y sin alterar la geometría de gameplay.
- **Arma nueva:** Model con `PrimaryPart=Handle`, Attachment `Grip` para montaje y
  Attachment `Muzzle` en la boca. Mantener aproximadamente la envolvente del
  blaster actual (unos 0.6×0.6×2 studs para referencia), y medirla en la mano R15.
  Piezas unidas, sin colisión, Massless y no ancladas al equiparlas. Los nombres
   `Handle/Grip` y `Barrel/Muzzle` ya son el contrato de WeaponVisualService en las
   tres plantillas actuales; no añadir otro constructor local del arma.

**Hallazgo útil:** los bounds actuales de `default` y `heavy` son aproximadamente
16×6.4×16 y 7.57×8.05×9.77 studs; `spike` sí mide 0.3×0.3×1.2. No asumir que todas
las plantillas existentes ya están normalizadas. Revisar tamaño/pivote de cada
reemplazo en una escena de prueba antes de sustituirlo; no se reescalaron en esta tarea.

### 2.3 Cargar o sustituir un modelo

1. Importar FBX con **3D Importer** de Studio; revisar escala, orientación y materiales.
2. Armar y nombrar Model, PrimaryPart, Attachments y uniones según la ficha anterior.
3. Probarlo al lado del avatar, en mano o como punta, antes de copiarlo a su carpeta.
4. Copiarlo a la ruta exacta de la tabla. Para reemplazar: guardar copia del anterior,
   retirar el viejo y dejar un único Model con **el mismo ID/nombre**.
5. Repetir en Match. Guardar fuente y RBXM con el mismo ID.
6. Reaparecer/reequipar/relanzar gancho para obtener clones nuevos. Un clon ya
   existente en Workspace no se actualiza al editar la plantilla.

**Importante para nuevos IDs:** pegar un modelo no lo agrega al inventario ni lo
pone a la venta. En ganchos hay que registrarlo en el catálogo y conceder su
propiedad. Las skins de personaje/arma requieren además el sistema siguiente.

### 2.4 Conexión técnica pendiente antes de cobrar

Proponer `ReplicatedStorage.CosmeticCatalog` con carpetas `Avatars`, `Hooks`,
`Weapons`; cada ID será un **Configuration** editable con atributos `DisplayName`,
`AssetPath`, `PassKey` y `Enabled`. Esta carpeta está POR CREAR.

- Ampliar DataService/InventoryService con propiedad y selección de skins,
  conservando los campos actuales de puntas/cuerdas.
- Añadir `ServerScriptService.CosmeticEntitlementService` para resolver derechos.
- Añadir `ServerScriptService.CosmeticVisualService` para clonar visuales y hacer
  que otros jugadores vean las skins. Desde el 09/10 el arma base ya se replica con
  WeaponVisualService; reutilizar ese montaje para futuras skins de armas, evitando
  un segundo productor del modelo. Personaje y derechos premium siguen pendientes.
- Ampliar WeaponVisualService para resolver la skin autorizada sin duplicar arma ni
  Muzzle; no reactivar el constructor procedural WeaponSetup.client.
- Integrar `weaponSkin`/`avatarSkin` en inventario y servidor; revisar permisos de
  cambio durante batalla y no rellenar energía al equipar.
- No registrar skins premium como `cost=0` en WorkshopBuy sin validar su derecho:
  eso permitiría obtenerlas gratis por el flujo de compra con monedas.

## 3. Tres pases de packs: crear, configurar y aplicar

**Implementado antes de los packs — pase por arma (2026-10-16):** en lugar de un
IntValue en `ReplicatedStorage.Monetization.Passes`, cada arma usa su entrada en
`ReplicatedStorage.WeaponOffers.<id>` con `SaleMode=GamePass`, `PassId` y
`PurchaseIntegrationReady`. `ServerScriptService.MonetizationService` resuelve el
derecho y conserva `profile.passes`. El Cañón ya está conectado (pase `2039918698`).
Los packs Aurora/Plasma/Solar de abajo siguen siendo una propuesta diferente: si se
crean, reutilizar este servicio y catálogo en vez de duplicar la lógica de pases.

**Sugerencia:** un pase permanente por colección:

| Pase | Contenido | IntValue propuesto en Studio — POR CREAR |
|---|---|---|
| Pack Aurora | avatar_aurora + hook_aurora + weapon_aurora | `ReplicatedStorage.Monetization.Passes.PackAurora` |
| Pack Plasma | avatar_plasma + hook_plasma + weapon_plasma | `ReplicatedStorage.Monetization.Passes.PackPlasma` |
| Pack Solar | avatar_solar + hook_solar + weapon_solar | `ReplicatedStorage.Monetization.Passes.PackSolar` |

**Pase:** compra de una vez, derecho permanente dentro del juego. No es un accesorio
del inventario global. Precio a decidir; no hay IDs ni precios finales asignados.

### Crear en Creator Dashboard

1. Publicar y hacer accesible la experiencia.
2. **Creator Dashboard → Creations → este juego → Monetization → Passes → Create pass**.
3. Subir icono de hasta 512×512; usar `pass_pack_aurora.png`, `pass_pack_plasma.png`
   o `pass_pack_solar.png`, con información importante dentro del recorte circular.
4. Poner nombre, descripción exacta del contenido y categoría; crear.
5. En el pase, **Sales → Item for Sale**, fijar precio y guardar.
6. En la lista de pases, **⋯ → Copy Asset ID**. Es el **Pass ID**, no el ID de su imagen.
7. Crear las carpetas/IntValues de la tabla y pegar ese ID en **Value**, en ambos Places.
   Son pases de la misma experiencia: no crear un pase distinto para Match.

### Aplicación dentro del juego — POR IMPLEMENTAR

- UI propuesta: `StarterGui.ZB_PremiumShop.Panel.Packs.PackAurora.BuyButton` y
  equivalentes Plasma/Solar; botón → `MarketplaceService:PromptGamePassPurchase`.
- Controlador propuesto: `StarterPlayer.StarterPlayerScripts.PremiumShopController`.
- Mostrar nombre/precio real con `GetProductInfoAsync(id, Enum.InfoType.GamePass)`
  en cliente; no fijar un precio de texto que ignore precios regionales.
- Servidor propuesto: `ServerScriptService.MonetizationService`. En PlayerAdded,
  consultar `UserOwnsGamePassAsync`; manejar errores sin conceder por defecto.
- Escuchar `PromptGamePassPurchaseFinished` en servidor y resolver el derecho tras
  compra. Conceder el conjunto de skins de forma idempotente; ya poseer el pase
  debe recuperar el contenido al reconectar o llegar al otro Place.
- El cliente nunca envía «ya pagué» como prueba. La UI solo solicita mostrar el prompt.

Cambiar la miniatura del pase se hace en **Dashboard**; cambiar el dibujo de la
skin se hace en su **Model** de Studio. No crear un pase nuevo solo para cambiar
el arte: los compradores anteriores deben conservar el derecho.

## 4. Productos de desarrollador: compras repetibles

Usar un producto para un paquete de monedas u otro consumible repetible.
No usarlo como primera opción para una skin permanente que solo debe comprarse una vez.

### Creación

1. **Dashboard → Creations → juego → Monetization → Developer Products → Create developer product**.
2. Ejemplo propuesto: `Monedas100`; icono `product_monedas100.png`, hasta 512×512,
   nombre/descripcion claros, categoría y precio decidido por el equipo.
3. Guardar y copiar **Developer Product ID** desde ⋯. No confundirlo con Pass ID.
4. Ruta propuesta: **`ReplicatedStorage.Monetization.Products.Monedas100`**, IntValue;
   pegar Product ID en **Value**. Mismo valor en Lobby y Match.
5. UI propuesta: `StarterGui.ZB_PremiumShop.Panel.Products.Monedas100.BuyButton`;
   solicitar `PromptProductPurchase` y mostrar precio con
   `GetProductInfoAsync(id, Enum.InfoType.Product)`.

### Entrega autoritativa obligatoria — POR IMPLEMENTAR

Un único **`ServerScriptService.MonetizationService`** debe registrar
`MarketplaceService.ProcessReceipt` y despachar todos los ProductId admitidos,
también los usados como recompensas publicitarias.

1. Validar ProductId permitido, PlayerId, perfil disponible y PurchaseId del recibo.
2. Si PurchaseId ya está aplicado, devolver `PurchaseGranted` sin volver a entregar.
3. Guardar **recompensa y PurchaseId aplicado de manera atómica en el perfil**, a
   través de DataService y su mecanismo de bloqueo/guardado. No sumar primero a
   leaderstats y escribir después un marcador independiente.
4. La operación persistente debe ser idempotente ante reintentos y dos servidores.
   Si se usa UpdateAsync, su callback puede repetirse: no emitir efectos externos
   dentro de él ni sumar otra vez fuera de la transacción.
5. Solo después de confirmar el guardado/entrega devolver `PurchaseGranted`.
   Si falta jugador/perfil o falla el guardado, devolver `NotProcessedYet`.
6. No entregar por `PromptProductPurchaseFinished`, cerrar el prompt o un RemoteEvent
   del cliente. Eso no confirma una compra.
7. Mantener handlers de productos retirados de venta para cumplir recibos pendientes.

Ambos Places necesitan la misma lógica de recibos, aunque se venda principalmente
desde Lobby. Crear el producto en Dashboard sin completar este flujo no entrega nada.

**Pruebas:** compra, cancelación, recibo duplicado, fallo de guardado, salida antes
de respuesta, reconexión, teleport y producto retirado con recibo pendiente.
El modo de prueba de compras **externas** del Dashboard consume Robux reales según
la documentación; no confundirlo con una simulación gratuita de Studio.

## 5. Videos propios: cargar y reemplazar desde Properties

Esto sirve para un tráiler o tutorial. **Un VideoFrame con nuestro MP4 no genera
ingresos publicitarios automáticamente.**

### Archivo y límites consultados

- Entrega propuesta: `docs/assets/media/zb_lobby_trailer.mp4`, **1920×1080, 16:9**,
  15–30 segundos como recomendación del proyecto.
- Roblox documenta MP4/MOV, hasta **5 minutos**, resolución hasta **4096×2160**,
  menos de **3.75 GB**, sin alfa; máximo 20 subidas/día.
- La guía consultada indica usuario 13+ con ID verificada, opción **File → Beta
  Features → Video Uploads**, y **2.000 Robux por subida**. Comprobar disponibilidad
  y cargo actual antes de confirmar: estas condiciones pueden cambiar.

### Pantalla del Lobby — POR CREAR

```text
Workspace
└─ MediaScreens (Folder)
   └─ LobbyTrailer (Part, Anchored=true, Size=16,9,1)
      └─ SurfaceGui
         └─ Video (VideoFrame)
```

1. Importar el archivo desde Asset Manager o **Dashboard → Creations → Video**;
   revisar permisos de uso de la experiencia y moderación.
2. Crear el árbol anterior; orientar la cara del Part al público y elegir esa
   misma cara en `SurfaceGui.Face`.
3. Seleccionar `Workspace.MediaScreens.LobbyTrailer.SurfaceGui.Video`.
4. En Properties: **Video = `rbxassetid://ID_DEL_VIDEO`**, Size `{1,0},{1,0}`,
   Looped=true, Playing=true; Volume bajo o 0 según diseño.
5. Mantener la superficie a 16:9 para no estirar la imagen. Roblox documenta como
   máximo dos videos reproduciéndose simultáneamente: empezar con uno.
6. Probar carga/sonido en Player. Para sustituir: subir el nuevo archivo y cambiar
   **la propiedad Video del mismo objeto**. No rehacer el cartel.

Para video dentro de un menú, el destino alternativo propuesto es
`StarterGui.ZB_Media.Panel.Video`, también VideoFrame, con un botón de cierre.
Si solo existe en Lobby, no hace falta copiar la pantalla al Match.

## 6. Publicidad: tres casos distintos

### A. Pagar publicidad para traer jugadores

1. Ir a **https://create.roblox.com/advertise** y seleccionar la cuenta/grupo correcto.
2. Crear cuenta publicitaria y configurar facturación/créditos según elegibilidad.
3. **Manage Ads → Create Campaign**: seleccionar el juego, objetivo, audiencia,
   presupuesto diario o total y duración.
4. Creativo sugerido `docs/assets/media/ad_zero_breach_01.png`, **1920×1080, 16:9**.
   Subirlo en **Asset library → Add asset** o elegir una miniatura existente.
5. Destino: Lobby, **Start Place ID 125075465377023**, no el Match reservado que
   requiere TeleportData válido.
6. Revisar presupuesto antes de publicar. Medir coste por jugador, retención y
   conversión; una campaña gasta dinero, no es ingreso por sí sola.

No hay una ruta de Workspace que editar para esta campaña: se administra en la web.

### B. Cobrar por anuncios inmersivos dentro del Lobby

Ruta propuesta: **`Workspace.Advertising.LobbyBillboard.AdGui`** — POR CREAR.

1. **Dashboard → juego → Monetization → Ads → Eligibility/Settings**: comprobar
   elegibilidad del propietario y la experiencia.
2. La guía vigente pide experiencia pública, cuestionario revisado, 2.000 visitantes
   únicos mensuales; propietario 13+, ID verificada y 2FA, entre otros requisitos.
   No se comprobó que esta cuenta/experiencia cumpla los requisitos.
3. Crear Folder `Advertising`, Part `LobbyBillboard` anclado y un **AdGui** hijo.
4. Tamaño válido documentado de la superficie: entre **8×4.5 y 32×18 studs**.
   Elegir **16×9** y configurar `AdGui.Face`; activar `EnableVideoAds` si corresponde.
5. No poner otro AdGui/SurfaceGui en la misma cara. Roblox sirve el contenido;
   no hay que pegar el ID de un MP4 de un anunciante.
6. Conservar el fallback para usuarios sin anuncio/no elegibles. Elegibilidad
   no garantiza que haya un anuncio disponible ni ingresos fijos.

### C. «Ver un anuncio para recibir una recompensa»

**Rewarded video**, voluntario y solo en zona segura del Lobby. No interrumpir VS.

Rutas propuestas — todas POR CREAR:

- Botón: `StarterGui.ZB_PremiumShop.Panel.RewardedAdButton`.
- Producto recompensa: `ReplicatedStorage.Monetization.Products.AdRewardCoins` (IntValue).
- Solicitud: `ReplicatedStorage.RemoteEvents.RequestRewardedAd`.
- Servidor: `ServerScriptService.RewardedAdsService`.
- Entrega: el **mismo** `ServerScriptService.MonetizationService.ProcessReceipt`.

Pasos:
1. En **Monetization → Ads → Settings → Rewarded Video**, habilitar Serving si la
   experiencia es elegible. Elegir un developer product de **esta misma experiencia**.
2. Recompensa sugerida: cantidad fija y moderada de monedas; mostrar exactamente
   qué recibe el usuario. No Robux ni recompensa aleatoria.
3. Al abrir el menú, cliente consulta
   `AdService:GetAdAvailabilityNowAsync(Enum.AdFormat.RewardedVideo)`; ocultar o
   deshabilitar el botón cuando no haya disponibilidad o falle la consulta.
4. Al pulsar, servidor valida Lobby, jugador vivo/seguro, ausencia de otra solicitud
   y límites antirrepetición; cliente no elige el ProductId.
5. Servidor crea recompensa con `CreateAdRewardFromDevProductId` y solicita
   `ShowRewardedVideoAdAsync(player, reward)`.
6. **Entregar por ProcessReceipt**, no por un temporizador, VideoFrame.Ended ni un
   mensaje del cliente. Un recibo repetido no debe duplicar monedas.
7. Confirmar cancelación, falta de anuncios y fallos sin bloquear el juego.

Según la guía actual, la recompensa debe ser un producto que normalmente pueda
comprarse con Robux dentro del juego. No habilitarlo hasta completar el procesador.

## 7. Regalar algo que quede en el perfil/inventario general de Roblox

### La distinción que evita prometer algo que el juego no puede entregar

| Qué se entrega | ¿Queda como objeto global equipable? | Vía |
|---|---|---|
| Mochila Model/Accessory clonada en el personaje del juego | **No** | Solo visual dentro de esta experiencia |
| Skin comprada por pase o monedas del juego | **No** | Derecho guardado por nuestro juego |
| Mochila publicada como accesorio de avatar en Marketplace y adquirida | **Sí** | Transacción oficial de Roblox |
| PNG/Decal de una pegatina | **No, no por sí solo** | Imagen del juego; para vestirla convertirla en artículo de avatar admitido |
| Animación reproducida o emote añadido al HumanoidDescription del juego | **No** | No concede propiedad global |
| Emote publicado como Avatar Item y adquirido en Marketplace | **Sí** | Publicación y transacción oficial |
| Insignia / Badge | Aparece en la colección de insignias, **no es un accesorio** | BadgeService |

`Humanoid:AddAccessory`, poner un objeto en Backpack, guardar un DataStore o
usar un AnimationId **no escribe el inventario global** del usuario.
No existe un permiso general de nuestro servidor para regalar arbitrariamente
cualquier asset de Marketplace a cualquier cuenta.

### 7.1 Regalo concreto recomendado: mochila UGC Limited gratuita

**Propuesto:** `ZB Explorer Backpack`. Esta es una publicación independiente de la
imagen del botón de mochila y de las skins internas del juego.

Fuentes propuestas: `docs/assets/avatar/backpack_explorer.fbx`, texturas
`backpack_explorer_color.png` de 1024×1024 como recomendación inicial.
Objeto de trabajo propuesto: **`ServerStorage.AvatarPublish.BackpackExplorer`**,
un **Accessory** ajustado al cuerpo con Accessory Fitting Tool. Esta ruta no existe aún.

1. Modelar y ajustar el accesorio de espalda al R15; validar mesh, attachment,
   tamaño y requisitos oficiales de accesorios. Una imagen de mochila no basta.
2. Verificar requisitos del creador Marketplace. La documentación consultada
   exige verificación ID o parental admitida; para publicación, 2FA y membresía
   Roblox Plus o Premium 1000/2200 del creador/propietario del grupo, además de cargos.
3. Publicar mediante **Save to Roblox → Avatar Item**, categoría de espalda
   correspondiente; superar validación y moderación.
4. En Marketplace settings, si esta categoría admite esa modalidad, elegir
   **Limited → Free Item**, cantidad y límite por usuario. Las categorías
   Non-Limited documentadas no permiten simplemente poner precio cero.
5. **Gratis para el jugador no significa gratis para nosotros:** los Limited
   gratuitos tienen coste por unidad financiado por el creador, además de los
   cargos aplicables. Confirmar el importe actual en Dashboard y presupuestar
   cantidad antes de publicar. No se efectuó ninguna subida ni gasto.
6. Si se quiere reclamar exclusivamente desde el juego, configurar **Sale Location
   → Experience By Place ID (API Only)** con el Start Place ID del Lobby.
7. En el juego: **Dashboard → Monetization → Avatar Items**, buscar el AssetId y
   habilitar su venta/reclamación cuando corresponda. Si dueño del objeto y del
   juego coinciden, Roblox puede añadirlo automáticamente; verificarlo.
8. Guardar el AssetId en la ruta propuesta
   **`ReplicatedStorage.Monetization.AvatarRewards.BackpackExplorer`**, IntValue.
9. Botón propuesto: `StarterGui.ZB_Rewards.Panel.ClaimBackpack`. Solicitud al
   servidor propuesto `ServerScriptService.AvatarRewardService`; validar el logro
   o condición real del usuario, propiedad y disponibilidad. No aceptar un ID libre del cliente.
10. Consultar los datos actuales del artículo; solo presentar la reclamación
    gratuita cuando tenga unidades originales disponibles y precio cero.
    Si se agotó, mostrar AGOTADO: no caer silenciosamente en una compra de reventa paga.
11. Desde servidor, mostrar **`MarketplaceService:PromptPurchase(player, assetId)`**;
    API-only exige servidor. El usuario confirma la transacción oficial de Roblox.
12. Después verificar propiedad con `PlayerOwnsAssetAsync` y permitir equipar el
    artículo. Comprobar también el inventario en la web/Avatar Editor y en otra
    experiencia que admita ese accesorio. No prometer que todo juego permite vestirlo.

La condición de reclamación autoriza **mostrar el prompt**; no elimina las
restricciones de Marketplace, stock o confirmación del usuario.

### 7.2 Pegatina

- Si se quiere una pegatina dentro de ZERO BREACH: usar una imagen/decal y guardar
  el desbloqueo; no presentarla como premio global.
- Para llevar el diseño fuera del juego, diseñar un **artículo de avatar admitido**:
  por ejemplo un accesorio/parche o prenda con ese gráfico. Publicarlo/adquirirlo
  por su categoría real y comprobar sus reglas de precio y distribución.
- Un PNG de 512×512 llamado `sticker_zero_breach.png` no se convierte por sí solo
  en un objeto global equipable. Una Badge es otra alternativa para un recuerdo
  en el perfil, pero debe anunciarse como insignia, no como pegatina/accesorio.

### 7.3 Emote global

1. Fuente propuesta `docs/assets/avatar/emote_zero_salute.fbx` o animación creada
   en Animation Editor sobre un R15 estándar; cumplir especificaciones de emotes.
2. Importar/crear, convertir a **CurveAnimation** con Curve Editor y publicar la
   animación. Crear un objeto **Animation** y poner ese ID en `AnimationId`.
3. Guardar el objeto de trabajo propuesto en
   **`ServerStorage.AvatarPublish.ZeroSalute`**.
4. **Save to Roblox → Content Type: Avatar Item → Asset Category: Emote**.
   Superar moderación y cargos. Publicar una animación normal no es este paso.
5. Usar el **AssetId del artículo de emote publicado**, no confundirlo con el
   AnimationId interno. Ruta propuesta:
   `ReplicatedStorage.Monetization.AvatarRewards.ZeroSalute` (IntValue).
6. Conectar un prompt oficial de adquisición y verificar propiedad global.
   **No asumir que la categoría Emote permite Free Limited/precio cero**: comprobar
   las opciones vigentes de esa categoría. Si no permite distribución gratuita,
   no podemos convertirlo en regalo global mediante un script local.

Para un regalo gratuito concreto, priorizar el accesorio Limited admitido y
presupuestado. Un pase pagado del juego no debe prometer un emote global gratis
si aún no existe una vía de entrega aprobada para ese artículo.

### Sustituir un regalo publicado

La guía de Marketplace indica que la geometría/miniatura de assets ya subidos
no se edita como un Model local: un nuevo diseño puede requerir **nuevo asset y
nuevo ID**, nueva revisión y cargos. Cambiar nuestro IntValue afecta futuras
reclamaciones; no transforma automáticamente los objetos que ya poseen usuarios.
Conservar un registro del ID anterior y del nuevo.

## 8. Ficha para cada paso futuro

Copiar esta ficha debajo cuando se empiece un trabajo:

```text
Tema / ID estable:
Estado: propuesta | preparado | conectado | probado Studio | publicado | probado Player
Responsable / fecha:
Archivo local exacto y medidas:
Ruta exacta en Studio y clase:
Propiedad que se cambia:
AssetId / PassId / ProductId (indicar cuál):
Propietario cuenta/grupo:
Place(s) afectados:
Pasos pendientes:
Prueba de compra/reclamación y de reconexión:
ID o copia para volver atrás:
Cargos/presupuesto aprobados, si corresponde:
```

## 9. Documentación oficial consultada

Consultada el 2026-10-06. Revalidar requisitos, precios/cargos y opciones del
Dashboard al ejecutar cada tarea; no asumir que se mantienen indefinidamente.

- [Pases](https://create.roblox.com/docs/production/monetization/passes)
- [Developer products y recibos](https://create.roblox.com/docs/production/monetization/developer-products)
- [MarketplaceService: compras, propiedad y GetProductInfoAsync](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService)
- [Videos: subida, límites y VideoFrame](https://create.roblox.com/docs/ui/video-frames)
- [Ads Manager](https://create.roblox.com/docs/production/promotion/ads-manager)
- [Anuncios inmersivos](https://create.roblox.com/docs/production/monetization/immersive-ads)
- [Rewarded video ads](https://create.roblox.com/docs/production/promotion/rewarded-video-ads)
- [Venta de avatar items en una experiencia](https://create.roblox.com/docs/production/monetization/avatar-items)
- [Publicación Marketplace y Free Limited](https://create.roblox.com/docs/marketplace/publish-to-marketplace)
- [Requisitos del creador](https://create.roblox.com/docs/marketplace/marketplace-policy)
- [Cargos y comisiones](https://create.roblox.com/docs/marketplace/marketplace-fees-and-commissions)
- [Emotes](https://create.roblox.com/docs/avatar/emotes)
- [Importar y publicar emotes](https://create.roblox.com/docs/avatar/emotes/import)
