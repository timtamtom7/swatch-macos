import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject private var store = ColorStore.shared
    @ObservedObject private var paletteStore = PaletteStore.shared
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            PickerView(store: store, paletteStore: paletteStore)
                .tabItem {
                    Label("Picker", systemImage: "eyedropper")
                }
                .tag(0)

            PalettesView(store: store, paletteStore: paletteStore)
                .tabItem {
                    Label("Palettes", systemImage: "square.grid.3x3")
                }
                .tag(1)

            HarmonyView(store: store)
                .tabItem {
                    Label("Harmony", systemImage: "circle.hexagongrid")
                }
                .tag(2)

            ContrastView(store: store)
                .tabItem {
                    Label("Contrast", systemImage: "circle.lefthalf.filled")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(4)
        }
        .frame(width: Theme.popoverWidth, height: Theme.popoverHeight)
        .background(Color(nsColor: Theme.backgroundColor))
        .onReceive(store.$selectedColor) { color in
            updateStatusItemColor(color)
        }
    }

    private func updateStatusItemColor(_ color: SwatchColor) {
        guard let appDelegate = NSApp.delegate as? AppDelegate else { return }
        appDelegate.updateStatusItemColor(color.nsColor)
    }
}

// MARK: - Picker View (Main Color View)

struct PickerView: View {
    @ObservedObject var store: ColorStore
    @ObservedObject var paletteStore: PaletteStore
    @State private var showEyedropperCursor = false

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
                    addToPaletteSection
                }
                .padding(16)
            }
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
            colorFormatRow(label: "HEX", value: store.selectedColor.hex)
            colorFormatRow(label: "RGB", value: store.selectedColor.rgbString)
            colorFormatRow(label: "HSB", value: store.selectedColor.hsbString)
            colorFormatRow(label: "CMYK", value: store.selectedColor.cmykString)
            colorFormatRow(label: "Swift", value: store.selectedColor.swiftUIColor)
            colorFormatRow(label: "NSColor", value: store.selectedColor.nsColorString)
        }
        .padding(12)
        .background(Color(nsColor: Theme.surfaceColor))
        .cornerRadius(Theme.cornerRadius)
    }

    private func colorFormatRow(label: String, value: String) -> some View {
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
                    Button("Clear") { store.clearHistory() }
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
                            .onTapGesture { store.selectColor(swatchColor) }
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
            quickCopyButton(title: "Copy HEX") { store.copyToClipboard(store.selectedColor.hex) }
            quickCopyButton(title: "Copy RGB") { store.copyToClipboard(store.selectedColor.rgbString) }
            quickCopyButton(title: "Copy Swift") { store.copyToClipboard(store.selectedColor.swiftUIColor) }
        }
    }

    private func quickCopyButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(Color(nsColor: store.selectedColor.nsColor).opacity(0.3))
                .cornerRadius(Theme.smallRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.smallRadius)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var addToPaletteSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Add to Palette")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(nsColor: Theme.textSecondary))
                Spacer()
            }

            if paletteStore.palettes.isEmpty {
                Button("Create First Palette") {
                    let palette = paletteStore.createPalette(name: "My Palette")
                    paletteStore.setActivePalette(palette.id)
                }
                .font(.system(size: 12))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(paletteStore.palettes) { palette in
                            Button(action: { paletteStore.addColorToActivePalette(store.selectedColor) }) {
                                Text(palette.name)
                                    .font(.system(size: 11))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color(nsColor: Theme.surfaceElevated))
                                    .cornerRadius(4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private func activateEyedropper() {
        guard let appDelegate = NSApp.delegate as? AppDelegate else { return }
        appDelegate.activateEyedropper()
    }

    private func openSystemColorPicker() {
        let panel = NSColorPanel.shared
        panel.setTarget(nil)
        panel.color = store.selectedColor.nsColor
        panel.isContinuous = false
        panel.mode = .wheel
        panel.orderFront(nil)
    }
}

// MARK: - Palettes View

struct PalettesView: View {
    @ObservedObject var store: ColorStore
    @ObservedObject var paletteStore: PaletteStore
    @State private var showCreatePalette = false
    @State private var newPaletteName = ""
    @State private var selectedPaletteId: UUID?
    @State private var showExportSheet = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Palettes")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Button(action: { showCreatePalette = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(Color(nsColor: Theme.surfaceColor))

            Divider()

            ScrollView {
                VStack(spacing: 12) {
                    if paletteStore.palettes.isEmpty {
                        emptyState
                    } else {
                        ForEach(paletteStore.palettes) { palette in
                            paletteCard(palette)
                        }
                    }
                }
                .padding(12)
            }
        }
        .sheet(isPresented: $showCreatePalette) {
            createPaletteSheet
        }
        .sheet(isPresented: $showExportSheet) {
            if let paletteId = selectedPaletteId,
               let palette = paletteStore.palettes.first(where: { $0.id == paletteId }) {
                ExportSheet(palette: palette, paletteStore: paletteStore, isPresented: $showExportSheet)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.grid.3x3")
                .font(.system(size: 32))
                .foregroundColor(Color(nsColor: Theme.textSecondary))
            Text("No palettes yet")
                .font(.system(size: 14))
                .foregroundColor(.white)
            Text("Create a palette to organize your colors")
                .font(.system(size: 11))
                .foregroundColor(Color(nsColor: Theme.textSecondary))
            Button("Create Palette") { showCreatePalette = true }
                .font(.system(size: 12, weight: .medium))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    private func paletteCard(_ palette: ColorPalette) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(palette.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
                Text("\(palette.colors.count) colors")
                    .font(.system(size: 10))
                    .foregroundColor(Color(nsColor: Theme.textSecondary))

                Button(action: {
                    selectedPaletteId = palette.id
                    showExportSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 11))
                        .foregroundColor(Color(nsColor: Theme.textSecondary))
                }
                .buttonStyle(.plain)

                Button(action: { paletteStore.deletePalette(palette.id) }) {
                    Image(systemName: "trash")
                        .font(.system(size: 11))
                        .foregroundColor(Color(nsColor: Theme.textSecondary))
                }
                .buttonStyle(.plain)
            }

            if palette.colors.isEmpty {
                Text("No colors in this palette")
                    .font(.system(size: 11))
                    .foregroundColor(Color(nsColor: Theme.textSecondary))
                    .padding(.vertical, 8)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(24), spacing: 4), count: 10), spacing: 4) {
                    ForEach(palette.colors) { color in
                        let swatchColor = SwatchColor(hex: color.hex)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(nsColor: swatchColor.nsColor))
                            .frame(width: 24, height: 24)
                            .onTapGesture {
                                store.selectColor(swatchColor)
                            }
                            .help(color.name ?? color.hex)
                    }
                }
            }
        }
        .padding(12)
        .background(Color(nsColor: Theme.surfaceColor))
        .cornerRadius(Theme.cornerRadius)
    }

    private var createPaletteSheet: some View {
        VStack(spacing: 16) {
            Text("New Palette")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)

            TextField("Palette name", text: $newPaletteName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 200)

            HStack {
                Button("Cancel") { showCreatePalette = false }
                    .buttonStyle(.bordered)
                Button("Create") {
                    if !newPaletteName.isEmpty {
                        let palette = paletteStore.createPalette(name: newPaletteName)
                        paletteStore.setActivePalette(palette.id)
                        newPaletteName = ""
                        showCreatePalette = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(newPaletteName.isEmpty)
            }
        }
        .padding(20)
        .frame(width: 280, height: 140)
    }
}

