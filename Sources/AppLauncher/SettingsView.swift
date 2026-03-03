import AppKit
import Carbon
import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: ShortcutStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Registered Shortcuts")
                    .font(.headline)
                Spacer()
                Button {
                    store.addEntry()
                } label: {
                    Label("Add Shortcut", systemImage: "plus")
                }
            }

            if store.entries.isEmpty {
                EmptyStateView(
                    title: "No shortcuts yet",
                    systemImage: "keyboard",
                    description: "Add a shortcut and assign an app to launch or focus."
                )
                Spacer()
            } else {
                List {
                    ForEach(store.entries) { entry in
                        ShortcutRow(entry: entry) { updated in
                            store.updateEntry(updated)
                        }
                    }
                    .onDelete(perform: store.removeEntries)
                }
                .listStyle(.inset)
            }
        }
        .padding(20)
    }
}

private struct EmptyStateView: View {
    let title: String
    let systemImage: String
    let description: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.headline)
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 160)
        .padding(.vertical, 16)
    }
}

private struct ShortcutRow: View {
    @State var entry: ShortcutEntry
    let onChange: (ShortcutEntry) -> Void

    var body: some View {
        HStack(spacing: 12) {
            TextField("Name", text: binding(\.title))
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 160)

            TextField("App", text: binding(\.appName))
                .textFieldStyle(.roundedBorder)

            Button("Choose App…") {
                chooseApp()
            }

            Picker("Key", selection: Binding(
                get: { Int(entry.keyCode.map(Int.init) ?? -1) },
                set: {
                    entry.keyCode = $0 == -1 ? nil : UInt32($0)
                    onChange(entry)
                }
            )) {
                Text("None").tag(-1)
                ForEach(KeyChoice.common) { key in
                    Text(key.label).tag(Int(key.code))
                }
            }
            .frame(width: 120)

            ModifierPicker(modifiers: binding(\.modifiers))
                .frame(width: 220)
        }
        .padding(.vertical, 4)
    }

    private func binding<T>(_ keyPath: WritableKeyPath<ShortcutEntry, T>) -> Binding<T> {
        Binding(
            get: { entry[keyPath: keyPath] },
            set: { newValue in
                entry[keyPath: keyPath] = newValue
                onChange(entry)
            }
        )
    }

    private func chooseApp() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.application]

        guard panel.runModal() == .OK, let url = panel.url else { return }

        let bundle = Bundle(url: url)
        entry.appURL = url
        entry.bundleIdentifier = bundle?.bundleIdentifier
        entry.appName = bundle?.object(forInfoDictionaryKey: "CFBundleName") as? String ?? url.deletingPathExtension().lastPathComponent
        if entry.title == "New Shortcut" {
            entry.title = entry.appName
        }

        onChange(entry)
    }
}

private struct ModifierPicker: View {
    @Binding var modifiers: UInt32

    var body: some View {
        HStack(spacing: 8) {
            Toggle("⌘", isOn: flagBinding(UInt32(cmdKey)))
            Toggle("⌥", isOn: flagBinding(UInt32(optionKey)))
            Toggle("⌃", isOn: flagBinding(UInt32(controlKey)))
            Toggle("⇧", isOn: flagBinding(UInt32(shiftKey)))
        }
        .toggleStyle(.checkbox)
    }

    private func flagBinding(_ flag: UInt32) -> Binding<Bool> {
        Binding(
            get: { modifiers & flag != 0 },
            set: { enabled in
                if enabled {
                    modifiers |= flag
                } else {
                    modifiers &= ~flag
                }
            }
        )
    }
}

private struct KeyChoice: Identifiable {
    let id: String
    let label: String
    let code: UInt32

    static let common: [KeyChoice] = [
        .init(id: "A", label: "A", code: 0),
        .init(id: "B", label: "B", code: 11),
        .init(id: "C", label: "C", code: 8),
        .init(id: "D", label: "D", code: 2),
        .init(id: "E", label: "E", code: 14),
        .init(id: "F", label: "F", code: 3),
        .init(id: "G", label: "G", code: 5),
        .init(id: "H", label: "H", code: 4),
        .init(id: "I", label: "I", code: 34),
        .init(id: "J", label: "J", code: 38),
        .init(id: "K", label: "K", code: 40),
        .init(id: "L", label: "L", code: 37),
        .init(id: "M", label: "M", code: 46),
        .init(id: "N", label: "N", code: 45),
        .init(id: "O", label: "O", code: 31),
        .init(id: "P", label: "P", code: 35),
        .init(id: "Q", label: "Q", code: 12),
        .init(id: "R", label: "R", code: 15),
        .init(id: "S", label: "S", code: 1),
        .init(id: "T", label: "T", code: 17),
        .init(id: "U", label: "U", code: 32),
        .init(id: "V", label: "V", code: 9),
        .init(id: "W", label: "W", code: 13),
        .init(id: "X", label: "X", code: 7),
        .init(id: "Y", label: "Y", code: 16),
        .init(id: "Z", label: "Z", code: 6),
        .init(id: "1", label: "1", code: 18),
        .init(id: "2", label: "2", code: 19),
        .init(id: "3", label: "3", code: 20),
        .init(id: "4", label: "4", code: 21),
        .init(id: "5", label: "5", code: 23),
        .init(id: "6", label: "6", code: 22),
        .init(id: "7", label: "7", code: 26),
        .init(id: "8", label: "8", code: 28),
        .init(id: "9", label: "9", code: 25),
        .init(id: "0", label: "0", code: 29)
    ]
}
