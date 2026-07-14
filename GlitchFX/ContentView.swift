import SwiftUI
import AppKit

private final class GlitchFXAppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}

@main
struct GlitchFXShowcaseApp: App {
    @NSApplicationDelegateAdaptor(GlitchFXAppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @AppStorage("glitchFX.soundEnabled") private var isSoundEnabled = true
    @AppStorage("glitchFX.hapticsEnabled") private var isHapticsEnabled = true
    @AppStorage("glitchFX.volume") private var volume = 0.8
    @AppStorage("glitchFX.variation") private var variation = 0.72
    @AppStorage("glitchFX.playInSilentMode") private var playInSilentMode = false

    @State private var isSettingsPresented = false
    @State private var isFocusModeOn = false
    @State private var level = 0.55
    @State private var quantity = 2
    @State private var selectedMode = DemoMode.gentle
    @State private var selectedTheme = SoundTheme.signature
    @State private var lastCue = SoundCue.bloom
    @State private var playCount = 0

    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 220), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.035, green: 0.045, blue: 0.075)
                    .ignoresSafeArea()

//                AmbientBackdrop(lastCue: lastCue, playCount: playCount)

                ScrollView {
                    LazyVStack(spacing: 18) {
                        HeroCard(lastCue: lastCue, playCount: playCount) {
                            play(.backward)
                        }

                        DemoSection(
                            eyebrow: "01 · PALETTE",
                            title: "Nine coherent sound worlds",
                            detail: "Signature+ is the most resolved; Wonderland is the strange one. Every cue keeps its meaning while changing material and character."
                        ) {
                            ThemeSelector(selection: $selectedTheme)

                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(SoundCue.allCases) { cue in
                                    CueCard(cue: cue, isLatest: cue == lastCue) {
                                        play(cue)
                                    }
                                }
                            }
                        }

                        DemoSection(
                            eyebrow: "02 · CONTROLS",
                            title: "Built for real SwiftUI",
                            detail: "Native controls keep their behavior and accessibility; sound is an extra sensory layer."
                        ) {
                            VStack(spacing: 0) {
                                ControlRow(
                                    icon: "moon.stars.fill",
                                    title: "Focus mode",
                                    detail: "Related on/off cues"
                                ) {
                                    SoundToggle(isOn: $isFocusModeOn) {
                                        EmptyView()
                                    }
                                    .labelsHidden()
                                }

                                Divider().overlay(.white.opacity(0.08))

                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Label("Intensity", systemImage: "waveform.path")
                                            .font(.subheadline.weight(.semibold))
                                        Spacer()
                                        Text(level, format: .percent.precision(.fractionLength(0)))
                                            .font(.system(.caption, design: .monospaced, weight: .bold))
                                            .foregroundStyle(.white.opacity(0.62))
                                    }
                                    SoundSlider(value: $level, step: 0.05) {
                                        Text("Intensity")
                                    }
                                    .tint(CueColor.mint.color)
                                }
                                .padding(16)

                                Divider().overlay(.white.opacity(0.08))

                                ControlRow(
                                    icon: "square.stack.3d.up.fill",
                                    title: "Layers",
                                    detail: "Discrete selection ticks"
                                ) {
                                    HStack(spacing: 12) {
                                        CompactSoundButton(symbol: "minus") {
                                            quantity = max(quantity - 1, 1)
                                        }
                                        Text("\(quantity)")
                                            .font(.system(.body, design: .rounded, weight: .bold))
                                            .frame(minWidth: 18)
                                        CompactSoundButton(symbol: "plus") {
                                            quantity = min(quantity + 1, 5)
                                        }
                                    }
                                }
                            }
                            .background(.white.opacity(0.045), in: .rect(cornerRadius: 22))

                            Picker("Character", selection: $selectedMode) {
                                ForEach(DemoMode.allCases) { mode in
                                    Text(mode.title).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .soundEffect(.select, trigger: selectedMode)

                            HStack(spacing: 12) {
                                OutcomeButton(
                                    title: "Save",
                                    symbol: "checkmark",
                                    tint: CueColor.mint.color,
                                    cue: .success
                                ) { playCount += 1 }

                                OutcomeButton(
                                    title: "Delete",
                                    symbol: "trash",
                                    tint: CueColor.coral.color,
                                    cue: .delete
                                ) { playCount += 1 }
                            }

                            LiquidGlassButtonExamples {
                                playCount += 1
                            }
                        }

                        DemoSection(
                            eyebrow: "03 · RELATIONSHIPS",
                            title: "Opposites sound related",
                            detail: "Direction is reinforced with mirrored pitch movement instead of one generic click."
                        ) {
                            HStack(spacing: 12) {
                                DirectionButton(title: "Back", symbol: "arrow.left", cue: .backward) {
                                    play(.backward)
                                }
                                DirectionButton(title: "Forward", symbol: "arrow.right", cue: .forward) {
                                    play(.forward)
                                }
                            }

                            HStack(spacing: 12) {
                                DirectionButton(title: "Close", symbol: "rectangle.compress.vertical", cue: .close) {
                                    play(.close)
                                }
                                DirectionButton(title: "Open", symbol: "rectangle.expand.vertical", cue: .open) {
                                    play(.open)
                                }
                            }
                        }

                        DemoSection(
                            eyebrow: "04 · HOVER",
                            title: "Sound under the pointer",
                            detail: "Attach a cue to one specific view. Each example changes color and plays once when the pointer enters."
                        ) {
                            HoverSoundExamples()
                        }

                        DemoSection(
                            eyebrow: "05 · DROP-IN API",
                            title: "One line where it matters",
                            detail: "Use the palette, a component, a style, or state-driven feedback."
                        ) {
                            CodeSample()
                        }

                        DesignPrinciplesCard()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .frame(maxWidth: 760)
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
            }
            .foregroundStyle(.white)
            .navigationTitle("GlitchFX Lab")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isSettingsPresented = true
                        play(.open)
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .accessibilityLabel("Sound settings")
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $isSettingsPresented, onDismiss: { play(.close) }) {
            SettingsView(
                isSoundEnabled: $isSoundEnabled,
                isHapticsEnabled: $isHapticsEnabled,
                volume: $volume,
                variation: $variation,
                playInSilentMode: $playInSilentMode
            )
            .presentationDetents([.medium, .large])
        }
        .onAppear { applyConfiguration() }
        .onChange(of: currentConfiguration) { _, newValue in
            Soundscape.shared.configure(newValue)
        }
        .onChange(of: selectedTheme) { _, newTheme in
            applyConfiguration()
            lastCue = .confirm
            playCount += 1
            Soundscape.shared.play(.confirm, theme: newTheme)
        }
    }

    private var currentConfiguration: Soundscape.Configuration {
        .init(
            isSoundEnabled: isSoundEnabled,
            isHapticsEnabled: isHapticsEnabled,
            volume: Float(volume),
            variation: variation,
            defaultTheme: selectedTheme,
            audioPolicy: playInSilentMode ? .playInSilentMode : .respectSilentMode
        )
    }

    private func applyConfiguration() {
        Soundscape.shared.configure(currentConfiguration)
    }

    private func play(_ cue: SoundCue) {
        lastCue = cue
        playCount += 1
        Soundscape.shared.play(cue)
    }
}

