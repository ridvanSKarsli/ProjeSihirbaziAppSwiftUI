import SwiftUI

struct ProjeSihirbaziAIUI: View {
    let projectId: Int
    let projeSihirbaziAIDataAccess = ProjeSihirbaziAIDataAccess()
    
    @State private var messageText: String = ""
    @State private var chat: [ChatMessage] = []
    @State private var chatId: Int = 0
    @State private var token: String = ""
    @State private var chats: [ProjeSihirbaziAI] = [] // Eski sohbetler
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showOldChats = false  // Eski sohbetler ekranını kontrol eden bayrak
    
    var body: some View {
        VStack {
            // Mesaj listesi
            List {
                ForEach(chat, id: \.id) { chatMessage in
                    chatBubble(chatMessage)
                        .id(chatMessage.id)
                }
            }
            .listStyle(.plain)
            .refreshable {
                refreshData()
            }
            
            // Mesaj yazma ve gönderme kısmı
            messageInputBar
        }
        .onAppear {
            if chatId != 0, let token = UserDefaults.standard.string(forKey: "accessToken") {
                self.token = token
                getChatWithId(token: token, id: chatId)
            }
        }
        .navigationTitle("Sohbet")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Sohbetler") {
                    self.showOldChats.toggle()
                    if let token = UserDefaults.standard.string(forKey: "accessToken") {
                        self.token = token
                        getOldChats(token: token)
                    }
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Hata"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("Tamam")))
        }
        .sheet(isPresented: $showOldChats) {
            oldChatsSheet
        }
    }
    
    // MARK: - Subviews
    
    private func chatBubble(_ message: ChatMessage) -> some View {
        HStack {
            if message.sender == "user" { Spacer() }
            
            Text(message.text)
                .padding()
                .background(message.sender == "user" ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 3)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
            
            if message.sender != "user" { Spacer() }
        }
        .padding(.vertical, 4)
    }
    
    private var messageInputBar: some View {
        HStack {
            TextField("Mesajınızı giriniz", text: $messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(height: 45)
            
            Button(action: sendMessageClicked) {
                Text("Gönder")
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 6)
    }
    
    private var oldChatsSheet: some View {
        VStack {
            Text("Eski Sohbetler")
                .font(.title2.bold())
                .padding(.top)
            
            List {
                ForEach(chats, id: \.id) { chat in
                    Button {
                        self.chatId = chat.getId()
                        getChatWithId(token: token, id: chatId)
                        self.showOldChats = false
                    } label: {
                        HStack {
                            Text("Chat \(chat.getCreatedDateTime())")
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                }
                .onDelete(perform: deleteChat)
            }
            
            Button("Yeni Sohbet Oluştur") {
                createNewChat()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .presentationDetents([.medium, .large])
    }
    
    // MARK: - Actions
    
    private func sendMessageClicked() {
        guard !messageText.isEmpty else { return }
        askToAI()
    }
    
    private func askToAI() {
        if chatId == 0 {
            if let token = UserDefaults.standard.string(forKey: "accessToken") {
                projeSihirbaziAIDataAccess.createNewChat(projectId: projectId, token: token) { chat in
                    if let chat = chat {
                        DispatchQueue.main.async {
                            self.chatId = chat.getId()
                            UserDefaults.standard.set(self.chatId, forKey: "selectedChatId")
                            self.sendMessage(token: token)
                        }
                    }
                }
            }
        } else {
            if let token = UserDefaults.standard.string(forKey: "accessToken") {
                sendMessage(token: token)
            }
        }
    }
    
    private func sendMessage(token: String) {
        projeSihirbaziAIDataAccess.sendMessage(chatId: chatId, message: messageText, token: token)
        getChatWithId(token: token, id: chatId)
        messageText = ""
        dismissKeyboard()
    }
    
    private func createNewChat() {
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            projeSihirbaziAIDataAccess.createNewChat(projectId: projectId, token: token) { chat in
                if let chat = chat {
                    DispatchQueue.main.async {
                        self.chatId = chat.getId()
                        UserDefaults.standard.set(self.chatId, forKey: "selectedChatId")
                        self.sendMessage(token: token)
                        self.showOldChats = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.alertMessage = "Yeni sohbet oluşturulamadı."
                        self.showAlert = true
                    }
                }
            }
        }
    }
    
    private func getChatWithId(token: String, id: Int) {
        projeSihirbaziAIDataAccess.getChatWithId(projectId: projectId, chatId: id, token: token) { chatWithId in
            if let chat = chatWithId {
                DispatchQueue.main.async {
                    self.chat = chat
                }
            }
        }
    }
    
    private func getOldChats(token: String) {
        projeSihirbaziAIDataAccess.getOldChat(projectId: projectId, token: token) { chat in
            if let chat = chat {
                DispatchQueue.main.async {
                    self.chats = chat
                }
            }
        }
    }
    
    private func deleteChat(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        let chat = chats[index]
        
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            projeSihirbaziAIDataAccess.deleteChat(token: token, chatId: chat.getId()) { success in
                DispatchQueue.main.async {
                    if success {
                        self.chats.remove(at: index)
                    } else {
                        self.alertMessage = "Sohbet silinemedi"
                        self.showAlert = true
                    }
                }
            }
        }
    }
    
    private func refreshData() {
        if let selectedChatIdUserDefaul = UserDefaults.standard.value(forKey: "selectedChatId") as? Int {
            chatId = selectedChatIdUserDefaul
        }
        
        if chatId != 0 {
            if let token = UserDefaults.standard.string(forKey: "accessToken") {
                self.token = token
                chat.removeAll()
                getChatWithId(token: token, id: chatId)
            }
        }
    }
    
    private func dismissKeyboard() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = scene.windows.first(where: { $0.isKeyWindow }) {
                window.endEditing(true)
            }
        }
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
