# Third-party notices

## Procedural Sounds

The Procedural theme adapts selected synthesis patches from
[Mick Cesanek's Procedural Sounds](https://github.com/m1ckc3s/procedural-sounds),
revision `bab3f31d0132972bec64b0856e72f09cb295ab3f`.
The interactive reference is [Procedural interface sounds, with taste](https://procedural-sounds.vercel.app/).

The source IDs below refer to zero-based entries in `data/pool/<category>.json`
at that revision. Only the selected patch parameters are adapted; no source
recordings, training data, Web Audio engine, or runtime service are included.

| GlitchSoundFX cue | Source patch | Adaptation |
| --- | --- | --- |
| Tick | `pool/hover/112` | Short rising hover tone |
| Press / Release | `pool/hover/13` | Falling tap; reversed pitch slide for release |
| Toggle on / off | `pool/tap/7` | Two notes; reversed pitches for off |
| Select | `pool/tap/6` | Single clear tap |
| Open / Close | `pool/hover/12` | Rising slide; reversed for close |
| Forward / Backward | `pool/tap/4` | Two notes; reversed pitches for backward |
| Confirm | `pool/tap/5` | Short rising pair |
| Success | `pool/success/3` | Three-note rising phrase |
| Warning | `pool/warning/0` | Repeated triangle tone |
| Error | `pool/error/0` | Descending triangle pair |
| Delete | `pool/transition/3` | Falling sine slide |
| Notify | `pool/notification/0` | Two-note notification |
| Bloom | `pool/transition/4` | Rising slide with a delayed sustained tone |
| Sparkle | `pool/notification/10` | Three-note high/low/high figure |

These are native adaptations, not sample-identical Web Audio ports. Frequencies,
waveforms, note offsets, and relative layer gains follow the selected patches.
The native smooth attack and power decay replace the source envelope curves and sustain;
release time is folded into decay, and zero attacks become 1 ms. Bloom's 78 ms
pitch slide spans its first layer's full envelope in the native renderer.
Layer gains are scaled by 0.22, with master gain 0.42 (0.32 for Warning), to fit
GlitchSoundFX's output boost. Existing variation, DC removal, edge fades, and
peak protection remain active. No extra echo is added.

MIT License

Copyright (c) 2026 Mick Cesanek

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
