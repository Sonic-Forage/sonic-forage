# GoPro / Walking 360+POV Footage — Source Registry

Curated sources for motion-reference video (H3 R2V video refs + splat training). Verified 2026-08-28.

## Verified available

### CC / licensed OK

| Source | What | Res | License | Use |
|---|---|---|---|---|
| HF `shawshankvkt/Walking_Tours` | 10 urban egocentric walks (Amsterdam, Bangkok, Istanbul, Venice…) + 1 safari | 4K60 | CC-BY | H3 video refs, motion priors, walking style transfer |
| NASA images API (already used) | 360 NASA footage | up to 8K | US Gov PD | Splat + motion refs (already in w0rldw3aver360-motion) |
| HF `Jamesbass/bigsur-360-colmap` | DJI Avata 360 drone flight → COLMAP + LichtFeld splat | 8K ERP | check repo | Drone-motion reference + splat pipeline example |

### Research / non-commercial

| Source | What | Res | License | Use |
|---|---|---|---|---|
| HF `Insta360-Research/GGPS` | 3 outdoor ERP scenes + openMVG recon + pretrained .ply splats (FTP 354, NSC 1862, NSK 576 panos) | ERP png | CC BY-NC 4.0 | Splat training study, 360 walk reconstruction reference |
| CMU MS CV 2025 team4 | 8 Insta360 X4 walks (5.7K/8K), VSLAM poses | 5.7K | check | Method reference for our own capture pipeline |
| GitHub `MattWallingford/360-1M` | 1M+ 360 videos metadata + YouTube links | varies | none (links) | Index only — license unknown per video, do NOT bulk rip |

### Commercial (skip unless funded)
- AxonLab egocentric 4K (100+ hrs) — paid
- Gerra First-Person Motion — paid, NDA

## Gaps / to build
- **CC0 GoPro-style walk clips in natural environments** — Walking_Tours is urban CC-BY; nobody has CC0 nature POV
- **360 walking footage with clean license** — GGPS is NC; we can synthesize our own via H3 chaining from our CC0 panos (in progress via walk catalog)

## Extraction recipes
- YouTube sources: yt-dlp at source res, cut 10-15s windows, keep license attribution in CSV
- 360 sources: ffmpeg v360 e→flat for POV refs (h_fov 100), or keep ERP for splat training
- Pair every clip with: source URL, license, capture rig (if known), caption in w0rldw3aver360 grammar
