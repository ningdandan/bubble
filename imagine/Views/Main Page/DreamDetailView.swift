// Views/Detail/DreamDetailView.swift
import SwiftUI
import Combine

struct DreamDetailView: View {
    @ObservedObject var viewModel: DreamDetailViewModel
    var onDreamUpdate: ((Dream) -> Void)? = nil
    @State private var showingEditor = false
    @State private var showArchiveConfirm = false
    @ObservedObject private var keyboard = KeyboardResponder()
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            ZStack {
                Image("bg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                Image("bubble") // 你的图片名，放在 Assets 中
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.9)
                    .position(x: UIScreen.main.bounds.width / 2, y: 240)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer().frame(height: 60)
                    ScrollView {
                        VStack(spacing: 24) {
                            VStack(spacing: 4) {
                                Text("\(daysUntilDue) days until")
                                    .subtitleFont()
                                    .multilineTextAlignment(.center)
                                Text(viewModel.dream.name)
                                    .titleFont()
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            
                            ImageGridView(images: .constant(viewModel.dream.images))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 32)
                            
                            Divider()
                            
                            Text("details")
                                .labelFont()
                                .padding(.horizontal)
                            
                            VStack(spacing: 16) {
                                ForEach(viewModel.actions.reversed()) { action in
                                    TodoItemView(action: action)
                                }
                            }
                            .padding(.horizontal)
                            
                            Spacer(minLength: 40)
                        }
                        .padding(.top)
                        .background(Color.clear)
                    }.background(Color.clear)
                    
                    VStack {
                        TodoInputView { text in
                            viewModel.addAction(content: text)
                            onDreamUpdate?(viewModel.dream)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, keyboard.currentHeight + 60)
                        .animation(.easeOut(duration: 0.05), value: keyboard.currentHeight)
                        .frame(maxWidth: .infinity, alignment: .bottom)
                    }
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                // ✅ 自定义左上角返回按钮
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // 返回上一页
                        dismiss()
                    }) {
                        HStack(spacing: 6) {
                            Image("back") // 用你自己的 icon 名字
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                    }
                }
                
                // ✅ 右上角的按钮保留原样
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: { showingEditor = true }) {
                            Image("pencil")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        
                        Button(action: { showArchiveConfirm = true }) {
                            Image("menu")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                    }
                }
            }
            .confirmationDialog("Are you sure you want to archive this dream?", isPresented: $showArchiveConfirm) {
                Button("Archive", role: .destructive) {
                    viewModel.dream.isArchived = true
                    onDreamUpdate?(viewModel.dream)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
            .blur(radius: showingEditor ? 20 : 0)
            .disabled(showingEditor)
            
            if showingEditor {
                DreamEditorFloatingView(
                    onDismiss: { showingEditor = false },
                    onSave: { updatedDream in
                        viewModel.dream = updatedDream
                        viewModel.actions = updatedDream.actions  // ❗️这一行必须加！！
                        onDreamUpdate?(updatedDream)
                        showingEditor = false
                    }
                )
                .transition(.scale.combined(with: .opacity))
                .zIndex(10)
            }
        }
    }
    
    var daysUntilDue: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: viewModel.dream.dueDate)
        return components.day ?? 0
    }
}

final class KeyboardResponder: ObservableObject {
    @Published var currentHeight: CGFloat = 0
    private var cancellable: AnyCancellable?
    
    init() {
        let willShow = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }
        
        let willHide = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        cancellable = Publishers.Merge(willShow, willHide)
            .subscribe(on: RunLoop.main)
            .assign(to: \.currentHeight, on: self)
    }
}

#Preview {
    let sampleActions = [
        Action(content: "Buy sketchbook", createdDate: Date()),
        Action(content: "Upload drawings", createdDate: Date().addingTimeInterval(-86400)),
        Action(content: "Prepare for critique", createdDate: Date().addingTimeInterval(-172800))
    ]
    
    let sampleDream = Dream(
        id: UUID(),
        name: "Art Portfolio",
        styling: 1,
        dueDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!,
        images: [
            DreamImage(filename: "sample1"),
            DreamImage(filename: "sample2"),
            DreamImage(filename: "sample3")
        ],
        actions: sampleActions,
        isArchived: false
    )
    
    let viewModel = DreamDetailViewModel(dream: sampleDream)
    
    DreamDetailView(viewModel: viewModel)
}