private struct HeroCard: View {
    let lastCue: SoundCue
    let playCount: Int
    let play: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("THE SOUND OF TOUCH")
                        .font(.system(.caption2, design: .monospaced, weight: .bold))
                        .tracking(1.7)
                        .foregroundStyle(CueColor.mint.color)
                    Text("Make software\nfeel tangible.")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .tracking(-1.2)
                }
                Spacer(minLength: 8)
                Image(systemName: "waveform.badge.sparkles")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(CueColor.lilac.color)
                    .symbolEffect(.bounce, value: playCount)
            }

            Text("A dependency-free SwiftUI sound system: layered synthesis, meaningful cue families, subtle human variation, and paired haptics.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.68))
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 14) {
                MiniWaveform(playCount: playCount, color: lastCue.cueColor.color)
                    .frame(maxWidth: .infinity)

                Button(action: play) {
                    Label("Hear it", systemImage: "play.fill")
                        .font(.subheadline.weight(.bold))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 13)
                }
                .buttonStyle(
                    HoverColorButtonStyle(
                        normalColor: .white,
                        hoverColor: CueColor.mint.color,
                        foregroundColor: .black,
                        shape: .capsule
                    )
                )
            }
        }
        .padding(22)
        .background {
            LinearGradient(
                colors: [
                    Color(red: 0.11, green: 0.12, blue: 0.22),
                    Color(red: 0.075, green: 0.08, blue: 0.14)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(.rect(cornerRadius: 28))
            .overlay {
                RoundedRectangle(cornerRadius: 28)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            }
        }
    }
}

