import SwiftUI

struct AcademicianRow: View {
    var academician: Academician
    
    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.m) {
            avatar
                .frame(width: 64, height: 64)
                .clipShape(Circle())
                .overlay(Circle().stroke(AppTheme.border, lineWidth: 1))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(academician.name)  // Direct access to 'name'
                    .font(.body.weight(.semibold))
                
                Text(academician.university)  // Direct access to 'university'
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 8) {
                    if !academician.title.isEmpty {
                        tag(academician.title)  // Direct access to 'title'
                    }
                    if !academician.section.isEmpty {
                        tag(academician.section)  // Direct access to 'section'
                    }
                }
                
                if !academician.keywords.isEmpty {
                    Text(academician.keywords)  // Direct access to 'keywords'
                        .font(.footnote)
                        .foregroundStyle(AppTheme.primary)
                        .lineLimit(2)
                }
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private var avatar: some View {
        Group {
            if let url = URL(string: "https://projesihirbaziapi.enmdigital.com" + academician.imageUrl) {  // Direct access to 'imageUrl'
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
