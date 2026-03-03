import Carbon
import Foundation

struct ShortcutEntry: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var appName: String
    var bundleIdentifier: String?
    var appURL: URL?
    var keyCode: UInt32?
    var modifiers: UInt32

    init(
        id: UUID = UUID(),
        title: String = "New Shortcut",
        appName: String = "",
        bundleIdentifier: String? = nil,
        appURL: URL? = nil,
        keyCode: UInt32? = nil,
        modifiers: UInt32 = UInt32(cmdKey)
    ) {
        self.id = id
        self.title = title
        self.appName = appName
        self.bundleIdentifier = bundleIdentifier
        self.appURL = appURL
        self.keyCode = keyCode
        self.modifiers = modifiers
    }

    var isComplete: Bool {
        keyCode != nil && (appURL != nil || bundleIdentifier != nil)
    }
}
