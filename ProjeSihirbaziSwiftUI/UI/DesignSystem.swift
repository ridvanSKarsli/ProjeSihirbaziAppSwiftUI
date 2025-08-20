import SwiftUI

// MARK: - App Theme Tokens
enum AppTheme {
    // Asset’te varsa onları kullan, yoksa fallback
    static var primary: Color { Color("App/Primary", default: Color.accentColor) }
    static var secondary: Color { Color("App/Secondary", default: Color.blue.opacity(0.18)) }
    static var background: Color { Color("App/Background", default: Color(.systemBackground)) }
    static var surface: Color { Color("App/Surface", default: Color(.secondarySystemBackground)) }
    static var onPrimary: Color { Color("App/OnPrimary", default: .white) }
    static var border: Color { Color("App/Border", default: Color.primary.opacity(0.08)) }

    enum Radius { static let s: CGFloat = 10; static let m: CGFloat = 14; static let l: CGFloat = 20 }
    enum Spacing { static let xs: CGFloat = 8; static let s: CGFloat = 12; static let m: CGFloat = 16; static let l: CGFloat = 24; static let xl: CGFloat = 32 }
    enum Shadow {
        static let soft = ShadowStyle(radius: 18, x: 0, y: 8, opacity: 0.12)
        static let none = ShadowStyle(radius: 0, x: 0, y: 0, opacity: 0)
        struct ShadowStyle { let radius, x, y: CGFloat; let opacity: CGFloat }
    }
}

// Asset yoksa fallback veren yardımcı init
extension Color {
    init(_ name: String, bundle: Bundle = .main, default fallback: Color) {
        if UIColor(named: name, in: bundle, compatibleWith: nil) != nil { self = Color(name, bundle: bundle) }
        else { self = fallback }
    }
}
