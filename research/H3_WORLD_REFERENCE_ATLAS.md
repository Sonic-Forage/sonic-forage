# MiniMax H3 World Reference Atlas — Multi-View Animation Plan

> Status: research and experiment specification
> Created: 2026-08-29
> Parent plan: `research/UNREAL_SPLAT_DATASET_FORGE.md`
> Goal: turn posed Unreal views, panoramas, splats, and camera routes into coherent H3 reference-driven world animation.

## Executive answer

For MiniMax H3, the best input is **not initially one image containing every angle**.

H3-Base-Ref2VA natively accepts:

- up to 9 reference images;
- up to 3 reference videos, each 2–15 seconds, with 15 seconds total;
- up to 3 reference audio clips, with 15 seconds total;
- at most 12 mixed reference files.

Connect individual views separately and reference them by connection order as `<Picture 1>`, `<Picture 2>`, and so on. Give every reference one explicit job.

A spliced contact sheet remains valuable as:

1. a fallback for a one-image-only workflow;
2. a portable human-readable world identity card;
3. training material for a future World Weaver multi-view/atlas LoRA.

Official sources:

- Model card: https://huggingface.co/MiniMaxAI/MiniMax-H3
- API input rules: https://platform.minimax.io/docs/api-reference/video-generation-v2-create
- ComfyUI H3 guide: https://docs.comfy.org/tutorials/video/minimax/minimax-h3
- Official Ref2VA prompt guide: https://huggingface.co/MiniMaxAI/MiniMax-H3/blob/main/docs/VIDEO_PROMPT_WRITING_GUIDE_ref_en.md
- Official integration index: https://github.com/MiniMax-AI/awesome-minimax-h3-integration

## Ready-to-run CC0 starter pack

The repository now includes [`datasets/h3-reference-starter/`](../datasets/h3-reference-starter/README.md):

- three legally reusable Poly Haven environments;
- four ordered 1024×1024 cardinal views per environment;
- one labeled clockwise 2×2 atlas per environment;
- one 2048×1024 equirectangular source panorama per environment;
- source URLs, CC0 provenance, manifest, checksums, exact build script, and H3 prompt templates.

Run the first Ref2VA ablation with four separate A1–A4 files, then repeat with the atlas only. These views rotate around one camera center and are intentionally a reference-conditioning baseline. They do not contain the translated-camera parallax required for Gaussian-splat reconstruction.

The first Orbit-7 implementation is also ready at [`datasets/h3-reference-starter/abandoned_workshop_02/orbit7_pilot/`](../datasets/h3-reference-starter/abandoned_workshop_02/orbit7_pilot/README.md). It maps H1–H7 to a complete 360° loop, with H7 returning to H1. Native 15-second H3 uses 362 frames on the `17k + 5` grid, so the seven recommended guide frames are `0, 60, 120, 181, 241, 301, 361`.

## H3's two model families must not be confused

| Family | Best use | Inputs | Important constraint |
|---|---|---|---|
| FL2VA | Highest-quality anchored clip and first/last-frame interpolation | text plus zero, one, or two keyframe images | API first/last frames cannot be mixed with reference roles |
| Ref2VA | World, character, style, motion, camera, and sound reference | text plus multiple images/video/audio | More flexible references, but raw output can be weaker than FL2VA |
| AddGuide workflow | Force a clip through known images at chosen frame indices | chained image/audio guides in native ComfyUI | Experimental control path; requires current ComfyUI |
| Ref2VA plus reference video | Transfer camera movement or temporal rhythm while pictures hold world identity | pictures plus motion video, optionally audio | State each asset's job explicitly |

The API treats image-to-video/FL2VA and Ref2VA as mutually exclusive request modes. Do not connect a `first_frame` role and a `reference_image` role in the same API request.

## Recommended World Atlas reference pack

Start with four views, not nine. Four strong, overlapping views are easier for H3 to bind than nine weak or contradictory views.

### Four-view pack

| H3 label | World Weaver meaning | Capture requirement | Prompt job |
|---|---|---|---|
| `<Picture 1>` | Hero/identity view | strongest room composition | definitive architecture, palette, lighting, and atmosphere |
| `<Picture 2>` | Right/east continuation | 30–60 degrees from Picture 1 with strong overlap | geometry and objects leaving the right side of Picture 1 |
| `<Picture 3>` | Rear/south continuation | overlaps Picture 2 | back wall, doorway, and hidden objects |
| `<Picture 4>` | Left/west continuation | overlaps Pictures 1 and 3 | closes the room identity loop |

Do not jump by 90 degrees unless the room is simple and has distinctive landmarks. For video continuity, 30–60-degree overlap is safer.

