#!/bin/bash
# usage: sheet.sh OUTDIR t1 t2 ...
set -e
OUT="${1:?}"; shift
mkdir -p "$OUT"; find "$OUT" -name 't*.png' -delete
node "$(dirname "$0")/stills.js" "$OUT" "$@"
python3 -c "
import sys,glob
from PIL import Image
fs=sorted(glob.glob(sys.argv[1]+'/t*.png'),key=lambda f:float(f.split('/t')[-1][:-4]))
ims=[Image.open(f).resize((270,480)) for f in fs]
cols=6;rows=(len(ims)+cols-1)//cols
sheet=Image.new('RGB',(270*cols,480*rows))
for i,im in enumerate(ims): sheet.paste(im,((i%cols)*270,(i//cols)*480))
sheet.save(sys.argv[1]+'/sheet.png')" "$OUT"
