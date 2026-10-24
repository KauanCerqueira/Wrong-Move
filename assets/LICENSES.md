# Asset licenses

Godot Engine is MIT-licensed; the notice is included in `GODOT_LICENSE.txt`.
Font and audio notices below accompany the assets in the debug export.

## Fonts

Noto Sans and Noto Serif, unmodified variable fonts from the official
Google Fonts repository (`ofl/notosans` and `ofl/notoserif`), downloaded
2026-10-24. SIL Open Font License1.1; the complete notices are included as
`fonts/NotoSans-OFL.txt` and `fonts/NotoSerif-OFL.txt`. Keep these notices with
redistributions. Sources: https://github.com/google/fonts/tree/main/ofl/notosans
and https://github.com/google/fonts/tree/main/ofl/notoserif.

## Cards and UI

`ui/icon.svg`, theme and procedural card faces are original project assets.
They do not include Balatro assets. The root PNG logo remains a user-supplied
visual reference, not an automatically verified third-party licensed asset.

## Audio

Author/source: original algorithmic synthesis created for Wrong Move in
`tools/generate_audio.gd`. No external samples or compositions. The generated
audio is dedicated to the public domain under CC0 1.0 Universal
(https://creativecommons.org/publicdomain/zero/1.0/); no external attribution is
required. This dedication covers the generated audio files, not Godot, FFmpeg,
libvorbis, fonts, or other assets.

| File | Author / source | License |
| --- | --- | --- |
| audio/card.wav | Wrong Move original synthesis | CC0-1.0 |
| audio/check.wav | Wrong Move original synthesis | CC0-1.0 |
| audio/call.wav | Wrong Move original synthesis | CC0-1.0 |
| audio/raise.wav | Wrong Move original synthesis | CC0-1.0 |
| audio/fold.wav | Wrong Move original synthesis | CC0-1.0 |
| audio/pot.wav | Wrong Move original synthesis | CC0-1.0 |
| audio/victory.wav | Wrong Move original synthesis | CC0-1.0 |
| audio/alert.wav | Wrong Move original synthesis | CC0-1.0 |
| audio/ambient.ogg | Wrong Move original synthesis | CC0-1.0 |

Godot provides the synthesis/playback backend (MIT license,
https://godotengine.org/license/). FFmpeg/libvorbis encodes the OGG during
development; no encoder executable is shipped with these audio assets.
