import SwiftUI

struct DescriptionEditorFloatingView: View {
    var onDismiss: () -> Void
    var onSave: () -> Void
    @Binding var content: String
    @Binding var showError: Bool
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            // 背景模糊层 - 确保全屏覆盖
            Color.black.opacity(0.001)
//                .background(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture {
                            onDismiss()
                        }
            
            // Modal 主体 - 限制高度和位置
            VStack {
                // 描述编辑内容
                VStack(spacing: 16) { // 减小间距
                    Text("Edit Dream")
                        .titleFont()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        TextEditor(text: $content)
                            .focused($isTextFieldFocused)
                            .frame(minHeight: 100, maxHeight: 150) // 限制最大高度
                            .padding(10)
                            .scrollContentBackground(.hidden) // iOS 16+ 可用
                            .background(Color.clear) // 设置透明背景
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 8)
//                                    .stroke(
//                                        Color.gray.opacity(0.4),
//                                        style: StrokeStyle(lineWidth: 1, dash: [3])
//                                    )
//                            )
//                            .background(Color.gray.opacity(0.1))
                        
                        if showError {
                            Text("Description cannot be empty")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.leading, 4)
                        }
                    }
                    
                    Button(action: {
                        onSave()
                    }) {
                        Image("send")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 40, height: 40) // 减小按钮尺寸
                    }
                    .buttonStyle(PlainButtonStyle())
                    .opacity(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                }
                
                .padding(18) // 减小内边距
            }
            .frame(maxWidth: 370)
            .padding(16) // 减小外边距
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
//                    Image("exit")
//                        .resizable()
//                        .frame(width: 20, height: 20) // 减小退出按钮尺寸
//                }
//                .padding(8),
//                alignment: .topTrailing
//            )
            .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2 - 50) // 向上调整位置
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    DescriptionEditorFloatingView(
        onDismiss: {},
        onSave: {},
        content: .constant("Example description text"),
        showError: .constant(false)
    )
} 
