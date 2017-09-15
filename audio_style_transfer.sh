#!/usr/bin/env bash

#
# USAGE:
#
# - Inputs:
#    1: image
#    2: sound clip
#
# - Output:
#    readable_sound.wav : image converted to a sound
#    transferred.wav : output sound with sound style transferred onto it
#    styled_image : transferred converted back to an image of same dimensions as original input
#
#

function cmd()
{
    OUTPUT=$(eval "$@" 2>&1)
    if (( $? )); then
        echo -e "\n----- ERROR -----"
        echo -e "\n\$ ${*}\n\n"
        echo -e "$OUTPUT"
        echo -e "\n----- ERROR -----"
        cleanup 1
    fi
    echo "$OUTPUT"
}

function cmdSilent()
{
    OUTPUT=$(eval "$@" 2>&1)
    if (( $? )); then
        echo -e "\n----- ERROR -----"
        echo -e "\n\$ ${*}\n\n"
        echo -e "$OUTPUT"
        echo -e "\n----- ERROR -----"
        cleanup 1
    fi
}

function clean()
{
    rm tmp.u8
		rm other_tmp.u8
}

function getResolution()
{
    eval $(cmd ffprobe -v error -of flat=s=_ -select_streams v:0 -show_entries stream=height,width \"$1\")
    RES="${streams_stream_0_width}x${streams_stream_0_height}"
    echo "$RES"
}

BITS=8
RES=${RES:-"$(getResolution "$1" x)"}
RES_COLON=$(echo "$RES" | tr x :)
echo $RES
echo $1

### CONVERT IMAGE TO SOUND
echo "Extract raw image data..."

# convert to yuv colour space
ffmpeg -y -i $1 -pix_fmt rgb24 -vf scale=$RES_COLON tmp.yuv

mv tmp.yuv tmp.u"$BITS"
# convert to sound with sox

sox --bits "$BITS" -c1 -r44100 --encoding unsigned-integer -t u"$BITS" tmp.u"$BITS" \
  	--bits "$BITS" -c1 -r44100 --encoding unsigned-integer readable_sound.wav

### DO THE STYLE TRANSFER
echo "Doing style transfer.. this will take a while"

python style_transfer.py readable_sound.wav $2

### CREATE AN IMAGE FROM THE OUTPUT
echo "Recreate image..."

sox --bits "$BITS" -c1 -r44100 --encoding unsigned-integer transferred.wav \
		--bits "$BITS" -c1 -r44100 --encoding unsigned-integer -t u"$BITS" other_tmp.u"$BITS"

ffmpeg -y -f rawvideo -pix_fmt rgb24 -s $RES -i other_tmp.u"$BITS" styled_image.png

clean 0
