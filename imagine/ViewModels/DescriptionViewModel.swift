import Foundation
import SwiftUI

class DescriptionViewModel: ObservableObject {
    @Published var dream: Dream
    @Published var showingEditor: Bool = false
    @Published var editContent: String = ""
    @Published var showError: Bool = false
    
    var onUpdate: ((Dream) -> Void)? = nil
    
    init(dream: Dream) {
        self.dream = dream
        if let description = dream.description {
            self.editContent = description.content
        }
    }
    
    func toggleEdit() {
        // 创建一个副本防止更新冲突
        let newValue = !showingEditor
        
        // 通过主线程异步执行确保安全更新
        DispatchQueue.main.async {
            self.showingEditor = newValue
            
            if self.showingEditor {
                if let description = self.dream.description {
                    self.editContent = description.content
                } else {
                    self.editContent = ""
                }
            }
        }
    }
    
    func updateDescription() {
        let trimmedContent = editContent.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedContent.isEmpty {
            // 使用主线程异步更新 UI 状态
            DispatchQueue.main.async {
                self.showError = true
            }
            return
        }
        
        // 使用主线程异步更新 UI 状态
        DispatchQueue.main.async {
            self.showError = false
            
            var updatedDream = self.dream
            let description = Description(
                id: self.dream.description?.id ?? UUID(),
                content: self.editContent,
                createdDate: Date()
            )
            
            updatedDream.description = description
            self.dream = updatedDream
            
            // 通知上层组件
            self.onUpdate?(updatedDream)
            
            // 退出编辑模式
            self.showingEditor = false
        }
    }
} 