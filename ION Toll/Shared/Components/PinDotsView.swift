import SwiftUI

struct PinDotsView: View {
    let pinLength: Int
    let filledCount: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<pinLength, id: \.self) { index in
                let isFilled = index < filledCount
                Circle()
                    .fill(isFilled ? Color.brandPrimary.opacity(0.15) : Color.clear)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(isFilled ? Color.brandPrimary : Color(.separator), lineWidth: 2)
                    )
                    .scaleEffect(isFilled ? 1.0 : 0.85)
                    .animation(.spring(duration: 0.3, bounce: 0.4), value: filledCount)
            }
        }
    }
}
