import SwiftUI

struct DreamEditorFloatingView: View {
    var onDismiss: () -> Void
    var onSave: (Dream) -> Void
    @StateObject private var editorVM = DreamEditorViewModel()

    var body: some View {
        ZStack {
            // 背景模糊层
            Color.black.opacity(0.001)
                //.background(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture {
                            onDismiss()
                        }

            // Modal 主体
            VStack {
                DreamEditorView(viewModel: editorVM) { dream in
                    onSave(dream)
                }.frame(maxWidth: 350)
            }
            .padding(24)
            .background(
                ZStack {
                    Circle()
                                .fill(Color(hex: "#FFF9E5")) // 米色背景
                                .frame(width: 600, height: 600)
                    Image("bubble") // 用你自己的背景图替代 ultraThinMaterial
                        .resizable()
                        .scaledToFill()
                        .clipped()
                }
            )
            .frame(width: 670, height: 670) // 让它成为正圆
            .clipShape(Circle())
            .cornerRadius(32)
            .shadow(
                color: Color(hex: "#FFF9E5").opacity(0.45),
                radius: 24,
                x: 0,
                y: 4
            )
            .frame(maxWidth: 360)
//            .overlay(
//                Button(action: onDismiss) {
//                    Image("exit") // 用你自己的 icon 名
//                        .resizable()
//                        .frame(width: 24, height: 24)
//                }
//                .padding(12),
//                alignment: .topTrailing
//            )
        }
    }
}


#Preview {
    DreamEditorFloatingView(
        onDismiss: {
            print("Dismiss tapped")
        },
        onSave: { dream in
            print("Saved dream: \(dream.name)")
        }
    )
}
