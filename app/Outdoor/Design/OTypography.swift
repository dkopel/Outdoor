import SwiftUI

/// Typography tokens. SF Pro Display for display sizes, SF Pro Text for body.
/// Generous sizes — touch screens with cold hands.
enum OType {

    // Display — used for screen titles and big numbers.
    static let displayXL = Font.system(size: 40, weight: .bold, design: .default).leading(.tight)
    static let displayL  = Font.system(size: 32, weight: .bold, design: .default).leading(.tight)
    static let displayM  = Font.system(size: 26, weight: .semibold, design: .default).leading(.tight)

    // Headings — section titles, card titles.
    static let h1 = Font.system(size: 22, weight: .semibold).leading(.tight)
    static let h2 = Font.system(size: 19, weight: .semibold).leading(.tight)
    static let h3 = Font.system(size: 17, weight: .semibold).leading(.tight)

    // Body — prose, message text, descriptions.
    static let bodyLarge = Font.system(size: 18, weight: .regular).leading(.standard)
    static let body      = Font.system(size: 16, weight: .regular).leading(.standard)
    static let bodySmall = Font.system(size: 14, weight: .regular).leading(.standard)

    // Labels — buttons, chips, metadata.
    static let labelL = Font.system(size: 16, weight: .medium)
    static let labelM = Font.system(size: 14, weight: .medium)
    static let labelS = Font.system(size: 12, weight: .medium)

    // Caption — secondary metadata, timestamps.
    static let caption = Font.system(size: 12, weight: .regular)

    // Mono — for source citations, IDs.
    static let mono = Font.system(size: 12, weight: .regular, design: .monospaced)
}
