//
//  AchivView.swift
//  Sky Memory
//
//  Created by Рома Котов on 12.09.2025.
//

import SwiftUI

// Экран достижений
struct AchivView: View {
    @Environment(\.presentationMode) var presentationMode
    
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
                    Image("achiv_label")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 20)
                        .padding(.top, 8)
                    
                    Spacer()
                    
                    // Пустое место справа для баланса
                    Spacer()
                        .frame(width: 44)
                        .padding(.trailing, 16)
                }
                
                // ScrollView с панелями достижений
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Панель достижения 1
                        AchivPanel(
                            achivImage: "achiv1",
                            onSquareTap: {
                                print("Achiv 1 square tapped")
                            }
                        )
                        
                        // Панель достижения 2
                        AchivPanel(
                            achivImage: "achiv2",
                            onSquareTap: {
                                print("Achiv 2 square tapped")
                            }
                        )
                        
                        // Панель достижения 3
                        AchivPanel(
                            achivImage: "achiv3",
                            onSquareTap: {
                                print("Achiv 3 square tapped")
                            }
                        )
                        
                        // Панель достижения 4
                        AchivPanel(
                            achivImage: "achiv4",
                            onSquareTap: {
                                print("Achiv 4 square tapped")
                            }
                        )
                        
                        // Панель достижения 5
                        AchivPanel(
                            achivImage: "achiv5",
                            onSquareTap: {
                                print("Achiv 5 square tapped")
                            }
                        )
                        
                        // Панель достижения 6
                        AchivPanel(
                            achivImage: "achiv6",
                            onSquareTap: {
                                print("Achiv 6 square tapped")
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

// Компонент панели достижения
struct AchivPanel: View {
    let achivImage: String
    let onSquareTap: () -> Void
    
    var body: some View {
        ZStack {
            // Изображение достижения
            Image(achivImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 100)
            
            // Кнопка square_place поверх изображения справа
            VStack {
                HStack {
                    Spacer()
                    Button(action: onSquareTap) {
                        Image("square_place")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                    }
                    .padding(.trailing, 70)
                    .padding(.top, 15)
                }
                Spacer()
            }
        }
        .frame(height: 100)
    }
}

#Preview {
    AchivView()
}
