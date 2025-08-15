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

enum AlertSeverity: String, CaseIterable, Codable {
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

enum RiskLevel: String, CaseIterable, Codable {
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
    var id = UUID()
    var name: String
    var phoneNumber: String
    var relationship: String
    var isEnabled: Bool = true
}

// MARK: - Web Safety Check Model
struct WebSafetyCheck: Codable {
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

// MARK: - Widget Model
struct WidgetData: Codable {
    let totalAlerts: Int
    let blockedCalls: Int
    let safeEmails: Int
    let lastUpdate: Date
    let protectionStatus: Bool
}

// MARK: - Emergency SOS Model
struct EmergencySOS: Codable {
    var isEnabled: Bool
    var triggerMethod: SOSTriggerMethod
    var autoCallEnabled: Bool
    var autoMessageEnabled: Bool
    var locationSharingEnabled: Bool
    var contacts: [EmergencyContact]
    var customMessage: String
}

enum SOSTriggerMethod: String, CaseIterable, Codable {
    case powerButton = "電源ボタン"
    case volumeButton = "音量ボタン"
    case shake = "振動"
    case voice = "音声"
    
    var description: String {
        switch self {
        case .powerButton: return "電源ボタンを5回連続で押す"
        case .volumeButton: return "音量ボタンを3回連続で押す"
        case .shake: return "デバイスを強く振る"
        case .voice: return "「SOS」と叫ぶ"
        }
    }
}

// MARK: - Family Connection Model
struct FamilyMember: Identifiable, Codable {
    var id = UUID()
    var name: String
    var phoneNumber: String
    var relationship: String
    var isGuardian: Bool
    var canViewAlerts: Bool
    var canReceiveNotifications: Bool
    var lastActive: Date?
    var deviceInfo: DeviceInfo?
}

struct DeviceInfo: Codable {
    let deviceName: String
    let osVersion: String
    let appVersion: String
    let lastSync: Date
}

// MARK: - Statistics Model
struct SecurityStatistics: Codable {
    let period: StatisticsPeriod
    let totalAlerts: Int
    let blockedCalls: Int
    let safeEmails: Int
    let blockedWebsites: Int
    let educationCompleted: Int
    let protectionScore: Int // 0-100
    let trends: [StatisticsTrend]
}

enum StatisticsPeriod: String, CaseIterable, Codable {
    case day = "今日"
    case week = "今週"
    case month = "今月"
    case year = "今年"
}

struct StatisticsTrend: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let alerts: Int
    let blockedCalls: Int
    let protectionScore: Int
}

// MARK: - Voice Assistant Model
struct VoiceCommand: Identifiable, Codable {
    var id = UUID()
    let command: String
    let action: VoiceAction
    let description: String
    let isEnabled: Bool
}

enum VoiceAction: String, CaseIterable, Codable {
    case checkSecurity = "セキュリティチェック"
    case emergencyCall = "緊急通話"
    case readAlerts = "警告を読む"
    case openSettings = "設定を開く"
    case callFamily = "家族に電話"
    
    var voiceTriggers: [String] {
        switch self {
        case .checkSecurity: return ["セキュリティチェック", "安全確認", "保護状況"]
        case .emergencyCall: return ["緊急通話", "SOS", "助けて"]
        case .readAlerts: return ["警告を読む", "アラート", "通知"]
        case .openSettings: return ["設定", "設定を開く"]
        case .callFamily: return ["家族に電話", "家族", "連絡"]
        }
    }
}

// MARK: - Offline Content Model
struct OfflineContent: Identifiable, Codable {
    var id = UUID()
    let title: String
    let content: String
    let category: OfflineCategory
    let lastUpdated: Date
    let isDownloaded: Bool
    let fileSize: Int64
}

enum OfflineCategory: String, CaseIterable, Codable {
    case education = "教育コンテンツ"
    case emergency = "緊急情報"
    case contacts = "連絡先"
    case settings = "設定"
    
    var iconName: String {
        switch self {
        case .education: return "book.fill"
        case .emergency: return "exclamationmark.triangle.fill"
        case .contacts: return "person.2.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

// MARK: - Personalization Model
struct UserProfile: Codable {
    var name: String
    var age: Int
    var preferredLanguage: Language
    var accessibilityNeeds: [AccessibilityNeed]
    var interests: [String]
    var techLevel: TechLevel
    var notificationPreferences: NotificationPreferences
}

enum Language: String, CaseIterable, Codable {
    case japanese = "日本語"
    case english = "English"
    case chinese = "中文"
    case korean = "한국어"
}

enum AccessibilityNeed: String, CaseIterable, Codable {
    case largeText = "大きな文字"
    case highContrast = "高コントラスト"
    case voiceOver = "VoiceOver"
    case reducedMotion = "動きを減らす"
    case hearingAid = "補聴器"
}

enum TechLevel: String, CaseIterable, Codable {
    case beginner = "初心者"
    case intermediate = "中級者"
    case advanced = "上級者"
    
    var description: String {
        switch self {
        case .beginner: return "スマートフォンを初めて使う方"
        case .intermediate: return "基本的な操作ができる方"
        case .advanced: return "様々な機能を使いこなせる方"
        }
    }
}

struct NotificationPreferences: Codable {
    var alertNotifications: Bool = true
    var educationNotifications: Bool = true
    var familyNotifications: Bool = true
    var systemNotifications: Bool = true
    var quietHours: QuietHours?
}

struct QuietHours: Codable {
    let startTime: Date
    let endTime: Date
    let isEnabled: Bool
}

// MARK: - Theme Model
struct AppTheme: Codable {
    let name: String
    let primaryColor: String
    let secondaryColor: String
    let backgroundColor: String
    let textColor: String
    let isDarkMode: Bool
    let fontSize: FontSize
    let cornerRadius: Double
}

// MARK: - Achievement Model
struct Achievement: Identifiable, Codable {
    var id = UUID()
    let title: String
    let description: String
    let iconName: String
    let category: AchievementCategory
    let isUnlocked: Bool
    let unlockedDate: Date?
    let progress: Double // 0.0 to 1.0
}

enum AchievementCategory: String, CaseIterable, Codable {
    case security = "セキュリティ"
    case education = "学習"
    case family = "家族"
    case usage = "利用"
    
    var color: Color {
        switch self {
        case .security: return .red
        case .education: return .blue
        case .family: return .green
        case .usage: return .purple
        }
    }
} 