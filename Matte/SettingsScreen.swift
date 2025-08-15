//
//  SettingsScreen.swift
//  Matte
//
//  Created by Igasaki Gouta on 2025/08/04.
//

import SwiftUI

struct SettingsScreen: View {
    @State private var settings = UserSettings()
    @State private var showingEmergencyContacts = false
    @State private var showingEducationContent = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 基本設定
                    BasicSettingsCard(settings: $settings)
                    
                    // 通知設定
                    NotificationSettingsCard(settings: $settings)
                    
                    // 緊急連絡先
                    EmergencyContactsCard(
                        contacts: $settings.emergencyContacts,
                        onAddContact: { showingEmergencyContacts = true }
                    )
                    
                    // 緊急SOS設定
                    EmergencySOSSettingsCard()
                    
                    // 家族連携設定
                    FamilyConnectionSettingsCard()
                    
                    // 音声アシスタント設定
                    VoiceAssistantSettingsCard()
                    
                    // 統計・レポート設定
                    StatisticsSettingsCard()
                    
                    // 教育コンテンツ
                    EducationSettingsCard(onTap: { showingEducationContent = true })
                    
                    // アプリ情報
                    AppInfoCard()
                }
                .padding()
            }
            .navigationTitle("Matte")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $showingEmergencyContacts) {
            EmergencyContactsView(contacts: $settings.emergencyContacts)
        }
        .sheet(isPresented: $showingEducationContent) {
            EducationContentView()
        }
    }
}

struct BasicSettingsCard: View {
    @Binding var settings: UserSettings
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.blue)
                Text("基本設定")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 15) {
                SettingRow(
                    title: "通話スクリーニング",
                    description: "危険な通話を自動的にブロック",
                    isEnabled: $settings.isCallScreeningEnabled
                )
                
                SettingRow(
                    title: "メール警告",
                    description: "不審なメールを検出して警告",
                    isEnabled: $settings.isEmailAlertEnabled
                )
                
                SettingRow(
                    title: "ウェブ安全確認",
                    description: "危険なウェブサイトを検出",
                    isEnabled: $settings.isWebSafetyEnabled
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct NotificationSettingsCard: View {
    @Binding var settings: UserSettings
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(.orange)
                Text("通知設定")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 15) {
                SettingRow(
                    title: "通知を有効にする",
                    description: "警告やアラートを通知",
                    isEnabled: $settings.isNotificationEnabled
                )
                
                SettingRow(
                    title: "バイブレーション",
                    description: "警告時にバイブレーション",
                    isEnabled: $settings.isVibrationEnabled
                )
                
                SettingRow(
                    title: "音声読み上げ",
                    description: "警告を音声で読み上げ",
                    isEnabled: $settings.isVoiceEnabled
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct SettingRow: View {
    let title: String
    let description: String
    @Binding var isEnabled: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
        }
    }
}



struct EducationSettingsCard: View {
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "graduationcap.fill")
                    .foregroundColor(.purple)
                Text("教育コンテンツ")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                
                Button("表示") {
                    onTap()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            Text("詐欺手法やセキュリティ知識を学べるコンテンツを提供しています。定期的にチェックして、最新の詐欺手法について学びましょう。")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct AppInfoCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.gray)
                Text("アプリ情報")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 10) {
                InfoRow(title: "アプリ名", value: "Matte")
                InfoRow(title: "バージョン", value: "1.0.0")
                InfoRow(title: "開発者", value: "Matte")
                InfoRow(title: "プライバシーポリシー", value: "タップして確認")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
        }
    }
}

struct EmergencyContactsView: View {
    @Binding var contacts: [EmergencyContact]
    @Environment(\.dismiss) private var dismiss
    @State private var newContact = EmergencyContact(name: "", phoneNumber: "", relationship: "")
    @State private var showingAddContact = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(contacts, id: \.id) { contact in
                    ContactDetailRow(contact: contact)
                }
                .onDelete(perform: deleteContact)
            }
            .navigationTitle("緊急連絡先")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("閉じる") { dismiss() },
                trailing: Button("追加") { showingAddContact = true }
            )
        }
        .sheet(isPresented: $showingAddContact) {
            AddContactView(contact: $newContact) {
                if !newContact.name.isEmpty && !newContact.phoneNumber.isEmpty {
                    contacts.append(newContact)
                    newContact = EmergencyContact(name: "", phoneNumber: "", relationship: "")
                    showingAddContact = false
                }
            }
        }
    }
    
    private func deleteContact(offsets: IndexSet) {
        contacts.remove(atOffsets: offsets)
    }
}

struct ContactDetailRow: View {
    let contact: EmergencyContact
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(contact.name)
                .font(.headline)
            
            Text(contact.phoneNumber)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(contact.relationship)
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 5)
    }
}

struct AddContactView: View {
    @Binding var contact: EmergencyContact
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("連絡先情報") {
                    TextField("名前", text: $contact.name)
                    TextField("電話番号", text: $contact.phoneNumber)
                        .keyboardType(.phonePad)
                    TextField("関係", text: $contact.relationship)
                }
            }
            .navigationTitle("連絡先追加")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("キャンセル") { dismiss() },
                trailing: Button("保存") { onSave() }
                    .disabled(contact.name.isEmpty || contact.phoneNumber.isEmpty)
            )
        }
    }
}

