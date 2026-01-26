import Foundation

struct FocusTask: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var duration: TimeInterval      // Default 600 (10 min)
    var elapsedTime: TimeInterval   // Time spent so far
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date

    var remainingTime: TimeInterval {
        max(0, duration - elapsedTime)
    }

    var progress: Double {
        guard duration > 0 else { return 0 }
        return min(1.0, elapsedTime / duration)
    }

    var formattedElapsedTime: String {
        formatTime(elapsedTime)
    }

    var formattedDuration: String {
        formatTime(duration)
    }

    var formattedRemainingTime: String {
        formatTime(remainingTime)
    }

    init(name: String, duration: TimeInterval = 600) {
        self.id = UUID()
        self.name = name
        self.duration = duration
        self.elapsedTime = 0
        self.isCompleted = false
        self.completedAt = nil
        self.createdAt = Date()
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    mutating func markCompleted() {
        isCompleted = true
        completedAt = Date()
    }

    mutating func reset() {
        elapsedTime = 0
        isCompleted = false
        completedAt = nil
    }
}
