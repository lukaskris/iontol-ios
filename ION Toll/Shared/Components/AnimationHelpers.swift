import SwiftUI
import UIKit

// MARK: - Haptic Feedback

enum Haptic {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

// MARK: - Staggered Fade-In Modifier

struct StaggeredFadeIn: ViewModifier {
    let index: Int
    let total: Int
    let baseDelay: Double

    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 16)
            .onAppear {
                let delay = baseDelay * Double(index)
                withAnimation(.spring(duration: 0.45, bounce: 0.15).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func staggeredFadeIn(index: Int, total: Int = 1, baseDelay: Double = 0.06) -> some View {
        modifier(StaggeredFadeIn(index: index, total: total, baseDelay: baseDelay))
    }
}

// MARK: - Press Scale Button Style

struct PressScaleButtonStyle: ButtonStyle {
    let scale: CGFloat

    init(scale: CGFloat = 0.96) {
        self.scale = scale
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.spring(duration: 0.25, bounce: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressScaleButtonStyle {
    static var pressScale: PressScaleButtonStyle {
        PressScaleButtonStyle()
    }
}

// MARK: - Shake Effect (for errors)

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 8
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(animatableData * .pi * CGFloat(shakesPerUnit))
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

// MARK: - Card Press Modifier (for non-button tappable areas)

struct CardPressModifier: ViewModifier {
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(duration: 0.25, bounce: 0.1), value: isPressed)
    }
}

// MARK: - Fade + Slide Transition

extension AnyTransition {
    static var fadeSlideUp: AnyTransition {
        .opacity.combined(with: .move(edge: .bottom))
    }

    static var fadeSlideLeading: AnyTransition {
        .opacity.combined(with: .move(edge: .leading))
    }
}
