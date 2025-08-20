import SwiftUI

struct FilterViewAcedemician: View {
    @Binding var selectedUniversity: String
    @Binding var selectedProvince: String
    @Binding var selectedKeywords: String
    
    var iller: [String]
    var universiteler: [String]
    var anahtarKelimeler: [String]

    @State private var searchUniversity: String = ""
    @State private var searchProvince: String = ""
    @State private var searchKeywords: String = ""
    
    @State private var showUniversityDropdown: Bool = false
    @State private var showProvinceDropdown: Bool = false
    @State private var showKeywordsDropdown: Bool = false
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.l) {
                    
                    // Üniversite
                    AppCard {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.m) {
                            Text("Üniversite")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                            
                            searchField(placeholder: "Üniversite ara",
                                        text: $searchUniversity,
                                        isOpen: $showUniversityDropdown)
                            
                            if showUniversityDropdown {
                                listBox(items: filteredUniversities) { value in
                                    selectedUniversity = value
                                    searchUniversity = value
                                    showUniversityDropdown = false
                                }
                            } else if !selectedUniversity.isEmpty {
                                selectedPill(text: selectedUniversity) { selectedUniversity = "" }
                            }
                        }
                    }
                    
                    // İl
                    AppCard {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.m) {
                            Text("İl")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                            
                            searchField(placeholder: "İl ara",
                                        text: $searchProvince,
                                        isOpen: $showProvinceDropdown)
                            
                            if showProvinceDropdown {
                                listBox(items: filteredProvinces) { value in
                                    selectedProvince = value
                                    searchProvince = value
                                    showProvinceDropdown = false
                                }
                            } else if !selectedProvince.isEmpty {
                                selectedPill(text: selectedProvince) { selectedProvince = "" }
                            }
                        }
                    }
                    
                    // Anahtar kelime
                    AppCard {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.m) {
                            Text("Anahtar Kelime")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                            
                            searchField(placeholder: "Anahtar kelime ara",
                                        text: $searchKeywords,
                                        isOpen: $showKeywordsDropdown)
                            
                            if showKeywordsDropdown {
                                listBox(items: filteredKeywords) { value in
                                    selectedKeywords = value
                                    searchKeywords = value
                                    showKeywordsDropdown = false
                                }
                            } else if !selectedKeywords.isEmpty {
                                selectedPill(text: selectedKeywords) { selectedKeywords = "" }
                            }
                        }
                    }
                    
                    // Butonlar
                    HStack(spacing: AppTheme.Spacing.m) {
                        Button("Temizle") {
                            selectedUniversity = ""
                            selectedProvince = ""
                            selectedKeywords = ""
                            searchUniversity = ""
                            searchProvince = ""
                            searchKeywords = ""
                        }
                        .buttonStyle(AppButtonStyle(kind: .secondary))
                        
                        Button("Uygula") {
                            dismiss()
                        }
                        .buttonStyle(AppButtonStyle(kind: .primary))
                    }
                }
                .appPadding()
                .padding(.top, AppTheme.Spacing.m)
            }
            .navigationTitle("Filtreler")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }
                        .buttonStyle(AppButtonStyle(kind: .tertiary))
                }
            }
        }
    }
    
    // MARK: - Reusable subviews
    private func searchField(placeholder: String, text: Binding<String>, isOpen: Binding<Bool>) -> some View {
        HStack(spacing: 8) {
            TextField(placeholder, text: text)
                .textInputAutocapitalization(.never)
                .padding(.horizontal, 12).padding(.vertical, 10)
                .background(AppTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.s)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.s))
            
            Button {
                withAnimation { isOpen.wrappedValue.toggle() }
            } label: {
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isOpen.wrappedValue ? 180 : 0))
            }
            .buttonStyle(AppButtonStyle(kind: .tertiary))
        }
    }
    
    private func listBox(items: [String], onPick: @escaping (String) -> Void) -> some View {
        VStack(spacing: 0) {
            ForEach(items.prefix(50), id: \.self) { item in
                Button {
                    onPick(item)
                } label: {
                    HStack {
                        Text(item).foregroundStyle(.primary)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                if item != items.prefix(50).last {
                    Divider()
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(AppTheme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.s)
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.s))
        .frame(maxHeight: 180)
    }
    
    private func selectedPill(text: String, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.caption)
            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(AppTheme.primary.opacity(0.10))
        .foregroundStyle(AppTheme.primary)
        .clipShape(Capsule())
    }
    
    // MARK: - Filters
    private var filteredUniversities: [String] {
        searchUniversity.isEmpty ? universiteler
        : universiteler.filter { $0.localizedCaseInsensitiveContains(searchUniversity) }
    }
    private var filteredProvinces: [String] {
        searchProvince.isEmpty ? iller
        : iller.filter { $0.localizedCaseInsensitiveContains(searchProvince) }
    }
    private var filteredKeywords: [String] {
        searchKeywords.isEmpty ? anahtarKelimeler
        : anahtarKelimeler.filter { $0.localizedCaseInsensitiveContains(searchKeywords) }
    }
}