### Expanded pack, only after the four-view test

| H3 label | Purpose |
|---|---|
| `<Picture 5>` | ceiling, upper architecture, signage, and light fixtures |
| `<Picture 6>` | floor, lower furniture, walkable path, and material detail |
| `<Picture 7>` | close view of the most important persistent prop |
| `<Picture 8>` | visual style and material reference, not a camera anchor |
| `<Picture 9>` | storyboard or final-composition reference |

Nine images are a maximum, not a quality target. Every unused reference slot is one less opportunity for the model to misunderstand us.

## The contact-sheet fallback

If a specific cloud template exposes only one image input, use a **2×2 atlas**, not a 3×3 sheet.

Recommended format:

- 4096×4096 PNG or high-quality JPEG/WebP, under the platform size limit;
- four equal 2048×2048 source tiles before upload;
- reading order: top-left Picture A, top-right Picture B, bottom-left Picture C, bottom-right Picture D;
- narrow neutral gutters;
- no decorative borders;
- no large text over the scene;
- same exposure, color grade, and camera height;
- 30–60-degree overlap between adjacent views.

ComfyUI's `ref_image_size=max` keeps at most a 2048-pixel short edge. A 2×2 sheet therefore leaves roughly 1024 pixels per tile after reference resizing. A 3×3 sheet leaves only roughly 682 pixels per tile. Separate images preserve much more information.

H3 does not natively assign `<Picture 1A>` or `<Picture 1B>` to quadrants. The whole contact sheet is only `<Picture 1>`. The prompt must describe its quadrants:

```text
<Picture 1> is a 2×2 world atlas of the same cyberpunk apartment.
Its top-left quadrant is the north-facing hero view.
Its top-right quadrant is the east-facing continuation.
Its bottom-left quadrant is the south-facing continuation.
Its bottom-right quadrant is the west-facing continuation.
All four quadrants define one continuous room with identical architecture,
objects, materials, scale, and lighting.
```

Visible A/B/C/D labels may help the text encoder but may also leak into generated signs or textures. Use fixed quadrant order and an external manifest first. Test tiny border labels only as an ablation.

Do not repeat the same tile to “increase weight.” Duplication can make the model over-focus on that composition or treat it as a recurring shot. Weight a view through a clearer prompt job, better crop, separate input, or `ref_image_size=max`.

## Better than a sheet: three generation modes

### Mode 1 — Ref2VA ordered pictures

Use separate images and connect them in deterministic order.

Example assignment:

```text
subject_definitions:
<Subject 1> is the single cyberpunk apartment whose definitive appearance,
architecture, materials, object placement, neon palette, and atmosphere come
from <Picture 1>, <Picture 2>, <Picture 3>, and <Picture 4>.
<Picture 1> provides the hero composition and north wall.
<Picture 2> provides the continuous east side and right-hand doorway.
<Picture 3> provides the rear wall and kitchen alcove.
<Picture 4> provides the west side and closes the room back toward <Picture 1>.

summary:
[reference generation] Generate one continuous first-person walk through
<Subject 1>. Preserve the room as one fixed physical space. Do not redesign,
replace, duplicate, or move persistent objects between viewpoints.

retention_analysis:
<Subject 1>: fully_preserved - retain the same layout, room dimensions,
materials, lighting, furniture, doors, windows, signage, and persistent props
shown across <Picture 1> through <Picture 4>.

detailed_description:
[Shot 1] A chest-height first-person camera begins in the region shown by
<Picture 1> and walks slowly toward the right-hand doorway. The camera pans
toward the overlapping region in <Picture 2>; objects leaving the left edge
remain behind the camera rather than changing form. It continues through the
same fixed apartment toward the rear alcove shown in <Picture 3>. Natural
footsteps and quiet room ambience remain spatially coherent. No cuts, morphing,
teleportation, or architecture changes.
```

Start with one five-second shot. Do not ask Ref2VA for a complete 15-second tour until the five-second result is stable.

### Mode 2 — Pictures define the world; video defines movement

This is probably the strongest practical H3 mode for World Weaver.

- `<Picture 1–4>`: world identity and fixed layout.
- `<Video 1>`: camera path, walking speed, head bob, turns, and timing.
- `<Audio 1>`: footsteps or ambience only if needed.

Prompt relationship:

```text
<Subject 1> is the cyberpunk apartment defined by <Picture 1> through
<Picture 4>. <Video 1> provides camera movement, walking speed, turn timing,
and stabilization only. Do not copy the scene, person, colors, or objects from
<Video 1>. Recreate its motion inside <Subject 1>.
```

For a clean reference-video source, render a low-detail or neutral-shaded Unreal camera route. This isolates motion from appearance and reduces accidental style transfer.

