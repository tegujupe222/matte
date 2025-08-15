//
//  AIService.swift
//  Matte
//
//  Created by Igasaki Gouta on 2025/08/04.
//

import Foundation
import SwiftUI
import Speech
import AVFoundation

// MARK: - AI Service Protocol
protocol AIServiceProtocol {
    func analyzeScamContent(_ content: String, type: ScamType) async throws -> ScamAnalysisResult
    func generateSafetyRecommendations(_ context: String) async throws -> [String]
    func answerUserQuestion(_ question: String) async throws -> String
    func generateEducationalContent(_ topic: String) async throws -> EducationalContent
    func analyzeCallRisk(_ phoneNumber: String, context: String?) async throws -> CallRiskAnalysis
    func analyzeEmailRisk(_ emailContent: String) async throws -> EmailRiskAnalysis
    func analyzeWebsiteRisk(_ url: String) async throws -> WebsiteRiskAnalysis
}

// MARK: - Scam Types
enum ScamType: String, CaseIterable {
    case phone = "phone"
    case email = "email"
    case website = "website"
    case sms = "sms"
    case socialMedia = "social_media"
    
    var displayName: String {
        switch self {
        case .phone: return "電話詐欺"
        case .email: return "メール詐欺"
        case .website: return "ウェブサイト詐欺"
        case .sms: return "SMS詐欺"
        case .socialMedia: return "SNS詐欺"
        }
    }
}

// MARK: - Analysis Results
struct ScamAnalysisResult {
    let isScam: Bool
    let confidence: Double // 0.0 - 1.0
    let riskLevel: RiskLevel
    let detectedThreats: [String]
    let recommendations: [String]
    let explanation: String
    let aiReasoning: String
}

struct CallRiskAnalysis {
    let riskLevel: RiskLevel
    let confidence: Double
    let detectedThreats: [String]
    let recommendations: [String]
    let callerInfo: String?
    let isKnownScammer: Bool
}

struct EmailRiskAnalysis {
    let riskLevel: RiskLevel
    let confidence: Double
    let detectedThreats: [String]
    let recommendations: [String]
    let senderAnalysis: String
    let contentAnalysis: String
    let isPhishing: Bool
}

struct WebsiteRiskAnalysis {
    let riskLevel: RiskLevel
    let confidence: Double
    let detectedThreats: [String]
    let recommendations: [String]
    let domainAnalysis: String
    let contentAnalysis: String
    let isSafe: Bool
}

struct EducationalContent {
    let title: String
    let content: String
    let difficulty: Difficulty
    let estimatedTime: TimeInterval
    let keyPoints: [String]
    let examples: [String]
}



// MARK: - AI Service
class AIService: ObservableObject {
    @Published var isListening = false
    @Published var recognizedText = ""
    @Published var voiceCommands: [VoiceCommand] = []
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    init() {
        setupVoiceCommands()
        requestSpeechAuthorization()
    }
    
