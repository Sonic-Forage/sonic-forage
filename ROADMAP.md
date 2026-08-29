# ROADMAP — Agent Work Priorities

Ordered queue. Each item is scoped so an agent can pick it up cold.

## P0 — Tonight (night shift)

### N0. w0rldw3aver360 continuation (agents start HERE)
- Read `W0RLDW3AVER360.md` — complete project guide
- Remaining walk worlds: kart_club, orbita, lakeside_sunrise, metro_vijzelgracht, rosendal_park_sunset, rural_winter_roadside, small_cathedral, abandoned_workshop_02 (start frames ready in _starts/)
- 1 walk clip per run via h3-chain-film skill → build_walks_dataset.py → redeploy walks site → push HF
- Then: SPAG-4D install attempt (PC or pod), 12 panos → .ply
- Then: loop-closure test (chain walk until last ≈ first, PSNR >30)
- Full splat method comparison in `SPLAT_RESEARCH.md`

### N1. Krea2 LoRA training (PC required)
- Config ready: `~/mindbotz-studio/training/w0rldw3aver360_krea2_v1.yaml`
- 3000 steps, rank 32, 1024×512, ~3-4h on 4070
- Needs PC awake. When online: check ComfyUI, verify ai-toolkit deps, launch, monitor hourly
- Output → HF `w0rldw3aver360-lora` + test 5 generations vs control prompts

### N2. GGPS dataset ingest (CPU, VPS)
- `hf download Insta360-Research/GGPS --repo-type model` (CC BY-NC 4.0 — non-commercial, fine for research/training study)
- 3 scenes (FTP 354 panos, NSC 1862, NSK 576), ERP png + openMVG sfm_data
- Build `w0rldw3aver360-splats` study dataset: scenes + caption pairs + provenance README
- DO NOT redistribute weights commercially — document license clearly

### N3. Overnight H3 walk catalog (Comfy Cloud, ~$0 video_* templates)
- 6 panos × 1 walk clip each (1376×768, 5.17s) using `h3-chain-film` skill
- Each: v360 perspective extract → upload → run → download → archive
- Output: `~/mindbotz-studio/outputs/walk_catalog/<slug>/`
- Post to HF as `w0rldw3aver360-walks` (CC0 ours) with README

## P1 — This week

### W1. H3-R2V reference pipeline (the user's directed walk idea)
- Template `video_minimax_h3_r2v`: reference images (look) + video ref (motion, GoPro/drone) + audio ref (ambience)
- Test matrix: 2 panos × {GoPro walk ref, drone orbit ref} × ambience audio from GMI
- Chain result via last-frame continuation (skill)
- Deliver: prompt/asset template documented in skill

### W2. Gaussian splat pipeline on PC
- Install SPAG-4D (DA360 backend, 2s/pano, 2GB VRAM, commercial-OK)
- Run over all 12 panos → 12 .ply
- PLY→SPZ compression for web embed
- Add splat viewer section to w0rldw3aver360 site

### W2B. Unreal Splat Dataset Forge — cyberpunk apartment canary
- Read `research/UNREAL_SPLAT_DATASET_FORGE.md`
- Prefer the AI-allowed UnrealToColmap plugin; do not use SplatCapture for AI training until its Fab usage flag is clarified
- Select one legally clean cyberpunk apartment scene
- Smoke capture: sparse 6-camera grid at preview resolution
- Validate exported COLMAP poses, images, and point cloud in one trainer
- Train base splat; then render one Unreal-native paired restyle from identical camera poses
- Compare 3DGS-aware generative edit only after the base/control path passes
- Record holdout metrics, training time, peak VRAM, storage, splat size, render FPS, and camera-path flicker

### W3. Forage Radio autoplay + publish push
- Radio queue UI on discography page
- 3 new DJ sets (build_demo_album.py retry if GMI limit cleared)
- IG/YouTube Shorts: 3 cutdowns from walk catalog (vertical 9:16 crops)

### W4. GL1TCH FM expansion
- Track 2-3 of Signal Lost (GMI when available)
- Voice intros (pitch "0", speed 0.95, max_wait_s 540)

## P2 — This month

### M1. w0rldw3aver360 v2 dataset (synthetic flywheel)
- Train LoRA (N1) → generate 200 new panos → caption with grammar → QA → upload v2
- Pairs/ drag-drop format, README quoted-tag fix (already learned)

### M2. Gaussian splat training dataset (the real goal)
- Panos → splats (W2) + walk videos → multi-view splats
- Format: (caption, .ply) + (caption, walk.mp4) pairs
- Publish `text-to-splat` training set — nobody has this

### M3. Vex voice agent revival
- LiveKit self-hosted on VPS, GL1TCH FM persona
- Phone mesh node = remote DJ control

### M4. Fiverr gig launch
- GIG-LISTING.md drafted in monetization/fiverr/
- Portfolio: Sasquatch film + discography + walk catalog
- $20 runway → first commission funds RunPod

## Blocked / waiting

- GMI music rate limit (Error 1002) — retry daily, 11-track demo album pending
- RunPod Flash-Next endpoint — user to deploy template (110GB RAM pod needed)
- PC wake-on-demand — user must wake PC for N1/W2 (autostart not approved)

## Cost guardrails

- Comfy Cloud video_* templates: no per-call credit burn observed, but batch ≤12 jobs/night
- RunPod: only when user approves; target <$1/test
- GMI: retry with backoff, never loop-blast
