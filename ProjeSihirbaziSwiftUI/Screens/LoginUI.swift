import SwiftUI

struct LoginUI: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToHome: Bool = false
    @State private var isPasswordVisible: Bool = false
    @State private var showForgotPassword: Bool = false
    @State private var forgotPasswordEmail: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        // BURADA NavigationStack YOK
        ScrollView {
            VStack(spacing: AppTheme.Spacing.l) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.top, AppTheme.Spacing.xl)
                    .accessibilityHidden(true)
                
                Text("Giriş Yap")
                    .font(.largeTitle.weight(.semibold))
                    .padding(.bottom, AppTheme.Spacing.m)
                
                // Email
                VStack(alignment: .leading, spacing: 6) {
                    Text("E-posta")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                    TextField("", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .padding(.horizontal, 14).padding(.vertical, 12)
                        .background(AppTheme.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.s)
                                .stroke(AppTheme.border, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.s))
                }
                
                // Password
                VStack(alignment: .leading, spacing: 6) {
                    Text("Şifre")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                    HStack {
                        if isPasswordVisible {
                            TextField("", text: $password).textInputAutocapitalization(.never)
                        } else {
                            SecureField("", text: $password)
                        }
                        Button { isPasswordVisible.toggle() } label: {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 12)
                    .background(AppTheme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.s)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.s))
                }
                
                // Giriş Yap
                Button("Giriş Yap", action: login)
                    .buttonStyle(AppButtonStyle(kind: .primary))
                    .navigationDestination(isPresented: $navigateToHome) {
                        MainMenuUI() // DİKKAT: MainMenuUI içinde de NavigationStack yok
                    }
                
                // Şifremi Unuttum
                Button("Şifremi Unuttum?") { showForgotPassword = true }
                    .buttonStyle(AppButtonStyle(kind: .tertiary))
                    .font(.footnote)
                
                Spacer(minLength: AppTheme.Spacing.l)
            }
            .appPadding()
        }
        .appScreen(hideNavBar: false)
        .navigationTitle("Giriş Yap")
        .alert("Uyarı", isPresented: $showAlert) {
            Button("Tamam", role: .cancel) {}
        } message: { Text(alertMessage) }
        .overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ProgressView("Yükleniyor...")
                        .controlSize(.large)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordSheet(email: $forgotPasswordEmail) { message in
                showAlert(message: message)
            }
            .presentationDetents([.fraction(0.5)]) // iOS 15+ uyumlu
        }
    }
    
    private func login() {
        let userDataAccess = UserManager()
        isLoading = true
        userDataAccess.logIn(email: email, password: password) { success in
            DispatchQueue.main.async {
                isLoading = false
                if success {
                    navigateToHome = true
                } else {
                    showAlert(message: "Giriş başarısız. Lütfen bilgilerinizi kontrol edin.")
                }
            }
        }
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}

// Şifremi Unuttum Sheet
struct ForgotPasswordSheet: View {
    @Binding var email: String
    var onSubmit: (String) -> Void
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.m) {
            Text("Şifremi Unuttum").font(.title2.weight(.semibold))
            TextField("E-posta", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .padding(.horizontal, 14).padding(.vertical, 12)
                .background(AppTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.s)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.s))
            Button("Gönder") {
                let manager = UserManager()
                manager.forgetPassword(email: email) { message in
                    onSubmit(message)
                }
            }
            .buttonStyle(AppButtonStyle(kind: .primary))
            Button("İptal") { }
                .buttonStyle(AppButtonStyle(kind: .tertiary))
        }
        .appPadding()
    }
}
