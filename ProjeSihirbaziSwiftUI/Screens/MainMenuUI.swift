import SwiftUI

struct MainMenuUI: View {
    // Data
    @State private var grantCount: Int = 0
    @State private var academicianCount: Int = 0
    @State private var tenderCount: Int = 0
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showProfileSheet: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.l) {
                
                // Başlık
                Text("Ana Menü")
                    .font(.largeTitle.weight(.semibold))
                    .padding(.top, AppTheme.Spacing.l)
                
                // İstatistikler (küçük kartlar)
                HStack(spacing: AppTheme.Spacing.m) {
                    StatCard(title: "Hibe", value: grantCount, systemImage: "doc.text.fill")
                    StatCard(title: "Akademisyen", value: academicianCount, systemImage: "person.2.fill")
                    StatCard(title: "İhale", value: tenderCount, systemImage: "doc.plaintext")
                }
                
                // Hızlı Erişim
                AppSectionHeader(title: "Hızlı Erişim")
                AppCard {
                    VStack(spacing: 0) {
                        NavigationLink {
                            ProjectsUI(projectsType: "Hibe")
                        } label: {
                            AppListRow(
                                title: "Hibe Projeleri",
                                subtitle: "\(grantCount) kayıt",
                                icon: "doc.text.fill"
                            )
                        }
                        Divider()
                        NavigationLink {
                            AcademicsUI()
                        } label: {
                            AppListRow(
                                title: "Akademisyenler",
                                subtitle: "\(academicianCount) kişi",
                                icon: "person.fill"
                            )
                        }
                        Divider()
                        NavigationLink {
                            ProjectsUI(projectsType: "İhale")
                        } label: {
                            AppListRow(
                                title: "İhale Projeleri",
                                subtitle: "\(tenderCount) kayıt",
                                icon: "doc.plaintext"
                            )
                        }
                    }
                }
            }
            .appPadding()
        }
        .appScreen(hideNavBar: false)
        .navigationTitle("Ana Menü") // Üst NavigationStack (BeforeLoginUI) tarafından gösterilir
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showProfileSheet.toggle() } label: {
                    Image(systemName: "person.crop.circle")
                        .font(.title2)
                        .foregroundStyle(AppTheme.primary)
                }
                .accessibilityLabel("Profil")
            }
        }
        .sheet(isPresented: $showProfileSheet) {
            ProfileUI()
        }
        .alert("Uyarı", isPresented: $showAlert) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            UserDefaults.standard.set(0, forKey: "selectedChatId")
            getDashboardData()
        }
    }
    
    // MARK: Data
    private func getDashboardData() {
        let dashboardDataAccess = DashboardManager()
        dashboardDataAccess.fetchDashboardData { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let dashboard):
                    grantCount = dashboard.grantCount
                    academicianCount = dashboard.academicianCount
                    tenderCount = dashboard.tenderCount
                case .failure(let error):
                    alertMessage = "Veriler alınamadı. Hata: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}

// MARK: - Küçük İstatistik Kartı (yerel alt view)
private struct StatCard: View {
    let title: String
    let value: Int
    let systemImage: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.primary)
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Text("\(value)")
                .font(.title2.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.Spacing.m)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.m, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.m, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }
}