// MARK: - Export Sheet

struct ExportSheet: View {
    let palette: ColorPalette
    @ObservedObject var paletteStore: PaletteStore
    @Binding var isPresented: Bool
    @State private var selectedFormat: ExportFormat = .css

    var body: some View {
        VStack(spacing: 16) {
            Text("Export: \(palette.name)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)

            Picker("Format", selection: $selectedFormat) {
                ForEach(ExportFormat.allCases, id: \.self) { format in
                    Text(format.rawValue).tag(format)
                }
            }
            .pickerStyle(.segmented)

            ScrollView {
                Text(paletteStore.exportPalette(palette, format: selectedFormat))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 200)
            .padding(8)
            .background(Color.black.opacity(0.3))
            .cornerRadius(6)

            HStack {
                Button("Copy") {
                    let text = paletteStore.exportPalette(palette, format: selectedFormat)
                    ClipboardHelper.copy(text)
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                Button("Done") { isPresented = false }
                    .buttonStyle(.bordered)
            }
        }
        .padding(20)
        .frame(width: 340, height: 380)
        .background(Color(nsColor: Theme.backgroundColor))
    }
}

// MARK: - Clipboard Helper

enum ClipboardHelper {
    static func copy(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}

// MARK: - Harmony View

struct HarmonyView: View {
    @ObservedObject var store: ColorStore

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Color Harmony")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    ForEach(harmonyColors, id: \.hex) { color in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(nsColor: color.nsColor))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                            Text(color.hex)
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(Color(nsColor: Theme.textSecondary))
                        }
                        .onTapGesture {
                            store.selectColor(color)
                        }
                    }
                }
                .padding(12)
                .background(Color(nsColor: Theme.surfaceColor))
                .cornerRadius(Theme.cornerRadius)

