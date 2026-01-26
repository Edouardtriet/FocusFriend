import Foundation
import Combine

class TimerManager: ObservableObject {
    @Published var activeTaskId: UUID?
    @Published var elapsedTime: TimeInterval = 0
    @Published var isRunning: Bool = false

    var onTimerComplete: ((UUID) -> Void)?

    private var timer: AnyCancellable?
    private var taskDuration: TimeInterval = 0
    private var startTime: Date?
    private var accumulatedTime: TimeInterval = 0

    var remainingTime: TimeInterval {
        max(0, taskDuration - elapsedTime)
    }

    var progress: Double {
        guard taskDuration > 0 else { return 0 }
        return min(1.0, elapsedTime / taskDuration)
    }

    var formattedRemainingTime: String {
        formatTime(remainingTime)
    }

    var formattedElapsedTime: String {
        formatTime(elapsedTime)
    }

    // MARK: - Timer Controls

    func start(taskId: UUID, duration: TimeInterval, currentElapsed: TimeInterval = 0) {
        activeTaskId = taskId
        taskDuration = duration
        accumulatedTime = currentElapsed
        elapsedTime = currentElapsed
        startTime = Date()
        isRunning = true

        timer?.cancel()
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func pause() {
        guard isRunning else { return }
        isRunning = false
        accumulatedTime = elapsedTime
        timer?.cancel()
        timer = nil
    }

    func resume() {
        guard !isRunning, activeTaskId != nil else { return }
        startTime = Date()
        isRunning = true

        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func stop() {
        timer?.cancel()
        timer = nil
        isRunning = false
        activeTaskId = nil
        elapsedTime = 0
        accumulatedTime = 0
        taskDuration = 0
        startTime = nil
    }

    func restart(duration: TimeInterval) {
        guard let taskId = activeTaskId else { return }
        accumulatedTime = 0
        elapsedTime = 0
        taskDuration = duration
        startTime = Date()

        if !isRunning {
            isRunning = true
            timer = Timer.publish(every: 0.1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    self?.tick()
                }
        }
    }

    // MARK: - Private

    private func tick() {
        guard let startTime = startTime else { return }
        let now = Date()
        elapsedTime = accumulatedTime + now.timeIntervalSince(startTime)

        if elapsedTime >= taskDuration {
            elapsedTime = taskDuration
            if let taskId = activeTaskId {
                onTimerComplete?(taskId)
            }
            stop()
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
