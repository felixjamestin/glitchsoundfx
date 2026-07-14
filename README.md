# GlitchFX

GlitchFX is a dependency-free SwiftUI interaction-sound framework and a working showcase app. It synthesizes its palette at runtime with `AVAudioEngine`, so there are no audio files to copy, license, or keep in sync.

The system follows the ideas in [The Sound of Software](https://notbor.ing/words/the-sound-of-software) and the small declarative/imperative surface demonstrated by [Cuelume](https://cuelume-site.pages.dev/): communicate rather than decorate, build related cue families, layer simple sources, pair sound with haptics, and break exact repetition with subtle variation.

## Add it to an app

Add this repository as a local or remote Swift Package and import the library:

```swift
import GlitchFX
import SwiftUI
```

Use the shared palette imperatively:

```swift
Soundscape.shared.play(.success)
Soundscape.shared.play(.success, theme: .glass)
```

## Sound themes

Nine presets change the material of the complete palette while preserving semantic relationships such as open/close and forward/back:

- `.tactile` — warm, physical, and balanced; the default.
- `.soft` — darker, quieter, and damped for dense interfaces.
- `.glass` — clean tonal pings with restrained shimmer and almost no noise.
- `.playful` — brighter and lightly musical for expressive products.
- `.signature` — the flagship palette and recommended upgrade: dimensional body, precise detail, subtle air, and an individually tuned semantic accent for every cue.
- `.organic` — dry felt, wood, and paper-like textures with very little ambience.
- `.kinetic` — short, precise, rhythmic feedback for fast tools and spatial interfaces.
- `.neon` — vivid high-frequency polish with a clean digital glow.
- `.wonderland` — the deliberately unusual option: elastic bubbles, toy-creature chirps, odd pitch swoops, and tiny pentatonic phrases authored per interaction.

`Signature+` and `Wonderland` are deeper palettes rather than global tone/EQ transformations. Every one of their 18 cues receives a purpose-built accent or gesture.

Set the default for an entire app:

```swift
Soundscape.shared.configure(
    .init(defaultTheme: .signature)
)
```

Or override it at the point of use:

```swift
Button("Continue") { advance() }
    .buttonStyle(SoundButtonStyle(theme: .signature))

SoundToggle(isOn: $isOn, theme: .tactile) {
    Text("Power")
}

view.soundEffect(.success, trigger: didSave, theme: .wonderland)
```

Attach sound to any view when state changes:

```swift
Toggle("Focus", isOn: $isFocused)
    .soundEffect(isFocused ? .toggleOn : .toggleOff, trigger: isFocused)
```

Play a cue when the pointer enters one particular piece of text or image:

```swift
Text("Hover for details")
    .soundOnHover(.select)

Image(systemName: "photo.on.rectangle.angled")
    .soundOnHover(.sparkle, theme: .glass)
```

`soundOnHover` fires on pointer entry, not continuously while the pointer remains over the view. Use it selectively so moving through the interface does not become noisy.

Give a native button a physical press/release pair:

```swift
Button("Save") { save() }
    .buttonStyle(
        SoundButtonStyle(
            backgroundColor: .blue,
            hoverColor: .purple
        )
    )
```

Use native Liquid Glass with the same press/release sound behavior:

```swift
Button("Glass action") {
    performAction()
} label: {
    Label("Create", systemImage: "sparkles")
}
.buttonStyle(
    LiquidGlassSoundButtonStyle(
        release: .sparkle,
        theme: .glass,
        tint: .purple,
        hoverTint: .pink,
        cornerRadius: 16,
        horizontalPadding: 18,
        verticalPadding: 12,
        kerning: 0.4,
        fontSize: 15,
        fontColor: .white,
        textShadowColor: .black.opacity(0.4),
        textShadowRadius: 2,
        textShadowY: 1,
        borderColor: .white.opacity(0.2),
        borderWidth: 1,
        shadowColor: .black.opacity(0.18),
        shadowRadius: 8,
        shadowY: 4,
        hoverShadowColor: .pink.opacity(0.3),
        hoverShadowRadius: 14,
        hoverShadowY: 6,
        hoverAnimationDuration: 0.18
    )
)
```

The style accepts separate horizontal and vertical padding, an optional border,
a resting shadow, a hover shadow, and a configurable hover animation duration.
It can also apply `kerning`, `fontSize`, `fontColor`, and a text shadow to the
button label. `textShadowRadius`, `textShadowX`, and `textShadowY` control that
shadow. Leave the typography values as `nil` to preserve the label's own style.
Set either button shadow radius to `0` to disable that shadow. `shadowX`, `shadowY`,
`hoverShadowX`, and `hoverShadowY` control the corresponding offsets. When
`hoverShadowColor` is omitted, the hover shadow is derived from `hoverTint`,
`tint`, or the accent color.

`LiquidGlassSoundButtonStyle` uses native Liquid Glass on iOS,
macOS, tvOS, and watchOS 26 or later. It falls back to an adaptive material on
earlier releases and on visionOS, so the package can keep its existing minimum
deployment targets. Building this API requires the SwiftUI SDK included with
Xcode 26 or later.

Or use the ready-made components:

```swift
SoundButton(actionCue: .success) {
    save()
} label: {
    Label("Save", systemImage: "checkmark")
}

SoundToggle(isOn: $isFocused) {
    Text("Focus")
}

SoundSlider(value: $intensity, step: 0.05) {
    Text("Intensity")
}
```

## Configuration and user control

Interaction sound defaults to the `.ambient` audio-session category: it respects the silent switch and mixes with existing audio. Apps should expose settings and persist them using their own preference system.

```swift
Soundscape.shared.configure(
    .init(
        isSoundEnabled: true,
        isHapticsEnabled: true,
        volume: 0.8,
        variation: 0.72,
        defaultTheme: .tactile,
        audioPolicy: .respectSilentMode
    )
)
```

Use `.playInSilentMode` only when sound is essential to the experience. Ordinary interface decoration should not override a person's device preference.

## How variation works

Every playback chooses one of 12 variants and never immediately repeats the previous choice. Variants make bounded changes to pitch, gain, layer timing, filter brightness, and stereo position. The recipe stays recognizable while the waveform stops feeling mechanically identical.

Rendered buffers use a transparent peak ceiling with guaranteed headroom, DC blocking, and short edge fades. The player maintains a 16-voice polyphony budget and never truncates an active cue just to start another one, avoiding clipping and click artifacts during rapid interaction.

The `horizontalLocation` argument can add restrained spatial meaning without turning ordinary UI into a spatial-audio spectacle:

```swift
Soundscape.shared.play(.select, horizontalLocation: tapX / viewWidth)
```

Dense controls can throttle their cues:

```swift
Soundscape.shared.play(.select, minimumInterval: 0.045)
```

## Custom sound worlds

Built-in cues cover press/release, toggle on/off, selection, open/close, forward/back, confirmations, outcomes, notifications, and expressive accents. A product can create its own palette from layered tones and filtered noise:

```swift
let archive = SoundRecipe(
    layers: [
        .noise(.init(filter: .lowpass, frequency: 1_300, decay: 0.15, gain: 0.07)),
        .tone(.init(frequency: 280, glideTo: 120, decay: 0.18, gain: 0.04))
    ],
    masterGain: 0.48
)

Soundscape.shared.play(recipe: archive, id: "archive", haptic: .rigid)
```

## Design guidance

- Use sound to acknowledge, warn, celebrate, explain direction, or add materiality—not on every possible event.
- Keep frequent cues short, quiet, and spectrally distinct from speech.
- Treat opposites as siblings: press/release, open/close, forward/back, on/off.
- Reserve musical or longer cues for infrequent outcomes.
- Pair appropriate haptics, but let people disable sound and haptics independently.
- Test on the actual device speaker, earbuds, and in a noisy environment.
- Keep failure silent: audio must never prevent the primary action.

## Project layout

- `GlitchFX/GlitchFX/` — portable package source
- `GlitchFX/ContentView.swift` — showcase app
- `Tests/GlitchFXTests/` — recipe, render-safety, and variation tests

The package targets iOS 17+, macOS 14+, tvOS 17+, watchOS 10+, and visionOS 1+.
