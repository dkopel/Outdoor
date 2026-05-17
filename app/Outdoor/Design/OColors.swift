import SwiftUI

/// Outdoor palette — warm, confident, outdoor-without-the-cliché.
///
/// Designed to feel like dawn over a ridge: cream, forest, ember accent.
/// Adapts to dark mode (deep warm dark, never pure black).
enum OColor {

    // MARK: Surfaces

    /// App background — warm off-white in light, deep warm-dark in dark.
    static let background = Color(light: 0xF5F1EA, dark: 0x191E1C)

    /// Cards, sheets, elevated surfaces.
    static let surface = Color(light: 0xFFFFFF, dark: 0x232927)

    /// Subtle surface for grouped backgrounds.
    static let surfaceMuted = Color(light: 0xEFEAE1, dark: 0x1F2523)

    /// Hairline separators.
    static let separator = Color(light: 0xE2DCD0, dark: 0x2F3633)

    // MARK: Foreground

    /// Primary text — near-black with warmth.
    static let text = Color(light: 0x1F2A24, dark: 0xEFE9DD)

    /// Secondary text.
    static let textSecondary = Color(light: 0x5C6962, dark: 0xA8AFA8)

    /// Tertiary text / placeholders / disabled.
    static let textTertiary = Color(light: 0x8E988F, dark: 0x767D77)

    // MARK: Brand

    /// Spruce — deep evergreen. Primary brand color.
    static let spruce = Color(light: 0x2D4A3E, dark: 0x4A7A66)

    /// Lichen — muted moss accent for secondary actions and tags.
    static let lichen = Color(light: 0x6E8A5E, dark: 0x9DB58A)

    /// Ember — warm accent for primary CTAs, focused states.
    static let ember = Color(light: 0xD97757, dark: 0xE8895C)

    /// Sky — soft blue for informational states (rare).
    static let sky = Color(light: 0x5B8DA8, dark: 0x86B3CC)

    // MARK: Hazard

    /// Low risk — calm green-ish.
    static let hazardLow = Color(light: 0x6E8A5E, dark: 0x9DB58A)

    /// Medium risk — amber, gentle warning.
    static let hazardMedium = Color(light: 0xD9A24A, dark: 0xE8B669)

    /// High risk — ember/red-orange.
    static let hazardHigh = Color(light: 0xC75D3A, dark: 0xE0764C)

    /// Critical — saturated red, used sparingly.
    static let hazardCritical = Color(light: 0xA8331E, dark: 0xC74F37)

    // MARK: Domain tints — used for domain icons + filters

    static func domainTint(_ domain: String) -> Color {
        switch domain {
        case "first-aid":    return hazardHigh
        case "knots":        return Color(light: 0x8A6E4A, dark: 0xB3946B)
        case "water":        return Color(light: 0x4A86A8, dark: 0x7AB0CC)
        case "shelter":      return Color(light: 0x6E5A8A, dark: 0xA08AC0)
        case "fire":         return ember
        case "navigation":   return Color(light: 0x4A6E8A, dark: 0x7A9AB8)
        case "wildlife":     return Color(light: 0x6E5A3A, dark: 0xB89A6A)
        case "plants":       return lichen
        case "weather":      return sky
        case "food":         return Color(light: 0x8A6E5A, dark: 0xB89A82)
        case "gear-fixes":   return Color(light: 0x6E6E6E, dark: 0xA0A0A0)
        case "trip-basics":  return spruce
        default:             return textSecondary
        }
    }
}

// MARK: - Color hex helper

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }

    init(light: UInt32, dark: UInt32) {
        #if canImport(UIKit)
        let ui = UIColor { trait in
            let hex = trait.userInterfaceStyle == .dark ? dark : light
            let r = CGFloat((hex >> 16) & 0xFF) / 255.0
            let g = CGFloat((hex >> 8) & 0xFF) / 255.0
            let b = CGFloat(hex & 0xFF) / 255.0
            return UIColor(red: r, green: g, blue: b, alpha: 1.0)
        }
        self.init(uiColor: ui)
        #else
        self.init(hex: light)
        #endif
    }
}
