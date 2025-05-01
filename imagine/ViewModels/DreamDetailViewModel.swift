import Foundation

class DreamDetailViewModel: ObservableObject {
    @Published var dream: Dream

    init(dream: Dream) {
        self.dream = dream
    }

    func addAction(content: String) {
        let action = Action(content: content)
        dream.actions.append(action)
    }

    func toggleAction(_ action: Action) {
        if let index = dream.actions.firstIndex(of: action) {
            dream.actions[index].isFinished.toggle()
        }
    }
}
