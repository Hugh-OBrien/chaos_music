#!/usr/bin/env bash

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
echo "Extract raw image data..."
echo $1
# convert to yuv colour space
ffmpeg -y -i $1 -pix_fmt rgb24 -vf scale=$RES_COLON tmp.yuv

mv tmp.yuv tmp.u"$BITS"
# convert to sound with sox
sox --bits "$BITS" -c1 -r44100 --encoding unsigned-integer -t u"$BITS" tmp.u"$BITS" \
  	--bits "$BITS" -c1 -r44100 --encoding unsigned-integer -t u"$BITS" sound.wav

sox --bits "$BITS" -c1 -r44100 --encoding unsigned-integer -t u"$BITS" tmp.u"$BITS" \
  	--bits 16 -c1 -r44100 --encoding unsigned-integer readable.wav

echo "Recreate image..."
sox --bits "$BITS" -c1 -r44100 --encoding unsigned-integer -t u"$BITS" sound.wav \
		--bits "$BITS" -c1 -r44100 --encoding unsigned-integer -t u"$BITS" other_tmp.u"$BITS"

ffmpeg -y -f rawvideo -pix_fmt rgb24 -s $RES -i other_tmp.u"$BITS" recreated.png
