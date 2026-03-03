import AppKit
import SwiftUI

@main
struct AppLauncherApp: App {
    @StateObject private var store: ShortcutStore
    @StateObject private var manager: HotkeyManager

    init() {
        let shortcutStore = ShortcutStore()
        _store = StateObject(wrappedValue: shortcutStore)
        _manager = StateObject(wrappedValue: HotkeyManager(store: shortcutStore))

        NSApp.setActivationPolicy(.accessory)
    }

    var body: some Scene {
        MenuBarExtra("AppLauncher", systemImage: "keyboard") {
            Button("Open Settings…") {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                NSApp.activate(ignoringOtherApps: true)
            }

            Divider()
            Toggle("Pause Shortcuts", isOn: $manager.isPaused)
            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }

        Settings {
            SettingsView(store: store)
                .frame(minWidth: 640, minHeight: 400)
        }
    }
}
