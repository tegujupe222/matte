//
//  VoiceAssistantScreen.swift
//  Matte
//
//  Created by Igasaki Gouta on 2025/08/04.
//

import SwiftUI
import Speech
import AVFoundation

struct VoiceAssistantScreen: View {
    @StateObject private var aiService = AIService()
    @State private var isListening = false
    @State private var recognizedText = ""
    @State private var showingSettings = false
    @State private var voiceCommands: [VoiceCommand] = []
    @State private var showingCommandHelp = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // 音声アシスタントメイン
                    VoiceAssistantMainCard(
                        isListening: $isListening,
                        recognizedText: $recognizedText,
                        onStartListening: startListening,
                        onStopListening: stopListening
                    )
                    
                    // 音声コマンド一覧
                    VoiceCommandsCard(
                        commands: voiceCommands,
                        onCommandTap: { command in
                            showingCommandHelp = true
                        }
                    )
                    
                    // 音声設定
                    VoiceSettingsCard()
                    
                    // 音声テスト
                    VoiceTestCard()
                    
                    // ヘルプ・ヒント
                    VoiceHelpCard()
                }
                .padding()
            }
            .navigationTitle("音声アシスタント")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("設定") {
                        showingSettings = true
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                VoiceSettingsView()
            }
            .sheet(isPresented: $showingCommandHelp) {
                VoiceCommandHelpView()
            }
            .onAppear {
                loadVoiceCommands()
            }
        }
    }
    
    private func loadVoiceCommands() {
        voiceCommands = [
            VoiceCommand(
                command: "セキュリティチェック",
                action: .checkSecurity,
                description: "現在のセキュリティ状況を確認",
                isEnabled: true
            ),
            VoiceCommand(
                command: "緊急通話",
                action: .emergencyCall,
                description: "緊急連絡先に電話",
                isEnabled: true
            ),
            VoiceCommand(
                command: "警告を読む",
                action: .readAlerts,
                description: "最新の警告を読み上げ",
                isEnabled: true
            ),
            VoiceCommand(
                command: "設定を開く",
                action: .openSettings,
                description: "設定画面を開く",
                isEnabled: true
            ),
            VoiceCommand(
                command: "家族に電話",
                action: .callFamily,
                description: "家族に電話",
                isEnabled: true
            )
        ]
    }
    
    private func startListening() {
        aiService.startListening()
        isListening = true
    }
    
    private func stopListening() {
        aiService.stopListening()
        isListening = false
    }
}

