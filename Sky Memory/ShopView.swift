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
    @State private var coins: Int = 0 // По умолчанию 0 монет
    
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
                    MoneyPanel(coins: coins)
                        .padding(.trailing, 16)
                        .padding(.top, 8)
                }
                
                // ScrollView с панелями скинов
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 50) {
                        // Панель скина 1
                        SkinPanel(
                            skinImage: "skin1_panel",
                            onBuyTap: {
                                print("Skin 1 buy tapped")
                            }
                        )
                        
                        // Панель скина 2
                        SkinPanel(
                            skinImage: "skin2_panel",
                            onBuyTap: {
                                print("Skin 2 buy tapped")
                            }
                        )
                        
                        // Панель скина 3
                        SkinPanel(
                            skinImage: "skin3_panel",
                            onBuyTap: {
                                print("Skin 3 buy tapped")
                            }
                        )
                        
                        // Панель скина 4
                        SkinPanel(
                            skinImage: "skin4_panel",
                            onBuyTap: {
                                print("Skin 4 buy tapped")
                            }
                        )
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
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .shadow(radius: 2)
        }
    }
}

// Компонент панели скина
struct SkinPanel: View {
    let skinImage: String
    let onBuyTap: () -> Void
    
    var body: some View {
        ZStack {
            // Изображение панели скина
            Image(skinImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300 ,height: 200)
            
            // Кнопка buy в правом нижнем углу
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: onBuyTap) {
                        Image("buy_button")
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
}

#Preview {
    ShopView()
}
