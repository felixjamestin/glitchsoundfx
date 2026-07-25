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

/// The glass material variant used by `LiquidGlassSoundButtonStyle`.
///
/// Mirrors SwiftUI's `Glass` presets without naming that type at the API
/// boundary, so the package keeps its existing deployment targets instead of
/// requiring OS 26. Each case also maps to a sensible pre-26 fallback material.
public enum GlassVariant: String, CaseIterable, Identifiable, Sendable {
    /// Standard Liquid Glass. Falls back to `.regularMaterial`.
    case regular
    /// More transparent glass that lets more of the backdrop through.
    /// Falls back to `.ultraThinMaterial`.
    case clear
    /// No glass material at all. Only the tint, border, and shadows remain.
    case identity

    public var id: String { rawValue }
}

/// A sound-enabled button style that uses Liquid Glass on OS 26+
/// and an adaptive material fallback on earlier releases. Press audio is opt-in.
public struct LiquidGlassSoundButtonStyle: ButtonStyle {
    private let pressCue: SoundCue?
    private let releaseCue: SoundCue
    private let theme: SoundTheme?
    private let glass: GlassVariant
    private let interactive: Bool
    private let tint: Color?
    private let hoverTint: Color?
    private let cornerRadius: CGFloat
    private let horizontalPadding: CGFloat
    private let verticalPadding: CGFloat
    private let kerning: CGFloat?
    private let fontSize: CGFloat?
    private let fontColor: Color?
    private let textShadowColor: Color?
    private let textShadowRadius: CGFloat
    private let textShadowX: CGFloat
    private let textShadowY: CGFloat
    private let borderColor: Color?
    private let borderWidth: CGFloat
    private let shadowColor: Color
    private let shadowRadius: CGFloat
    private let shadowX: CGFloat
    private let shadowY: CGFloat
    private let hoverShadowColor: Color?
    private let hoverShadowRadius: CGFloat
    private let hoverShadowX: CGFloat
    private let hoverShadowY: CGFloat
    private let hoverAnimationDuration: TimeInterval
    private let soundscape: Soundscape

    @MainActor
    public init(
        press: SoundCue? = nil,
        release: SoundCue = .release,
        theme: SoundTheme? = nil,
        glass: GlassVariant = .regular,
        interactive: Bool = true,
        tint: Color? = nil,
        hoverTint: Color? = nil,
        cornerRadius: CGFloat = 16,
        horizontalPadding: CGFloat = 0,
        verticalPadding: CGFloat = 0,
        kerning: CGFloat? = nil,
        fontSize: CGFloat? = nil,
        fontColor: Color? = nil,
        textShadowColor: Color? = nil,
        textShadowRadius: CGFloat = 0,
        textShadowX: CGFloat = 0,
        textShadowY: CGFloat = 0,
        borderColor: Color? = nil,
        borderWidth: CGFloat = 0,
        shadowColor: Color = .clear,
        shadowRadius: CGFloat = 0,
        shadowX: CGFloat = 0,
        shadowY: CGFloat = 0,
        hoverShadowColor: Color? = nil,
        hoverShadowRadius: CGFloat = 12,
        hoverShadowX: CGFloat = 0,
        hoverShadowY: CGFloat = 5,
        hoverAnimationDuration: TimeInterval = 0.14,
        soundscape: Soundscape? = nil
    ) {
        pressCue = press
        releaseCue = release
        self.theme = theme
        self.glass = glass
        self.interactive = interactive
        self.tint = tint
        self.hoverTint = hoverTint
        self.cornerRadius = max(0, cornerRadius)
        self.horizontalPadding = max(0, horizontalPadding)
        self.verticalPadding = max(0, verticalPadding)
        self.kerning = kerning
        self.fontSize = fontSize.map { max(1, $0) }
        self.fontColor = fontColor
        self.textShadowColor = textShadowColor
        self.textShadowRadius = max(0, textShadowRadius)
        self.textShadowX = textShadowX
        self.textShadowY = textShadowY
        self.borderColor = borderColor
        self.borderWidth = max(0, borderWidth)
        self.shadowColor = shadowColor
        self.shadowRadius = max(0, shadowRadius)
        self.shadowX = shadowX
        self.shadowY = shadowY
        self.hoverShadowColor = hoverShadowColor
        self.hoverShadowRadius = max(0, hoverShadowRadius)
        self.hoverShadowX = hoverShadowX
        self.hoverShadowY = hoverShadowY
        self.hoverAnimationDuration = max(0, hoverAnimationDuration)
        self.soundscape = soundscape ?? .shared
    }

