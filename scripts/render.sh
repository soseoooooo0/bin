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

# Three scenes: celestial lotus reveal, baby descent, luminous impact zoom.
ffmpeg -y \
  -loop 1 -framerate "$FPS" -i "$LOTUS" \
  -loop 1 -framerate "$FPS" -i "$CHILD" \
  -filter_complex "\
color=c=0x020106:s=\${WIDTH}x\${HEIGHT}:r=\${FPS}:d=\${DURATION},drawbox=x=48:y=70:w=2:h=2:color=white@0.82:t=fill,drawbox=x=126:y=130:w=1:h=1:color=white@0.82:t=fill,drawbox=x=195:y=64:w=2:h=2:color=white@0.82:t=fill,drawbox=x=279:y=112:w=1:h=1:color=white@0.82:t=fill,drawbox=x=365:y=54:w=2:h=2:color=white@0.82:t=fill,drawbox=x=455:y=148:w=1:h=1:color=white@0.82:t=fill,drawbox=x=536:y=84:w=2:h=2:color=white@0.82:t=fill,drawbox=x=650:y=132:w=1:h=1:color=white@0.82:t=fill,drawbox=x=86:y=235:w=1:h=1:color=white@0.82:t=fill,drawbox=x=170:y=289:w=2:h=2:color=white@0.82:t=fill,drawbox=x=267:y=215:w=1:h=1:color=white@0.82:t=fill,drawbox=x=344:y=285:w=1:h=1:color=white@0.82:t=fill,drawbox=x=431:y=231:w=2:h=2:color=white@0.82:t=fill,drawbox=x=587:y=254:w=1:h=1:color=white@0.82:t=fill,drawbox=x=675:y=315:w=2:h=2:color=white@0.82:t=fill,drawbox=x=38:y=420:w=1:h=1:color=white@0.82:t=fill,drawbox=x=118:y=489:w=2:h=2:color=white@0.82:t=fill,drawbox=x=214:y=402:w=1:h=1:color=white@0.82:t=fill,drawbox=x=304:y=464:w=1:h=1:color=white@0.82:t=fill,drawbox=x=405:y=421:w=2:h=2:color=white@0.82:t=fill,drawbox=x=510:y=485:w=1:h=1:color=white@0.82:t=fill,drawbox=x=608:y=405:w=2:h=2:color=white@0.82:t=fill,drawbox=x=688:y=458:w=1:h=1:color=white@0.82:t=fill,drawbox=x=70:y=590:w=2:h=2:color=white@0.82:t=fill,drawbox=x=159:y=665:w=1:h=1:color=white@0.82:t=fill,drawbox=x=249:y=555:w=1:h=1:color=white@0.82:t=fill,drawbox=x=336:y=632:w=2:h=2:color=white@0.82:t=fill,drawbox=x=449:y=577:w=1:h=1:color=white@0.82:t=fill,drawbox=x=552:y=651:w=2:h=2:color=white@0.82:t=fill,drawbox=x=640:y=555:w=1:h=1:color=white@0.82:t=fill,drawbox=x=697:y=692:w=2:h=2:color=white@0.82:t=fill[space];\
color=c=0xff8fcd@0.30:s=180x\${HEIGHT}:r=\${FPS}:d=\${DURATION},format=rgba,gblur=sigma=65[beam];\
color=c=0xffb5df@0.42:s=360x360:r=\${FPS}:d=\${DURATION},format=rgba,gblur=sigma=80[halo];\
[space][beam]overlay=x='(W-w)/2':y=0:eval=frame[spacebeam];\
[spacebeam][halo]overlay=x='(W-w)/2':y=255:eval=frame[cosmos];\
[0:v]scale=500:-2:force_original_aspect_ratio=decrease,format=rgba,colorkey=0x000000:0.055:0.02[lotusbase];\
[lotusbase]split=2[lotusglow][lotusani];\
[lotusglow]gblur=sigma=30,colorchannelmixer=aa=0.72[lotuslight];\
[cosmos][lotuslight]overlay=x='(W-w)/2':y=365:eval=frame[lit];\
[lotusani]scale=w='max(2,trunc(iw*(0.20+0.80*min(1,t/2.5))/2)*2)':h=-2:eval=frame,rotate='-0.9*t':ow='rotw(iw)':oh='roth(ih)':c=none[lotus];\
[lit][lotus]overlay=x='(W-w)/2':y='385-18*sin(2*PI*t)':eval=frame[scene1];\
[1:v]scale=340:-2:force_original_aspect_ratio=decrease,format=rgba,colorkey=0xffffff:0.028:0.01[child];\
[scene1][child]overlay=x='(W-w)/2':y='if(lt(t,2),-h,if(lt(t,5),-h+(280+h)*(t-2)/3,280))':eval=frame[scene2];\
[scene2]scale=w='trunc(iw*(1+0.52*min(1,max(0,(t-5.20)/2.80)))/2)*2':h='trunc(ih*(1+0.52*min(1,max(0,(t-5.20)/2.80)))/2)*2':eval=frame,crop=\${WIDTH}:\${HEIGHT}:(in_w-\${WIDTH})/2:(in_h-\${HEIGHT})/2,fade=t=in:st=5.20:d=0.08:color=white,fade=t=out:st=5.28:d=0.42:color=white,format=yuv420p[v]" \
  -map "[v]" -t "$DURATION" -r "$FPS" -movflags +faststart \
  -c:v libx264 -crf 17 -preset medium "$OUTPUT"

echo "Rendered $OUTPUT"