private struct CueCard: View {
    let cue: SoundCue
    let isLatest: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: cue.symbol)
                        .font(.system(size: 16, weight: .bold))
                        .frame(width: 34, height: 34)
                        .background(cue.cueColor.color.opacity(0.16), in: .circle)
                        .foregroundStyle(cue.cueColor.color)
                    Spacer()
                    Circle()
                        .fill(isLatest ? cue.cueColor.color : .white.opacity(0.15))
                        .frame(width: 6, height: 6)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(cue.title)
                        .font(.subheadline.weight(.bold))
                    Text(cue.character)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.52))
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(15)
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isLatest ? cue.cueColor.color.opacity(0.38) : .white.opacity(0.06))
            }
        }
        .buttonStyle(
            CueCardButtonStyle(
                normalColor: .white.opacity(isLatest ? 0.085 : 0.045),
                hoverColor: cue.cueColor.color.opacity(0.18),
                cornerRadius: 18
            )
        )
        .accessibilityLabel("Play \(cue.title) sound")
    }
}

private struct ThemeSelector: View {
    @Binding var selection: SoundTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView(.horizontal) {
                HStack(spacing: 9) {
                    ForEach(SoundTheme.allCases) { theme in
                        Button {
                            selection = theme
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: theme.demoSymbol)
                                        .font(.caption.weight(.bold))
                                    if let badge = theme.demoBadge {
                                        Text(badge)
                                            .font(.system(size: 8, weight: .black, design: .rounded))
                                            .tracking(0.6)
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 3)
                                            .background(theme.demoColor.opacity(0.18), in: .capsule)
                                    }
                                }
                                .foregroundStyle(theme.demoColor)

                                Text(theme.title)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white)
                            }
                            .frame(minWidth: 106, alignment: .leading)
                            .padding(12)
                            .overlay {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        selection == theme
                                            ? theme.demoColor.opacity(0.55)
                                            : .white.opacity(0.06)
                                    )
                            }
                        }
                        .buttonStyle(
                            CueCardButtonStyle(
                                normalColor: selection == theme
                                    ? theme.demoColor.opacity(0.16)
                                    : .white.opacity(0.045),
                                hoverColor: theme.demoColor.opacity(0.28),
                                cornerRadius: 14
                            )
                        )
                        .accessibilityLabel("Use \(theme.title) sound theme")
                    }
                }
            }
            .scrollIndicators(.hidden)

            Text(selection.detail)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.52))
        }
    }
}

private struct DemoSection<Content: View>: View {
    let eyebrow: String
    let title: String
    let detail: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(eyebrow)
                    .font(.system(.caption2, design: .monospaced, weight: .bold))
                    .tracking(1.3)
                    .foregroundStyle(CueColor.lilac.color)
                Text(title)
                    .font(.title3.weight(.bold))
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.58))
                    .fixedSize(horizontal: false, vertical: true)
            }
            content
        }
        .padding(20)
        .background(.black.opacity(0.18), in: .rect(cornerRadius: 26))
        .overlay {
            RoundedRectangle(cornerRadius: 26)
                .stroke(.white.opacity(0.07))
        }
    }
}

