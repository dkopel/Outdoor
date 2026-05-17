import SwiftUI

/// 4-pt spacing grid. Use these tokens everywhere instead of magic numbers.
enum OSpace {
    static let xxs: CGFloat = 4
    static let xs:  CGFloat = 8
    static let s:   CGFloat = 12
    static let m:   CGFloat = 16
    static let l:   CGFloat = 20
    static let xl:  CGFloat = 28
    static let xxl: CGFloat = 40
    static let xxxl: CGFloat = 56
}

/// Corner radius tokens. Modern, soft — never bubbly.
enum ORadius {
    static let chip: CGFloat = 10
    static let button: CGFloat = 14
    static let card: CGFloat = 18
    static let sheet: CGFloat = 24
    static let pill: CGFloat = 999
}

/// Motion tokens.
enum OMotion {
    static let soft = Animation.spring(response: 0.4, dampingFraction: 0.85)
    static let snappy = Animation.spring(response: 0.28, dampingFraction: 0.78)
    static let gentle = Animation.easeInOut(duration: 0.22)
}
