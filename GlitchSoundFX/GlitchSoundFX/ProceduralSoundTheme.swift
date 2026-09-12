import Foundation

extension SoundTheme {
    /// Adapts selected Procedural Sounds patches to the native renderer.
    /// See THIRD-PARTY-NOTICES.md for source IDs, changes, and license terms.
    func proceduralRecipe(for cue: SoundCue) -> SoundRecipe {
        let layers: [SoundLayer]

        switch cue {
        case .tick:
            layers = [
                proceduralTone(1_087.486, glideTo: 1_365.809, attack: 0.004, decay: 0.028, gain: 0.058)
            ]
        case .press, .release:
            let pressing = cue == .press
            layers = [
                proceduralTone(
                    pressing ? 501.249 : 400.999,
                    glideTo: pressing ? 400.999 : 501.249,
                    decay: 0.052,
                    gain: 0.06
                )
            ]
        case .toggleOn, .toggleOff:
            let turningOn = cue == .toggleOn
            layers = [
                proceduralTone(turningOn ? 860.07 : 1_288.65, decay: 0.048, gain: 0.198),
                proceduralTone(turningOn ? 1_288.65 : 860.07, offset: 0.068, decay: 0.032, gain: 0.12)
            ]
        case .select:
            layers = [
                proceduralTone(914.072, attack: 0.006, decay: 0.074, gain: 0.237)
            ]
        case .open, .close:
            let opening = cue == .open
            layers = [
                proceduralTone(
                    opening ? 385.763 : 482.388,
                    glideTo: opening ? 482.388 : 385.763,
                    attack: 0.007,
                    decay: 0.11,
                    gain: 0.13
                )
            ]
        case .forward, .backward:
            let advancing = cue == .forward
            layers = [
                proceduralTone(advancing ? 348.106 : 459.425, decay: 0.07, gain: 0.1),
                proceduralTone(advancing ? 459.425 : 348.106, offset: 0.08, decay: 0.055, gain: 0.08)
            ]
        case .confirm:
            layers = [
                proceduralTone(997.603, decay: 0.05, gain: 0.1),
                proceduralTone(1_816.504, offset: 0.05, decay: 0.05, gain: 0.05)
            ]
        case .success:
            layers = [
                proceduralTone(435.402, attack: 0.003, decay: 0.15, gain: 0.185),
                proceduralTone(581.192, offset: 0.068, attack: 0.002, decay: 0.097, gain: 0.142),
                proceduralTone(870.803, offset: 0.136, attack: 0.006, decay: 0.319, gain: 0.138)
            ]
        case .warning:
            layers = [
                proceduralTone(543.828, waveform: .triangle, attack: 0.012, decay: 0.124717, gain: 0.3),
                proceduralTone(543.828, waveform: .triangle, offset: 0.10346, attack: 0.012, decay: 0.234205, gain: 0.3)
            ]
        case .error:
            layers = [
                proceduralTone(371.015, waveform: .triangle, attack: 0.004, decay: 0.097, gain: 0.181),
                proceduralTone(262.348, waveform: .triangle, offset: 0.136, attack: 0.004, decay: 0.135, gain: 0.167)
            ]
        case .delete:
            layers = [
                proceduralTone(717.228, glideTo: 239.076, decay: 0.16, gain: 0.16)
            ]
        case .notify:
            layers = [
                proceduralTone(713.747, attack: 0.007, decay: 0.121, gain: 0.154),
                proceduralTone(1_069.413, offset: 0.074, attack: 0.006, decay: 0.176, gain: 0.116)
            ]
        case .bloom:
            layers = [
                proceduralTone(343.058, glideTo: 514.006, attack: 0.002, decay: 0.274, gain: 0.176),
                proceduralTone(514.006, offset: 0.04, attack: 0.067, decay: 0.333, gain: 0.101)
            ]
        case .sparkle:
            layers = [
                proceduralTone(1_432.101, decay: 0.016, gain: 0.175),
                proceduralTone(942.648, offset: 0.064, decay: 0.051, gain: 0.134),
                proceduralTone(1_661.134, offset: 0.129, decay: 0.056, gain: 0.125)
            ]
        }

        return SoundRecipe(layers: layers, masterGain: cue == .warning ? 0.32 : 0.42)
    }

    private func proceduralTone(
        _ frequency: Double,
        glideTo: Double? = nil,
        waveform: SoundLayer.Tone.Waveform = .sine,
        offset: TimeInterval = 0,
        attack: TimeInterval = 0.001,
        decay: TimeInterval,
        gain: Float
    ) -> SoundLayer {
        // Scale source gains to fit the renderer's output boost.
        .tone(.init(
            frequency: frequency,
            glideTo: glideTo,
            waveform: waveform,
            offset: offset,
            attack: attack,
            decay: decay,
            gain: gain * 0.22
        ))
    }
}
