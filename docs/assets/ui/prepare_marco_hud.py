"""Prepare MarcoHUD at an explicit Roblox texture size, preserving its aspect."""
import json
from pathlib import Path

from PIL import Image


def main():
    folder = Path(__file__).resolve().parent
    image = Image.open(folder / "MarcoHUD.png").convert("RGBA")
    original = list(image.size)
    image.thumbnail((1024, 1024), Image.Resampling.LANCZOS)
    image.save(folder / "marco_hud_roblox.png")
    # Keep the corner plates outside the four extensible edge regions.
    w, h = image.size
    report = {
        "source": "MarcoHUD.png",
        "originalSize": original,
        "file": "marco_hud_roblox.png",
        "size": [w, h],
        "sliceCenter": [round(w * .27), round(h * .27),
                        round(w * .73), round(h * .73)],
        "sliceScale": .12,
        "renderer": "UIFrameArtwork: proportional corner and edge details",
    }
    (folder / "marco_hud_manifest.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