private struct ControlRow<Trailing: View>: View {
    let icon: String
    let title: String
    let detail: String
    @ViewBuilder let trailing: Trailing

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 28)
                .foregroundStyle(CueColor.sky.color)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(detail).font(.caption).foregroundStyle(.white.opacity(0.48))
            }
            Spacer()
            trailing
        }
        .padding(16)
    }
}

private struct CompactSoundButton: View {
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.caption.weight(.bold))
                .frame(width: 30, height: 30)
        }
        .buttonStyle(
            SoundButtonStyle(
                release: .select,
                backgroundColor: .white.opacity(0.08),
                hoverColor: CueColor.sky.color.opacity(0.28),
                hoverCornerRadius: 15
            )
        )
    }
}

private struct OutcomeButton: View {
    let title: String
    let symbol: String
    let tint: Color
    let cue: SoundCue
    let action: () -> Void

    var body: some View {
        SoundButton(
            actionCue: cue,
            backgroundColor: tint.opacity(0.16),
            hoverColor: tint.opacity(0.3),
            hoverCornerRadius: 15,
            action: action
        ) {
            Label(title, systemImage: symbol)
                .font(.subheadline.weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(tint)
                .overlay {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(tint.opacity(0.25))
                }
        }
    }
}

private struct LiquidGlassButtonExamples: View {
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("LIQUID GLASS VARIANTS")
                    .font(.system(.caption2, design: .monospaced, weight: .bold))
                    .tracking(1.1)
                    .foregroundStyle(CueColor.lilac.color)
                Text("Default, primary, success, and destructive treatments")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }

            groupedButtons
        }
    }

    @ViewBuilder
    private var groupedButtons: some View {
        #if os(visionOS)
        buttons
        #else
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            GlassEffectContainer(spacing: 12) {
                buttons
            }
        } else {
            buttons
        }
        #endif
    }

    private var buttons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                LiquidGlassDemoButton(
                    title: "Preview",
                    symbol: "play.fill",
                    cue: .select,
                    action: action
                )
                LiquidGlassDemoButton(
                    title: "Create",
                    symbol: "sparkles",
                    cue: .sparkle,
                    tint: CueColor.lilac.color,
                    action: action
                )
            }

            HStack(spacing: 12) {
                LiquidGlassDemoButton(
                    title: "Confirm",
                    symbol: "checkmark",
                    cue: .success,
                    tint: CueColor.mint.color,
                    action: action
                )
                LiquidGlassDemoButton(
                    title: "Remove",
                    symbol: "trash",
                    cue: .delete,
                    tint: CueColor.coral.color,
                    action: action
                )
            }
        }
    }
}

private struct LiquidGlassDemoButton: View {
    let title: String
    let symbol: String
    let cue: SoundCue
    var tint: Color? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.subheadline.weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
        }
        .buttonStyle(
            LiquidGlassSoundButtonStyle(
                release: cue,
                theme: .glass,
                tint: tint,
                cornerRadius: 17
            )
        )
        .accessibilityLabel("Play \(title) Liquid Glass button sound")
    }
}

private struct DirectionButton: View {
    let title: String
    let symbol: String
    let cue: SoundCue
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: symbol)
                Text(title)
                Spacer()
                Image(systemName: "waveform")
                    .foregroundStyle(cue.cueColor.color)
            }
            .font(.subheadline.weight(.semibold))
            .padding(15)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            CueCardButtonStyle(
                normalColor: .white.opacity(0.05),
                hoverColor: cue.cueColor.color.opacity(0.2),
                cornerRadius: 16
            )
        )
    }
}

