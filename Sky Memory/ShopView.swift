//
//  ShopView.swift
//  Sky Memory
//
//  Created by Рома Котов on 12.09.2025.
//

import SwiftUI

// Экран магазина
struct ShopView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var playerData = PlayerData.shared // Используем наш singleton
    private let availableSkins = PlayerData.getAvailableSkins() // Получаем список скинов
    
    var body: some View {
        ZStack {
            // Фоновое изображение
            Image("main_bg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea(.all)
            
            VStack {
                // Навигационная панель
                HStack {
                    // Кнопка возврата слева
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image("back_button")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 44, height: 44)
                    }
                    .padding(.leading, 16)
                    .padding(.top, 8)
                    
                    Spacer()
                    
                    // Заголовок по центру
                    Image("shop_label")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 20)
                        .padding(.top, 8)
                    
                    Spacer()
                    
                    // Панель монет справа
                    MoneyPanel(coins: playerData.coins) // Отображаем монеты из PlayerData
                        .padding(.trailing, 16)
                        .padding(.top, 8)
                }
                
                // ScrollView с панелями скинов
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 50) {
                        ForEach(availableSkins) { skin in
                            SkinPanel(skin: skin, playerData: playerData)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarHidden(true)
    }
}

// Компонент панели монет
struct MoneyPanel: View {
    let coins: Int
    
    var body: some View {
        ZStack {
            // Панель монет
            Image("money_panel")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)
            
            // Количество монет поверх панели
            Text("\(coins)")
                .font(.headline) // Уменьшаем размер шрифта
                .fontWeight(.bold)
                .foregroundColor(.white)
                .shadow(radius: 2)
        }
    }
}

// Компонент панели скина
struct SkinPanel: View {
    let skin: Skin
    @ObservedObject var playerData: PlayerData
    
    var body: some View {
        ZStack {
            // Изображение панели скина
            Image(skin.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300 ,height: 200)
            
            // Кнопка в правом нижнем углу
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: handleButtonTap) {
                        Image(buttonImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                    }
                    .padding(.trailing, 80)
                    .padding(.top, 90 )
                }
                Spacer()
            }
        }
        .frame(height: 100)
    }
    
    // Определяем, какую кнопку показать
    private var buttonImageName: String {
        if playerData.selectedSkinID == skin.id {
            return "inUse_button" // Скин выбран и используется
        } else if playerData.purchasedSkins.contains(skin.id) {
            return "use_button" // Скин куплен, но не используется
        } else {
            return "buy_button" // Скин не куплен
        }
    }
    
    // Обрабатываем нажатие на кнопку
    private func handleButtonTap() {
        if playerData.selectedSkinID == skin.id {
            // Кнопка "In Use" - ничего не делаем
            print("Скин уже используется")
        } else if playerData.purchasedSkins.contains(skin.id) {
            // Кнопка "Use" - выбираем скин
            playerData.selectSkin(skin: skin)
        } else {
            // Кнопка "Buy" - покупаем скин
            playerData.buySkin(skin: skin)
        }
    }
}

#Preview {
    ShopView()
}
