import SwiftUI

extension Color {
    static let panelBackground = Color(red: 0.11, green: 0.11, blue: 0.12)
    static let surface = Color(red: 0.17, green: 0.17, blue: 0.18)
    static let surfaceHover = Color(red: 0.22, green: 0.22, blue: 0.23)
    static let accent = Color(red: 0.0, green: 0.83, blue: 0.67)  // Cyan/teal
    static let timerActive = Color(red: 0.96, green: 0.65, blue: 0.14)  // Amber
    static let completed = Color(red: 0.49, green: 0.70, blue: 0.26)  // Green
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.56, green: 0.56, blue: 0.58)
    static let danger = Color(red: 0.90, green: 0.30, blue: 0.30)
}

enum AppConstants {
    static let panelWidth: CGFloat = 320
    static let panelHeight: CGFloat = 400
    static let cornerRadius: CGFloat = 12
    static let spacing: CGFloat = 12
    static let padding: CGFloat = 16
}
