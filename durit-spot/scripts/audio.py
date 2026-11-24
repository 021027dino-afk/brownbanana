"""Synthesized sound design for the DURIT 30 s spot (120 BPM grid).

Writes a 48 kHz stereo WAV. All cues follow the storyboard timings.
"""
import sys
import wave
import numpy as np

SR = 48000
DUR = 30.0
N = int(SR * DUR)
t = np.arange(N) / SR
rng = np.random.default_rng(7)
L = np.zeros(N)
R = np.zeros(N)


def env_ar(n, a, r):
    e = np.ones(n)
    na, nr = int(a * SR), int(r * SR)
    if na:
        e[:na] = np.linspace(0, 1, na)
    if nr:
        e[-nr:] *= np.linspace(1, 0, nr) ** 2
    return e


def add(sig, start, gain=1.0, pan=0.0):
    i = int(start * SR)
    j = min(N, i + len(sig))
    if j <= i:
        return
    s = sig[: j - i] * gain
    L[i:j] += s * np.sqrt((1 - pan) / 2) * 1.414
    R[i:j] += s * np.sqrt((1 + pan) / 2) * 1.414


def lowpass(x, cutoff):
    a = np.exp(-2 * np.pi * cutoff / SR)
    y = np.empty_like(x)
    acc = 0.0
    for k in range(len(x)):
        acc = (1 - a) * x[k] + a * acc
        y[k] = acc
    return y


def noise(d):
    return rng.standard_normal(int(d * SR))


# --- low electric hum 0–6 s (CUT 1–2) --------------------------------------
seg = t < 6.2
h = 0.5 * np.sin(2 * np.pi * 55 * t) + 0.25 * np.sin(2 * np.pi * 110 * t) + 0.08 * np.sin(2 * np.pi * 165 * t)
hum_env = np.clip(t / 1.2, 0, 1) * np.clip((6.2 - t) / 0.6, 0, 1)
L += 0.10 * h * hum_env * seg
R += 0.10 * h * hum_env * seg

# --- ambient synth pad: soft from the start, fully in at 6 s, ducks at 25 s --
pad = np.zeros(N)
for f, a in [(110.0, .5), (164.81, .35), (220.0, .3), (277.18, .18), (329.63, .14)]:
    for det in (-0.6, 0.6):
        pad += a * np.sin(2 * np.pi * (f + det) * t + rng.uniform(0, 6))
pad_env = 0.15 * np.clip(t / 3, 0, 1) + 0.85 * np.clip((t - 6) / 1.2, 0, 1)
pad_env *= np.where(t < 25, 1, np.clip(1 - (t - 25) / 2.0, 0.08, 1))
pad_env *= np.where(t < 27, 1, np.clip(1 - (t - 27) / 1.5, 0, 1))
pad_lp = lowpass(pad, 900)
L += 0.035 * pad_lp * pad_env
R += 0.035 * np.roll(pad_lp, 240) * pad_env

# --- tick at 2.6 -------------------------------------------------------------
tick = noise(0.03) * np.exp(-np.linspace(0, 12, int(0.03 * SR)))
add(np.diff(tick, prepend=0), 2.6, 0.15)

# --- metallic whoosh at 3.15 --------------------------------------------------
d = 0.9
n = noise(d)
sweep = np.sin(np.linspace(0, np.pi, len(n))) ** 2
w = lowpass(n, 2500) * sweep
ring = np.sin(2 * np.pi * 2350 * np.arange(len(n)) / SR) * np.exp(-np.linspace(0, 6, len(n)))
add(w * 0.5 + ring * 0.04, 3.15 - 0.3, 0.6, pan=-0.3)

# --- button click ------------------------------------------------------------
def click():
    k = int(0.025 * SR)
    c = noise(0.025) * np.exp(-np.linspace(0, 18, k))
    c = np.diff(c, prepend=0)
    body = np.sin(2 * np.pi * 1800 * np.arange(k) / SR) * np.exp(-np.linspace(0, 25, k))
    return c * 0.6 + body * 0.5


