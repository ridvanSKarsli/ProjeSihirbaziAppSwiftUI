// ProjeSihirbaziAIService.swift
import Foundation

protocol ProjeSihirbaziAIService {
    func getOldChat(
        projectId: Int,
        token: String,
        completion: @escaping (Result<[ProjeSihirbaziAI], Error>) -> Void
    )
    
    func createNewChat(
        projectId: Int,
        token: String,
        completion: @escaping (Result<ProjeSihirbaziAI, Error>) -> Void
    )
    
    func deleteChat(
        token: String,
        chatId: Int,
        completion: @escaping (Result<Bool, Error>) -> Void
    )
    
    func getChatWithId(
        projectId: Int,
        chatId: Int,
        token: String,
        completion: @escaping (Result<[ChatMessage], Error>) -> Void
    )
    
    func sendMessage(
        chatId: Int,
        message: String,
        token: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}
