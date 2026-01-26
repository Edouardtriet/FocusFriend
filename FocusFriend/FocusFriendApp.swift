import SwiftUI

@main
struct FocusFriendApp: App {
    @AppStorage("currentTask") private var currentTask: String = ""

    var body: some Scene {
        MenuBarExtra {
            ContentView()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: currentTask.isEmpty ? "circle" : "circle.fill")
                Text(currentTask.isEmpty ? "Focus Friend" : currentTask)
            }
        }
        .menuBarExtraStyle(.window)
    }
}
