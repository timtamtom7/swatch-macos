import Foundation
import StoreKit

/// R16: Subscription management for Swatch
@available(macOS 13.0, *)
public final class SwatchSubscriptionManager: ObservableObject {
    public static let shared = SwatchSubscriptionManager()
    @Published public private(set) var subscription: SwatchSubscription?
    @Published public private(set) var products: [Product] = []
    
    private init() {}
    
    public func loadProducts() async {
        do {
            products = try await Product.products(for: [
                "com.swatch.macos.pro.monthly",
                "com.swatch.macos.pro.yearly",
                "com.swatch.macos.team.monthly",
                "com.swatch.macos.team.yearly"
            ])
        } catch { print("Failed to load products") }
    }
    
    public func canAccess(_ feature: SwatchFeature) -> Bool {
        guard let sub = subscription else { return false }
        switch feature {
        case .colorBlindness: return sub.tier != .free
        case .exportFormats: return sub.tier != .free
        case .shortcuts: return sub.tier != .free
        case .widgets: return sub.tier != .free
        case .accessibility: return sub.tier == .pro || sub.tier == .team
        case .teamSharing: return sub.tier == .team
        }
    }
    
    public func updateStatus() async {
        var found: SwatchSubscription = SwatchSubscription(tier: .free)
        for await result in Transaction.currentEntitlements {
            do {
                let t = try checkVerified(result)
                if t.productID.contains("team") {
                    found = SwatchSubscription(tier: .team, status: t.revocationDate == nil ? "active" : "expired")
                } else if t.productID.contains("pro") {
                    found = SwatchSubscription(tier: .pro, status: t.revocationDate == nil ? "active" : "expired")
                }
            } catch { continue }
        }
        await MainActor.run { self.subscription = found }
    }
    
    public func restore() async throws {
        try await AppStore.sync()
        await updateStatus()
    }
    
    private func checkVerified<T>(_ r: VerificationResult<T>) throws -> T {
        switch r { case .unverified: throw NSError(domain: "Swatch", code: -1); case .verified(let s): return s }
    }
}

public enum SwatchFeature { case colorBlindness, exportFormats, shortcuts, widgets, accessibility, teamSharing }
