import SwiftUI

/// Three-dot typing indicator. Used by ChatView while the retriever runs and
/// by MessageBubble while an LLM stream is producing its first token.
struct TypingDotsView: View {
    var tint: Color = OColor.ember
    var size: CGFloat = 6

    @State private var phase: Double = 0

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(tint)
                    .frame(width: size, height: size)
                    .opacity(opacity(for: i))
            }
        }
        .frame(height: max(size * 2, 16))
        .onAppear {
            withAnimation(.linear(duration: 0.9).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
        .accessibilityHidden(true)
    }

    private func opacity(for i: Int) -> Double {
        let p = (phase * 3 - Double(i)).truncatingRemainder(dividingBy: 3)
        return max(0.25, 1.0 - abs(p - 1.0))
    }
}

#Preview {
    TypingDotsView()
        .padding()
        .background(OColor.surface)
}
