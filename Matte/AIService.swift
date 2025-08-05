//
//  AIService.swift
//  Matte
//
//  Created by Igasaki Gouta on 2025/08/04.
//

import Foundation
import SwiftUI

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

// MARK: - Gemini AI Service
class GeminiAIService: AIServiceProtocol, ObservableObject {
    private let apiKey: String
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent"
    
    init() {
        // Info.plistからAPIキーを取得
        self.apiKey = Bundle.main.infoDictionary?["GEMINI_API_KEY"] as? String ?? ""
    }
    
    // MARK: - Main AI Methods
    
    func analyzeScamContent(_ content: String, type: ScamType) async throws -> ScamAnalysisResult {
        let prompt = createScamAnalysisPrompt(content: content, type: type)
        let response = try await callGeminiAPI(prompt: prompt)
        return parseScamAnalysisResponse(response, type: type)
    }
    
    func generateSafetyRecommendations(_ context: String) async throws -> [String] {
        let prompt = createRecommendationsPrompt(context: context)
        let response = try await callGeminiAPI(prompt: prompt)
        return parseRecommendationsResponse(response)
    }
    
    func answerUserQuestion(_ question: String) async throws -> String {
        let prompt = createQuestionAnswerPrompt(question: question)
        let response = try await callGeminiAPI(prompt: prompt)
        return parseQuestionAnswerResponse(response)
    }
    
    func generateEducationalContent(_ topic: String) async throws -> EducationalContent {
        let prompt = createEducationalContentPrompt(topic: topic)
        let response = try await callGeminiAPI(prompt: prompt)
        return parseEducationalContentResponse(response, topic: topic)
    }
    
    func analyzeCallRisk(_ phoneNumber: String, context: String?) async throws -> CallRiskAnalysis {
        let prompt = createCallRiskPrompt(phoneNumber: phoneNumber, context: context)
        let response = try await callGeminiAPI(prompt: prompt)
        return parseCallRiskResponse(response)
    }
    
    func analyzeEmailRisk(_ emailContent: String) async throws -> EmailRiskAnalysis {
        let prompt = createEmailRiskPrompt(emailContent: emailContent)
        let response = try await callGeminiAPI(prompt: prompt)
        return parseEmailRiskResponse(response)
    }
    
    func analyzeWebsiteRisk(_ url: String) async throws -> WebsiteRiskAnalysis {
        let prompt = createWebsiteRiskPrompt(url: url)
        let response = try await callGeminiAPI(prompt: prompt)
        return parseWebsiteRiskResponse(response)
    }
    
    // MARK: - Private Methods
    
