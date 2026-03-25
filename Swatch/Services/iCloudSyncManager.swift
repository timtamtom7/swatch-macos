import Foundation

@MainActor
final class SwatchSyncManager: ObservableObject {
    static let shared = SwatchSyncManager()

    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSynced: Date?

    enum SyncStatus: Equatable {
        case idle
        case syncing
        case synced
        case offline
        case error(String)
    }

    private let store = NSUbiquitousKeyValueStore.default
    private var observers: [NSObjectProtocol] = []

    private init() {
        setupObservers()
    }

    private func setupObservers() {
        let notification = NSUbiquitousKeyValueStore.didChangeExternallyNotification
        let observer = NotificationCenter.default.addObserver(
            forName: notification,
            object: store,
            queue: .main
        ) { [weak self] _ in
            self?.handleExternalChange()
        }
        observers.append(observer)
    }

    // MARK: - Sync Data

    struct SyncPayload: Codable {
        var palettes: [ColorPalette]
        var activePaletteId: UUID?
        var history: [String]
        var settings: SwatchSettings

        struct SwatchSettings: Codable {
            var recentFormat: String
            var showContrast: Bool
        }
    }

    func sync() {
        guard isICloudAvailable else {
            syncStatus = .offline
            return
        }

        syncStatus = .syncing

        do {
            let payload = buildPayload()
            let data = try JSONEncoder().encode(payload)
            store.set(data, forKey: "swatch.sync.data")
            store.synchronize()

            syncStatus = .synced
            lastSynced = Date()
        } catch {
            syncStatus = .error(error.localizedDescription)
        }
    }

    func pullFromCloud() {
        guard isICloudAvailable else { return }

        guard let data = store.data(forKey: "swatch.sync.data"),
              let payload = try? JSONDecoder().decode(SyncPayload.self, from: data) else {
            return
        }

        applyPayload(payload)
    }

    private func buildPayload() -> SyncPayload {
        let palettes = PaletteStore.shared.palettes
        let activeId = PaletteStore.shared.activePalette?.id
        let history = ColorStore.shared.colorHistory.map { $0.hex }

        let settings = SyncPayload.SwatchSettings(
            recentFormat: UserDefaults.standard.string(forKey: "swatch_recentFormat") ?? "hex",
            showContrast: UserDefaults.standard.bool(forKey: "swatch_showContrast")
        )

        return SyncPayload(
            palettes: palettes,
            activePaletteId: activeId,
            history: history,
            settings: settings
        )
    }

    private func applyPayload(_ payload: SyncPayload) {
        PaletteStore.shared.palettes = payload.palettes

        if let activeId = payload.activePaletteId {
            PaletteStore.shared.setActivePalette(activeId)
        }

        ColorStore.shared.colorHistory = payload.history.map { SwatchColor(hex: $0) }

        UserDefaults.standard.set(payload.settings.recentFormat, forKey: "swatch_recentFormat")
        UserDefaults.standard.set(payload.settings.showContrast, forKey: "swatch_showContrast")
    }

    private func handleExternalChange() {
        pullFromCloud()
        syncStatus = .synced
        lastSynced = Date()
    }

    var isICloudAvailable: Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }

    func syncNow() {
        sync()
    }

    deinit {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
    }
}
