import Combine
import Foundation

final class ShortcutStore: ObservableObject {
    @Published private(set) var entries: [ShortcutEntry] = []

    private let storageKey = "shortcut_entries"
    private let defaults = UserDefaults.standard

    init() {
        load()
    }

    func load() {
        guard let data = defaults.data(forKey: storageKey) else {
            entries = []
            return
        }

        do {
            entries = try JSONDecoder().decode([ShortcutEntry].self, from: data)
        } catch {
            entries = []
        }
    }

    func addEntry() {
        entries.append(ShortcutEntry())
        persist()
    }

    func updateEntry(_ entry: ShortcutEntry) {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[index] = entry
        persist()
    }

    func removeEntries(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        persist()
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(entries)
            defaults.set(data, forKey: storageKey)
        } catch {
            assertionFailure("Failed to persist shortcuts: \(error)")
        }
    }
}