    private func callGeminiAPI(prompt: String) async throws -> String {
        guard !apiKey.isEmpty else {
            throw AIError.apiKeyNotConfigured
        }
        
        let url = URL(string: "\(baseURL)?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = GeminiRequest(contents: [
            GeminiContent(parts: [GeminiPart(text: prompt)])
        ])
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.apiError
        }
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        return geminiResponse.candidates.first?.content.parts.first?.text ?? ""
    }
    
    // MARK: - Prompt Creation Methods
    
    private func createScamAnalysisPrompt(content: String, type: ScamType) -> String {
        return """
        あなたは詐欺検出の専門家です。以下の内容を分析して、詐欺の可能性を評価してください。
        
        分析対象: \(type.displayName)
        内容: \(content)
        
        以下の形式でJSONで回答してください：
        {
            "isScam": true/false,
            "confidence": 0.0-1.0,
            "riskLevel": "safe/suspicious/dangerous/blocked",
            "detectedThreats": ["脅威1", "脅威2"],
            "recommendations": ["推奨アクション1", "推奨アクション2"],
            "explanation": "分析結果の説明",
            "aiReasoning": "AIの推論過程"
        }
        
        高齢者向けに分かりやすく説明してください。
        """
    }
    
    private func createRecommendationsPrompt(context: String) -> String {
        return """
        以下の状況に基づいて、高齢者向けの安全対策を3つ提案してください：
        
        状況: \(context)
        
        以下の形式でJSONで回答してください：
        {
            "recommendations": ["対策1", "対策2", "対策3"]
        }
        
        具体的で実践的なアドバイスを提供してください。
        """
    }
    
    private func createQuestionAnswerPrompt(question: String) -> String {
        return """
        あなたは高齢者向けの詐欺防止アドバイザーです。以下の質問に分かりやすく回答してください：
        
        質問: \(question)
        
        以下の点に注意して回答してください：
        1. 高齢者にも分かりやすい言葉で説明
        2. 具体的な例を交えて説明
        3. 実践的なアドバイスを提供
        4. 不安を煽らないよう配慮
        """
    }
    
    private func createEducationalContentPrompt(topic: String) -> String {
        return """
        高齢者向けの詐欺防止教育コンテンツを作成してください。
        
        トピック: \(topic)
        
        以下の形式でJSONで回答してください：
        {
            "title": "タイトル",
            "content": "詳細な内容",
            "difficulty": "beginner/intermediate/advanced",
            "estimatedTime": 300,
            "keyPoints": ["ポイント1", "ポイント2", "ポイント3"],
            "examples": ["例1", "例2"]
        }
        
        高齢者に分かりやすく、実践的な内容にしてください。
        """
    }
    
    private func createCallRiskPrompt(phoneNumber: String, context: String?) -> String {
        let contextText = context ?? "情報なし"
        return """
        以下の電話番号のリスクを分析してください：
        
        電話番号: \(phoneNumber)
        状況: \(contextText)
        
        以下の形式でJSONで回答してください：
        {
            "riskLevel": "safe/suspicious/dangerous/blocked",
            "confidence": 0.0-1.0,
            "detectedThreats": ["脅威1", "脅威2"],
            "recommendations": ["推奨アクション1", "推奨アクション2"],
            "callerInfo": "発信者情報の分析",
            "isKnownScammer": true/false
        }
        """
    }
    
    private func createEmailRiskPrompt(emailContent: String) -> String {
        return """
        以下のメール内容のリスクを分析してください：
        
        メール内容: \(emailContent)
        
        以下の形式でJSONで回答してください：
        {
            "riskLevel": "safe/suspicious/dangerous/blocked",
            "confidence": 0.0-1.0,
            "detectedThreats": ["脅威1", "脅威2"],
            "recommendations": ["推奨アクション1", "推奨アクション2"],
            "senderAnalysis": "送信者分析",
            "contentAnalysis": "内容分析",
            "isPhishing": true/false
        }
        """
    }
    
    private func createWebsiteRiskPrompt(url: String) -> String {
        return """
        以下のウェブサイトのリスクを分析してください：
        
        URL: \(url)
        
        以下の形式でJSONで回答してください：
        {
            "riskLevel": "safe/suspicious/dangerous/blocked",
            "confidence": 0.0-1.0,
            "detectedThreats": ["脅威1", "脅威2"],
            "recommendations": ["推奨アクション1", "推奨アクション2"],
            "domainAnalysis": "ドメイン分析",
            "contentAnalysis": "内容分析",
            "isSafe": true/false
        }
        """
    }
    
    // MARK: - Response Parsing Methods
    
    private func parseScamAnalysisResponse(_ response: String, type: ScamType) -> ScamAnalysisResult {
        // JSONパースの実装
        // 実際の実装では適切なJSONパーサーを使用
        return ScamAnalysisResult(
            isScam: response.contains("true"),
            confidence: 0.8,
            riskLevel: .suspicious,
            detectedThreats: ["フィッシング", "個人情報要求"],
            recommendations: ["リンクをクリックしない", "情報を入力しない"],
            explanation: "AI分析による詐欺の可能性が検出されました",
            aiReasoning: response
        )
    }
    
    private func parseRecommendationsResponse(_ response: String) -> [String] {
        return ["推奨アクション1", "推奨アクション2", "推奨アクション3"]
    }
    
    private func parseQuestionAnswerResponse(_ response: String) -> String {
        return response
    }
    
    private func parseEducationalContentResponse(_ response: String, topic: String) -> EducationalContent {
        return EducationalContent(
            title: "\(topic)について",
            content: response,
            difficulty: .beginner,
            estimatedTime: 300,
            keyPoints: ["ポイント1", "ポイント2", "ポイント3"],
            examples: ["例1", "例2"]
        )
    }
    
    private func parseCallRiskResponse(_ response: String) -> CallRiskAnalysis {
        return CallRiskAnalysis(
            riskLevel: .suspicious,
            confidence: 0.7,
            detectedThreats: ["不明な発信者"],
            recommendations: ["着信を拒否", "番号をブロック"],
            callerInfo: "不明な番号",
            isKnownScammer: false
        )
    }
    
    private func parseEmailRiskResponse(_ response: String) -> EmailRiskAnalysis {
        return EmailRiskAnalysis(
            riskLevel: .dangerous,
            confidence: 0.9,
            detectedThreats: ["フィッシング", "偽のリンク"],
            recommendations: ["メールを削除", "リンクをクリックしない"],
            senderAnalysis: "不審な送信者",
            contentAnalysis: "緊急性を演出",
            isPhishing: true
        )
    }
    
    private func parseWebsiteRiskResponse(_ response: String) -> WebsiteRiskAnalysis {
        return WebsiteRiskAnalysis(
            riskLevel: .dangerous,
            confidence: 0.8,
            detectedThreats: ["マルウェア", "フィッシング"],
            recommendations: ["アクセスを避ける", "セキュリティソフトでスキャン"],
            domainAnalysis: "不審なドメイン",
            contentAnalysis: "危険なコンテンツ",
            isSafe: false
        )
    }
}

// MARK: - Gemini API Models
struct GeminiRequest: Codable {
    let contents: [GeminiContent]
}

struct GeminiContent: Codable {
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    let text: String
}

struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]
}

struct GeminiCandidate: Codable {
    let content: GeminiContent
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