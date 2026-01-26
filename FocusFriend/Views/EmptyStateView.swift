import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            // Three circles representing the 3-task concept
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(Color.textSecondary.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
            }

            VStack(spacing: 8) {
                Text("Focus on Three")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.textPrimary)

                Text("Add up to 3 tasks to focus on today")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    EmptyStateView()
        .frame(width: 320, height: 200)
        .background(Color.panelBackground)
}
