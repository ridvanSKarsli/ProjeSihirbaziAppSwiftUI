// ProjeSihirbaziAIDataAccess.swift
import Foundation

final class ProjeSihirbaziAIDataAccess: ProjeSihirbaziAIService {
    
    enum NetworkError: Error, LocalizedError {
        case invalidURL
        case noData
        case badStatus(Int)
        case decoding(String)
        case encoding(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Geçersiz URL."
            case .noData: return "Sunucudan veri alınamadı."
            case .badStatus(let code): return "Sunucu hatası: \(code)."
            case .decoding(let msg): return "Çözümleme hatası: \(msg)"
            case .encoding(let msg): return "JSON oluşturma hatası: \(msg)"
            }
        }
    }
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }
    
    // MARK: - Helpers
    
    private func makeRequest(
        url: URL,
        method: String,
        token: String,
        body: Data? = nil,
        timeout: TimeInterval = 15
    ) -> URLRequest {
        var req = URLRequest(url: url, timeoutInterval: timeout)
        req.httpMethod = method
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        if let body = body {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = body
        }
        return req
    }
    
    private func run<T: Decodable>(
        _ request: URLRequest,
        decode type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error { return completion(.failure(error)) }
                guard let http = response as? HTTPURLResponse else { return completion(.failure(NetworkError.noData)) }
                guard (200...299).contains(http.statusCode) else { return completion(.failure(NetworkError.badStatus(http.statusCode))) }
                guard let data = data else { return completion(.failure(NetworkError.noData)) }
                do {
                    let value = try self.decoder.decode(T.self, from: data)
                    completion(.success(value))
                } catch {
                    completion(.failure(NetworkError.decoding(error.localizedDescription)))
                }
            }
        }.resume()
    }
    
    private func runVoid(
        _ request: URLRequest,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        session.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error { return completion(.failure(error)) }
                guard let http = response as? HTTPURLResponse else { return completion(.failure(NetworkError.noData)) }
                guard (200...299).contains(http.statusCode) else { return completion(.failure(NetworkError.badStatus(http.statusCode))) }
                completion(.success(()))
            }
        }.resume()
    }
    
    // MARK: - API
    
    func getOldChat(projectId: Int, token: String, completion: @escaping (Result<[ProjeSihirbaziAI], Error>) -> Void) {
        guard let url = URL(string: APIEndpoints.getOldChatURL(id: projectId)) else {
            return completion(.failure(NetworkError.invalidURL))
        }
        let req = makeRequest(url: url, method: "GET", token: token)
        run(req, decode: [ProjeSihirbaziAI].self, completion: completion)
    }
    
    func createNewChat(projectId: Int, token: String, completion: @escaping (Result<ProjeSihirbaziAI, Error>) -> Void) {
        guard let url = URL(string: APIEndpoints.createNewChatURL(id: projectId)) else {
            return completion(.failure(NetworkError.invalidURL))
        }
        let req = makeRequest(url: url, method: "POST", token: token)
        run(req, decode: ProjeSihirbaziAI.self, completion: completion)
    }
    
    func deleteChat(token: String, chatId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: APIEndpoints.deleteChatURL(chatId: chatId)) else {
            return completion(.failure(NetworkError.invalidURL))
        }
        // Not: API'niz DELETE yerine GET kullanıyorsa aşağıyı "GET" bırakın.
        let req = makeRequest(url: url, method: "GET", token: token)
        session.dataTask(with: req) { _, response, error in
            DispatchQueue.main.async {
                if let error = error { return completion(.failure(error)) }
                guard let http = response as? HTTPURLResponse else { return completion(.failure(NetworkError.noData)) }
                if (200...299).contains(http.statusCode) {
                    completion(.success(true))
                } else {
                    completion(.failure(NetworkError.badStatus(http.statusCode)))
                }
            }
        }.resume()
    }
    
    func getChatWithId(projectId: Int, chatId: Int, token: String, completion: @escaping (Result<[ChatMessage], Error>) -> Void) {
        getOldChat(projectId: projectId, token: token) { result in
            switch result {
            case .failure(let err):
                completion(.failure(err))
            case .success(let chats):
                guard let chat = chats.first(where: { $0.id == chatId }) else {
                    return completion(.failure(NetworkError.noData))
                }
                guard let jsonData = chat.chatHistoryJson.data(using: .utf8) else {
                    return completion(.failure(NetworkError.decoding("chatHistoryJson geçersiz UTF-8")))
                }
                do {
                    let messages = try self.decoder.decode([ChatMessage].self, from: jsonData)
                    completion(.success(messages))
                } catch {
                    completion(.failure(NetworkError.decoding(error.localizedDescription)))
                }
            }
        }
    }
    
    func sendMessage(chatId: Int, message: String, token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: APIEndpoints.sendMessageURL.url) else {
            return completion(.failure(NetworkError.invalidURL))
        }
        let payload: [String: Any?] = [
            "chatId": chatId,
            "message": message,
            "fileInfo": nil
        ]
        do {
            let body = try JSONSerialization.data(withJSONObject: payload, options: [])
            let req = makeRequest(url: url, method: "POST", token: token, body: body)
            runVoid(req, completion: completion)
        } catch {
            completion(.failure(NetworkError.encoding(error.localizedDescription)))
        }
    }
}

struct ChatMessage: Codable, Identifiable, Equatable {
    let id = UUID()
    let sender: String
    let text: String
    let fileInfo: String?
    
    private enum CodingKeys: String, CodingKey {
        case sender = "Sender"
        case text = "Text"
        case fileInfo = "FileInfo"
    }
}
