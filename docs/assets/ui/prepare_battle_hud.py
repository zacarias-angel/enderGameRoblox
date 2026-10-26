"""Prepare the supplied battle HUD art without stretching or baking energy fills."""
import json
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw


def remove_red_matte(image):
    pixels = image.load()
    for y in range(image.height):
        for x in range(image.width):
            r, g, b, a = pixels[x, y]
            if r > 175 and g < 100 and b < 90 and r > g * 1.8:
                pixels[x, y] = (r, g, b, 0)


def main():
    output = Path(__file__).resolve().parent
    report = {}
    outline = [(30, 276), (80, 277), (99, 295), (466, 295),
               (494, 316), (494, 352), (476, 374), (97, 374),
               (82, 383), (26, 383), (10, 366), (10, 297)]
    for key, source in [('weapon', 'Barra arma.png'), ('hook', 'Barra gancho.png')]:
        image = Image.open(output.parent / source).convert('RGBA')
        mask = Image.new('L', image.size)
        ImageDraw.Draw(mask).polygon(outline, fill=255)
        image.putalpha(ImageChops.darker(image.getchannel('A'), mask))
        remove_red_matte(image)
        crop = (4, 270, 500, 390)
        image = image.crop(crop)
        filename = f'battle_{key}_bar.png'
        image.save(output / filename)
        report[key] = dict(source=source, file=filename, size=list(image.size),
                           crop=list(crop), fillRect=[109, 59, 465, 79],
                           iconRect=[23, 30, 83, 90])
    image = Image.open(output.parent / 'HUD GENERAL BATALLA.png').convert('RGBA')
    original_size = list(image.size)
    image.thumbnail((1024, 1024), Image.Resampling.LANCZOS)
    image.save(output / 'battle_general_frame_full.png')
    report['general'] = dict(source='HUD GENERAL BATALLA.png',
                              file='battle_general_frame_full.png', size=list(image.size),
                              originalSize=original_size, crop=None,
                              renderer='One complete ImageLabel, ScaleType.Fit; no slices or ImageRect crops')
    (output / 'battle_hud_manifest.json').write_text(
        json.dumps(report, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    print(json.dumps(report, indent=2, ensure_ascii=False))


if __name__ == '__main__':
    main()
