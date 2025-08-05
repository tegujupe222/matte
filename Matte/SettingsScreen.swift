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
                        onAdd: { showingEmergencyContacts = true }
                    )
                    
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

struct EmergencyContactsCard: View {
    @Binding var contacts: [EmergencyContact]
    let onAdd: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "phone.circle.fill")
                    .foregroundColor(.red)
                Text("緊急連絡先")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                
                Button("追加") {
                    onAdd()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            if contacts.isEmpty {
                Text("緊急連絡先が設定されていません")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(contacts.prefix(3), id: \.id) { contact in
                    ContactRow(contact: contact)
                }
                
                if contacts.count > 3 {
                    Button("すべて表示") {
                        onAdd()
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct ContactRow: View {
    let contact: EmergencyContact
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .foregroundColor(.green)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(contact.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(contact.phoneNumber)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(contact.relationship)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 5)
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

#Preview {
    SettingsScreen()
} 