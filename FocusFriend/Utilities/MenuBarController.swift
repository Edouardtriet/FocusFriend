import SwiftUI
import AppKit
import Combine

@MainActor
final class MenuBarController: NSObject, NSPopoverDelegate {
    private let statusItem: NSStatusItem
    private let popover: NSPopover
    private let taskManager: TaskManager
    private let timerManager: TimerManager
    private let settingsManager: SettingsManager
    private var cancellables: Set<AnyCancellable> = []

    init(taskManager: TaskManager, timerManager: TimerManager, settingsManager: SettingsManager) {
        self.taskManager = taskManager
        self.timerManager = timerManager
        self.settingsManager = settingsManager
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.popover = NSPopover()
        super.init()
        configureStatusItem()
        configurePopover()
        observeState()
        updateStatusItem()
    }

    private func configureStatusItem() {
        guard let button = statusItem.button else { return }
        button.target = self
        button.action = #selector(togglePopover(_:))
        button.imagePosition = .imageLeading
    }

    private func configurePopover() {
        let content = MainPanelView(
            taskManager: taskManager,
            timerManager: timerManager,
            settingsManager: settingsManager
        )
        let controller = NSHostingController(rootView: content)
        controller.preferredContentSize = NSSize(width: AppConstants.panelWidth, height: AppConstants.panelHeight)
        popover.contentViewController = controller
        popover.contentSize = controller.preferredContentSize
        popover.behavior = .transient
        popover.animates = true
        popover.delegate = self
    }

    private func observeState() {
        timerManager.$isRunning
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateStatusItem() }
            .store(in: &cancellables)

        timerManager.$elapsedTime
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateStatusItem() }
            .store(in: &cancellables)

        timerManager.$activeTaskId
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateStatusItem() }
            .store(in: &cancellables)

        taskManager.$tasks
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateStatusItem() }
            .store(in: &cancellables)
    }

    @objc private func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover()
        }
    }

    private func showPopover() {
        guard let button = statusItem.button else { return }
        popover.contentSize = NSSize(width: AppConstants.panelWidth, height: AppConstants.panelHeight)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        button.state = .on
    }

    private func closePopover(_ sender: Any?) {
        popover.performClose(sender)
    }

    func popoverWillClose(_ notification: Notification) {
        statusItem.button?.state = .off
    }

    private func updateStatusItem() {
        guard let button = statusItem.button else { return }
        let display = currentDisplay()
        button.image = NSImage(systemSymbolName: display.symbolName, accessibilityDescription: "FocusFriend")
        button.image?.isTemplate = true
        button.title = display.title
        button.imagePosition = display.title.isEmpty ? .imageOnly : .imageLeading
    }

    private func currentDisplay() -> (symbolName: String, title: String) {
        if timerManager.isRunning,
           let activeId = timerManager.activeTaskId,
           let task = taskManager.tasks.first(where: { $0.id == activeId }) {
            let title = "\(timerManager.formattedRemainingTime) — \(truncateName(task.name))"
            return ("timer", title)
        }

        if let firstTask = taskManager.tasks.first {
            return ("3.circle.fill", truncateName(firstTask.name))
        }

        return ("3.circle.fill", "")
    }

    private func truncateName(_ name: String, maxLength: Int = 30) -> String {
        guard name.count > maxLength else { return name }
        return String(name.prefix(maxLength)) + "..."
    }
}
