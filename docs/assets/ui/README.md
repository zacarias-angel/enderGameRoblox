# Entrega de imágenes UI

Guía completa y catálogo: [../../UI_ASSETS.md](../../UI_ASSETS.md).

## HUD nuevo — integración posterior del 26/10/2026

- `battle_weapon_bar.png` y `battle_hook_bar.png`, 496×120: marco/título del arma
  y gancho; el relleno sigue siendo dinámico en Roblox.
- `battle_general_frame_full.png`, 1024×341: marco original **completo**, sin recorte
  del lienzo, para accesos/estado/monedas/header VS. ID 138592401278319, Fit.
  `battle_general_frame.png` y su ID anterior son historial de la versión segmentada
  rechazada por el usuario; no son la fuente activa.
- `prepare_battle_hud.py`: preparación desde los tres originales en assets;
  `battle_hud_manifest.json`: recortes/geometría; `battle_hud_asset_ids.json`: IDs.
- Fuente editable en ambos Places: `ReplicatedStorage.UIAssets.BattleHud`.
  Este marco afecta al HUD de las referencias, no reemplaza los Artwork locales
  del panel interior de mochila del colaborador.
- QA Studio de ambos y simulador iPhone 17 Pro registrada en UI_ASSETS; sin publicar.

## Estado contrastado — 26/10/2026

- Lobby tiene mochila completa editable: `StarterGui.ZB_EquipmentDashboard.Panel`
  y `Templates.CatalogCard`. Sus Artwork locales usan `92094831612893`, navegación
  `99022357719006` y marcos de iconos `95844709202495`. Son IDs observados en Studio;
  no se identificaron aquí sus PNG fuente. Rutas detalladas en UI_ASSETS.
- Match mantiene su mochila anterior. Sus tres WeaponImages siguen con Image
  vacío; no se completó la sincronización descrita abajo.
- `roblox_asset_ids.json` registra la entrega original del atlas del 13/10,
  **no todo el catálogo vigente**: los cuatro paneles de UIAssets.Skins usan ahora
  `106613197873068`, documentado en `marco_hud_asset_ids.json` y
  `marco_hud_manifest.json`. La mochila nueva de Lobby usa su arte local distinto.
- `weapon_images_manifest.json` documenta los tres PNG de armas; otros manifiestos
  registran láseres, protección y manual. El manual actual usa la placa con texto
  incorporado y botón entero; la prohibición de texto de abajo es para iconos/skins.
- Rankings nuevos de Lobby: Workspace.Rankings3D, marco `92094831612893` y atlas
  `119594247613582`. No sustituir sus recortes por los de MarcoHUD.
- Esta revisión verificó propiedades en Edit; no acredita carga/permiso en Player
  ni una publicación nueva de los Places.

Integración del **13/10/2026**: entrega de 28 PNG derivados de los tres
atlas entregados: 16 iconos, 8 estados de botones y 4 marcos.

- Iconos: 256×256 RGBA, dibujo dentro de 192×192, `ScaleType=Fit`.
- Botones: 512×352 RGBA, `ScaleType=Slice`; estados normal/hover/pressed/disabled.
- Marcos: ancho 512 y alto según pieza, `ScaleType=Slice`; damero exterior retirado.
- `atlas_manifest.json`: fuente, recorte, medidas y SliceCenter.
- `roblox_asset_ids.json`: IDs de aquella entrega; contrastar sustituciones con el corte actual.
- `atlas_preview.jpg`: referencia visual local, no recurso del juego.

Agregado **16/10/2026**: `weapon_blaster.png`, `weapon_rifle.png` y
`weapon_cannon.png`, 512×512 RGBA, derivados de la imagen de armas neón del usuario.
Recortes/IDs en `weapon_images_manifest.json`; preparación reproducible con
`prepare_weapon_images.py`. Aplicados/probados en Lobby; sincronización a Match
pendiente. Se editan en `ReplicatedStorage.UIAssets.WeaponImages.<id>.Image`.

Los Frames originales se conservan en `UIAssets.Icons.<clave>.Fallback` y los
estilos nativos sirven de respaldo. Los iconos no incluidos en el atlas siguen
usando sus trazos.

El juego clona el ImageLabel `ReplicatedStorage.UIAssets.Icons.<clave>` y usa su
propiedad `Image`, no este directorio. Después de importar cada PNG en Roblox,
seleccionar el ImageLabel y editar Image en Properties, en Lobby y Match.
Los fondos se editan en `ReplicatedStorage.UIAssets.Skins`. No usar Stretch ni
incluir textos en el PNG. La subida de imágenes no publica los Places.
