"""Split mechanical/volcanic claw art without erasing the volcanic red details."""
import json
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw


def main():
    output = Path(__file__).resolve().parent
    source = output.parent / "Íconos de Garra Mecánica y Volcánica.png"
    image = Image.open(source).convert("RGBA")
    width, height = image.size
    report = {"sourcePixels": [width, height], "images": []}
    for index, item in enumerate(("default", "heavy")):
        left, right = round(index * width / 2), round((index + 1) * width / 2)
        tile = image.crop((left, 0, right, height))
        # Locate the gold frame, then mask only its exterior. Never key out red:
        # the volcanic claw deliberately contains bright red cracks.
        gold = []
        for position, (red, green, blue, alpha) in enumerate(tile.getdata()):
            if alpha > 32 and red > 180 and green > 90 and blue < 110 and green > red * 0.38 and blue < green * 0.5:
                gold.append((position % tile.width, position // tile.width))
        if gold:
            x0, x1 = min(p[0] for p in gold), max(p[0] for p in gold)
            y0, y1 = min(p[1] for p in gold), max(p[1] for p in gold)
            corner = round(min(x1 - x0, y1 - y0) * 0.05)
            mask = Image.new("L", tile.size, 0)
            ImageDraw.Draw(mask).polygon(
                [(x0 + corner, y0), (x1 - corner, y0), (x1, y0 + corner),
                 (x1, y1 - corner), (x1 - corner, y1), (x0 + corner, y1),
                 (x0, y1 - corner), (x0, y0 + corner)], fill=255)
            tile.putalpha(ImageChops.darker(tile.getchannel("A"), mask))
        tile.thumbnail((512, 512), Image.Resampling.LANCZOS)
        canvas = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
        canvas.alpha_composite(tile, ((512 - tile.width) // 2, (512 - tile.height) // 2))
        name = f"hook_tip_{item}.png"
        canvas.save(output / name)
        report["images"].append({"id": item, "file": name, "crop": [left, 0, right, height]})
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
