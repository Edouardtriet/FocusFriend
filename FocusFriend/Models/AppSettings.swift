import Foundation

struct AppSettings: Codable, Equatable {
    var defaultDuration: TimeInterval = 600  // 10 minutes
    var alarmSound: String = "Glass"
    var launchAtLogin: Bool = false
    var showFloatingTimer: Bool = true

    static let availableDurations: [(label: String, value: TimeInterval)] = [
        ("5 minutes", 300),
        ("10 minutes", 600),
        ("15 minutes", 900),
        ("20 minutes", 1200),
        ("25 minutes", 1500),
        ("30 minutes", 1800)
    ]

    static let availableSounds: [String] = [
        "Glass",
        "Basso",
        "Blow",
        "Bottle",
        "Frog",
        "Funk",
        "Hero",
        "Morse",
        "Ping",
        "Pop",
        "Purr",
        "Sosumi",
        "Submarine",
        "Tink"
    ]
}
