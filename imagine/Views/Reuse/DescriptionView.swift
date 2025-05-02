import SwiftUI

struct DescriptionView: View {
    @ObservedObject var viewModel: DescriptionViewModel
    
    var body: some View {
        ZStack {
            // 主要内容
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Dream")
                        .labelFont()
                    
                    Spacer()
                    
                    Button(action: {
                        DispatchQueue.main.async {
                            viewModel.toggleEdit()
                        }
                    }) {
                        Text(viewModel.dream.description == nil ? "Add" : "Edit")
                            .subtitleFont()
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
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
            .blur(radius: viewModel.showingEditor ? 20 : 0)
            .disabled(viewModel.showingEditor)
            
            // 浮动编辑器
            if viewModel.showingEditor {
                DescriptionEditorFloatingView(
                    onDismiss: { 
                        DispatchQueue.main.async {
                            viewModel.showingEditor = false 
                        }
                    },
                    onSave: { 
                        DispatchQueue.main.async {
                            viewModel.updateDescription() 
                        }
                    },
                    content: $viewModel.editContent,
                    showError: $viewModel.showError
                )
                .transition(.scale.combined(with: .opacity))
                .zIndex(10)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.showingEditor)
    }
} 