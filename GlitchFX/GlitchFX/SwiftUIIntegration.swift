import SwiftUI

public extension View {
    /// Plays a cue when an Equatable value changes. Ideal for state-driven feedback.
    @MainActor
    func soundEffect<Value: Equatable>(
        _ cue: SoundCue,
        trigger: Value,
        theme: SoundTheme? = nil,
        minimumInterval: TimeInterval = 0,
        soundscape: Soundscape? = nil
    ) -> some View {
        let soundscape = soundscape ?? .shared
        return modifier(
            SoundEffectModifier(
                cue: cue,
                trigger: trigger,
                theme: theme,
                minimumInterval: minimumInterval,
                soundscape: soundscape
            )
        )
    }

    /// Adds a release cue to any tappable view without replacing its existing gesture.
    @MainActor
    func soundOnTap(
        _ cue: SoundCue = .release,
        theme: SoundTheme? = nil,
        soundscape: Soundscape? = nil
    ) -> some View {
        let soundscape = soundscape ?? .shared
        return simultaneousGesture(
            TapGesture().onEnded { soundscape.play(cue, theme: theme) }
        )
    }

    /// Plays a cue once when the pointer enters this view.
    @MainActor
    func soundOnHover(
        _ cue: SoundCue = .select,
        theme: SoundTheme? = nil,
        minimumInterval: TimeInterval = 0.08,
        soundscape: Soundscape? = nil
    ) -> some View {
        let soundscape = soundscape ?? .shared
        return modifier(
            SoundOnHoverModifier(
                cue: cue,
                theme: theme,
                minimumInterval: minimumInterval,
                soundscape: soundscape
            )
        )
    }
}

/// A button style that treats touch-down and release as a related pair.
public struct SoundButtonStyle: ButtonStyle {
    private let pressCue: SoundCue
    private let releaseCue: SoundCue
    private let theme: SoundTheme?
    private let soundscape: Soundscape
    private let backgroundColor: Color
    private let hoverColor: Color
    private let hoverCornerRadius: CGFloat

    @MainActor
    public init(
        press: SoundCue = .press,
        release: SoundCue = .release,
        theme: SoundTheme? = nil,
        backgroundColor: Color = .clear,
        hoverColor: Color = Color.accentColor.opacity(0.22),
        hoverCornerRadius: CGFloat = 14,
        soundscape: Soundscape? = nil
    ) {
        pressCue = press
        releaseCue = release
        self.theme = theme
        self.backgroundColor = backgroundColor
        self.hoverColor = hoverColor
        self.hoverCornerRadius = hoverCornerRadius
        self.soundscape = soundscape ?? .shared
    }

    public func makeBody(configuration: Configuration) -> some View {
        SoundButtonStyleBody(
            configuration: configuration,
            pressCue: pressCue,
            releaseCue: releaseCue,
            theme: theme,
            soundscape: soundscape,
            backgroundColor: backgroundColor,
            hoverColor: hoverColor,
            hoverCornerRadius: hoverCornerRadius
        )
    }
}

/// A sound-enabled button style that uses Liquid Glass on OS 26+
/// and an adaptive material fallback on earlier releases.
public struct LiquidGlassSoundButtonStyle: ButtonStyle {
    private let pressCue: SoundCue
    private let releaseCue: SoundCue
    private let theme: SoundTheme?
    private let tint: Color?
    private let hoverTint: Color?
    private let cornerRadius: CGFloat
    private let soundscape: Soundscape

    @MainActor
    public init(
        press: SoundCue = .press,
        release: SoundCue = .release,
        theme: SoundTheme? = nil,
        tint: Color? = nil,
        hoverTint: Color? = nil,
        cornerRadius: CGFloat = 16,
        soundscape: Soundscape? = nil
    ) {
        pressCue = press
        releaseCue = release
        self.theme = theme
        self.tint = tint
        self.hoverTint = hoverTint
        self.cornerRadius = cornerRadius
        self.soundscape = soundscape ?? .shared
    }

    public func makeBody(configuration: Configuration) -> some View {
        LiquidGlassSoundButtonStyleBody(
            configuration: configuration,
            pressCue: pressCue,
            releaseCue: releaseCue,
            theme: theme,
            tint: tint,
            hoverTint: hoverTint,
            cornerRadius: cornerRadius,
            soundscape: soundscape
        )
    }
}

