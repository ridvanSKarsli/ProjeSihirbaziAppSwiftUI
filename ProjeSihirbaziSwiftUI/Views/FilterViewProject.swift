import SwiftUI

struct FilterViewProject: View {
    @Binding var selectedKurum: String
    @Binding var selectedSektor: String
    @Binding var selectedName: String
    @Binding var selectedDurum: String
    @Binding var selectedSiralama: String
    
    var kurumlar: [String] = []
    var sektorler: [String] = []
    var basvuruDurumlari: [String] = []
    var siralamalar: [String] = []
    
    @State private var searchKurum: String = ""
    @State private var searchSektor: String = ""
    @State private var showKurumDropdown: Bool = false
    @State private var showSektorDropdown: Bool = false
    @State private var showDurumDropdown: Bool = false
    @State private var showSiralamaDropdown: Bool = false
    
    @Environment(\.dismiss) private var dismiss
       
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.l) {
                    
                    // Kurum
                    AppCard {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.m) {
                            Text("Kurum").font(.footnote.weight(.semibold)).foregroundStyle(.secondary)
                            searchField(placeholder: "Kurum ara", text: $searchKurum, isOpen: $showKurumDropdown)
                            if showKurumDropdown {
                                listBox(items: filteredKurumlar) { value in
                                    selectedKurum = value
                                    searchKurum = value
                                    showKurumDropdown = false
                                }
                            } else if !selectedKurum.isEmpty {
                                selectedPill(text: selectedKurum) { selectedKurum = "" }
                            }
                        }
                    }
                    
                    // Sektör
                    AppCard {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.m) {
                            Text("Sektör").font(.footnote.weight(.semibold)).foregroundStyle(.secondary)
                            searchField(placeholder: "Sektör ara", text: $searchSektor, isOpen: $showSektorDropdown)
                            if showSektorDropdown {
                                listBox(items: filteredSektorler) { value in
                                    selectedSektor = value
                                    searchSektor = value
                                    showSektorDropdown = false
                                }
                            } else if !selectedSektor.isEmpty {
                                selectedPill(text: selectedSektor) { selectedSektor = "" }
                            }
                        }
                    }
                    
                    // Başvuru durumu
                    AppCard {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.m) {
                            Text("Başvuru Durumu").font(.footnote.weight(.semibold)).foregroundStyle(.secondary)
                            selectorRow(title: selectedDurum.isEmpty ? "Başvuru durumu seçin" : selectedDurum,
                                        isOpen: $showDurumDropdown)
                            if showDurumDropdown {
                                pickerList(items: basvuruDurumlari) { value in
                                    selectedDurum = value
                                    showDurumDropdown = false
                                }
                            }
                        }
                    }
                    
                    // Sıralama
                    AppCard {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.m) {
                            Text("Sıralama").font(.footnote.weight(.semibold)).foregroundStyle(.secondary)
                            selectorRow(title: selectedSiralama.isEmpty ? "Sıralama seçin" : selectedSiralama,
                                        isOpen: $showSiralamaDropdown)
                            if showSiralamaDropdown {
                                pickerList(items: siralamalar) { value in
                                    selectedSiralama = value
                                    showSiralamaDropdown = false
                                }
                            }
                        }
                    }
                    
                    // Butonlar
                    HStack(spacing: AppTheme.Spacing.m) {
                        Button("Temizle") {
                            selectedKurum = ""
                            selectedSektor = ""
                            selectedDurum = ""
                            selectedSiralama = ""
                            selectedName = ""
                            searchKurum = ""
                            searchSektor = ""
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
    
    // MARK: - Reusable pieces
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
    
    private func selectorRow(title: String, isOpen: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .foregroundColor(title.contains("seçin") ? .gray : .primary)
            Spacer()
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(isOpen.wrappedValue ? 180 : 0))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.s)
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.s))
        .onTapGesture {
            withAnimation { isOpen.wrappedValue.toggle() }
        }
    }
    
    private func listBox(items: [String], onPick: @escaping (String) -> Void) -> some View {
        VStack(spacing: 0) {
            ForEach(items.prefix(50), id: \.self) { item in
                Button {
                    onPick(item)
                } label: {
                    HStack { Text(item); Spacer() }
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                if item != items.prefix(50).last { Divider() }
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
    
    private func pickerList(items: [String], onPick: @escaping (String) -> Void) -> some View {
        VStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                Button {
                    onPick(item)
                } label: {
                    HStack { Text(item); Spacer() }
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                if item != items.last { Divider() }
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
        .frame(maxHeight: 220)
    }
    
    private func selectedPill(text: String, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: 6) {
            Text(text).font(.caption)
            Button { onRemove() } label: { Image(systemName: "xmark.circle.fill") }
                .buttonStyle(.plain)
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(AppTheme.primary.opacity(0.10))
        .foregroundStyle(AppTheme.primary)
        .clipShape(Capsule())
    }
    
    // MARK: - Filters
    private var filteredKurumlar: [String] {
        searchKurum.isEmpty ? kurumlar
        : kurumlar.filter { $0.localizedCaseInsensitiveContains(searchKurum) }
    }
    private var filteredSektorler: [String] {
        searchSektor.isEmpty ? sektorler
        : sektorler.filter { $0.localizedCaseInsensitiveContains(searchSektor) }
    }
}