private struct CodeSample: View {
    private let code = """
    Button("Save") { save() }
      .buttonStyle(SoundButtonStyle(theme: .signature))

    Button("Glass action") { performAction() }
      .buttonStyle(LiquidGlassSoundButtonStyle(tint: .purple))

    Toggle("Focus", isOn: $focus)
      .soundEffect(.toggleOn, trigger: focus, theme: .soft)

    Text("Hover for details")
      .soundOnHover(.select)

    Image(systemName: "photo")
      .soundOnHover(.sparkle, theme: .glass)

    Soundscape.shared.play(.success, theme: .wonderland)
    """

    var body: some View {
        ScrollView(.horizontal) {
            Text(code)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.white.opacity(0.78))
                .padding(16)
        }
        .scrollIndicators(.hidden)
        .background(Color.black.opacity(0.32), in: .rect(cornerRadius: 18))
        .overlay(alignment: .topTrailing) {
            Text("SWIFT")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .tracking(1)
                .foregroundStyle(CueColor.mint.color)
                .padding(10)
        }
    }
}

private struct HoverSoundExamples: View {
    @State private var isTextHovered = false
    @State private var isImageHovered = false

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                Label("TEXT", systemImage: "textformat")
                    .font(.system(.caption2, design: .monospaced, weight: .bold))
                    .foregroundStyle(.white.opacity(0.48))

                Text("Hover this phrase")
                    .font(.headline)
                    .foregroundStyle(isTextHovered ? CueColor.amber.color : .white)
                    .soundOnHover(.select)
                    .onHover { isTextHovered = $0 }

                Text("Plays Select")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.46))
            }
            .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
            .padding(16)
            .background(
                (isTextHovered ? CueColor.amber.color : Color.white)
                    .opacity(isTextHovered ? 0.12 : 0.045),
                in: .rect(cornerRadius: 18)
            )

            VStack(alignment: .leading, spacing: 12) {
                Label("IMAGE", systemImage: "photo")
                    .font(.system(.caption2, design: .monospaced, weight: .bold))
                    .foregroundStyle(.white.opacity(0.48))

                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(isImageHovered ? CueColor.lilac.color : CueColor.sky.color)
                    .contentShape(.rect)
                    .soundOnHover(.sparkle, theme: .glass)
                    .onHover { isImageHovered = $0 }

                Text("Plays Sparkle")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.46))
            }
            .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
            .padding(16)
            .background(
                (isImageHovered ? CueColor.lilac.color : Color.white)
                    .opacity(isImageHovered ? 0.12 : 0.045),
                in: .rect(cornerRadius: 18)
            )
        }
        .animation(.easeOut(duration: 0.14), value: isTextHovered)
        .animation(.easeOut(duration: 0.14), value: isImageHovered)
    }
}

