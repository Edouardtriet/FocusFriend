import SwiftUI

struct CircularCheckbox: View {
    let isCompleted: Bool
    var size: CGFloat = 20
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .stroke(isCompleted ? Color.completed : Color.textSecondary.opacity(0.4), lineWidth: 1.5)
                    .frame(width: size, height: size)

                if isCompleted {
                    Circle()
                        .fill(Color.completed)
                        .frame(width: size, height: size)

                    Image(systemName: "checkmark")
                        .font(.system(size: size * 0.5, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .frame(width: size + 10, height: size + 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
    }
}

#Preview {
    HStack(spacing: 20) {
        CircularCheckbox(isCompleted: false, action: {})
        CircularCheckbox(isCompleted: true, action: {})
    }
    .padding()
    .background(Color.panelBackground)
}
