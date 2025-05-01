import SwiftUI
import PhotosUI

class DreamEditorViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var styling: Int = 1
    @Published var dueDate: Date = Date().addingTimeInterval(86400 * 30)
    @Published var images: [DreamImage] = []

    init() {
        self.styling = Int.random(in: 1...5)
    }
    @Published var selectedItems: [PhotosPickerItem] = [] {
        didSet {
            loadImagesFromPicker()
        }
    }

    private func loadImagesFromPicker() {
        for item in selectedItems {
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data),
                   let url = saveImageToFileSystem(uiImage) {

                    let filename = url.lastPathComponent  // ✅ 提取文件名
                    let image = DreamImage(filename: filename)

                    await MainActor.run {
                        self.images.append(image)
                    }
                }
            }
        }
    }


    private func saveImageToFileSystem(_ image: UIImage) -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        let filename = UUID().uuidString + ".jpg"
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        
        
        do {
            try data.write(to: url)
            let image = DreamImage(filename: filename)
            print("Saved image to: \(url.path)")
            return url
        } catch {
            print("Error saving image to file: \(error)")
            return nil
        }
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func toDream(existingID: UUID? = nil) -> Dream {
        Dream(id: existingID ?? UUID(), name: name, styling: styling, dueDate: dueDate, images: images)
    }

    func load(from dream: Dream) {
        self.name = dream.name
        self.styling = dream.styling
        self.dueDate = dream.dueDate
        self.images = dream.images
    }
}
