import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = DreamListViewModel()
    @State private var showingEditor = false
    @State private var selectedDream: Dream? = nil
    @State private var animationTrigger = UUID()
    
    // 添加一个状态变量来保存 DreamDetailViewModel
    @State private var detailViewModel: DreamDetailViewModel? = nil

    
    var body: some View {
    
        GeometryReader { geo in
            ZStack {
                
                NavigationView {
                    ZStack {
                        DreamPhysicsView(
                            dreams: viewModel.dreams.filter { !$0.isArchived },
                            containerSize: geo.size
                        ) { dream in
                            selectedDream = dream
                        }
                        .id(animationTrigger)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .edgesIgnoringSafeArea(.all)
                        
                        VStack {
                            Spacer()
                            
                            NavigationLink(
                                destination: selectedDream.map { dream in
                                    // 使用或创建 detailViewModel
                                    let vm = detailViewModel ?? DreamDetailViewModel(dream: dream)
                                    // 确保 detailViewModel 已设置
                                    if detailViewModel == nil {
                                        DispatchQueue.main.async {
                                            detailViewModel = vm
                                        }
                                    }
                                    
                                    return DreamDetailView(
                                        viewModel: vm,
                                        onDreamUpdate: { updated in
                                            viewModel.updateDream(updated)
                                        }
                                    )
                                },
                                isActive: Binding(
                                    get: { selectedDream != nil },
                                    set: { if !$0 { 
                                        selectedDream = nil
                                        // 当导航返回时清空 detailViewModel
                                        detailViewModel = nil 
                                    }}
                                )
                            ) {
                                EmptyView()
                            }
                            .hidden()
                            
                            VStack {
                                Spacer()
                                Button(action: {
                                    showingEditor = true
                                }) {
                                    Image("net-button-1")
                                        .resizable()
                                        .frame(width: 300, height: 280) // 根据实际大小调整
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.bottom, -20) // 调整距离底部的间距
                            }.ignoresSafeArea(edges: .bottom)
                            
                            //                            .padding(.bottom, 40) // ✅ 可手动加 padding 调整回理想位置
                        }
                    }
                    .background(
                        Image("bg")
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                    )
                             
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("imagine...").titleFont()
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: SettingsView(viewModel: viewModel)) {
                                Image("info")
                                    .frame(width: 24, height: 24)
                                
                            }
                        }
                    }
                }
                
                .blur(radius: showingEditor ? 20 : 0)
                        .disabled(showingEditor)

                        // ✅ 前层的浮窗弹出视图
                        if showingEditor {
                            DreamEditorFloatingView(
                                onDismiss: { showingEditor = false },
                                onSave: { newDream in
                                    viewModel.addDream(newDream)
                                    animationTrigger = UUID()
                                    showingEditor = false
                                }
                            )
                            .transition(.scale.combined(with: .opacity))
                            .zIndex(1)
                        }
            }
            .animation(.easeInOut(duration: 0.45), value: showingEditor)
        }
        .onAppear {viewModel.loadDreams()}
        

    }

    func stylingColor(for style: Int) -> Color {
        DreamStyleColors.color(for: style)
    }
}
