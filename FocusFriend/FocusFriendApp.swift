import SwiftUI

@main
struct FocusFriendApp: App {
    @StateObject private var taskManager = TaskManager()
    @StateObject private var timerManager = TimerManager()
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var floatingWindowController = FloatingWindowController()

    init() {
        // Timer completion handler will be set up in body
    }

    var body: some Scene {
        MenuBarExtra {
            MainPanelView(
                taskManager: taskManager,
                timerManager: timerManager,
                settingsManager: settingsManager
            )
            .onAppear {
                setupTimerCompletion()
            }
            .onChange(of: timerManager.isRunning) { isRunning in
                updateFloatingWindow(isRunning: isRunning)
            }
        } label: {
            menuBarLabel
        }
        .menuBarExtraStyle(.window)
    }

    @ViewBuilder
    private var menuBarLabel: some View {
        if timerManager.isRunning, let task = taskManager.tasks.first(where: { $0.id == timerManager.activeTaskId }) {
            HStack(spacing: 4) {
                Image(systemName: "timer")
                Text("\(timerManager.formattedRemainingTime) — \(truncateName(task.name))")
            }
        } else {
            Image(systemName: "3.circle.fill")
        }
    }

    private func truncateName(_ name: String, maxLength: Int = 15) -> String {
        if name.count <= maxLength {
            return name
        }
        return String(name.prefix(maxLength)) + "..."
    }

    private func setupTimerCompletion() {
        timerManager.onTimerComplete = { taskId in
            // Play completion sound (always play, don't silently fail)
            SoundManager.shared.playCompletionSound(soundName: self.settingsManager.alarmSound)

            // Mark task as complete
            if let task = self.taskManager.tasks.first(where: { $0.id == taskId }) {
                self.taskManager.completeTask(task)
            }
        }
    }

    private func updateFloatingWindow(isRunning: Bool) {
        guard settingsManager.showFloatingTimer else {
            floatingWindowController.hide()
            return
        }

        if isRunning {
            let content = FloatingTimerView(
                taskManager: taskManager,
                timerManager: timerManager
            )
            floatingWindowController.show(content: content)
        } else {
            floatingWindowController.hide()
        }
    }
}
