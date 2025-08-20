import SwiftUI

struct BeforeLoginUI: View {
    @State private var isLoginActive = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.Spacing.xl) {
                Spacer(minLength: AppTheme.Spacing.l)
                
                // Logo + başlık
                VStack(spacing: AppTheme.Spacing.s) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .accessibilityHidden(true)
                    Text("Proje Sihirbazı")
                        .font(.largeTitle.weight(.semibold))
                }
                .appPadding()
                
                Text("Hesabınla giriş yaparak kişiselleştirilmiş deneyime geç.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .appPadding()
                
                AppCard {
                    VStack(spacing: AppTheme.Spacing.m) {
                        Button("Giriş Yap") { isLoginActive = true }
                            .buttonStyle(AppButtonStyle(kind: .primary))
                        Button("Gizlilik ve Koşullar") { /* legal */ }
                            .buttonStyle(AppButtonStyle(kind: .tertiary))
                            .font(.footnote)
                    }
                }
                .appPadding()
                
                Spacer()
                Text("© \(Calendar.current.component(.year, from: Date())) ENM Digital")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, AppTheme.Spacing.s)
            }
            .appScreen()
            .navigationDestination(isPresented: $isLoginActive) {
                LoginUI() // DİKKAT: LoginUI içinde NavigationStack yok
                    .toolbarTitleDisplayMode(.inline)
            }
        }
    }
}
