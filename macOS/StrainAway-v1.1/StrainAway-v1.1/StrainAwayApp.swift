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

        Window("Customise Notification Settings", id: "settings-window") {
            SettingsView()
                .environmentObject(timerManager)
        }
        .windowResizability(.contentSize)

        Window("About StrainAway", id: "about-window") {
            AboutView()
        }
        .windowResizability(.contentSize)
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

    @Published var intervalMinutes: Double = 20.0 {
        didSet {
            if isRunning {
                start()
            }
        }
    }
    @Published var breakDurationSeconds: Double = 20.0
    
    // Generates values: [20, 25, 30, 35, 40, 45, 50, 55, 60]
    static let durationOptions: [Int] = Array(stride(from: 20, through: 60, by: 5))
    
    private var mainTimer: Timer?
    private let notificationDelegate = NotificationDelegate()

    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        start()
    }

    func start() {
        stop()
        isRunning = true
        
        mainTimer = Timer.scheduledTimer(withTimeInterval: intervalMinutes * 60, repeats: true) { [weak self] _ in
            self?.fireEyeBreakNotification()
        }
    }

    func stop() {
        mainTimer?.invalidate()
        mainTimer = nil
        isRunning = false
    }

    private func fireEyeBreakNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time To Take The Strain Away!"
        let formattedDuration = formatNotificationDuration(Int(breakDurationSeconds))
        content.body = "Look at something 20 feet (6 metres) away for \(formattedDuration)."
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    private func formatNotificationDuration(_ seconds: Int) -> String {
        if seconds < 60 {
            return "\(seconds) seconds"
        } else {
            let mins = seconds / 60
            return "\(mins) minute\(mins > 1 ? "s" : "")"
        }
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
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        if timerManager.isRunning {
            Button("Stop Notifications") { timerManager.stop() }
        } else {
            Button("Start Notifications") { timerManager.start() }
        }
        
        Divider()
        
        Button("Customise Notification Settings") {
            bringAppToFront()
            openWindow(id: "settings-window")
        }
        
        Divider()
        
        Button(timerManager.launchAtLoginEnabled ? "Disable launch at login" : "Enable launch at login") {
            timerManager.toggleLaunchAtLogin()
        }
        
        Divider()
        
        Button("About StrainAway") {
            bringAppToFront()
            openWindow(id: "about-window")
        }
        
        Divider()
        
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
    }
    
    private func bringAppToFront() {
        NSApp.activate(ignoringOtherApps: true)
    }
}

struct SettingsView: View {
    @EnvironmentObject var timerManager: BreakTimerManager
    
    private var durationIndexBinding: Binding<Double> {
        Binding(
            get: {
                let seconds = Int(timerManager.breakDurationSeconds)
                if let index = BreakTimerManager.durationOptions.firstIndex(of: seconds) {
                    return Double(index)
                }
                let closest = BreakTimerManager.durationOptions.enumerated().min(by: {
                    abs($0.element - seconds) < abs($1.element - seconds)
                })
                return Double(closest?.offset ?? 0)
            },
            set: { newValue in
                let maxIndex = Double(BreakTimerManager.durationOptions.count - 1)
                let clampedIndex = Int(max(0, min(newValue, maxIndex)))
                timerManager.breakDurationSeconds = Double(BreakTimerManager.durationOptions[clampedIndex])
            }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Customise Notification Settings")
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("Tailor the notification frequency and eye break duration to help alleviate Digital Eye Strain (DES) symptoms. Research suggests self-paced breaks away from screen should be as frequent as every 10 minutes - see *About StrainAway* via the app menu for more information.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Eye Break Protocol")
                    .font(.headline)
                    .bold()
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("**Notification Frequency** - *how often would you like to receive notifications to take the strain away?*")
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack {
                        Slider(value: $timerManager.intervalMinutes, in: 1...35, step: 1)
                        
                        Text("\(Int(timerManager.intervalMinutes)) mins")
                           .font(.title3)
                           .fontWeight(.semibold)
                           .frame(width: 90, alignment: .trailing)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("**Break Duration** - *this shows on the notification banner, how long would you like to spend looking away from the screen to focus on blinking?*")
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack {
                        Slider(
                            value: durationIndexBinding,
                            in: 0...Double(BreakTimerManager.durationOptions.count - 1),
                            step: 1
                        )
                        Text(formatDurationDisplay(Int(timerManager.breakDurationSeconds)))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(width: 90, alignment: .trailing)
                    }
                }
            }
            
            Divider()
            
            HStack {
                Spacer()
                Button(action: {
                    timerManager.intervalMinutes = 20.0
                    timerManager.breakDurationSeconds = 20.0
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset to 20-20-20 Rule Presets")
                    }
                    .padding(.horizontal, 4)
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
            }
        }
        .padding(24)
        .frame(minWidth: 450, idealWidth: 500, maxWidth: 900)
    }
    
