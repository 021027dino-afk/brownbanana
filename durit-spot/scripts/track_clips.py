"""Build clips/manifest.json: frame counts plus a smoothed contact-point track for the care shots.

The contact point is the centroid of the device's coloured light at the skin
(strong blue in c5, strong red in c7), smoothed over ~0.4 s.
"""
import glob
import json
import numpy as np
from PIL import Image


def track(name, cond):
    pts = []
    for f in sorted(glob.glob(f"clips/{name}/*.jpg")):
        a = np.asarray(Image.open(f).reduce(2)).astype(int)
        m = cond(a[..., 0], a[..., 1], a[..., 2])
        ys, xs = np.where(m)
        pts.append((xs.mean() * 2, ys.mean() * 2) if m.sum() > 20 else (np.nan, np.nan))
    p = np.array(pts)
    for k in range(2):  # fill gaps, then smooth
        v = p[:, k]
        idx = np.arange(len(v))
        ok = ~np.isnan(v)
        v[~ok] = np.interp(idx[~ok], idx[ok], v[ok])
        p[:, k] = np.convolve(np.pad(v, 5, mode="edge"), np.ones(11) / 11, mode="valid")
    return [[round(x), round(y)] for x, y in p]


man = {}
for name in ("c2", "c3", "c5", "c7"):
    n = len(glob.glob(f"clips/{name}/*.jpg"))
    man[name] = {"n": n, "fps": 24, "dur": n / 24}
man["c5"]["track"] = track("c5", lambda r, g, b: (b > 170) & (b - r > 60) & (g > 110))
man["c7"]["track"] = track("c7", lambda r, g, b: (r > 215) & (g < 110) & (b < 120))
json.dump(man, open("clips/manifest.json", "w"))
print({k: v["n"] for k, v in man.items()}, man["c7"]["track"][::20])
