// Shared/ImageGridView.swift
import SwiftUI

struct ImageGridView: View {
    @Binding var images: [DreamImage]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: -60) {
                Spacer(minLength: 40)
                ForEach(images.indices, id: \.self) { index in
                            let image = images[index]
                    ZStack(alignment: .topTrailing) {
                        let fullPath = FileManager.default
                            .urls(for: .documentDirectory, in: .userDomainMask)[0]
                            .appendingPathComponent(image.filename)
                        
                        if let uiImage = UIImage(contentsOfFile: fullPath.path) {
                            let verticalOffset: CGFloat = CGFloat.random(in: 10...25)
                            let offsetY = index % 2 == 0 ? -verticalOffset : verticalOffset

                            
                            ZStack {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 180, height: 230)
                                    .cornerRadius(12)
                                    .rotationEffect(.degrees(Double.random(in: -10...10)))
                                    .offset(y: offsetY)// ✅ 上下错位
                                    //.zIndex(Double.random(in: -10...10)) // ✅ 保持渲染顺序稳定
                                    .shadow(radius: 4)
                            }
                            .frame(width: 160, height: 280)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

//struct ImageGridView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Create some sample image filenames (these should exist in your documents directory for images to show)
//        let sampleImages = [
//            DreamImage(from:"sample1"),
//                DreamImage(assetName: "sample2"),
//                DreamImage(assetName: "sample3")
//        ]
//        
//        // Use a Stateful preview wrapper
//        StatefulPreviewWrapper(sampleImages) { binding in
//            ImageGridView(images: binding)
//        }
//    }
//}
//
//struct StatefulPreviewWrapper<Value, Content: View>: View {
//    @State var value: Value
//    var content: (Binding<Value>) -> Content
//
//    init(_ initialValue: Value, content: @escaping (Binding<Value>) -> Content) {
//        _value = State(wrappedValue: initialValue)
//        self.content = content
//    }
//
//    var body: some View {
//        content($value)
//    }
//}
