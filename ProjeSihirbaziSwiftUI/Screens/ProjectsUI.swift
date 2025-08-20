import SwiftUI

struct ProjectsUI: View {
    var filtreDataAccess = FiltreManager()
    let projectsType: String
    
    @State private var projectsArr: [Projects] = []
    @State private var kurumlar: [String] = []
    @State private var sektorler: [String] = []
    @State private var basvuruDurumlari = ["Açık", "Yakında Açılacaklar", "Sürekli Açık"]
    @State private var siralamalar = ["Tarihe göre(Artan)", "Tarihe göre(Azalan)", "Ada göre(A-Z)", "Ada göre(Z-A)"]
    
    @State private var basvuruDurumlariAPI = ["AÇIK", "YAKINDA_AÇILACAK", "SÜREKLİ_AÇIK"]
    @State private var siralamalarAPI = ["date_desc", "date_asc", "name_asc", "name_desc"]
    
    @State private var currentPage = 1
    @State private var selectedAd: String = ""
    @State private var selectedSiralama: String = ""
    @State private var selectedKurum: String = ""
    @State private var selectedSektor: String = ""
    @State private var selectedDurum: String = ""
    @State private var isLoading: Bool = false
    @State private var totalPages: Int = 1
    @State private var showFilterSheet: Bool = false
    
    // SwiftUI alert
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        // DİKKAT: Burada NavigationStack KULLANMIYORUZ (kökte var)
        VStack(spacing: 0) {
            
            // Arama alanı (AppTheme ile)
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Ad ara", text: $selectedAd)
                    .textInputAutocapitalization(.never)
                    .onChange(of: selectedAd) { _, _ in
                        currentPage = 1
                        getProject()
                    }
                if !selectedAd.isEmpty {
                    Button {
                        selectedAd = ""
                        currentPage = 1
                        getProject()
                    } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12).padding(.vertical, 10)
            .background(AppTheme.surface)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.s, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.s, style: .continuous))
            .appPadding()
            .padding(.top, AppTheme.Spacing.m)
            
            // Liste
            ScrollView {
                VStack(spacing: AppTheme.Spacing.s) {
                    if isLoading {
                        ProgressView("Yükleniyor...")
                            .controlSize(.large)
                            .padding(.vertical, AppTheme.Spacing.l)
                    } else {
                        LazyVStack(spacing: AppTheme.Spacing.s) {
                            ForEach(projectsArr) { project in
                                ProjectRow(project: project, projectsType: projectsType)
                                    .padding(.horizontal, AppTheme.Spacing.l)
                            }
                        }
                        .refreshable { refreshData() }
                    }
                }
                .padding(.bottom, AppTheme.Spacing.l)
            }
            
            // Sayfalama
            HStack {
                Button {
                    guard currentPage > 1 else { return }
                    currentPage -= 1
                    getProject()
                } label: {
                    Image(systemName: "chevron.left").frame(width: 36, height: 36)
                }
                .buttonStyle(AppButtonStyle(kind: currentPage > 1 ? .secondary : .tertiary))
                .disabled(currentPage <= 1)
                
                Spacer()
                
                Text("Sayfa \(currentPage) / \(max(totalPages, 1))")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    guard currentPage < totalPages else { return }
                    currentPage += 1
                    getProject()
                } label: {
                    Image(systemName: "chevron.right").frame(width: 36, height: 36)
                }
                .buttonStyle(AppButtonStyle(kind: currentPage < totalPages ? .secondary : .tertiary))
                .disabled(currentPage >= totalPages)
            }
            .appPadding()
            .padding(.bottom, AppTheme.Spacing.m)
        }
        .appScreen(hideNavBar: false)
        .navigationTitle(projectsType)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showFilterSheet.toggle()
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.title3)
                        .foregroundStyle(AppTheme.primary)
                }
                .accessibilityLabel("Filtreler")
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterViewProject(
                selectedKurum: $selectedKurum,
                selectedSektor: $selectedSektor,
                selectedName: $selectedAd,
                selectedDurum: $selectedDurum,
                selectedSiralama: $selectedSiralama,
                kurumlar: kurumlar,
                sektorler: sektorler,
                basvuruDurumlari: basvuruDurumlari,
                siralamalar: siralamalar
            )
            .presentationDetents([.fraction(0.6)])
            .onDisappear {
                currentPage = 1
                getProject()
            }
        }
        .alert("Uyarı", isPresented: $showAlert) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            getProject()
            getSektorler()
            getKurumlar(tur: projectsType)
            performTokenRefresh()
        }
    }
    
    private func refreshData() {
        currentPage = 1
        getProject()
    }

    private func getProject() {
        let projectDataAccess = ProjectManager()
        let durumIndex = basvuruDurumlari.firstIndex(of: selectedDurum)
        let siralamaIndex = siralamalar.firstIndex(of: selectedSiralama)
        let durumAPIValue = durumIndex != nil ? basvuruDurumlariAPI[durumIndex!] : ""
        let siralamaAPIValue = siralamaIndex != nil ? siralamalarAPI[siralamaIndex!] : ""
        
        isLoading = true
        projectDataAccess.getProject(
            tur: projectsType,
            page: currentPage,
            sector: selectedSektor,
            search: selectedAd,
            status: durumAPIValue,
            company: selectedKurum,
            sortOrder: siralamaAPIValue
        ) { projevts, totalPages, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    alertMessage = error
                    showAlert = true
                } else if let projects = projevts, let totalPages = totalPages {
                    self.projectsArr = projects
                    self.totalPages = max(totalPages, 1)
                }
            }
        }
    }

    private func getKurumlar(tur: String) {
        filtreDataAccess.getKurumlar(tur: tur) { kurumlar in
            DispatchQueue.main.async { self.kurumlar = kurumlar }
        }
    }

    private func getSektorler() {
        filtreDataAccess.getSektorler { sektorler in
            DispatchQueue.main.async { self.sektorler = sektorler }
        }
    }
    
    private func performTokenRefresh() {
        // Not: Projende UserDataAccess kullanıyorsun, ona dokunmadım
        let userDataAccess = UserDataAccess()
        userDataAccess.refreshToken { success in
            print(success ? "Token başarıyla yenilendi." : "Token yenileme başarısız.")
        }
    }
}

#Preview {
    ProjectsUI(projectsType: "İhale")
}
