#!/usr/bin/env bash
set -euo pipefail

pack_root="${1:-datasets/h3-reference-starter}"
source_root="${pack_root}/.source-cache"
mkdir -p "$source_root"

declare -A expected_md5=(
  [abandoned_workshop_02]="df639e9a3e30683bf4dabc13e1ab4ebc"
  [small_cathedral]="c9cdbd6165bc232a4dd54cd82bbe69c2"
  [metro_vijzelgracht]="3d21570ca2502e85b72a467b8372403e"
)

for scene_id in abandoned_workshop_02 small_cathedral metro_vijzelgracht; do
  source_file="${source_root}/${scene_id}.jpg"
  output_root="${pack_root}/${scene_id}"
  source_url="https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/${scene_id}.jpg"
  mkdir -p "$output_root"

  curl -L --fail --retry 5 -C - -o "$source_file" "$source_url"
  printf '%s  %s\n' "${expected_md5[$scene_id]}" "$source_file" | md5sum --check --status

  ffmpeg -hide_banner -loglevel error -y -i "$source_file" \
    -vf "scale=2048:1024:flags=lanczos" -q:v 3 \
    "${output_root}/source_pano_2048x1024.jpg"

  for view_spec in \
    "A1_front_yaw000:0" \
    "A2_right_yaw090:90" \
    "A3_back_yaw180:180" \
    "A4_left_yaw270:-90"; do
    view_name="${view_spec%%:*}"
    view_yaw="${view_spec##*:}"
    ffmpeg -hide_banner -loglevel error -y -i "$source_file" \
      -vf "v360=input=e:output=flat:yaw=${view_yaw}:pitch=0:h_fov=100:v_fov=100:w=1024:h=1024" \
      -q:v 3 "${output_root}/${view_name}.jpg"
  done

  convert "${output_root}/A1_front_yaw000.jpg" "${output_root}/A2_right_yaw090.jpg" \
    +append "${output_root}/row_top.jpg"
  convert "${output_root}/A4_left_yaw270.jpg" "${output_root}/A3_back_yaw180.jpg" \
    +append "${output_root}/row_bottom.jpg"
  convert "${output_root}/row_top.jpg" "${output_root}/row_bottom.jpg" -append \
    -font DejaVu-Sans-Bold -pointsize 54 -fill white -stroke black -strokewidth 3 \
    -draw "text 28,68 'A1 FRONT 0 deg' text 1052,68 'A2 RIGHT 90 deg' text 28,1092 'A4 LEFT 270 deg' text 1052,1092 'A3 BACK 180 deg'" \
    -resize 1600x1600 -quality 75 "${output_root}/atlas_2x2_clockwise.jpg"
  rm "${output_root}/row_top.jpg" "${output_root}/row_bottom.jpg"
done

echo "Built H3 reference pack at ${pack_root}"
