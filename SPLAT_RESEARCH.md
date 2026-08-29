# Synthetic Gaussian Splat Generation — Research Notes

> For agents continuing this work. Everything we know about turning our synthetic
> 360 content into Gaussian splats, plus what's still unexplored.

## Why splats are the endgame

Gaussian Splatting = the format that makes 3D worlds explorable at 60fps in a browser.
Our 360 panos are flat images; splats give them depth, parallax, and real camera freedom.
The w0rldw3aver360 project's full promise: **stand inside an AI-generated world**.

## What we have that splat pipelines need

| Input type | Status | Source |
|---|---|---|
| Single equirect panos | ✅ 12 CC0 + 1 synthetic (Ancient Hall) | Poly Haven + Qwen 360 LoRA |
| Walking video (perspective) | ✅ 7 chained clips | H3 chains (walk_catalog) |
| Multi-view with parallax | ⚠️ partial — chains drift from true geometry | H3 (plausible, not physical) |
| Loop-closure video | ❌ not yet — the killer feature to build | H3 chain returning to start frame |
| Depth maps | ❌ not yet | DA360 / DAP / MoGe can generate |
| SfM poses | ❌ not yet | COLMAP spherical model |

## Unreal known-pose dataset branch

Unreal can serve as a deterministic multi-view data factory rather than relying on pose recovery from generated video. A capture plugin exports rendered views, exact camera intrinsics/extrinsics, and an initial point cloud; identical cameras can then render paired visual styles.

- Full experiment plan: `research/UNREAL_SPLAT_DATASET_FORGE.md`
- Preferred first candidate: UnrealToColmap, because its Fab listing explicitly permits AI use and supports UE 5.8
- SplatCapture is technically suitable but its Fab listing currently marks AI usage as disallowed; obtain clarification before using it for training
- First canary: one cyberpunk apartment, base splat plus one geometry-matched Unreal-native restyle
- Do not independently edit every camera view; preserve the camera graph and use multi-view/3DGS-aware editing

## Methods ranked by effort

### 1. SPAG-4D — direct pano → splat (FASTEST WIN, not yet installed)
- https://github.com/cedarconnor/SPAG4d
- 4 backends: DA360 (~2s, 2GB, commercial-OK), DAP (metric depth), PaGeR (12GB, non-comm), SHARP 360 (8GB, best detail, non-comm)
- **Install on PC (12GB 4070 fits DA360 + SHARP)** or RunPod
- Includes OmniRoam v2 disocclusion repair (fills holes behind objects)
- Exports PLY / SPZ / SOG
- **Action:** install, run 12 panos → 12 ply, embed web viewer in explorer site

### 2. GGPS-style: COLMAP spherical + 3DGS (BEST QUALITY, needs video)
- From our STUDY.md: ERP panos → openMVG/COLMAP spherical → LichtFeld Studio --undistort
- Reference: bigsur-360-colmap (PSNR 31.6 on drone data)
- Needs: multi-view VIDEO with real parallax — our chained walks are *plausible* not *physical*
- **Loop-closure walk hack:** chain clips until last ≈ first frame → camera path closes → SfM behaves
- **Action:** test on one walk (sunset_forest 4-clip chain) vs one NASA static clip

### 3. MoGe — pano → textured mesh (Comfy Cloud template exists)
- `3d_moge_panorama_to_mesh` template on Comfy Cloud — verified available
- Outputs GLB (mesh, not splats) — useful for reference/proxy, or mesh→splat conversion
- **Action:** run 1 pano through it to see quality (1 job)

### 4. Feed-forward splat networks (RESEARCH)
- FlexSplat / ZipSplat / GlobalSplat / EcoSplat — multi-view images → splats, no per-scene optimization
- All need posed multi-view input; none handle equirect natively; licenses mostly research
- **Text→splat does not exist yet** — if our (caption, ply) pairs accumulate, we could train the first one. That's the moonshot; needs 10k+ pairs (SPAG-4D at 2s/pano makes this feasible once world synthesis flywheel runs)

## The flywheel (how splats scale)

```
Qwen 360 LoRA → new synthetic world pano (2s, CC0, ours)
     ↓
SPAG-4D → .ply splat (2s)
     ↓
H3 chain → walkthrough video (5s/clip)
     ↓
loop-closure pass → closed camera path
     ↓
(dataset grows: caption + pano + splat + walk per world)
     ↓
v2 dataset → eventually train text→splat directly
```

Every stage is fast and unattended-able. The constraint is orchestration, not compute.

## Open questions to resolve experimentally

1. Does COLMAP spherical SfM work on H3-chained frames (synthetic parallax) or only real captures?
2. SPAG-4D DA360 vs SHARP 360 on Poly Haven panos — visual quality delta worth the license trade?
3. Can loop-closure chains actually close (PSNR >30 on last-to-first seam)?
4. Splat from Ancient Hall (synthetic pano) vs real pano — does the LoRA's output reconstruct cleanly?
5. Web viewer: model-viewer vs gsplat.js vs antimatter15/splat — which streams SPZ/SOG best?

## Cost snapshot

- SPAG-4D on 4070: $0 (local), ~1 min for all 12 panos
- SPAG-4D on pod: ~$0.75 for the same (if PC asleep)
- COLMAP+LichtFeld on pod: ~$2-5 per scene (1-2h)
- MoGe on Comfy Cloud: 1 job per pano (video_* pricing, observed $0 so far)
