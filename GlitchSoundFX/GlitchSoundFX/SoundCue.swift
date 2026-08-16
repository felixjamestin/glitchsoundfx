import Foundation

/// A coherent palette for common interface moments.
public enum SoundCue: String, CaseIterable, Identifiable, Sendable {
    case tick
    case press
    case release
    case toggleOn
    case toggleOff
    case select
    case open
    case close
    case forward
    case backward
    case confirm
    case success
    case warning
    case error
    case delete
    case notify
    case bloom
    case sparkle

    public var id: String { rawValue }

    public var recipe: SoundRecipe {
        switch self {
        case .tick:
            return .init(layers: [
                .noise(.init(frequency: 5_200, resonance: 1.8, decay: 0.018, gain: 0.13)),
                .tone(.init(frequency: 2_600, decay: 0.025, gain: 0.025))
            ], masterGain: 0.42)
        case .press:
            // The Glitch Design System's slider click, ported layer for
            // layer: a 1 400 Hz ping with a fast decay and a one-millisecond
            // noise onset. The renderer's own pitch variation stands in for
            // the original's five pitched variants.
            return .init(layers: [
                .noise(.init(frequency: 2_600, resonance: 0.7, decay: 0.004, gain: 0.035)),
                .tone(.init(frequency: 1_400, attack: 0.002, decay: 0.028, gain: 0.031))
            ], masterGain: 0.46)
        case .release:
            return .init(layers: [
                .noise(.init(frequency: 4_400, resonance: 1.7, decay: 0.018, gain: 0.12)),
                .tone(.init(frequency: 2_900, offset: 0.006, decay: 0.045, gain: 0.022))
            ], masterGain: 0.42)
        case .toggleOn:
            return .init(layers: [
                .noise(.init(frequency: 2_100, resonance: 1.5, decay: 0.018, gain: 0.11)),
                .noise(.init(frequency: 4_100, resonance: 1.7, offset: 0.025, decay: 0.022, gain: 0.1)),
                .tone(.init(frequency: 880, offset: 0.025, decay: 0.07, gain: 0.025))
            ], masterGain: 0.44)
        case .toggleOff:
            return .init(layers: [
                .noise(.init(frequency: 3_800, resonance: 1.7, decay: 0.018, gain: 0.1)),
                .noise(.init(frequency: 1_900, resonance: 1.5, offset: 0.025, decay: 0.024, gain: 0.12)),
                .tone(.init(frequency: 660, glideTo: 440, offset: 0.018, decay: 0.07, gain: 0.02))
            ], masterGain: 0.42)
        case .select:
            return .init(layers: [
                .tone(.init(frequency: 1_760, decay: 0.045, gain: 0.045)),
                .noise(.init(frequency: 3_900, resonance: 1.4, decay: 0.012, gain: 0.05))
            ], masterGain: 0.38)
        case .open:
            return .init(layers: [
                .tone(.init(frequency: 520, glideTo: 780, attack: 0.015, decay: 0.14, gain: 0.055)),
                .noise(.init(filter: .lowpass, frequency: 1_400, attack: 0.018, decay: 0.11, gain: 0.035))
            ], masterGain: 0.48, echo: .init(delay: 0.1, feedback: 0.18, wet: 0.1))
        case .close:
            return .init(layers: [
                .tone(.init(frequency: 780, glideTo: 480, attack: 0.008, decay: 0.13, gain: 0.055)),
                .noise(.init(filter: .lowpass, frequency: 1_200, offset: 0.03, decay: 0.09, gain: 0.04))
            ], masterGain: 0.46)
        case .forward:
            return .init(layers: [
                .tone(.init(frequency: 660, decay: 0.07, gain: 0.045)),
                .tone(.init(frequency: 880, offset: 0.055, decay: 0.11, gain: 0.05))
            ], masterGain: 0.45, echo: .init(delay: 0.09, feedback: 0.15, wet: 0.08))
        case .backward:
            return .init(layers: [
                .tone(.init(frequency: 880, decay: 0.07, gain: 0.045)),
                .tone(.init(frequency: 660, offset: 0.055, decay: 0.11, gain: 0.05))
            ], masterGain: 0.45)
        case .confirm:
            return .init(layers: [
                .noise(.init(frequency: 2_800, resonance: 1.3, decay: 0.025, gain: 0.07)),
                .tone(.init(frequency: 988, offset: 0.016, decay: 0.14, gain: 0.055))
            ], masterGain: 0.48, echo: .init(delay: 0.08, feedback: 0.15, wet: 0.09))
        case .success:
            return .init(layers: [
                .tone(.init(frequency: 659.25, decay: 0.09, gain: 0.052)),
                .tone(.init(frequency: 830.61, offset: 0.065, decay: 0.11, gain: 0.052)),
                .tone(.init(frequency: 1_046.5, offset: 0.13, decay: 0.2, gain: 0.062))
            ], masterGain: 0.52, echo: .init(delay: 0.11, feedback: 0.2, wet: 0.13))
        case .warning:
            return .init(layers: [
                .tone(.init(frequency: 440, waveform: .triangle, decay: 0.12, gain: 0.05)),
                .tone(.init(frequency: 440, waveform: .triangle, offset: 0.15, decay: 0.15, gain: 0.055))
            ], masterGain: 0.5)
        case .error:
            return .init(layers: [
                .tone(.init(frequency: 330, glideTo: 275, waveform: .triangle, decay: 0.12, gain: 0.06)),
                .tone(.init(frequency: 247, glideTo: 196, waveform: .triangle, offset: 0.105, decay: 0.2, gain: 0.065))
            ], masterGain: 0.52)
        case .delete:
            return .init(layers: [
                .noise(.init(filter: .lowpass, frequency: 1_500, attack: 0.008, decay: 0.16, gain: 0.075)),
                .tone(.init(frequency: 310, glideTo: 120, waveform: .triangle, decay: 0.18, gain: 0.04))
            ], masterGain: 0.48)
        case .notify:
            return .init(layers: [
                .tone(.init(frequency: 1_046.5, decay: 0.16, gain: 0.06)),
                .tone(.init(frequency: 1_568, offset: 0.09, decay: 0.24, gain: 0.055))
            ], masterGain: 0.48, echo: .init(delay: 0.13, feedback: 0.23, wet: 0.14))
        case .bloom:
            return .init(layers: [
                .tone(.init(frequency: 528, attack: 0.055, decay: 0.3, gain: 0.055)),
                .tone(.init(frequency: 535, attack: 0.055, decay: 0.34, gain: 0.045))
            ], masterGain: 0.5, echo: .init(delay: 0.15, feedback: 0.18, wet: 0.11))
        case .sparkle:
            return .init(layers: [
                .tone(.init(frequency: 1_760, decay: 0.08, gain: 0.04)),
                .tone(.init(frequency: 2_217, offset: 0.045, decay: 0.08, gain: 0.037)),
                .tone(.init(frequency: 2_637, offset: 0.09, decay: 0.09, gain: 0.034)),
                .tone(.init(frequency: 3_520, offset: 0.135, decay: 0.13, gain: 0.03))
            ], masterGain: 0.48, echo: .init(delay: 0.075, feedback: 0.26, wet: 0.16))
        }
    }
}

extension SoundCue {
    var isExpressive: Bool {
        switch self {
        case .open, .close, .forward, .backward, .confirm, .success,
             .warning, .error, .delete, .notify, .bloom, .sparkle:
            true
        case .tick, .press, .release, .toggleOn, .toggleOff, .select:
            false
        }
    }
}
