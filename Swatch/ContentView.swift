import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject private var store = ColorStore.shared
    @State private var showEyedropperCursor = false
    @State private var showSettingsMenu = false

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            ScrollView {
                VStack(spacing: 12) {
                    colorPreviewSection
                    colorFormatsSection
                    eyedropperSection
                    historySection
                    quickCopySection
                }
                .padding(16)
            }
        }
        .frame(width: Theme.popoverWidth, height: Theme.popoverHeight)
        .background(Color(nsColor: Theme.backgroundColor))
        .onReceive(store.$selectedColor) { color in
            updateStatusItemColor(color)
        }
    }

    private var headerView: some View {
        HStack {
            Text("Swatch")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)

            Spacer()

            Button(action: activateEyedropper) {
                Image(systemName: "eye.dropper")
                    .font(.system(size: 13))
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)
            .help("Pick Screen Color (Cmd+Shift+C)")

            Menu {
                Button("Clear History", action: { store.clearHistory() })
                Divider()
                Button("Pick Screen Color", action: activateEyedropper)
                Divider()
                Button("Open System Color Picker") {
                    openSystemColorPicker()
                }
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 13))
                    .foregroundColor(.white)
            }
            .menuStyle(.borderlessButton)
            .frame(width: 24, height: 24)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(nsColor: Theme.surfaceColor))
    }

    private var colorPreviewSection: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(Color(nsColor: store.selectedColor.nsColor))
                .frame(width: Theme.swatchSize, height: Theme.swatchSize)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
    }

    private var colorFormatsSection: some View {
        VStack(spacing: 6) {
            colorFormatRow(label: "HEX", value: store.selectedColor.hex, color: store.selectedColor.nsColor)
            colorFormatRow(label: "RGB", value: store.selectedColor.rgbString, color: store.selectedColor.nsColor)
            colorFormatRow(label: "HSB", value: store.selectedColor.hsbString, color: store.selectedColor.nsColor)
            colorFormatRow(label: "CMYK", value: store.selectedColor.cmykString, color: store.selectedColor.nsColor)
            colorFormatRow(label: "Swift", value: store.selectedColor.swiftUIColor, color: store.selectedColor.nsColor)
            colorFormatRow(label: "NSColor", value: store.selectedColor.nsColorString, color: store.selectedColor.nsColor)
        }
        .padding(12)
        .background(Color(nsColor: Theme.surfaceColor))
        .cornerRadius(Theme.cornerRadius)
    }

    private func colorFormatRow(label: String, value: String, color: NSColor) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(Color(nsColor: Theme.textSecondary))
                .frame(width: 52, alignment: .leading)

            Text(value)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.white)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer()

            Button(action: { store.copyToClipboard(value) }) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 10))
                    .foregroundColor(Color(nsColor: Theme.textSecondary))
            }
            .buttonStyle(.plain)
            .frame(width: 20, height: 20)
        }
    }

    private var eyedropperSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Eyedropper")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(nsColor: Theme.textSecondary))
                Spacer()
            }

            Button(action: activateEyedropper) {
                HStack {
                    Image(systemName: "eye.dropper")
                        .font(.system(size: 12))
                    Text("Pick Screen Color")
                        .font(.system(size: 12))
                    Spacer()
                    Text("⌘⇧C")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color(nsColor: Theme.textSecondary))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(nsColor: Theme.surfaceElevated))
                .cornerRadius(Theme.smallRadius)
            }
            .buttonStyle(.plain)
        }
    }

    private var historySection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("History")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(nsColor: Theme.textSecondary))
                Spacer()
                if !store.colorHistory.isEmpty {
                    Button("Clear") {
                        store.clearHistory()
                    }
                    .font(.system(size: 10))
                    .foregroundColor(Color(nsColor: Theme.textSecondary))
                    .buttonStyle(.plain)
                }
            }

            if store.colorHistory.isEmpty {
                Text("No colors yet")
                    .font(.system(size: 11))
                    .foregroundColor(Color(nsColor: Theme.textSecondary))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(Theme.historyCellSize), spacing: 4), count: 10), spacing: 4) {
                    ForEach(store.colorHistory.prefix(20)) { swatchColor in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(nsColor: swatchColor.nsColor))
                            .frame(width: Theme.historyCellSize, height: Theme.historyCellSize)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                            )
                            .onTapGesture {
                                store.selectColor(swatchColor)
                            }
                            .help(swatchColor.hex)
                    }
                }
            }
        }
        .padding(12)
        .background(Color(nsColor: Theme.surfaceColor))
        .cornerRadius(Theme.cornerRadius)
    }

    private var quickCopySection: some View {
        HStack(spacing: 8) {
            quickCopyButton(title: "Copy HEX", color: store.selectedColor.nsColor) {
                store.copyToClipboard(store.selectedColor.hex)
            }
            quickCopyButton(title: "Copy RGB", color: store.selectedColor.nsColor) {
                store.copyToClipboard(store.selectedColor.rgbString)
            }
            quickCopyButton(title: "Copy Swift", color: store.selectedColor.nsColor) {
                store.copyToClipboard(store.selectedColor.swiftUIColor)
            }
        }
    }

    private func quickCopyButton(title: String, color: NSColor, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(Color(nsColor: color).opacity(0.3))
                .cornerRadius(Theme.smallRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.smallRadius)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func activateEyedropper() {
        guard let appDelegate = NSApp.delegate as? AppDelegate else { return }
        appDelegate.activateEyedropper()
    }

    private func updateStatusItemColor(_ color: SwatchColor) {
        guard let appDelegate = NSApp.delegate as? AppDelegate else { return }
        appDelegate.updateStatusItemColor(color.nsColor)
    }

    private func openSystemColorPicker() {
        let panel = NSColorPanel.shared
        panel.setTarget(self)
        panel.color = store.selectedColor.nsColor
        panel.isContinuous = false
        panel.mode = .wheel
        panel.orderFront(nil)

        NotificationCenter.default.addObserver(
            forName: NSColorPanel.colorDidChangeNotification,
            object: panel,
            queue: .main
        ) { [self] _ in
            let color = SwatchColor(nsColor: panel.color)
            store.selectColor(color)
        }
    }
}
