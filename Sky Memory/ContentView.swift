//
//  ContentView.swift
//  Sky Memory
//
//  Created by Рома Котов on 12.09.2025.
//

import SwiftUI
import SpriteKit

struct SKViewRepresentable: UIViewRepresentable {
    var scene: SKScene
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.isMultipleTouchEnabled = true
        view.presentScene(scene)
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        // Обновления, если необходимо
    }
}

struct ContentView: View {
    @State private var gameScene: GameScene?
    @State private var showGameScene = false
    @State private var selectedLevel: Int = 0
    @State private var notificationObserver: NSObjectProtocol?
    
    var body: some View {
        NavigationView {
            if showGameScene {
                // Игровая сцена
                if let scene = gameScene {
                    GameSceneView(scene: scene, onHome: {
                        // Возвращаемся на главный экран без автозапуска туториала/уровня
                        showGameScene = false
                        gameScene = nil
                    })
                } else {
                    // Показываем загрузочный индикатор, пока сцена не готова
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            } else {
                // Главное меню
                MainMenuView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Menu {
                                Button("Уровень 1") {
                                    startGame(level: 0)
                                }
                                Button("Уровень 2") {
                                    startGame(level: 1)
                                }
                            } label: {
                                Text("Выбрать уровень")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                        }
                    }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            // Единая подписка для открытия главного меню
            notificationObserver = NotificationCenter.default.addObserver(forName: Notification.Name("OpenMainMenu"), object: nil, queue: .main) { _ in
                showGameScene = false
                gameScene = nil
            }
            // Подписка на запуск уровней с главного меню
            NotificationCenter.default.addObserver(forName: Notification.Name("StartLevel"), object: nil, queue: .main) { note in
                if let number = note.object as? Int {
                    // Убираем туториал: любой выбранный уровень запускает игру
                    let levelIndex = (number == 2) ? 1 : 0
                    startGame(level: levelIndex)
                }
            }
        }
        .onDisappear {
            if let observer = notificationObserver {
                NotificationCenter.default.removeObserver(observer)
                notificationObserver = nil
            }
        }
    }
    
    private func startGame(level: Int) {
        selectedLevel = level
        let scene = GameScene(size: UIScreen.main.bounds.size, level: level)
        scene.scaleMode = .aspectFill
        gameScene = scene
        showGameScene = true
    }
}

// Отдельное представление для игровой сцены и интерфейса
struct GameSceneView: View {
    @ObservedObject var scene: GameScene
    let onHome: () -> Void
    @ObservedObject private var playerData = PlayerData.shared
    @State private var health: Int = 3 // Максимальное здоровье
    @State private var showPauseAlert = false
    
    var body: some View {
        ZStack {
            // Игровая сцена
            SKViewRepresentable(scene: scene)
                .ignoresSafeArea()
            
            // Игровой интерфейс поверх сцены
            VStack {
                // Навигационная панель
                HStack {
                    VStack(spacing: 8) {
                        // Кнопка паузы
                        Button(action: {
                            showPauseAlert = true
                            scene.pauseGame()
                        }) {
                            Image("pause_button")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 44, height: 44)
                        }
                        
                        // Кнопка повтора (SwiftUI вызывает метод сцены)
                        Button(action: {
                            scene.repeatPath()
                        }) {
                            Image("repeat_button")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 44, height: 44)
                        }
                    }
                    .padding(.leading, 18)
                    .padding(.top, 8)
                    
                    Spacer().frame(width: 15)
                    
                    // Индикаторы жизней на панели hp_panel (увеличиваем высоту)
                    ZStack {
                        Image("hp_panel")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 80)
                        HStack(spacing: 8) {
                            ForEach(0..<3) { index in
                                Image(index < scene.lives ? "fillHeart_icon" : "notFill_icon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 44, height: 44)
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                    
                    // Панель для звезд и монет (увеличиваем высоту)
                    ZStack {
                        Image("panelStar_image")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 76)
                        VStack(alignment: .trailing, spacing: 2) {
                            HStack(spacing: 6) {
                                ForEach(0..<3) { index in
                                    Image(index < scene.stars ? "fillStar_icon" : "notFillStar_icon")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 26, height: 26)
                                }
                            }
                            LevelCoinCounterView(scene: scene)
                        }
                        .padding(.horizontal, 14)
                    }
                    .padding(.trailing, 16)
                }
                
                Spacer()
            }
            
            // Алерт победы/поражения
            if scene.gameOver {
                GameOverOverlay(didWin: scene.didWin,
                                 stars: scene.stars,
                                 rewardCoins: scene.didWin ? scene.levelCoins : 0,
                                 onRestart: { scene.restartGame() },
                                 onHome: {
                                     NotificationCenter.default.post(name: Notification.Name("OpenMainMenu"), object: nil)
                                 })
            }
            
            // Алерт паузы
            if showPauseAlert {
                PauseAlert(isPresented: $showPauseAlert)
                    .environmentObject(scene)
            }
        }
        .navigationBarHidden(true)
    }
}