    // MARK: - Voice Assistant
    private func setupVoiceCommands() {
        voiceCommands = [
            VoiceCommand(
                id: UUID(),
                command: "セキュリティチェック",
                action: .checkSecurity,
                description: "現在のセキュリティ状況を確認",
                isEnabled: true
            ),
            VoiceCommand(
                id: UUID(),
                command: "緊急通話",
                action: .emergencyCall,
                description: "緊急連絡先に電話",
                isEnabled: true
            ),
            VoiceCommand(
                id: UUID(),
                command: "警告を読む",
                action: .readAlerts,
                description: "最新の警告を読み上げ",
                isEnabled: true
            ),
            VoiceCommand(
                id: UUID(),
                command: "設定を開く",
                action: .openSettings,
                description: "設定画面を開く",
                isEnabled: true
            ),
            VoiceCommand(
                id: UUID(),
                command: "家族に電話",
                action: .callFamily,
                description: "家族に電話",
                isEnabled: true
            )
        ]
    }
    
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("音声認識が許可されました")
                case .denied:
                    print("音声認識が拒否されました")
                case .restricted:
                    print("音声認識が制限されています")
                case .notDetermined:
                    print("音声認識の許可が未決定です")
                @unknown default:
                    print("未知の音声認識ステータス")
                }
            }
        }
    }
    
    func startListening() {
        guard !isListening else { return }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            
            recognitionRequest.shouldReportPartialResults = true
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    self.recognizedText = result.bestTranscription.formattedString
                    self.processVoiceCommand(self.recognizedText)
                }
                
                if error != nil || result?.isFinal == true {
                    self.stopListening()
                }
            }
            
            isListening = true
        } catch {
            print("音声認識の開始に失敗しました: \(error)")
        }
    }
    
    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        isListening = false
        recognizedText = ""
    }
    
    private func processVoiceCommand(_ text: String) {
        let lowercasedText = text.lowercased()
        
        for command in voiceCommands where command.isEnabled {
            for trigger in command.action.voiceTriggers {
                if lowercasedText.contains(trigger.lowercased()) {
                    executeVoiceAction(command.action)
                    return
                }
            }
        }
    }
    
    private func executeVoiceAction(_ action: VoiceAction) {
        switch action {
        case .checkSecurity:
            // セキュリティ状況を音声で報告
            speak("セキュリティ状況を確認します。現在の保護状況は良好です。")
        case .emergencyCall:
            // 緊急通話を実行
            speak("緊急通話を開始します。")
        case .readAlerts:
            // 最新の警告を読み上げ
            speak("最新の警告をお読みします。")
        case .openSettings:
            // 設定画面を開く
            speak("設定画面を開きます。")
        case .callFamily:
            // 家族に電話
            speak("家族に電話します。")
        }
    }
    
    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 0.8
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    // MARK: - AI Analysis
    func analyzeCall(_ phoneNumber: String, callerName: String?) async -> RiskLevel {
        // 実際のAI分析ロジックをここに実装
        await Task.sleep(1_000_000_000) // 1秒待機
        
        // サンプルロジック
        if phoneNumber.contains("090") || phoneNumber.contains("080") {
            return .suspicious
        } else if phoneNumber.contains("0120") || phoneNumber.contains("0800") {
            return .safe
        } else {
            return .dangerous
        }
    }
    
    func analyzeEmail(_ sender: String, subject: String, content: String) async -> AlertSeverity {
        // メール分析ロジック
        await Task.sleep(500_000_000) // 0.5秒待機
        
        let suspiciousKeywords = ["銀行", "クレジットカード", "緊急", "確認", "更新", "停止"]
        let contentLower = content.lowercased()
        
        let suspiciousCount = suspiciousKeywords.filter { contentLower.contains($0.lowercased()) }.count
        
        if suspiciousCount >= 3 {
            return .high
        } else if suspiciousCount >= 1 {
            return .medium
        } else {
            return .low
        }
    }
    
    func analyzeWebsite(_ url: String) async -> WebSafetyCheck {
        // ウェブサイト分析ロジック
        await Task.sleep(800_000_000) // 0.8秒待機
        
        let suspiciousDomains = ["fake-bank.com", "scam-site.net", "phishing.org"]
        let isSuspicious = suspiciousDomains.contains { url.contains($0) }
        
        return WebSafetyCheck(
            url: url,
            isSafe: !isSuspicious,
            riskScore: isSuspicious ? 85 : 15,
            threats: isSuspicious ? ["フィッシング", "マルウェア"] : [],
            recommendations: isSuspicious ? ["このサイトにはアクセスしないでください"] : ["安全なサイトです"],
            lastChecked: Date()
        )
    }
    
    // MARK: - Statistics Analysis
    func generateSecurityReport(period: StatisticsPeriod) async -> SecurityStatistics {
        // 統計レポート生成
        await Task.sleep(1_200_000_000) // 1.2秒待機
        
        let trends = generateTrendData(period: period)
        
        return SecurityStatistics(
            period: period,
            totalAlerts: Int.random(in: 5...50),
            blockedCalls: Int.random(in: 2...20),
            safeEmails: Int.random(in: 10...100),
            blockedWebsites: Int.random(in: 1...10),
            educationCompleted: Int.random(in: 1...5),
            protectionScore: Int.random(in: 70...95),
            trends: trends
        )
    }
    
    private func generateTrendData(period: StatisticsPeriod) -> [StatisticsTrend] {
        let calendar = Calendar.current
        let now = Date()
        var trends: [StatisticsTrend] = []
        
        let days: Int
        switch period {
        case .day: days = 1
        case .week: days = 7
        case .month: days = 30
        case .year: days = 365
        }
        
        for i in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                trends.append(StatisticsTrend(
                    id: UUID(),
                    date: date,
                    alerts: Int.random(in: 0...10),
                    blockedCalls: Int.random(in: 0...5),
                    protectionScore: Int.random(in: 70...95)
                ))
            }
        }
        
        return trends.reversed()
    }
    
    // MARK: - Offline Content Management
    func downloadOfflineContent() async -> [OfflineContent] {
        // オフラインコンテンツのダウンロード
        await Task.sleep(2_000_000_000) // 2秒待機
        
        return [
            OfflineContent(
                id: UUID(),
                title: "詐欺防止の基本",
                content: "詐欺から身を守るための基本的な知識...",
                category: .education,
                lastUpdated: Date(),
                isDownloaded: true,
                fileSize: 1024 * 1024
            ),
            OfflineContent(
                id: UUID(),
                title: "緊急連絡先",
                content: "警察: 110, 救急: 119...",
                category: .emergency,
                lastUpdated: Date(),
                isDownloaded: true,
                fileSize: 512 * 1024
            )
        ]
    }
    
    // MARK: - AI Support Chat
    func getAISupportResponse(_ question: String) async -> String {
        // AIサポート応答生成
        await Task.sleep(1_500_000_000) // 1.5秒待機
        
        let responses = [
            "詐欺防止についてお答えします。まず、不審な電話やメールには注意が必要です。",
            "セキュリティを強化するには、定期的にパスワードを変更し、二段階認証を有効にしてください。",
            "家族との連携は重要です。緊急時にはすぐに連絡できるよう、事前に設定しておきましょう。",
            "教育コンテンツを活用して、最新の詐欺手法について学ぶことをお勧めします。"
        ]
        
        return responses.randomElement() ?? "申し訳ございませんが、その質問にはお答えできません。"
    }
}

