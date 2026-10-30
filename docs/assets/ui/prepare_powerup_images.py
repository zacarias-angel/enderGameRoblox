"""Prepare individual power-up PNGs; preserve originals and genuine alpha."""
import json
from collections import deque
from pathlib import Path

from PIL import Image


def prepare(source, target):
    image = Image.open(source).convert("RGBA")
    alpha = image.getchannel("A")
    original_alpha = alpha.getextrema()
    removed = 0
    # Only remove near-black background connected to the canvas border.
    # Never key dark blue pixels inside the actual object.
    if original_alpha == (255, 255):
        pixels = image.load()
        queue = deque()
        seen = set()
        for x in range(image.width):
            queue.extend(((x, 0), (x, image.height - 1)))
        for y in range(image.height):
            queue.extend(((0, y), (image.width - 1, y)))
        while queue:
            x, y = queue.popleft()
            if (x, y) in seen:
                continue
            seen.add((x, y))
            r, g, b, a = pixels[x, y]
            if max(r, g, b) > 24:
                continue
            pixels[x, y] = (r, g, b, 0)
            removed += 1
            for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                if 0 <= nx < image.width and 0 <= ny < image.height:
                    queue.append((nx, ny))
    bounds = image.getchannel("A").getbbox()
    if not bounds:
        raise ValueError(f"Empty image: {source}")
    image = image.crop(bounds)
    image.thumbnail((900, 900), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (1024, 1024))
    canvas.alpha_composite(image, ((1024 - image.width) // 2, (1024 - image.height) // 2))
    canvas.save(target)
    return {"source": source.name, "file": target.name,
            "original_alpha": original_alpha, "background_pixels_removed": removed,
            "alpha": canvas.getchannel("A").getextrema(), "size": canvas.size}


def main():
    folder = Path(__file__).resolve().parent
    files = (("escudo.png", "powerup_shield.png"),
             ("hieloneón.png", "powerup_fullfreeze.png"),
             ("Módulo_impulso.png", "powerup_boost.png"))
    result = [prepare(folder / source, folder / target) for source, target in files]
    (folder / "powerup_images_manifest.json").write_text(
        json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(result, ensure_ascii=True, indent=2))


if __name__ == "__main__":
    main()
