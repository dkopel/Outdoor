import SwiftUI

// MARK: - OCard

/// A surface with soft elevation. The standard container for grouped content.
struct OCard<Content: View>: View {
    var padding: CGFloat = OSpace.m
    var tint: Color = OColor.surface
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(tint, in: RoundedRectangle(cornerRadius: ORadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ORadius.card, style: .continuous)
                    .strokeBorder(OColor.separator, lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 8, y: 2)
    }
}

// MARK: - OButton styles

enum OButtonKind {
    case primary    // ember, used for the most important action on a screen
    case secondary  // surface w/ border, for non-destructive secondary actions
    case ghost      // text-only, for tertiary actions
    case destructive
}

struct OButtonStyle: ButtonStyle {
    var kind: OButtonKind = .primary
    var size: Size = .regular
    var fullWidth: Bool = false

    enum Size {
        case compact, regular, large
        var height: CGFloat {
            switch self { case .compact: 36; case .regular: 48; case .large: 56 }
        }
        var hPadding: CGFloat {
            switch self { case .compact: 14; case .regular: 18; case .large: 22 }
        }
        var font: Font {
            switch self { case .compact: OType.labelM; case .regular: OType.labelL; case .large: OType.h3 }
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        let bg: Color = {
            switch kind {
            case .primary:     return OColor.ember
            case .secondary:   return OColor.surface
            case .ghost:       return .clear
            case .destructive: return OColor.hazardCritical
            }
        }()
        let fg: Color = {
            switch kind {
            case .primary:     return .white
            case .secondary:   return OColor.text
            case .ghost:       return OColor.text
            case .destructive: return .white
            }
        }()
        let border: Color = kind == .secondary ? OColor.separator : .clear

        return configuration.label
            .font(size.font)
            .foregroundStyle(fg)
            .padding(.horizontal, size.hPadding)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(height: size.height)
            .background(bg, in: RoundedRectangle(cornerRadius: ORadius.button, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ORadius.button, style: .continuous)
                    .strokeBorder(border, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(OMotion.snappy, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == OButtonStyle {
    static func o(_ kind: OButtonKind = .primary,
                  size: OButtonStyle.Size = .regular,
                  fullWidth: Bool = false) -> OButtonStyle {
        OButtonStyle(kind: kind, size: size, fullWidth: fullWidth)
    }
}

// MARK: - Pill / chip

struct OPill: View {
    var icon: String? = nil
    var text: String
    var tint: Color = OColor.spruce
    var filled: Bool = false

    var body: some View {
        HStack(spacing: OSpace.xxs) {
            if let icon { Image(systemName: icon).font(.system(size: 11, weight: .semibold)) }
            Text(text).font(OType.labelS).lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .foregroundStyle(filled ? .white : tint)
        .background(
            (filled ? tint : tint.opacity(0.10))
                .clipShape(Capsule())
        )
    }
}

// MARK: - Section header

struct OSectionHeader: View {
    let title: String
    var trailing: String? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(OType.h2)
                .foregroundStyle(OColor.text)
            Spacer(minLength: 0)
            if let trailing {
                Text(trailing)
                    .font(OType.labelM)
                    .foregroundStyle(OColor.textSecondary)
            }
        }
        .padding(.horizontal, OSpace.m)
    }
}
