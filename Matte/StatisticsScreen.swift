//
//  StatisticsScreen.swift
//  Matte
//
//  Created by Igasaki Gouta on 2025/08/04.
//

import SwiftUI

struct StatisticsScreen: View {
    @StateObject private var aiService = AIService()
    @State private var selectedPeriod: StatisticsPeriod = .week
    @State private var statistics: SecurityStatistics?
    @State private var isLoading = false
    @State private var achievements: [Achievement] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // 期間選択
                    PeriodSelectorView(selectedPeriod: $selectedPeriod)
                    
                    if isLoading {
                        ProgressView("統計を読み込み中...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.vertical, 50)
                    } else if let stats = statistics {
                        // 保護スコア
                        ProtectionScoreCard(score: stats.protectionScore)
                        
                        // 統計サマリー
                        StatisticsSummaryCard(statistics: stats)
                        
                        // トレンドグラフ
                        TrendsChartCard(trends: stats.trends)
                        
                        // 詳細統計
                        DetailedStatisticsCard(statistics: stats)
                        
                        // 達成度
                        AchievementsCard(achievements: achievements)
                        
                        // 推奨事項
                        RecommendationsCard(statistics: stats)
                    }
                }
                .padding()
            }
            .navigationTitle("統計・レポート")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
            .onAppear {
                loadStatistics()
                loadAchievements()
            }
            .onChange(of: selectedPeriod) { _ in
                loadStatistics()
            }
        }
    }
    
    private func loadStatistics() {
        isLoading = true
        
        Task {
            let stats = await aiService.generateSecurityReport(period: selectedPeriod)
            
            DispatchQueue.main.async {
                self.statistics = stats
                self.isLoading = false
            }
        }
    }
    
    private func loadAchievements() {
        achievements = [
            Achievement(
                title: "初回保護",
                description: "初めてセキュリティ保護を有効にしました",
                iconName: "shield.fill",
                category: .security,
                isUnlocked: true,
                unlockedDate: Date().addingTimeInterval(-86400 * 7),
                progress: 1.0
            ),
            Achievement(
                title: "学習者",
                description: "教育コンテンツを5つ完了しました",
                iconName: "graduationcap.fill",
                category: .education,
                isUnlocked: true,
                unlockedDate: Date().addingTimeInterval(-86400 * 3),
                progress: 1.0
            ),
            Achievement(
                title: "家族連携",
                description: "家族メンバーを3人追加しました",
                iconName: "person.3.fill",
                category: .family,
                isUnlocked: false,
                unlockedDate: nil,
                progress: 0.67
            ),
            Achievement(
                title: "継続利用",
                description: "30日間連続でアプリを使用しました",
                iconName: "calendar.badge.clock",
                category: .usage,
                isUnlocked: false,
                unlockedDate: nil,
                progress: 0.8
            )
        ]
    }
}

struct PeriodSelectorView: View {
    @Binding var selectedPeriod: StatisticsPeriod
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("期間選択")
                .font(.headline)
                .fontWeight(.bold)
            
