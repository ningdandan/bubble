import SwiftUI
import PhotosUI

struct DreamEditorView: View {
    @ObservedObject var viewModel: DreamEditorViewModel
    var onSave: (Dream) -> Void
    var existingDreamID: UUID? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var showDatePicker: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("imagine...")
                .titleFont()
            

            TextField("Goal", text: $viewModel.name)
                .titleFont()
                .frame(height: 44)
                .dottedFieldStyle()
            

            HStack {
                TextField(
                    "",
                    text: .constant(viewModel.dueDate.formatted(date: .abbreviated, time: .omitted)),
                    prompt: Text("Due Date").font(.custom(FontName.martianMonoLight, size: 11))
                )
                    .disabled(true)
                    .font(.custom(FontName.martianMonoLight, size: 14))

                Image(systemName: "calendar")
                    .foregroundColor(.gray)
            }
            .onTapGesture {
                showDatePicker = true
            }
            .dottedFieldStyle()
            

            
            ImageGridView(images: $viewModel.images)
                .padding(.horizontal).padding(.vertical, 16)

            if viewModel.images.isEmpty {
                PhotosPicker(
                    selection: $viewModel.selectedItems,
                    maxSelectionCount: 3,
                    matching: .images
                ) {
                    ZStack {
                        ForEach(0..<3) { index in
                            let xOffset = CGFloat(index - 1) * 100
                            let yOffset = index == 1 ? 0 : CGFloat.random(in: -10...10)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(
                                    Color.gray.opacity(0.4),
                                    style: StrokeStyle(lineWidth: 1, dash: [3])
                                )
                                .frame(width: 140, height: 180)
                                .background(Color.gray.opacity(0.1))
                                .rotationEffect(.degrees(Double(index - 1) * 5))
                                .offset(x: xOffset, y: yOffset)
                                .overlay(
                                    index == 1 ?
                                    Text("Upload")
                                        .subtitleFont()
                                    //.foregroundColor(.gray)
                                    : nil
                                )
                        }
                    }
                }
            }
            

            Button(action: {
                let dream = viewModel.toDream(existingID: existingDreamID)
                onSave(dream)
                dismiss()
            }) {
                Image("send")
                        .resizable()
                        .renderingMode(.original) // 保留原图颜色（如果需要）
                        .frame(width: 48, height: 48) // 根据图标尺寸调整
                }
            .buttonStyle(PlainButtonStyle()) // 去除默认背景样式
        }
        .sheet(isPresented: $showDatePicker) {
            VStack {
                DatePicker("Select Due Date", selection: $viewModel.dueDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                Button("Done") {
                    showDatePicker = false
                }
            }
            .padding()
        }
        .padding()
    }
}


#Preview {
    DreamEditorView(
        viewModel: DreamEditorViewModel(),
        onSave: { dream in
            print("Saved dream: \(dream)")
        }
    )
}


struct ImageCardView: View {
    let image: UIImage
    let index: Int

    var body: some View {
        let verticalOffset: CGFloat = CGFloat.random(in: 10...25)
        let offsetY = index % 2 == 0 ? -verticalOffset : verticalOffset

        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: 140, height: 180)
            .cornerRadius(12)
            .rotationEffect(.degrees(Double.random(in: -10...10)))
            .offset(y: offsetY)
            .shadow(radius: 4)
            .frame(width: 160, height: 240) // ✅ 外层固定大小
    }
}
