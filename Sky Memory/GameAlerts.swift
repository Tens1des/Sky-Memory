import SpriteKit

class AlertNode {
    
    // MARK: - Win Menu
    static func createWinMenu(lives: Int, size: CGSize) -> SKNode {
        let menuNode = SKNode()
        menuNode.zPosition = 1000
        
        print("Creating win menu with lives: \(lives), size: \(size)")
        
        // Полупрозрачный фон
        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = .black
        overlay.alpha = 0.8
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 1
        menuNode.addChild(overlay)
        
        // Панель (пробуем alert_panel, если не работает - создаём программно)
        let panel: SKNode
        if let alertPanel = SKSpriteNode(imageNamed: "alert_panel") as SKNode? {
            print("Using alert_panel image")
            panel = alertPanel
            (panel as! SKSpriteNode).setScale(0.8)
        } else {
            print("Creating panel programmatically")
            let shapePanel = SKShapeNode(rectOf: CGSize(width: 300, height: 400))
            shapePanel.fillColor = .systemBlue
            shapePanel.strokeColor = .white
            shapePanel.lineWidth = 3
            panel = shapePanel
        }
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        panel.zPosition = 2
        menuNode.addChild(panel)
        
        // Простой текст
        let titleLabel = SKLabelNode(text: "YOU WIN!")
        titleLabel.fontSize = 24
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 50)
        titleLabel.zPosition = 3
        menuNode.addChild(titleLabel)
        
        // Простая кнопка
        let button = SKShapeNode(rectOf: CGSize(width: 100, height: 40))
        button.fillColor = .red
        button.strokeColor = .white
        button.lineWidth = 1
        button.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        button.zPosition = 3
        button.name = "restartButton"
        menuNode.addChild(button)
        
        let buttonLabel = SKLabelNode(text: "RESTART")
        buttonLabel.fontSize = 16
        buttonLabel.fontColor = .white
        buttonLabel.position = CGPoint(x: 0, y: -5)
        button.addChild(buttonLabel)
        
        print("Win menu created with \(menuNode.children.count) children")
        return menuNode
    }
    
    // MARK: - Lose Menu
    static func createLoseMenu(size: CGSize) -> SKNode {
        let menuNode = SKNode()
        menuNode.zPosition = 1000
        
        print("Creating lose menu with size: \(size)")
        
        // Полупрозрачный фон
        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = .black
        overlay.alpha = 0.8
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 1
        menuNode.addChild(overlay)
        
        // Панель (пробуем alert_panel, если не работает - создаём программно)
        let panel: SKNode
        if let alertPanel = SKSpriteNode(imageNamed: "alert_panel") as SKNode? {
            print("Using alert_panel image")
            panel = alertPanel
            (panel as! SKSpriteNode).setScale(0.8)
        } else {
            print("Creating panel programmatically")
            let shapePanel = SKShapeNode(rectOf: CGSize(width: 300, height: 400))
            shapePanel.fillColor = .systemRed
            shapePanel.strokeColor = .white
            shapePanel.lineWidth = 3
            panel = shapePanel
        }
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        panel.zPosition = 2
        menuNode.addChild(panel)
        
        // Простой текст
        let titleLabel = SKLabelNode(text: "YOU LOSE!")
        titleLabel.fontSize = 24
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 50)
        titleLabel.zPosition = 3
        menuNode.addChild(titleLabel)
        
        // Простая кнопка
        let button = SKShapeNode(rectOf: CGSize(width: 100, height: 40))
        button.fillColor = .blue
        button.strokeColor = .white
        button.lineWidth = 1
        button.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        button.zPosition = 3
        button.name = "restartButton"
        menuNode.addChild(button)
        
        let buttonLabel = SKLabelNode(text: "RESTART")
        buttonLabel.fontSize = 16
        buttonLabel.fontColor = .white
        buttonLabel.position = CGPoint(x: 0, y: -5)
        button.addChild(buttonLabel)
        
        print("Lose menu created with \(menuNode.children.count) children")
        return menuNode
    }
}