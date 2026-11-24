# DURIT: "One device, two modes" (30 s, 9:16)

A frame-exact animatic of the DURIT spot: 1080×1920, 30 fps, 120 BPM grid, with the full synthesized sound design. Everything is drawn in code from `spot.html` (`render(t)`), so every cut, button press, LED, caption and sound cue sits on the storyboard timecode.

- Video: `out/DURIT_30s_1080x1920.mp4` (H.264 + AAC, 30.0 s)
- Rebuild:
  ```bash
  python3 scripts/audio.py out/durit_audio.wav
  node scripts/render.js out/DURIT_30s_1080x1920.mp4 out/durit_audio.wav 30
  ```
- Preview any frame: `scripts/sheet.sh <dir> 1.5 9.4 15.8` writes stills plus a contact sheet.

## What is final and what is a placeholder

| Element | Status |
|---|---|
| Edit: cut points, timing, camera moves (ease-out only), captions, safe area, palette, type | Final; this is the locked timing reference |
| Sound design: hum, tick, whoosh, click, LED tones 880/1175/1568 Hz, wave swells, 150→36 Hz drop, kick/hats, chime | Final as temp track; swap in a composed pad/beat on the same grid |
| DURIT product | **Vector stand-in** built from the written spec (proportions, 120° bend, ring order, LED and button layout). Replace with the reference-photo or CG product plates. |
| Model (CUT 3, 5, 7, 9) | **Stylized silhouette previz.** Replace with live-action or AI plates. The light pool, ripples, red lines and jaw trace are separate passes to composite over the real plate. |
| `duflow` logo, `DURIT` wordmark, package art, Red Dot mark | **Typeset placeholders.** Composite THE iLLON's real brand assets in the edit. |

## Cut list (as rendered)

| Cut | Time | World | Key beats |
|---|---|---|---|
| 1 Reveal | 0–3 | Studio | Macro head, slide L→R; rings light at 0.5 / 0.95 / 1.4; caption 0.5 |
| 2 Detail | 3–6 | Studio | 180° turntable settles front-on at 5.5; green arcs, mirror floor; caption 3.3 |
| 3 User | 6–8 | Studio | Picks up DURIT, push-in 1.0→1.05; no caption |
| 4 Blue on | 8–10 | →Blue | Press 8.4 + white ring; LEDs 8.55 / 8.85 / 9.15; edge wash from 8.5 |
| 5 Blue care | 10–15 | Blue | Cheek→jaw glide; elliptical ripple every 0.28 s, 1.9 s fade; DOF blur |
| 6 Switch | 15–17 | Blue→Red | Press 15.3, LEDs red 15.45, diagonal streak wipe 15.5–16.05, zoom-out 16.0–16.9 |
| 7 Red care | 17–22 | Red | Chin→ear tracking, 15 converging dash lines, jaw trace; macro insert 19.55–20.45 |
| 8 Hero | 22–25 | Split | Blue left / red right drift apart, green underglow, dolly 0.94→1.02 |
| 9 Model + product | 25–27 | X beams | Push-in face→product 1.0→1.12; music ducks |
| 10 Packshot | 27–30 | Black | Rises at 27.15 / 27.35 / 27.75 / 28.10 / 28.45; chime 27.25 |

Captions sit at y 390–560 px, x ≥ 90 px, ≥ 140 px from the right edge. None fall in the bottom 320 px.

## v2: built on the reference stills

`out/DURIT_30s_v2_photo.mp4` is rendered from `spot2.html` on the 11 reference stills in `plates/`, which were cleaned by `scripts/prep_plates.py` (letterbox removal, product keys, a blue-world version of the switch shot, a background key for the X beams). The timing, captions and audio match v1.

```bash
python3 scripts/prep_plates.py <folder with 1.webp … 11.webp>
PAGE=spot2.html node scripts/render.js out/DURIT_30s_v2_photo.mp4 out/durit_audio.wav 30
```

Motion comes from camera moves plus light passes on still plates: ring light, LED on/off, the press ring, ripples, the streak wipe, red lines and the jaw trace, beams and glows. The turntable in CUT 2, the pick-up in CUT 3 and the head glides in CUT 5 and 7 need real footage or image-to-video plates; slow dollies stand in for them for now.
