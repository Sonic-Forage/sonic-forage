# SONIC FORAGE — Master Repository

> AI-native studio empire run by Mind Expander + Hermes agent swarm.
> The pipeline is the product.

## Live now

| Asset | URL | Status |
|---|---|---|
| Forage Radio — The Digital Underground | https://forage-radio-sonic-forage.netlify.app | ✅ Live (21 tracks, discography) |
| Discography page | https://forage-radio-sonic-forage.netlify.app/discography | ✅ Live |
| GL1TCH FM — Signal Lost | https://glitch-fm-sonic-forage.netlify.app | ✅ Live (11-track album) |
| Qwen3.8-FM capability site | https://qwen38-fm.netlify.app | ✅ Live |
| w0rldw3aver360 world explorer | https://w0rldw3aver360.netlify.app | ✅ Live (12 worlds + film) |

## HuggingFace datasets

| Dataset | Contents | License |
|---|---|---|
| [w0rldw3aver360](https://huggingface.co/datasets/TheMindExpansionNetwork/w0rldw3aver360) | 12 CC0 equirect panos + caption pairs | CC0 |
| [w0rldw3aver360-motion](https://huggingface.co/datasets/TheMindExpansionNetwork/w0rldw3aver360-motion) | 12 NASA 360 clips (15s, 2:1) + montage | US Gov PD |
| [mindbotz-style-sheets-v2](https://huggingface.co/datasets/TheMindExpansionNetwork/mindbotz-style-sheets-v2) | 20 character sheet pairs | CC-BY |
| [mindbotz-character-sheets](https://huggingface.co/datasets/TheMindExpansionNetwork/mindbotz-character-sheets) | 69 ref sheets + 20 environments | CC-BY |

## Repos (Sonic-Forage org)

- `forage-radio` — discography web app (Next.js)
- `forage-dj` — DJ scripts, demo album builder, setlist forge
- `qwen38-fm` — model capability site
- `w0rldw3aver360-site` — 360 explorer + Sasquatch film
- `glitch-fm` — GL1TCH FM site
- `sonic-forage` — THIS master repo (project bible + roadmap)

## Infrastructure

- **VPS** `vps-f8dcb7c1` (100.118.239.109) — Hermes brain, ffmpeg, netlify-cli, cron swarm
- **Home PC** `DESKTOP-PVDFNBF` (100.84.222.44, RTX 4070 12GB) — ComfyUI via SSH tunnel (`comfy-tunnel.service`), Wan2.1, Krea2, LTX-2.5, TRELLIS, ACE-Step
- **Comfy Cloud** — MCP authenticated; H3 I2V/FLF2V/R2V templates (video_* = not spend-gated)
- **Netlify** — 12 sites
- **Cron swarm** — ai-news radar 08:00, midnight wrap 00:00, night-shift worker hourly

## Key learnings (hard-won)

- GMI Speech 2.8: pitch MUST be string "0" (negative → HTTP 500). RPM rate limit Error 1002 on music gen
- Comfy Cloud template overrides: subgraph interiors addressed as `105:104` (flattened), NOT `105.prompt`
- ResolutionSelector valid values: `16:9 (Widescreen)` etc. — exact strings only
- Signed GCS download URLs: shell curl mangles them → download via python urllib with full URL
- Windows SSH admin trap: keys go in `C:\ProgramData\ssh\administrators_authorized_keys`
- ComfyUI on PC: use `ComfyUI\.venv\Scripts\python.exe` + `--extra-model-paths-config` yaml
- H3 chain: last-frame → first-frame chaining holds at 34–41 dB PSNR per seam
- MiniMax H3: reference (R2V) and first/last-frame modes are mutually exclusive

Read `PROJECTS.md` for detail and `ROADMAP.md` for what agents should build next.

## NEW: w0rldw3aver360-walks (Aug 28)
- Site: https://walks-w0rldw3aver360.netlify.app
- HF: https://huggingface.co/datasets/TheMindExpansionNetwork/w0rldw3aver360-walks (7 clips, 4 worlds, CC0)
- Method: v360 perspective extract -> MiniMax H3 I2V walk -> last-frame chaining
- Repos: w0rldw3aver360-walks-site; builder script mindbotz-studio/scripts/build_walks_dataset.py
