# Comfy agent task: World Weaver Orbit-7 proof

## Objective

Produce one 15-second, full-360, clockwise environment loop from the Orbit-7 pilot while preserving topology.

## Preconditions

- ComfyUI 0.34.0 or newer; `MiniMaxH3AddGuide` must be available.
- Use native MiniMax H3 Ref2VA weights, not FastH3 Preview.
- Do not expose or request account credentials.
- Require manual approval immediately before any paid/cloud queue action.

## Run A — required baseline

1. Load a native MiniMax H3 workflow.
2. Set duration to 15 seconds; verify the resulting latent length is 362 frames.
3. Use 24 fps and a resolution divisible by 32.
4. For the first proof, use the workflow's low-cost preview resolution.
5. Chain seven `MiniMaxH3AddGuide` image guides using the clean H1–H7 files.
6. Set frame indices to `0, 60, 120, 181, 241, 301, 361`.
7. Use the prompt in `H3_PROMPT.md`.
8. Use the normal-quality sampler path; keep Turbo disabled.
9. Queue only after manual cost approval.
10. Save workflow JSON, exact seed, output MP4, runtime, VRAM peak, and errors beside the experiment record.

## Run B — only after Run A succeeds

1. Use native Ref2VA.
2. Connect clean H1–H7 as `<Picture 1>` through `<Picture 7>`.
3. Connect the continuous sweep MP4 as `<Video 1>`.
4. Use `ref_image_size=max`, 20 steps, and the `beta` scheduler.
5. Preserve the same prompt, resolution, and duration as Run A.

## Acceptance test

- H7 matches H1 closely enough to loop without a visible scene redesign.
- The camera rotates rather than cutting or dissolving between anchors.
- Doors, openings, graffiti, pillars, vegetation, and floor boundaries remain persistent.
- No H-labels, captions, or numbers appear in the generated world.
- Save failures too; failed topology is training evidence.
