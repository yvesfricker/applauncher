# AppLauncher

A simple macOS menu bar app to register global keyboard shortcuts that either:

- launch an app, or
- bring a running app to the foreground.

## Current implementation notes

- Uses SwiftUI for menu bar + Settings UI.
- Uses Carbon `RegisterEventHotKey` for global hotkeys.
- Persists shortcut entries in `UserDefaults`.
- Each shortcut can store app target + key + modifiers.

## Run locally on macOS

> This project targets **macOS 13+**. It will not compile on Linux because it depends on AppKit/Carbon.

### Option A: Run from Terminal (SwiftPM)

```bash
swift run AppLauncher
```

When launched, look for the keyboard icon in the menu bar.

### Option B: Open in Xcode

1. Open the folder in Xcode (`File -> Open...`).
2. Let Xcode resolve the Swift package.
3. Run the `AppLauncher` executable target.

## First-use flow

1. Click the menu bar icon.
2. Open **Settings…**.
3. Add a shortcut row.
4. Click **Choose App…** and select a `.app` bundle.
5. Choose key + modifiers.
6. Use the shortcut globally.

If the app is already running, the shortcut activates it; otherwise, it launches it.
