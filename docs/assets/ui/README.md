# Entrega de imágenes UI

Guía completa y catálogo: [../../UI_ASSETS.md](../../UI_ASSETS.md).

Guardar aquí los futuros PNG individuales: `ui_bag.png`, `ui_shop.png`, etc.
Medidas: 256×256 RGBA; emblema 512×512. Fondo transparente y margen del 12.5%.

Actualmente los iconos tienen trazos nativos como Frames dentro de
`game.ReplicatedStorage.UIAssets.Icons.<clave>.Fallback`; no hay PNG individuales exportados ni
IDs individuales activos. Esta carpeta fija su ubicación de entrega.

El juego clona el ImageLabel `ReplicatedStorage.UIAssets.Icons.<clave>` y usa su
propiedad `Image`, no este directorio. Después de importar cada PNG en Roblox,
seleccionar el ImageLabel y editar Image en Properties, en Lobby y Match.
