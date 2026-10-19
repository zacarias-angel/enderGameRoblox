"""Prepare the supplied red laser and spawn-protection banner for Roblox UI."""
import json
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw


def main():
    output = Path(__file__).resolve().parent
    red = Image.open(output.parent / "Láserrojo.png").convert("RGBA")
    gold = []
    for index, (r, g, b, a) in enumerate(red.getdata()):
        x, y = index % red.width, index // red.width
        # Ignore the decorative streaks above the actual card frame.
        if y >= red.height * 0.04 and a > 32 and r > 180 and g > 90 and b < 110 and b < g * 0.5:
            gold.append((x, y))
    x0, x1 = min(p[0] for p in gold), max(p[0] for p in gold)
    y0, y1 = min(p[1] for p in gold), max(p[1] for p in gold)
    corner = round(min(x1 - x0, y1 - y0) * 0.075)
    mask = Image.new("L", red.size, 0)
    ImageDraw.Draw(mask).polygon(
        [(x0 + corner, y0), (x1 - corner, y0), (x1, y0 + corner),
         (x1, y1 - corner), (x1 - corner, y1), (x0 + corner, y1),
         (x0, y1 - corner), (x0, y0 + corner)], fill=255)
    red.putalpha(ImageChops.darker(red.getchannel("A"), mask))
    red = red.crop((x0, y0, x1 + 1, y1 + 1))
    red.thumbnail((496, 496), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (512, 512))
    canvas.alpha_composite(red, ((512 - red.width) // 2, (512 - red.height) // 2))
    canvas.save(output / "laser_red.png")

    banner = Image.open(output.parent / "ui protegido.png").convert("RGBA")
    bounds = banner.getchannel("A").point(lambda a: 255 if a >= 8 else 0).getbbox()
    if not bounds:
        raise ValueError("Protection banner is empty")
    x0, y0, x1, y1 = bounds
    bounds = (max(0, x0 - 12), max(0, y0 - 12),
              min(banner.width, x1 + 12), min(banner.height, y1 + 12))
    banner = banner.crop(bounds)
    banner.thumbnail((1536, 512), Image.Resampling.LANCZOS)
    banner.save(output / "spawn_protection.png")
    report = {"laser_red": {"file": "laser_red.png", "size": [512, 512]},
              "spawn_protection": {"file": "spawn_protection.png", "size": list(banner.size), "crop": list(bounds)}}
    (output / "extra_ui_images_manifest.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
