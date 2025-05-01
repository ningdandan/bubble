import SwiftUI

struct DreamEditorFloatingView: View {
    var onDismiss: () -> Void
    var onSave: (Dream) -> Void
    @StateObject private var editorVM = DreamEditorViewModel()

    var body: some View {
        VStack {
            DreamEditorView(viewModel: editorVM) { dream in
                onSave(dream)
            }
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .cornerRadius(32)
        .shadow(radius: 20)
        .frame(maxWidth: 360)
        .overlay(
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
            .padding(12),
            alignment: .topTrailing
        )
    }
}
