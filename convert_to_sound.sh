#!/usr/bin/env bash

echo "Extract raw image data..."
echo $1
# convert to yuv colour space
ffmpeg -y -i $1 -pix_fmt rgb24 ./tmp.yuv

mv tmp.yuv tmp.u8
# convert to sound with sox
sox tmp.u8 out.wav


echo "Recreate image..."
# ffmpeg -y -i ./tmp.yuv \"$2\"