    private func formatDurationDisplay(_ seconds: Int) -> String {
        if seconds < 60 {
            return "\(seconds) secs"
        } else {
            let mins = seconds / 60
            return "\(mins) min\(mins > 1 ? "s" : "")"
        }
    }
}

struct AboutView: View {
    private var appIcon: NSImage {
        NSImage(named: NSImage.applicationIconName)
        ?? NSWorkspace.shared.icon(forFile: Bundle.main.bundlePath)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Image(nsImage: appIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .padding(.top, 24)
            
            VStack(spacing: 4) {
                Text("StrainAway")
                    .font(.title2)
                    .bold()
                Text("Version 1.1")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Link(destination: URL(string: "https://github.com/ClinicalScript")!) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.plaintext")
                        Text("Created by ClinicalScript")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.accentColor)
                    .padding(.top, 2)
                }
                
                Divider()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("StrainAway is an open-source eye break reminder app, available for macOS and Windows. By default it follows the 20-20-20 rule: every 20 minutes, StrainAway reminds you to look at something 20 feet (6 metres) away for 20 seconds.")
                        Text("I acknowledge there is research suggesting the 20-20-20 rule is not always going to be an optimal solution, so I have implemented a feature to customise notification and break duration intervals to explore what works best for your individual needs within reasonable parameters.")
                    }
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                }
                .frame(height: 170)
                
                Divider()
                
                VStack(spacing: 4) {
                    HStack(spacing: 12) {
                        Link(destination: URL(string: "https://github.com/ClinicalScript/StrainAway")!) {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.plaintext")
                                Text("GitHub Repository")
                            }
                            .font(.caption)
                        }
                        
                        Text("•")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        Link(destination: URL(string: "https://github.com/ClinicalScript/StrainAway/blob/main/LICENSE")!) {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.plaintext")
                                Text("Open-Source Licence")
                            }
                            .font(.caption)
                        }
                    }
                    .padding(.bottom, 4)
                    
                    Text("For further information, please refer to:")
                        .font(.system(size:10))
                    
                    Link(destination: URL(string: "https://www.optometrytimes.com/view/deconstructing-20-20-20-rule-digital-eye-strain")!) {
                        HStack(spacing: 4) {
                            Text("The 20-20-20 Rule")
                            Image(systemName: "arrow.up.forward.app")
                        }
                        .font(.caption)
                    }
                    
                    Link(destination: URL(string: "https://www.sciencedirect.com/science/article/abs/pii/S0014483525002349?via%3Dihub")!) {
                        HStack(spacing: 4) {
                            Text("Research Supporting Bespoke Eye Break Intervals")
                            Image(systemName: "arrow.up.forward.app")
                        }
                        .font(.caption)
                    }
                    
                    Text("Disclaimer: This application is a general wellness tool designed to encourage ergonomic screen breaks. It does not provide medical advice, diagnosis, or treatment. This app acts as a general habit promoting tool and should not replace professional ophthalmic or medical consultation.")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding()
            .frame(width: 410, height: 400)
        }
    }
}
