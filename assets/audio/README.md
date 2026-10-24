# Wrong Move original audio

All nine tracks are original, algorithmically generated for Wrong Move by
`tools/generate_audio.gd`, using sine oscillators and deterministic noise. No
recordings, samples, copied songs, fonts, or third-party musical material are used.
No external audio attribution is required. Godot is the synthesis/playback backend;
FFmpeg/libvorbis is the encoding backend, not a source of musical content.

These are simple prototype-quality effects and an ambient chord loop, not a claim
of polished final sound design or completion of release gate R12.

| File | Sound | Format / duration |
| --- | --- | --- |
| card.wav | Short filtered paper-like swish | Mono PCM16, 44,100 Hz / 0.16 s |
| check.wav | Soft single tap | Mono PCM16, 44,100 Hz / 0.12 s |
| call.wav | Two ascending chip tones | Mono PCM16, 44,100 Hz / 0.22 s |
| raise.wav | Three ascending tones | Mono PCM16, 44,100 Hz / 0.30 s |
| fold.wav | Low muted swish | Mono PCM16, 44,100 Hz / 0.20 s |
| pot.wav | Small cluster of chip tones | Mono PCM16, 44,100 Hz / 0.38 s |
| victory.wav | Brief ascending major arpeggio | Mono PCM16, 44,100 Hz / 0.48 s |
| alert.wav | Two gentle repeated tones | Mono PCM16, 44,100 Hz / 0.32 s |
| ambient.ogg | Slowly blended ambient chords | Stereo Vorbis, 44,100 Hz / 60 s |

The ambient source uses integer-cycle oscillators and periodic chord blending,
so its endpoints join continuously before Vorbis encoding. GameFeedback enables
OGG looping at playback. Music defaults to 35% and effects to 70%, with additional
quiet playback gains; vibration defaults off. Android haptics are independent of
the effect volume. Text/visual alerts must still be supplied by Main.

Regenerate from the project root with Godot 4.7 and a Vorbis-capable FFmpeg:

```sh
godot --headless --path . --script tools/generate_audio.gd -- --ffmpeg /path/to/ffmpeg
godot --headless --editor --path . --quit
godot --headless --path . --script tools/generate_audio.gd -- --verify
```

The generator removes its intermediate stereo WAV after successful encoding.
Only development generation runs the encoder; gameplay never invokes it.
Main should create GameFeedback, call `apply_preferences(saved_values)` before
adding it as a child, forward settings changes, and call `play(effect)` after the
corresponding accepted game event. Public effect names match the WAV stems.

License: CC0-1.0 for the generated audio; see `../LICENSES.md`.
