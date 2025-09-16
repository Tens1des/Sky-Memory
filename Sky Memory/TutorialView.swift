//
//  TutorialView.swift
//  Sky Memory
//
//  Created by Рома Котов on 12.09.2025.
//

import SwiftUI

// Экран туториала
struct TutorialView: View {
    @State private var currentTutorialIndex = 0
    @State private var showGameScene = false
    
    private let tutorialImages = ["tutorial1", "tutorial2", "tutorial3", "tutorial4", "tutorial5"]
    
    var body: some View {
        Group {
            if showGameScene {
                // При нажатии Home закрываем TutorialView полностью, а не возвращаемся к сцене
                GameSceneView(scene: GameScene(size: UIScreen.main.bounds.size, level: 0), onHome: {
                    // Единое событие открытия главного меню
                    NotificationCenter.default.post(name: Notification.Name("OpenMainMenu"), object: nil)
                })
            } else {
                ZStack {
                    // Фоновое изображение
                    Image("main_bg")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea(.all)
                    
                    // Текущая картинка туториала
                    Image(tutorialImages[currentTutorialIndex])
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea(.all)
                        .onTapGesture {
                            nextTutorial()
                        }
                    
                    // Индикатор прогресса внизу
                    VStack {
                        Spacer()
                        
                        HStack(spacing: 10) {
                            ForEach(0..<tutorialImages.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentTutorialIndex ? Color.white : Color.white.opacity(0.3))
                                    .frame(width: 10, height: 10)
                            }
                        }
                        .padding(.bottom, 50)
                    }
                }
                .navigationBarHidden(true)
            }
        }
    }
    
    private func nextTutorial() {
        if currentTutorialIndex < tutorialImages.count - 1 {
            currentTutorialIndex += 1
        } else {
            // Завершение туториала - переход к игре
            showGameScene = true
        }
    }
}

#Preview {
    TutorialView()
}
