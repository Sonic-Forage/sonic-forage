# w0rldw3aver360 — Synthetic World Engine

> **The complete guide for agents.** Everything needed to understand, continue, and expand
> the synthetic 360° world → Gaussian splat pipeline. Read this first; the project self-documents
> from here.

## What this project IS

An end-to-end pipeline that turns **CC0 equirectangular panoramas** into:
1. **360° splat-ready worlds** (Gaussian splatting source data)
2. **First-person walkthrough videos** (synthetic GoPro-style footage, for camera-motion LoRAs and multi-view splats)
3. **Interactive web experiences** (three.js sphere viewer, narrative films)

## The core idea (why this matters)

Licensed 360° walking footage barely exists. Real 360 splat capture needs expensive rigs.
**Synthetic generation solves both**: CC0 panoramas are free and clean → AI generates the
motion/walkthroughs → output is CC0-able if we own the generator. The gap in the market IS the product.

## Current asset inventory (as of 2026-08-29)

### Datasets on HuggingFace (TheMindExpansionNetwork)

| Dataset | Contents | License | HF ID |
|---|---|---|---|
| `w0rldw3aver360` | 12 CC0 Poly Haven equirect panos (2048×1024) + caption pairs (56–72 word grammar, trigger `w0rldw3aver360` first token) | CC0 | datasets/TheMindExpansionNetwork/w0rldw3aver360 |
| `w0rldw3aver360-motion` | 12 NASA 360 video clips (15s, exact 2:1) — Stennis B-2 + Perseverance + montage | US Gov PD | datasets/TheMindExpansionNetwork/w0rldw3aver360-motion |
| `w0rldw3aver360-walks` | 7+ synthetic walkthrough clips across 4 worlds (1376×768@24fps, generated ambience) + start frames + captions + walk_prompts.csv | CC0 | datasets/TheMindExpansionNetwork/w0rldw3aver360-walks |
| `forgesinger-data` | (private) AIdol shard for singing model | private | datasets/TheMindExpansionNetwork/forgesinger-data |

### Live websites

| Site | What |
|---|---|
| https://w0rldw3aver360.netlify.app | Interactive three.js 360 explorer + 5-clip "Meeting Sasquatch" chained narrative film + live caption panel |
| https://walks-w0rldw3aver360.netlify.app | Walk dataset explainer: method diagram, license landscape table, inline clip previews, catalog with per-world status |

### GitHub repos (Sonic-Forage org)

| Repo | Contents |
|---|---|
| `w0rldw3aver360-site` | 360 explorer + film section (Next.js-free, single HTML + assets) |
| `w0rldw3aver360-walks-site` | Walk dataset explainer site |
| `sonic-forage` | Master repo: README / PROJECTS / ROADMAP / DATASETS registries |

### Local data (on VPS, /home/ubuntu/mindbotz-studio/)

| Path | Contents |
|---|---|
| `datasets/w0rldw3aver360/review/pairs/` | 12 panos + 12 caption .txt (source of truth for stills) |
| `datasets/w0rldw3aver360-motion/clips/` | 12 NASA clips + captions |
| `datasets/ggps/` | GGPS study set (354 ERP panos + openMVG SfM + ply) — **CC BY-NC 4.0, research-only** |
| `datasets/ggps/STUDY.md` | Splat reconstruction method notes from GGPS |
| `outputs/walk_catalog/<slug>/` | Synthetic walks per world (7 clips, 4 worlds so far) |
| `outputs/walk_catalog/_starts/` | Perspective-extracted start frames (yaw-tagged) |
| `outputs/hall/ancient_hall_pano.png` | First fully-synthetic pano (Qwen-Image-2512 + 360 LoRA, 2048×1024) |
| `scripts/chain_walk.py` | Frame extraction / probe / concat helper |
| `scripts/build_walks_dataset.py` | Packages walk_catalog → HF layout (walks/ starts/ captions/ csv) |

---

## The pipelines (how to continue each one)

### PIPELINE A — pano → walk (chained H3, proven)

Each clip: panorama → perspective extract → MiniMax H3 image-to-video → last-frame chains to next clip.

**Skill:** load `h3-chain-film` (creative/) — has every command, exact template IDs, override keys, gotchas.

**Quick version:**
```bash
# 1. perspective extract from equirect (ffmpeg v360, GoPro feel)
ffmpeg -y -loglevel error -i pano.jpg \
  -vf "v360=input=e:output=flat:w=1376:h=768:h_fov=100:v_fov=62:yaw=15:pitch=-5" \
  -frames:v 1 -q:v 2 /tmp/start.jpg
# 2. upload to Comfy Cloud (upload_file → curl PUT the single-use URL)
# 3. run_template video_minimax_h3_i2v with overrides:
#    114.image=<name>, 115.aspect_ratio="16:9 (Widescreen)"+megapixels=1, 105:104.prompt=<walk prompt>
# 4. download via python urllib (NOT shell curl — signed URLs get mangled)
# 5. extract last frame → repeat for chain
# 6. verify seams: PSNR >30dB (we get 34–41)
# 7. build_walks_dataset.py → deploy site → push HF
```

