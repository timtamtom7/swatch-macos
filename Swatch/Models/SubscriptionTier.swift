import Foundation

/// R16: Subscription tiers for Swatch
public enum SwatchSubscriptionTier: String, Codable, CaseIterable {
    case free = "free"
    case pro = "pro"
    case team = "team"
    
    public var displayName: String {
        switch self { case .free: return "Free"; case .pro: return "Swatch Pro"; case .team: return "Swatch Team" }
    }
    public var monthlyPrice: Decimal? {
        switch self { case .free: return nil; case .pro: return 3.99; case .team: return 7.99 }
    }
    public var maxPalettes: Int? {
        switch self { case .free: return 10; case .pro: return nil; case .team: return nil }
    }
    public var supportsColorBlindness: Bool { self != .free }
    public var supportsExportFormats: Bool { self != .free }
    public var supportsShortcuts: Bool { self != .free }
    public var supportsWidgets: Bool { self != .free }
    public var supportsAccessibility: Bool { self == .pro || self == .team }
    public var supportsTeamSharing: Bool { self == .team }
    public var trialDays: Int { self == .free ? 0 : 14 }
}

public struct SwatchSubscription: Codable {
    public let tier: SwatchSubscriptionTier
    public let status: String
    public let expiresAt: Date?
    public init(tier: SwatchSubscriptionTier, status: String = "active", expiresAt: Date? = nil) {
        self.tier = tier; self.status = status; self.expiresAt = expiresAt
    }
}
