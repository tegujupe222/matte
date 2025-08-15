//
//  AIAnalysisScreen.swift
//  Matte
//
//  Created by Igasaki Gouta on 2025/08/04.
//

import SwiftUI

struct AIAnalysisScreen: View {
    @StateObject private var aiService = GeminiAIService()
    @State private var selectedAnalysisType: AnalysisType = .call
    @State private var inputContent = ""
    @State private var analysisResult: AnalysisResult?
    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 分析タイプ選択
                    AnalysisTypeSelector(selectedType: $selectedAnalysisType)
                    
                    // 入力エリア
                    InputArea(
                        type: selectedAnalysisType,
                        content: $inputContent,
                        onAnalyze: performAnalysis
                    )
                    
                    // 分析結果
                    if let result = analysisResult {
                        AnalysisResultView(result: result)
                    }
                    
                    // 分析履歴
                    AnalysisHistoryView()
                }
                .padding()
            }
            .navigationTitle("AI分析")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
        .alert("エラー", isPresented: $showingError) {
            Button("OK") { 
                showingError = false
            }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func performAnalysis() {
        guard !inputContent.isEmpty else { return }
        
        isLoading = true
        
        Task {
            do {
                let result: AnalysisResult
                
                switch selectedAnalysisType {
                case .call:
                    let callAnalysis = try await aiService.analyzeCallRisk(inputContent, context: nil)
                    result = AnalysisResult(
                        type: .call,
                        riskLevel: callAnalysis.riskLevel,
                        confidence: callAnalysis.confidence,
                        threats: callAnalysis.detectedThreats,
                        recommendations: callAnalysis.recommendations,
                        details: callAnalysis.callerInfo ?? "情報なし"
                    )
                    
                case .email:
                    let emailAnalysis = try await aiService.analyzeEmailRisk(inputContent)
                    result = AnalysisResult(
                        type: .email,
                        riskLevel: emailAnalysis.riskLevel,
                        confidence: emailAnalysis.confidence,
                        threats: emailAnalysis.detectedThreats,
                        recommendations: emailAnalysis.recommendations,
                        details: emailAnalysis.contentAnalysis
                    )
                    
                case .website:
                    let websiteAnalysis = try await aiService.analyzeWebsiteRisk(inputContent)
                    result = AnalysisResult(
                        type: .website,
                        riskLevel: websiteAnalysis.riskLevel,
                        confidence: websiteAnalysis.confidence,
                        threats: websiteAnalysis.detectedThreats,
                        recommendations: websiteAnalysis.recommendations,
                        details: websiteAnalysis.domainAnalysis
                    )
                }
                
                await MainActor.run {
                    analysisResult = result
                    isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
}

enum AnalysisType: String, CaseIterable {
    case call = "call"
    case email = "email"
    case website = "website"
    
    var displayName: String {
        switch self {
        case .call: return "通話分析"
        case .email: return "メール分析"
        case .website: return "ウェブサイト分析"
        }
    }
    
    var iconName: String {
        switch self {
        case .call: return "phone.fill"
        case .email: return "envelope.fill"
        case .website: return "globe"
        }
    }
    
    var placeholder: String {
        switch self {
        case .call: return "電話番号を入力してください"
        case .email: return "メール内容を入力してください"
        case .website: return "URLを入力してください"
        }
    }
}

struct AnalysisResult {
    let type: AnalysisType
    let riskLevel: RiskLevel
    let confidence: Double
    let threats: [String]
    let recommendations: [String]
    let details: String
}

struct AnalysisTypeSelector: View {
    @Binding var selectedType: AnalysisType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("分析タイプ")
                .font(.title3)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                ForEach(AnalysisType.allCases, id: \.self) { type in
                    AnalysisTypeButton(
                        type: type,
                        isSelected: selectedType == type,
                        onTap: { selectedType = type }
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

struct AnalysisTypeButton: View {
    let type: AnalysisType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                Image(systemName: type.iconName)
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(type.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct InputArea: View {
    let type: AnalysisType
    @Binding var content: String
    let onAnalyze: () -> Void
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.blue)
                Text("分析対象")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            TextField(type.placeholder, text: $content, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
                .disabled(isLoading)
            
            Button(action: onAnalyze) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "brain.head.profile")
                    }
                    
                    Text(isLoading ? "分析中..." : "AI分析を実行")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(content.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(content.isEmpty || isLoading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct AnalysisResultView: View {
    let result: AnalysisResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.purple)
                Text("分析結果")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            // リスクレベル
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("リスクレベル")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(result.riskLevel.displayName)
                        .font(.subheadline)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(result.riskLevel.color.opacity(0.2))
                        .foregroundColor(result.riskLevel.color)
                        .cornerRadius(4)
                }
                
                // 信頼度
                HStack {
                    Text("信頼度")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("\(Int(result.confidence * 100))%")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // 検出された脅威
            if !result.threats.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("検出された脅威")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ForEach(result.threats, id: \.self) { threat in
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .frame(width: 20)
                            
                            Text(threat)
                                .font(.subheadline)
                            
                            Spacer()
                        }
                    }
                }
            }
            
            Divider()
            
            // 推奨アクション
            VStack(alignment: .leading, spacing: 10) {
                Text("推奨アクション")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
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
            
            Divider()
            
            // 詳細情報
            VStack(alignment: .leading, spacing: 10) {
                Text("詳細情報")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(result.details)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct AnalysisHistoryView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                Text("分析履歴")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            Text("最近の分析結果がここに表示されます")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

#Preview {
    AIAnalysisScreen()
} 