                VStack(alignment: .leading, spacing: 8) {
                    harmonyButton(.complementary)
                    harmonyButton(.triadic)
                    harmonyButton(.analogous)
                    harmonyButton(.splitComplementary)
                    harmonyButton(.tetradic)
                }
            }
            .padding(16)
        }
    }

    private var harmonyColors: [SwatchColor] {
        let hsb = store.selectedColor.hsb
        return ColorHarmony.triadic.colors(from: (h: hsb.h, s: hsb.s, b: hsb.b)).map { h, s, b in
            SwatchColor(hue: h, saturation: s, brightness: b)
        }
    }

    private func harmonyButton(_ harmony: ColorHarmony) -> some View {
        let colors = harmony.colors(from: (h: store.selectedColor.hsb.h, s: store.selectedColor.hsb.s, b: store.selectedColor.hsb.b))
        return Button(action: {
            let first = colors.first
            if let c = first {
                store.selectColor(SwatchColor(hue: c.h, saturation: c.s, brightness: c.b))
            }
        }) {
            HStack(spacing: 6) {
                Text(harmonyName(harmony))
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                Spacer()
                HStack(spacing: 3) {
                    ForEach(Array(colors.enumerated()), id: \.offset) { _, c in
                        let color = SwatchColor(hue: c.h, saturation: c.s, brightness: c.b)
                        Circle()
                            .fill(Color(nsColor: color.nsColor))
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding(10)
            .background(Color(nsColor: Theme.surfaceColor))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }

    private func harmonyName(_ harmony: ColorHarmony) -> String {
        switch harmony {
        case .complementary: return "Complementary"
        case .triadic: return "Triadic"
        case .analogous: return "Analogous"
        case .splitComplementary: return "Split Complementary"
        case .tetradic: return "Tetradic"
        }
    }
}

// MARK: - Contrast View

struct ContrastView: View {
    @ObservedObject var store: ColorStore
    @State private var backgroundColor: SwatchColor = SwatchColor(hex: "#FFFFFF")
    @State private var foregroundColor: SwatchColor = SwatchColor(hex: "#000000")

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("WCAG Contrast Checker")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)

                // Preview
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        colorPicker("Background", color: $backgroundColor)
                        colorPicker("Foreground", color: $foregroundColor)
                    }

                    // Sample text
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sample Text")
                            .font(.system(size: 14, weight: .bold))
                        Text("This is how your color combination looks in practice.")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(Color(nsColor: foregroundColor.nsColor))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color(nsColor: backgroundColor.nsColor))
                    .cornerRadius(6)
                }
                .padding(12)
                .background(Color(nsColor: Theme.surfaceColor))
                .cornerRadius(Theme.cornerRadius)

                // Results
                let contrast = WCAGContrast(background: backgroundColor, foreground: foregroundColor)
                VStack(spacing: 8) {
                    HStack {
                        Text("Contrast Ratio")
                            .font(.system(size: 12))
                            .foregroundColor(Color(nsColor: Theme.textSecondary))
                        Spacer()
                        Text(contrast.ratioString)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(ratioColor(contrast.contrastRatio))
                    }

                    HStack(spacing: 8) {
                        wcagBadge("AA Normal", passed: contrast.wcagAA)
                        wcagBadge("AA Large", passed: contrast.wcagAALarge)
                        wcagBadge("AAA Normal", passed: contrast.wcagAAA)
                        wcagBadge("AAA Large", passed: contrast.wcagAAALarge)
                    }
                }
                .padding(12)
                .background(Color(nsColor: Theme.surfaceColor))
                .cornerRadius(Theme.cornerRadius)
            }
            .padding(16)
        }
        .onAppear {
            foregroundColor = store.selectedColor
        }
    }

    private func colorPicker(_ label: String, color: Binding<SwatchColor>) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(Color(nsColor: Theme.textSecondary))
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(nsColor: color.wrappedValue.nsColor))
                .frame(width: 80, height: 40)
                .overlay(
                    Text(color.wrappedValue.hex)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(Color.white.opacity(0.7))
                )
                .cornerRadius(4)
                .onTapGesture {
                    store.selectColor(color.wrappedValue)
                    foregroundColor = color.wrappedValue
                }
        }
        .frame(maxWidth: .infinity)
    }

    private func wcagBadge(_ text: String, passed: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 12))
            Text(text)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundColor(passed ? .green : .red)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background((passed ? Color.green : Color.red).opacity(0.15))
        .cornerRadius(4)
    }

    private func ratioColor(_ ratio: Double) -> Color {
        if ratio >= 7 { return .green }
        if ratio >= 4.5 { return .yellow }
        return .red
    }
}

// MARK: - Settings View

struct SettingsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    sectionHeader("ABOUT")
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Swatch")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                        Text("Color picker and palette manager for macOS")
                            .font(.system(size: 11))
                            .foregroundColor(Color(nsColor: Theme.textSecondary))
                    }
                    .padding(12)
                    .background(Color(nsColor: Theme.surfaceColor))
                    .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    sectionHeader("ACCESSIBILITY")
                    AccessibilityInfoView()
                }
            }
            .padding(16)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(Color(nsColor: Theme.textSecondary))
            .tracking(0.05)
    }
}
