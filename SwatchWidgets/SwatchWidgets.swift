import WidgetKit
import SwiftUI

// MARK: - Color of the Day Widget

struct ColorOfDayEntry: TimelineEntry {
    let date: Date
    let colorHex: String
    let colorName: String
}

struct ColorOfDayProvider: TimelineProvider {
    func placeholder(in context: Context) -> ColorOfDayEntry {
        ColorOfDayEntry(date: Date(), colorHex: "#4A90D9", colorName: "Ocean Blue")
    }

    func getSnapshot(in context: Context, completion: @escaping (ColorOfDayEntry) -> Void) {
        let entry = ColorOfDayEntry(date: Date(), colorHex: "#4A90D9", colorName: "Ocean Blue")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ColorOfDayEntry>) -> Void) {
        let userDefaults = UserDefaults(suiteName: "group.com.swatch.app")
        let colorHex = userDefaults?.string(forKey: "featuredColorHex") ?? "#4A90D9"
        let colorName = userDefaults?.string(forKey: "featuredColorName") ?? "Ocean Blue"
        
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 6
        components.minute = 0
        
        let nextRefresh = calendar.date(from: components) ?? now
        
        let entry = ColorOfDayEntry(date: nextRefresh, colorHex: colorHex, colorName: colorName)
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }
}

struct ColorOfDayWidgetView: View {
    var entry: ColorOfDayEntry

    var body: some View {
        ZStack {
            Color(hex: entry.colorHex)
            VStack {
                Spacer()
                Text(entry.colorHex)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.5), in: RoundedRectangle(cornerRadius: 6))
            }
        }
        .widgetURL(URL(string: "swatch://color?hex=\(entry.colorHex)") ?? URL(string: "swatch://")!)
    }
}

struct ColorOfDayWidget: Widget {
    let kind: String = "ColorOfDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ColorOfDayProvider()) { entry in
            ColorOfDayWidgetView(entry: entry)
        }
        .configurationDisplayName("Color of the Day")
        .description("Shows a featured color daily at 6 AM.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Palette Widget

struct PaletteEntry: TimelineEntry {
    let date: Date
    let paletteName: String
    let colors: [String]
}

struct PaletteProvider: TimelineProvider {
    func placeholder(in context: Context) -> PaletteEntry {
        PaletteEntry(date: Date(), paletteName: "My Palette", colors: ["#FF5733", "#33FF57", "#3357FF", "#F333FF", "#33FFF3"])
    }

    func getSnapshot(in context: Context, completion: @escaping (PaletteEntry) -> Void) {
        let entry = PaletteEntry(date: Date(), paletteName: "My Palette", colors: ["#FF5733", "#33FF57", "#3357FF", "#F333FF", "#33FFF3"])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PaletteEntry>) -> Void) {
        let userDefaults = UserDefaults(suiteName: "group.com.swatch.app")
        let paletteName = userDefaults?.string(forKey: "selectedPaletteName") ?? "My Palette"
        let colors = userDefaults?.stringArray(forKey: "selectedPaletteColors") ?? ["#FF5733", "#33FF57", "#3357FF", "#F333FF", "#33FFF3"]
        
        let entry = PaletteEntry(date: Date(), paletteName: paletteName, colors: colors)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct PaletteWidgetView: View {
    var entry: PaletteEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                ForEach(entry.colors.prefix(5), id: \.self) { hex in
                    Rectangle()
                        .fill(Color(hex: hex))
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 44)
            .cornerRadius(8)
            
            Text(entry.paletteName)
                .font(.caption2)
                .foregroundColor(.secondary)
            + Text(" • Swatch")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .widgetURL(URL(string: "swatch://palette?name=\(entry.paletteName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") ?? URL(string: "swatch://")!)
    }
}

struct PaletteWidget: Widget {
    let kind: String = "PaletteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PaletteProvider()) { entry in
            PaletteWidgetView(entry: entry)
        }
        .configurationDisplayName("Palette Widget")
        .description("Shows your palette's colors.")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Widget Bundle

@main
struct SwatchWidgetBundle: WidgetBundle {
    var body: some Widget {
        ColorOfDayWidget()
        PaletteWidget()
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
