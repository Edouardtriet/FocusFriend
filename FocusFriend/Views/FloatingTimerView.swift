import SwiftUI

struct FloatingTimerView: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var timerManager: TimerManager

    @State private var isHovering = false

    private var activeTask: FocusTask? {
        guard let id = timerManager.activeTaskId else { return nil }
        return taskManager.tasks.first { $0.id == id }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Timer display
            Text(timerManager.formattedRemainingTime)
                .font(.system(size: 24, weight: .medium, design: .monospaced))
                .foregroundColor(timerManager.isRunning ? .timerActive : .textPrimary)

            // Task name
            if let task = activeTask {
                Text(task.name)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: 350)
            }

            // Controls (visible on hover)
            if isHovering {
                HStack(spacing: 8) {
                    // Pause/Resume
                    Button(action: toggleTimer) {
                        Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.textPrimary)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 24, height: 24)
                    .background(Color.surface)
                    .cornerRadius(4)

                    // Stop
                    Button(action: stopTimer) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.textPrimary)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 24, height: 24)
                    .background(Color.surface)
                    .cornerRadius(4)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.panelBackground)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        )
        .overlay(
            Capsule()
                .stroke(Color.surface, lineWidth: 1)
        )
        .frame(minWidth: 120)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }

    private func toggleTimer() {
        if timerManager.isRunning {
            timerManager.pause()
            if let taskId = timerManager.activeTaskId {
                taskManager.updateElapsedTime(for: taskId, elapsed: timerManager.elapsedTime)
            }
        } else {
            timerManager.resume()
        }
    }

    private func stopTimer() {
        if let taskId = timerManager.activeTaskId {
            taskManager.updateElapsedTime(for: taskId, elapsed: timerManager.elapsedTime)
        }
        timerManager.stop()
    }
}
