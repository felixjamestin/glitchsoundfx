import AVFAudio
import Foundation

struct RenderedVariation: Equatable {
    var pitchMultiplier: Double
    var gainMultiplier: Float
    var timingOffset: TimeInterval
    var pan: Float
    var brightness: Double
}

enum VariationGenerator {
    static let count = 12

    static func make(
        id: String,
        index: Int,
        amount: Double,
        horizontalLocation: Double? = nil
    ) -> RenderedVariation {
        var random = SeededRandom(seed: stableSeed(for: id) &+ UInt64(index &* 7_919))
        let boundedAmount = min(max(amount, 0), 1)
        let cents = random.signed() * 18 * boundedAmount
        let gain = 1 + random.signed() * 0.06 * boundedAmount
        let timing = random.signed() * 0.0035 * boundedAmount
        let randomPan = random.signed() * 0.05 * boundedAmount
        let locationPan = horizontalLocation.map { min(max(($0 - 0.5) * 0.32, -0.16), 0.16) } ?? 0

        return RenderedVariation(
            pitchMultiplier: pow(2, cents / 1_200),
            gainMultiplier: Float(gain),
            timingOffset: timing,
            pan: Float(min(max(randomPan + locationPan, -0.2), 0.2)),
            brightness: 1 + random.signed() * 0.1 * boundedAmount
        )
    }

    private static func stableSeed(for string: String) -> UInt64 {
        string.utf8.reduce(14_695_981_039_346_656_037) { hash, byte in
            (hash ^ UInt64(byte)) &* 1_099_511_628_211
        }
    }
}

enum SoundRenderer {
    static let sampleRate = 44_100.0

    /// Scales every rendered cue above the level the recipes were authored at. The per-cue
    /// `masterGain` values land around 0.32–0.44, which peaks near 0.03 — far below the
    /// `peakCeiling` limiter, so the palette read as too quiet at full system volume.
    /// 3.2x is roughly +10dB, the point where the cues read as twice as loud rather than
    /// merely measuring twice the amplitude. The limiter below still catches anything
    /// this pushes too far.
    static let outputBoost: Float = 3.2

    static func render(
        recipe: SoundRecipe,
        id: String,
        variationIndex: Int,
        variationAmount: Double
    ) -> AVAudioPCMBuffer? {
        let variation = VariationGenerator.make(
            id: id,
            index: variationIndex,
            amount: variationAmount
        )
        let sourceEnd = recipe.layers.map(layerEnd).max() ?? 0.1
        let echoTail = recipe.echo.map { $0.delay * 6 } ?? 0
        let duration = min(max(sourceEnd + echoTail + 0.04, 0.06), 1.8)
        let frameCount = AVAudioFrameCount(ceil(duration * sampleRate))
        guard
            let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount),
            let output = buffer.floatChannelData?[0]
        else { return nil }

        buffer.frameLength = frameCount
        var samples = [Float](repeating: 0, count: Int(frameCount))

        for (layerIndex, layer) in recipe.layers.enumerated() {
            switch layer {
            case let .tone(tone):
                render(
                    tone: tone,
                    into: &samples,
                    variation: variation,
                    seedOffset: layerIndex
                )
            case let .noise(noise):
                render(
                    noise: noise,
                    into: &samples,
                    variation: variation,
                    seed: UInt64(variationIndex &* 1_009 + layerIndex &* 97 + 1)
                )
            }
        }

        if let echo = recipe.echo {
            applyEcho(echo, to: &samples)
        }

        applyDCBlocker(to: &samples)
        applyEdgeFades(to: &samples)

