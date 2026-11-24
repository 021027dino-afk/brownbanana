"""Clean the reference stills into full-frame 1080x1920 plates.

- removes letterbox bars (p01 bottom, p08 and p09 top/bottom) by cover-scaling the content
- builds luminance keys for the black-background product plates (p02, p11)
- builds a blue-world version of p06 (red light hue-swapped) for the mode-switch wipe
"""
import sys
import numpy as np
from PIL import Image, ImageFilter

SRC = sys.argv[1]
W, H = 1080, 1920


def cover(im, top, bottom):
    c = im.crop((0, top, im.width, bottom))
    s = H / c.height
    c = c.resize((round(c.width * s), H), Image.LANCZOS)
    x = (c.width - W) // 2
    return c.crop((x, 0, x + W, H))


for i in range(1, 12):
    im = Image.open(f"{SRC}/{i}.webp").convert("RGB")
    if i == 1:
        im = cover(im, 0, 1722)
    elif i == 8:
        im = cover(im, 192, 1726)
    elif i == 9:
        im = cover(im, 246, 1674)
    im.save(f"plates/p{i:02d}.jpg", quality=94)

# product keys on black backgrounds (floor reflection excluded below the base line)
for i, base in [(2, 1460), (11, 1585)]:
    a = np.asarray(Image.open(f"plates/p{i:02d}.jpg")).astype(float)
    lum = a.max(2)
    m = np.clip((lum - 14) / 26, 0, 1)
    m[base:] = 0
    mk = Image.fromarray((m * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(1.5))
    rgba = Image.open(f"plates/p{i:02d}.jpg").convert("RGBA")
    rgba.putalpha(mk)
    rgba.save(f"plates/p{i:02d}_key.png")

# p06 blue-world variant: swap strongly red light to blue (skin/thumb untouched)
a = np.asarray(Image.open("plates/p06.jpg")).astype(float)
r, g, b = a[..., 0], a[..., 1], a[..., 2]
red = np.clip((r - 1.9 * np.maximum(g, b)) / 40, 0, 1)
red = np.asarray(Image.fromarray((red * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(3))).astype(float) / 255
blue = np.stack([b * 0.6 + r * 0.05, g * 0.9 + r * 0.25, r * 1.05], -1)
out = a * (1 - red[..., None]) + blue * red[..., None]
Image.fromarray(np.clip(out, 0, 255).astype(np.uint8)).save("plates/p06_blue.jpg", quality=94)
print("plates ready")


# ---- layout passes: keep the product clear of the caption band (330–560 px) ----
def shift_down(name, dy):
    im = Image.open(f"plates/{name}")
    mode = im.mode
    fill = tuple(int(v) for v in np.asarray(im.convert("RGB"))[:4].reshape(-1, 3).mean(0))  # match the plate's own black
    out = Image.new(mode, (W, H), (0, 0, 0, 0) if mode == "RGBA" else fill)
    out.paste(im.crop((0, 0, W, H - dy)), (0, dy))
    out.save(f"plates/{name}")


for n in ("p02.jpg", "p02_key.png"):
    shift_down(n, 230)

# p09: original-size content lowered by 450 px; the empty bands are filled from blurred,
# mirrored edge content so the blue/red gradient carries on without a hard bar
src = Image.open(f"{SRC}/9.webp").convert("RGB").crop((0, 246, 1080, 1674))
out = Image.new("RGB", (W, H))
top_fill = src.crop((0, 0, W, 24)).resize((W, 450), Image.BILINEAR).filter(ImageFilter.GaussianBlur(40))  # smear the top edge
out.paste(top_fill, (0, 0))
out.paste(src, (0, 450))
bot = H - (450 + src.height)
if bot > 0:
    bf = src.crop((0, src.height - bot, W, src.height)).transpose(Image.FLIP_TOP_BOTTOM).filter(ImageFilter.GaussianBlur(30))
    out.paste(bf, (0, 450 + src.height))
a = np.asarray(out).astype(float)
fade = np.clip(np.arange(H) / 450, 0, 1) ** 1.5  # darken the extended top
a[:450] *= fade[:450, None, None]
Image.fromarray(a.astype(np.uint8)).save("plates/p09.jpg", quality=94)

# p10: background key for the X beams (dark background above the shoulder line, not the subject)
a = np.asarray(Image.open("plates/p10.jpg")).astype(float)
lum = a.max(2)
m = np.clip((26 - lum) / 14, 0, 1)
yy, xx = np.mgrid[0:H, 0:W]
shoulder = np.interp(xx, [0, 380, 480, 950, 1080], [1380, 1240, 1110, 1110, 1260])
m[yy > shoulder] = 0
m[(xx > 300) & (xx < 1060) & (yy < 760) & (yy > 60)] *= 0.35  # hair: only a faint spill
mk = Image.fromarray((m * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(6))
rgba = Image.new("RGBA", mk.size, (255, 255, 255, 0))
rgba.putalpha(mk)  # alpha-only mask for canvas destination-in
rgba.save("plates/p10_bgmask.png")
print("layout passes done")
