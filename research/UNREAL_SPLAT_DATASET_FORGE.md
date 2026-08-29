# Unreal Splat Dataset Forge — World Weaver Research Plan

> Status: research proposal
> Created: 2026-08-29
> Owner: Mind Expander
> Agent roles: Hermes executes captures/training; Codex maintains experiment design, validation, and repository records.

## The idea

Use Unreal Engine as a deterministic synthetic-data factory:

1. Build or select a source world such as a cyberpunk apartment.
2. Render overlapping views from known cameras.
3. Export exact camera intrinsics, camera poses, and an initial point cloud.
4. Produce alternate visual styles while keeping geometry and cameras fixed.
5. Train and validate a Gaussian Splat for every style.
6. Record controlled camera paths and 360 footage for future continuous-video and world-generation training.

The important shift is that the images are not an unordered folder. They form a **camera graph**. Each image has a known position, rotation, lens, and set of neighboring views. This is the machine-readable version of the “arrows connecting the pictures” concept.

## Research finding: plugin choice

### Preferred production candidate

**Unreal to Gaussian Splat — Automated COLMAP Dataset Generator**

- Fab: https://www.fab.com/listings/d5ce0b45-8c80-486d-8316-882856198875
- Supports Unreal Engine 5.5, 5.6, 5.7, and 5.8 on Windows.
- Fab currently marks “Allows usage with AI: Yes.”
- Exports RGB views, COLMAP camera files, colored point cloud, and optional masks.
- Product, path, room-volume, manual, and aerial capture rigs.
- Supports Lumen or path tracing and custom Movie Render Queue presets.
- Intended for Postshot, LichtFeld Studio, and other COLMAP-compatible trainers.

This is the recommended first purchase/test because the intended AI-dataset use is explicit and its capture modes fit rooms, corridors, worlds, and continuous paths.

### Secondary technical candidate — license clarification required

**SplatCapture by KazTech**

- Fab: https://www.fab.com/listings/d8fd9d3a-875e-4054-92ee-d592e9da80c6
- Documentation: https://sites.google.com/view/splatcapture
- Editor-only dataset generator with collision-aware grid/spline capture.
- Six-camera rig at approximately 100-degree FOV or 22-camera rig at approximately 53-degree FOV.
- Exports PNG/EXR, COLMAP cameras/images, and points3D PLY/TXT.
- Provides point-density preview and accepts manual cameras.
- Fab currently marks “Allows usage with AI: No.”

Do **not** use SplatCapture for the proposed model-training dataset until the seller or applicable Fab license clearly confirms the intended use. The plugin is technically aligned with the project, but the marketplace flag conflicts with our use case.

### Separate tool category: splat rendering

Dataset-generation plugins create posed training views. They do not necessarily render trained splats inside Unreal. Runtime/editor viewing is a later stage and should be benchmarked separately with tools such as NanoGS or another UE 5.8-compatible renderer.

## What the exported “arrows” actually are

For each image, preserve:

- **Intrinsics:** width, height, focal length/FOV, principal point, camera model.
- **Extrinsics:** world-to-camera rotation and translation.
- **Capture graph:** nearest cameras, distance, angular difference, overlap estimate.
- **Scene geometry:** point cloud plus optional depth, normals, object IDs, and masks.
- **Appearance state:** lighting rig, exposure, materials, style ID, prompt, model/checkpoint, seed.
- **Provenance:** Unreal project/level, engine version, plugin version, asset licenses, capture timestamp.

COLMAP stores the essential intrinsics and extrinsics in `cameras.txt` and `images.txt`. The original camera pose must remain authoritative. We should not ask an image model to infer or redraw the camera map.

## Core dataset layout

