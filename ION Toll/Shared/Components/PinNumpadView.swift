import SwiftUI

struct PinNumpadView: View {
    let onDigit: (String) -> Void
    let onDelete: () -> Void

    private let rows = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
    ]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { digit in
                        digitButton(digit)
                    }
                }
            }

            HStack(spacing: 12) {
                Spacer()
                    .frame(maxWidth: .infinity)

                digitButton("0")

                deleteButton
            } 
        }.padding(16)
    }

    private func digitButton(_ digit: String) -> some View {
        Button {
            onDigit(digit)
        } label: {
            Text(digit)
                .font(.ionTitle2)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(Circle().fill(Color(.tertiarySystemBackground)))
                .overlay(Circle().stroke(Color(.separator), lineWidth: 1))
        }
        .buttonStyle(.pressScale)
    }

    private var deleteButton: some View {
        Button(action: onDelete) {
            Image(systemName: "delete.left")
                .font(.title3)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(Circle().fill(Color(.tertiarySystemBackground)))
                .overlay(Circle().stroke(Color(.separator), lineWidth: 1))
        }
        .buttonStyle(.pressScale)
    }
}