// MARK: - Network Service
class NetworkService: ObservableObject {
    private let baseURL = "https://your-vercel-app.vercel.app/api" // Replace with your actual Vercel URL
    
    func analyzeContent(type: String, content: String, userId: String, context: [String: Any]? = nil) async throws -> AIAnalysis {
        let url = URL(string: "\(baseURL)/gemini")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body: [String: Any] = [
            "type": type,
            "content": content,
            "userId": userId
        ]
        
        if let context = context {
            body["context"] = context
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.apiError
        }
        
        return try JSONDecoder().decode(AIAnalysis.self, from: data)
    }
    
    func getEmergencyStatus(userId: String) async throws -> EmergencyStatus {
        let url = URL(string: "\(baseURL)/sos?userId=\(userId)&action=status")!
        let request = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.apiError
        }
        
        return try JSONDecoder().decode(EmergencyStatus.self, from: data)
    }
    
    func triggerEmergency(userId: String, triggerMethod: String, location: LocationData?) async throws -> EmergencyResponse {
        let url = URL(string: "\(baseURL)/sos")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body: [String: Any] = [
            "action": "trigger",
            "data": [
                "triggerMethod": triggerMethod
            ]
        ]
        
        if let location = location {
            body["data"] = [
                "triggerMethod": triggerMethod,
                "location": [
                    "latitude": location.latitude,
                    "longitude": location.longitude
                ]
            ]
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.apiError
        }
        
        return try JSONDecoder().decode(EmergencyResponse.self, from: data)
    }
    
    func getFamilyMembers(userId: String) async throws -> [FamilyMember] {
        let url = URL(string: "\(baseURL)/family?userId=\(userId)&action=members")!
        let request = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.apiError
        }
        
        let familyResponse = try JSONDecoder().decode(FamilyResponse.self, from: data)
        return familyResponse.members
    }
    
    func updateLocation(userId: String, latitude: Double, longitude: Double, accuracy: Double = 10) async throws -> LocationData {
        let url = URL(string: "\(baseURL)/family")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "action": "update-location",
            "data": [
                "latitude": latitude,
                "longitude": longitude,
                "accuracy": accuracy
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.apiError
        }
        
        let locationResponse = try JSONDecoder().decode(LocationResponse.self, from: data)
        return locationResponse.location
    }
    
    func getStatistics(userId: String, period: String = "week") async throws -> StatisticsOverview {
        let url = URL(string: "\(baseURL)/statistics?userId=\(userId)&action=overview&period=\(period)")!
        let request = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.apiError
        }
        
        return try JSONDecoder().decode(StatisticsOverview.self, from: data)
    }
    
    func logSecurityEvent(userId: String, type: String, severity: String, description: String) async throws -> SecurityEvent {
        let url = URL(string: "\(baseURL)/statistics")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "action": "log-event",
            "data": [
                "type": type,
                "severity": severity,
                "description": description
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw AIError.apiError
        }
        
        let eventResponse = try JSONDecoder().decode(EventResponse.self, from: data)
        return eventResponse.event
    }
}

