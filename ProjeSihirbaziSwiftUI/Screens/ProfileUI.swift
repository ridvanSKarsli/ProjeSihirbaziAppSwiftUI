import SwiftUI
import UIKit

struct ProfileUI: View {
    @State private var profileImage: UIImage? = nil
    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var newPassword: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var imagePickerPresented: Bool = false
    @State private var isLogOut: Bool = false
    @State private var isLoading: Bool = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.l) {
                    
                    // Profil resmi
                    VStack {
                        if let image = profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(AppTheme.border, lineWidth: 1))
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .foregroundStyle(AppTheme.primary.opacity(0.7))
                        }
                    }
                    .onTapGesture { imagePickerPresented = true }
                    .padding(.top, AppTheme.Spacing.l)
                    
                    // Kullanıcı bilgileri kartı
                    AppCard {
                        VStack(spacing: AppTheme.Spacing.m) {
                            field(title: "Ad", text: $name)
                            field(title: "Soyad", text: $surname)
                            field(title: "E-posta", text: $email, disabled: true)
                            field(title: "Telefon", text: $phone)
                            SecureField("Yeni Şifre", text: $newPassword)
                                .padding(.horizontal, 14).padding(.vertical, 12)
                                .background(AppTheme.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.s)
                                        .stroke(AppTheme.border, lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.s))
                        }
                    }
                    
                    // Güncelle butonu
                    Button("Güncelle") { updateUserData() }
                        .buttonStyle(AppButtonStyle(kind: .primary))
                    
                    // Çıkış butonu
                    Button("Çıkış Yap") {
                        logOut()
                        isLogOut = true
                    }
                    .buttonStyle(AppButtonStyle(kind: .destructive))
                    
                    Spacer(minLength: AppTheme.Spacing.l)
                }
                .appPadding()
            }
            .appScreen(hideNavBar: false)
            .navigationTitle("Profil")
            .alert("Uyarı", isPresented: $showAlert) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $imagePickerPresented) {
                ImagePicker(selectedImage: $profileImage)
            }
            .fullScreenCover(isPresented: $isLogOut) {
                BeforeLoginUI()
                    .navigationBarBackButtonHidden(true)
            }
            .onAppear {
                isLoading = true
                performTokenRefresh()
                if let token = UserDefaults.standard.string(forKey: "accessToken") {
                    getUserData(token: token)
                }
            }
        }
    }
    
    // MARK: - Custom field
    private func field(title: String, text: Binding<String>, disabled: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
            TextField("", text: text)
                .disabled(disabled)
                .padding(.horizontal, 14).padding(.vertical, 12)
                .background(AppTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.s)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.s))
        }
    }
    
    // MARK: - Data ops
    private func getUserData(token: String) {
        let userDataAccess = UserManager()
        userDataAccess.getUserData(token: token) { fetchedUser in
            DispatchQueue.main.async {
                if let u = fetchedUser {
                    name = u.getName()
                    surname = u.getSurname()
                    email = u.getEmail()
                    phone = u.getPhone()
                    if let url = URL(string: u.getImageFile() ?? "") {
                        loadImage(from: url)
                    }
                } else {
                    alertMessage = "Kullanıcı verileri alınamadı."
                    showAlert = true
                }
            }
        }
    }
    
    private func updateUserData() {
        let userDataAccess = UserManager()
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            userDataAccess.updateUserData(token: token, name: name, surname: surname, imageFile: "", password: newPassword) { updatedUser in
                DispatchQueue.main.async {
                    if let updated = updatedUser {
                        name = updated.getName()
                        surname = updated.getSurname()
                        email = updated.getEmail()
                        phone = updated.getPhone()
                        alertMessage = "Kullanıcı bilgileri başarıyla güncellendi."
                    } else {
                        alertMessage = "Güncelleme başarısız."
                    }
                    showAlert = true
                }
            }
        }
    }
    
    private func logOut() {
        UserDefaults.standard.removeObject(forKey: "refreshToken")
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async { self.profileImage = image }
            }
        }.resume()
    }
    
    private func performTokenRefresh() {
        let userDataAccess = UserManager()
        userDataAccess.refreshToken { success in
            print(success ? "Token başarıyla yenilendi." : "Token yenileme başarısız.")
        }
    }
}

#Preview
{
    ProfileUI()
}
