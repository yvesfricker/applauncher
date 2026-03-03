import AppKit
import Foundation

enum AppActivator {
    static func activate(entry: ShortcutEntry) {
        if let bundleIdentifier = entry.bundleIdentifier,
           let running = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier).first {
            running.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
            return
        }

        if let appURL = entry.appURL {
            launch(url: appURL)
            return
        }

        if let bundleIdentifier = entry.bundleIdentifier,
           let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            launch(url: appURL)
        }
    }

    private static func launch(url: URL) {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true

        NSWorkspace.shared.openApplication(at: url, configuration: configuration) { _, error in
            guard let error else { return }
            DispatchQueue.main.async {
                NSAlert(error: error).runModal()
            }
        }
    }
}
