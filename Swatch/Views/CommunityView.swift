import SwiftUI

// MARK: - Community View

struct CommunityView: View {
    @StateObject private var communityService = ColorCommunityService.shared
    @State private var selectedSection = 0

    var body: some View {
        VStack(spacing: 0) {
            // Section Picker
            Picker("", selection: $selectedSection) {
                Text("Featured").tag(0)
                Text("Trending").tag(1)
                Text("My Shared").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()

            Divider()

            // Content
            ScrollView {
                switch selectedSection {
                case 0:
                    featuredSection
                case 1:
                    trendingSection
                case 2:
                    mySharedSection
                default:
                    EmptyView()
                }
            }
        }
    }

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Featured Palettes")
                    .font(.headline)
                Spacer()
                Button("Refresh") {
                    Task {
                        await communityService.fetchFeaturedPalettes()
                    }
                }
                .controlSize(.small)
            }

            ForEach(communityService.featuredPalettes) { palette in
                paletteCard(palette)
            }

            if communityService.featuredPalettes.isEmpty {
                Button("Load Featured") {
                    Task {
                        await communityService.fetchFeaturedPalettes()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }

    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Trending Palettes")
                    .font(.headline)
                Spacer()
                Button("Refresh") {
                    Task {
                        await communityService.fetchTrendingPalettes()
                    }
                }
                .controlSize(.small)
            }

            ForEach(communityService.trendingPalettes) { palette in
                paletteCard(palette)
            }

            if communityService.trendingPalettes.isEmpty {
                Button("Load Trending") {
                    Task {
                        await communityService.fetchTrendingPalettes()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }

    private var mySharedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("My Shared Palettes")
                .font(.headline)

            if communityService.mySharedPalettes.isEmpty {
                emptySharedState
            } else {
                ForEach(communityService.mySharedPalettes) { palette in
                    paletteCard(palette)
                }
            }
        }
        .padding()
    }

    private var emptySharedState: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 32))
                .foregroundColor(.secondary)

            Text("No Shared Palettes")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("Share your palettes from the Palettes tab")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }

    private func paletteCard(_ palette: ColorSet) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(palette.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    if let author = palette.authorName {
                        Text("by \(author)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "arrow.down.circle")
                    Text("\(palette.downloadCount)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            // Color strip
            HStack(spacing: 2) {
                ForEach(palette.colors.prefix(5)) { color in
                    Rectangle()
                        .fill(Color(hex: color.hex))
                        .frame(height: 30)
                }
            }
            .cornerRadius(4)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Export View

struct ExportView: View {
    @StateObject private var communityService = ColorCommunityService.shared
    @ObservedObject var store: ColorStore
    @State private var selectedFormat: ColorExportFormat = .hex
    @State private var exportCode = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Export Colors")
                    .font(.title2)
                    .fontWeight(.bold)

                // Current Color
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Color")
                        .font(.headline)

                    HStack {
                        Rectangle()
                            .fill(Color(hex: store.selectedColor.hex))
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)

                        VStack(alignment: .leading) {
                            Text(store.selectedColor.hex)
                                .font(.system(.body, design: .monospaced))
                            Text("HEX")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Format Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Export Format")
                        .font(.headline)

                    Picker("Format", selection: $selectedFormat) {
                        ForEach(ColorExportFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .labelsHidden()
                }

                // Code Preview
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preview")
                        .font(.headline)

                    Text(generateExportCode())
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                }

                // Copy Button
                Button("Copy to Clipboard") {
                    copyToClipboard(generateExportCode())
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }

    private func generateExportCode() -> String {
        let color = store.selectedColor

        switch selectedFormat {
        case .hex:
            return color.hex
        case .rgb:
            let rgb = color.toRGB()
            return "rgb(\(rgb.r), \(rgb.g), \(rgb.b))"
        case .rgba:
            let rgb = color.toRGB()
            return "rgba(\(rgb.r), \(rgb.g), \(rgb.b), 1.0)"
        case .swift:
            return "UIColor(red: \(Double(color.toRGB().r)/255), green: \(Double(color.toRGB().g)/255), blue: \(Double(color.toRGB().b)/255), alpha: 1.0)"
        case .swiftui:
            return "Color(hex: \"\(color.hex)\")"
        case .css:
            return "--color-primary: \(color.hex);"
        case .json:
            return "{\"hex\": \"\(color.hex)\"}"
        default:
            return color.hex
        }
    }

    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}

// MARK: - Accessibility View

struct AccessibilityView: View {
    @StateObject private var communityService = ColorCommunityService.shared
    @State private var foregroundHex = "#000000"
    @State private var backgroundHex = "#FFFFFF"
    @State private var checkResult: AccessibilityCheck?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Color Accessibility")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Check contrast ratios for WCAG compliance")
                    .foregroundColor(.secondary)

                // Color Inputs
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Foreground")
                            .font(.caption)
                        HStack {
                            Rectangle()
                                .fill(Color(hex: foregroundHex))
                                .frame(width: 40, height: 40)
                                .cornerRadius(4)
                            TextField("HEX", text: $foregroundHex)
                                .textFieldStyle(.roundedBorder)
                        }
                    }

                    VStack(alignment: .leading) {
                        Text("Background")
                            .font(.caption)
                        HStack {
                            Rectangle()
                                .fill(Color(hex: backgroundHex))
                                .frame(width: 40, height: 40)
                                .cornerRadius(4)
                            TextField("HEX", text: $backgroundHex)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                }

                Button("Check Contrast") {
                    checkResult = communityService.checkAccessibility(
                        foreground: foregroundHex,
                        background: backgroundHex
                    )
                }
                .buttonStyle(.borderedProminent)

                // Preview
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preview")
                        .font(.headline)

                    ZStack {
                        Rectangle()
                            .fill(Color(hex: backgroundHex))
                            .frame(height: 80)
                            .cornerRadius(8)

                        Text("Sample Text on Background")
                            .foregroundColor(Color(hex: foregroundHex))
                            .font(.title3)
                    }
                }

                // Results
                if let result = checkResult {
                    resultsView(result)
                }
            }
            .padding()
        }
    }

    private func resultsView(_ result: AccessibilityCheck) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Results")
                .font(.headline)

            HStack {
                Text("Contrast Ratio:")
                Spacer()
                Text(String(format: "%.2f:1", result.contrastRatio))
                    .fontWeight(.bold)
            }

            HStack {
                Text("WCAG AA (normal text):")
                Spacer()
                Image(systemName: result.wcagAA ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(result.wcagAA ? .green : .red)
            }

            HStack {
                Text("WCAG AA (large text):")
                Spacer()
                Image(systemName: result.wcagAALarge ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(result.wcagAALarge ? .green : .red)
            }

            HStack {
                Text("WCAG AAA (normal text):")
                Spacer()
                Image(systemName: result.wcagAAA ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(result.wcagAAA ? .green : .red)
            }

            if let recommendation = result.recommendation {
                Text(recommendation)
                    .foregroundColor(.orange)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}
