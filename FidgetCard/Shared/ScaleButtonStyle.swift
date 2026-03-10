import SwiftUI

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: configuration.isPressed ? 0.08 : 0.12), value: configuration.isPressed)
            .sensoryFeedback(.impact(flexibility: .solid, intensity: 0.4), trigger: configuration.isPressed) { _, newValue in
                newValue
            }
    }
}
