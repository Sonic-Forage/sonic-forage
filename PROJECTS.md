# PROJECTS.md — Sonic Forage Project Detail

## 1. Forage Radio — The Digital Underground (flagship)
**Status: LIVE**
- 21 music tracks + 2 voice intros across 3 albums (Digital Roster 13, Ember Cosmic Campfire 7, GL1TCH FM Signal Lost 1)
- SoundCloud-style discography: filter by DJ/Album/Phase, sort, persistent player
- Stack: Next.js on Netlify, catalog.json source of truth, build_catalog.py
- Repo: Sonic-Forage/forage-radio (b76f7c7), Sonic-Forage/forage-dj (a3ae850)
- Audio: public/sets/ (streams via 206 range requests)
- Next: autoplay radio mode, 3 new DJ sets, vertical cutdowns

## 2. GL1TCH FM — Signal Lost (separate brand)
**Status: LIVE (site + 1 track)**
- Distinct identity from Forage Radio. Voice: English_expressive_narrator, pitch "0", speed 0.95
- Album format: voice intros between tracks = story
- 11-track album blocked on GMI rate limit; track 1 done
- Monetization ladder: free → tips → forks → commissions → sync
- Next: tracks 2–3, TTS queue discipline (max_wait_s 540)

## 3. w0rldw3aver360 — Synthetic World Engine
**Status: LIVE + film**
- 12 CC0 Poly Haven panos, uniform caption DNA (56–72 words, trigger first token)
- Interactive three.js explorer (drag/zoom/compass/fullscreen)
- Caption-as-prompt scored 9/10 → format is learnable
- Training config ready (Krea2, rank 32, 3000 steps) — needs PC
- **NEW: "Meeting Sasquatch" — 5-clip chained H3 narrative film, 25.9s, seams 34.8–40.8 dB, GoPro grade**
- Live: https://w0rldw3aver360.netlify.app
- Repo: Sonic-Forage/w0rldw3aver360-site

## 4. w0rldw3aver360-motion — 360 Video Dataset
**Status: PUBLISHED**
- NASA public domain: Stennis B-2 (4 clips) + Perseverance (2 clips), 15s each, exact 2:1
- QC rejected: Curiosity 8K (partial mosaic + burned-in text), Hurricane Maria (flat render)
- Montage preview uploaded. Local has 12 clips (HF has 6 — re-upload pending)
- Synthetic expansion (Wan2.1 I2V canary) worked; 81-frame render OK; sweep 1/36 (ComfyUI died mid-run)
- License: US Gov PD + CC0 curation
- Next: HF re-upload 12 clips, finish sweep when PC up

## 5. mindbotz-style-sheets-v2
**Status: PUBLISHED**
- 20 detailed character reference sheets + caption pairs (drag-drop pairs/)
- captest tape_ghost scored 6.5–7/10 (LoRA will bake layout)
- Training config ready. HF: TheMindExpansionNetwork/mindbotz-style-sheets-v2

## 6. Qwen3.8-Flash / Flash-Next
**Status: daily driver live, self-host pending**
- Conversation model via OpenRouter/CommandCode ($0.16/$0.47 per M, 1M ctx, no reasoning tax)
- qwen38-fm.netlify.app = capability site
- RunPod template (177B on 24GB via --n-cpu-moe, 110GB RAM) — user to deploy
- setlist_forge.py still on Haiku (proven parser)

## 7. Vex Voice Agent
**Status: PAUSED**
- LiveKit self-host, GL1TCH persona, phone mesh node
- Deps: LiveKit VPS setup (skills exist), revive after splat pipeline

## 8. Monetization
**Status: drafted**
- Fiverr: GIG-LISTING.md drafted, 1 portfolio sample (Sasquatch film is portfolio #2)
- Ladder: free → tips → forks → commissions → sync
- Runway: $20. Comfy Cloud video_* templates not observed to burn credits
- Next: publish gig, add film to portfolio

## 9. Cron Swarm
**Status: LIVE**
- ai-news-repo-model-radar @ 08:00 (36127d01a832)
- midnight-daily-wrap @ 00:00 (a0af2260ea69)
- night-shift-orchestrator hourly (overnight build queue)
- Logs: ~/mindbotz-studio/logs/

## 10. Infrastructure map
- VPS 100.118.239.109 — Hermes, tunnels, cron, storage
- PC 100.84.222.44 — RTX 4070, ComfyUI (tunnel 8188), models: krea2_turbo, ideogram4, wan2.1, LTX2.5, TRELLIS, acestep, Qwen3-TTS
- Phone — Tailscale mesh citizen
- Comfy Cloud — MCP (h3-chain-film skill), H3/T2V/I2V/R2V/FLF templates
- Netlify — 12 sites
- GitHub Sonic-Forage org — 78 repos
- HF TheMindExpansionNetwork — 4 datasets
