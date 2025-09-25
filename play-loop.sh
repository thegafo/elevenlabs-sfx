#!/usr/bin/env bash

# play-loop.sh
# Usage:
# ./play-loop.sh sound.mp3

set -e

if [[ -z "$1" ]]; then
    echo "Usage: $0 <sound_file>"
    exit 1
fi

SOUND_FILE="$1"

if [[ ! -f "$SOUND_FILE" ]]; then
    echo "Error: File '$SOUND_FILE' not found."
    exit 1
fi

# Detect available player and loop the sound seamlessly
if command -v ffplay &>/dev/null; then
    echo "▶ Playing '$SOUND_FILE' in a seamless loop using ffplay (press q to quit)..."
    ffplay -nodisp -autoexit -loop 0 "$SOUND_FILE"
elif command -v mpg123 &>/dev/null; then
    echo "▶ Playing '$SOUND_FILE' in a seamless loop using mpg123 (Ctrl+C to quit)..."
    while true; do
        mpg123 -q "$SOUND_FILE"
    done
elif [[ "$OSTYPE" == "darwin"* ]] && command -v afplay &>/dev/null; then
    echo "▶ Playing '$SOUND_FILE' in a seamless loop using afplay (Ctrl+C to quit)..."
    while true; do
        afplay "$SOUND_FILE"
    done
else
    echo "Error: No supported audio player found. Please install ffmpeg (for ffplay) or mpg123."
    exit 1
fi
