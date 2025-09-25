# Sound FX Scripts

Utility scripts for generating and previewing looping sound effects with the [ElevenLabs sound-generation API](https://elevenlabs.io/docs/api-reference/text-to-sound-effects/convert).

## Prerequisites
- `curl` and `jq`
- An ElevenLabs API key exported as `ELEVENLABS_API_KEY`
- At least one audio player: `ffplay` (from FFmpeg), `mpg123`, or macOS `afplay`

## Generating Sound Effects (`sfx.sh`)
The script sends a text prompt to the ElevenLabs API and saves the generated audio to a timestamped file named after the prompt.

```bash
./sfx.sh \
  --text "wind blowing softly" \
  --loop true \
  --duration 5 \
  --prompt_influence 0.5 \
  --model_id eleven_text_to_sound_v2 \
  --output_format mp3_44100_128 \
  --output_file wind.mp3
```

Key flags:
- `--text` *(required)*: Prompt that describes the sound; it also seeds the filename (e.g., `wind-blowing-softly_20240508_153015.mp3`).
- `--loop`: `true` or `false`. Request that ElevenLabs generates a seamlessly loopable clip (defaults to `false`).
- `--duration`: Optional length in seconds. Omit to let the model decide.
- `--prompt_influence`: Float between 0 and 1 controlling how strongly the model follows the text prompt.
- `--model_id`: ElevenLabs model identifier. Defaults to `eleven_text_to_sound_v2`.
- `--output_format`: See ElevenLabs docs for valid formats (default `mp3_44100_128`).
- `--output_file`: Provides the file extension (e.g., `wind.wav` → `.wav`). The base name is always derived from the prompt, and a timestamp is appended automatically.

When the command completes, the audio file is saved alongside the script.

## Looping Playback (`play-loop.sh`)
Use this helper to audition a file in a seamless loop.

```bash
./play-loop.sh wind-blowing-softly_20240508_153015.mp3
```

The script will:
- Prefer `ffplay -loop 0` for gapless playback (press `q` to stop).
- Fall back to `mpg123` or macOS `afplay`, replaying the file continuously until you stop it with `Ctrl+C`.
- Display an error if no supported player is available.

## Workflow Example
1. Export your ElevenLabs key once per session: `export ELEVENLABS_API_KEY="sk_your_key"`.
2. Generate a clip with `sfx.sh`.
3. Preview the result with `play-loop.sh`.

Both scripts exit on error, so failures (such as missing dependencies or API issues) stop the workflow immediately.
