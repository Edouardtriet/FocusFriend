import SwiftUI

enum PanelTab {
    case tasks
    case history
    case settings
}

struct MainPanelView: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var timerManager: TimerManager
    @ObservedObject var settingsManager: SettingsManager

    @State private var currentTab: PanelTab = .tasks

    private var totalTimeToday: TimeInterval {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Sum elapsed time from active tasks
        let activeTasks = taskManager.tasks.reduce(0) { sum, task in
            if timerManager.activeTaskId == task.id {
                return sum + timerManager.elapsedTime
            }
            return sum + task.elapsedTime
        }

        // Sum time from completed tasks today
        let completedToday = taskManager.completedTasks
            .filter { task in
                if let completedAt = task.completedAt {
                    return calendar.isDate(completedAt, inSameDayAs: today)
                }
                return false
            }
            .reduce(0) { sum, task in sum + task.elapsedTime }

        return activeTasks + completedToday
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Content
            contentView

            // Footer
            footerView
        }
        .frame(width: AppConstants.panelWidth, height: AppConstants.panelHeight)
        .background(Color.panelBackground)
    }

    private var headerView: some View {
        HStack {
            if currentTab == .tasks {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.textPrimary)

                    Text(formatTotalTime(totalTimeToday) + " focused")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.textSecondary)
                }
            } else {
                Button(action: { currentTab = .tasks }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .medium))
                        Text(currentTab == .history ? "History" : "Settings")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.textPrimary)
                }
                .buttonStyle(.plain)
            }

            Spacer()

            if currentTab == .tasks {
                HStack(spacing: 12) {
                    Button(action: { currentTab = .history }) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 16))
                            .foregroundColor(.textSecondary)
                    }
                    .buttonStyle(.plain)

                    Button(action: { currentTab = .settings }) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 16))
                            .foregroundColor(.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.surface)
    }

    @ViewBuilder
    private var contentView: some View {
        switch currentTab {
        case .tasks:
            ScrollView {
                TaskListView(
                    taskManager: taskManager,
                    timerManager: timerManager,
                    settingsManager: settingsManager
                )
                .padding(.vertical, 8)
            }
        case .history:
            HistoryView(taskManager: taskManager)
        case .settings:
            SettingsView(settingsManager: settingsManager)
        }
    }

    private var footerView: some View {
        HStack {
            // Active timer indicator
            if timerManager.isRunning, let task = taskManager.tasks.first(where: { $0.id == timerManager.activeTaskId }) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.timerActive)
                        .frame(width: 8, height: 8)

                    Text(timerManager.formattedRemainingTime)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.timerActive)

                    Text(task.name)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }

            Spacer()

            Button(action: { NSApplication.shared.terminate(nil) }) {
                Text("Quit")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.textSecondary.opacity(0.6))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.surface.opacity(0.5))
    }

    private func formatTotalTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
