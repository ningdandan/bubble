// Views/Detail/DreamDetailView.swift
import SwiftUI
import Combine

struct DreamDetailView: View {
    @ObservedObject var viewModel: DreamDetailViewModel
    var onDreamUpdate: ((Dream) -> Void)? = nil
    @State private var showingEditor = false
    @State private var showArchiveConfirm = false
    
    // 添加 description 编辑相关状态
    @State private var showingDescriptionEditor = false
    @State private var descriptionContent = ""
    @State private var showDescriptionError = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            ZStack {
                Image("bg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                Image("bubble")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.9)
                    .position(x: UIScreen.main.bounds.width / 2, y: 240)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer().frame(height: 60)
                    ScrollView {
                        VStack(spacing: 24) {
                            // 标题部分
                            VStack(spacing: 4) {
                                Text("\(daysUntilDue) days until")
                                    .subtitleFont()
                                    .multilineTextAlignment(.center)
                                Text(viewModel.dream.name)
                                    .titleFont()
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
//                            Text("图片区域开始")
//                                .foregroundColor(.red)
//                            
                            ImageGridView(images: .constant(viewModel.dream.images))
                                .frame(maxWidth: .infinity, minHeight: 200)
                                .padding(.vertical, 32)
//                                .border(Color.red)
//                            Text("图片区域结束")
//                                .foregroundColor(.red)
                            
                            // Description 部分 - 直接在这里显示
                            VStack(alignment: .leading, spacing: 16) {

                                // 图片区域
                            


                                HStack {
                                    Text("Dream")
                                        .labelFont()
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        // 打开描述编辑器
                                        descriptionContent = viewModel.dream.description?.content ?? ""
                                        showDescriptionError = false
                                        showingDescriptionEditor = true
                                    }) {
                                        Text(viewModel.dream.description == nil ? "Add" : "Edit")
                                            .subtitleFont()
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.horizontal)
                                
                                // 描述内容
                                if let description = viewModel.dream.description {
                                    Text(description.content)
                                        .subtitleFont()
                                        .padding(.horizontal)
                                        .multilineTextAlignment(.leading)
                                } else {
                                    Text("Add a description for your dream...")
                                        .subtitleFont()
                                        .foregroundColor(.gray)
                                        .padding(.horizontal)
                                }
                                
                                Divider()
                                    .padding(.vertical, 8)
                            }
                            
                            
                            
                            // 其他内容...
                        }
                    }
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                // 导航栏按钮...
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Image("back")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                    }
                }
                
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
            // 两个浮动视图的模糊效果
            .blur(radius: showingEditor || showingDescriptionEditor ? 20 : 0)
            .disabled(showingEditor || showingDescriptionEditor)
            
            // Dream编辑浮动视图
            if showingEditor {
                DreamEditorFloatingView(
                    onDismiss: { showingEditor = false },
                    onSave: { updatedDream in
                        viewModel.dream = updatedDream
                        viewModel.actions = updatedDream.actions
                        onDreamUpdate?(updatedDream)
                        showingEditor = false
                    }
                )
                .transition(.opacity)
                .zIndex(10)
            }
            
            // Description编辑浮动视图
            if showingDescriptionEditor {
                DescriptionEditorFloatingView(
                    onDismiss: { 
                        showingDescriptionEditor = false 
                    },
                    onSave: { 
                        updateDescription() 
                    },
                    content: $descriptionContent,
                    showError: $showDescriptionError
                )
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .animation(.interpolatingSpring(stiffness: 70, damping: 20).speed(0.7), value: showingDescriptionEditor)
        .animation(.interpolatingSpring(stiffness: 70, damping: 20).speed(0.7), value: showingEditor)
    }
    
    // 更新描述内容的方法
    private func updateDescription() {
        let trimmedContent = descriptionContent.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedContent.isEmpty {
            showDescriptionError = true
            return
        }
        
        showDescriptionError = false
        
        var updatedDream = viewModel.dream
        let description = Description(
            id: viewModel.dream.description?.id ?? UUID(),
            content: descriptionContent,
            createdDate: Date()
        )
        
        updatedDream.description = description
        viewModel.dream = updatedDream
        
        // 通知上层更新
        onDreamUpdate?(updatedDream)
        
        // 关闭编辑器
        showingDescriptionEditor = false
    }
    
    var daysUntilDue: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: viewModel.dream.dueDate)
        return components.day ?? 0
    }
}

//final class KeyboardResponder: ObservableObject {
//    @Published var currentHeight: CGFloat = 0
//    private var cancellable: AnyCancellable?
//    
//    init() {
//        let willShow = NotificationCenter.default
//            .publisher(for: UIResponder.keyboardWillShowNotification)
//            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
//            .map { $0.height }
//        
//        let willHide = NotificationCenter.default
//            .publisher(for: UIResponder.keyboardWillHideNotification)
//            .map { _ in CGFloat(0) }
//        
//        cancellable = Publishers.Merge(willShow, willHide)
//            .subscribe(on: RunLoop.main)
//            .assign(to: \.currentHeight, on: self)
//    }
//}

//#Preview {
//    let sampleActions = [
//        Action(content: "Buy sketchbook", createdDate: Date()),
//        Action(content: "Upload drawings", createdDate: Date().addingTimeInterval(-86400)),
//        Action(content: "Prepare for critique", createdDate: Date().addingTimeInterval(-172800))
//    ]
//    
//    let sampleDream = Dream(
//        id: UUID(),
//        name: "Art Portfolio",
//        styling: 1,
//        dueDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!,
//        images: [
//            DreamImage(filename: "sample1"),
//            DreamImage(filename: "sample2"),
//            DreamImage(filename: "sample3")
//        ],
//        actions: sampleActions,
//        isArchived: false
//    )
//    
//    let viewModel = DreamDetailViewModel(dream: sampleDream)
//    
//    DreamDetailView(viewModel: viewModel)
//}

struct DescriptionSection: View {
    let dream: Dream
    let onUpdate: (Dream) -> Void
    @StateObject private var viewModel: DescriptionViewModel
    
    init(dream: Dream, onUpdate: @escaping (Dream) -> Void) {
        self.dream = dream
        self.onUpdate = onUpdate
        _viewModel = StateObject(wrappedValue: DescriptionViewModel(dream: dream))
    }
    
    var body: some View {
        DescriptionView(viewModel: viewModel)
            .onAppear {
                viewModel.onUpdate = onUpdate
            }
    }
}
