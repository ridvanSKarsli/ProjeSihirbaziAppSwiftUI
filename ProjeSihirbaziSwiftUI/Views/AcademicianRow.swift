import SwiftUI

struct AcademicianRow: View {
    var academician: Academician
    
    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.m) {
            // Avatar
            avatar
                .frame(width: 64, height: 64)
                .clipShape(Circle())
                .overlay(Circle().stroke(AppTheme.border, lineWidth: 1))
            
            // Metinler
            VStack(alignment: .leading, spacing: 4) {
                Text(academician.getName())
                    .font(.body.weight(.semibold))
                
                Text(academician.getUniversity())
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                
                // Etiketler
                HStack(spacing: 8) {
                    if !academician.getTitle().isEmpty {
                        tag(academician.getTitle())
                    }
                    if !academician.getSection().isEmpty {
                        tag(academician.getSection())
                    }
                }
                
                if !academician.getKeywords().isEmpty {
                    Text(academician.getKeywords())
                        .font(.footnote)
                        .foregroundStyle(AppTheme.primary)
                        .lineLimit(2)
                }
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Subviews
    private var avatar: some View {
        Group {
            if let url = URL(string: "https://projesihirbaziapi.enmdigital.com" + academician.getImageUrl()) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().controlSize(.small)
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        Image(systemName: "person.crop.circle.fill")
                            .resizable().scaledToFit()
                            .foregroundStyle(.secondary)
                    @unknown default:
                        Color.clear
                    }
                }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable().scaledToFit()
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private func tag(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(AppTheme.primary.opacity(0.10))
            .foregroundStyle(AppTheme.primary)
            .clipShape(Capsule())
    }
}
