import SpriteKit

class BubbleButtonScene: SKScene {
    
    // 将类型从 SKShapeNode 改为 SKSpriteNode
    var bubble: SKSpriteNode!
    private var bubbleContainer: SKNode! // 新增容器节点
    var onBubbleExploded: (() -> Void)?
    private var isGrowing = false
    private var initialRadius: CGFloat = 40 // 半径为40，直径为80
    private var maxRadius: CGFloat = 300 // 直径为600的一半
    private var currentScale: CGFloat = 1.0
    
    override func didMove(to view: SKView) {
        backgroundColor = .clear
        
        // 创建容器节点以便控制泡泡的锚点
        bubbleContainer = SKNode()
        
        // 创建使用图片的泡泡精灵
        let texture = SKTexture(imageNamed: "bubble")
        bubble = SKSpriteNode(texture: texture)
        
        // 设置泡泡的初始大小，直径为 initialRadius*2
        bubble.size = CGSize(width: initialRadius * 2, height: initialRadius * 2)
        bubble.name = "bubble"
        
        // 将泡泡的位置设为底部，但是在容器内往上偏移radius，使泡泡底边与容器底边对齐
        // SKSpriteNode 的锚点默认在中心，所以y位置保持为initialRadius
        bubble.position = CGPoint(x: 0, y: initialRadius)
        
        // 添加泡泡到容器
        bubbleContainer.addChild(bubble)
        
        let hitArea = SKShapeNode(circleOfRadius: initialRadius)
           hitArea.fillColor = .clear  // 完全透明
           hitArea.strokeColor = .clear
           hitArea.name = "bubbleHitArea"
           hitArea.position = CGPoint(x: 0, y: 0)  // 相对于泡泡的位置
           bubble.addChild(hitArea)
        
        // 先添加到场景，然后在下一帧更新位置
        addChild(bubbleContainer)
        
        // 使用延迟确保size已经正确设置
        DispatchQueue.main.async {
            self.updateBubblePosition()
        }
        
        // 确保场景不捕获屏幕外的触摸事件
        isUserInteractionEnabled = true
        view.isMultipleTouchEnabled = true
        self.isUserInteractionEnabled = true
    }

    // 添加方法来更新泡泡位置
    func updateBubblePosition() {
        // 确保使用当前场景的宽度来居中放置
        bubbleContainer.position = CGPoint(x: size.width / 2, y: 20)
        print("更新气泡位置: \(size.width / 2), 20")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        // 检查是否点击到了任何名为"bubbleHitArea"的节点
        let touchedNodes = nodes(at: location)
        if touchedNodes.contains(where: { $0.name == "bubbleHitArea" || $0.name == "bubble" }) {
            print("✅ Bubble tapped")
            isGrowing = true
        } else {
            print("❌ Tapped outside bubble")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 继续保持增长
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGrowing {
            isGrowing = false
            shrinkBubble()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGrowing {
            isGrowing = false
            shrinkBubble()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isGrowing {
            growBubble()
        }
    }
    
    private func growBubble() {
        // 每帧增加一小部分比例
        let growFactor: CGFloat = 1.03
        currentScale *= growFactor
        
        // 限制最大尺寸
        if currentScale * initialRadius >= maxRadius {
            isGrowing = false
            onBubbleExploded?()
            // 重置大小
            resetBubble()
            return
        }
        
        // 应用新的比例，但保持底部固定
        let newScale = currentScale
        bubble.setScale(newScale)
        
        // 调整泡泡位置以保持底部固定（使用初始半径作为参考）
        bubble.position = CGPoint(x: 0, y: initialRadius * newScale)
    }
    
    private func shrinkBubble() {
        // 创建自定义动作序列
        let shrinkAction = SKAction.customAction(withDuration: 0.3) { [weak self] node, elapsedTime in
            guard let self = self else { return }
            
            // 计算动画进度 (0.0 到 1.0)
            let progress = elapsedTime / 0.3
            
            // 使用 easeOut 时间曲线
            let easedProgress = 1.0 - pow(1.0 - progress, 3)
            
            // 计算当前缩放比例
            let startScale = self.currentScale
            let targetScale: CGFloat = 1.0
            let currentScale = startScale + (targetScale - startScale) * easedProgress
            
            // 应用缩放
            node.setScale(currentScale)
            
            // 调整位置以保持底部固定
            node.position = CGPoint(x: 0, y: self.initialRadius * currentScale)
        }
        
        bubble.run(shrinkAction, completion: {
            self.currentScale = 1.0
        })
    }
    
    private func resetBubble() {
        currentScale = 1.0
        bubble.setScale(1.0)
        bubble.position = CGPoint(x: 0, y: initialRadius)
    }
} 
