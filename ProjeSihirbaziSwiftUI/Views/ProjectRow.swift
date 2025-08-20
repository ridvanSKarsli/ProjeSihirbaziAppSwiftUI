import SwiftUI

struct ProjectRow: View {
    var project: Projects
    var projectsType: String
    @State private var navigateToAIWizard = false

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.m) {
                
                // Görsel
                if let url = URL(string: "https://projesihirbaziapi.enmdigital.com/" + project.getResim()) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                Rectangle().fill(AppTheme.surface)
                                ProgressView()
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.s))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.s)
                                    .stroke(AppTheme.border, lineWidth: 1)
                            )
                        case .success(let image):
                            image.resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.s))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.s)
                                        .stroke(AppTheme.border, lineWidth: 1)
                                )
                        case .failure:
                            HStack(spacing: 8) {
                                Image(systemName: "photo").foregroundStyle(.secondary)
                                Text("Görsel yüklenemedi").foregroundStyle(.secondary)
                            }
                            .frame(height: 160)
                        @unknown default:
                            Color.clear.frame(height: 160)
                        }
                    }
                }
                
                // Metin içerik
                VStack(alignment: .leading, spacing: 6) {
                    Text(project.getAd())
                        .font(.headline)
                        .lineLimit(3)
                    
                    Text(project.getKurum())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        if !project.getBasvuruDurumu().isEmpty {
                            pill(project.getBasvuruDurumu())
                        }
                        if !project.getSektorler().isEmpty {
                            pill(project.getSektorler())
                        }
                    }
                    
                    if !project.getEklenmeTarihi().isEmpty {
                        Text(project.getEklenmeTarihi())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // CTA’lar
                HStack(spacing: AppTheme.Spacing.m) {
                    Button("Detay / Başvuru Linki") {
                        if let url = URL(string: project.getBasvuruLinki()) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .buttonStyle(AppButtonStyle(kind: .secondary))
                    
                    if projectsType == "Hibe" {
                        Button("Yapay Zeka ile Konuş") {
                            navigateToAIWizard = true
                        }
                        .buttonStyle(AppButtonStyle(kind: .primary))
                        .navigationDestination(isPresented: $navigateToAIWizard) {
                            ProjeSihirbaziAIUI(projectId: project.getId())
                        }
                    }
                }
            }
        }
        .contentShape(Rectangle()) // Kartın boş alanı da tıklanabilir olsun
        .onTapGesture {
            if let url = URL(string: project.getBasvuruLinki()) {
                UIApplication.shared.open(url)
            }
        }
        .padding(.vertical, AppTheme.Spacing.s)
    }
    
    // küçük kapsül etiket
    private func pill(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(AppTheme.primary.opacity(0.10))
            .foregroundStyle(AppTheme.primary)
            .clipShape(Capsule())
    }
}
