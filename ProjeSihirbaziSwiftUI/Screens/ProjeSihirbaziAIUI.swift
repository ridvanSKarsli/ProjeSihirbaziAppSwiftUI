// ProjeSihirbaziAIUI.swift
import SwiftUI
import UIKit

// MARK: - ViewModel
@MainActor
final class ProjeSihirbaziAIViewModel: ObservableObject {
    // Outputs
    @Published var messageText: String = ""
    @Published var chat: [ChatMessage] = []
    @Published var chatId: Int = 0
    @Published var chats: [ProjeSihirbaziAI] = []
    
    // UI State
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var showOldChats = false
    @Published var isLoading = false
    @Published var isSending = false
    
    // Inputs
    private let projectId: Int
    private let service: ProjeSihirbaziAIService
    private var token: String { UserDefaults.standard.string(forKey: "accessToken") ?? "" }
    
    init(projectId: Int, service: ProjeSihirbaziAIService = ProjeSihirbaziAIManager()) {
        self.projectId = projectId
        self.service = service
        if let storedId = UserDefaults.standard.value(forKey: "selectedChatId") as? Int {
            self.chatId = storedId
        }
    }
    
    // MARK: Lifecycle
    func onAppear() {
        guard !token.isEmpty, chatId != 0 else { return }
        getChatWithId(id: chatId)
    }
    
    func refresh() {
        guard !token.isEmpty, chatId != 0 else { return }
        chat.removeAll()
        getChatWithId(id: chatId)
    }
    
    // MARK: Old Chats
    func openOldChats() {
        showOldChats = true
        loadOldChats()
    }
    
    func tapOldChat(_ item: ProjeSihirbaziAI) {
        chatId = item.id
        UserDefaults.standard.set(chatId, forKey: "selectedChatId")
        getChatWithId(id: chatId)
        showOldChats = false
    }
    
    func createNewChat() {
        guard !token.isEmpty else { inform("Oturum bulunamadı.") ; return }
        isLoading = true
        service.createNewChat(projectId: projectId, token: token) { [weak self] result in
            guard let self else { return }
            self.isLoading = false
            switch result {
            case .success(let newChat):
                self.chatId = newChat.id
                UserDefaults.standard.set(self.chatId, forKey: "selectedChatId")
                self.showOldChats = false
                self.getChatWithId(id: self.chatId)   // ✅ yeni sohbet açılınca otomatik içine gidiyor
            case .failure(let error):
                self.inform("Yeni sohbet oluşturulamadı.\n\(error.localizedDescription)")
            }
        }
    }
    
    func deleteChat(at offsets: IndexSet) {
        guard let idx = offsets.first, chats.indices.contains(idx) else { return }
        let item = chats[idx]
        guard !token.isEmpty else { inform("Oturum bulunamadı.") ; return }
        
        isLoading = true
        service.deleteChat(token: token, chatId: item.id) { [weak self] result in
            guard let self else { return }
            self.isLoading = false
            switch result {
            case .success:
                self.chats.remove(at: idx)
                if self.chatId == item.id {
                    self.chatId = 0
                    UserDefaults.standard.removeObject(forKey: "selectedChatId")
                    self.chat.removeAll()
                }
            case .failure(let error):
                self.inform("Sohbet silinemedi.\n\(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Send
    func sendMessageClicked() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        if chatId == 0 {
            createNewChatAndSend()
        } else {
            sendMessage()
        }
    }
    
    private func createNewChatAndSend() {
        guard !token.isEmpty else { inform("Oturum bulunamadı.") ; return }
        isSending = true
        service.createNewChat(projectId: projectId, token: token) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let newChat):
                self.chatId = newChat.id
                UserDefaults.standard.set(self.chatId, forKey: "selectedChatId")
                self.sendMessage()
            case .failure(let error):
                self.isSending = false
                self.inform("Yeni sohbet oluşturulamadı.\n\(error.localizedDescription)")
            }
        }
    }
    