add(click(), 8.4, 0.9)
add(click(), 15.3, 0.9)

# --- three rising LED tones (880, 1175, 1568 Hz) ----------------------------
for f, st in [(880, 8.55), (1175, 8.85), (1568, 9.15)]:
    k = int(0.45 * SR)
    x = np.arange(k) / SR
    tone = (np.sin(2 * np.pi * f * x) + 0.2 * np.sin(2 * np.pi * 2 * f * x)) * env_ar(k, 0.004, 0.4)
    add(tone, st, 0.16)

# --- rolling low wave swells at 10.1 and 12.6 -------------------------------
for st in (10.1, 12.6):
    d = 2.6
    k = int(d * SR)
    x = np.arange(k) / SR
    sw = lowpass(noise(d), 380) * np.sin(np.pi * x / d) ** 2
    sub = np.sin(2 * np.pi * 48 * x) * np.sin(np.pi * x / d) ** 2
    add(sw * 1.6 + sub * 0.25, st, 0.45)

# --- bass drop 150 → 36 Hz at 15.3 ------------------------------------------
d = 1.6
k = int(d * SR)
x = np.arange(k) / SR
f = 36 + (150 - 36) * np.exp(-x * 4.5)
ph = 2 * np.pi * np.cumsum(f) / SR
drop = np.tanh(1.8 * np.sin(ph)) * np.exp(-x * 1.6)
add(drop, 15.3, 0.55)

# --- whoosh with the streak 15.5–16.05 --------------------------------------
d = 0.7
n = noise(d)
k = len(n)
env = np.concatenate([np.linspace(0, 1, int(k * 0.75)) ** 2, np.linspace(1, 0, k - int(k * 0.75))])
add(np.diff(lowpass(n, 4000), prepend=0) * env * 2.0, 15.45, 0.5, pan=0.3)

# --- beat: kick every 0.5 s from 17.0, hats on off-beats in 22–25 -----------
def kick():
    d = 0.35
    k = int(d * SR)
    x = np.arange(k) / SR
    f = 45 + 110 * np.exp(-x * 30)
    return np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-x * 9)


def hat():
    d = 0.06
    h = np.diff(noise(d), prepend=0)
    return np.diff(h, prepend=0) * np.exp(-np.linspace(0, 10, len(h)))


def beat_gain(tt):
    if tt < 25:
        return 1.0
    return max(0.0, 1 - (tt - 25) / 2.0)


b = 17.0
while b < 27.0:
    add(kick(), b, 0.6 * beat_gain(b))
    if 22.0 <= b < 25.0:
        add(hat(), b + 0.25, 0.10)
    b += 0.5

# soft sub-bass line under RED (17–25)
bass_env = np.clip((t - 17) / 0.3, 0, 1) * np.clip((27 - t) / 2.0, 0, 1) * (t >= 17)
bass = np.sin(2 * np.pi * 41.2 * t) * bass_env
L += 0.06 * bass
R += 0.06 * bass

# --- final chime at 27.25 ---------------------------------------------------
d = 2.7
k = int(d * SR)
x = np.arange(k) / SR
chime = np.zeros(k)
for f, a in [(1318.5, 1), (1975.5, .5), (2637, .3), (3951, .12)]:
    chime += a * np.sin(2 * np.pi * f * x) * np.exp(-x * (1.4 + f / 2000))
add(chime * env_ar(k, 0.003, 0.3), 27.25, 0.13)

# --- master ------------------------------------------------------------------
mix = np.stack([L, R], 1)
mix = np.tanh(mix * 1.4) / np.tanh(1.4)
fade = np.clip((DUR - t) / 0.25, 0, 1)
mix *= fade[:, None]
mix /= max(1e-9, np.abs(mix).max()) / 0.89
pcm = (mix * 32767).astype(np.int16)
with wave.open(sys.argv[1], "wb") as wf:
    wf.setnchannels(2)
    wf.setsampwidth(2)
    wf.setframerate(SR)
    wf.writeframes(pcm.tobytes())
print("wrote", sys.argv[1])
