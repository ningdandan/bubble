import SpriteKit

class BubbleScene: SKScene {

    var bubble: SKShapeNode!
    var onBubbleExploded: (() -> Void)?
    var isGrowing = false

    override func didMove(to view: SKView) {
        backgroundColor = .white

        let radius: CGFloat = 50
        bubble = SKShapeNode(circleOfRadius: radius)
        bubble.fillColor = .systemBlue
        bubble.strokeColor = .clear
        
//        let texture = SKTexture(imageNamed: "bubble")
//        bubble = SKSpriteNode(texture: texture)
//        bubble.size = CGSize(width: 100, height: 100)  // 初始大小
//        
        bubble.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bubble.name = "bubble"
        addChild(bubble)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }

        if let node = atPoint(location) as? SKShapeNode, node.name == "bubble" {
            isGrowing = true
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isGrowing = false
    }

    override func update(_ currentTime: TimeInterval) {
        guard isGrowing else { return }

        // 每帧稍微放大
        bubble.setScale(bubble.xScale * 1.01)

        // 检查是否超出屏幕
        if bubble.frame.width > max(size.width, size.height) * 1.2 {
            isGrowing = false
            onBubbleExploded?()
        }
    }
}