        let master = recipe.masterGain * outputBoost
        let peak = samples.reduce(Float.zero) { current, sample in
            max(current, abs(sample * master))
        }
        let peakCeiling: Float = 0.72
        let safetyGain = peak > peakCeiling ? peakCeiling / peak : 1
        for index in samples.indices {
            output[index] = samples[index] * master * safetyGain
        }
        return buffer
    }

    private static func layerEnd(_ layer: SoundLayer) -> TimeInterval {
        switch layer {
        case let .tone(tone): tone.offset + tone.attack + tone.decay
        case let .noise(noise): noise.offset + noise.attack + noise.decay
        }
    }

    private static func render(
        tone: SoundLayer.Tone,
        into samples: inout [Float],
        variation: RenderedVariation,
        seedOffset: Int
    ) {
        let start = max(0, Int((tone.offset + variation.timingOffset) * sampleRate))
        let length = max(1, Int((tone.attack + tone.decay) * sampleRate))
        let attackLength = max(1, Int(tone.attack * sampleRate))
        var phase = Double(seedOffset) * 0.17

        for localIndex in 0..<length where start + localIndex < samples.count {
            let progress = Double(localIndex) / Double(max(length - 1, 1))
            let baseFrequency: Double
            if let glideTo = tone.glideTo {
                baseFrequency = tone.frequency * pow(glideTo / tone.frequency, progress)
            } else {
                baseFrequency = tone.frequency
            }
            let frequency = baseFrequency * variation.pitchMultiplier
            phase += 2 * Double.pi * frequency / sampleRate

            let oscillator: Double
            switch tone.waveform {
            case .sine:
                oscillator = sin(phase)
            case .triangle:
                oscillator = 2 / Double.pi * asin(sin(phase))
            case .softSquare:
                oscillator = tanh(sin(phase) * 2.2)
            }

            let envelope = amplitudeEnvelope(
                localIndex: localIndex,
                totalLength: length,
                attackLength: attackLength
            )
            samples[start + localIndex] += Float(oscillator) * envelope * tone.gain
        }
    }

    private static func render(
        noise: SoundLayer.Noise,
        into samples: inout [Float],
        variation: RenderedVariation,
        seed: UInt64
    ) {
        let start = max(0, Int((noise.offset + variation.timingOffset) * sampleRate))
        let length = max(1, Int((noise.attack + noise.decay) * sampleRate))
        let attackLength = max(1, Int(noise.attack * sampleRate))
        var random = SeededRandom(seed: seed)
        var filter = Biquad(
            type: noise.filter,
            frequency: min(noise.frequency * variation.brightness, sampleRate * 0.46),
            q: noise.resonance,
            sampleRate: sampleRate
        )

        for localIndex in 0..<length where start + localIndex < samples.count {
            let raw = Float(random.signed())
            let filtered = filter.process(raw)
            let envelope = amplitudeEnvelope(
                localIndex: localIndex,
                totalLength: length,
                attackLength: attackLength
            )
            samples[start + localIndex] += filtered * envelope * noise.gain
        }
    }

    private static func amplitudeEnvelope(
        localIndex: Int,
        totalLength: Int,
        attackLength: Int
    ) -> Float {
        if localIndex < attackLength {
            let progress = Float(localIndex) / Float(attackLength)
            return progress * progress * (3 - 2 * progress)
        }
        let decayLength = max(totalLength - attackLength, 1)
        let progress = Float(localIndex - attackLength) / Float(decayLength)
        return pow(max(1 - progress, 0), 2.4)
    }

    private static func applyEcho(_ echo: SoundRecipe.Echo, to samples: inout [Float]) {
        let delayFrames = max(1, Int(echo.delay * sampleRate))
        var delayLine = [Float](repeating: 0, count: delayFrames)
        var cursor = 0

        for index in samples.indices {
            let dry = samples[index]
            let delayed = delayLine[cursor]
            samples[index] = dry + delayed * echo.wet
            delayLine[cursor] = dry + delayed * echo.feedback
            cursor = (cursor + 1) % delayFrames
        }
    }

    /// Removes inaudible DC energy that can waste speaker headroom on short transients.
    private static func applyDCBlocker(to samples: inout [Float]) {
        var previousInput: Float = 0
        var previousOutput: Float = 0
        let coefficient: Float = 0.995
        for index in samples.indices {
            let input = samples[index]
            let output = input - previousInput + coefficient * previousOutput
            samples[index] = output
            previousInput = input
            previousOutput = output
        }
    }

    /// Guarantees smooth buffer boundaries even for custom recipes with abrupt envelopes.
    private static func applyEdgeFades(to samples: inout [Float]) {
        let fadeInCount = min(32, samples.count)
        let fadeOutCount = min(192, samples.count)
        for index in 0..<fadeInCount {
            samples[index] *= Float(index) / Float(max(fadeInCount - 1, 1))
        }
        for offset in 0..<fadeOutCount {
            let index = samples.count - fadeOutCount + offset
            let gain = Float(fadeOutCount - 1 - offset) / Float(max(fadeOutCount - 1, 1))
            samples[index] *= gain
        }
    }
}

private struct SeededRandom {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 0x9E37_79B9_7F4A_7C15 : seed
    }

    mutating func signed() -> Double {
        state ^= state >> 12
        state ^= state << 25
        state ^= state >> 27
        let value = state &* 2_685_821_657_736_338_717
        let unit = Double(value >> 11) / Double(1 << 53)
        return unit * 2 - 1
    }
}

private struct Biquad {
    private let b0: Float
    private let b1: Float
    private let b2: Float
    private let a1: Float
    private let a2: Float
    private var z1: Float = 0
    private var z2: Float = 0

    init(type: SoundLayer.Noise.Filter, frequency: Double, q: Double, sampleRate: Double) {
        let omega = 2 * Double.pi * frequency / sampleRate
        let cosine = cos(omega)
        let sine = sin(omega)
        let alpha = sine / (2 * max(q, 0.1))
        let coefficients: (Double, Double, Double)

        switch type {
        case .lowpass:
            coefficients = ((1 - cosine) / 2, 1 - cosine, (1 - cosine) / 2)
        case .bandpass:
            coefficients = (alpha, 0, -alpha)
        case .highpass:
            coefficients = ((1 + cosine) / 2, -(1 + cosine), (1 + cosine) / 2)
        }

        let a0 = 1 + alpha
        b0 = Float(coefficients.0 / a0)
        b1 = Float(coefficients.1 / a0)
        b2 = Float(coefficients.2 / a0)
        a1 = Float(-2 * cosine / a0)
        a2 = Float((1 - alpha) / a0)
    }

    mutating func process(_ input: Float) -> Float {
        let output = b0 * input + z1
        z1 = b1 * input - a1 * output + z2
        z2 = b2 * input - a2 * output
        return output
    }
}
