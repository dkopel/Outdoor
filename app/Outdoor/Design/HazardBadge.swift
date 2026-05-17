import SwiftUI

/// Color-coded hazard level indicator. Used on first-aid and other safety
/// content to communicate severity at a glance.
struct HazardBadge: View {
    let level: HazardLevel

    private var tint: Color {
        switch level {
        case .low:      return OColor.hazardLow
        case .medium:   return OColor.hazardMedium
        case .high:     return OColor.hazardHigh
        case .critical: return OColor.hazardCritical
        }
    }

    private var icon: String {
        switch level {
        case .critical: return "exclamationmark.octagon.fill"
        case .high:     return "exclamationmark.triangle.fill"
        case .medium:   return "exclamationmark.circle.fill"
        case .low:      return "info.circle.fill"
        }
    }

    private var label: String {
        switch level {
        case .low:      return "Low risk"
        case .medium:   return "Caution"
        case .high:     return "High risk"
        case .critical: return "Critical"
        }
    }

    var body: some View {
        HStack(spacing: OSpace.xxs) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
            Text(label)
                .font(OType.labelS)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(tint.opacity(0.12), in: Capsule())
    }
}
