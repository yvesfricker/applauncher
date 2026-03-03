import AppKit
import Carbon
import Combine
import Foundation

final class HotkeyManager: ObservableObject {
    @Published var isPaused = false {
        didSet { refresh() }
    }

    private let store: ShortcutStore
    private var cancellables: Set<AnyCancellable> = []
    private var hotKeyRefs: [UUID: EventHotKeyRef] = [:]
    private var idToEntry: [UInt32: ShortcutEntry] = [:]
    private var eventHandler: EventHandlerRef?
    private var currentID: UInt32 = 1

    init(store: ShortcutStore) {
        self.store = store
        installHandler()

        store.$entries
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)

        refresh()
    }

    deinit {
        hotKeyRefs.values.forEach { UnregisterEventHotKey($0) }
        if let eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }

    private func installHandler() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        let callback: EventHandlerUPP = { _, event, userData in
            guard let event, let userData else { return noErr }
            let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
            manager.handle(event: event)
            return noErr
        }

        InstallEventHandler(
            GetApplicationEventTarget(),
            callback,
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )
    }

    private func refresh() {
        hotKeyRefs.values.forEach { UnregisterEventHotKey($0) }
        hotKeyRefs.removeAll()
        idToEntry.removeAll()

        guard !isPaused else { return }

        for entry in store.entries where entry.isComplete {
            guard let keyCode = entry.keyCode else { continue }

            let hotkeyID = EventHotKeyID(signature: OSType(0x41504C48), id: currentID)
            currentID += 1

            var ref: EventHotKeyRef?
            let result = RegisterEventHotKey(
                keyCode,
                carbonModifiers(from: entry.modifiers),
                hotkeyID,
                GetApplicationEventTarget(),
                0,
                &ref
            )

            if result == noErr, let ref {
                hotKeyRefs[entry.id] = ref
                idToEntry[hotkeyID.id] = entry
            }
        }
    }

    private func handle(event: EventRef) {
        var hotKeyID = EventHotKeyID()
        let status = GetEventParameter(
            event,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &hotKeyID
        )

        guard status == noErr, let entry = idToEntry[hotKeyID.id] else { return }
        AppActivator.activate(entry: entry)
    }

    private func carbonModifiers(from cocoa: UInt32) -> UInt32 {
        var result: UInt32 = 0
        if cocoa & UInt32(cmdKey) != 0 { result |= UInt32(cmdKey) }
        if cocoa & UInt32(optionKey) != 0 { result |= UInt32(optionKey) }
        if cocoa & UInt32(controlKey) != 0 { result |= UInt32(controlKey) }
        if cocoa & UInt32(shiftKey) != 0 { result |= UInt32(shiftKey) }
        return result
    }
}
