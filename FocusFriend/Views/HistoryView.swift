import SwiftUI

struct HistoryView: View {
    @ObservedObject var taskManager: TaskManager

    private var groupedTasks: [(date: Date, tasks: [FocusTask])] {
        taskManager.completedTasksGroupedByDate()
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                if groupedTasks.isEmpty {
                    emptyState
                } else {
                    ForEach(groupedTasks, id: \.date) { group in
                        Section {
                            ForEach(group.tasks) { task in
                                HistoryItemView(task: task)
                            }
                        } header: {
                            Text(formatDateHeader(group.date))
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(.textSecondary)
                                .textCase(.uppercase)
                                .padding(.top, 8)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 32))
                .foregroundColor(.textSecondary.opacity(0.5))

            Text("No completed tasks yet")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }

    private func formatDateHeader(_ date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: date)
        }
    }
}

struct HistoryItemView: View {
    let task: FocusTask

    var body: some View {
        HStack(spacing: 12) {
            // Checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(.completed)

            // Task info
            VStack(alignment: .leading, spacing: 2) {
                Text(task.name)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)

                Text(formatDuration(task.elapsedTime) + " spent")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.textSecondary)
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.surface.opacity(0.5))
        .cornerRadius(8)
    }

    private func formatDuration(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        if minutes < 1 {
            return "<1m"
        }
        return "\(minutes)m"
    }
}
