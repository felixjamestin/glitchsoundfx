import AVFAudio
import XCTest
@testable import GlitchSoundFX

final class ProceduralThemeTests: XCTestCase {
    func testOppositeActionsHaveOppositePitchDirections() throws {
        let pairs: [(SoundCue, SoundCue)] = [
            (.release, .press), (.toggleOn, .toggleOff),
            (.open, .close), (.forward, .backward)
        ]
        for (rising, falling) in pairs {
            XCTAssertGreaterThan(try pitchChange(for: rising), 0, "\(rising)")
            XCTAssertLessThan(try pitchChange(for: falling), 0, "\(falling)")
        }
    }

    func testAllProceduralVariationsStayAudibleShortAndBelowTheLimiter() throws {
        for cue in SoundCue.allCases {
            for index in 0..<VariationGenerator.count {
                let buffer = try XCTUnwrap(SoundRenderer.render(
                    recipe: SoundTheme.procedural.recipe(for: cue),
                    id: "procedural.\(cue.rawValue)",
                    variationIndex: index,
                    variationAmount: 1
                ))
                let data = try XCTUnwrap(buffer.floatChannelData?[0])
                let samples = UnsafeBufferPointer(start: data, count: Int(buffer.frameLength))
                let peak = samples.map { abs($0) }.max() ?? 0
                let context = "\(cue), variant \(index)"
                XCTAssertTrue(samples.allSatisfy(\.isFinite), context)
                XCTAssertGreaterThan(peak, 0.05, context)
                XCTAssertLessThan(peak, 0.70, context)
                XCTAssertLessThan(Double(buffer.frameLength) / buffer.format.sampleRate, 0.55, context)
                XCTAssertLessThan(abs(samples.first ?? 1), 0.0001, context)
                XCTAssertLessThan(abs(samples.last ?? 1), 0.0001, context)
            }
        }
    }

    private func pitchChange(for cue: SoundCue) throws -> Double {
        let tones = SoundTheme.procedural.recipe(for: cue).layers.compactMap { layer -> SoundLayer.Tone? in
            if case let .tone(tone) = layer { return tone }
            return nil
        }
        let first = try XCTUnwrap(tones.first)
        let last = try XCTUnwrap(tones.last)
        return (last.glideTo ?? last.frequency) - first.frequency
    }
}