// MARK: - Response Models
struct AIAnalysis: Codable {
    let type: String
    let content: String
    let analysis: String
    let timestamp: String
    let userId: String
    let riskLevel: String
    let recommendations: [String]
}

struct EmergencyStatus: Codable {
    let isEnabled: Bool
    let hasActiveEmergency: Bool
    let lastTriggered: String?
}

struct EmergencyResponse: Codable {
    let emergency: EmergencyData
    let actions: [EmergencyAction]
    let message: String
}

struct EmergencyData: Codable {
    let id: String
    let userId: String
    let triggerMethod: String
    let location: LocationData?
    let timestamp: String
    let status: String
}

struct EmergencyAction: Codable {
    let type: String
    let target: String?
    let status: String
    let timestamp: String
}

struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    let timestamp: String
    let accuracy: Double
}

struct FamilyResponse: Codable {
    let members: [FamilyMember]
}

struct LocationResponse: Codable {
    let location: LocationData
}

struct StatisticsOverview: Codable {
    let period: String
    let protectionScore: Int
    let totalEvents: Int
    let highRiskEvents: Int
    let resolvedEvents: Int
    let trend: String
    let lastUpdated: String
}

struct SecurityEvent: Codable {
    let id: String
    let userId: String
    let type: String
    let severity: String
    let description: String
    let timestamp: String
    let resolved: Bool
    let aiAnalysis: String?
}

struct EventResponse: Codable {
    let event: SecurityEvent
}

// MARK: - Gemini AI Service
class GeminiAIService: AIServiceProtocol, ObservableObject {
    private let networkService = NetworkService()
    
    init() {
        // Network service is initialized automatically
    }
    
    // MARK: - Main AI Methods
    
    func analyzeScamContent(_ content: String, type: ScamType) async throws -> ScamAnalysisResult {
        let analysisType: String
        switch type {
        case .phone: analysisType = "call_analysis"
        case .email: analysisType = "email_analysis"
        case .website: analysisType = "website_analysis"
        case .sms: analysisType = "call_analysis"
        case .socialMedia: analysisType = "general_advice"
        }
        
        let aiAnalysis = try await networkService.analyzeContent(
            type: analysisType,
            content: content,
            userId: "user_\(UUID().uuidString)"
        )
        
        return ScamAnalysisResult(
            isScam: aiAnalysis.riskLevel == "high",
            confidence: 0.8,
            riskLevel: parseRiskLevel(aiAnalysis.riskLevel),
            detectedThreats: aiAnalysis.recommendations,
            recommendations: aiAnalysis.recommendations,
            explanation: aiAnalysis.analysis,
            aiReasoning: aiAnalysis.analysis
        )
    }
    
