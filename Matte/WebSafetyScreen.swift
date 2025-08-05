//
//  WebSafetyScreen.swift
//  Matte
//
//  Created by Igasaki Gouta on 2025/08/04.
//

import SwiftUI

struct WebSafetyScreen: View {
    @State private var urlToCheck = ""
    @State private var isWebSafetyEnabled = true
    @State private var showingSafetyCheck = false
    @State private var safetyCheckResult: WebSafetyCheck?
    @State private var recentChecks: [WebSafetyCheck] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // ウェブ安全確認状況
                    WebSafetyStatusCard(isEnabled: $isWebSafetyEnabled)
                    
                    // URL安全確認
                    URLCheckCard(
                        url: $urlToCheck,
                        onCheck: {
                            showingSafetyCheck = true
                            performSafetyCheck()
                        }
                    )
                    
                    // 最近の確認履歴
                    if !recentChecks.isEmpty {
                        RecentChecksCard(checks: recentChecks)
                    }
                    
                    // 安全なサイトの例
                    SafeSitesExamplesCard()
                }
                .padding()
            }
            .navigationTitle("ウェブ安全確認")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
        .onAppear {
            loadRecentChecks()
        }
        .sheet(isPresented: $showingSafetyCheck) {
            if let result = safetyCheckResult {
                SafetyCheckResultView(result: result)
            }
        }
    }
    
    private func performSafetyCheck() {
        // サンプルの安全確認結果
        safetyCheckResult = WebSafetyCheck(
            url: urlToCheck,
            isSafe: urlToCheck.contains("https") && !urlToCheck.contains("suspicious"),
            riskScore: urlToCheck.contains("suspicious") ? 85 : 15,
            threats: urlToCheck.contains("suspicious") ? ["フィッシング", "マルウェア配布"] : [],
            recommendations: urlToCheck.contains("suspicious") ? ["このサイトは危険です", "アクセスを避けてください"] : ["安全なサイトです"],
            lastChecked: Date()
        )
        
        if let result = safetyCheckResult {
            recentChecks.insert(result, at: 0)
        }
    }
    
    private func loadRecentChecks() {
        // サンプルデータ
        recentChecks = [
            WebSafetyCheck(
                url: "https://www.google.com",
                isSafe: true,
                riskScore: 10,
                threats: [],
                recommendations: ["安全なサイトです"],
                lastChecked: Date()
            ),
            WebSafetyCheck(
                url: "https://suspicious-site.com",
                isSafe: false,
                riskScore: 90,
                threats: ["フィッシング", "個人情報窃取"],
                recommendations: ["このサイトは危険です", "アクセスを避けてください"],
                lastChecked: Date().addingTimeInterval(-3600)
            )
        ]
    }
}

struct WebSafetyStatusCard: View {
    @Binding var isEnabled: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: isEnabled ? "globe.badge.checkmark.fill" : "globe.badge.xmark.fill")
                    .font(.system(size: 40))
                    .foregroundColor(isEnabled ? .green : .gray)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(isEnabled ? "ウェブ安全確認有効" : "ウェブ安全確認無効")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(isEnabled ? "危険なウェブサイトを自動的に検出します" : "設定で有効にしてください")
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

struct URLCheckCard: View {
    @Binding var url: String
    let onCheck: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.blue)
                Text("URL安全確認")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            TextField("URLを入力してください", text: $url)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.URL)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            Button("安全確認を実行") {
                onCheck()
            }
            .buttonStyle(.borderedProminent)
            .disabled(url.isEmpty)
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct RecentChecksCard: View {
    let checks: [WebSafetyCheck]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                Text("最近の確認履歴")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            ForEach(checks.prefix(5), id: \.url) { check in
                CheckRow(check: check)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct CheckRow: View {
    let check: WebSafetyCheck
    
    var body: some View {
        HStack {
            Image(systemName: check.isSafe ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(check.isSafe ? .green : .red)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(check.url)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text("リスクスコア: \(check.riskScore)/100")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(check.isSafe ? "安全" : "危険")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background((check.isSafe ? Color.green : Color.red).opacity(0.2))
                    .cornerRadius(4)
                
                Text(check.lastChecked, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 5)
    }
}

struct SafeSitesExamplesCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(.green)
                Text("安全なサイトの例")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 10) {
                SafeSiteExample(
                    title: "Google",
                    url: "https://www.google.com",
                    description: "正規の検索エンジン"
                )
                
                SafeSiteExample(
                    title: "Amazon",
                    url: "https://www.amazon.co.jp",
                    description: "正規のECサイト"
                )
                
                SafeSiteExample(
                    title: "銀行サイト",
                    url: "https://www.bank.co.jp",
                    description: "正規の銀行サイト"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct SafeSiteExample: View {
    let title: String
    let url: String
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
                
                Text(url)
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct SafetyCheckResultView: View {
    let result: WebSafetyCheck
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 結果ヘッダー
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: result.isSafe ? "checkmark.shield.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(result.isSafe ? .green : .red)
                                .font(.title)
                            
                            Text(result.isSafe ? "安全なサイト" : "危険なサイト")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        Text(result.url)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background((result.isSafe ? Color.green : Color.red).opacity(0.1))
                    .cornerRadius(10)
                    
                    // リスクスコア
                    VStack(alignment: .leading, spacing: 15) {
                        Text("リスクスコア")
                            .font(.headline)
                        
                        HStack {
                            Text("\(result.riskScore)/100")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(result.riskScore > 50 ? .red : .green)
                            
                            Spacer()
                            
                            ProgressView(value: Double(result.riskScore), total: 100)
                                .progressViewStyle(LinearProgressViewStyle(tint: result.riskScore > 50 ? .red : .green))
                                .frame(width: 100)
                        }
                    }
                    
                    // 検出された脅威
                    if !result.threats.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("検出された脅威")
                                .font(.headline)
                            
                            ForEach(result.threats, id: \.self) { threat in
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .frame(width: 20)
                                    
                                    Text(threat)
                                        .font(.subheadline)
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    // 推奨アクション
                    VStack(alignment: .leading, spacing: 15) {
                        Text("推奨アクション")
                            .font(.headline)
                        
                        ForEach(result.recommendations, id: \.self) { recommendation in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .frame(width: 20)
                                
                                Text(recommendation)
                                    .font(.subheadline)
                                
                                Spacer()
                            }
                        }
                    }
                    
                    // アクションボタン
                    VStack(spacing: 10) {
                        if !result.isSafe {
                            Button("このサイトをブロック") {
                                // ブロック機能
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                        }
                        
                        Button("詳細レポートを確認") {
                            // 詳細レポート機能
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
            }
            .navigationTitle("安全確認結果")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("閉じる") {
                dismiss()
            })
        }
    }
}

#Preview {
    WebSafetyScreen()
} 