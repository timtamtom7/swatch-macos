import AppKit
import SwiftUI

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var colorPickerWindow: NSWindow?
    private var globalHotkeyMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize SwatchState for shortcuts
        SwatchState.shared.configure()

        setupMenu()
        setupStatusItem()
        setupPopover()
        setupGlobalHotkey()
    }

    private func setupMenu() {
        let mainMenu = NSMenu()

        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)

        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu

        let aboutItem = NSMenuItem(
            title: "About Swatch",
            action: #selector(showAbout),
            keyEquivalent: ""
        )
        aboutItem.target = self
        appMenu.addItem(aboutItem)

        appMenu.addItem(NSMenuItem.separator())

        let prefsItem = NSMenuItem(
            title: "Preferences...",
            action: #selector(showPreferences),
            keyEquivalent: ","
        )
        prefsItem.target = self
        appMenu.addItem(prefsItem)

        appMenu.addItem(NSMenuItem.separator())

        let hideItem = NSMenuItem(
            title: "Hide Swatch",
            action: #selector(NSApplication.hide(_:)),
            keyEquivalent: "h"
        )
        appMenu.addItem(hideItem)

        appMenu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(
            title: "Quit Swatch",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        appMenu.addItem(quitItem)

        NSApp.mainMenu = mainMenu
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.action = #selector(togglePopover)
            button.target = self

            let color = ColorStore.shared.selectedColor.nsColor
            let image = makeColorSwatchImage(color: color, size: NSSize(width: 18, height: 18))
            button.image = image
            button.image?.isTemplate = false
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: Theme.popoverWidth, height: Theme.popoverHeight)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(rootView: ContentView())
    }

    private func setupGlobalHotkey() {
        globalHotkeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains([.command, .shift]) && event.charactersIgnoringModifiers == "c" {
                self?.activateEyedropper()
            }
        }
    }

    func updateStatusItemColor(_ color: NSColor) {
        guard let button = statusItem.button else { return }
        let image = makeColorSwatchImage(color: color, size: NSSize(width: 18, height: 18))
        button.image = image
        button.image?.isTemplate = false
    }

    private func makeColorSwatchImage(color: NSColor, size: NSSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        color.setFill()
        let rect = NSRect(origin: .zero, size: size)
        let path = NSBezierPath(roundedRect: rect, xRadius: 3, yRadius: 3)
        path.fill()

        NSColor.white.withAlphaComponent(0.3).setStroke()
        path.lineWidth = 0.5
        path.stroke()
        image.unlockFocus()
        return image
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    @objc private func showAbout() {
        NSApp.orderFrontStandardAboutPanel(nil)
    }

    @objc private func showPreferences() {
        // R2: Preferences window
    }

    func activateEyedropper() {
        popover.performClose(nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            EyedropperService.shared.startPicking(
                onColorPicked: { [weak self] color in
                    Task { @MainActor in
                        ColorStore.shared.selectColor(color)
                        self?.updateStatusItemColor(color.nsColor)
                    }
                },
                onCancel: {}
            )
        }
    }
}

// MARK: - Global State for Shortcuts

@MainActor
final class SwatchState {
    static let shared = SwatchState()

    var store: ColorStore? { ColorStore.shared }

    private init() {}

    func configure() {
        // Initialize any state needed for shortcuts
    }
}
