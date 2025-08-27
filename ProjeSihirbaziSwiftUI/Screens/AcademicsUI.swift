import SwiftUI

struct AcademicsUI: View {
    let filtreDataAccess = FiltreManager()
    
    @State private var currentPage = 1
    @State private var selectedName = ""
    @State private var selectedProvince = ""
    @State private var selectedUniversity = ""
    @State private var selectedKeywords = ""
    @State private var academicsArr: [Academician] = []
    @State private var iller: [String] = []
    @State private var universiteler: [String] = []
    @State private var anahtarKelimeler: [String] = []
    @State private var isLoading: Bool = false
    @State private var showFilterSheet = false
    @State private var totalPages = 1
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.m) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Ad ara", text: $selectedName)
                    .textInputAutocapitalization(.never)
                    .onChange(of: selectedName) { _, _ in
                        currentPage = 1
                        getAcademics()
                    }
                if !selectedName.isEmpty {
                    Button {
                        selectedName = ""
                        currentPage = 1
                        getAcademics()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
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
            
            ScrollView {
                VStack(spacing: AppTheme.Spacing.s) {
                    if isLoading {
                        ProgressView("Yükleniyor...")
                            .controlSize(.large)
                            .padding(.vertical, AppTheme.Spacing.l)
                    } else {
                        LazyVStack(spacing: AppTheme.Spacing.s) {
                            ForEach(academicsArr, id: \.name) { academician in
                                AcademicianRow(academician: academician)
                                    .padding(.horizontal, AppTheme.Spacing.l)
                            }
                        }
                        .refreshable { refreshData() }
                    }
                }
                .padding(.bottom, AppTheme.Spacing.l)
            }
            
            HStack {
                Button {
                    guard currentPage > 1 else { return }
                    currentPage -= 1
                    getAcademics()
                } label: {
                    Image(systemName: "chevron.left")
                        .frame(width: 36, height: 36)
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
                    getAcademics()
                } label: {
                    Image(systemName: "chevron.right")
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(AppButtonStyle(kind: currentPage < totalPages ? .secondary : .tertiary))
                .disabled(currentPage >= totalPages)
            }
            .appPadding()
            .padding(.bottom, AppTheme.Spacing.m)
        }
        .appScreen(hideNavBar: false)
        .navigationTitle("Akademisyenler")
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
            FilterViewAcedemician(
                selectedUniversity: $selectedUniversity,
                selectedProvince: $selectedProvince,
                selectedKeywords: $selectedKeywords,
                iller: iller,
                universiteler: universiteler,
                anahtarKelimeler: anahtarKelimeler
            )
            .presentationDetents([.fraction(0.6)])
            .onDisappear {
                currentPage = 1
                getAcademics()
            }
        }
        .onAppear {
            getAcademics()
            getIl()
            getUni()
            getKeyword()
        }
    }
    
    private func refreshData() {
        currentPage = 1
        getAcademics()
    }

    private func getAcademics() {
        let academicianDataAccess = AcademicianManager()
        isLoading = true
        academicianDataAccess.getAcademics(
            currentPage: currentPage,
            selectedName: selectedName,
            selectedProvince: selectedProvince,
            selectedUniversity: selectedUniversity,
            selectedKeywords: selectedKeywords
        ) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let (academics, totalPages)):
                    self.academicsArr = academics
                    self.totalPages = totalPages
                case .failure(let error):
                    print("Hata: \(error)")
                }
            }
        }
    }

    private func getIl() {
        filtreDataAccess.getIl { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let iller):
                    self.iller = iller  // Success durumunda illeri alıyoruz
                case .failure(let error):
                    print("Hata: \(error.localizedDescription)")  // Hata durumunda hata mesajını yazdırıyoruz
                    self.iller = []  // Hata durumunda iller dizisini boş bırakıyoruz
                }
            }
        }
    }

    private func getUni() {
        filtreDataAccess.getUni { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let universities):
                    self.universiteler = universities  // Success durumunda üniversiteleri alıyoruz
                case .failure(let error):
                    print("Hata: \(error.localizedDescription)")  // Hata durumunda hata mesajını yazdırıyoruz
                    self.universiteler = []  // Hata durumunda üniversiteler dizisini boş bırakıyoruz
                }
            }
        }
    }

    private func getKeyword() {
        filtreDataAccess.getKeyword { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let keys):
                    self.anahtarKelimeler = keys  // Success durumunda anahtar kelimeleri alıyoruz
                case .failure(let error):
                    print("Hata: \(error.localizedDescription)")  // Hata durumunda hata mesajını yazdırıyoruz
                    self.anahtarKelimeler = []  // Hata durumunda anahtar kelimeler dizisini boş bırakıyoruz
                }
            }
        }
    }
}
