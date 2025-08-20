import SwiftUI

// MARK: - Button
struct AppButtonStyle: ButtonStyle {
    enum Kind { case primary, secondary, tertiary, destructive }
    var kind: Kind = .primary
    
    func makeBody(configuration: Configuration) -> some View {
        switch kind {
        case .primary:
            configuration.label
                .font(.headline)
                .frame(maxWidth: .infinity).padding(.vertical, 14)
                .foregroundStyle(AppTheme.onPrimary)
                .background(AppTheme.primary)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.m, style: .continuous))
                .opacity(configuration.isPressed ? 0.88 : 1)
                .scaleEffect(configuration.isPressed ? 0.98 : 1)
            
        case .secondary:
            configuration.label
                .font(.headline)
                .frame(maxWidth: .infinity).padding(.vertical, 14)
                .foregroundStyle(AppTheme.primary)
                .background(AppTheme.primary.opacity(0.12))
                .overlay(RoundedRectangle(cornerRadius: AppTheme.Radius.m, style: .continuous)
                    .stroke(AppTheme.primary.opacity(0.25), lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.m, style: .continuous))
            
        case .tertiary:
            configuration.label
                .font(.headline)
                .padding(.vertical, 10)
                .foregroundStyle(AppTheme.primary)
            
        case .destructive:
            configuration.label
                .font(.headline)
                .frame(maxWidth: .infinity).padding(.vertical, 14)
                .foregroundStyle(.white)
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.m, style: .continuous))
                .opacity(configuration.isPressed ? 0.88 : 1)
                .scaleEffect(configuration.isPressed ? 0.98 : 1)
        }
    }
}

// MARK: - Card
struct AppCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.m) { content }
            .padding(AppTheme.Spacing.l)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.l, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: AppTheme.Radius.l, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1))
    }
}

// MARK: - TextField
struct AppTextField: View {
    let title: String
    @Binding var text: String
    var isSecure: Bool = false
    @FocusState private var focused: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.footnote.weight(.semibold)).foregroundStyle(.secondary)
            Group {
                if isSecure { SecureField("", text: $text).textContentType(.password) }
                else { TextField("", text: $text) }
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .background(AppTheme.surface)
            .overlay(RoundedRectangle(cornerRadius: AppTheme.Radius.s, style: .continuous)
                .stroke(focused ? AppTheme.primary.opacity(0.6) : AppTheme.border, lineWidth: focused ? 1.2 : 1))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.s, style: .continuous))
            .focused($focused)
        }
        .animation(.easeInOut(duration: 0.15), value: focused)
    }
}

// MARK: - List Row
struct AppListRow: View {
    var title: String
    var subtitle: String? = nil
    var icon: String? = nil
    var body: some View {
        HStack(spacing: AppTheme.Spacing.m) {
            if let icon { Image(systemName: icon).frame(width: 28).foregroundStyle(.secondary) }
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.body.weight(.semibold))
                if let subtitle { Text(subtitle).font(.footnote).foregroundStyle(.secondary) }
            }
            Spacer()
            Image(systemName: "chevron.right").font(.footnote).foregroundStyle(.tertiary)
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Section Header
struct AppSectionHeader: View {
    var title: String
    var body: some View {
        Text(title.uppercased())
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 2)
    }
}