struct VoiceAssistantMainCard: View {
    @Binding var isListening: Bool
    @Binding var recognizedText: String
    let onStartListening: () -> Void
    let onStopListening: () -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            // メイン音声ボタン
            Button(action: {
                if isListening {
                    onStopListening()
                } else {
                    onStartListening()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(isListening ? Color.red : Color.blue)
                        .frame(width: 120, height: 120)
                        .scaleEffect(isListening ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: isListening)
                    
                    Image(systemName: isListening ? "stop.fill" : "mic.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // 状態表示
            VStack(spacing: 10) {
                Text(isListening ? "音声を聞いています..." : "タップして話してください")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(isListening ? .red : .primary)
                
                if isListening {
                    HStack {
                        ForEach(0..<3) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.red)
                                .frame(width: 4, height: 20)
                                .scaleEffect(y: isListening ? 1.0 : 0.3)
                                .animation(
                                    Animation.easeInOut(duration: 0.5)
                                        .repeatForever()
                                        .delay(Double(index) * 0.1),
                                    value: isListening
                                )
                        }
                    }
                }
            }
            
            // 認識されたテキスト
            if !recognizedText.isEmpty {
                VStack(spacing: 10) {
                    Text("認識された内容:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(recognizedText)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
            }
            
            // ヒント
            Text("「セキュリティチェック」や「緊急通話」などと言ってみてください")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct VoiceCommandsCard: View {
    let commands: [VoiceCommand]
    let onCommandTap: (VoiceCommand) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "list.bullet")
                    .foregroundColor(.purple)
                Text("音声コマンド")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(commands) { command in
                    VoiceCommandRow(command: command) {
                        onCommandTap(command)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct VoiceCommandRow: View {
    let command: VoiceCommand
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: commandIcon)
                    .foregroundColor(commandColor)
                    .frame(width: 25)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(command.command)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(command.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 5) {
                    if command.isEnabled {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var commandIcon: String {
        switch command.action {
        case .checkSecurity: return "shield.fill"
        case .emergencyCall: return "phone.fill"
        case .readAlerts: return "exclamationmark.triangle.fill"
        case .openSettings: return "gearshape.fill"
        case .callFamily: return "person.2.fill"
        }
    }
    
    private var commandColor: Color {
        switch command.action {
        case .checkSecurity: return .green
        case .emergencyCall: return .red
        case .readAlerts: return .orange
        case .openSettings: return .blue
        case .callFamily: return .purple
        }
    }
}

struct VoiceSettingsCard: View {
    @State private var isVoiceEnabled = true
    @State private var isVibrationEnabled = true
    @State private var voiceSpeed: Double = 0.5
    @State private var voiceVolume: Double = 0.8
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.blue)
                Text("音声設定")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 15) {
                Toggle("音声アシスタントを有効にする", isOn: $isVoiceEnabled)
                    .font(.subheadline)
                
                Toggle("振動フィードバック", isOn: $isVibrationEnabled)
                    .font(.subheadline)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("音声速度")
                            .font(.subheadline)
                        Spacer()
                        Text("\(Int(voiceSpeed * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $voiceSpeed, in: 0.3...1.0, step: 0.1)
                        .accentColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("音量")
                            .font(.subheadline)
                        Spacer()
                        Text("\(Int(voiceVolume * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $voiceVolume, in: 0.0...1.0, step: 0.1)
                        .accentColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct VoiceTestCard: View {
    @State private var testText = "こんにちは、Matteです。音声アシスタントのテストです。"
    @State private var isSpeaking = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundColor(.green)
                Text("音声テスト")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 15) {
                TextField("テスト用のテキスト", text: $testText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
                
                Button(action: speakTestText) {
                    HStack {
                        Image(systemName: isSpeaking ? "stop.fill" : "play.fill")
                        Text(isSpeaking ? "停止" : "音声テスト")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isSpeaking ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(testText.isEmpty)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
    
    private func speakTestText() {
        if isSpeaking {
            // 音声停止
            isSpeaking = false
        } else {
            // 音声再生
            let utterance = AVSpeechUtterance(string: testText)
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            utterance.rate = 0.5
            utterance.pitchMultiplier = 1.0
            utterance.volume = 0.8
            
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speak(utterance)
            isSpeaking = true
            
            // 音声終了後にフラグをリセット
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isSpeaking = false
            }
        }
    }
}

struct VoiceHelpCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(.orange)
                Text("ヘルプ・ヒント")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                HelpRow(
                    title: "音声認識のコツ",
                    description: "はっきりと、ゆっくり話してください",
                    icon: "mic.fill"
                )
                
                HelpRow(
                    title: "環境について",
                    description: "静かな場所で使用することをお勧めします",
                    icon: "ear.fill"
                )
                
                HelpRow(
                    title: "コマンド例",
                    description: "「セキュリティチェック」「緊急通話」など",
                    icon: "text.bubble.fill"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct HelpRow: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 25)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 5)
    }
}

// MARK: - Supporting Views
struct VoiceSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isVoiceEnabled = true
    @State private var isVibrationEnabled = true
    @State private var voiceSpeed: Double = 0.5
    @State private var voiceVolume: Double = 0.8
    @State private var selectedLanguage = "ja-JP"
    
    let languages = [
        ("日本語", "ja-JP"),
        ("English", "en-US"),
        ("中文", "zh-CN"),
        ("한국어", "ko-KR")
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本設定") {
                    Toggle("音声アシスタント", isOn: $isVoiceEnabled)
                    Toggle("振動フィードバック", isOn: $isVibrationEnabled)
                }
                
                Section("音声設定") {
                    Picker("言語", selection: $selectedLanguage) {
                        ForEach(languages, id: \.1) { language in
                            Text(language.0).tag(language.1)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("音声速度")
                            Spacer()
                            Text("\(Int(voiceSpeed * 100))%")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $voiceSpeed, in: 0.3...1.0, step: 0.1)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("音量")
                            Spacer()
                            Text("\(Int(voiceVolume * 100))%")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $voiceVolume, in: 0.0...1.0, step: 0.1)
                    }
                }
                
                Section("音声認識設定") {
                    Toggle("自動音声認識", isOn: .constant(true))
                    Toggle("部分認識結果表示", isOn: .constant(true))
                }
                
                Section("アクセシビリティ") {
                    Toggle("大きな文字", isOn: .constant(false))
                    Toggle("高コントラスト", isOn: .constant(false))
                }
            }
            .navigationTitle("音声設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct VoiceCommandHelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    let commands = [
        ("セキュリティチェック", "現在のセキュリティ状況を音声で報告します", "shield.fill", Color.green),
        ("緊急通話", "緊急連絡先に電話をかけます", "phone.fill", Color.red),
        ("警告を読む", "最新のセキュリティ警告を読み上げます", "exclamationmark.triangle.fill", Color.orange),
        ("設定を開く", "設定画面を開きます", "gearshape.fill", Color.blue),
        ("家族に電話", "家族に電話をかけます", "person.2.fill", Color.purple)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 15) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("音声コマンドヘルプ")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("以下のコマンドを話すことで、アプリを操作できます")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack(spacing: 15) {
                        ForEach(commands, id: \.0) { command in
                            CommandHelpRow(
                                command: command.0,
                                description: command.1,
                                icon: command.2,
                                color: command.3
                            )
                        }
                    }
                    
                    VStack(spacing: 10) {
                        Text("使用のヒント")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            TipRow(text: "はっきりと、ゆっくり話してください")
                            TipRow(text: "静かな環境で使用してください")
                            TipRow(text: "コマンドの後に少し待ってください")
                            TipRow(text: "「Matte」と呼びかけてからコマンドを言うこともできます")
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("コマンドヘルプ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CommandHelpRow: View {
    let command: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(command)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("「\(command)」")
                .font(.caption)
                .foregroundColor(.blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

struct TipRow: View {
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
                .font(.caption)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    VoiceAssistantScreen()
}
