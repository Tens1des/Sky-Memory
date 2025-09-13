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
    
    var body: some View {
        NavigationView {
            if showGameScene {
                // Игровая сцена
                if let scene = gameScene {
                    GameSceneView(scene: scene)
                } else {
                    // Показываем загрузочный индикатор, пока сцена не готова
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            } else {
                // Главное меню
                MainMenuView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            // Инициализируем сцену при появлении представления
            if gameScene == nil {
                let scene = GameScene()
                scene.scaleMode = .aspectFill
                gameScene = scene
            }
        }
    }
}

// Отдельное представление для игровой сцены и интерфейса
struct GameSceneView: View {
    @ObservedObject var scene: GameScene
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
                        }) {
                            Image("pause_button")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 44, height: 44)
                        }
                        
                        // Кнопка повтора
                        Button(action: {
                            print("Кнопка повтора нажата")
                        }) {
                            Image("repeat_button")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 44, height: 44)
                        }
                    }
                    .padding(.leading, 16)
                    .padding(.top, 8)
                    
                    Spacer()
                    
                    // Система здоровья по центру
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Image(index < health ? "fillHeart_icon" : "notFill_icon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                        }
                    }
                    .padding(.top, 8)
                    
                    Spacer()
                    
                    // Пустое место справа для баланса
                    Spacer()
                        .frame(width: 44)
                        .padding(.trailing, 16)
                }
                
                Spacer()
            }
            
            // Алерт паузы
            if showPauseAlert {
                PauseAlert(isPresented: $showPauseAlert)
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
                    HStack(spacing: 8) {
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
                        showMainMenu = true
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
            
            // Навигация к главному меню
            if showMainMenu {
                NavigationLink(destination: MainMenuView(), isActive: $showMainMenu) {
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
