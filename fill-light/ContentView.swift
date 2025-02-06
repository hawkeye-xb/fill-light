//
//  ContentView.swift
//  fill-light
//
//  Created by 李西西 on 2025/2/6.
//
import SwiftUI
import UIKit
import AVFoundation
import Photos

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
    @State private var isSelfieMode: Bool = false
    @State private var screenBrightness: Double = UIScreen.main.brightness
    @State private var savedPresets: [ColorPreset] = []
    
    private func applyPreset(_ preset: ColorPreset) {
        red = preset.red
        green = preset.green
        blue = preset.blue
        alpha = preset.alpha
        screenBrightness = preset.brightness
        UIScreen.main.brightness = preset.brightness
    }
    
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
    
    // 添加删除预设方法
    private func deletePreset(_ preset: ColorPreset) {
        savedPresets.removeAll { $0.id == preset.id }
        if let encoded = try? JSONEncoder().encode(savedPresets) {
            UserDefaults.standard.set(encoded, forKey: "ColorPresets")
        }
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
                                .contextMenu {
                                    Button(role: .destructive, action: { deletePreset(preset) }) {
                                        Label("删除", systemImage: "trash")
                                    }
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
                            // 修改按钮布局
                            VStack(spacing: 12) {
                                HStack(spacing: 20) {
                                    Button(action: savePreset) {
                                        VStack {
                                            Image(systemName: "square.and.arrow.down")
                                                .font(.system(size: 20))
                                            Text("保存")
                                                .font(.system(size: 14))
                                        }
                                        .foregroundColor(.white)
                                        .frame(width: 60)
                                        .padding(.vertical, 8)
                                        .background(Color.green)
                                        .cornerRadius(10)
                                    }
                                    
                                    Button(action: { isEditMode.toggle() }) {
                                        VStack {
                                            Image(systemName: "eye")
                                                .font(.system(size: 20))
                                            Text("纯净")
                                                .font(.system(size: 14))
                                        }
                                        .foregroundColor(.white)
                                        .frame(width: 60)
                                        .padding(.vertical, 8)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                    }
                                    
                                    Button(action: { 
                                        isEditMode = false
                                        isSelfieMode = true 
                                    }) {
                                        VStack {
                                            Image(systemName: "camera")
                                                .font(.system(size: 20))
                                            Text("自拍")
                                                .font(.system(size: 14))
                                        }
                                        .foregroundColor(.white)
                                        .frame(width: 60)
                                        .padding(.vertical, 8)
                                        .background(Color.purple)
                                        .cornerRadius(10)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(15)
                }
                .padding()
            } else if isSelfieMode {
                CameraView(isSelfieMode: $isSelfieMode, isEditMode: $isEditMode)
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

// 添加相机视图
struct CameraView: View {
    @Binding var isSelfieMode: Bool
    @Binding var isEditMode: Bool
    @StateObject private var camera = CameraModel()
    
    var body: some View {
        ZStack {
            // 相机预览
            CameraPreviewView(camera: camera)
                .frame(width: 300, height: 400)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 2)
                )
            
            // 控制按钮
            VStack {
                HStack {
                    Button(action: {
                        isSelfieMode = false
                        isEditMode = true  // 返回编辑模式
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                
                Spacer()
                
                Button(action: { camera.takePicture() }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.3), lineWidth: 2)
                                .padding(4)
                        )
                }
                .padding(.bottom, 30)
            }
            .padding()
        }
    }
}

// 相机预览视图
struct CameraPreviewView: UIViewRepresentable {
    @ObservedObject var camera: CameraModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// 相机模型
class CameraModel: NSObject, ObservableObject {
    var session = AVCaptureSession()
    var preview: AVCaptureVideoPreviewLayer!
    
    override init() {
        super.init()
        setupCamera()
    }
    
    func setupCamera() {
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                
                let output = AVCapturePhotoOutput()
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                
                DispatchQueue.global(qos: .background).async {
                    self.session.startRunning()
                }
            } catch {
                print("相机设置错误：\(error.localizedDescription)")
            }
        }
    }
    
    func takePicture() {
        guard let output = session.outputs.first as? AVCapturePhotoOutput else { return }
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(),
           let image = UIImage(data: imageData) {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
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
