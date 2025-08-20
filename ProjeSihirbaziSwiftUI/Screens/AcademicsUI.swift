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
        // DİKKAT: Burada NavigationStack YOK (kökte var)
        VStack(spacing: AppTheme.Spacing.m) {
            // Arama (AppTheme ile)
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
            
            // Liste
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
            
            // Sayfalama
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
        ) { academics, error, total in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    print("Hata: \(error)")
                } else if let academics = academics {
                    self.academicsArr = academics
                    self.totalPages = max(total ?? 1, 1)
                }
            }
        }
    }

    private func getIl() {
        filtreDataAccess.getIl { iller in
            DispatchQueue.main.async { self.iller = iller }
        }
    }

    private func getUni() {
        filtreDataAccess.getUni { universities in
            DispatchQueue.main.async { self.universiteler = universities }
        }
    }

    private func getKeyword() {
        filtreDataAccess.getKeyword { keys in
            DispatchQueue.main.async { self.anahtarKelimeler = keys }
        }
    }
}

#Preview { AcademicsUI() }