    public func makeBody(configuration: Configuration) -> some View {
        LiquidGlassSoundButtonStyleBody(
            configuration: configuration,
            pressCue: pressCue,
            releaseCue: releaseCue,
            theme: theme,
            glass: glass,
            interactive: interactive,
            tint: tint,
            hoverTint: hoverTint,
            cornerRadius: cornerRadius,
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding,
            kerning: kerning,
            fontSize: fontSize,
            fontColor: fontColor,
            textShadowColor: textShadowColor,
            textShadowRadius: textShadowRadius,
            textShadowX: textShadowX,
            textShadowY: textShadowY,
            borderColor: borderColor,
            borderWidth: borderWidth,
            shadowColor: shadowColor,
            shadowRadius: shadowRadius,
            shadowX: shadowX,
            shadowY: shadowY,
            hoverShadowColor: hoverShadowColor,
            hoverShadowRadius: hoverShadowRadius,
            hoverShadowX: hoverShadowX,
            hoverShadowY: hoverShadowY,
            hoverAnimationDuration: hoverAnimationDuration,
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
    let pressCue: SoundCue?
    let releaseCue: SoundCue
    let theme: SoundTheme?
    let glass: GlassVariant
    let interactive: Bool
    let tint: Color?
    let hoverTint: Color?
    let cornerRadius: CGFloat
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let kerning: CGFloat?
    let fontSize: CGFloat?
    let fontColor: Color?
    let textShadowColor: Color?
    let textShadowRadius: CGFloat
    let textShadowX: CGFloat
    let textShadowY: CGFloat
    let borderColor: Color?
    let borderWidth: CGFloat
    let shadowColor: Color
    let shadowRadius: CGFloat
    let shadowX: CGFloat
    let shadowY: CGFloat
    let hoverShadowColor: Color?
    let hoverShadowRadius: CGFloat
    let hoverShadowX: CGFloat
    let hoverShadowY: CGFloat
    let hoverAnimationDuration: TimeInterval
    let soundscape: Soundscape
    @State private var isHovering = false

    var body: some View {
        styledLabel
            .overlay {
                if let borderColor, borderWidth > 0 {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(borderColor, lineWidth: borderWidth)
                }
            }
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: shadowX,
                y: shadowY
            )
            .shadow(
                color: resolvedHoverShadowColor,
                radius: isHovering ? hoverShadowRadius : 0,
                x: hoverShadowX,
                y: isHovering ? hoverShadowY : 0
            )
            .animation(.easeOut(duration: hoverAnimationDuration), value: isHovering)
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
            paddedLabel
                .contentShape(.rect(cornerRadius: cornerRadius))
                .glassEffect(
                    resolvedGlass.tint(glassTint),
                    in: .rect(cornerRadius: cornerRadius)
                )
        } else {
            fallbackLabel
        }
        #endif
    }

    // `Glass` is unavailable on visionOS entirely, so this mirrors the
    // platform bracketing used by `styledLabel` above.
    #if !os(visionOS)
    @available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *)
    private var resolvedGlass: Glass {
        let base: Glass = switch glass {
        case .regular: .regular
        case .clear: .clear
        case .identity: .identity
        }
        return base.interactive(interactive)
    }
    #endif

    private var fallbackLabel: some View {
        paddedLabel
            .contentShape(.rect(cornerRadius: cornerRadius))
            .background { fallbackMaterial }
            .overlay {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(fallbackTint)
                    if glass != .identity {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(.white.opacity(0.14), lineWidth: 1)
                    }
                }
            }
            // Liquid Glass renders its own press response on OS 26. This
            // approximates it wherever the material fallback is used, matching
            // the motion `SoundButtonStyle` already applies.
            .scaleEffect(isPressedInteractively ? 0.975 : 1)
            .opacity(isPressedInteractively ? 0.86 : 1)
            .animation(.snappy(duration: 0.16), value: isPressedInteractively)
    }

    private var isPressedInteractively: Bool {
        interactive && configuration.isPressed
    }

    /// Approximates each glass variant on releases without Liquid Glass.
    @ViewBuilder
    private var fallbackMaterial: some View {
        switch glass {
        case .regular:
            RoundedRectangle(cornerRadius: cornerRadius).fill(.regularMaterial)
        case .clear:
            RoundedRectangle(cornerRadius: cornerRadius).fill(.ultraThinMaterial)
        case .identity:
            Color.clear
        }
    }

    private var paddedLabel: some View {
        kernedLabel
            .shadow(
                color: textShadowColor ?? .clear,
                radius: textShadowRadius,
                x: textShadowX,
                y: textShadowY
            )
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
    }

    @ViewBuilder
    private var kernedLabel: some View {
        if let kerning {
            coloredLabel.kerning(kerning)
        } else {
            coloredLabel
        }
    }

    @ViewBuilder
    private var coloredLabel: some View {
        if let fontColor {
            fontSizedLabel.foregroundStyle(fontColor)
        } else {
            fontSizedLabel
        }
    }

    @ViewBuilder
    private var fontSizedLabel: some View {
        if let fontSize {
            configuration.label.font(.system(size: fontSize))
        } else {
            configuration.label
        }
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

    private var resolvedHoverShadowColor: Color {
        guard isHovering else { return .clear }
        return hoverShadowColor
            ?? (hoverTint ?? tint ?? Color.accentColor).opacity(0.28)
    }
}

private struct PressStateObserver: View {
    let isPressed: Bool
    let pressCue: SoundCue?
    let releaseCue: SoundCue
    let theme: SoundTheme?
    let soundscape: Soundscape
    @State private var hasPressed = false

    var body: some View {
        Color.clear
            .onChange(of: isPressed) { _, newValue in
                if newValue {
                    hasPressed = true
                    if let pressCue {
                        soundscape.play(pressCue, theme: theme, intensity: 0.75)
                    }
                } else if hasPressed {
                    hasPressed = false
                    soundscape.play(releaseCue, theme: theme, intensity: 0.65)
                }
            }
            .accessibilityHidden(true)
    }
}
