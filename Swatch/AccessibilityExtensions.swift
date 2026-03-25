import SwiftUI

// MARK: - Accessibility Extensions

extension View {
    func accessibilityColorLabel(_ color: SwatchColor, role: String) -> some View {
        self.accessibilityLabel("\(role), \(color.hex), red \(color.rgb.r), green \(color.rgb.g), blue \(color.rgb.b)")
    }
    
    func accessibilityColorFormat(label: String, value: String) -> some View {
        self.accessibilityLabel("\(label) color format, \(value)")
    }
    
    func reduceMotionPrefers() -> Bool {
        #if os(macOS)
        return NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        #else
        return false
        #endif
    }
}

// MARK: - Accessible Color Format Row

struct AccessibleFormatRow: View {
    let label: String
    let value: String
    let color: SwatchColor
    let onCopy: () -> Void
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(Color(nsColor: Theme.textSecondary))
                .frame(width: 52, alignment: .leading)
                .accessibilityHidden(true)

            Text(value)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.white)
                .lineLimit(1)
                .truncationMode(.tail)
                .accessibilityLabel("\(label) color format, \(value)")

            Spacer()

            Button(action: onCopy) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 10))
                    .foregroundColor(Color(nsColor: Theme.textSecondary))
            }
            .buttonStyle(.plain)
            .frame(width: 20, height: 20)
            .accessibilityLabel("Copy \(label) color to clipboard")
            .keyboardShortcut("c", modifiers: [.command])
        }
    }
}

// MARK: - Accessible History Swatch

struct AccessibleHistorySwatch: View {
    let color: SwatchColor
    let index: Int
    let total: Int
    let onTap: () -> Void
    
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color(nsColor: color.nsColor))
            .frame(width: Theme.historyCellSize, height: Theme.historyCellSize)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            )
            .onTapGesture { onTap() }
            .accessibilityLabel("Color history item \(index + 1) of \(total), \(color.hex)")
            .accessibilityAddTraits(.isButton)
            .help(color.hex)
    }
}

// MARK: - Accessible Harmony Swatch

struct AccessibleHarmonySwatch: View {
    let color: SwatchColor
    let harmonyType: String
    let onTap: () -> Void
    
    var body: some View {
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
        .onTapGesture { onTap() }
        .accessibilityLabel("\(harmonyType) color, \(color.hex), click to select")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Accessible Eyedropper Button

struct AccessibleEyedropperButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
        .accessibilityLabel("Pick color from screen, opens screen picker")
        .accessibilityHint("Use Cmd+Shift+C as keyboard shortcut")
        .keyboardShortcut("c", modifiers: [.command, .shift])
    }
}

// MARK: - Accessible Quick Copy Button

struct AccessibleQuickCopyButton: View {
    let title: String
    let color: SwatchColor
    let onCopy: () -> Void
    
    var body: some View {
        Button(action: onCopy) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(Color(nsColor: color.nsColor).opacity(0.3))
                .cornerRadius(Theme.smallRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.smallRadius)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Copy \(title)")
    }
}

// MARK: - Accessible Palette Swatch

struct AccessiblePaletteSwatch: View {
    let color: SwatchColor
    let paletteName: String
    let colorIndex: Int
    let totalColors: Int
    let onTap: () -> Void
    
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color(nsColor: color.nsColor))
            .frame(width: 24, height: 24)
            .onTapGesture { onTap() }
            .accessibilityLabel("Color \(colorIndex + 1) of \(totalColors) in \(paletteName), \(color.hex)")
            .accessibilityAddTraits(.isButton)
            .help(color.name ?? color.hex)
    }
}

// MARK: - Accessible Contrast Badge

struct AccessibleContrastBadge: View {
    let text: String
    let passed: Bool
    
    var body: some View {
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
        .accessibilityLabel("\(text), \(passed ? "pass" : "fail")")
    }
}

// MARK: - Accessibility Info

struct AccessibilityInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Swatch supports VoiceOver, Dynamic Type, and Keyboard Navigation")
                .font(.system(size: 11))
                .foregroundColor(Color(nsColor: Theme.textSecondary))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Keyboard Shortcuts")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                
                HStack(spacing: 16) {
                    shortcutBadge("⌘⇧C", "Pick Color")
                    shortcutBadge("⌘C", "Copy Format")
                }
            }
        }
        .padding(12)
        .background(Color(nsColor: Theme.surfaceColor))
        .cornerRadius(8)
        .accessibilityElement(children: .combine)
    }
    
    private func shortcutBadge(_ key: String, _ description: String) -> some View {
        HStack(spacing: 4) {
            Text(key)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(nsColor: Theme.surfaceElevated))
                .cornerRadius(3)
            Text(description)
                .font(.system(size: 10))
                .foregroundColor(Color(nsColor: Theme.textSecondary))
        }
    }
}
