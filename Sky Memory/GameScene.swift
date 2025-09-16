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
    var numColumns = 10
    var numRows = 7
    private var levelIndex: Int = 0

    // Инициализация уровня с параметром level: 0 → базовая сетка, 1 → +1 столбик
    convenience init(size: CGSize, level: Int) {
        self.init(size: size)
        self.levelIndex = level
        configureGridForLevel()
    }

    override init(size: CGSize) {
        super.init(size: size)
        configureGridForLevel()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureGridForLevel()
    }

    private func configureGridForLevel() {
        // База: 10 столбцов, 7 рядов. Для уровня 2 (index >= 1) добавляем +1 плитку в каждом столбике
        numColumns = 10
        numRows = 7 + (levelIndex >= 1 ? 1 : 0)
    }
    
    // --- Свойства для расчетов позиций ---
    private var tileSize: CGFloat = 0
    private var gridStartX: CGFloat = 0
    private var gridStartY: CGFloat = 0
    
    // --- Свойства для маршрута и геймплея ---
    private var correctPath: [(row: Int, col: Int)] = []
    private var pathSprites: [SKSpriteNode] = []
    private var currentPathIndex = 0
    @Published private(set) var lives = 3
    @Published private(set) var stars = 3 // Добавляем отслеживание звезд
    @Published var levelCoins: Int = 150 // Базовые монеты уровня для расчёта
    @Published var gameOver = false
    @Published var didWin = false
    private var isGameOver = false
    private var canPlayerMove = false
    private var playerNode: SKSpriteNode?
    private var greyPlatformNode: SKSpriteNode?
    
    // --- Ураган как живой таймер ---
    private var tornadoNode: SKSpriteNode?
    private var tornadoSpeed: CGFloat = 20.0 // пикс/сек стартовая скорость
    private var tornadoAcceleration: CGFloat = 4.0 // ускорение пикс/сек^2
    private var lastUpdateTime: TimeInterval = 0
    
    // Управление паузой
    func pauseGame() {
        self.isPaused = true
    }
    
    func resumeGame() {
        self.isPaused = false
    }
    
    // --- Движение шипов и плиток ---
    private let spikesSpeed: CGFloat = -3.0 // Очень медленная скорость для шипов
    private var rowNodes: [SKNode] = [] // Массив для хранения рядов плиток
    // Отдельный массив скоростей не храним; направление зададим по индексу ряда
    
    override func didMove(to view: SKView) {
        // Очищаем сцену на случай перезапуска
        self.removeAllChildren()
        
        // Настраиваем сцену с нуля
        setupScene()
        
        // Шипы статичны — движение не запускаем
        // startSpikesMovement()
    }
    
    private func startSpikesMovement() {
        // Создаем действия для движения
        let duration: TimeInterval = 8.0 // Очень медленное движение - 8 секунд в одну сторону
        let moveLeftToCenter = SKAction.moveBy(x: frame.width/5, y: 0, duration: duration)
        let moveRightToCenter = SKAction.moveBy(x: -frame.width/5, y: 0, duration: duration)
        let resetLeft = SKAction.moveTo(x: 0, duration: 0)
        let resetRight = SKAction.moveTo(x: frame.maxX, duration: 0)
        
        // Создаем последовательности действий
        let leftSequence = SKAction.sequence([moveLeftToCenter, resetLeft])
        let rightSequence = SKAction.sequence([moveRightToCenter, resetRight])
        
        // Запускаем бесконечное повторение
        if let leftSpike = childNode(withName: "spikesLeft") {
            leftSpike.run(SKAction.repeatForever(leftSequence))
        }
        
        if let rightSpike = childNode(withName: "spikesRight") {
            rightSpike.run(SKAction.repeatForever(rightSequence))
        }
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
        
        // 2.1 Размещаем шипы слева и справа от сетки
        setupSpikes()
        
        // 2.2 Размещаем ураган внизу сетки (старт таймера)
        setupTornado()
        
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
                self?.startRowsMovement() // Запускаем движение рядов после скрытия пути
                // Шипы остаются статичными, поэтому не запускаем движение
                // self?.startSpikesMovement()
                self?.canPlayerMove = true
            }
        ]))
    }
    
    private func setupGrid() {
        rowNodes.removeAll() // Очищаем массив рядов
        
        let tileColors = [
            "tile_red", "tile_orange", "tile_yellow", "tile_green", "tile_cyan"
        ]
        
        // Делам поле уже и выше, как на референсе: больше вертикали, меньше ширины
        let contentWidth = size.width * 0.7
        let contentHeight = size.height * 0.6
        let tileSizeByWidth = contentWidth / CGFloat(numColumns)
        let tileSizeByHeight = contentHeight / CGFloat(numRows)
        // Используем минимальный размер для сохранения пропорций тайлов
        tileSize = min(tileSizeByWidth, tileSizeByHeight)
        
        // Пересчитываем размеры сетки с учетом фиксированного размера тайла
        let actualGridWidth = tileSize * CGFloat(numColumns)
        let actualGridHeight = tileSize * CGFloat(numRows)
        
        gridStartX = frame.midX - actualGridWidth / 2
        gridStartY = frame.midY - actualGridHeight / 2
        
        // Создаем ряды плиток
        for row in 0..<numRows {
            // Создаем контейнер для ряда
            let rowNode = SKNode()
            rowNode.position = CGPoint(x: gridStartX, y: gridStartY + CGFloat(row) * tileSize)
            rowNode.zPosition = 0
            addChild(rowNode)
            rowNodes.append(rowNode)
            
            // Создаем плитки в ряду
            for col in 0..<numColumns {
                let tile = SKSpriteNode(imageNamed: tileColors.randomElement()!)
                tile.size = CGSize(width: tileSize, height: tileSize)
                tile.position = CGPoint(x: CGFloat(col) * tileSize + tileSize / 2, y: tileSize / 2)
                rowNode.addChild(tile)
            }
        }
        
        // Движение рядов запустится после показа пути
        
        // Серая панель под сеткой (чуть выше, чтобы визуально казалось массивнее)
        let panelHeight = tileSize * 1.1
        let panel = SKSpriteNode(imageNamed: "grey_panel")
        panel.size = CGSize(width: actualGridWidth, height: panelHeight)
        panel.position = CGPoint(x: gridStartX + actualGridWidth / 2, y: gridStartY - panelHeight / 2)
        panel.zPosition = 1
        addChild(panel)
        greyPlatformNode = panel
    }
    
    private func startRowsMovement() {
        for (index, rowNode) in rowNodes.enumerated() {
            // Чередуем направление движения по индексам рядов
            let direction: CGFloat = (index % 2 == 0) ? 1 : -1
            let moveDistance = tileSize // Расстояние в одну сторону
            
            // Создаем действия движения с фиксированной длительностью для большей плавности
            let duration: TimeInterval = 4.0 // 4 секунды в одну сторону
            let moveForward = SKAction.moveBy(x: moveDistance * direction, y: 0, duration: duration)
            let moveBack = SKAction.moveBy(x: -moveDistance * direction, y: 0, duration: duration)
            
            // Создаем последовательность: движение вперед -> движение назад
            let sequence = SKAction.sequence([moveForward, moveBack])
            
            // Запускаем бесконечное повторение
            rowNode.run(SKAction.repeatForever(sequence))
        }
    }
    
    private func setupSpikes() {
        // Располагаем шипы по краям экрана и ограничиваем их высотой сетки
        let spikeWidth = tileSize * 3
        let actualGridWidth = tileSize * CGFloat(numColumns)
        let actualGridHeight = tileSize * CGFloat(numRows)
        let spikesHeight = actualGridHeight
        let spikesCenterY = gridStartY + actualGridHeight / 2
        
        // Левый шип — у левого края экрана
        let spikesLeft = SKSpriteNode(imageNamed: "spikesL")
        spikesLeft.name = "spikesLeft"
        spikesLeft.size = CGSize(width: spikeWidth, height: spikesHeight)
        spikesLeft.position = CGPoint(x: gridStartX - spikeWidth / 2, y: spikesCenterY)
        spikesLeft.zPosition = 3
        addChild(spikesLeft)
        
        // Правый шип — у правого края экрана
        let spikesRight = SKSpriteNode(imageNamed: "spikesR")
        spikesRight.name = "spikesRight"
        spikesRight.size = CGSize(width: spikeWidth, height: spikesHeight)
        spikesRight.position = CGPoint(x: gridStartX + actualGridWidth + spikeWidth / 2, y: spikesCenterY)
        spikesRight.zPosition = 3
        addChild(spikesRight)
    }

    private func setupTornado() {
        let tornado = SKSpriteNode(imageNamed: "torndo_image")
        tornado.name = "tornado"
        let actualGridWidth = tileSize * CGFloat(numColumns)
        tornado.size = CGSize(width: actualGridWidth * 1.5, height: tileSize * 3)
        // Старт ниже экрана, по центру сетки
        let startX = gridStartX + actualGridWidth / 2
        let startY = frame.minY - tornado.size.height
        tornado.position = CGPoint(x: startX, y: startY)
        tornado.zPosition = 1 // над фоном, под игроком/плитками
        addChild(tornado)
        tornadoNode = tornado
        
        // Сброс параметров
        tornadoSpeed = 0.0
        tornadoAcceleration = 0.0
        tornado.speed = 1.0

        // Плавное постоянное поднятие снизу до верхней границы экрана (медленно)
        let endY = frame.maxY + tornado.size.height
        let rise = SKAction.moveTo(y: endY, duration: 30.0)
        rise.timingMode = .linear
        tornado.run(rise)
    }
    
    private func setupPlayer() {
        // Получаем имя спрайта для выбранного скина
        let planeImageName = PlayerData.shared.getCurrentPlaneImageName()
        
        let player = SKSpriteNode(imageNamed: planeImageName)
        player.name = "player"
        player.size = CGSize(width: tileSize * 0.7, height: tileSize * 0.5)
        
        // Спавн на серой панели под сеткой
        let actualGridWidth = tileSize * CGFloat(numColumns)
        let playerX = gridStartX + actualGridWidth / 2
        let panelY = greyPlatformNode?.position.y ?? (gridStartY - tileSize / 2)
        let playerY = panelY
        
        player.position = CGPoint(x: playerX, y: playerY)
        player.zPosition = 3
        
        addChild(player)
        self.playerNode = player
    }
    
    private func setupUI() {
        // Кнопки интерфейса создаются в SwiftUI. Здесь ничего не добавляем.
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
        
        if isGameOver { return }
        if self.isPaused { return }
        
        guard canPlayerMove else { return }
        
        // Новая логика: определяем ряд/колонку с учётом текущего смещения рядов
        guard let (tappedRow, tappedCol) = tileIndexAtScenePoint(location) else { return }
        
        let expectedMove = correctPath[currentPathIndex]
        print("TAP DEBUG -> tapped (r: \(tappedRow), c: \(tappedCol)), expected (r: \(expectedMove.row), c: \(expectedMove.col)), idx: \(currentPathIndex)")
        
        // Добавляем проверку условий
        let isCorrectRow = tappedRow == expectedMove.row
        let isCorrectCol = tappedCol == expectedMove.col
        print("Check conditions -> correctRow: \(isCorrectRow), correctCol: \(isCorrectCol)")
        
        if isCorrectRow && isCorrectCol {
            print("Correct move! Calling movePlayer...")
            movePlayer(toRow: tappedRow, toCol: tappedCol)
        } else {
            print("Incorrect move! Row match: \(isCorrectRow), Col match: \(isCorrectCol)")
            handleIncorrectMove()
        }
    }

    // Публичный метод для повторного показа пути (для кнопки в SwiftUI)
    func repeatPath() {
        showPath()
        run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.run { [weak self] in
                self?.hidePath()
            }
        ]))
    }
    
    // Определение индекса плитки под точкой касания с учётом смещений рядов
    private func tileIndexAtScenePoint(_ point: CGPoint) -> (row: Int, col: Int)? {
        for (rowIndex, rowNode) in rowNodes.enumerated() {
            // Проверяем вертикальные границы ряда
            let rowY = gridStartY + CGFloat(rowIndex) * tileSize
            if point.y < rowY || point.y > rowY + tileSize {
                continue
            }
            
            // Получаем смещение ряда
            let rowOffset = rowNode.position.x - gridStartX
            
            // Вычисляем позицию тапа относительно начала ряда с учетом смещения
            let relativeX = point.x - gridStartX - rowOffset
            
            // Проверяем горизонтальные границы
            if relativeX < 0 || relativeX > tileSize * CGFloat(numColumns) {
                continue
            }
            
            // Определяем индекс колонки
            let colIndex = Int(relativeX / tileSize)
            if colIndex >= 0 && colIndex < numColumns {
                return (row: rowIndex, col: colIndex)
            }
        }
        return nil
    }
    
    private func movePlayer(toRow: Int, toCol: Int) {
        print("Starting movePlayer with row: \(toRow), col: \(toCol)")
        
        guard let player = self.playerNode else {
            print("Error: Player node ref is nil!")
            return
        }
        
        // Целевая плитка
        let rowNode = rowNodes[toRow]
        print("Found row node at index: \(toRow)")
        
        guard rowNode.children.count > toCol else {
            print("Error: Column index \(toCol) out of bounds!")
            return
        }
        
        let tileNode = rowNode.children[toCol]
        print("Found tile node at column: \(toCol)")
        
        // Отсоединяем игрока от текущего родителя и прикрепляем к целевой плитке
        print("Current player parent: \(player.parent?.name ?? "none")")
        player.removeFromParent()
        tileNode.addChild(player)
        player.position = .zero
        player.zPosition = 10
        print("Player attached to new tile, position: \(player.position), zPosition: \(player.zPosition)")
        
        currentPathIndex += 1
        print("Current path index: \(currentPathIndex)/\(correctPath.count)")
        
        if currentPathIndex >= correctPath.count {
            winGame()
        }
    }
    
    private func handleIncorrectMove() {
        lives -= 1
        stars = lives // Обновляем звезды вместе с жизнями
        // Штраф за потерю звезды: -50 монет из монет уровня (не ниже нуля)
        levelCoins = max(0, levelCoins - 50)
        // Ураган сокращает дистанцию: рывок вперед на пол-плитки и рост скорости
        if let tornado = tornadoNode {
            tornado.position.y += tileSize * 0.5
            tornadoSpeed *= 1.15
        }
        updateLivesUI()
        
        if lives <= 0 {
            loseGame()
            } else {
            let shake = SKAction.moveBy(x: 10, y: 0, duration: 0.05)
            self.run(SKAction.repeat(SKAction.sequence([shake, shake.reversed(), shake.reversed(), shake]), count: 2))
        }
    }
    
    private func updateLivesUI() {
        // Обновление жизней теперь происходит через @Published свойство
        // и автоматически отображается в SwiftUI
    }
    
    private func winGame() {
        isGameOver = true
        gameOver = true
        didWin = true
        self.isPaused = true
        // Награда за победу: добавляем монеты уровня к общему балансу
        PlayerData.shared.coins += levelCoins
        print("YOU WIN! +\(levelCoins) coins. Total: \(PlayerData.shared.coins)")
    }
    
    private func loseGame() {
        isGameOver = true
        gameOver = true
        didWin = false
        self.isPaused = true
        // Награда за поражение — 0
        print("YOU LOSE! +0 coins. Total: \(PlayerData.shared.coins)")
    }
    
    // Алерт перенесён в SwiftUI-оверлей в ContentView
    
    func restartGame() {
        // Сбрасываем состояние текущей сцены (не создавая новую), чтобы SwiftUI-привязки сохранились
        self.isPaused = false
        removeAllActions()
        removeAllChildren()
        
        // Сброс игровых флагов и данных
        gameOver = false
        didWin = false
        isGameOver = false
        canPlayerMove = false
        currentPathIndex = 0
        correctPath.removeAll()
        pathSprites.removeAll()
        rowNodes.removeAll()
        playerNode = nil
        tornadoNode = nil

        // Жизни/звезды по умолчанию
        lives = 3
        stars = 3
        levelCoins = 150

        // Инициализируем сцену заново
        setupScene()
    }
    
    override func update(_ currentTime: TimeInterval) {
        var dt: CGFloat = 0
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        } else {
            dt = CGFloat(currentTime - lastUpdateTime)
            lastUpdateTime = currentTime
        }
        
        if isGameOver || self.isPaused || !canPlayerMove { return }
        guard let tornado = tornadoNode else { return }
        
        // Движение урагана вверх с ускорением
        tornado.position.y += tornadoSpeed * dt
        tornadoSpeed += tornadoAcceleration * dt
        
        // Проверка столкновения с игроком
        if let player = playerNode {
            // Переводим позицию игрока в координаты сцены
            let playerInScene = player.parent?.convert(player.position, to: self) ?? player.position
            let catchLineY = playerInScene.y - (player.size.height * 0.4)
            if tornado.position.y >= catchLineY {
                loseGame()
            }
        }
    }
}
