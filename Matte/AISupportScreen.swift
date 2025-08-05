//
//  AISupportScreen.swift
//  Matte
//
//  Created by Igasaki Gouta on 2025/08/04.
//

import SwiftUI

struct AISupportScreen: View {
    @StateObject private var aiService = GeminiAIService()
    @State private var userQuestion = ""
    @State private var aiResponse = ""
    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var conversationHistory: [ConversationItem] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 会話履歴
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(conversationHistory, id: \.id) { item in
                            ConversationBubble(item: item)
                        }
                        
                        if isLoading {
                            LoadingBubble()
                        }
                    }
                    .padding()
                }
                
                // 入力エリア
                VStack(spacing: 10) {
                    HStack {
                        TextField("質問を入力してください...", text: $userQuestion, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                            .disabled(isLoading)
                        
                        Button(action: sendQuestion) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(userQuestion.isEmpty ? Color.gray : Color.blue)
                                .cornerRadius(20)
                        }
                        .disabled(userQuestion.isEmpty || isLoading)
                    }
                    
                    // クイック質問ボタン
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            QuickQuestionButton(title: "フィッシングとは？") {
                                userQuestion = "フィッシング詐欺について教えてください"
                            }
                            
                            QuickQuestionButton(title: "電話詐欺の見分け方") {
                                userQuestion = "電話詐欺の見分け方を教えてください"
                            }
                            
                            QuickQuestionButton(title: "安全なサイトの見分け方") {
                                userQuestion = "安全なウェブサイトの見分け方を教えてください"
                            }
                            
                            QuickQuestionButton(title: "個人情報の保護方法") {
                                userQuestion = "個人情報を守る方法を教えてください"
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .shadow(radius: 2)
            }
            .navigationTitle("AIサポート")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
        .alert("エラー", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            loadInitialConversation()
        }
    }
    
    private func sendQuestion() {
        guard !userQuestion.isEmpty else { return }
        
        let question = userQuestion
        userQuestion = ""
        
        // ユーザーの質問を履歴に追加
        let userItem = ConversationItem(
            id: UUID(),
            type: .user,
            content: question,
            timestamp: Date()
        )
        conversationHistory.append(userItem)
        
        // AI回答を取得
        isLoading = true
        
        Task {
            do {
                let response = try await aiService.answerUserQuestion(question)
                
                await MainActor.run {
                    let aiItem = ConversationItem(
                        id: UUID(),
                        type: .ai,
                        content: response,
                        timestamp: Date()
                    )
                    conversationHistory.append(aiItem)
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
    
    private func loadInitialConversation() {
        let welcomeMessage = """
        こんにちは！私は詐欺防止AIアシスタントです。
        
        以下のような質問にお答えできます：
        • 詐欺の手口について
        • 安全対策のアドバイス
        • 不審な通話やメールの判断
        • 個人情報保護の方法
        
        何でもお気軽にお聞きください！
        """
        
        let welcomeItem = ConversationItem(
            id: UUID(),
            type: .ai,
            content: welcomeMessage,
            timestamp: Date()
        )
        
        conversationHistory.append(welcomeItem)
    }
}

struct ConversationItem: Identifiable {
    let id: UUID
    let type: ConversationType
    let content: String
    let timestamp: Date
}

enum ConversationType {
    case user
    case ai
}

struct ConversationBubble: View {
    let item: ConversationItem
    
    var body: some View {
        HStack {
            if item.type == .user {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 5) {
                    Text(item.content)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    
                    Text(item.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.purple)
                            .frame(width: 20)
                        
                        Text(item.content)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(15)
                    }
                    
                    Text(item.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
    }
}

struct LoadingBubble: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.purple)
                        .frame(width: 20)
                    
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 8, height: 8)
                                .scaleEffect(isAnimating ? 1.2 : 0.8)
                                .animation(
                                    Animation.easeInOut(duration: 0.6)
                                        .repeatForever()
                                        .delay(Double(index) * 0.2),
                                    value: isAnimating
                                )
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                }
            }
            
            Spacer()
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct QuickQuestionButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(15)
        }
    }
}

#Preview {
    AISupportScreen()
} 