```text
worldweaver-forge/
  scenes/<scene_id>/
    scene.json
    geometry/
      source_mesh_or_level.txt
      points3D.ply
    cameras/
      cameras.txt
      images.txt
      camera_graph.json
    styles/
      base/
        images/
        aux/depth/
        aux/normals/
        aux/masks/
        manifest.jsonl
      cyberpunk_v1/
        images/
        aux/depth/
        aux/normals/
        aux/masks/
        manifest.jsonl
    trajectories/
      walk_001/
        frames/
        poses.jsonl
        video.mp4
        trajectory.json
    splats/
      base/
      cyberpunk_v1/
    evaluations/
      reconstruction.json
      cross_view.json
      video.json
```

Every styled image must reuse the base view ID and camera pose. Never rename views in a way that breaks the pose mapping.

Suggested manifest record:

```json
{
  "scene_id": "cyber_apartment_001",
  "style_id": "cyberpunk_v1",
  "view_id": "cam_000142",
  "image": "images/cam_000142.png",
  "base_image": "../base/images/cam_000142.png",
  "camera_id": 1,
  "pose_id": 142,
  "neighbors": ["cam_000136", "cam_000141", "cam_000143"],
  "depth": "aux/depth/cam_000142.exr",
  "normal": "aux/normals/cam_000142.exr",
  "mask": "aux/masks/cam_000142.png",
  "prompt": "a lived-in cyberpunk apartment...",
  "seed": 42042,
  "edit_model": "record exact model and revision",
  "license_state": "internal-research"
}
```

## Three restyling experiments

We should test three methods on the same room and identical camera graph.

### Track A — Unreal-native restyle: ground-truth control

Change materials, lights, decals, props, fog, and post-processing inside Unreal, then render every style from the exact same cameras.

Why this matters:

- Perfect multi-view consistency.
- Exact paired before/after views.
- Best training data for an edit or style-transfer model.
- Establishes the maximum quality achievable before generative editing.

Start with:

1. Base apartment.
2. Cyberpunk neon.
3. Bioluminescent overgrowth.
4. Ancient ritual technology.

This may be the highest-value dataset in the entire plan because geometry and pose are identical across styles.

### Track B — pose-preserving generative restyle

Do not edit each image independently.

1. Select anchor views across the camera graph.
2. Edit anchors using the same reference image/style adapter, prompt, seed family, depth, normals, and segmentation controls.
3. Propagate edits from anchors to neighboring cameras in graph order.
4. Reproject edited pixels through depth into neighboring views.
5. Detect conflicts, temporal flicker, and geometry changes.
6. Inpaint only disoccluded or unresolved regions.
7. Refit a new splat using the original camera poses and edited RGB views.

Candidate research implementations:

- GaussCtrl: https://github.com/ActiveVisionLab/gaussctrl
- GaussianEditor: https://github.com/buaacyw/GaussianEditor
- EditSplat: https://github.com/kuai-lab/cvpr25_EditSplat
- DGE: https://github.com/silent-chen/DGE

GaussCtrl is the first candidate because it is designed for depth-conditioned, multi-view-consistent text-driven 3DGS editing. These research tools require license and hardware review before production use.

### Track C — train base splat first, then edit in 3D

1. Train the clean base splat.
2. Render its known cameras and depth.
3. Apply a 3DGS-aware editor.
4. Optimize the edited splat while enforcing geometry and multi-view consistency.
5. Export new styled PLY/SPZ/SOG variants.

This is likely safer than independently restyling hundreds of 2D frames because the splat becomes the consistency layer.

## Seamless cleanup and inpainting

“Inpainting the seams” should mean filling missing 3D visibility, not painting over camera disagreements.

Use this order:

1. Train a baseline splat.
2. Render novel-view coverage and confidence maps.
3. Identify holes, floaters, low-confidence regions, and true disocclusions.
4. Generate repairs conditioned on neighboring views, depth, normals, and masks.
5. Project repairs back into 3D.
6. Re-optimize the splat.
7. Re-render every holdout camera and reject repairs that only work from one angle.

SPAG-4D’s refinement path is useful for the single-panorama branch, but Unreal known-pose datasets should retain their real synthetic geometry and use multi-view repair rather than flattening through a single panorama.

