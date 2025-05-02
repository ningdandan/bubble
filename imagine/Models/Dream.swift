// Models/Dream.swift
import Foundation

struct Dream: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var styling: Int // 1–5
    var dueDate: Date
    let createdDate: Date = Date()
    var images: [DreamImage] = []
    var actions: [Action] = []
    var isArchived: Bool = false  // ✅ 新增字段，默认未归档
}

struct DreamImage: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var filename: String // ✅ 只存文件名
}

struct Action: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var content: String
    var createdDate: Date = Date()
//    var isFinished: Bool = false
    
    init(id: UUID = UUID(), content: String, createdDate: Date = Date()) {
            self.id = id
            self.content = content
            self.createdDate = createdDate
//            self.isFinished = isFinished
        }
}