private struct DesignPrinciplesCard: View {
    private let principles = [
        ("12×", "bounded variants"),
        ("9", "sound themes"),
        ("0", "audio files"),
        ("∞", "custom recipes")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("DESIGNED TO STAY DELIGHTFUL")
                .font(.system(.caption2, design: .monospaced, weight: .bold))
                .tracking(1.3)
                .foregroundStyle(CueColor.coral.color)

            HStack(spacing: 8) {
                ForEach(principles, id: \.1) { value, label in
                    VStack(spacing: 5) {
                        Text(value)
                            .font(.system(.title3, design: .rounded, weight: .bold))
                        Text(label)
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [CueColor.coral.color.opacity(0.12), CueColor.lilac.color.opacity(0.08)],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: .rect(cornerRadius: 22)
        )
    }
}

private struct SettingsView: View {
    @Binding var isSoundEnabled: Bool
    @Binding var isHapticsEnabled: Bool
    @Binding var volume: Double
    @Binding var variation: Double
    @Binding var playInSilentMode: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Feedback") {
                    Toggle("Interaction sounds", isOn: $isSoundEnabled)
                    Toggle("Haptics", isOn: $isHapticsEnabled)
                }

                Section("Character") {
                    LabeledContent("Volume", value: volume, format: .percent)
                    Slider(value: $volume)
                    LabeledContent("Human variation", value: variation, format: .percent)
                    Slider(value: $variation)
                }

                Section {
                    Toggle("Play in silent mode", isOn: $playInSilentMode)
                } footer: {
                    Text("Leave this off for ordinary interface feedback. Turn it on only when sound is central to the experience.")
                }
            }
            .navigationTitle("Sound settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct AmbientBackdrop: View {
    let lastCue: SoundCue
    let playCount: Int

    var body: some View {
        GeometryReader { proxy in
            Circle()
                .fill(lastCue.cueColor.color.opacity(0.16))
                .frame(width: proxy.size.width * 0.9)
                .blur(radius: 90)
                .offset(x: proxy.size.width * 0.4, y: -proxy.size.height * 0.08)
                .scaleEffect(playCount.isMultiple(of: 2) ? 0.94 : 1.05)
                .animation(.easeOut(duration: 0.8), value: playCount)
        }
        .allowsHitTesting(false)
    }
}

private struct MiniWaveform: View {
    let playCount: Int
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<22, id: \.self) { index in
                Capsule()
                    .fill(color.opacity(0.45 + Double(index % 4) * 0.12))
                    .frame(width: 3, height: height(for: index))
            }
        }
        .frame(height: 36)
        .animation(.spring(response: 0.38, dampingFraction: 0.62), value: playCount)
        .accessibilityHidden(true)
    }

    private func height(for index: Int) -> CGFloat {
        let phase = Double(index) * 0.82 + Double(playCount) * 1.7
        return 7 + abs(sin(phase)) * 25
    }
}

private struct CueCardButtonStyle: ButtonStyle {
    var normalColor = Color.clear
    var hoverColor = CueColor.lilac.color.opacity(0.2)
    var cornerRadius: CGFloat = 16

    func makeBody(configuration: Configuration) -> some View {
        CueCardButtonStyleBody(
            configuration: configuration,
            normalColor: normalColor,
            hoverColor: hoverColor,
            cornerRadius: cornerRadius
        )
    }
}

private struct CueCardButtonStyleBody: View {
    let configuration: ButtonStyle.Configuration
    let normalColor: Color
    let hoverColor: Color
    let cornerRadius: CGFloat
    @State private var isHovering = false

    var body: some View {
        configuration.label
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(isHovering ? hoverColor : normalColor)
            }
            .scaleEffect(configuration.isPressed ? 0.975 : 1)
            .brightness(configuration.isPressed ? 0.07 : 0)
            .animation(.snappy(duration: 0.14), value: configuration.isPressed)
            .animation(.easeOut(duration: 0.14), value: isHovering)
            .onHover { isHovering = $0 }
    }
}

private struct HoverColorButtonStyle: ButtonStyle {
    enum Shape {
        case capsule
        case roundedRectangle(CGFloat)
    }

    let normalColor: Color
    let hoverColor: Color
    let foregroundColor: Color
    let shape: Shape

    func makeBody(configuration: Configuration) -> some View {
        HoverColorButtonStyleBody(
            configuration: configuration,
            normalColor: normalColor,
            hoverColor: hoverColor,
            foregroundColor: foregroundColor,
            shape: shape
        )
    }
}

private struct HoverColorButtonStyleBody: View {
    let configuration: ButtonStyle.Configuration
    let normalColor: Color
    let hoverColor: Color
    let foregroundColor: Color
    let shape: HoverColorButtonStyle.Shape
    @State private var isHovering = false

    var body: some View {
        configuration.label
            .background {
                switch shape {
                case .capsule:
                    Capsule().fill(isHovering ? hoverColor : normalColor)
                case let .roundedRectangle(radius):
                    RoundedRectangle(cornerRadius: radius)
                        .fill(isHovering ? hoverColor : normalColor)
                }
            }
            .foregroundStyle(foregroundColor)
            .scaleEffect(configuration.isPressed ? 0.975 : 1)
            .animation(.easeOut(duration: 0.14), value: isHovering)
            .animation(.snappy(duration: 0.14), value: configuration.isPressed)
            .onHover { isHovering = $0 }
    }
}

