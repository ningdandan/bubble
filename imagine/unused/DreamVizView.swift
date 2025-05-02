import SwiftUI

struct DreamVizView: View {
    let dreams: [Dream]
    let onDreamTap: (Dream) -> Void
    @State private var positions: [UUID: CGPoint] = [:]
    @State private var screenSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                
                ForEach(dreams) { dream in
                    BubbleView(dream: dream)
                        .frame(width: bubbleSize(for: dream), height: bubbleSize(for: dream))
                        .position(positions[dream.id, default: randomPosition(in: geo.size)])
                        .onTapGesture {
                            onDreamTap(dream)
                        }
                        .onAppear {
                            screenSize = geo.size
                            positions[dream.id] = randomPosition(in: geo.size)
                        }
                }
            }
            .background(
                TimelineView(.animation) { _ in
                    Color.clear
                        .task {
                            withAnimation(.easeInOut(duration: 2.0)) {
                                for id in dreams.map(\.id) {
                                    positions[id] = randomJitter(from: positions[id] ?? .zero, in: screenSize)
                                }
                            }
                        }
                }
            )
        }
    }

    // Bubble size based on number of actions (min size 80, max 160)
    func bubbleSize(for dream: Dream) -> CGFloat {
        let base: CGFloat = 80
        let max: CGFloat = 160
        return base + CGFloat(min(dream.actions.count, 10)) * 8
    }

    // Random initial position
    func randomPosition(in size: CGSize) -> CGPoint {
        let padding: CGFloat = 100
        return CGPoint(
            x: CGFloat.random(in: padding...(size.width - padding)),
            y: CGFloat.random(in: padding...(size.height - padding))
        )
    }

    // Slight offset jitter
    func randomJitter(from point: CGPoint, in size: CGSize) -> CGPoint {
        let offset: CGFloat = 20
        return CGPoint(
            x: min(max(point.x + CGFloat.random(in: -offset...offset), 60), size.width - 60),
            y: min(max(point.y + CGFloat.random(in: -offset...offset), 60), size.height - 60)
        )
    }
}

struct BubbleView: View {
    let dream: Dream

    var body: some View {
        ZStack {
            Circle()
                .fill(DreamStyleColors.color(for: dream.styling))
            Text(dream.name)
                .font(.caption)
                .foregroundColor(.black)
                .padding()
                .multilineTextAlignment(.center)
        }
    }
}
