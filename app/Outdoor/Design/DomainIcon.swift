import SwiftUI

/// SF Symbol mapped to each pack content domain, in the domain's tint.
struct DomainIcon: View {
    let domain: String
    var size: CGFloat = 28

    private var symbol: String {
        switch domain {
        case "first-aid":    return "cross.case.fill"
        case "knots":        return "link"
        case "water":        return "drop.fill"
        case "shelter":      return "house.lodge.fill"
        case "fire":         return "flame.fill"
        case "navigation":   return "location.north.line.fill"
        case "wildlife":     return "pawprint.fill"
        case "plants":       return "leaf.fill"
        case "weather":      return "cloud.bolt.rain.fill"
        case "food":         return "fork.knife"
        case "gear-fixes":   return "wrench.adjustable.fill"
        case "trip-basics":  return "backpack.fill"
        default:             return "circle.dotted"
        }
    }

    var body: some View {
        let tint = OColor.domainTint(domain)
        return Image(systemName: symbol)
            .font(.system(size: size * 0.46, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: size * 0.32, style: .continuous))
    }
}

extension String {
    /// Title-case a domain key for display ("first-aid" → "First Aid").
    var domainDisplayName: String {
        self.split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
}
