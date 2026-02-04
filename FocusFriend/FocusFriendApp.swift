import SwiftUI
import Combine

@main
struct FocusFriendApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let taskManager = TaskManager()
    private let timerManager = TimerManager()
    private let settingsManager = SettingsManager()
    private let floatingWindowController = FloatingWindowController()
    private var menuBarController: MenuBarController?
    private var cancellables: Set<AnyCancellable> = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        menuBarController = MenuBarController(
            taskManager: taskManager,
            timerManager: timerManager,
            settingsManager: settingsManager
        )

        setupTimerCompletion()
        observeTimerState()
        updateFloatingWindow(isRunning: timerManager.isRunning)
    }

    private func observeTimerState() {
        timerManager.$isRunning
            .receive(on: RunLoop.main)
            .sink { [weak self] isRunning in
                self?.updateFloatingWindow(isRunning: isRunning)
            }
            .store(in: &cancellables)

        settingsManager.$settings
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.updateFloatingWindow(isRunning: self.timerManager.isRunning)
            }
            .store(in: &cancellables)
    }

    private func setupTimerCompletion() {
        timerManager.onTimerComplete = { [weak self] taskId in
            guard let self = self else { return }
            SoundManager.shared.playCompletionSound(soundName: self.settingsManager.alarmSound)

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