private enum DemoMode: String, CaseIterable, Identifiable {
    case gentle
    case crisp
    case playful

    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

private enum CueColor {
    case mint
    case sky
    case lilac
    case coral
    case amber

    var color: Color {
        switch self {
        case .mint: Color(red: 0.34, green: 0.94, blue: 0.72)
        case .sky: Color(red: 0.38, green: 0.72, blue: 1)
        case .lilac: Color(red: 0.68, green: 0.55, blue: 1)
        case .coral: Color(red: 1, green: 0.44, blue: 0.45)
        case .amber: Color(red: 1, green: 0.73, blue: 0.28)
        }
    }
}

private extension SoundCue {
    var title: String {
        switch self {
        case .toggleOn: "Toggle on"
        case .toggleOff: "Toggle off"
        default: rawValue.capitalized
        }
    }

    var character: String {
        switch self {
        case .tick: "crisp · instant"
        case .press: "muted · grounded"
        case .release: "bright · springy"
        case .toggleOn: "mechanical · rising"
        case .toggleOff: "mechanical · falling"
        case .select: "precise · light"
        case .open: "airy · expanding"
        case .close: "soft · resolving"
        case .forward: "warm · ascending"
        case .backward: "warm · descending"
        case .confirm: "clear · settled"
        case .success: "musical · rewarding"
        case .warning: "attentive · measured"
        case .error: "low · unmistakable"
        case .delete: "textured · weighty"
        case .notify: "present · spacious"
        case .bloom: "warm · swelling"
        case .sparkle: "bright · playful"
        }
    }

    var symbol: String {
        switch self {
        case .tick: "cursorarrow.click"
        case .press: "hand.point.down.fill"
        case .release: "hand.raised.fill"
        case .toggleOn: "switch.2"
        case .toggleOff: "switch.2"
        case .select: "scope"
        case .open: "rectangle.expand.vertical"
        case .close: "rectangle.compress.vertical"
        case .forward: "arrow.right"
        case .backward: "arrow.left"
        case .confirm: "checkmark.circle"
        case .success: "checkmark.seal.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .error: "xmark.octagon.fill"
        case .delete: "trash.fill"
        case .notify: "bell.fill"
        case .bloom: "camera.macro"
        case .sparkle: "sparkles"
        }
    }

    var cueColor: CueColor {
        switch self {
        case .press, .release, .tick, .select: .sky
        case .toggleOn, .open, .forward, .confirm, .success, .bloom: .mint
        case .toggleOff, .close, .backward, .notify: .lilac
        case .warning: .amber
        case .error, .delete: .coral
        case .sparkle: .amber
        }
    }
}

private extension SoundTheme {
    var demoBadge: String? {
        switch self {
        case .signature: "BEST"
        case .wonderland: "WILD"
        default: nil
        }
    }

    var demoSymbol: String {
        switch self {
        case .tactile: "hand.tap.fill"
        case .soft: "cloud.fill"
        case .glass: "diamond.fill"
        case .playful: "music.note"
        case .signature: "sparkle"
        case .organic: "leaf.fill"
        case .kinetic: "bolt.fill"
        case .neon: "light.beacon.max.fill"
        case .wonderland: "party.popper.fill"
        }
    }

    var demoColor: Color {
        switch self {
        case .tactile: CueColor.sky.color
        case .soft: Color.white.opacity(0.72)
        case .glass: CueColor.lilac.color
        case .playful: CueColor.amber.color
        case .signature: CueColor.mint.color
        case .organic: Color(red: 0.66, green: 0.78, blue: 0.42)
        case .kinetic: Color(red: 0.35, green: 0.82, blue: 1)
        case .neon: Color(red: 1, green: 0.3, blue: 0.78)
        case .wonderland: CueColor.coral.color
        }
    }
}

#Preview {
    ContentView()
}
