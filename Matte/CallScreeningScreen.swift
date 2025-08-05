//
//  CallScreeningScreen.swift
//  Matte
//
//  Created by Igasaki Gouta on 2025/08/04.
//

import SwiftUI

struct CallScreeningScreen: View {
    @State private var recentCalls: [CallEntry] = []
    @State private var blacklistedNumbers: [String] = []
    @State private var showingAddBlacklist = false
    @State private var newBlacklistNumber = ""
    @State private var isCallScreeningEnabled = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 通話スクリーニング状況
                    CallScreeningStatusCard(isEnabled: $isCallScreeningEnabled)
                    
                    // 最近の通話履歴
                    RecentCallsCard(calls: recentCalls)
                    
                    // ブラックリスト管理
                    BlacklistCard(
                        blacklistedNumbers: blacklistedNumbers,
                        onAdd: { showingAddBlacklist = true },
                        onRemove: { number in
                            blacklistedNumbers.removeAll { $0 == number }
                        }
                    )
                    
                    // 統計情報
                    CallStatisticsCard(calls: recentCalls)
                }
                .padding()
            }
            .navigationTitle("通話スクリーニング")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
        .onAppear {
            loadCallData()
        }
        .sheet(isPresented: $showingAddBlacklist) {
            AddBlacklistView(
                phoneNumber: $newBlacklistNumber,
                onAdd: {
                    if !newBlacklistNumber.isEmpty {
                        blacklistedNumbers.append(newBlacklistNumber)
                        newBlacklistNumber = ""
                        showingAddBlacklist = false
                    }
                }
            )
        }
    }
    
    private func loadCallData() {
        // サンプルデータ
        recentCalls = [
            CallEntry(
                phoneNumber: "090-1234-5678",
                callerName: "不明",
                timestamp: Date(),
                isBlocked: true,
                riskLevel: .dangerous,
                duration: nil
            ),
            CallEntry(
                phoneNumber: "03-1234-5678",
                callerName: "銀行",
                timestamp: Date().addingTimeInterval(-3600),
                isBlocked: false,
                riskLevel: .suspicious,
                duration: 120
            ),
            CallEntry(
                phoneNumber: "080-9876-5432",
                callerName: "家族",
                timestamp: Date().addingTimeInterval(-7200),
                isBlocked: false,
                riskLevel: .safe,
                duration: 300
            )
        ]
        
        blacklistedNumbers = ["090-1234-5678", "090-9999-9999"]
    }
}

struct CallScreeningStatusCard: View {
    @Binding var isEnabled: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: isEnabled ? "phone.down.circle.fill" : "phone.down.circle")
                    .font(.system(size: 40))
                    .foregroundColor(isEnabled ? .green : .gray)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(isEnabled ? "通話スクリーニング有効" : "通話スクリーニング無効")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(isEnabled ? "危険な通話を自動的にブロックします" : "設定で有効にしてください")
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

struct RecentCallsCard: View {
    let calls: [CallEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                Text("最近の通話")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            if calls.isEmpty {
                Text("通話履歴がありません")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(calls.prefix(5), id: \.id) { call in
                    CallRow(call: call)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct CallRow: View {
    let call: CallEntry
    
    var body: some View {
        HStack {
            Image(systemName: call.isBlocked ? "phone.down.fill" : "phone.fill")
                .foregroundColor(call.riskLevel.color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(call.callerName ?? "不明")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(call.phoneNumber)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(call.riskLevel.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(call.riskLevel.color.opacity(0.2))
                    .cornerRadius(4)
                
                Text(call.timestamp, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 5)
    }
}

struct BlacklistCard: View {
    let blacklistedNumbers: [String]
    let onAdd: () -> Void
    let onRemove: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "person.crop.circle.badge.minus.fill")
                    .foregroundColor(.red)
                Text("ブラックリスト")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                
                Button("追加") {
                    onAdd()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            if blacklistedNumbers.isEmpty {
                Text("ブラックリストに登録された番号はありません")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(blacklistedNumbers, id: \.self) { number in
                    HStack {
                        Text(number)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Button("削除") {
                            onRemove(number)
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct CallStatisticsCard: View {
    let calls: [CallEntry]
    
    private var blockedCount: Int {
        calls.filter { $0.isBlocked }.count
    }
    
    private var dangerousCount: Int {
        calls.filter { $0.riskLevel == .dangerous }.count
    }
    
    private var totalCount: Int {
        calls.count
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
                StatisticItem(title: "総通話数", value: "\(totalCount)", color: .blue)
                StatisticItem(title: "ブロック数", value: "\(blockedCount)", color: .red)
                StatisticItem(title: "危険通話", value: "\(dangerousCount)", color: .orange)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct StatisticItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct AddBlacklistView: View {
    @Binding var phoneNumber: String
    let onAdd: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("ブラックリストに追加")
                    .font(.title2)
                    .fontWeight(.bold)
                
                TextField("電話番号を入力", text: $phoneNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
                
                Button("追加") {
                    onAdd()
                }
                .buttonStyle(.borderedProminent)
                .disabled(phoneNumber.isEmpty)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("キャンセル") {
                dismiss()
            })
        }
    }
}

#Preview {
    CallScreeningScreen()
} 