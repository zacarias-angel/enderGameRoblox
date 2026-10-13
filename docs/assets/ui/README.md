# Entrega de imágenes UI

Guía completa y catálogo: [../../UI_ASSETS.md](../../UI_ASSETS.md).

Integración del **13/10/2026**: esta carpeta contiene 28 PNG derivados de los tres
atlas entregados: 16 iconos, 8 estados de botones y 4 marcos.

- Iconos: 256×256 RGBA, dibujo dentro de 192×192, `ScaleType=Fit`.
- Botones: 512×352 RGBA, `ScaleType=Slice`; estados normal/hover/pressed/disabled.
- Marcos: ancho 512 y alto según pieza, `ScaleType=Slice`; damero exterior retirado.
- `atlas_manifest.json`: fuente, recorte, medidas y SliceCenter.
- `roblox_asset_ids.json`: IDs activos, compartidos entre Lobby y Match.
- `atlas_preview.jpg`: referencia visual local, no recurso del juego.

Los Frames originales se conservan en `UIAssets.Icons.<clave>.Fallback` y los
estilos nativos sirven de respaldo. Los iconos no incluidos en el atlas siguen
usando sus trazos.

El juego clona el ImageLabel `ReplicatedStorage.UIAssets.Icons.<clave>` y usa su
propiedad `Image`, no este directorio. Después de importar cada PNG en Roblox,
seleccionar el ImageLabel y editar Image en Properties, en Lobby y Match.
Los fondos se editan en `ReplicatedStorage.UIAssets.Skins`. No usar Stretch ni
incluir textos en el PNG. La subida de imágenes no publica los Places.
