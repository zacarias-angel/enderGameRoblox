"""Split the supplied laser sheet into transparent catalog icons."""
import json
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw


def main():
    output = Path(__file__).resolve().parent
    source = next(output.parent.glob("*seres*.png"))
    sheet = Image.open(source).convert("RGBA")
    report = {"source": source.name, "images": []}
    for index, color_id in enumerate(("cyan", "green", "gold", "purple")):
        left = round(index * sheet.width / 4)
        right = round((index + 1) * sheet.width / 4)
        tile = sheet.crop((left, 0, right, sheet.height))
        gold = []
        for position, (r, g, b, a) in enumerate(tile.getdata()):
            if a > 32 and r > 180 and g > 90 and b < 110 and b < g * 0.5:
                gold.append((position % tile.width, position // tile.width))
        if not gold:
            raise ValueError(f"No frame found for {color_id}")
        x0, x1 = min(p[0] for p in gold), max(p[0] for p in gold)
        y0, y1 = min(p[1] for p in gold), max(p[1] for p in gold)
        corner = round(min(x1 - x0, y1 - y0) * 0.075)
        mask = Image.new("L", tile.size, 0)
        ImageDraw.Draw(mask).polygon(
            [(x0 + corner, y0), (x1 - corner, y0), (x1, y0 + corner),
             (x1, y1 - corner), (x1 - corner, y1), (x0 + corner, y1),
             (x0, y1 - corner), (x0, y0 + corner)], fill=255)
        tile.putalpha(ImageChops.darker(tile.getchannel("A"), mask))
        tile = tile.crop((x0, y0, x1 + 1, y1 + 1))
        tile.thumbnail((496, 496), Image.Resampling.LANCZOS)
        canvas = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
        canvas.alpha_composite(tile, ((512 - tile.width) // 2, (512 - tile.height) // 2))
        filename = f"laser_{color_id}.png"
        canvas.save(output / filename)
        report["images"].append({"id": color_id, "file": filename})
    (output / "laser_images_manifest.json").write_text(
        json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(report, ensure_ascii=True, indent=2))


if __name__ == "__main__":
    main()