struct EducationContentView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(EducationCategory.allCases, id: \.self) { category in
                        EducationCategoryCard(category: category)
                    }
                }
                .padding()
            }
            .navigationTitle("教育コンテンツ")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("閉じる") { dismiss() })
        }
    }
}

struct EducationCategoryCard: View {
    let category: EducationCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: category.iconName)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                Text(category.rawValue)
                    .font(.headline)
                
                Spacer()
                
                Button("学習") {
                    // 学習コンテンツを開く
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            Text(getCategoryDescription(category))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
    
    private func getCategoryDescription(_ category: EducationCategory) -> String {
        switch category {
        case .phishing:
            return "偽のメールやウェブサイトによる詐欺手法について学びます"
        case .phoneScam:
            return "電話を使った詐欺の手口と対処法を学びます"
        case .smsScam:
            return "SMSを使った詐欺の手口と対処法を学びます"
        case .socialEngineering:
            return "心理的な操作による詐欺手法について学びます"
        case .malware:
            return "マルウェアの脅威と対策について学びます"
        }
    }
}

// MARK: - New Settings Cards
struct EmergencySOSSettingsCard: View {
    @State private var isSOSEnabled = true
    @State private var triggerMethod: SOSTriggerMethod = .powerButton
    @State private var autoCallEnabled = true
    @State private var autoMessageEnabled = true
    @State private var locationSharingEnabled = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "sos")
                    .foregroundColor(.red)
                Text("緊急SOS設定")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 15) {
                SettingRow(
                    title: "SOS機能を有効にする",
                    description: "緊急時に素早く家族に連絡",
                    isEnabled: $isSOSEnabled
                )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("トリガー方法")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("トリガー方法", selection: $triggerMethod) {
                        ForEach(SOSTriggerMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Text(triggerMethod.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                SettingRow(
                    title: "自動通話",
                    description: "SOS発動時に自動で電話",
                    isEnabled: $autoCallEnabled
                )
                
                SettingRow(
                    title: "自動メッセージ",
                    description: "SOS発動時に自動でメッセージ送信",
                    isEnabled: $autoMessageEnabled
                )
                
                SettingRow(
                    title: "位置情報共有",
                    description: "SOS発動時に位置情報を共有",
                    isEnabled: $locationSharingEnabled
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct FamilyConnectionSettingsCard: View {
    @State private var isFamilyEnabled = true
    @State private var isLocationSharingEnabled = true
    @State private var isActivitySharingEnabled = true
    @State private var isEmergencySharingEnabled = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "person.3.fill")
                    .foregroundColor(.purple)
                Text("家族連携設定")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 15) {
                SettingRow(
                    title: "家族連携を有効にする",
                    description: "家族との安全な連携機能",
                    isEnabled: $isFamilyEnabled
                )
                
                SettingRow(
                    title: "位置情報共有",
                    description: "家族と位置情報を共有",
                    isEnabled: $isLocationSharingEnabled
                )
                
                SettingRow(
                    title: "活動状況共有",
                    description: "家族に活動状況を共有",
                    isEnabled: $isActivitySharingEnabled
                )
                
                SettingRow(
                    title: "緊急時共有",
                    description: "緊急時に家族に情報を共有",
                    isEnabled: $isEmergencySharingEnabled
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct VoiceAssistantSettingsCard: View {
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
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "mic.fill")
                    .foregroundColor(.blue)
                Text("音声アシスタント設定")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 15) {
                SettingRow(
                    title: "音声アシスタント",
                    description: "音声でアプリを操作",
                    isEnabled: $isVoiceEnabled
                )
                
                SettingRow(
                    title: "振動フィードバック",
                    description: "音声認識時に振動",
                    isEnabled: $isVibrationEnabled
                )
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("言語")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    
                    Picker("言語", selection: $selectedLanguage) {
                        ForEach(languages, id: \.1) { language in
                            Text(language.0).tag(language.1)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("音声速度")
                            .font(.subheadline)
                            .fontWeight(.medium)
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
                            .fontWeight(.medium)
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

struct StatisticsSettingsCard: View {
    @State private var isStatisticsEnabled = true
    @State private var isDataSharingEnabled = false
    @State private var isAchievementEnabled = true
    @State private var isRecommendationEnabled = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.green)
                Text("統計・レポート設定")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 15) {
                SettingRow(
                    title: "統計機能を有効にする",
                    description: "セキュリティ状況の統計を表示",
                    isEnabled: $isStatisticsEnabled
                )
                
                SettingRow(
                    title: "データ共有",
                    description: "匿名化されたデータを共有（改善のため）",
                    isEnabled: $isDataSharingEnabled
                )
                
                SettingRow(
                    title: "達成度表示",
                    description: "セキュリティ達成度を表示",
                    isEnabled: $isAchievementEnabled
                )
                
                SettingRow(
                    title: "推奨事項表示",
                    description: "セキュリティ改善の推奨事項を表示",
                    isEnabled: $isRecommendationEnabled
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

#Preview {
    SettingsScreen()
} 