import Foundation
import Combine
import ServiceManagement

class SettingsManager: ObservableObject {
    @Published var settings: AppSettings {
        didSet {
            saveSettings()
        }
    }

    private let settingsKey = "focusfriend.settings"

    init() {
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        } else {
            settings = AppSettings()
        }
    }

    var defaultDuration: TimeInterval {
        get { settings.defaultDuration }
        set { settings.defaultDuration = newValue }
    }

    var alarmSound: String {
        get { settings.alarmSound }
        set { settings.alarmSound = newValue }
    }

    var launchAtLogin: Bool {
        get { settings.launchAtLogin }
        set {
            settings.launchAtLogin = newValue
            updateLaunchAtLogin(newValue)
        }
    }

    var showFloatingTimer: Bool {
        get { settings.showFloatingTimer }
        set { settings.showFloatingTimer = newValue }
    }

    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }

    private func updateLaunchAtLogin(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to update launch at login: \(error)")
            }
        }
    }
}
