//
//  ContentView.swift
//  fill-light
//
//  Created by 李西西 on 2025/2/6.
//
import SwiftUI
import UIKit

// 添加颜色预设模型
struct ColorPreset: Codable, Identifiable {
    let id = UUID()
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
    let brightness: Double
}

struct ContentView: View {
    @State private var red: Double = 1.0
    @State private var green: Double = 1.0
    @State private var blue: Double = 1.0
    @State private var alpha: Double = 1.0
    @State private var isEditMode: Bool = true
    @State private var screenBrightness: Double = UIScreen.main.brightness
    @State private var savedPresets: [ColorPreset] = []
    
    // 添加数据持久化方法
    private func savePreset() {
        let newPreset = ColorPreset(red: red, green: green, blue: blue, 
                                  alpha: alpha, brightness: screenBrightness)
        savedPresets.append(newPreset)
        if let encoded = try? JSONEncoder().encode(savedPresets) {
            UserDefaults.standard.set(encoded, forKey: "ColorPresets")
        }
    }
    
    private func loadPresets() {
        if let data = UserDefaults.standard.data(forKey: "ColorPresets"),
           let decoded = try? JSONDecoder().decode([ColorPreset].self, from: data) {
            savedPresets = decoded
        }
    }
    
    // 添加应用预设方法
    private func applyPreset(_ preset: ColorPreset) {
        red = preset.red
        green = preset.green
        blue = preset.blue
        alpha = preset.alpha
        screenBrightness = preset.brightness
        UIScreen.main.brightness = preset.brightness
    }
    
    var body: some View {
        ZStack {
            Color(red: red, green: green, blue: blue, opacity: alpha)
                .ignoresSafeArea()
            
            if isEditMode {
                VStack {
                    // 预设颜色展示区域移到顶部
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(savedPresets) { preset in
                                Button(action: { applyPreset(preset) }) {
                                    Circle()
                                        .fill(Color(red: preset.red, 
                                                  green: preset.green,
                                                  blue: preset.blue,
                                                  opacity: preset.alpha))
                                        .frame(width: 50, height: 50)
                                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                                        .shadow(color: .black.opacity(0.3), radius: 3)
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(20)
                    .padding(.bottom, 10)
                    
                    // 控制面板
                    VStack {
                        ColorSlider(value: $red, color: .red, label: "红色")
                        ColorSlider(value: $green, color: .green, label: "绿色")
                        ColorSlider(value: $blue, color: .blue, label: "蓝色")
                        ColorSlider(value: $alpha, color: .gray, label: "透明度")
                        
                        HStack {
                            Image(systemName: "sun.min")
                                .foregroundColor(.white)
                            Slider(value: $screenBrightness, in: 0...1) { _ in
                                UIScreen.main.brightness = screenBrightness
                            }
                            Image(systemName: "sun.max")
                                .foregroundColor(.white)
                        }
                        .padding()
                        
                        HStack(spacing: 15) {
                            Button(action: savePreset) {
                                Text("保存当前颜色")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: { isEditMode.toggle() }) {
                                Text("切换到纯净模式")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(15)
                }
                .padding()
            } else {
                // 纯净模式下只保留切换按钮
                VStack {
                    Spacer()
                    Button(action: { isEditMode.toggle() }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding(.bottom)
                }
            }
        }
        .onAppear(perform: loadPresets)
    }
}

// 颜色滑块组件
struct ColorSlider: View {
    @Binding var value: Double
    let color: Color
    let label: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.white)
                .frame(width: 60)
            Slider(value: $value, in: 0...1)
                .accentColor(color)
            Text(String(format: "%.2f", value))
                .foregroundColor(.white)
                .frame(width: 50)
        }
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}
