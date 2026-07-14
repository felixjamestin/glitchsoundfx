import Foundation

/// Curated timbral presets that preserve each cue's meaning and relationships.
public enum SoundTheme: String, CaseIterable, Identifiable, Sendable {
    /// Warm tones with short, filtered physical transients.
    case tactile
    /// Quieter, darker, and more damped for dense productivity interfaces.
    case soft
    /// Clean sine-like pings with restrained shimmer and almost no noise.
    case glass
    /// Brighter, lightly musical tones for expressive or game-like products.
    case playful
    /// A premium, deeply layered palette with tuned body, detail, and air.
    case signature
    /// Dry, fibrous, low-pitched textures inspired by wood, paper, and felt.
    case organic
    /// Short, precise, rhythmic feedback for fast tools and spatial interfaces.
    case kinetic
    /// Polished high-frequency tones with a vivid digital glow.
    case neon
    /// Elastic bubbles, toy-creature chirps, and surprising pentatonic gestures.
    case wonderland

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .tactile: "Tactile"
        case .soft: "Soft"
        case .glass: "Glass"
        case .playful: "Playful"
        case .signature: "Signature+"
        case .organic: "Organic"
        case .kinetic: "Kinetic"
        case .neon: "Neon"
        case .wonderland: "Wonderland"
        }
    }

    public var detail: String {
        switch self {
        case .tactile: "Physical and balanced"
        case .soft: "Damped and discreet"
        case .glass: "Clean and luminous"
        case .playful: "Bright and musical"
        case .signature: "Layered, dimensional, and premium"
        case .organic: "Felt, wood, and paper"
        case .kinetic: "Fast, precise, and rhythmic"
        case .neon: "Vivid and digitally polished"
        case .wonderland: "Elastic, strange, and joyfully alive"
        }
    }

    /// Returns a themed version of a built-in cue while retaining its semantic contour.
    public func recipe(for cue: SoundCue) -> SoundRecipe {
        let base = cue.recipe
        switch self {
        case .tactile:
            return transform(
                base,
                toneFrequency: 1,
                toneGain: 0.94,
                noiseFrequency: 0.96,
                noiseGain: 0.78,
                duration: 1,
                masterGain: 0.94,
                toneWaveform: nil,
                noiseAsTone: false,
                echoScale: 0.85
            )
        case .soft:
            return transform(
                base,
                toneFrequency: 0.82,
                toneGain: 0.72,
                noiseFrequency: 0.62,
                noiseGain: 0.28,
                duration: 1.18,
                masterGain: 0.82,
                toneWaveform: .sine,
                noiseAsTone: false,
                echoScale: 0.42
            )
        case .glass:
            return transform(
                base,
                toneFrequency: 1.28,
                toneGain: 0.78,
                noiseFrequency: 1,
                noiseGain: 0.3,
                duration: 1.24,
                masterGain: 0.78,
                toneWaveform: .sine,
                noiseAsTone: true,
                echoScale: 1.15
            )
        case .playful:
            return transform(
                base,
                toneFrequency: 1.122_462,
                toneGain: 0.78,
                noiseFrequency: 1.08,
                noiseGain: 0.42,
                duration: 1.06,
                masterGain: 0.88,
                toneWaveform: .triangle,
                noiseAsTone: false,
                echoScale: 0.9
            )
        case .signature:
            return signatureRecipe(for: cue, base: base)
        case .organic:
            return transform(
                base,
                toneFrequency: 0.74,
                toneGain: 0.76,
                noiseFrequency: 0.52,
                noiseGain: 0.48,
                duration: 1.08,
                masterGain: 0.76,
                toneWaveform: .triangle,
                noiseAsTone: false,
                echoScale: 0.12
            )
        case .kinetic:
            return transform(
                base,
                toneFrequency: 1.06,
                toneGain: 0.86,
                noiseFrequency: 1.18,
                noiseGain: 0.58,
                duration: 0.68,
                masterGain: 0.91,
                toneWaveform: .sine,
                noiseAsTone: false,
                echoScale: 0.25
            )
        case .neon:
            return transform(
                base,
                toneFrequency: 1.52,
                toneGain: 0.68,
                noiseFrequency: 1.2,
                noiseGain: 0.24,
                duration: 0.82,
                masterGain: 0.8,
                toneWaveform: .sine,
                noiseAsTone: true,
                echoScale: 1.28
            )
        case .wonderland:
            return wonderlandRecipe(for: cue, base: base)
        }
    }

    private func signatureRecipe(for cue: SoundCue, base: SoundRecipe) -> SoundRecipe {
        var recipe = transform(
            base,
            toneFrequency: 0.96,
            toneGain: 0.82,
            noiseFrequency: 0.9,
            noiseGain: 0.36,
            duration: 1.1,
            masterGain: 0.85,
            toneWaveform: .sine,
            noiseAsTone: false,
            echoScale: 0.92
        )
        recipe.layers.append(contentsOf: signatureAccents(for: cue))

        if recipe.echo == nil, cue.isExpressive {
            recipe.echo = .init(delay: 0.095, feedback: 0.16, wet: 0.09)
        }
        return recipe
    }

    private func signatureAccents(for cue: SoundCue) -> [SoundLayer] {
        switch cue {
        case .tick:
            [tone(3_200, offset: 0.004, decay: 0.026, gain: 0.012)]
        case .press:
            [tone(112, glideTo: 86, decay: 0.052, gain: 0.022)]
        case .release:
            [tone(2_350, offset: 0.005, decay: 0.06, gain: 0.016)]
        case .toggleOn:
            [tone(740, offset: 0.018, decay: 0.09, gain: 0.021)]
        case .toggleOff:
            [tone(555, glideTo: 415, offset: 0.018, decay: 0.09, gain: 0.021)]
        case .select:
            [tone(1_480, decay: 0.055, gain: 0.017)]
        case .open:
            [tone(1_040, offset: 0.065, decay: 0.15, gain: 0.021)]
        case .close:
            [tone(390, offset: 0.06, decay: 0.14, gain: 0.022)]
        case .forward:
            [tone(1_320, offset: 0.1, decay: 0.14, gain: 0.021)]
        case .backward:
            [tone(495, offset: 0.1, decay: 0.14, gain: 0.021)]
        case .confirm:
            [tone(1_480, offset: 0.07, decay: 0.16, gain: 0.022)]
        case .success:
            [tone(1_568, offset: 0.195, decay: 0.25, gain: 0.025)]
        case .warning:
            [tone(220, offset: 0.02, decay: 0.24, gain: 0.018)]
        case .error:
            [tone(146.83, offset: 0.11, decay: 0.24, gain: 0.024)]
        case .delete:
            [tone(96, glideTo: 58, offset: 0.025, decay: 0.2, gain: 0.024)]
        case .notify:
            [tone(2_093, offset: 0.17, decay: 0.24, gain: 0.02)]
        case .bloom:
            [tone(792, offset: 0.11, attack: 0.035, decay: 0.32, gain: 0.02)]
        case .sparkle:
            [tone(4_186, offset: 0.19, decay: 0.16, gain: 0.014)]
        }
    }

    private func wonderlandRecipe(for cue: SoundCue, base: SoundRecipe) -> SoundRecipe {
        var recipe = transform(
            base,
            toneFrequency: 1.31,
            toneGain: 0.46,
            noiseFrequency: 1,
            noiseGain: 0.12,
            duration: 0.88,
            masterGain: 0.74,
            toneWaveform: .sine,
            noiseAsTone: true,
            echoScale: 0.72
        )
        recipe.layers.append(contentsOf: wonderlandAccents(for: cue))
        recipe.echo = .init(delay: 0.082, feedback: 0.17, wet: 0.115)
        return recipe
    }

    private func wonderlandAccents(for cue: SoundCue) -> [SoundLayer] {
        switch cue {
        case .tick:
            [tone(2_100, glideTo: 3_300, decay: 0.055, gain: 0.024)]
        case .press:
            [tone(270, glideTo: 145, waveform: .triangle, decay: 0.085, gain: 0.035)]
        case .release:
            [tone(390, glideTo: 920, decay: 0.095, gain: 0.029)]
        case .toggleOn:
            phrase([523.25, 783.99, 1_174.66], spacing: 0.037, decay: 0.09)
        case .toggleOff:
            phrase([1_174.66, 783.99, 523.25], spacing: 0.037, decay: 0.09)
        case .select:
            [tone(1_250, glideTo: 1_930, decay: 0.07, gain: 0.027)]
        case .open:
            phrase([392, 783.99, 1_174.66], spacing: 0.052, decay: 0.13)
        case .close:
            phrase([1_174.66, 783.99, 392], spacing: 0.045, decay: 0.12)
        case .forward:
            phrase([659.25, 987.77, 1_318.51], spacing: 0.045, decay: 0.11)
        case .backward:
            phrase([1_318.51, 987.77, 659.25], spacing: 0.045, decay: 0.11)
        case .confirm:
            [
                tone(740, glideTo: 1_046.5, decay: 0.1, gain: 0.026),
                tone(1_568, offset: 0.075, decay: 0.16, gain: 0.021)
            ]
        case .success:
            phrase([523.25, 783.99, 1_174.66, 1_568], spacing: 0.052, decay: 0.15)
        case .warning:
            [
                tone(466.16, glideTo: 493.88, waveform: .triangle, decay: 0.13, gain: 0.026),
                tone(493.88, glideTo: 466.16, waveform: .triangle, offset: 0.13, decay: 0.15, gain: 0.026)
            ]
        case .error:
            [
                tone(311.13, glideTo: 207.65, waveform: .triangle, decay: 0.13, gain: 0.03),
                tone(233.08, glideTo: 155.56, waveform: .triangle, offset: 0.105, decay: 0.2, gain: 0.032)
            ]
        case .delete:
            [tone(185, glideTo: 62, waveform: .triangle, decay: 0.23, gain: 0.034)]
        case .notify:
            phrase([1_046.5, 783.99, 1_318.51], spacing: 0.085, decay: 0.18)
        case .bloom:
            [
                tone(440, glideTo: 660, attack: 0.045, decay: 0.28, gain: 0.026),
                tone(452, glideTo: 678, offset: 0.03, attack: 0.045, decay: 0.31, gain: 0.022)
            ]
        case .sparkle:
            phrase([1_396.91, 2_093, 2_637.02, 3_520], spacing: 0.038, decay: 0.11)
        }
    }

    private func phrase(
        _ frequencies: [Double],
        spacing: TimeInterval,
        decay: TimeInterval
    ) -> [SoundLayer] {
        frequencies.enumerated().map { index, frequency in
            tone(
                frequency,
                offset: Double(index) * spacing,
                decay: decay,
                gain: max(0.014, 0.027 - Float(index) * 0.003)
            )
        }
    }

    private func tone(
        _ frequency: Double,
        glideTo: Double? = nil,
        waveform: SoundLayer.Tone.Waveform = .sine,
        offset: TimeInterval = 0,
        attack: TimeInterval = 0.003,
        decay: TimeInterval,
        gain: Float
    ) -> SoundLayer {
        .tone(
            .init(
                frequency: frequency,
                glideTo: glideTo,
                waveform: waveform,
                offset: offset,
                attack: attack,
                decay: decay,
                gain: gain
            )
        )
    }

    private func transform(
        _ recipe: SoundRecipe,
        toneFrequency: Double,
        toneGain: Float,
        noiseFrequency: Double,
        noiseGain: Float,
        duration: Double,
        masterGain: Float,
        toneWaveform: SoundLayer.Tone.Waveform?,
        noiseAsTone: Bool,
        echoScale: Float
    ) -> SoundRecipe {
        let layers = recipe.layers.map { layer -> SoundLayer in
            switch layer {
            case var .tone(tone):
                tone.frequency *= toneFrequency
                tone.glideTo = tone.glideTo.map { $0 * toneFrequency }
                tone.gain *= toneGain
                tone.attack = max(tone.attack * duration, 0.0025)
                tone.decay *= duration
                if let toneWaveform { tone.waveform = toneWaveform }
                return .tone(tone)

            case var .noise(noise):
                if noiseAsTone {
                    let cleanFrequency = min(max(noise.frequency * 0.28, 520), 2_400)
                    return .tone(
                        .init(
                            frequency: cleanFrequency,
                            waveform: .sine,
                            offset: noise.offset,
                            attack: max(noise.attack, 0.003),
                            decay: max(noise.decay * 2.1, 0.048),
                            gain: noise.gain * noiseGain
                        )
                    )
                }
                noise.frequency *= noiseFrequency
                noise.gain *= noiseGain
                noise.attack = max(noise.attack * duration, 0.0015)
                noise.decay *= duration
                noise.resonance = min(noise.resonance, 1.45)
                return .noise(noise)
            }
        }

        let echo = recipe.echo.map {
            SoundRecipe.Echo(
                delay: $0.delay,
                feedback: min($0.feedback * echoScale, 0.28),
                wet: min($0.wet * echoScale, 0.18)
            )
        }
        return SoundRecipe(
            layers: layers,
            masterGain: recipe.masterGain * masterGain,
            echo: echo
        )
    }
}