            HStack(spacing: 10) {
                ForEach(StatisticsPeriod.allCases, id: \.self) { period in
                    PeriodButton(
                        period: period,
                        isSelected: selectedPeriod == period,
                        action: { selectedPeriod = period }
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct PeriodButton: View {
    let period: StatisticsPeriod
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(period.rawValue)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.blue : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue, lineWidth: isSelected ? 0 : 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ProtectionScoreCard: View {
    let score: Int
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "shield.fill")
                    .foregroundColor(.green)
                Text("保護スコア")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: Double(score) / 100.0)
                    .stroke(
                        LinearGradient(
                            colors: scoreColor,
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 15, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: score)
                
                VStack {
                    Text("\(score)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(scoreColor.first)
                    
                    Text("点")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(scoreDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
    
    private var scoreColor: [Color] {
        switch score {
        case 0..<50: return [.red]
        case 50..<75: return [.orange]
        case 75..<90: return [.yellow]
        default: return [.green]
        }
    }
    
    private var scoreDescription: String {
        switch score {
        case 0..<50: return "セキュリティが脆弱です\n設定を見直してください"
        case 50..<75: return "セキュリティが改善されています\nさらなる強化をお勧めします"
        case 75..<90: return "良好なセキュリティ状態です\nこの調子を維持しましょう"
        default: return "優秀なセキュリティ状態です\n完璧な保護ができています"
        }
    }
}

struct StatisticsSummaryCard: View {
    let statistics: SecurityStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                Text("統計サマリー")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                StatItem(
                    title: "総警告数",
                    value: "\(statistics.totalAlerts)",
                    icon: "exclamationmark.triangle.fill",
                    color: .orange
                )
                
                StatItem(
                    title: "ブロック通話",
                    value: "\(statistics.blockedCalls)",
                    icon: "phone.down.fill",
                    color: .red
                )
                
                StatItem(
                    title: "安全メール",
                    value: "\(statistics.safeEmails)",
                    icon: "envelope.fill",
                    color: .green
                )
                
                StatItem(
                    title: "学習完了",
                    value: "\(statistics.educationCompleted)",
                    icon: "graduationcap.fill",
                    color: .blue
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct TrendsChartCard: View {
    let trends: [StatisticsTrend]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.purple)
                Text("トレンド分析")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            // シンプルなグラフ表示（Chartsフレームワークなし）
            VStack(spacing: 10) {
                ForEach(trends.suffix(7)) { trend in
                    HStack {
                        Text(trend.date, style: .date)
                            .font(.caption)
                        
                        Spacer()
                        
                        Text("警告: \(trend.alerts)")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Text("スコア: \(trend.protectionScore)")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(5)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct DetailedStatisticsCard: View {
    let statistics: SecurityStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "list.bullet.clipboard")
                    .foregroundColor(.indigo)
                Text("詳細統計")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                DetailRow(
                    title: "ブロックされたウェブサイト",
                    value: "\(statistics.blockedWebsites)",
                    icon: "globe",
                    color: .red
                )
                
                DetailRow(
                    title: "平均保護スコア",
                    value: "\(statistics.protectionScore)点",
                    icon: "shield.lefthalf.filled",
                    color: .green
                )
                
                DetailRow(
                    title: "学習進捗率",
                    value: "\(Int(Double(statistics.educationCompleted) / 10.0 * 100))%",
                    icon: "book.fill",
                    color: .blue
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 25)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
}

struct AchievementsCard: View {
    let achievements: [Achievement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)
                Text("達成度")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                
                Text("\(achievements.filter(\.isUnlocked).count)/\(achievements.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                ForEach(achievements) { achievement in
                    AchievementItem(achievement: achievement)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct AchievementItem: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? achievement.category.color : Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.iconName)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
            }
            
            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                
                if !achievement.isUnlocked {
                    ProgressView(value: achievement.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: achievement.category.color))
                        .frame(height: 4)
                    
                    Text("\(Int(achievement.progress * 100))%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(achievement.isUnlocked ? achievement.category.color.opacity(0.1) : Color.gray.opacity(0.1))
        )
    }
}

struct RecommendationsCard: View {
    let statistics: SecurityStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("推奨事項")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                RecommendationRow(
                    title: "学習コンテンツの活用",
                    description: "セキュリティ知識を向上させましょう",
                    icon: "book.fill",
                    priority: .high
                )
                
                if statistics.blockedCalls > 0 {
                    RecommendationRow(
                        title: "ブロックリストの確認",
                        description: "ブロックされた通話を確認してください",
                        icon: "phone.down.fill",
                        priority: .medium
                    )
                }
                
                RecommendationRow(
                    title: "家族との連携強化",
                    description: "緊急時の連絡体制を整えましょう",
                    icon: "person.2.fill",
                    priority: .low
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct RecommendationRow: View {
    let title: String
    let description: String
    let icon: String
    let priority: Priority
    
    enum Priority {
        case low, medium, high
        
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .orange
            case .high: return .red
            }
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(priority.color)
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
            
            Circle()
                .fill(priority.color)
                .frame(width: 8, height: 8)
        }
    }
}

#Preview {
    StatisticsScreen()
}
