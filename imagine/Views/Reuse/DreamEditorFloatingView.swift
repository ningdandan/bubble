import SwiftUI

struct DreamEditorFloatingView: View {
    var onDismiss: () -> Void
    var onSave: (Dream) -> Void
    @StateObject private var editorVM = DreamEditorViewModel()

    var body: some View {
        ZStack {
            // 背景模糊层
            Color.clear
                .background(.ultraThinMaterial)
                .ignoresSafeArea()

            // Modal 主体
            VStack {
                DreamEditorView(viewModel: editorVM) { dream in
                    onSave(dream)
                }
            }
            .padding(24)
            .background(
                ZStack {
                    Image("bg") // 用你自己的背景图替代 ultraThinMaterial
                        .resizable()
                        .scaledToFill()
                        .clipped()
                }
            )
            .cornerRadius(32)
            .shadow(
                color: Color(hex: "#FFF9E5").opacity(0.45),
                radius: 24,
                x: 0,
                y: 4
            )
            .frame(maxWidth: 360)
            .overlay(
                Button(action: onDismiss) {
                    Image("exit") // 用你自己的 icon 名
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding(12),
                alignment: .topTrailing
            )
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
