//
//  EmailAlertScreen.swift
//  Matte
//
//  Created by Igasaki Gouta on 2025/08/04.
//

import SwiftUI

struct EmailAlertScreen: View {
    @State private var emailAlerts: [ScamAlert] = []
    @State private var isEmailAlertEnabled = true
    @State private var showingEmailDetail = false
    @State private var selectedAlert: ScamAlert?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // メール警告状況
                    EmailAlertStatusCard(isEnabled: $isEmailAlertEnabled)
                    
                    // 最近の警告
                    if !emailAlerts.isEmpty {
                        RecentEmailAlertsCard(
                            alerts: emailAlerts,
                            onAlertTap: { alert in
                                selectedAlert = alert
                                showingEmailDetail = true
                            }
                        )
                    }
                    
                    // 統計情報
                    EmailStatisticsCard(alerts: emailAlerts)
                    
                    // 安全なメールの例
                    SafeEmailExamplesCard()
                }
                .padding()
            }
            .navigationTitle("メール警告")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
        .onAppear {
            loadEmailAlerts()
        }
        .sheet(isPresented: $showingEmailDetail) {
            if let alert = selectedAlert {
                EmailDetailView(alert: alert)
            }
        }
    }
    
    private func loadEmailAlerts() {
        // サンプルデータ
        emailAlerts = [
            ScamAlert(
                type: .email,
                title: "銀行からの緊急通知",
                description: "口座の停止を装ったフィッシングメール",
                timestamp: Date(),
                severity: .high
            ),
            ScamAlert(
                type: .email,
                title: "Amazonからの注文確認",
                description: "身に覚えのない注文を装った詐欺メール",
                timestamp: Date().addingTimeInterval(-3600),
                severity: .medium
            ),
            ScamAlert(
                type: .email,
                title: "政府機関からの通知",
                description: "税金の還付を装った詐欺メール",
                timestamp: Date().addingTimeInterval(-7200),
                severity: .critical
            )
        ]
    }
}

struct EmailAlertStatusCard: View {
    @Binding var isEnabled: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: isEnabled ? "envelope.badge.fill" : "envelope.badge.fill")
                    .font(.system(size: 40))
                    .foregroundColor(isEnabled ? .green : .gray)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(isEnabled ? "メール警告有効" : "メール警告無効")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(isEnabled ? "不審なメールを自動的に検出します" : "設定で有効にしてください")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct RecentEmailAlertsCard: View {
    let alerts: [ScamAlert]
    let onAlertTap: (ScamAlert) -> Void
    
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
            
            ForEach(alerts.prefix(5), id: \.id) { alert in
                EmailAlertRow(alert: alert, onTap: { onAlertTap(alert) })
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct EmailAlertRow: View {
    let alert: ScamAlert
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: alert.type.iconName)
                    .foregroundColor(alert.severity.color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(alert.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(alert.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(alert.severity.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(alert.severity.color.opacity(0.2))
                        .cornerRadius(4)
                    
                    Text(alert.timestamp, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmailStatisticsCard: View {
    let alerts: [ScamAlert]
    
    private var highRiskCount: Int {
        alerts.filter { $0.severity == .high || $0.severity == .critical }.count
    }
    
    private var totalCount: Int {
        alerts.count
    }
    
    private var blockedCount: Int {
        alerts.filter { $0.severity == .critical }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.purple)
                Text("統計情報")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                StatisticItem(title: "総警告数", value: "\(totalCount)", color: .blue)
                StatisticItem(title: "高リスク", value: "\(highRiskCount)", color: .orange)
                StatisticItem(title: "ブロック済み", value: "\(blockedCount)", color: .red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct SafeEmailExamplesCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(.green)
                Text("安全なメールの例")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 10) {
                SafeEmailExample(
                    title: "銀行からの通知",
                    description: "送信者アドレスが正規の銀行ドメイン",
                    isSafe: true
                )
                
                SafeEmailExample(
                    title: "Amazonからの注文確認",
                    description: "実際に注文した商品の確認メール",
                    isSafe: true
                )
                
                SafeEmailExample(
                    title: "政府機関からの通知",
                    description: "正式な政府ドメインからの通知",
                    isSafe: true
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct SafeEmailExample: View {
    let title: String
    let description: String
    let isSafe: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isSafe ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isSafe ? .green : .red)
                .frame(width: 20)
            
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
    }
}

struct EmailDetailView: View {
    let alert: ScamAlert
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 警告ヘッダー
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(alert.severity.color)
                                .font(.title)
                            
                            Text(alert.title)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        Text(alert.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(alert.severity.color.opacity(0.1))
                    .cornerRadius(10)
                    
                    // 詳細情報
                    VStack(alignment: .leading, spacing: 15) {
                        Text("検出された脅威")
                            .font(.headline)
                        
                        ThreatDetailItem(title: "フィッシング", description: "偽のログインページへの誘導")
                        ThreatDetailItem(title: "個人情報の要求", description: "パスワードやクレジットカード情報の要求")
                        ThreatDetailItem(title: "緊急性の演出", description: "即座の対応を求める内容")
                    }
                    
                    // 推奨アクション
                    VStack(alignment: .leading, spacing: 15) {
                        Text("推奨アクション")
                            .font(.headline)
                        
                        ActionItem(title: "メールを削除", description: "このメールは削除してください")
                        ActionItem(title: "リンクをクリックしない", description: "メール内のリンクは絶対にクリックしないでください")
                        ActionItem(title: "情報を入力しない", description: "個人情報やパスワードを入力しないでください")
                    }
                    
                    // 緊急連絡先
                    VStack(alignment: .leading, spacing: 15) {
                        Text("緊急時の連絡先")
                            .font(.headline)
                        
                        Button("家族に通知") {
                            // 家族への通知機能
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        
                        Button("警察に相談") {
                            // 警察への相談機能
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
            }
            .navigationTitle("警告詳細")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("閉じる") {
                dismiss()
            })
        }
    }
}

struct ThreatDetailItem: View {
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
                .frame(width: 20)
            
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
    }
}

struct ActionItem: View {
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .frame(width: 20)
            
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
    }
}

#Preview {
    EmailAlertScreen()
} 