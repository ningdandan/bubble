import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = DreamListViewModel()
    @State private var showingEditor = false
    @State private var selectedDream: Dream? = nil
    @State private var animationTrigger = UUID()

    
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
                                destination: selectedDream.map {
                                    DreamDetailView(
                                        viewModel: DreamDetailViewModel(dream: $0),
                                        onDreamUpdate: { updated in
                                            viewModel.updateDream(updated)
                                        }
                                    )
                                },
                                isActive: Binding(
                                    get: { selectedDream != nil },
                                    set: { if !$0 { selectedDream = nil } }
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
                                    Image("net-button")
                                        .resizable()
                                        .frame(width: 200, height: 200) // 根据实际大小调整
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
            }.animation(.easeInOut(duration: 0.65), value: showingEditor)
        }.onAppear {
            viewModel.loadDreams()
        }
        

    }

    func stylingColor(for style: Int) -> Color {
        DreamStyleColors.color(for: style)
    }
}