SPAG-4D canonical repository: https://github.com/cedarconnor/SPAG4d

## First cyberpunk-apartment experiment

### Capture tiers

Run small before running expensive:

| Tier | Capture | Purpose |
|---|---|---|
| Smoke | 6-camera rig, preview resolution, sparse room grid | Verify pose import and trainer compatibility |
| Baseline | 6-camera rig, 2K PNG, moderate room grid plus manual corners | First quality splat |
| Dense | 22-camera rig or reduced spacing, high-quality PNG/EXR | Determine whether extra views materially improve quality |

Exact camera count should be recorded rather than assumed. Storage and training cost should be measured from the smoke run and projected before dense capture.

### Trainers to compare

- Postshot: fast commercial baseline.
- LichtFeld Studio: preferred reproducible/local workflow if stable.
- Nerfstudio Splatfacto or another COLMAP-compatible open trainer: research control.

Use the same dataset and holdout cameras for every trainer.

### Minimum acceptance gates

A run is not successful merely because a PLY opens.

- At least 90% of planned views rendered and mapped to valid poses.
- No cameras inside walls, furniture, or outside the intended volume.
- Hold out 10% of cameras from training.
- Record holdout PSNR, SSIM, and LPIPS.
- Record training time, peak VRAM, source size, splat size, and render FPS.
- Inspect thin geometry, mirrors, glass, emissive lights, doorways, and corners separately.
- Measure cross-view style consistency on neighboring views.
- Render a fixed walk path and measure flicker/temporal consistency.
- Preserve the untouched base dataset so every edit can be compared or reversed.

## Continuous video and FastH3 direction

After a room produces a stable splat:

1. Author deterministic Unreal camera splines for walk, orbit, crouch, doorway, and room-to-room motion.
2. Export RGB video plus per-frame camera pose, depth, normals, masks, and audio/event metadata.
3. Render the same trajectory across multiple styles.
4. Render the trained splat on the identical trajectory.
5. Store paired Unreal-ground-truth, splat-render, and generative-video sequences.

This creates useful data for:

- camera-trajectory-conditioned video models;
- continuous navigation and long-video consistency;
- splat-to-video and video-to-splat studies;
- future MiniMax H3 adapters if licensing/training support permits;
- FastVideo post-training and distillation experiments.

FastVideo currently provides a post-training/inference framework and a 4-step DMD2-distilled FastH3 preview:

- Framework: https://github.com/hao-ai-lab/FastVideo
- Model: https://huggingface.co/FastVideo/FastVideo-Minimax-FastH3-Preview-v0.2

The FastH3 preview is a large dual video/audio model under the MiniMax H3 Community License. Treat H3 fine-tuning as a later licensed GPU project; the immediate goal is to capture a future-proof trajectory dataset rather than assume the 12GB local GPU can train the full model.

## Recommended execution order

1. Confirm or purchase the AI-allowed UnrealToColmap plugin.
2. Choose one legally clean cyberpunk apartment source scene.
3. Run the smoke capture.
4. Validate COLMAP import in one trainer.
5. Train and evaluate the base splat.
6. Run Unreal-native paired restyles.
7. Compare Track B and Track C generative restyling.
8. Add inpainting only after coverage failures are measured.
9. Export deterministic trajectory packs.
10. Expand to additional rooms/worlds only after the schema and gates pass.

## Decision log

| Decision | Current answer | Reason |
|---|---|---|
| First plugin | UnrealToColmap candidate | UE 5.8 support and AI usage explicitly allowed |
| First scene | One cyberpunk apartment | Bounded interior with difficult materials and strong style signal |
| First restyle | Unreal-native | Creates geometry-consistent control dataset |
| First generative method | 3DGS-aware edit | Safer consistency than independent image edits |
| First output | Base + one styled splat | Proves the complete loop before scaling |
| H3/FastH3 training | Later phase | Large model, license, compute, and data-format validation required |
