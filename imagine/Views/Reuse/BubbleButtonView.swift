import SwiftUI
import SpriteKit

struct BubbleButtonView: UIViewRepresentable {
    var onBubbleExploded: () -> Void

    func makeUIView(context: Context) -> TransparentHitTestSKView {
        let skView = TransparentHitTestSKView()
        skView.backgroundColor = .clear
        skView.allowsTransparency = true
        skView.isUserInteractionEnabled = true
        skView.onBubbleExploded = onBubbleExploded

        let scene = BubbleButtonScene()
        scene.scaleMode = .resizeFill
        scene.onBubbleExploded = onBubbleExploded
        scene.size = UIScreen.main.bounds.size
        scene.isUserInteractionEnabled = true

        skView.presentScene(scene)
        skView.bubbleScene = scene

        return skView
    }

    func updateUIView(_ uiView: TransparentHitTestSKView, context: Context) {
        if let scene = uiView.scene as? BubbleButtonScene {
            let size = uiView.bounds.size
            if scene.size != size {
                scene.size = size
            }
        }
    }
}


import SpriteKit

class TransparentHitTestSKView: SKView {
    var onBubbleExploded: (() -> Void)?
    weak var bubbleScene: BubbleButtonScene?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let scene = bubbleScene,
              let bubble = scene.bubble else {
            return nil
        }

        let scenePoint = convert(point, to: scene)
        let pointInBubble = bubble.convert(scenePoint, from: scene)

        if bubble.contains(pointInBubble) {
            print("🎯 Tap inside bubble")
            return self
        } else {
            print("💨 Tap outside bubble – pass through")
            return nil
        }
    }
}

