//
//  MainTabView.swift
//  Matte
//
//  Created by Igasaki Gouta on 2025/08/04.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeScreen()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Matte")
                }
            
            CallScreeningScreen()
                .tabItem {
                    Image(systemName: "phone.fill")
                    Text("Matte")
                }
            
            EmailAlertScreen()
                .tabItem {
                    Image(systemName: "envelope.fill")
                    Text("Matte")
                }
            
            WebSafetyScreen()
                .tabItem {
                    Image(systemName: "globe")
                    Text("Matte")
                }
            
            AISupportScreen()
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("Matte")
                }
            
            AIAnalysisScreen()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Matte")
                }
            
            SettingsScreen()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Matte")
                }
        }
        .accentColor(.red) // 警告色として赤を使用
        .font(.title2) // 高齢者向けに大きなフォント
    }
}

#Preview {
    MainTabView()
} 