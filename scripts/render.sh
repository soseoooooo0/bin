#!/usr/bin/env bash
set -euo pipefail

WIDTH=720
HEIGHT=720
FPS=30
DURATION=8
BACKGROUND="assets/background.png"
LOTUS="assets/lotus.png"
CHILD="assets/child.png"
OUTPUT="output/lotus-baby.mp4"

for asset in "$BACKGROUND" "$LOTUS" "$CHILD"; do
  if [[ ! -f "$asset" ]]; then
    echo "Missing $asset. See README.md for the required three images."
    exit 1
  fi
done

mkdir -p output

# Timeline: lotus spins in (0–2.5s), child descends (2–5s), then a 2.6s zoom/flash finale.
ffmpeg -y \
  -loop 1 -framerate "$FPS" -i "$BACKGROUND" \
  -loop 1 -framerate "$FPS" -i "$LOTUS" \
  -loop 1 -framerate "$FPS" -i "$CHILD" \
  -filter_complex "[0:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=increase,crop=$WIDTH:$HEIGHT,setsar=1[bg];[1:v]scale=470:-1:force_original_aspect_ratio=decrease,format=rgba,rotate='-0.9*t':ow='rotw(iw)':oh='roth(ih)':c=none,setsar=1[lotus];[2:v]scale=310:-1:force_original_aspect_ratio=decrease,format=rgba,setsar=1[child];[bg][lotus]overlay=x='(W-w)/2':y='375-32*sin(2*PI*t)':eval=frame[scene1];[scene1][child]overlay=x='(W-w)/2':y='if(lt(t,2),-h,if(lt(t,5),-h+(285+h)*(t-2)/3,285))':eval=frame[scene2];[scene2]scale=w='trunc(iw*(1+0.42*min(1,max(0,(t-5.35)/2.65)))/2)*2':h='trunc(ih*(1+0.42*min(1,max(0,(t-5.35)/2.65)))/2)*2':eval=frame,crop=$WIDTH:$HEIGHT:(in_w-$WIDTH)/2:(in_h-$HEIGHT)/2[zoom];[zoom]format=rgba,fade=t=in:st=5.35:d=0.10:color=white,fade=t=out:st=5.45:d=0.42:color=white,format=yuv420p[v]" \
  -map "[v]" -t "$DURATION" -r "$FPS" -movflags +faststart \
  -c:v libx264 -crf 18 -preset medium "$OUTPUT"

echo "Rendered $OUTPUT"
