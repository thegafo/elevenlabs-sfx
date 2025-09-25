#!/usr/bin/env bash

# text-to-sfx.sh
# Usage:
# ./text-to-sfx.sh --text "wind blowing softly" --loop true --duration 5 --prompt_influence 0.5 --model_id eleven_text_to_sound_v2 --output_format mp3_44100_128 --output_file wind.mp3

set -e

# Defaults
OUTPUT_FORMAT="mp3_44100_128"
OUTPUT_FILE="sound.mp3"
LOOP="false"
DURATION=""
PROMPT_INFLUENCE=""
MODEL_ID="eleven_text_to_sound_v2"

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --text) TEXT="$2"; shift ;;
        --loop) LOOP="$2"; shift ;;
        --duration) DURATION="$2"; shift ;;
        --prompt_influence) PROMPT_INFLUENCE="$2"; shift ;;
        --model_id) MODEL_ID="$2"; shift ;;
        --output_format) OUTPUT_FORMAT="$2"; shift ;;
        --output_file) OUTPUT_FILE="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Validate required arguments
if [[ -z "$TEXT" ]]; then
    echo "Error: --text is required."
    exit 1
fi

if [[ -z "$ELEVENLABS_API_KEY" ]]; then
    echo "Error: ELEVENLABS_API_KEY environment variable not set."
    exit 1
fi

# Derive a safe filename slug from the prompt without external dependencies
PROMPT_SLUG=$(echo "$TEXT" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -e 's/[^a-z0-9]/-/g' -e 's/-\{2,\}/-/g' -e 's/^-//' -e 's/-$//')
if [[ -z "$PROMPT_SLUG" ]]; then
    PROMPT_SLUG="sound"
fi

# Add timestamp suffix before file extension
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
EXTENSION="${OUTPUT_FILE##*.}"
if [[ "$EXTENSION" == "$OUTPUT_FILE" ]]; then
    EXTENSION="mp3"
fi
OUTPUT_DIR=$(dirname "$OUTPUT_FILE")
if [[ "$OUTPUT_DIR" == "." ]]; then
    OUTPUT_DIR=""
else
    OUTPUT_DIR+="/"
fi
OUTPUT_FILE="${OUTPUT_DIR}${PROMPT_SLUG}_${TIMESTAMP}.${EXTENSION}"

# Build JSON payload
JSON_PAYLOAD=$(jq -n \
  --arg text "$TEXT" \
  --arg loop "$LOOP" \
  --arg model_id "$MODEL_ID" \
  --argjson duration "${DURATION:-null}" \
  --argjson prompt_influence "${PROMPT_INFLUENCE:-null}" \
  '{
    text: $text,
    loop: ($loop == "true"),
    model_id: $model_id,
    duration_seconds: $duration,
    prompt_influence: $prompt_influence
  }'
)

# Make API call
curl -s -X POST "https://api.elevenlabs.io/v1/sound-generation?output_format=${OUTPUT_FORMAT}" \
  -H "xi-api-key: ${ELEVENLABS_API_KEY}" \
  -H "Content-Type: application/json" \
  -o "$OUTPUT_FILE" \
  -d "$JSON_PAYLOAD"

echo "✅ Sound effect saved to $OUTPUT_FILE"
