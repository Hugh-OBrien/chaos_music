#!/usr/bin/env bash

ffmpeg -y -i \"$1\" -pix_fmt $YUV_FMT $FFMPEG_IN_OPTS  $TMP_DIR/tmp.yuv

[[ $AUDIO = *[!\ ]* ]] && echo "Extracting audio track.."
[[ $AUDIO = *[!\ ]* ]] && cmdSilent "ffmpeg -y -i \"$1\" -q:a 0 -map a $TMP_DIR/audio_in.${AUDIO_TYPE}"

echo "Processing as sound.."
mv "$TMP_DIR"/tmp.yuv "$TMP_DIR"/tmp_audio_in."$S_TYPE"
cmdSilent sox --bits "$BITS" -c1 -r44100 --encoding unsigned-integer -t "$S_TYPE" "$TMP_DIR"/tmp_audio_in."$S_TYPE"  \
              --bits "$BITS" -c1 -r44100 --encoding unsigned-integer -t "$S_TYPE" "$TMP_DIR"/tmp_audio_out."$S_TYPE" \
              "$SOX_OPTS"
