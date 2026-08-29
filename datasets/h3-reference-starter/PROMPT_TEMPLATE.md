# MiniMax H3 prompt templates

## Preferred: four separate images

Connect the four files in A1 → A2 → A3 → A4 order so they become `<Picture 1>` through `<Picture 4>`.

```text
subject_definitions:
<Subject 1> is one fixed physical environment defined jointly by <Picture 1>,
<Picture 2>, <Picture 3>, and <Picture 4>. The pictures are clockwise views from
the same camera center. <Picture 1> faces front, <Picture 2> faces right,
<Picture 3> faces back, and <Picture 4> faces left. Preserve the exact
architecture, scale, materials, lighting, openings, signs, and persistent
landmarks across all four views.

summary:
[reference generation] Generate one continuous five-second first-person camera
turn inside <Subject 1>. The camera rotates clockwise from the region shown in
<Picture 1> toward <Picture 2>. This is one continuous world, not four rooms.

retention_analysis:
<Subject 1>: fully_preserved - do not redesign, duplicate, remove, move, or
replace the persistent geometry and landmarks shown across the references.

detailed_description:
[Shot 1] A stable chest-height camera begins facing the composition in
<Picture 1> and slowly pans clockwise into the overlapping region in
<Picture 2>. Features leaving the frame remain physically behind the camera.
Straight architectural lines remain straight and fixed. No cuts, teleportation,
object morphing, layout changes, new doors, new windows, text changes, people,
or camera translation.
```

## Fallback: one atlas image

Upload only `atlas_2x2_clockwise.jpg` as `<Picture 1>`.

```text
<Picture 1> is a labeled 2x2 atlas of one fixed physical environment. Its
top-left quadrant A1 faces front, top-right A2 faces right, bottom-right A3
faces back, and bottom-left A4 faces left. Reading clockwise A1 to A2 to A3 to
A4 completes the same 360-degree world. Treat repeated edge features as the
same physical landmarks. Generate a continuous five-second clockwise camera
turn from A1 toward A2. Preserve all geometry, scale, materials, lighting,
openings, signs, and landmarks. No cuts, morphing, teleportation, redesign,
new objects, or copied label text in the generated scene.
```
