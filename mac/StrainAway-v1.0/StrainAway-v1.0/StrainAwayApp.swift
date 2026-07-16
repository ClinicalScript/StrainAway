import SwiftUI
import Combine
import UserNotifications
import ServiceManagement

@main
struct EyeBreakApp: App {
    @StateObject private var timerManager = BreakTimerManager()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(timerManager)
        } label: {
            Image("MenuBarIcon")
        }
        .menuBarExtraStyle(.menu)
    }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

class BreakTimerManager: ObservableObject {
    @Published var isRunning = false
    @Published var launchAtLoginEnabled: Bool = SMAppService.mainApp.status == .enabled
    private var timer: Timer?
    private let notificationDelegate = NotificationDelegate()
    let interval: TimeInterval = 20 * 60 //20 minutes

    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            print("Notification permission granted: \(granted)")
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
        start()
    }

    func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            self.fireBreakNotification()
        }
        isRunning = true
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    private func fireBreakNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time To Take The Strain Away!"
        content.body = "Look at something 20 metres away for 20 seconds."
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    func toggleLaunchAtLogin() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
            launchAtLoginEnabled = SMAppService.mainApp.status == .enabled
        } catch {
            print("Failed to toggle launch at login: \(error)")
        }
    }
}

struct MenuBarView: View {
    @EnvironmentObject var timerManager: BreakTimerManager

    var body: some View {
        if timerManager.isRunning {
            Button("Stop reminders") { timerManager.stop() }
        } else {
            Button("Start reminders") { timerManager.start() }
        }
        Button(timerManager.launchAtLoginEnabled ? "Disable launch at login" : "Enable launch at login") {
            timerManager.toggleLaunchAtLogin()
        }
        Divider()
        Button("Quit") { NSApplication.shared.terminate(nil) }
    }
}

