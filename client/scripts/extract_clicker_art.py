#!/usr/bin/env python3
"""Extract Savitar 1 Macro Clicker cicn art from Savitar.rsrc into PNGs for Savitar2."""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "pillow", "-q"])
    from PIL import Image

RSRC = Path(__file__).resolve().parents[2].parent / "savitar140/Resources/mac/Savitar.rsrc"
OUT_DIR = Path(__file__).resolve().parents[1] / "Savitar2/resources/ClickerArt"

# Grid: off/on pairs; compass and vertical use off=normal, on=pressed (inverted IDs).
ICONS: dict[str, tuple[int, int, int]] = {
    "north": (1451, 1450, 16),
    "northeast": (1491, 1490, 16),
    "east": (1471, 1470, 16),
    "southeast": (1501, 1500, 16),
    "south": (1461, 1460, 16),
    "southwest": (1511, 1510, 16),
    "west": (1481, 1480, 16),
    "northwest": (1521, 1520, 16),
    "up": (1531, 1530, 16),
    "down": (1541, 1540, 16),
    "1": (1290, 1291, 32),
    "2": (1300, 1301, 32),
    "3": (1310, 1311, 32),
    "4": (1320, 1321, 32),
    "5": (1330, 1331, 32),
    "6": (1340, 1341, 32),
    "7": (1350, 1351, 32),
    "8": (1360, 1361, 32),
    "9": (1370, 1371, 32),
    "a": (1380, 1381, 32),
    "b": (1390, 1391, 32),
    "c": (1400, 1401, 32),
    "d": (1410, 1411, 32),
    "e": (1420, 1421, 32),
    "f": (1430, 1431, 32),
}


def fetch(res_id: int) -> bytes:
    out = subprocess.check_output(
        ["DeRez", "-only", f"'cicn' ({res_id})", "-useDF", str(RSRC)],
        text=True,
        errors="replace",
    )
    chunks = re.findall(r'\$"([^"]+)"', out)
    hexstr = "".join(c.replace(" ", "") for c in chunks)
    return bytes.fromhex(hexstr)


def cicn_rgba(data: bytes, size: int) -> bytes | None:
    row_bytes = size // 8
    pix_len = row_bytes * size
    best: tuple[int, bytes] | None = None
    for off in range(0, len(data) - pix_len * 2):
        pix = data[off : off + pix_len]
        mask = data[off + pix_len : off + pix_len * 2]
        rgba = bytearray()
        for row in range(size):
            for col in range(size):
                bit = 1 << (7 - (col % 8))
                on = bool(pix[row * row_bytes + col // 8] & bit)
                masked = bool(mask[row * row_bytes + col // 8] & bit)
                if not masked:
                    rgba.extend([0, 0, 0, 0])
                elif on:
                    rgba.extend([0x66, 0x68, 0x92, 255])
                else:
                    rgba.extend([0xAB, 0xAE, 0xD8, 255])
        score = sum(1 for i in range(3, len(rgba), 4) if rgba[i] > 0)
        if score > 20 and (best is None or score > best[0]):
            best = (score, bytes(rgba))
    return best[1] if best else None


def recolor_grid(img: Image.Image) -> Image.Image:
    px = img.load()
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            if r < 80:
                px[x, y] = (12, 210, 20, 255)
            else:
                px[x, y] = (170, 230, 170, 255)
    return img


def save_pair(name: str, normal_id: int, pressed_id: int, size: int) -> None:
    for suffix, res_id in (("", normal_id), ("-pressed", pressed_id)):
        rgba = cicn_rgba(fetch(res_id), size)
        if rgba is None:
            raise RuntimeError(f"failed to decode {name}{suffix} ({res_id})")
        img = Image.frombytes("RGBA", (size, size), rgba)
        if size == 32:
            img = recolor_grid(img)
        img.save(OUT_DIR / f"{name}{suffix}.png")


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for name, (normal_id, pressed_id, size) in ICONS.items():
        save_pair(name, normal_id, pressed_id, size)
        print("ok", name)
    print("wrote", len(list(OUT_DIR.glob("*.png"))), "files to", OUT_DIR)


if __name__ == "__main__":
    main()
