// ProjeSihirbaziAIManager.swift
import Foundation

final class ProjeSihirbaziAIManager: ProjeSihirbaziAIService {
    private let dataAccess: ProjeSihirbaziAIDataAccess
    
    init(dataAccess: ProjeSihirbaziAIDataAccess = .init()) {
        self.dataAccess = dataAccess
    }
    
    func getOldChat(projectId: Int, token: String, completion: @escaping (Result<[ProjeSihirbaziAI], Error>) -> Void) {
        dataAccess.getOldChat(projectId: projectId, token: token, completion: completion)
    }
    
    func createNewChat(projectId: Int, token: String, completion: @escaping (Result<ProjeSihirbaziAI, Error>) -> Void) {
        dataAccess.createNewChat(projectId: projectId, token: token, completion: completion)
    }
    
    func deleteChat(token: String, chatId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        dataAccess.deleteChat(token: token, chatId: chatId, completion: completion)
    }
    
    func getChatWithId(projectId: Int, chatId: Int, token: String, completion: @escaping (Result<[ChatMessage], Error>) -> Void) {
        dataAccess.getChatWithId(projectId: projectId, chatId: chatId, token: token, completion: completion)
    }
    
    func sendMessage(chatId: Int, message: String, token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        dataAccess.sendMessage(chatId: chatId, message: message, token: token, completion: completion)
    }
}