    private func sendMessage() {
        guard !token.isEmpty else { inform("Oturum bulunamadı.") ; return }
        let payload = messageText
        isSending = true
        service.sendMessage(chatId: chatId, message: payload, token: token) { [weak self] result in
            guard let self else { return }
            self.isSending = false
            switch result {
            case .success:
                self.messageText = ""          // ✅ gönderince temizle
                self.dismissKeyboard()
                self.getChatWithId(id: self.chatId) // gönderim sonrası yenile
            case .failure(let error):
                self.inform("Mesaj gönderilemedi.\n\(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Fetch
    private func loadOldChats() {
        guard !token.isEmpty else { inform("Oturum bulunamadı.") ; return }
        isLoading = true
        service.getOldChat(projectId: projectId, token: token) { [weak self] result in
            guard let self else { return }
            self.isLoading = false
            switch result {
            case .success(let list):
                self.chats = list
            case .failure(let error):
                self.inform("Eski sohbetler alınamadı.\n\(error.localizedDescription)")
            }
        }
    }
    
    private func getChatWithId(id: Int) {
        guard !token.isEmpty else { inform("Oturum bulunamadı.") ; return }
        isLoading = true
        service.getChatWithId(projectId: projectId, chatId: id, token: token) { [weak self] result in
            guard let self else { return }
            self.isLoading = false
            switch result {
            case .success(let messages):
                self.chat = messages
            case .failure(let error):
                self.inform("Sohbet yüklenemedi.\n\(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Utils
    private func inform(_ message: String) {
        alertMessage = message
        showAlert = true
    }
    
    private func dismissKeyboard() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first(where: { $0.isKeyWindow }) {
            window.endEditing(true)
        }
    }
}

// MARK: - View
struct ProjeSihirbaziAIUI: View {
    @StateObject private var vm: ProjeSihirbaziAIViewModel
    
    init(projectId: Int) {
        _vm = StateObject(wrappedValue: ProjeSihirbaziAIViewModel(projectId: projectId))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Mesaj Listesi
            if vm.chat.isEmpty && !vm.isLoading {
                emptyState
            } else {
                List {
                    ForEach(vm.chat, id: \.id) { item in
                        ChatBubbleView(message: item)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .padding(.vertical, 2)
                    }
                }
                .listStyle(.plain)
                .overlay {
                    if vm.isLoading && vm.chat.isEmpty {
                        ProgressView().controlSize(.large)
                    }
                }
                .refreshable { vm.refresh() }
            }
            
            // Giriş Çubuğu
            inputBar
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 10)
                .background(.ultraThinMaterial)
                .overlay(Divider(), alignment: .top)
        }
        .background(LinearGradient(
            gradient: Gradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)]),
            startPoint: .top, endPoint: .bottom
        ))
        .onAppear { vm.onAppear() }
        .navigationTitle("Sohbet")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    vm.openOldChats()
                } label: {
                    Label("Sohbetler", systemImage: "text.bubble")
                }
                .accessibilityLabel("Sohbetler")
            }
        }
        .alert(isPresented: $vm.showAlert) {
            Alert(title: Text("Bilgi"),
                  message: Text(vm.alertMessage),
                  dismissButton: .default(Text("Tamam")))
        }
        .sheet(isPresented: $vm.showOldChats) { oldChatsSheet }
    }
    
    // MARK: - Subviews
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("Henüz mesaj yok")
                .font(.headline)
                .foregroundColor(.primary)
            Text("Bir mesaj yazarak sohbete başlayabilirsin.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var inputBar: some View {
        HStack(spacing: 10) {
            HStack {
                Image(systemName: "rectangle.and.pencil.and.ellipsis")
                    .foregroundColor(.secondary)
                TextField("Mesajınızı yazın…", text: $vm.messageText)
                    .textInputAutocapitalization(.sentences)
                    .disableAutocorrection(false)
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(
                Capsule()
                    .fill(Color(.secondarySystemBackground))
            )
            
            Button(action: vm.sendMessageClicked) {
                HStack(spacing: 6) {
                    if vm.isSending {
                        ProgressView().controlSize(.small)
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                    Text("Gönder")
                        .fontWeight(.semibold)
                        .minimumScaleFactor(0.8)
                }
                .padding(.horizontal, 14)
                .frame(height: 44)
                .background(
                    Capsule().fill(
                        vm.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isSending
                        ? Color.blue.opacity(0.4)
                        : Color.blue
                    )
                )
                .foregroundColor(.white)
            }
            .disabled(vm.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isSending)
        }
        .animation(.easeInOut(duration: 0.15), value: vm.isSending)
        .animation(.easeInOut(duration: 0.15), value: vm.messageText)
    }
    
    private var oldChatsSheet: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if vm.isLoading && vm.chats.isEmpty {
                    ProgressView().padding()
                }
                List {
                    Section {
                        ForEach(vm.chats, id: \.id) { item in
                            Button {
                                vm.tapOldChat(item)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "bubble.left.fill")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 16, weight: .semibold))
                                        .frame(width: 34, height: 34)
                                        .background(Circle().fill(Color.blue))
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Chat #\(item.id)")
                                            .font(.headline)
                                        Text(item.createdDateTime)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 6)
                            }
                        }
                        .onDelete(perform: vm.deleteChat)
                    } header: {
                        Text("Sohbet Geçmişi")
                    }
                }
                .listStyle(.insetGrouped)
                
                Button {
                    vm.createNewChat()
                } label: {
                    HStack {
                        Spacer()
                        Label("Yeni Sohbet Oluştur", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .padding(.vertical, 12)
                        Spacer()
                    }
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding([.horizontal, .bottom])
                }
                .disabled(vm.isLoading)
            }
            .navigationTitle("Eski Sohbetler")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { EditButton() }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Chat Bubble
private struct ChatBubbleView: View {
    let message: ChatMessage
    
    var isUser: Bool {
        message.sender.lowercased() == "user"
    }
    
    var body: some View {
        HStack {
            if isUser { Spacer() }   // ✅ Kullanıcı mesajı için boşluk sola
            
            Text(message.text)
                .font(.body)
                .foregroundColor(isUser ? .white : .primary)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isUser ? Color.blue : Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(isUser ? Color.blue.opacity(0.4) : Color.black.opacity(0.05), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: isUser ? .trailing : .leading)
            
            if !isUser { Spacer() }  // ✅ AI mesajı için boşluk sağa
        }
        .padding(.horizontal)
        .padding(.vertical, 2)
    }
}


// MARK: - Preview
struct ProjeSihirbaziAIView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProjeSihirbaziAIUI(projectId: 90914)
        }
    }
}