### Mode 3 — Guide images anchored at exact video frames

Current native ComfyUI provides `MiniMaxH3AddGuide`, which can anchor an image or short clip at an arbitrary `frame_idx`. Multiple guide nodes can be chained.

Example five-second/approximately 124-frame route:

| Guide | Frame | Role |
|---|---:|---|
| A1 | 0 | starting view |
| A2 | 30 | first overlap/turn |
| A3 | 60 | mid-route composition |
| A4 | 90 | return/second turn |
| A5 | -1 | ending view |

This is the closest technical match to the A1 → A2 → A3 → A4 concept.

Rules:

- neighboring guides must overlap visually;
- camera position and height changes must be physically reachable;
- avoid inserting a view behind a wall or across a closed door;
- reserve enough frames for the required movement;
- use the same aspect ratio and grade;
- test with four anchors before adding more;
- measure whether the transition walks, pans, or merely morphs.

The guide path and the Ref2VA path are separate experiments. Do not assume they can be combined until the exact native workflow is validated.

## The existing H3 contact-sheet breakthrough

A community project has already demonstrated the core idea:

- LoRA: https://huggingface.co/matlod/minimax-h3-turnaround
- ComfyUI nodes: https://github.com/matlowai/ComfyUI-H3-ContactSheet

It repurposes five H3 time slots as five jointly denoised but independently decoded images, producing coordinated turnaround views from one reference image. This is not a normal video. Decoding it as one video smears the slots together; a dedicated contact-sheet decoder treats each slot as a standalone image.

This proves that H3's temporal axis can become a **viewpoint slot axis**.

The released LoRA targets character turnarounds, so do not assume it understands rooms or world geometry. The World Weaver research opportunity is to train an equivalent room/world adapter using Unreal's exact camera poses.

## Proposed World Weaver Orbit-5 LoRA

### Objective

Input:

- one hero view or one equirectangular panorama;
- instruction describing a world and camera rig.

Output:

- five coherent perspective views of the same fixed world;
- every view uses a predetermined camera relationship;
- decoded as images, not a movie.

### Orbit-5 slot definition

Use fixed semantic slots across every training sample:

| Slot | Camera meaning |
|---|---|
| 1 | hero/front view at yaw 0 degrees |
| 2 | yaw +45 degrees |
| 3 | yaw +90 degrees |
| 4 | yaw +135 degrees |
| 5 | yaw +180 degrees |

A second pack can cover 180–360 degrees, or a different LoRA can use four cardinal views plus one ceiling/floor/detail view.

A pure rotation around one camera center provides panoramic identity but no translation/parallax. It is useful for reference conditioning, not sufficient by itself for training a Gaussian splat. Splat reconstruction must continue using the larger translated Unreal camera graph.

### Training samples from Unreal

For each scene/location/style:

- hero input image;
- five fixed-yaw target views;
- exact intrinsics/extrinsics;
- depth, normals, masks, and object IDs;
- scene/style caption;
- world trigger token;
- camera-slot instruction;
- asset and model licenses.

Use identical camera rigs across many rooms and styles so the LoRA learns the slot meaning rather than memorizing one apartment.

### Training reality check

MiniMax publishes weights and inference code but no official H3 trainer. Current training paths are community implementations.

- `IAmIronMan42/MiniMax-H3-FineTuning` trains video/audio LoRAs at large multi-GPU scale, but its current documentation says reference media are not yet encoded into the conditioning sequence.
- AI Toolkit supports H3 T2V/I2V training, while Ref2VA support remains rapidly changing and must be verified at a pinned commit.
- Inline Studio and Fizgig claim consumer-GPU LoRA training, but their exact Ref2VA conditioning and reproducibility need a smoke test.
- The existing turnaround LoRA is the most direct evidence that a viewpoint-slot adapter is feasible.

Do inference experiments before building the training stack.

## Dataset additions for H3

Extend each World Weaver scene with:

```text
h3/
  references/
    picture_01_hero.png
    picture_02_east.png
    picture_03_rear.png
    picture_04_west.png
    atlas_2x2.png
    references.json
  motion_refs/
    unreal_walk_neutral_001.mp4
    unreal_orbit_neutral_001.mp4
  audio_refs/
    room_tone.wav
    footsteps.wav
  guides/
    guide_000.png
    guide_030.png
    guide_060.png
    guide_090.png
    guide_123.png
    guide_map.json
  outputs/
    experiment_id/
      request.json
      prompt.txt
      result.mp4
      metrics.json
```

Example `references.json`:

