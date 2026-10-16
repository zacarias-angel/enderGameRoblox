"""Split the supplied three-card weapon image into UI-ready PNGs."""

from pathlib import Path
import json

from PIL import Image


def main():
    output = Path(__file__).resolve().parent
    source = output.parent / "Íconos de armas futuristas en neón.png"
    image = Image.open(source).convert("RGBA")
    width, height = image.size
    result = {"source": source.name, "size": [width, height], "images": []}
    for index, weapon_id in enumerate(("blaster", "rifle", "cannon")):
        left = round(index * width / 3)
        right = round((index + 1) * width / 3)
        tile = image.crop((left, 0, right, height))
        pixels = list(tile.getdata())
        removed = 0
        for position, (red, green, blue, alpha) in enumerate(pixels):
            # Remove the saturated red matte around the gold/cyan card artwork.
            # The original source is retained intact.
            if alpha and red > 32 and green < red * 0.42 and blue < red * 0.42:
                pixels[position] = (red, green, blue, 0)
                removed += 1
        tile.putdata(pixels)
        tile.thumbnail((512, 512), Image.Resampling.LANCZOS)
        canvas = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
        canvas.alpha_composite(tile, ((512 - tile.width) // 2, (512 - tile.height) // 2))
        path = output / f"weapon_{weapon_id}.png"
        canvas.save(path)
        result["images"].append(
            {"weaponId": weapon_id, "file": path.name, "crop": [left, 0, right, height], "removedRedPixels": removed}
        )
    print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
