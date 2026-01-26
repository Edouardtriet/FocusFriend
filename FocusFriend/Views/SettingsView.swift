import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsManager: SettingsManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Timer section
                settingsSection(title: "Timer") {
                    // Default duration
                    settingsRow(label: "Default Duration") {
                        Picker("", selection: $settingsManager.settings.defaultDuration) {
                            ForEach(AppSettings.availableDurations, id: \.value) { duration in
                                Text(duration.label).tag(duration.value)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.textSecondary)
                        .frame(width: 120)
                    }

                    // Alarm sound
                    settingsRow(label: "Alarm Sound") {
                        Picker("", selection: $settingsManager.settings.alarmSound) {
                            ForEach(AppSettings.availableSounds, id: \.self) { sound in
                                Text(sound).tag(sound)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.textSecondary)
                        .frame(width: 120)
                    }
                }

                // Appearance section
                settingsSection(title: "Appearance") {
                    settingsRow(label: "Show Floating Timer") {
                        Toggle("", isOn: $settingsManager.settings.showFloatingTimer)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }
                }

                // System section
                settingsSection(title: "System") {
                    settingsRow(label: "Launch at Login") {
                        Toggle("", isOn: Binding(
                            get: { settingsManager.launchAtLogin },
                            set: { settingsManager.launchAtLogin = $0 }
                        ))
                        .toggleStyle(.switch)
                        .labelsHidden()
                    }
                }

                // About section
                settingsSection(title: "About") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("FocusFriend")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.textPrimary)

                        Text("Version 1.0")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.textSecondary)

                        Text("Focus on what matters. Three tasks at a time.")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.textSecondary)
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding(16)
        }
    }

    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.textSecondary)
                .textCase(.uppercase)

            VStack(spacing: 0) {
                content()
            }
            .background(Color.surface)
            .cornerRadius(10)
        }
    }

    private func settingsRow<Content: View>(label: String, @ViewBuilder control: () -> Content) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.textPrimary)

            Spacer()

            control()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
}
