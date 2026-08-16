import AVFAudio
import XCTest
@testable import GlitchSoundFX

final class PressCueTests: XCTestCase {
    /// The press cue is the design-system slider click: a 1 400 Hz ping with
    /// a noise transient. Guards the port against a future retune losing it.
    func testBasePressIsTheCommitClick() {
        let recipe = SoundCue.press.recipe
        let toneFrequencies = recipe.layers.compactMap { layer -> Double? in
            if case let .tone(tone) = layer { return tone.frequency }
            return nil
        }
        XCTAssertTrue(toneFrequencies.contains(1_400),
                      "press should carry the 1400 Hz commit ping, got \(toneFrequencies)")
        let hasNoiseTransient = recipe.layers.contains { layer in
            if case let .noise(noise) = layer { return noise.decay <= 0.01 }
            return false
        }
        XCTAssertTrue(hasNoiseTransient, "press should keep the click's noise onset")
    }

    /// Amethyst plays the cuelume theme, so the port only lands if cuelume's
    /// press override carries the same recipe as the base.
    func testCuelumePressMatchesBasePress() {
        XCTAssertEqual(SoundTheme.cuelume.recipe(for: .press), SoundCue.press.recipe)
    }

    /// The new press must sit at the palette's loudness, not the design
    /// system's quieter scale: within ±35 % of the peak the old cuelume
    /// press rendered at.
    func testNewPressLoudnessMatchesOldPress() throws {
        let oldCuelumePress = SoundRecipe(layers: [
            .noise(.init(frequency: 1_700, resonance: 1.4, attack: 0.001, decay: 0.02, gain: 0.13))
        ], masterGain: 0.4)

        let oldPeak = try peak(of: oldCuelumePress, id: "test.old")
        let newPeak = try peak(of: SoundTheme.cuelume.recipe(for: .press), id: "test.new")

        XCTAssertGreaterThan(newPeak, oldPeak * 0.65,
                             "new press is too quiet: \(newPeak) vs old \(oldPeak)")
        XCTAssertLessThan(newPeak, oldPeak * 1.35,
                          "new press is too loud: \(newPeak) vs old \(oldPeak)")
    }

    private func peak(of recipe: SoundRecipe, id: String) throws -> Float {
        let buffer = try XCTUnwrap(SoundRenderer.render(
            recipe: recipe, id: id, variationIndex: 0, variationAmount: 0))
        let channel = try XCTUnwrap(buffer.floatChannelData?[0])
        return (0..<Int(buffer.frameLength)).reduce(Float.zero) { current, frame in
            max(current, abs(channel[frame]))
        }
    }
}
