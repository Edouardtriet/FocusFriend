import SwiftUI

struct TaskRowView: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var timerManager: TimerManager
    @ObservedObject var settingsManager: SettingsManager
    let task: FocusTask

    @State private var isHovering = false
    @State private var isEditing = false
    @State private var editedName: String = ""
    @State private var showDeleteConfirmation = false

    private var isActive: Bool {
        timerManager.activeTaskId == task.id
    }

    private var isTimerRunning: Bool {
        isActive && timerManager.isRunning
    }

    private var currentElapsed: TimeInterval {
        isActive ? timerManager.elapsedTime : task.elapsedTime
    }

    private var currentProgress: Double {
        guard task.duration > 0 else { return 0 }
        return min(1.0, currentElapsed / task.duration)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Active indicator bar
                if isActive {
                    Rectangle()
                        .fill(Color.accent)
                        .frame(width: 3)
                        .cornerRadius(1.5)
                }

                // Checkbox
                CircularCheckbox(isCompleted: task.isCompleted) {
                    completeTask()
                }
                .accessibilityLabel(task.isCompleted ? "Mark incomplete" : "Mark complete")

                // Task content
                VStack(alignment: .leading, spacing: 6) {
                    // Task name
                    if isEditing {
                        TextField("Task name", text: $editedName)
                            .textFieldStyle(.plain)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.textPrimary)
                            .onSubmit { saveEdit() }
                            .onAppear { editedName = task.name }
                    } else {
                        Text(task.name)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.textPrimary)
                            .lineLimit(2)
                    }

                    // Progress bar
                    ProgressBarView(
                        progress: currentProgress,
                        foregroundColor: isActive ? Color.timerActive : Color.accent
                    )

                    // Time display
                    HStack {
                        Text(formatTime(currentElapsed))
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(isActive ? Color.timerActive : Color.textSecondary)

                        Spacer()

                        Text(formatTime(task.duration))
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.textSecondary)
                    }
                }

                Spacer()

                // Timer controls
                if isHovering || isActive {
                    HStack(spacing: 4) {
                        if isActive {
                            // Pause/Resume button
                            Button(action: toggleTimer) {
                                Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.textPrimary)
                                    .frame(width: 28, height: 28)
                                    .background(Color.surface)
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(isTimerRunning ? "Pause timer" : "Resume timer")

                            // Stop button
                            Button(action: stopTimer) {
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.textPrimary)
                                    .frame(width: 28, height: 28)
                                    .background(Color.surface)
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Stop timer")
                        } else {
                            // Play button
                            Button(action: startTimer) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.textPrimary)
                                    .frame(width: 28, height: 28)
                                    .background(Color.surface)
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Start timer for \(task.name)")
                        }
                    }
                }

                // Context menu button
                Menu {
                    contextMenuContent
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(isHovering ? Color.surface : Color.clear)
                        .cornerRadius(6)
                }
                .menuStyle(.borderlessButton)
                .tint(.textSecondary)
                .frame(width: 28)
                .accessibilityLabel("Task options")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .background(isHovering ? Color.surface.opacity(0.5) : Color.clear)
        .cornerRadius(8)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
        .confirmationDialog("Delete Task?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if isActive {
                    timerManager.stop()
                }
                taskManager.deleteTask(task)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \"\(task.name)\"?")
        }
    }

    @ViewBuilder
    private var contextMenuContent: some View {
        Button("Rename") {
            isEditing = true
            editedName = task.name
        }

        Divider()

        if let index = taskManager.tasks.firstIndex(where: { $0.id == task.id }) {
            if index > 0 {
                Button("Move Up") {
                    taskManager.moveTaskUp(task)
                }
            }
            if index < taskManager.tasks.count - 1 {
                Button("Move Down") {
                    taskManager.moveTaskDown(task)
                }
            }
        }

        Divider()

        if isActive {
            Button("Restart Timer") {
                timerManager.restart(duration: task.duration)
            }
        }

        Button("Reset Timer") {
            taskManager.resetTimer(for: task)
            if isActive {
                timerManager.stop()
            }
        }

        Divider()

        Menu("Set Duration") {
            ForEach(AppSettings.availableDurations, id: \.value) { duration in
                Button(duration.label) {
                    taskManager.setDuration(for: task, duration: duration.value)
                }
            }
        }

        Divider()

        Button("Delete Task", role: .destructive) {
            showDeleteConfirmation = true
        }
    }

    // MARK: - Actions

    private func startTimer() {
        timerManager.start(taskId: task.id, duration: task.duration, currentElapsed: task.elapsedTime)
    }

    private func toggleTimer() {
        if timerManager.isRunning {
            timerManager.pause()
            taskManager.updateElapsedTime(for: task.id, elapsed: timerManager.elapsedTime)
        } else {
            timerManager.resume()
        }
    }

    private func stopTimer() {
        taskManager.updateElapsedTime(for: task.id, elapsed: timerManager.elapsedTime)
        timerManager.stop()
    }

    private func completeTask() {
        if isActive {
            taskManager.updateElapsedTime(for: task.id, elapsed: timerManager.elapsedTime)
            timerManager.stop()
        }
        taskManager.completeTask(task)
    }

    private func saveEdit() {
        let trimmed = editedName.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            var updated = task
            updated.name = trimmed
            taskManager.updateTask(updated)
        }
        isEditing = false
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
