import Foundation

/// Curated timbral presets that preserve each cue's meaning and relationships.
public enum SoundTheme: String, CaseIterable, Identifiable, Sendable {
    /// Warm tones with short, filtered physical transients.
    case tactile
    /// Quieter, darker, and more damped for dense productivity interfaces.
    case soft
    /// Slow, pure, spacious tones shaped for breathing and meditation apps.
    case breath
    /// Clean sine-like pings with restrained shimmer and almost no noise.
    case glass
    /// Brighter, lightly musical tones for expressive or game-like products.
    case playful
    /// A premium, deeply layered palette with tuned body, detail, and air.
    case signature
    /// Dry, fibrous, low-pitched textures inspired by wood, paper, and felt.
    case organic
    /// Warm timber knocks, soft grain, and gently resonant natural percussion.
    case woodland
    /// Short, precise, rhythmic feedback for fast tools and spatial interfaces.
    case kinetic
    /// Polished high-frequency tones with a vivid digital glow.
    case neon
    /// Elastic bubbles, toy-creature chirps, and surprising pentatonic gestures.
    case wonderland
    /// The Cuelume web palette: airy chimes, glides, droplets, and paper, ported note for note.
    case cuelume

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .tactile: "Tactile"
        case .soft: "Soft"
        case .breath: "Breath"
        case .glass: "Glass"
        case .playful: "Playful"
        case .signature: "Signature+"
        case .organic: "Organic"
        case .woodland: "Woodland"
        case .kinetic: "Kinetic"
        case .neon: "Neon"
        case .wonderland: "Wonderland"
        case .cuelume: "Cuelume"
        }
    }

    public var detail: String {
        switch self {
        case .tactile: "Physical and balanced"
        case .soft: "Damped and discreet"
        case .breath: "Slow, spacious, and restorative"
        case .glass: "Clean and luminous"
        case .playful: "Bright and musical"
        case .signature: "Layered, dimensional, and premium"
        case .organic: "Felt, wood, and paper"
        case .woodland: "Warm timber, soft grain, and earth"
        case .kinetic: "Fast, precise, and rhythmic"
        case .neon: "Vivid and digitally polished"
        case .wonderland: "Elastic, strange, and joyfully alive"
        case .cuelume: "Chimes, glides, and droplets"
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
        case .breath:
            return breathRecipe(for: cue, base: base)
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
        case .woodland:
            return woodlandRecipe(for: cue)
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
        case .cuelume:
            return cuelumeRecipe(for: cue)
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

    /// A noise-free palette with slower envelopes and low, consonant sine tones. Short cues
    /// stay restrained, while outcomes and expressive moments receive a soft room-sized tail.
    private func breathRecipe(for cue: SoundCue, base: SoundRecipe) -> SoundRecipe {
        var recipe = transform(
            base,
            toneFrequency: 0.667_42,
            toneGain: 0.52,
            noiseFrequency: 1,
            noiseGain: 0.18,
            duration: 1.55,
            masterGain: 0.67,
            toneWaveform: .sine,
            noiseAsTone: true,
            echoScale: 0.55
        )
        recipe.layers.append(contentsOf: breathAccents(for: cue))

        if recipe.echo == nil, cue.isExpressive {
            recipe.echo = .init(delay: 0.16, feedback: 0.12, wet: 0.07)
        }
        return recipe
    }

    private func breathAccents(for cue: SoundCue) -> [SoundLayer] {
        switch cue {
        case .tick:
            [tone(659.25, attack: 0.012, decay: 0.075, gain: 0.012)]
        case .press:
            [tone(196, glideTo: 174.61, attack: 0.018, decay: 0.11, gain: 0.018)]
        case .release:
            [tone(261.63, glideTo: 293.66, attack: 0.02, decay: 0.13, gain: 0.017)]
        case .toggleOn:
            [
                tone(329.63, attack: 0.022, decay: 0.14, gain: 0.017),
                tone(440, offset: 0.09, attack: 0.025, decay: 0.18, gain: 0.018)
            ]
        case .toggleOff:
            [
                tone(440, attack: 0.022, decay: 0.14, gain: 0.017),
                tone(329.63, offset: 0.09, attack: 0.025, decay: 0.18, gain: 0.018)
            ]
        case .select:
            [tone(392, attack: 0.016, decay: 0.12, gain: 0.016)]
        case .open:
            [tone(293.66, glideTo: 440, attack: 0.045, decay: 0.3, gain: 0.019)]
        case .close:
            [tone(440, glideTo: 293.66, attack: 0.035, decay: 0.28, gain: 0.019)]
        case .forward:
            [
                tone(392, attack: 0.026, decay: 0.16, gain: 0.017),
                tone(523.25, offset: 0.12, attack: 0.03, decay: 0.22, gain: 0.019)
            ]
        case .backward:
            [
                tone(523.25, attack: 0.026, decay: 0.16, gain: 0.017),
                tone(392, offset: 0.12, attack: 0.03, decay: 0.22, gain: 0.019)
            ]
        case .confirm:
            [
                tone(392, attack: 0.03, decay: 0.2, gain: 0.018),
                tone(587.33, offset: 0.1, attack: 0.035, decay: 0.28, gain: 0.019)
            ]
        case .success:
            breathPhrase([261.63, 329.63, 392], spacing: 0.12, decay: 0.27)
        case .warning:
            [
                tone(220, attack: 0.035, decay: 0.2, gain: 0.019),
                tone(220, offset: 0.22, attack: 0.04, decay: 0.24, gain: 0.019)
            ]
        case .error:
            [
                tone(220, glideTo: 196, attack: 0.03, decay: 0.2, gain: 0.02),
                tone(174.61, offset: 0.16, attack: 0.04, decay: 0.28, gain: 0.021)
            ]
        case .delete:
            [tone(220, glideTo: 110, attack: 0.04, decay: 0.34, gain: 0.02)]
        case .notify:
            [
                tone(440, attack: 0.035, decay: 0.26, gain: 0.019),
                tone(659.25, offset: 0.15, attack: 0.045, decay: 0.34, gain: 0.02)
            ]
        case .bloom:
            [
                tone(220, glideTo: 293.66, attack: 0.11, decay: 0.46, gain: 0.02),
                tone(330, glideTo: 440, offset: 0.05, attack: 0.12, decay: 0.5, gain: 0.016)
            ]
        case .sparkle:
            breathPhrase([523.25, 659.25, 783.99], spacing: 0.1, decay: 0.22)
        }
    }

    private func breathPhrase(
        _ frequencies: [Double],
        spacing: TimeInterval,
        decay: TimeInterval
    ) -> [SoundLayer] {
        frequencies.enumerated().map { index, frequency in
            tone(
                frequency,
                offset: Double(index) * spacing,
                attack: 0.03,
                decay: decay,
                gain: max(0.014, 0.019 - Float(index) * 0.002)
            )
        }
    }

    /// An authored physical palette rather than a global EQ transform. Each cue combines a
    /// short filtered grain transient with triangle-wave resonances that behave like struck
    /// timber: a warm fundamental, a quieter upper mode, and almost no artificial ambience.
    private func woodlandRecipe(for cue: SoundCue) -> SoundRecipe {
        let layers: [SoundLayer]
        let echo: SoundRecipe.Echo?

        switch cue {
        case .tick:
            layers = grain(2_450, decay: 0.018, gain: 0.105)
                + knock(784, decay: 0.042, gain: 0.046)
        case .press:
            layers = grain(980, decay: 0.026, gain: 0.12)
                + knock(131, decay: 0.075, gain: 0.06)
        case .release:
            layers = grain(1_850, decay: 0.02, gain: 0.095)
                + knock(247, decay: 0.06, gain: 0.05)
        case .toggleOn:
            layers = grain(1_300, decay: 0.022, gain: 0.1)
                + knock(330, decay: 0.07, gain: 0.05)
                + knock(495, offset: 0.055, decay: 0.09, gain: 0.052)
        case .toggleOff:
            layers = grain(1_300, decay: 0.022, gain: 0.1)
                + knock(495, decay: 0.07, gain: 0.048)
                + knock(330, offset: 0.055, decay: 0.09, gain: 0.054)
        case .select:
            layers = grain(2_050, decay: 0.016, gain: 0.09)
                + knock(440, decay: 0.065, gain: 0.05)
        case .open:
            layers = grain(1_180, attack: 0.012, decay: 0.09, gain: 0.055)
                + knock(196, decay: 0.09, gain: 0.046)
                + knock(294, offset: 0.07, decay: 0.12, gain: 0.052)
        case .close:
            layers = grain(1_080, offset: 0.035, attack: 0.008, decay: 0.075, gain: 0.06)
                + knock(294, decay: 0.085, gain: 0.046)
                + knock(196, offset: 0.065, decay: 0.12, gain: 0.054)
        case .forward:
            layers = grain(1_650, decay: 0.02, gain: 0.08)
                + knock(294, decay: 0.065, gain: 0.046)
                + knock(440, offset: 0.06, decay: 0.1, gain: 0.052)
        case .backward:
            layers = grain(1_650, offset: 0.045, decay: 0.02, gain: 0.08)
                + knock(440, decay: 0.065, gain: 0.046)
                + knock(294, offset: 0.06, decay: 0.1, gain: 0.052)
        case .confirm:
            layers = grain(1_900, decay: 0.022, gain: 0.085)
                + knock(392, decay: 0.075, gain: 0.048)
                + knock(587.33, offset: 0.06, decay: 0.13, gain: 0.055)
        case .success:
            layers = grain(1_750, decay: 0.024, gain: 0.07)
                + knock(261.63, decay: 0.085, gain: 0.044)
                + knock(329.63, offset: 0.07, decay: 0.1, gain: 0.047)
                + knock(392, offset: 0.14, decay: 0.16, gain: 0.052)
        case .warning:
            layers = grain(820, decay: 0.03, gain: 0.105)
                + knock(220, decay: 0.11, gain: 0.055)
                + knock(220, offset: 0.16, decay: 0.14, gain: 0.058)
        case .error:
            layers = grain(680, decay: 0.035, gain: 0.12)
                + knock(220, decay: 0.1, gain: 0.058)
                + knock(164.81, offset: 0.105, decay: 0.19, gain: 0.064)
        case .delete:
            layers = grain(720, attack: 0.008, decay: 0.14, gain: 0.095)
                + knock(146.83, glideTo: 92.5, decay: 0.22, gain: 0.065)
        case .notify:
            layers = grain(2_100, decay: 0.02, gain: 0.07)
                + knock(523.25, decay: 0.12, gain: 0.05)
                + knock(659.25, offset: 0.1, decay: 0.18, gain: 0.055)
        case .bloom:
            layers = grain(950, attack: 0.03, decay: 0.2, gain: 0.045)
                + knock(196, attack: 0.035, decay: 0.28, gain: 0.048)
                + knock(294, offset: 0.07, attack: 0.04, decay: 0.32, gain: 0.042)
        case .sparkle:
            layers = grain(2_800, decay: 0.018, gain: 0.065)
                + knock(783.99, decay: 0.055, gain: 0.036)
                + knock(987.77, offset: 0.055, decay: 0.07, gain: 0.038)
                + knock(1_174.66, offset: 0.11, decay: 0.1, gain: 0.04)
        }

        switch cue {
        case .success, .notify, .bloom:
            echo = .init(delay: 0.105, feedback: 0.1, wet: 0.045)
        default:
            echo = nil
        }

        return .init(layers: layers, masterGain: 0.437, echo: echo)
    }

    private func knock(
        _ frequency: Double,
        glideTo: Double? = nil,
        offset: TimeInterval = 0,
        attack: TimeInterval = 0.0025,
        decay: TimeInterval,
        gain: Float
    ) -> [SoundLayer] {
        [
            tone(
                frequency,
                glideTo: glideTo,
                waveform: .triangle,
                offset: offset,
                attack: attack,
                decay: decay,
                gain: gain
            ),
            tone(
                frequency * 2.56,
                glideTo: glideTo.map { $0 * 2.56 },
                waveform: .triangle,
                offset: offset + 0.0015,
                attack: attack,
                decay: decay * 0.56,
                gain: gain * 0.31
            )
        ]
    }

    private func grain(
        _ frequency: Double,
        offset: TimeInterval = 0,
        attack: TimeInterval = 0.0015,
        decay: TimeInterval,
        gain: Float
    ) -> [SoundLayer] {
        [
            .noise(
                .init(
                    filter: .bandpass,
                    frequency: frequency,
                    resonance: 0.72,
                    offset: offset,
                    attack: attack,
                    decay: decay,
                    gain: gain
                )
            )
        ]
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

    /// Verbatim ports of Cuelume's Web Audio cues (cuelume-site.pages.dev), mapped onto the
    /// nearest GlitchSoundFX cue: chime→notify, droplet→select, loading→open/close, page→forward/
    /// backward, ready→confirm, whisper grounds delete. Cuelume's shimmer becomes echo, its
    /// per-layer peak becomes gain, and its filterQ becomes resonance.
    private func cuelumeRecipe(for cue: SoundCue) -> SoundRecipe {
        switch cue {
        case .tick:
            return .init(layers: [
                .noise(.init(frequency: 5_400, resonance: 1.8, attack: 0.001, decay: 0.018, gain: 0.14)),
                .tone(.init(frequency: 2_600, attack: 0.001, decay: 0.012, gain: 0.018))
            ], masterGain: 0.4)
        case .press:
            return .init(layers: [
                .noise(.init(frequency: 1_700, resonance: 1.4, attack: 0.001, decay: 0.02, gain: 0.13))
            ], masterGain: 0.4)
        case .release:
            return .init(layers: [
                .noise(.init(frequency: 4_600, resonance: 1.8, attack: 0.001, decay: 0.016, gain: 0.12)),
                .tone(.init(frequency: 3_200, offset: 0.006, attack: 0.001, decay: 0.05, gain: 0.02))
            ], masterGain: 0.4)
        case .toggleOn:
            return .init(layers: [
                .noise(.init(frequency: 2_200, resonance: 1.6, attack: 0.001, decay: 0.016, gain: 0.12)),
                .noise(.init(frequency: 3_800, resonance: 1.6, offset: 0.024, attack: 0.001, decay: 0.02, gain: 0.1))
            ], masterGain: 0.4)
        case .toggleOff:
            return .init(layers: [
                .noise(.init(frequency: 3_800, resonance: 1.6, attack: 0.001, decay: 0.016, gain: 0.12)),
                .noise(.init(frequency: 2_200, resonance: 1.6, offset: 0.024, attack: 0.001, decay: 0.02, gain: 0.1))
            ], masterGain: 0.4)
        case .select:
            return .init(layers: [
                .tone(.init(frequency: 1_200, glideTo: 550, attack: 0.004, decay: 0.2, gain: 0.075))
            ], masterGain: 0.55, echo: .init(delay: 0.09, feedback: 0.2, wet: 0.15))
        case .open:
            return .init(layers: [
                .noise(.init(filter: .lowpass, frequency: 1_400, resonance: 0.6, attack: 0.035, decay: 0.14, gain: 0.035)),
                .tone(.init(frequency: 420, glideTo: 630, attack: 0.025, decay: 0.18, gain: 0.05))
            ], masterGain: 0.42, echo: .init(delay: 0.11, feedback: 0.18, wet: 0.12))
        case .close:
            return .init(layers: [
                .noise(.init(filter: .lowpass, frequency: 1_400, resonance: 0.6, attack: 0.02, decay: 0.12, gain: 0.035)),
                .tone(.init(frequency: 630, glideTo: 420, attack: 0.012, decay: 0.16, gain: 0.05))
            ], masterGain: 0.42)
        case .forward:
            return .init(layers: [
                .noise(.init(filter: .lowpass, frequency: 1_800, resonance: 0.7, attack: 0.006, decay: 0.08, gain: 0.11)),
                .noise(.init(frequency: 4_200, resonance: 1.2, offset: 0.04, attack: 0.004, decay: 0.065, gain: 0.08)),
                .tone(.init(frequency: 2_400, offset: 0.075, attack: 0.002, decay: 0.045, gain: 0.02))
            ], masterGain: 0.38)
        case .backward:
            return .init(layers: [
                .noise(.init(frequency: 4_200, resonance: 1.2, attack: 0.004, decay: 0.065, gain: 0.08)),
                .noise(.init(filter: .lowpass, frequency: 1_800, resonance: 0.7, offset: 0.04, attack: 0.006, decay: 0.08, gain: 0.11)),
                .tone(.init(frequency: 1_800, offset: 0.075, attack: 0.002, decay: 0.045, gain: 0.02))
            ], masterGain: 0.38)
        case .confirm:
            return .init(layers: [
                .noise(.init(frequency: 3_200, resonance: 1.7, attack: 0.001, decay: 0.018, gain: 0.1)),
                .tone(.init(frequency: 659.25, offset: 0.025, attack: 0.012, decay: 0.2, gain: 0.05)),
                .tone(.init(frequency: 987.77, offset: 0.025, attack: 0.012, decay: 0.22, gain: 0.035))
            ], masterGain: 0.45, echo: .init(delay: 0.13, feedback: 0.2, wet: 0.13))
        case .success:
            return .init(layers: [
                .tone(.init(frequency: 880, attack: 0.004, decay: 0.09, gain: 0.06)),
                .tone(.init(frequency: 1_108.73, offset: 0.06, attack: 0.004, decay: 0.1, gain: 0.06)),
                .tone(.init(frequency: 1_318.51, offset: 0.12, attack: 0.004, decay: 0.18, gain: 0.07))
            ], masterGain: 0.5, echo: .init(delay: 0.1, feedback: 0.22, wet: 0.16))
        case .warning:
            return .init(layers: [
                .noise(.init(frequency: 850, resonance: 1.1, attack: 0.001, decay: 0.03, gain: 0.1)),
                .tone(.init(frequency: 440, waveform: .triangle, offset: 0.02, decay: 0.09, gain: 0.04)),
                .tone(.init(frequency: 440, waveform: .triangle, offset: 0.17, decay: 0.12, gain: 0.04))
            ], masterGain: 0.44)
        case .error:
            return .init(layers: [
                .noise(.init(frequency: 850, resonance: 1.1, attack: 0.001, decay: 0.035, gain: 0.13)),
                .tone(.init(frequency: 440, waveform: .triangle, offset: 0.025, decay: 0.09, gain: 0.045)),
                .tone(.init(frequency: 349.23, waveform: .triangle, offset: 0.1, decay: 0.14, gain: 0.04))
            ], masterGain: 0.42)
        case .delete:
            return .init(layers: [
                .noise(.init(filter: .lowpass, frequency: 1_200, resonance: 0.7, attack: 0.04, decay: 0.16, gain: 0.05)),
                .tone(.init(frequency: 520, glideTo: 180, decay: 0.18, gain: 0.045))
            ], masterGain: 0.45)
        case .notify:
            return .init(layers: [
                .tone(.init(frequency: 1_046.5, attack: 0.006, decay: 0.22, gain: 0.09)),
                .tone(.init(frequency: 1_568, offset: 0.09, attack: 0.006, decay: 0.26, gain: 0.08))
            ], masterGain: 0.5, echo: .init(delay: 0.12, feedback: 0.25, wet: 0.18))
        case .bloom:
            return .init(layers: [
                .tone(.init(frequency: 528, attack: 0.06, decay: 0.32, gain: 0.06)),
                // Cuelume detunes the second voice by +12 cents.
                .tone(.init(frequency: 531.67, attack: 0.06, decay: 0.34, gain: 0.05))
            ], masterGain: 0.5, echo: .init(delay: 0.15, feedback: 0.2, wet: 0.12))
        case .sparkle:
            return .init(layers: [
                .tone(.init(frequency: 1_760, attack: 0.003, decay: 0.09, gain: 0.045)),
                .tone(.init(frequency: 2_217, offset: 0.045, attack: 0.003, decay: 0.09, gain: 0.04)),
                .tone(.init(frequency: 2_637, offset: 0.09, attack: 0.003, decay: 0.1, gain: 0.038)),
                .tone(.init(frequency: 3_520, offset: 0.135, attack: 0.003, decay: 0.12, gain: 0.032))
            ], masterGain: 0.5, echo: .init(delay: 0.07, feedback: 0.35, wet: 0.22))
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
