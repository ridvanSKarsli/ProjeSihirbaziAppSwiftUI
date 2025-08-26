// Models.swift
import Foundation

struct ProjeSihirbaziAI: Codable, Identifiable, Equatable {
    let id: Int
    let userId: Int
    let chatHistoryJson: String
    let createdDateTime: String
    let lastDateTime: String
    let model: String
}


