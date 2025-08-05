//
//  Models.swift
//  Matte
//
//  Created by Igasaki Gouta on 2025/08/04.
//

import Foundation
import SwiftUI

// MARK: - ScamAlert Model
struct ScamAlert: Identifiable {
    let id = UUID()
    let type: AlertType
    let title: String
    let description: String
    let timestamp: Date
    let severity: AlertSeverity
    var isRead: Bool = false
}

enum AlertType: CaseIterable {
    case email
    case call
    case web
    case sms
    
    var iconName: String {
        switch self {
        case .email: return "envelope.fill"
        case .call: return "phone.fill"
        case .web: return "globe"
        case .sms: return "message.fill"
        }
    }
    
    var displayName: String {
        switch self {
        case .email: return "メール"
        case .call: return "通話"
        case .web: return "ウェブサイト"
        case .sms: return "SMS"
        }
    }
}

enum AlertSeverity: CaseIterable {
    case low
    case medium
    case high
    case critical
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
    
    var displayName: String {
        switch self {
        case .low: return "低"
        case .medium: return "中"
        case .high: return "高"
        case .critical: return "緊急"
        }
    }
}

// MARK: - Call Entry Model
struct CallEntry: Identifiable {
    let id = UUID()
    let phoneNumber: String
    let callerName: String?
    let timestamp: Date
    let isBlocked: Bool
    let riskLevel: RiskLevel
    let duration: TimeInterval?
}

enum RiskLevel: CaseIterable {
    case safe
    case suspicious
    case dangerous
    case blocked
    
    var color: Color {
        switch self {
        case .safe: return .green
        case .suspicious: return .yellow
        case .dangerous: return .orange
        case .blocked: return .red
        }
    }
    
    var displayName: String {
        switch self {
        case .safe: return "安全"
        case .suspicious: return "要注意"
        case .dangerous: return "危険"
        case .blocked: return "ブロック済み"
        }
    }
}

// MARK: - User Settings Model
struct UserSettings: Codable {
    var isCallScreeningEnabled: Bool = true
    var isEmailAlertEnabled: Bool = true
    var isWebSafetyEnabled: Bool = true
    var isNotificationEnabled: Bool = true
    var isVibrationEnabled: Bool = true
    var isVoiceEnabled: Bool = true
    var fontSize: FontSize = .large
    var emergencyContacts: [EmergencyContact] = []
    var blacklistedNumbers: [String] = []
    var whitelistedNumbers: [String] = []
}

enum FontSize: String, CaseIterable, Codable {
    case small = "小"
    case medium = "中"
    case large = "大"
    case extraLarge = "特大"
    
    var systemFont: Font {
        switch self {
        case .small: return .body
        case .medium: return .title3
        case .large: return .title2
        case .extraLarge: return .title
        }
    }
}

// MARK: - Emergency Contact Model
struct EmergencyContact: Identifiable, Codable {
    let id = UUID()
    var name: String
    var phoneNumber: String
    var relationship: String
    var isEnabled: Bool = true
}

// MARK: - Web Safety Check Model
struct WebSafetyCheck {
    let url: String
    let isSafe: Bool
    let riskScore: Int // 0-100
    let threats: [String]
    let recommendations: [String]
    let lastChecked: Date
}

// MARK: - Education Content Model
struct EducationContent: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let content: String
    let category: EducationCategory
    let difficulty: Difficulty
    let estimatedTime: TimeInterval
    let isCompleted: Bool = false
}

enum EducationCategory: String, CaseIterable {
    case phishing = "フィッシング"
    case phoneScam = "電話詐欺"
    case smsScam = "SMS詐欺"
    case socialEngineering = "ソーシャルエンジニアリング"
    case malware = "マルウェア"
    
    var iconName: String {
        switch self {
        case .phishing: return "envelope.badge"
        case .phoneScam: return "phone.down"
        case .smsScam: return "message.badge"
        case .socialEngineering: return "person.badge"
        case .malware: return "exclamationmark.triangle"
        }
    }
}

enum Difficulty: String, CaseIterable {
    case beginner = "初級"
    case intermediate = "中級"
    case advanced = "上級"
    
    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
} 