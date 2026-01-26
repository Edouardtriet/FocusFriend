import Foundation
import Combine

class TaskManager: ObservableObject {
    static let maxTasks = 3

    @Published var tasks: [FocusTask] = []
    @Published var completedTasks: [FocusTask] = []

    private let tasksKey = "focusfriend.tasks"
    private let completedTasksKey = "focusfriend.completedTasks"

    var canAddTask: Bool {
        tasks.count < Self.maxTasks
    }

    var activeTask: FocusTask? {
        tasks.first { !$0.isCompleted }
    }

    init() {
        loadTasks()
    }

    // MARK: - CRUD Operations

    func addTask(name: String, duration: TimeInterval) {
        guard canAddTask, !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let task = FocusTask(name: name.trimmingCharacters(in: .whitespaces), duration: duration)
        tasks.append(task)
        saveTasks()
    }

    func updateTask(_ task: FocusTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }

    func deleteTask(_ task: FocusTask) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }

    func deleteTask(at index: Int) {
        guard tasks.indices.contains(index) else { return }
        tasks.remove(at: index)
        saveTasks()
    }

    func completeTask(_ task: FocusTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            var completed = tasks[index]
            completed.markCompleted()
            tasks.remove(at: index)
            completedTasks.insert(completed, at: 0)
            saveTasks()
        }
    }

    func updateElapsedTime(for taskId: UUID, elapsed: TimeInterval) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].elapsedTime = elapsed
            saveTasks()
        }
    }

    // MARK: - Reordering

    func moveTaskUp(_ task: FocusTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }),
              index > 0 else { return }
        tasks.swapAt(index, index - 1)
        saveTasks()
    }

    func moveTaskDown(_ task: FocusTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }),
              index < tasks.count - 1 else { return }
        tasks.swapAt(index, index + 1)
        saveTasks()
    }

    // MARK: - Duration

    func setDuration(for task: FocusTask, duration: TimeInterval) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].duration = duration
            saveTasks()
        }
    }

    func resetTimer(for task: FocusTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].reset()
            saveTasks()
        }
    }

    // MARK: - History

    func completedTasksGroupedByDate() -> [(date: Date, tasks: [FocusTask])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: completedTasks) { task -> Date in
            calendar.startOfDay(for: task.completedAt ?? task.createdAt)
        }
        return grouped.sorted { $0.key > $1.key }.map { ($0.key, $0.value) }
    }

    func clearHistory() {
        completedTasks.removeAll()
        saveTasks()
    }

    // MARK: - Persistence

    private func saveTasks() {
        do {
            let tasksData = try JSONEncoder().encode(tasks)
            UserDefaults.standard.set(tasksData, forKey: tasksKey)
        } catch {
            print("[TaskManager] Failed to save tasks: \(error)")
        }

        do {
            let completedData = try JSONEncoder().encode(completedTasks)
            UserDefaults.standard.set(completedData, forKey: completedTasksKey)
        } catch {
            print("[TaskManager] Failed to save completed tasks: \(error)")
        }
    }

    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey) {
            do {
                tasks = try JSONDecoder().decode([FocusTask].self, from: data)
            } catch {
                print("[TaskManager] Failed to load tasks: \(error)")
            }
        }
        if let data = UserDefaults.standard.data(forKey: completedTasksKey) {
            do {
                completedTasks = try JSONDecoder().decode([FocusTask].self, from: data)
            } catch {
                print("[TaskManager] Failed to load completed tasks: \(error)")
            }
        }
    }
}
