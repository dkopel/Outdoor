import SwiftUI

/// Hero card for an installed pack — used at the top of the Packs tab.
struct InstalledPackCard: View {
    let pack: InstalledPack
    let isActive: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: OSpace.s) {
                HStack(spacing: OSpace.s) {
                    ZStack {
                        LinearGradient(
                            colors: [OColor.spruce, OColor.spruce.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        Image(systemName: "tent.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(pack.manifest.displayName)
                                .font(OType.h2)
                                .foregroundStyle(OColor.text)
                            if isActive {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(OColor.spruce)
                            }
                        }
                        Text("v\(pack.manifest.version) · \(pack.manifest.chunkCount) chunks · \(pack.manifest.sourceCount) sources")
                            .font(OType.caption)
                            .foregroundStyle(OColor.textSecondary)
                    }
                    Spacer(minLength: 0)
                }

                Text(pack.manifest.tagline)
                    .font(OType.body)
                    .foregroundStyle(OColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                FlowLayout(spacing: OSpace.xxs, lineSpacing: OSpace.xxs) {
                    ForEach(pack.manifest.domains, id: \.self) { d in
                        OPill(text: d.domainDisplayName, tint: OColor.domainTint(d))
                    }
                }
                .padding(.top, 2)

                HStack(spacing: OSpace.xs) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(OColor.spruce)
                    Text("Offline-ready")
                        .font(OType.labelS)
                        .foregroundStyle(OColor.spruce)
                    Spacer(minLength: 0)
                    Text("Active")
                        .font(OType.labelS)
                        .foregroundStyle(isActive ? .white : OColor.textSecondary)
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(isActive ? OColor.spruce : OColor.surfaceMuted,
                                    in: Capsule())
                }
                .padding(.top, OSpace.xs)
            }
            .padding(OSpace.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(OColor.surface, in: RoundedRectangle(cornerRadius: ORadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ORadius.card, style: .continuous)
                    .strokeBorder(
                        isActive ? OColor.spruce.opacity(0.4) : OColor.separator,
                        lineWidth: isActive ? 1.5 : 0.5
                    )
            )
            .shadow(color: Color.black.opacity(0.05), radius: 12, y: 4)
        }
        .buttonStyle(.plain)
    }
}

/// Tease card for a pack not yet shipped.
struct AvailablePackCard: View {
    let preview: PackPreview

    var tintColor: Color {
        Color(hex: parseHex(preview.tint))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: OSpace.s) {
            HStack(spacing: OSpace.s) {
                ZStack {
                    tintColor.opacity(0.14)
                    Image(systemName: preview.symbol)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(tintColor)
                }
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(preview.displayName)
                        .font(OType.h3)
                        .foregroundStyle(OColor.text)
                    Text("Coming soon")
                        .font(OType.caption)
                        .foregroundStyle(OColor.textTertiary)
                }
                Spacer(minLength: 0)
                Image(systemName: "lock.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(OColor.textTertiary)
            }
            Text(preview.description)
                .font(OType.bodySmall)
                .foregroundStyle(OColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(3)
        }
        .padding(OSpace.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(OColor.surface, in: RoundedRectangle(cornerRadius: ORadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ORadius.card, style: .continuous)
                .strokeBorder(OColor.separator, lineWidth: 0.5)
                .opacity(0.6)
        )
        .opacity(0.85)
    }

    private func parseHex(_ s: String) -> UInt32 {
        let cleaned = s.replacingOccurrences(of: "#", with: "")
        return UInt32(cleaned, radix: 16) ?? 0
    }
}

// MARK: - Tiny flow layout

/// Wraps children to multiple lines like CSS flex-wrap.
struct FlowLayout: Layout {
    var spacing: CGFloat = 6
    var lineSpacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0
        for sv in subviews {
            let sz = sv.sizeThatFits(.unspecified)
            if x + sz.width > width {
                x = 0
                y += lineHeight + lineSpacing
                lineHeight = 0
            }
            x += sz.width + spacing
            lineHeight = max(lineHeight, sz.height)
        }
        return CGSize(width: width, height: y + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0
        for sv in subviews {
            let sz = sv.sizeThatFits(.unspecified)
            if x + sz.width > bounds.maxX {
                x = bounds.minX
                y += lineHeight + lineSpacing
                lineHeight = 0
            }
            sv.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(sz))
            x += sz.width + spacing
            lineHeight = max(lineHeight, sz.height)
        }
    }
}
