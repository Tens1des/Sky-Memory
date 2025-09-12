//
//  MainMenuView.swift
//  Sky Memory
//
//  Created by Рома Котов on 12.09.2025.
//

import SwiftUI

// Модель для уровня
struct Level: Identifiable {
    let id = UUID()
    let number: Int
    var stars: Int = 0 // По умолчанию 0 звёзд
}

struct MainMenuView: View {
    @State private var showSettings = false
    @State private var levels: [Level] = []
    
    init() {
        // Инициализируем 10 уровней с 0 звёздами
        _levels = State(initialValue: (1...10).map { Level(number: $0, stars: 0) })
    }
    
    var body: some View {
        ZStack {
            // Фоновое изображение
            Image("main_bg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea(.all)
            
            // Основной контент
            VStack {
                // Навигационная панель
                HStack(alignment: .top) {
                    // Левая часть: Кнопки задач и достижений
                    VStack(spacing: 8) {
                        NavigationLink(destination: TasksView()) {
                            Image("tasks_button")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 44, height: 44)
                        }
                        
                        NavigationLink(destination: AchivView()) {
                            Image("achive_button")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 44, height: 44)
                        }
                    }
                    .padding(.leading, 16)
                    .padding(.top, 8)
                    
                    Spacer()
                    
                    // Логотип по центру
                    Image("logo_image")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 60)
                    
                    Spacer()
                    
                    // Кнопка настроек справа
                    Button(action: {
                        showSettings = true
                    }) {
                        Image("settings_button")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 44, height: 44)
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 8)
                }
                
                Spacer()
                
                // Центральный контент: ScrollView для уровней
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: [
                        GridItem(.flexible())
                    ], spacing: 15) {
                        ForEach(levels) { level in
                            LevelButton(level: level) {
                                // Действие при выборе уровня
                                print("Выбран уровень \(level.number)")
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Кнопка магазина в левом нижнем углу
                HStack {
                    NavigationLink(destination: ShopView()) {
                        Image("shop_button")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 110, height: 60)
                    }
                    .padding(.leading, 280)
                    .padding(.bottom, 20)
                    
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
        .overlay(
            // Кастомный алерт настроек
            Group {
                if showSettings {
                    SettingsAlert(isPresented: $showSettings)
                }
            }
        )
    }
}

// Кастомный слайдер
struct CustomSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Фон слайдера (не заполненная часть) - фиксированное расположение
                Image("notFill_image")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 12)
                
                // Заполненная часть слайдера - фиксированное расположение с маской
                Image("fillSlider_image")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 12)
                    .mask(
                        Rectangle()
                            .frame(width: geometry.size.width * CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)), height: 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    )
                
                // Ползунок
                Image("pin_image")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .offset(x: geometry.size.width * CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) - 10)
            }
        }
        .frame(height: 20)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    let sliderWidth: CGFloat = 120 // Фиксированная ширина слайдера
                    let percentage = gesture.location.x / sliderWidth
                    let newValue = range.lowerBound + percentage * (range.upperBound - range.lowerBound)
                    value = max(range.lowerBound, min(range.upperBound, newValue))
                }
        )
    }
}

// Кастомный алерт настроек
struct SettingsAlert: View {
    @Binding var isPresented: Bool
    @State private var musicVolume: Double = 0.7
    @State private var soundVolume: Double = 0.7
    
    var body: some View {
        ZStack {
            // Фон с возможностью закрытия при нажатии
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            // Синяя панель настроек
            VStack(spacing: 20) {
                // Заголовок SETTINGS
                Image("settings_label")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 20)
                
                // Слайдер музыки
                HStack(spacing: 15) {
                    Image("music_label")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                    
                    CustomSlider(value: $musicVolume, range: 0...1)
                        .frame(width: 120)
                }
                .padding(.horizontal, 20)
                
                // Слайдер звука
                HStack(spacing: 15) {
                    Image("sound_label")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                    
                    CustomSlider(value: $soundVolume, range: 0...1)
                        .frame(width: 120)
                }
                .padding(.horizontal, 20)
                
                // Кнопка домой
                Button(action: {
                    isPresented = false
                }) {
                    Image("home_button")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                }
                .padding(.top, 10)
            }
            .background(
                Image("blue_panel")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                
            )
            .frame(width: 350, height: 250)
            //.cornerRadius(20)
            .scaleEffect(isPresented ? 1.0 : 0.8)
            .opacity(isPresented ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.3), value: isPresented)
        }
    }
}

// Компонент для кнопки уровня
struct LevelButton: View {
    let level: Level
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Фон уровня
                Image("lvl_bg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 100)
                   // .cornerRadius(15)
                
                VStack(spacing: 8) {
                    // Номер уровня
                    Text("\(level.number)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                    
                    // Звёзды (одна картинка)
                    Image(starImageName(for: level.stars))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 30)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Функция для определения изображения звезды
    private func starImageName(for stars: Int) -> String {
        switch stars {
        case 0:
            return "zeroStar_icon" // 0 звёзд
        case 1:
            return "oneStar_icon" // 1 звезда
        case 2:
            return "twoStar_icon" // 2 звезды
        case 3:
            return "threeStar_icon" // 3 звезды
        default:
            return "zeroStar_icon" // По умолчанию 0 звёзд
        }
    }
}


#Preview {
    MainMenuView()
}