/// A ready-made button that adds press/release materiality and an optional outcome cue.
public struct SoundButton<Label: View>: View {
    private let actionCue: SoundCue?
    private let theme: SoundTheme?
    private let action: () -> Void
    private let label: Label
    private let soundscape: Soundscape
    private let backgroundColor: Color
    private let hoverColor: Color
    private let hoverCornerRadius: CGFloat

    @MainActor
    public init(
        actionCue: SoundCue? = nil,
        theme: SoundTheme? = nil,
        backgroundColor: Color = .clear,
        hoverColor: Color = Color.accentColor.opacity(0.22),
        hoverCornerRadius: CGFloat = 14,
        soundscape: Soundscape? = nil,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.actionCue = actionCue
        self.theme = theme
        self.backgroundColor = backgroundColor
        self.hoverColor = hoverColor
        self.hoverCornerRadius = hoverCornerRadius
        self.soundscape = soundscape ?? .shared
        self.action = action
        self.label = label()
    }

    public var body: some View {
        Button {
            action()
            if let actionCue { soundscape.play(actionCue, theme: theme) }
        } label: {
            label
        }
        .buttonStyle(
            SoundButtonStyle(
                theme: theme,
                backgroundColor: backgroundColor,
                hoverColor: hoverColor,
                hoverCornerRadius: hoverCornerRadius,
                soundscape: soundscape
            )
        )
    }
}

/// A native Toggle that plays related on/off cues only when its bound state changes.
public struct SoundToggle<Label: View>: View {
    @Binding private var isOn: Bool
    private let label: Label
    private let theme: SoundTheme?
    private let soundscape: Soundscape

    @MainActor
    public init(
        isOn: Binding<Bool>,
        theme: SoundTheme? = nil,
        soundscape: Soundscape? = nil,
        @ViewBuilder label: () -> Label
    ) {
        _isOn = isOn
        self.theme = theme
        self.soundscape = soundscape ?? .shared
        self.label = label()
    }

    public var body: some View {
        Toggle(isOn: $isOn) { label }
            .onChange(of: isOn) { _, newValue in
                soundscape.play(newValue ? .toggleOn : .toggleOff, theme: theme)
            }
    }
}

/// A native Slider with restrained, throttled ticks at discrete step boundaries.
public struct SoundSlider<Label: View>: View {
    @Binding private var value: Double
    private let range: ClosedRange<Double>
    private let step: Double
    private let label: Label
    private let theme: SoundTheme?
    private let soundscape: Soundscape

    @MainActor
    public init(
        value: Binding<Double>,
        in range: ClosedRange<Double> = 0...1,
        step: Double = 0.1,
        theme: SoundTheme? = nil,
        soundscape: Soundscape? = nil,
        @ViewBuilder label: () -> Label
    ) {
        _value = value
        self.range = range
        self.step = step
        self.theme = theme
        self.soundscape = soundscape ?? .shared
        self.label = label()
    }

    public var body: some View {
        Slider(value: $value, in: range, step: step) { label }
            .onChange(of: quantizedValue) { _, _ in
                soundscape.play(
                    .select,
                    theme: theme,
                    intensity: 0.55,
                    minimumInterval: 0.045
                )
            }
    }

    private var quantizedValue: Int {
        Int(((value - range.lowerBound) / step).rounded())
    }
}

private struct SoundEffectModifier<Value: Equatable>: ViewModifier {
    let cue: SoundCue
    let trigger: Value
    let theme: SoundTheme?
    let minimumInterval: TimeInterval
    let soundscape: Soundscape

    func body(content: Content) -> some View {
        content.onChange(of: trigger) { _, _ in
            soundscape.play(cue, theme: theme, minimumInterval: minimumInterval)
        }
    }
}

private struct SoundOnHoverModifier: ViewModifier {
    let cue: SoundCue
    let theme: SoundTheme?
    let minimumInterval: TimeInterval
    let soundscape: Soundscape
    @State private var isHovering = false

    func body(content: Content) -> some View {
        content.onHover { hovering in
            guard hovering != isHovering else { return }
            isHovering = hovering

            if hovering {
                soundscape.play(cue, theme: theme, minimumInterval: minimumInterval)
            }
        }
    }
}