// Алерт паузы
struct PauseAlert: View {
    @Binding var isPresented: Bool
    @State private var musicVolume: Double = 0.5
    @State private var soundVolume: Double = 0.7
    @State private var showMainMenu = false
    @EnvironmentObject var scene: GameScene
    
    var body: some View {
        ZStack {
            // Полупрозрачный фон
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            // Панель алерта
            VStack(spacing: 20) {
                // Заголовок
                Image("pause_label")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 25)
                
                // Слайдеры
                VStack(spacing: 12) {
                    // Слайдер музыки
                    HStack(spacing: 8) {
                        Image("music_label")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 12)
                        
                        CustomSlider(value: $musicVolume, range: 0...1)
                            .frame(width: 80, height: 15)
                    }
                    
                    // Слайдер звука
                    VStack(spacing: 15) {
                        Image("sound_label")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 12)
                        
                        CustomSlider(value: $soundVolume, range: 0...1)
                            .frame(width: 80, height: 15)
                    }
                }
                
                // Кнопки
                HStack(spacing: 15) {
                    // Кнопка домой
                    Button(action: {
                        print("Home button tapped")
                        isPresented = false
                        scene.resumeGame()
                        NotificationCenter.default.post(name: Notification.Name("OpenMainMenu"), object: nil)
                    }) {
                        Image("home_button")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 45)
                    }
                    
                    // Кнопка перезапуска
                    Button(action: {
                        print("Restart button tapped")
                        isPresented = false
                        scene.restartGame()
                    }) {
                        Image("restart_button")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 45)
                    }
                    
                    // Кнопка продолжения
                    Button(action: {
                        print("Continue button tapped")
                        isPresented = false
                        scene.resumeGame()
                    }) {
                        Image("countine_button")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 45)
                    }
                }
            }
            .padding(25)
            .background(
                Image("blue_panel")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            )
            .frame(width: 350, height: 280)
            
            // Навигация перенесена через onHome
        }
    }
}

//# MARK: - Game Over Overlay
struct GameOverOverlay: View {
    let didWin: Bool
    let stars: Int
    let rewardCoins: Int
    let onRestart: () -> Void
    let onHome: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text(didWin ? "YOU WIN!" : "YOU LOSE!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 8)
                
                // Звезды
                HStack(spacing: 12) {
                    ForEach(0..<3) { index in
                        Image(index < stars ? "fillStar_icon" : "notFillStar_icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                    }
                }

                // Награда
                HStack(spacing: 8) {
                    Text("+\(rewardCoins)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Image("money_icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 26, height: 26)
                }
                .padding(.top, 4)

                // Кнопки
                HStack(spacing: 40) {
                    Button(action: onRestart) {
                        Image("restart_button")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 45)
                    }
                    Button(action: onHome) {
                        Image("home_button")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 45)
                    }
                }
            }
            .padding(50)
            .background(
                Image("alert_panel")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            )
            .frame(width: 320, height: 300)
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: didWin)
    }
}

struct CoinCounterView: View {
    @ObservedObject private var playerData = PlayerData.shared
    var body: some View {
        HStack(spacing: 6) {
            Image("money_icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 24)
            Text("\(playerData.coins)")
                .font(.headline)
                .foregroundColor(.white)
                .shadow(radius: 2)
        }
    }
}

struct LevelCoinCounterView: View {
    @ObservedObject var scene: GameScene
    var body: some View {
        HStack(spacing: 6) {
            Image("money_icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 18)
            Text("+\(scene.levelCoins)")
                .font(.subheadline)
                .foregroundColor(.white)
                .shadow(radius: 1)
        }
    }
}

#Preview {
    ContentView()
}
