#!/usr/bin/env bash
set -euo pipefail

WIDTH=720
HEIGHT=720
FPS=30
DURATION=8
LOTUS="assets/lotus.png"
CHILD="assets/child.jpg"
OUTPUT="output/lotus-baby.mp4"

for asset in "$LOTUS" "$CHILD"; do
  [[ -f "$asset" ]] || { echo "Missing $asset"; exit 1; }
done
mkdir -p output

# Black celestial stage: rotating lotus, gentle descent, then a radiant zoom finale.
ffmpeg -y \
  -loop 1 -framerate "$FPS" -i "$LOTUS" \
  -loop 1 -framerate "$FPS" -i "$CHILD" \
  -filter_complex "color=c=black:s=$WIDTHx$HEIGHT:r=$FPS:d=$DURATION[black];color=c=0xff9ad9@0.18:s=160x$HEIGHT:r=$FPS:d=$DURATION,format=rgba,gblur=sigma=58[beam];[black][beam]overlay=x='(W-w)/2':y=0:eval=frame[space];[0:v]scale=500:-1:force_original_aspect_ratio=decrease,format=rgba,colorkey=0x000000:0.10:0.03,rotate='-0.85*t':ow='rotw(iw)':oh='roth(ih)':c=none[lotus];[0:v]scale=610:-1:force_original_aspect_ratio=decrease,format=rgba,colorkey=0x000000:0.14:0.05,gblur=sigma=24,colorchannelmixer=aa=0.45[glow];[space][glow]overlay=x='(W-w)/2':y=335:eval=frame[withglow];[withglow][lotus]overlay=x='(W-w)/2':y='375-22*sin(2*PI*t)':eval=frame[scene1];[1:v]scale=335:-1:force_original_aspect_ratio=decrease,format=rgba,colorkey=0xffffff:0.08:0.02[child];[scene1][child]overlay=x='(W-w)/2':y='if(lt(t,2),-h,if(lt(t,5),-h+(285+h)*(t-2)/3,285))':eval=frame[scene2];[scene2]scale=w='trunc(iw*(1+0.48*min(1,max(0,(t-5.25)/2.75)))/2)*2':h='trunc(ih*(1+0.48*min(1,max(0,(t-5.25)/2.75)))/2)*2':eval=frame,crop=$WIDTH:$HEIGHT:(in_w-$WIDTH)/2:(in_h-$HEIGHT)/2,fade=t=in:st=5.25:d=0.10:color=white,fade=t=out:st=5.35:d=0.42:color=white,format=yuv420p[v]" \
  -map "[v]" -t "$DURATION" -r "$FPS" -movflags +faststart \
  -c:v libx264 -crf 18 -preset medium "$OUTPUT"

echo "Rendered $OUTPUT"