    func generateSafetyRecommendations(_ context: String) async throws -> [String] {
        let aiAnalysis = try await networkService.analyzeContent(
            type: "general_advice",
            content: context,
            userId: "user_\(UUID().uuidString)"
        )
        return aiAnalysis.recommendations
    }
    
    func answerUserQuestion(_ question: String) async throws -> String {
        let aiAnalysis = try await networkService.analyzeContent(
            type: "general_advice",
            content: question,
            userId: "user_\(UUID().uuidString)"
        )
        return aiAnalysis.analysis
    }
    
    func generateEducationalContent(_ topic: String) async throws -> EducationalContent {
        let aiAnalysis = try await networkService.analyzeContent(
            type: "general_advice",
            content: topic,
            userId: "user_\(UUID().uuidString)"
        )
        
        return EducationalContent(
            title: topic,
            content: aiAnalysis.analysis,
            difficulty: .beginner,
            estimatedTime: 300,
            keyPoints: aiAnalysis.recommendations,
            examples: []
        )
    }
    
    func analyzeCallRisk(_ phoneNumber: String, context: String?) async throws -> CallRiskAnalysis {
        let aiAnalysis = try await networkService.analyzeContent(
            type: "call_analysis",
            content: "Phone number: \(phoneNumber). Context: \(context ?? "No context")",
            userId: "user_\(UUID().uuidString)"
        )
        
        return CallRiskAnalysis(
            riskLevel: parseRiskLevel(aiAnalysis.riskLevel),
            confidence: 0.7,
            detectedThreats: aiAnalysis.recommendations,
            recommendations: aiAnalysis.recommendations,
            callerInfo: aiAnalysis.analysis,
            isKnownScammer: aiAnalysis.riskLevel == "high"
        )
    }
    
    func analyzeEmailRisk(_ emailContent: String) async throws -> EmailRiskAnalysis {
        let aiAnalysis = try await networkService.analyzeContent(
            type: "email_analysis",
            content: emailContent,
            userId: "user_\(UUID().uuidString)"
        )
        
        return EmailRiskAnalysis(
            riskLevel: parseRiskLevel(aiAnalysis.riskLevel),
            confidence: 0.8,
            detectedThreats: aiAnalysis.recommendations,
            recommendations: aiAnalysis.recommendations,
            senderAnalysis: aiAnalysis.analysis,
            contentAnalysis: aiAnalysis.analysis,
            isPhishing: aiAnalysis.riskLevel == "high"
        )
    }
    
    func analyzeWebsiteRisk(_ url: String) async throws -> WebsiteRiskAnalysis {
        let aiAnalysis = try await networkService.analyzeContent(
            type: "website_analysis",
            content: url,
            userId: "user_\(UUID().uuidString)"
        )
        
        return WebsiteRiskAnalysis(
            riskLevel: parseRiskLevel(aiAnalysis.riskLevel),
            confidence: 0.8,
            detectedThreats: aiAnalysis.recommendations,
            recommendations: aiAnalysis.recommendations,
            domainAnalysis: aiAnalysis.analysis,
            contentAnalysis: aiAnalysis.analysis,
            isSafe: aiAnalysis.riskLevel == "low"
        )
    }
    
    private func parseRiskLevel(_ riskLevel: String) -> RiskLevel {
        switch riskLevel {
        case "high": return .dangerous
        case "medium": return .suspicious
        case "low": return .safe
        default: return .suspicious
        }
    }
    

    

}



// MARK: - AI Errors
enum AIError: Error, LocalizedError {
    case apiKeyNotConfigured
    case apiError
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .apiKeyNotConfigured:
            return "APIキーが設定されていません"
        case .apiError:
            return "API呼び出しでエラーが発生しました"
        case .invalidResponse:
            return "無効なレスポンスが返されました"
        }
    }
} 