import Foundation

class DreamDetailViewModel: ObservableObject {
    @Published var dream: Dream
    @Published var actions: [Action]

    init(dream: Dream) {
        self.dream = dream
        self.actions = dream.actions
    }

    func addAction(content: String) {
        let action = Action(content: content)
        actions.append(action)
        dream.actions = actions // ✅ 同步回 dream
        
        print("🌟 当前 actions.count: \(actions.count)")
            for (i, act) in actions.enumerated() {
                print("  \(i): \(act.content)")
            }

        print("📦 同步到 dream.actions.count: \(dream.actions.count)")
    }
}
