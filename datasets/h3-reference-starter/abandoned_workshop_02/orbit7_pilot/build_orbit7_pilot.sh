#!/usr/bin/env bash
set -euo pipefail

pilot_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
scene_root="$(cd "${pilot_root}/.." && pwd)"
dataset_root="$(cd "${scene_root}/.." && pwd)"
source_root="${dataset_root}/.source-cache"
source_file="${source_root}/abandoned_workshop_02.jpg"
source_url="https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/abandoned_workshop_02.jpg"
source_md5="df639e9a3e30683bf4dabc13e1ab4ebc"
temp_root="$(mktemp -d)"
trap 'rm -rf "$temp_root"' EXIT

mkdir -p "$source_root" "${pilot_root}/clean" "${pilot_root}/labeled"
curl -L --fail --retry 5 -C - -o "$source_file" "$source_url"
printf '%s  %s\n' "$source_md5" "$source_file" | md5sum --check --status

view_names=(H1_yaw000 H2_yaw060 H3_yaw120 H4_yaw180 H5_yaw240 H6_yaw300)
view_yaws=(0 60 120 180 -120 -60)

for index in 0 1 2 3 4 5; do
  ffmpeg -hide_banner -loglevel error -y -i "$source_file" \
    -vf "v360=input=e:output=flat:yaw=${view_yaws[$index]}:pitch=0:h_fov=100:v_fov=100:w=1024:h=1024" \
    -q:v 3 "${pilot_root}/clean/${view_names[$index]}.jpg"
done
cp "${pilot_root}/clean/H1_yaw000.jpg" "${pilot_root}/clean/H7_yaw360_loop.jpg"

labels=("H1|0 deg|LOOP START" "H2|60 deg|1/6" "H3|120 deg|2/6" "H4|180 deg|3/6" "H5|240 deg|4/6" "H6|300 deg|5/6" "H7|360 deg|LOOP CLOSE")
files=(H1_yaw000 H2_yaw060 H3_yaw120 H4_yaw180 H5_yaw240 H6_yaw300 H7_yaw360_loop)

for index in 0 1 2 3 4 5 6; do
  IFS='|' read -r slot degree phase <<< "${labels[$index]}"
  convert -size 160x1024 xc:'#111318' -font DejaVu-Sans-Bold -fill white \
    -gravity center -pointsize 62 -annotate +0-90 "$slot" \
    -pointsize 32 -annotate +0+0 "$degree" \
    -pointsize 24 -fill '#72e3ff' -annotate +0+70 "$phase" \
    "${temp_root}/label_strip.jpg"
  convert "${temp_root}/label_strip.jpg" "${pilot_root}/clean/${files[$index]}.jpg" \
    +append -quality 88 "${pilot_root}/labeled/${files[$index]}_labeled.jpg"
done

convert "${pilot_root}/labeled/H1_yaw000_labeled.jpg" "${pilot_root}/labeled/H2_yaw060_labeled.jpg" \
  "${pilot_root}/labeled/H3_yaw120_labeled.jpg" "${pilot_root}/labeled/H4_yaw180_labeled.jpg" \
  +append "${temp_root}/row1.jpg"
convert "${pilot_root}/labeled/H5_yaw240_labeled.jpg" "${pilot_root}/labeled/H6_yaw300_labeled.jpg" \
  "${pilot_root}/labeled/H7_yaw360_loop_labeled.jpg" -size 1184x1024 xc:'#111318' \
  +append "${temp_root}/row2.jpg"
convert "${temp_root}/row1.jpg" "${temp_root}/row2.jpg" -append -resize 1600x \
  "${pilot_root}/orbit7_debug_sheet.jpg"

convert "${scene_root}/source_pano_2048x1024.jpg" -resize 2166x1083 "${temp_root}/loop_pano.jpg"
ffmpeg -hide_banner -loglevel error -y -loop 1 -framerate 24 -i "${temp_root}/loop_pano.jpg" \
  -vf "scroll=horizontal=0.002770083102493075:vertical=0,v360=input=e:output=flat:yaw=0:pitch=0:h_fov=100:v_fov=100:w=512:h=512" \
  -frames:v 362 -c:v libx264 -preset slow -crf 35 -pix_fmt yuv420p -r 24 \
  -movflags +faststart "${pilot_root}/motion_ref_continuous_sweep_15s_362f_512.mp4"

ffmpeg -hide_banner -loglevel error -y -f concat -safe 0 -i "${pilot_root}/slideshow_concat.txt" \
  -vf "fps=24,scale=592:512:flags=lanczos" -frames:v 362 -c:v libx264 -preset slow \
  -crf 31 -pix_fmt yuv420p -movflags +faststart \
  "${pilot_root}/debug_slideshow_H1-H7_15s_362f.mp4"

echo "Built Orbit-7 pilot at ${pilot_root}"
