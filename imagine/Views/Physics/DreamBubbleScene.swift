import SpriteKit
import SwiftUI

class DreamBubbleScene: SKScene {
    var dreams: [Dream] = []
    var onTap: ((Dream) -> Void)?

    private var bubbleNodes: [UUID: SKShapeNode] = [:]
    private let sharedTexture = SKTexture(imageNamed: "bubble")
    
    override func didMove(to view: SKView) {
        backgroundColor = .clear
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        anchorPoint = CGPoint(x: 0, y: 0)
        // ✅ 等待 scene size 有效
        guard size.width > 0 && size.height > 0 else {
            print("Scene size not ready yet.")
            return
        }

        setupWalls()
        DispatchQueue.main.async {
            self.spawnBubbles()
        }
        print("🟢 SKScene.size =", self.size)
//        spawnBubbles()
    }
    
    
    
    var lastForceTime: TimeInterval = 0
    override func update(_ currentTime: TimeInterval) {
        guard currentTime - lastForceTime > 0.5 else { return }
        lastForceTime = currentTime
//        for (_, node) in bubbleNodes {
//            node.physicsBody?.applyForce(CGVector(dx: 10, dy: 3))
//        }
    }
    
    
    private func setupWalls() {
        let thickness: CGFloat = 10
        let size = self.size

        let wallRects = [
            // bottom wall (y = 0)
            CGRect(x: 0, y: 0, width: size.width, height: thickness),

            // top wall (y = maxY)
            CGRect(x: 0, y: size.height - 10*thickness, width: size.width, height: thickness),

            // left wall (x = 0)
            CGRect(x: 0, y: 0, width: thickness, height: size.height),

            // right wall (x = maxX)
            CGRect(x: size.width - thickness, y: 0, width: thickness, height: size.height)

        ]

        for rect in wallRects {


            // ✅ 2. 实际碰撞体
            let wall = SKNode()
            wall.physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
            wall.physicsBody?.isDynamic = false
            addChild(wall)
        }
    }

    private func spawnBubbles() {
        for dream in dreams {
//            let radius = CGFloat(90 + min(dream.actions.count, 10) * 10) // twice size
            
            let minRadius: CGFloat = 70
            let maxRadius: CGFloat = 110

            // 用 actions 数量映射到 radius 区间，0个 → min，10个以上 → max
            let actionCount = min(dream.actions.count, 5)
            let radius = minRadius + (CGFloat(actionCount) / 2.0) * (maxRadius - minRadius)
            
            let node = SKShapeNode(circleOfRadius: radius)

            node.fillTexture = sharedTexture
            node.fillColor = .white
            
            node.name = dream.id.uuidString

            node.position = CGPoint(
                x: CGFloat.random(in: radius...(size.width - radius)),
                y: CGFloat.random(in: radius...(size.height - radius))
            )

            let body = SKPhysicsBody(circleOfRadius: radius)
            body.restitution = 0.6         // 弹性低一点，避免疯狂反弹
            body.linearDamping = 0.05      // 更慢减速，漂浮感更强
            body.friction = 0.0            // 保持表面无摩擦
            body.allowsRotation = false    // 泡泡通常不旋转
            body.mass = 0.1                // 🌟 改小质量！更轻盈

            // Add gentle current-like force
            let dx = CGFloat.random(in: -100...100)  // 可以左右随机方向
            let dy = CGFloat.random(in: -30...30)
            body.applyForce(CGVector(dx: dx, dy: dy))
            
            node.physicsBody = body
            
            // ✅ 加名字 label
            let label = SKLabelNode(text: dream.name)
            label.fontSize = 11
            label.fontColor = .gray
            label.fontName = FontName.martianMonoLight
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            label.numberOfLines = 2
            label.preferredMaxLayoutWidth = radius * 1.5
            label.zPosition = 999

            node.addChild(label)
            addChild(node)

            bubbleNodes[dream.id] = node
        }
    }
    func applyShakeForce() {
        for node in bubbleNodes.values {
            let dx = CGFloat.random(in: -60...60)
            let dy = CGFloat.random(in: -40...40)
            node.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }

        var didTapBubble = false

        for (id, node) in bubbleNodes {
            if node.contains(location),
               let dream = dreams.first(where: { $0.id == id }) {
                onTap?(dream)
                didTapBubble = true
            }
        }

        // 👉 如果没点到泡泡，就当作是“点击水面推一把”
        if !didTapBubble {
            let impactRadius: CGFloat = 100.0

            for node in bubbleNodes.values {
                let dx = node.position.x - location.x
                let dy = node.position.y - location.y
                let distance = hypot(dx, dy)

                if distance < impactRadius {
                    let multiplier: CGFloat = (impactRadius - distance) / impactRadius
                    let magnitude: CGFloat = 1000
                    let angle = atan2(dy, dx)
                    let forceVector = CGVector(dx: cos(angle) * magnitude, dy: sin(angle) * magnitude)
                    
//                    let forceVector = CGVector(dx: dx * 30 * multiplier, dy: dy * 30 * multiplier)
                    node.physicsBody?.applyForce(forceVector)
                }
            }
        }
    }
}

class ShakeDetectingController: UIViewController {
    var scene: DreamBubbleScene?

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print("🌀 Device shaken!")
            scene?.applyShakeForce()
        }
    }
}



//struct DreamPhysicsView: UIViewRepresentable {
//    let dreams: [Dream]
//    let containerSize: CGSize
//    var onDreamTap: (Dream) -> Void
//
//    func makeUIView(context: Context) -> SKView {
//        let view = SKView()
//        let scene = DreamBubbleScene()
//        scene.size = containerSize // ✅ 确保尺寸来自外部传入
//        scene.scaleMode = .resizeFill
//        scene.dreams = dreams
//        scene.onTap = onDreamTap
//        DispatchQueue.main.async {
//            view.presentScene(scene)
//        }
////        view.presentScene(scene)
//        view.backgroundColor = .clear
//        view.allowsTransparency = true
//        return view
//    }
//
//    func updateUIView(_ uiView: SKView, context: Context) {
//        if let scene = uiView.scene as? DreamBubbleScene {
//            scene.dreams = dreams
//        }
//    }
//}


struct DreamPhysicsView: UIViewControllerRepresentable {
    let dreams: [Dream]
    let containerSize: CGSize
    var onDreamTap: (Dream) -> Void

    func makeUIViewController(context: Context) -> ShakeDetectingController {
        let controller = ShakeDetectingController()
        let skView = SKView()
        skView.backgroundColor = .clear
        skView.allowsTransparency = true

        let scene = DreamBubbleScene()
        scene.size = containerSize
        scene.scaleMode = .resizeFill
        scene.dreams = dreams
        scene.onTap = onDreamTap

        controller.view = skView
        controller.scene = scene

        DispatchQueue.main.async {
            skView.presentScene(scene)
        }

        return controller
    }

    func updateUIViewController(_ controller: ShakeDetectingController, context: Context) {
        if let scene = (controller.view as? SKView)?.scene as? DreamBubbleScene {
            scene.dreams = dreams
        }
    }
}


