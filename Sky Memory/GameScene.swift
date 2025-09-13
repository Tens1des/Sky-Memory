//
//  GameScene.swift
//  Sky Memory
//
//  Created by Рома Котов on 12.09.2025.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, ObservableObject {
    
    // --- Основные параметры сетки ---
    let numColumns = 5
    let numRows = 4
    
    // --- Свойства для расчетов позиций ---
    private var tileSize: CGFloat = 0
    private var gridStartX: CGFloat = 0
    private var gridStartY: CGFloat = 0
    
    // --- Свойства для маршрута и геймплея ---
    private var correctPath: [(row: Int, col: Int)] = []
    private var pathSprites: [SKSpriteNode] = []
    private var currentPathIndex = 0
    private var lives = 3
    private var lifeNodes: [SKSpriteNode] = []
    private var isGameOver = false
    private var canPlayerMove = false
    
    override func didMove(to view: SKView) {
        // Очищаем сцену на случай перезапуска
        self.removeAllChildren()
        
        // Настраиваем сцену с нуля
        setupScene()
    }
    
    private func setupScene() {
        // 1. Устанавливаем фон
        let background = SKSpriteNode(imageNamed: "game_bg")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = frame.size
        background.zPosition = -1
        addChild(background)
        
        // 2. Создаем сетку
        setupGrid()
        
        // 3. Добавляем игрока
        setupPlayer()
        
        // 4. Настраиваем UI (жизни)
        setupUI()
        
        // 5. Генерируем и показываем путь
        generatePath()
        showPath()
        
        // 6. Скрываем путь через 2 секунды и разрешаем игроку ходить
        run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.run { [weak self] in
                self?.hidePath()
                self?.canPlayerMove = true
            }
        ]))
    }
    
    private func setupGrid() {
        let tileColors = [
            "tile_red", "tile_orange", "tile_yellow", "tile_green", "tile_cyan", "tile_blue", "tile_pink"
        ]
        
        let contentWidth = size.width * 0.60
        tileSize = contentWidth / CGFloat(numColumns)
        
        let gridWidth = tileSize * CGFloat(numColumns)
        let gridHeight = tileSize * CGFloat(numRows)
        
        gridStartX = frame.midX - gridWidth / 2
        gridStartY = frame.midY - gridHeight / 2
        
        for col in 0..<numColumns {
            for row in 0..<numRows {
                let tile = SKSpriteNode(imageNamed: tileColors.randomElement()!)
                tile.size = CGSize(width: tileSize, height: tileSize)
                
                let x = gridStartX + CGFloat(col) * tileSize + tileSize / 2
                let y = gridStartY + CGFloat(row) * tileSize + tileSize / 2
                
                tile.position = CGPoint(x: x, y: y)
                tile.zPosition = 0
                
                addChild(tile)
            }
        }
    }
    
    private func setupPlayer() {
        let player = SKSpriteNode(imageNamed: "player_plane")
        player.name = "player"
        player.size = CGSize(width: tileSize * 0.7, height: tileSize * 0.5)
        
        let playerX = gridStartX + CGFloat(2) * tileSize + tileSize / 2
        let playerY = gridStartY - tileSize / 2
        
        player.position = CGPoint(x: playerX, y: playerY)
        player.zPosition = 2
        
        addChild(player)
    }
    
    private func setupUI() {
        let heartSize = CGSize(width: 40, height: 40)
        for i in 0..<3 {
            let heart = SKSpriteNode(imageNamed: "fillHeart_icon")
            heart.size = heartSize
            heart.position = CGPoint(x: frame.maxX - heartSize.width * CGFloat(i) - 25, y: frame.maxY - 35)
            heart.zPosition = 10
            addChild(heart)
            lifeNodes.append(heart)
        }
    }
    
    private func generatePath() {
        correctPath.removeAll()
        var currentCol = 2
        
        for row in 0..<numRows {
            correctPath.append((row: row, col: currentCol))
            if Bool.random() {
                let direction = Int.random(in: -1...1)
                let nextCol = currentCol + direction
                if nextCol >= 0 && nextCol < numColumns {
                    currentCol = nextCol
                }
            }
        }
    }
    
    private func showPath() {
        for pathNode in correctPath {
            let pathSprite = SKSpriteNode(imageNamed: "tile_path")
            pathSprite.size = CGSize(width: tileSize, height: tileSize)
            
            let x = gridStartX + CGFloat(pathNode.col) * tileSize + tileSize / 2
            let y = gridStartY + CGFloat(pathNode.row) * tileSize + tileSize / 2
            
            pathSprite.position = CGPoint(x: x, y: y)
            pathSprite.zPosition = 1
            
            addChild(pathSprite)
            pathSprites.append(pathSprite)
        }
    }

    private func hidePath() {
        for sprite in pathSprites {
            sprite.run(SKAction.fadeOut(withDuration: 0.5)) {
                sprite.removeFromParent()
            }
        }
        pathSprites.removeAll()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if isGameOver {
            let touchedNode = atPoint(location)
            if touchedNode.name == "restartButton" {
                restartGame()
            } else if touchedNode.name == "homeButton" {
                // Логика перехода домой
                print("Go Home")
            } else if touchedNode.name == "continueButton" {
                // Пока что "продолжить" = рестарт
                restartGame()
            }
            return
        }
        
        guard canPlayerMove else { return }
        
        let gridEndX = gridStartX + tileSize * CGFloat(numColumns)
        let gridEndY = gridStartY + tileSize * CGFloat(numRows)
        
        guard location.x >= gridStartX && location.x < gridEndX &&
              location.y >= gridStartY && location.y < gridEndY else { return }
        
        let tappedCol = Int((location.x - gridStartX) / tileSize)
        let tappedRow = Int((location.y - gridStartY) / tileSize)
        
        let expectedMove = correctPath[currentPathIndex]
        
        if tappedRow == expectedMove.row && tappedCol == expectedMove.col {
            movePlayer(toRow: tappedRow, toCol: tappedCol)
        } else {
            handleIncorrectMove()
        }
    }
    
    private func movePlayer(toRow: Int, toCol: Int) {
        guard let player = childNode(withName: "player") else { return }
        
        let targetX = gridStartX + CGFloat(toCol) * tileSize + tileSize / 2
        let targetY = gridStartY + CGFloat(toRow) * tileSize + tileSize / 2
        
        let moveAction = SKAction.move(to: CGPoint(x: targetX, y: targetY), duration: 0.2)
        player.run(moveAction)
        
        currentPathIndex += 1
        
        if currentPathIndex >= correctPath.count {
            winGame()
        }
    }
    
    private func handleIncorrectMove() {
        lives -= 1
        updateLivesUI()
        
        if lives <= 0 {
            loseGame()
        } else {
            let shake = SKAction.moveBy(x: 10, y: 0, duration: 0.05)
            self.run(SKAction.repeat(SKAction.sequence([shake, shake.reversed(), shake.reversed(), shake]), count: 2))
        }
    }
    
    private func updateLivesUI() {
        for (index, heart) in lifeNodes.enumerated() {
            if index < lives {
                heart.texture = SKTexture(imageNamed: "fillHeart_icon")
            } else {
                heart.texture = SKTexture(imageNamed: "notFill_icon")
            }
        }
    }
    
    private func winGame() {
        isGameOver = true
        print("YOU WIN!")
        createWinMenu()
    }
    
    private func loseGame() {
        isGameOver = true
        print("YOU LOSE!")
        createLoseMenu()
    }
    
    private func restartGame() {
        if let view = self.view {
            let newScene = GameScene(size: self.size)
            newScene.scaleMode = self.scaleMode
            view.presentScene(newScene)
        }
    }
    
    private func createWinMenu() {
        let menuNode = SKNode()
        menuNode.zPosition = 100
        
        // Полупрозрачный фон
        let overlay = SKShapeNode(rectOf: self.size)
        overlay.fillColor = .black
        overlay.alpha = 0.6
        overlay.position = CGPoint(x: frame.midX, y: frame.midY)
        menuNode.addChild(overlay)
        
        // Панель
        let panel = SKSpriteNode(imageNamed: "alert_panel")
        panel.position = CGPoint(x: frame.midX, y: frame.midY)
        panel.size = CGSize(width: 320, height: 250) // Задаем фиксированный размер
        menuNode.addChild(panel)
        
        // Заголовок
        let titleLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        titleLabel.text = "LEVEL COMPLETED!"
        titleLabel.fontSize = 32
        titleLabel.position = CGPoint(x: 0, y: 100)
        panel.addChild(titleLabel)
        
        // Звезды
        let starImageName = lives == 3 ? "threeStar_icon" : (lives == 2 ? "twoStar_icon" : "oneStar_icon")
        let stars = SKSpriteNode(imageNamed: starImageName)
        stars.position = CGPoint(x: 0, y: 30)
        stars.setScale(0.9)
        panel.addChild(stars)
        
        // Награда
        let rewardLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        rewardLabel.text = "+200"
        rewardLabel.fontSize = 24
        rewardLabel.position = CGPoint(x: 0, y: -40)
        panel.addChild(rewardLabel)
        
        // Кнопки
        let restartButton = SKSpriteNode(imageNamed: "restart_button")
        restartButton.name = "restartButton"
        restartButton.position = CGPoint(x: -80, y: -110)
        panel.addChild(restartButton)
        
        let continueButton = SKSpriteNode(imageNamed: "countine_button")
        continueButton.name = "continueButton"
        continueButton.position = CGPoint(x: 0, y: -110)
        panel.addChild(continueButton)
        
        let homeButton = SKSpriteNode(imageNamed: "home_button")
        homeButton.name = "homeButton"
        homeButton.position = CGPoint(x: 80, y: -110)
        panel.addChild(homeButton)
        
        addChild(menuNode)
    }
    
    private func createLoseMenu() {
        let menuNode = SKNode()
        menuNode.zPosition = 100
        
        // Фон
        let overlay = SKShapeNode(rectOf: self.size)
        overlay.fillColor = .black
        overlay.alpha = 0.6
        overlay.position = CGPoint(x: frame.midX, y: frame.midY)
        menuNode.addChild(overlay)
        
        let panel = SKSpriteNode(imageNamed: "alert_panel")
        panel.position = CGPoint(x: frame.midX, y: frame.midY)
        panel.size = CGSize(width: 320, height: 250) // Задаем тот же размер
        menuNode.addChild(panel)
        
        // Заголовок
        let titleLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        titleLabel.text = "YOU LOSE!"
        titleLabel.fontSize = 32
        titleLabel.position = CGPoint(x: 0, y: 100)
        panel.addChild(titleLabel)
        
        // Звезды
        let stars = SKSpriteNode(imageNamed: "zeroStar_icon")
        stars.position = CGPoint(x: 0, y: 30)
        stars.setScale(0.9)
        panel.addChild(stars)
        
        // Награда
        let rewardLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        rewardLabel.text = "+0"
        rewardLabel.fontSize = 24
        rewardLabel.position = CGPoint(x: 0, y: -40)
        panel.addChild(rewardLabel)
        
        // Кнопки
        let restartButton = SKSpriteNode(imageNamed: "restart_button")
        restartButton.name = "restartButton"
        restartButton.position = CGPoint(x: -50, y: -110)
        panel.addChild(restartButton)
        
        let homeButton = SKSpriteNode(imageNamed: "home_button")
        homeButton.name = "homeButton"
        homeButton.position = CGPoint(x: 50, y: -110)
        panel.addChild(homeButton)
        
        addChild(menuNode)
    }
}
