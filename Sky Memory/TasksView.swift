//
//  TasksView.swift
//  Sky Memory
//
//  Created by Рома Котов on 12.09.2025.
//

import SwiftUI

// Экран задач
struct TasksView: View {
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
                    Image("daily_label")
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
                
                // ScrollView с панелями задач
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Панель задачи 1
                        TaskPanel(
                            taskImage: "task1",
                            onSquareTap: {
                                print("Task 1 square tapped")
                            }
                        )
                        
                        // Панель задачи 2
                        TaskPanel(
                            taskImage: "task2",
                            onSquareTap: {
                                print("Task 2 square tapped")
                            }
                        )
                        
                        // Панель задачи 3
                        TaskPanel(
                            taskImage: "task3",
                            onSquareTap: {
                                print("Task 3 square tapped")
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

// Компонент панели задачи
struct TaskPanel: View {
    let taskImage: String
    let onSquareTap: () -> Void
    
    var body: some View {
        ZStack {
            // Изображение задачи
            Image(taskImage)
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
    TasksView()
}