**Walk worlds done:** sunset_forest (4 clips), abandoned_workshop (1), goegap (1), pond_bridge_night (1).
**Remaining:** kart_club, orbita, lakeside_sunrise, metro_vijzelgracht, rosendal_park_sunset, rural_winter_roadside, small_cathedral, orbita, abandoned_workshop_02 (start frames for 4 already in `_starts/`).

### PIPELINE B — text → new worlds (Qwen-Image-2512 + 360 LoRA)

Comfy Cloud template `template_qwen_Image_2512_360_lora` generates **native equirect 2:1 panoramas**
from text (2048×1024). Verified working — produced the Ancient Hall.
Slot overrides: `238.text` (prompt), `238.width`=2048, `238.height`=1024.

**This is the flywheel:** new synthetic worlds → Pipeline A walks them → dataset grows without Poly Haven.

### PIPELINE C — pano → Gaussian splat

**Current best path** (from GGPS study — see `datasets/ggps/STUDY.md`):
1. Walk video → frame extraction (sharpest-frame selection, 1fps)
2. COLMAP spherical camera model (`panorama_sfm.py --pano_render_type spherical`)
3. Splat training: LichtFeld Studio with `--undistort` (expands each ERP into 12×90° virtual pinhole views)
4. Export: PLY → SPZ/SOG for web

**Reference result:** Jamesbass/bigsur-360-colmap achieved PSNR 31.6 on a drone capture this way.
**Our advantage:** synthetic walks have perfect loop-closure potential (last frame ≈ first frame) —
run 1 walks, run 2 returns to start → seamless loop = clean splat geometry.

**Tool to install (not yet done):** SPAG-4D (github.com/cedarconnor/SPAG4D) — direct equirect→splat,
DA360 backend ~2s/pano, ~2GB VRAM, commercial-OK. Quick win: 12 panos → 12 .ply in under a minute.

### PIPELINE D — narrative films (proven, fun, marketable)

5-clip chained stories from a single pano. "Meeting Sasquatch" (25.9s, seams 34.8–40.8dB, GoPro-graded)
is live on the explorer site. Structure: Walk → Encounter → Offer → Trip → Departure.
Beats + shot lists in git history of w0rldw3aver360-site.

---

## Hard-won gotchas (do not relearn these)

1. **ffmpeg 8 v360 syntax:** long-form keys (`input=e:output=flat:` NOT `e:p`), `h_fov`/`v_fov` not `fov`
2. **Comfy Cloud subgraph overrides:** flattened keys `105:104`, NOT `105.prompt`. Slot addresses from get_template_schema work only for some nodes
3. **ResolutionSelector exact strings:** `16:9 (Widescreen)` — no "Landscape"
4. **Signed GCS URLs:** download with python urllib + full query string; shell curl mangles them → 403
5. **mjpeg extraction:** mp4→jpg direct fails YUV range; go through PNG first
6. **HF YAML:** quote the `"360"` tag (parses as int otherwise)
7. **AIdol/GGPS license walls:** AIdol = no public model release without permission; GGPS = research only. Our own outputs are CC0
8. **Vision is unavailable** to the agent — verify seams via PSNR math, never claim visual quality
9. **Site public copy:** no "GoPro"/"MiniMax"/"YouTube" mentions — neutral terms, scrub before deploy
10. **Dataset uploads:** README first, pairs/ drag-drop format, quoted tags

## Where the project is headed (priority order)

1. **Finish walk catalog** — 4/12 worlds done, 8 to go (start frames ready for 4)
2. **SPAG-4D install** on PC → 12 panos → 12 .ply splats → web viewer section
3. **Loop-closure walks** — return-to-start chains for splat-friendly geometry
4. **World synthesis flywheel** — Qwen 360 LoRA generates new worlds → walks → v2 dataset (100+ worlds)
5. **Splat training run** — LichtFeld or Nerfstudio on walk frames (needs PC or pod)
6. **Ancient Hall narrative** — the first fully-synthetic world deserves a film

## Key files for agents

- `h3-chain-film` skill — the full chain recipe
- `build_walks_dataset.py` — HF packaging
- `chain_walk.py` — frame ops
- `worlds.json` (in w0rldw3aver360-site) — world metadata source
- This file + master repo ROADMAP.md

## Contact points in code

- Explorer site JS: `w0rldw3aver360-site/index.html` (three.js inline, no build)
- Walks site: `w0rldw3aver360-walks-site/index.html`
- Netlify deploys: `npx netlify-cli deploy --prod --dir .` with NETLIFY_PERSONAL_ACCESS_TOKEN from .env
- HF uploads: token at ~/.cache/huggingface/token, api.upload_folder / upload_file
