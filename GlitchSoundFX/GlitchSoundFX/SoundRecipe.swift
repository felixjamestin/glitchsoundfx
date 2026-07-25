import Foundation

/// A small, composable description of a synthesized interaction sound.
public struct SoundRecipe: Sendable, Equatable {
    public var layers: [SoundLayer]
    public var masterGain: Float
    public var echo: Echo?

    public init(layers: [SoundLayer], masterGain: Float = 0.5, echo: Echo? = nil) {
        self.layers = layers
        self.masterGain = masterGain
        self.echo = echo
    }

    public struct Echo: Sendable, Equatable {
        public var delay: TimeInterval
        public var feedback: Float
        public var wet: Float

        public init(delay: TimeInterval, feedback: Float, wet: Float) {
            self.delay = delay
            self.feedback = feedback
            self.wet = wet
        }
    }
}

public enum SoundLayer: Sendable, Equatable {
    case tone(Tone)
    case noise(Noise)

    public struct Tone: Sendable, Equatable {
        public enum Waveform: Sendable, Equatable {
            case sine
            case triangle
            case softSquare
        }

        public var frequency: Double
        public var glideTo: Double?
        public var waveform: Waveform
        public var offset: TimeInterval
        public var attack: TimeInterval
        public var decay: TimeInterval
        public var gain: Float

        public init(
            frequency: Double,
            glideTo: Double? = nil,
            waveform: Waveform = .sine,
            offset: TimeInterval = 0,
            attack: TimeInterval = 0.004,
            decay: TimeInterval = 0.12,
            gain: Float = 0.08
        ) {
            self.frequency = frequency
            self.glideTo = glideTo
            self.waveform = waveform
            self.offset = offset
            self.attack = attack
            self.decay = decay
            self.gain = gain
        }
    }

    public struct Noise: Sendable, Equatable {
        public enum Filter: Sendable, Equatable {
            case lowpass
            case bandpass
            case highpass
        }

        public var filter: Filter
        public var frequency: Double
        public var resonance: Double
        public var offset: TimeInterval
        public var attack: TimeInterval
        public var decay: TimeInterval
        public var gain: Float

        public init(
            filter: Filter = .bandpass,
            frequency: Double,
            resonance: Double = 1,
            offset: TimeInterval = 0,
            attack: TimeInterval = 0.001,
            decay: TimeInterval = 0.03,
            gain: Float = 0.12
        ) {
            self.filter = filter
            self.frequency = frequency
            self.resonance = resonance
            self.offset = offset
            self.attack = attack
            self.decay = decay
            self.gain = gain
        }
    }
}
