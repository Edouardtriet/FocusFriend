import SwiftUI

struct ContentView: View {
    @AppStorage("currentTask") private var currentTask: String = ""
    @State private var taskInput: String = ""
    @State private var isHoveringDone: Bool = false
    @State private var pulseAnimation: Bool = false

    // MARK: - Colors
    private let bgColor = Color(red: 0.11, green: 0.11, blue: 0.12)
    private let surfaceColor = Color(red: 0.17, green: 0.17, blue: 0.18)
    private let accentAmber = Color(red: 0.96, green: 0.65, blue: 0.14)
    private let successGreen = Color(red: 0.49, green: 0.70, blue: 0.26)
    private let textPrimary = Color(red: 0.98, green: 0.98, blue: 0.98)
    private let textSecondary = Color(red: 0.56, green: 0.56, blue: 0.58)

    var body: some View {
        VStack(spacing: 0) {
            // Header area with ambient glow
            ZStack {
                // Ambient glow behind when task is active
                if !currentTask.isEmpty {
                    Circle()
                        .fill(accentAmber.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .blur(radius: 40)
                        .scaleEffect(pulseAnimation ? 1.1 : 0.9)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulseAnimation)
                }

                VStack(spacing: 8) {
                    // Status indicator
                    Circle()
                        .fill(currentTask.isEmpty ? textSecondary.opacity(0.3) : accentAmber)
                        .frame(width: 12, height: 12)
                        .shadow(color: currentTask.isEmpty ? .clear : accentAmber.opacity(0.6), radius: 8)

                    Text(currentTask.isEmpty ? "Ready to focus" : "In the zone")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(textSecondary)
                        .textCase(.uppercase)
                        .tracking(1.5)
                }
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [surfaceColor, bgColor],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            // Main content
            VStack(spacing: 24) {
                if currentTask.isEmpty {
                    // Empty state - Task input
                    VStack(spacing: 20) {
                        Text("What's your focus?")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundColor(textPrimary)

                        // Custom styled text field
                        ZStack(alignment: .leading) {
                            if taskInput.isEmpty {
                                Text("Enter your task...")
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundColor(textSecondary.opacity(0.6))
                            }

                            TextField("", text: $taskInput)
                                .textFieldStyle(.plain)
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(textPrimary)
                                .onSubmit { setTask() }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(surfaceColor)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(taskInput.isEmpty ? textSecondary.opacity(0.2) : accentAmber.opacity(0.5), lineWidth: 1)
                        )

                        // Set task button
                        Button(action: setTask) {
                            Text("Start Focusing")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(taskInput.isEmpty ? textSecondary : bgColor)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(taskInput.isEmpty ? surfaceColor : accentAmber)
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        .disabled(taskInput.isEmpty)
                        .animation(.easeOut(duration: 0.2), value: taskInput.isEmpty)
                    }
                } else {
                    // Active task state
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("CURRENT FOCUS")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundColor(textSecondary)
                                .tracking(2)

                            Text(currentTask)
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(textPrimary)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                        }

                        // Done button
                        Button(action: markDone) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16))
                                Text("Mark Complete")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(isHoveringDone ? bgColor : successGreen)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(isHoveringDone ? successGreen : successGreen.opacity(0.15))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(successGreen.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .onHover { hovering in
                            withAnimation(.easeOut(duration: 0.15)) {
                                isHoveringDone = hovering
                            }
                        }
                    }
                }
            }
            .padding(24)

            Spacer()

            // Footer
            HStack {
                Spacer()
                Button(action: { NSApplication.shared.terminate(nil) }) {
                    Text("Quit")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(textSecondary.opacity(0.6))
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    // Could add hover effect
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .frame(width: 320, height: 340)
        .background(bgColor)
        .onAppear {
            pulseAnimation = true
        }
    }

    private func setTask() {
        guard !taskInput.isEmpty else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentTask = taskInput
            taskInput = ""
        }
    }

    private func markDone() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentTask = ""
        }
    }
}

#Preview {
    ContentView()
}