```json
{
  "scene_id": "cyber_apartment_001",
  "style_id": "cyberpunk_v1",
  "connection_order": [
    {"label": "<Picture 1>", "file": "picture_01_hero.png", "job": "world identity and north wall"},
    {"label": "<Picture 2>", "file": "picture_02_east.png", "job": "east continuation and doorway"},
    {"label": "<Picture 3>", "file": "picture_03_rear.png", "job": "rear wall and alcove"},
    {"label": "<Picture 4>", "file": "picture_04_west.png", "job": "west continuation and loop closure"}
  ],
  "ref_image_size": "max",
  "world_coordinates": "Unreal centimeters, Z-up",
  "capture_rig": "record exact Unreal rig version"
}
```

## First experiment matrix

Hold the prompt, seed, duration, resolution, and route constant wherever the mode permits.

| ID | Mode | Inputs | Question |
|---|---|---|---|
| H3-A | FL2VA | hero first frame only | raw quality ceiling |
| H3-B | Ref2VA | hero as one separate image | one-reference world retention |
| H3-C | Ref2VA | four separate overlapping images | benefit of real multi-image conditioning |
| H3-D | Ref2VA | one 2×2 atlas containing the same four views | sheet penalty versus separate images |
| H3-E | Ref2VA | four pictures plus neutral Unreal motion video | best appearance/motion separation |
| H3-F | AddGuide | four or five frame-indexed guides | explicit route control versus reference conditioning |
| H3-G | Ref2VA | up to nine images | whether maximum context improves or confuses |
| H3-H | Ref2VA turbo | best prior setup plus four-step LoRA | quality/cost tradeoff |

Evaluation settings:

- start at five seconds;
- use standard Ref2VA 20 steps, then 25 for the winner;
- keep Turbo off during the first quality comparison;
- set `ref_image_size=max` for identity/architecture tests;
- record connection order exactly;
- use one fixed output ratio, preferably 16:9 for the first run;
- save request JSON, prompt, seed, workflow revision, checkpoint hash, runtime, and cost.

## World consistency scoring

A clip should be scored on more than “looks cool.”

| Metric | What to examine |
|---|---|
| Landmark retention | doors, windows, signs, furniture, and persistent props remain recognizable |
| Topology | paths, walls, corners, and openings do not move or swap |
| Cross-view identity | overlapping regions match the supplied pictures |
| Transition type | camera appears to move rather than scene morphing |
| Temporal flicker | textures and light do not crawl between frames |
| Camera adherence | motion follows the requested/reference route |
| Style retention | palette, materials, fog, lighting, and visual era remain fixed |
| Splat compatibility | frames retain enough stable features and parallax for registration |
| Audio coherence | footsteps/actions sync; passive ambience does not dominate or drift |
| Loop seam | last-to-first similarity plus landmark/camera-pose plausibility |

For splat research, add feature-track survival and pose-recovery tests. A visually convincing H3 clip may still have non-physical parallax and fail 3D reconstruction.

## Continuous generation strategy

H3 generates clips up to 15 seconds. For longer worlds:

1. Generate a validated five-second segment.
2. Extract its final frame and audio tail.
3. Carry motion context into the next block.
4. Reuse the same ordered World Atlas references.
5. Add the next route guides or motion reference.
6. Validate the seam before concatenation.
7. Periodically re-anchor to an Unreal ground-truth view to prevent world drift.

The community `ComfyUI-H3-Motion-Context` path carries the previous block's final frame and audio into the next block. Treat it as experimental until pinned and tested.

## Recommended execution order

1. Update ComfyUI to a version containing native H3 Ref2VA and AddGuide support.
2. Build four overlapping Unreal views from one legal cyberpunk apartment.
3. Test four separate pictures against one 2×2 atlas.
4. Test four pictures plus one neutral Unreal motion-reference video.
5. Test four frame-indexed AddGuide anchors.
6. Select the most spatially stable method, not merely the prettiest result.
7. Render the same experiment from a trained splat and compare.
8. Only then create 9-view packs or longer chained clips.
9. Build Orbit-5 training samples across multiple worlds.
10. Attempt a World Weaver H3 LoRA only after the inference baseline and training implementation are pinned.

## Current recommendation

**Best immediate path:** four separate overlapping Unreal images in Ref2VA, plus a neutral Unreal camera-motion reference video.

**Best route-control experiment:** four or five images anchored at chosen frames with `MiniMaxH3AddGuide`.

**Best one-image fallback:** a 2×2, 4096×4096 atlas with fixed quadrant order and `ref_image_size=max`.

**Best research moonshot:** train a World Weaver Orbit-5 LoRA that converts a hero view into five coordinated world views by treating H3's timeline as a viewpoint-slot axis.

The contact sheet is therefore not discarded. It becomes one branch of a stronger system instead of being forced to do every job.
