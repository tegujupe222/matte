//
//  HomeScreen.swift
//  Matte
//
//  Created by Igasaki Gouta on 2025/08/04.
//

import SwiftUI

struct HomeScreen: View {
    @State private var isProtected = true
    @State private var recentAlerts: [ScamAlert] = []
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // セキュリティ状況カード
                    SecurityStatusCard(isProtected: $isProtected)
                    
                    // 最近の警告
                    if !recentAlerts.isEmpty {
                        RecentAlertsCard(alerts: recentAlerts)
                    }
                    
                    // クイックアクション
                    QuickActionsView()
                    
                    // 緊急アクセス
                    EmergencyAccessCard()
                    
                    // 家族連携
                    FamilyConnectionCard()
                    
                    // AI機能カード
                    AIFeaturesCard()
                    
                    // 教育コンテンツ
                    EducationCard()
                }
                .padding()
            }
            .navigationTitle("Matte")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
        .onAppear {
            loadRecentAlerts()
        }
    }
    
    private func loadRecentAlerts() {
        // サンプルデータ
        recentAlerts = [
            ScamAlert(type: .email, title: "不審なメールを検出", description: "銀行からの緊急通知を装ったメール", timestamp: Date(), severity: .high),
            ScamAlert(type: .call, title: "迷惑電話を検出", description: "知らない番号からの着信", timestamp: Date().addingTimeInterval(-3600), severity: .medium)
        ]
    }
}

struct SecurityStatusCard: View {
    @Binding var isProtected: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: isProtected ? "shield.fill" : "shield.slash.fill")
                    .font(.system(size: 40))
                    .foregroundColor(isProtected ? .green : .red)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(isProtected ? "保護されています" : "保護が無効です")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(isProtected ? "すべての機能が正常に動作しています" : "設定を確認してください")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            if !isProtected {
                Button("保護を有効にする") {
                    isProtected = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct RecentAlertsCard: View {
    let alerts: [ScamAlert]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("最近の警告")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            ForEach(alerts.prefix(3), id: \.id) { alert in
                AlertRow(alert: alert)
            }
            
            if alerts.count > 3 {
                Button("すべて表示") {
                    // 詳細画面へ遷移
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct AlertRow: View {
    let alert: ScamAlert
    
    var body: some View {
        HStack {
            Image(systemName: alert.type.iconName)
                .foregroundColor(alert.severity.color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(alert.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(alert.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(alert.timestamp, style: .relative)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 5)
    }
}

struct QuickActionsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("クイックアクション")
                .font(.title3)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                QuickActionButton(title: "ブラックリスト", icon: "person.crop.circle.badge.minus", color: .red) {
                    // ブラックリスト画面へ
                }
                
                QuickActionButton(title: "緊急連絡先", icon: "phone.circle.fill", color: .green) {
                    // 緊急連絡先画面へ
                }
                
                QuickActionButton(title: "安全チェック", icon: "checkmark.shield.fill", color: .blue) {
                    // 安全チェック画面へ
                }
                
                QuickActionButton(title: "教育コンテンツ", icon: "book.fill", color: .purple) {
                    // 教育コンテンツ画面へ
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct AIFeaturesCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.purple)
                Text("AI機能")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 15) {
                AIFeatureRow(
                    title: "AIサポート",
                    description: "詐欺防止について質問できます",
                    icon: "message.fill",
                    color: .blue
                )
                
                AIFeatureRow(
                    title: "AI分析",
                    description: "通話・メール・ウェブサイトを分析",
                    icon: "magnifyingglass",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct AIFeatureRow: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 5)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmergencyAccessCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "sos")
                    .foregroundColor(.red)
                Text("緊急アクセス")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                EmergencyAccessRow(
                    title: "緊急SOS",
                    description: "緊急時に素早く家族に連絡",
                    icon: "phone.circle.fill",
                    color: .red
                )
                
                EmergencyAccessRow(
                    title: "音声アシスタント",
                    description: "音声でアプリを操作",
                    icon: "mic.fill",
                    color: .blue
                )
                
                EmergencyAccessRow(
                    title: "位置情報共有",
                    description: "現在地を家族に共有",
                    icon: "location.fill",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct EmergencyAccessRow: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
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
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 5)
    }
}

struct FamilyConnectionCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "person.3.fill")
                    .foregroundColor(.purple)
                Text("家族連携")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                FamilyConnectionRow(
                    title: "家族メンバー",
                    description: "登録済み: 3人",
                    icon: "person.2.fill",
                    color: .blue
                )
                
                FamilyConnectionRow(
                    title: "活動状況",
                    description: "2人がオンライン",
                    icon: "wifi",
                    color: .green
                )
                
                FamilyConnectionRow(
                    title: "緊急連絡",
                    description: "保護者に素早く連絡",
                    icon: "phone.circle.fill",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct FamilyConnectionRow: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
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
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 5)
    }
}

struct EducationCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "graduationcap.fill")
                    .foregroundColor(.blue)
                Text("今日のセキュリティ知識")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            Text("フィッシングメールの見分け方")
                .font(.headline)
            
            Text("銀行やクレジットカード会社を装ったメールには注意が必要です。URLをクリックする前に、送信者をよく確認しましょう。")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("詳しく学ぶ") {
                // 教育コンテンツ詳細へ
            }
            .font(.subheadline)
            .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

#Preview {
    HomeScreen()
} 