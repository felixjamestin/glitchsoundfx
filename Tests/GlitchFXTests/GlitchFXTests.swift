import AVFAudio
import XCTest
@testable import GlitchFX

final class GlitchFXTests: XCTestCase {
    func testEveryCueHasAUsableRecipe() {
        for cue in SoundCue.allCases {
            XCTAssertFalse(cue.recipe.layers.isEmpty, "\(cue) has no layers")
            XCTAssertGreaterThan(cue.recipe.masterGain, 0)
            XCTAssertLessThanOrEqual(cue.recipe.masterGain, 1)
        }
    }

    func testEveryThemeAndCueRendersWithCleanHeadroom() throws {
        for theme in SoundTheme.allCases {
            for cue in SoundCue.allCases {
                let buffer = try XCTUnwrap(
                    SoundRenderer.render(
                        recipe: theme.recipe(for: cue),
                        id: "\(theme.rawValue).\(cue.rawValue)",
                        variationIndex: 4,
                        variationAmount: 0.72
                    )
                )
                let data = try XCTUnwrap(buffer.floatChannelData?[0])
                let samples = UnsafeBufferPointer(start: data, count: Int(buffer.frameLength))
                let peak = samples.map { abs($0) }.max() ?? 0
                XCTAssertTrue(samples.allSatisfy(\.isFinite), "\(theme) \(cue) emitted invalid samples")
                XCTAssertGreaterThan(peak, 0.0001, "\(theme) \(cue) is silent")
                XCTAssertLessThanOrEqual(peak, 0.721, "\(theme) \(cue) exceeded safe headroom")
                XCTAssertLessThan(abs(samples.first ?? 1), 0.0001, "\(theme) \(cue) starts abruptly")
                XCTAssertLessThan(abs(samples.last ?? 1), 0.0001, "\(theme) \(cue) ends abruptly")
            }
        }
    }

    func testThemesProduceDifferentRecipes() {
        for cue in SoundCue.allCases {
            let recipes = SoundTheme.allCases.map { $0.recipe(for: cue) }
            XCTAssertEqual(Set(recipes.map(\.masterGain)).count, SoundTheme.allCases.count)
        }
    }

    func testAuthoredThemesAddPerCueGestures() {
        for cue in SoundCue.allCases {
            XCTAssertGreaterThan(
                SoundTheme.signature.recipe(for: cue).layers.count,
                cue.recipe.layers.count,
                "Signature+ needs an authored accent for \(cue)"
            )
            XCTAssertGreaterThan(
                SoundTheme.wonderland.recipe(for: cue).layers.count,
                cue.recipe.layers.count,
                "Wonderland needs an authored gesture for \(cue)"
            )
        }
    }

    func testVariationIsBoundedAndActuallyVaries() {
        let variants = (0..<VariationGenerator.count).map {
            VariationGenerator.make(id: "press", index: $0, amount: 1)
        }
        XCTAssertEqual(Set(variants.map(\.pitchMultiplier)).count, VariationGenerator.count)
        XCTAssertTrue(variants.allSatisfy { (0.98...1.02).contains($0.pitchMultiplier) })
        XCTAssertTrue(variants.allSatisfy { (0.94...1.06).contains(Double($0.gainMultiplier)) })
        XCTAssertTrue(variants.allSatisfy { (-0.21...0.21).contains(Double($0.pan)) })
    }

    func testZeroVariationIsStable() {
        let variants = (0..<VariationGenerator.count).map {
            VariationGenerator.make(id: "press", index: $0, amount: 0)
        }
        XCTAssertTrue(variants.allSatisfy { $0.pitchMultiplier == 1 })
        XCTAssertTrue(variants.allSatisfy { $0.gainMultiplier == 1 })
        XCTAssertTrue(variants.allSatisfy { $0.timingOffset == 0 })
        XCTAssertTrue(variants.allSatisfy { $0.brightness == 1 })
    }
}
