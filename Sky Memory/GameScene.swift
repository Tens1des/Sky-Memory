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
        
        // 4. Настраиваем UI (кнопка повтора)
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
        // Получаем имя спрайта для выбранного скина
        let planeImageName = PlayerData.shared.getCurrentPlaneImageName()
        
        let player = SKSpriteNode(imageNamed: planeImageName)
        player.name = "player"
        player.size = CGSize(width: tileSize * 0.7, height: tileSize * 0.5)
        
        let playerX = gridStartX + CGFloat(2) * tileSize + tileSize / 2
        let playerY = gridStartY - tileSize / 2
        
        player.position = CGPoint(x: playerX, y: playerY)
        player.zPosition = 2
        
        addChild(player)
    }
    
    private func setupUI() {
        // Убираем создание иконок здоровья
        lifeNodes.removeAll()
        
        // Создаем кнопку "Повторить путь"
        let repeatButton = SKSpriteNode(imageNamed: "repeat_button")
        repeatButton.name = "repeatButton"
        repeatButton.size = CGSize(width: 50, height: 50)
        // Позиционируем в левом верхнем углу
        repeatButton.position = CGPoint(x: frame.minX + 45, y: frame.maxY - 60)
        repeatButton.zPosition = 10
        addChild(repeatButton)
    }
    
    private func generatePath() {
        correctPath.removeAll()
        var currentCol = 2 // Начинаем с центральной колонки
        
        for row in 0..<numRows {
            correctPath.append((row: row, col: currentCol))
            
            // На каждом шаге, кроме последнего, решаем, куда двигаться дальше.
            // Это создаст более извилистый маршрут.
            if row < numRows - 1 {
                let direction = Int.random(in: -1...1) // -1: влево, 0: прямо, 1: вправо
                let nextCol = currentCol + direction
                
                // Проверяем, чтобы не выйти за пределы поля (0-4)
                if nextCol >= 0 && nextCol < numColumns {
                    currentCol = nextCol
                }
                // Если следующий шаг выходит за пределы, остаемся в той же колонке.
            }
        }
    }
    
    private func showPath() {
        // Сначала удаляем старые спрайты пути, если они есть
        hidePath(animated: false)
        
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

    private func hidePath(animated: Bool = true) {
        for sprite in pathSprites {
            if animated {
                sprite.run(SKAction.fadeOut(withDuration: 0.5)) {
                    sprite.removeFromParent()
                }
            } else {
                sprite.removeFromParent()
            }
        }
        pathSprites.removeAll()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let touchedNode = atPoint(location)
        
        // --- Обработка кнопки "Повторить путь" ---
        if touchedNode.name == "repeatButton" {
            showPath()
            run(SKAction.sequence([
                SKAction.wait(forDuration: 2.0),
                SKAction.run { [weak self] in
                    self?.hidePath()
                }
            ]))
            return // Выходим, чтобы не обрабатывать другие нажатия
        }
        
        if isGameOver {
            // Находим узел, по которому тапнули
            // Проверяем, не является ли этот узел или его родитель кнопкой рестарта
            if touchedNode.name == "restartButton" || touchedNode.parent?.name == "restartButton" {
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
            //updateLivesUI()
        
        if lives <= 0 {
            loseGame()
            } else {
            let shake = SKAction.moveBy(x: 10, y: 0, duration: 0.05)
            self.run(SKAction.repeat(SKAction.sequence([shake, shake.reversed(), shake.reversed(), shake]), count: 2))
        }
    }
    
    /* private func updateLivesUI() {
        print("Updating lives UI. Current lives: \(lives)")
        for (index, heart) in lifeNodes.enumerated() {
            if index < lives {
                heart.texture = SKTexture(imageNamed: "fillHeart_icon")
            } else {
                heart.texture = SKTexture(imageNamed: "notFill_icon")
            }
        }
    }*/
    
    private func winGame() {
        isGameOver = true
        print("YOU WIN!")
        createSimpleAlert(title: "YOU WIN!", color: .blue)
    }
    
    private func loseGame() {
        isGameOver = true
        print("YOU LOSE!")
        createSimpleAlert(title: "YOU LOSE!", color: .red)
    }
    
    private func createSimpleAlert(title: String, color: SKColor) {
        // --- Контейнер для всего алерта ---
        let alertNode = SKNode()
        alertNode.zPosition = 1000 // Очень высокий z-index, чтобы быть поверх всего
        
        // Полупрозрачный фон
        let overlay = SKShapeNode(rectOf: frame.size)
        overlay.fillColor = .black
        overlay.alpha = 0.7
        overlay.position = CGPoint(x: frame.midX, y: frame.midY)
        alertNode.addChild(overlay)
        
        // --- Панель (родительский узел для элементов) ---
        let panel = SKShapeNode(rectOf: CGSize(width: 300, height: 220), cornerRadius: 15)
        panel.fillColor = color
        panel.strokeColor = .white
        panel.lineWidth = 3
        panel.position = CGPoint(x: frame.midX, y: frame.midY)
        alertNode.addChild(panel)
        
        // --- Элементы (добавляем как дочерние к панели) ---
        
        // Текст (позиция относительно центра панели)
        let titleLabel = SKLabelNode(text: title)
        titleLabel.fontSize = 32
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: 50) // Центрируем по X, смещаем по Y
        panel.addChild(titleLabel)
        
        // Кнопка (позиция относительно центра панели)
        let button = SKShapeNode(rectOf: CGSize(width: 150, height: 50), cornerRadius: 10)
        button.fillColor = .white
        button.strokeColor = .black
        button.lineWidth = 2
        button.position = CGPoint(x: 0, y: -40) // Центрируем по X, смещаем по Y
        button.name = "restartButton"
        panel.addChild(button)
        
        // Текст на кнопке
        let buttonLabel = SKLabelNode(text: "RESTART")
        buttonLabel.fontSize = 20
        buttonLabel.fontColor = .black
        buttonLabel.position = CGPoint(x: 0, y: -8) // Центрируем в кнопке
        button.addChild(buttonLabel)
        
        // Добавляем весь алерт на сцену одним узлом
        addChild(alertNode)
        
        print("Alert created with title: \(title)")
    }
    
    private func restartGame() {
        if let view = self.view {
            let newScene = GameScene(size: self.size)
            newScene.scaleMode = self.scaleMode
            view.presentScene(newScene)
        }
    }
}
