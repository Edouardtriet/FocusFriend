import SwiftUI

struct ProgressBarView: View {
    let progress: Double
    var height: CGFloat = 3
    var backgroundColor: Color = Color.surface
    var foregroundColor: Color = Color.accent

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(backgroundColor)
                    .frame(height: height)

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(foregroundColor)
                    .frame(width: max(0, geometry.size.width * CGFloat(progress)), height: height)
                    .animation(.easeInOut(duration: 0.2), value: progress)
            }
        }
        .frame(height: height)
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressBarView(progress: 0.0)
        ProgressBarView(progress: 0.25)
        ProgressBarView(progress: 0.5)
        ProgressBarView(progress: 0.75)
        ProgressBarView(progress: 1.0)
    }
    .padding()
    .background(Color.panelBackground)
}
