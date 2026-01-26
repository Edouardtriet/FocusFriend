import SwiftUI

struct TaskListView: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var timerManager: TimerManager
    @ObservedObject var settingsManager: SettingsManager

    @State private var newTaskName: String = ""
    @State private var isAddingTask: Bool = false
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 8) {
            if taskManager.tasks.isEmpty && !isAddingTask {
                EmptyStateView()
                    .onTapGesture { cancelAdd() }
            } else {
                // Task list
                ForEach(taskManager.tasks) { task in
                    TaskRowView(
                        taskManager: taskManager,
                        timerManager: timerManager,
                        settingsManager: settingsManager,
                        task: task
                    )
                }
            }

            // Add task input or button (always visible when can add)
            if isAddingTask {
                addTaskInput
            } else if taskManager.canAddTask {
                addTaskButton
            }

            // Tappable spacer to cancel adding
            if isAddingTask {
                Spacer()
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .contentShape(Rectangle())
                    .onTapGesture { cancelAdd() }
            }
        }
        .padding(.horizontal, 8)
    }

    private var addTaskButton: some View {
        Button(action: {
            withAnimation(.easeOut(duration: 0.2)) {
                isAddingTask = true
                isInputFocused = true
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 14))
                Text("Add a task...")
                    .font(.system(size: 14, design: .rounded))
            }
            .foregroundColor(.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
        .background(Color.surface.opacity(0.3))
        .cornerRadius(8)
    }

    private var addTaskInput: some View {
        ZStack(alignment: .leading) {
            if newTaskName.isEmpty {
                Text("What do you need to focus on?")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.textSecondary)
            }
            TextField("", text: $newTaskName)
                .textFieldStyle(.plain)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.textPrimary)
                .focused($isInputFocused)
                .onSubmit { addTask() }
                .onExitCommand { cancelAdd() }
                .onChange(of: isInputFocused) { focused in
                    if !focused {
                        cancelAdd()
                    }
                }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.surface)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.accent.opacity(0.5), lineWidth: 1)
        )
    }

    private func addTask() {
        guard !newTaskName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        taskManager.addTask(name: newTaskName, duration: settingsManager.defaultDuration)
        newTaskName = ""
        isAddingTask = false
    }

    private func cancelAdd() {
        newTaskName = ""
        isAddingTask = false
    }
}
