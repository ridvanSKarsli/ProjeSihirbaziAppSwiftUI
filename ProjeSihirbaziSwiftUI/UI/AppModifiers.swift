import SwiftUI

struct AppBackground: View { // gradient yerine sade, dark/light uyumlu
    var body: some View { AppTheme.background.ignoresSafeArea() }
}

struct AppScreenModifier: ViewModifier {
    var hideNavBar: Bool = true
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppBackground())
            .toolbar(hideNavBar ? .hidden : .automatic, for: .navigationBar)
    }
}

extension View {
    func appScreen(hideNavBar: Bool = true) -> some View { modifier(AppScreenModifier(hideNavBar: hideNavBar)) }
    func appPadding() -> some View { padding(.horizontal, AppTheme.Spacing.l) }
}