private struct SoundButtonStyleBody: View {
    let configuration: ButtonStyle.Configuration
    let pressCue: SoundCue
    let releaseCue: SoundCue
    let theme: SoundTheme?
    let soundscape: Soundscape
    let backgroundColor: Color
    let hoverColor: Color
    let hoverCornerRadius: CGFloat
    @State private var isHovering = false

    var body: some View {
        configuration.label
            .background {
                RoundedRectangle(cornerRadius: hoverCornerRadius)
                    .fill(isHovering ? hoverColor : backgroundColor)
            }
            .scaleEffect(configuration.isPressed ? 0.975 : 1)
            .opacity(configuration.isPressed ? 0.86 : 1)
            .animation(.snappy(duration: 0.16), value: configuration.isPressed)
            .animation(.easeOut(duration: 0.14), value: isHovering)
            .onHover { isHovering = $0 }
            .background {
                PressStateObserver(
                    isPressed: configuration.isPressed,
                    pressCue: pressCue,
                    releaseCue: releaseCue,
                    theme: theme,
                    soundscape: soundscape
                )
            }
    }
}

private struct LiquidGlassSoundButtonStyleBody: View {
    let configuration: ButtonStyle.Configuration
    let pressCue: SoundCue
    let releaseCue: SoundCue
    let theme: SoundTheme?
    let tint: Color?
    let hoverTint: Color?
    let cornerRadius: CGFloat
    let soundscape: Soundscape
    @State private var isHovering = false

    var body: some View {
        styledLabel
            .onHover { isHovering = $0 }
            .background {
                PressStateObserver(
                    isPressed: configuration.isPressed,
                    pressCue: pressCue,
                    releaseCue: releaseCue,
                    theme: theme,
                    soundscape: soundscape
                )
            }
    }

    @ViewBuilder
    private var styledLabel: some View {
        #if os(visionOS)
        fallbackLabel
        #else
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            configuration.label
                .contentShape(.rect(cornerRadius: cornerRadius))
                .glassEffect(
                    .regular.tint(glassTint),
                    in: .rect(cornerRadius: cornerRadius)
                )
                .shadow(
                    color: hoverShadowColor,
                    radius: isHovering ? 12 : 0,
                    y: isHovering ? 5 : 0
                )
                .animation(.easeOut(duration: 0.14), value: isHovering)
        } else {
            fallbackLabel
        }
        #endif
    }

    private var fallbackLabel: some View {
        configuration.label
            .contentShape(.rect(cornerRadius: cornerRadius))
            .background(.regularMaterial, in: .rect(cornerRadius: cornerRadius))
            .overlay {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(fallbackTint)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(.white.opacity(0.14), lineWidth: 1)
                }
            }
            .shadow(
                color: hoverShadowColor,
                radius: isHovering ? 10 : 0,
                y: isHovering ? 4 : 0
            )
            .animation(.easeOut(duration: 0.14), value: isHovering)
    }

    private var glassTint: Color? {
        if isHovering {
            return hoverTint ?? tint ?? Color.accentColor.opacity(0.22)
        }
        return tint?.opacity(0.62)
    }

    private var fallbackTint: Color {
        if isHovering {
            return (hoverTint ?? tint ?? Color.accentColor).opacity(0.24)
        }
        return tint?.opacity(0.14) ?? .clear
    }

    private var hoverShadowColor: Color {
        guard isHovering else { return .clear }
        return (hoverTint ?? tint ?? Color.accentColor).opacity(0.28)
    }
}

private struct PressStateObserver: View {
    let isPressed: Bool
    let pressCue: SoundCue
    let releaseCue: SoundCue
    let theme: SoundTheme?
    let soundscape: Soundscape
    @State private var hasPressed = false

    var body: some View {
        Color.clear
            .onChange(of: isPressed) { _, newValue in
                if newValue {
                    hasPressed = true
                    soundscape.play(pressCue, theme: theme, intensity: 0.75)
                } else if hasPressed {
                    hasPressed = false
                    soundscape.play(releaseCue, theme: theme, intensity: 0.65)
                }
            }
            .accessibilityHidden(true)
    }
}
