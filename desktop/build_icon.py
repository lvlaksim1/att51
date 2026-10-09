"""Create reproducible multi-resolution Att51_export Windows icon.

Visual identity: blue rounded application tile, white document, green
up-arrow showing the preparation of a structured XML export.
Build-time only, requires Pillow; app itself does not generate icon files.
"""
from __future__ import annotations
from pathlib import Path
import sys

from PIL import Image, ImageDraw, ImageFont

S = 1024


def font(size: int, bold: bool = True):
    candidates = [
        "C:/Windows/Fonts/segoeuib.ttf" if bold else "C:/Windows/Fonts/segoeui.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    ]
    for p in candidates:
        if Path(p).is_file():
            return ImageFont.truetype(p, size)
    return ImageFont.load_default()


def build():
    image = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    pix = image.load()
    # Subtle navy-to-blue gradient; rounded mask keeps transparency outside.
    gradient = Image.new("RGBA", (S, S))
    gp = gradient.load()
    for y in range(S):
        for x in range(S):
            shade = max(0.0, min(1.0, (x + 1.4 * y) / (2.4 * S)))
            gp[x, y] = (
                int(16 + 26 * shade),
                int(88 + 50 * shade),
                int(154 + 45 * shade),
                255,
            )
    mask = Image.new("L", (S, S), 0)
    md = ImageDraw.Draw(mask)
    md.rounded_rectangle((48, 48, 976, 976), radius=194, fill=255)
    image.paste(gradient, (0, 0), mask)
    d = ImageDraw.Draw(image)
    # Highlighted frame.
    d.rounded_rectangle((56, 56, 968, 968), radius=188,
                        outline=(153, 207, 254, 110), width=10)
    # Document white body, with folded top-right corner.
    d.polygon([(250, 176), (625, 176), (778, 330),
               (778, 755), (250, 755)], fill=(248, 252, 255, 255))
    d.polygon([(625, 176), (625, 330), (778, 330)], fill=(175, 216, 244, 255))
    d.line([(625, 177), (625, 330), (778, 330)], fill=(82, 151, 208), width=8)
    for y, width in ((374, 366), (455, 344), (536, 286)):
        d.rounded_rectangle((332, y, 332 + width, y + 25), radius=8,
                            fill=(36, 102, 169))
    # Distinct EXPORT ribbon at bottom of document.
    d.rounded_rectangle((165, 672, 684, 871), radius=37, fill=(19, 105, 196))
    d.rounded_rectangle((171, 681, 678, 860), radius=31,
                        outline=(129, 206, 255, 255), width=8)
    d.text((194, 720), "EXPORT", font=font(79), fill=(255, 255, 255))
    # Green export/up arrow, offset to lower right.
    d.polygon([(754, 559), (875, 432), (987, 558),
               (921, 558), (921, 840), (821, 840),
               (821, 558)], fill=(73, 198, 75))
    d.line([(754, 559), (875, 432), (987, 558)], fill=(210, 248, 151), width=12)
    return image


if __name__ == "__main__":
    output = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("build/app.ico")
    output.parent.mkdir(parents=True, exist_ok=True)
    image = build()
    image.save(str(output), format="ICO", sizes=[(16, 16), (24, 24), (32, 32),
              (48, 48), (64, 64), (128, 128), (256, 256)])
    print(f"ICON_OK {output} {output.stat().st_size} bytes")
