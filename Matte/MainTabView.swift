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
                    Text("ホーム")
                }
            
            EmergencySOSScreen()
                .tabItem {
                    Image(systemName: "sos")
                    Text("緊急SOS")
                }
            
            FamilyConnectionScreen()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("家族連携")
                }
            
            VoiceAssistantScreen()
                .tabItem {
                    Image(systemName: "mic.fill")
                    Text("音声")
                }
            
            StatisticsScreen()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("統計")
                }
            
            SettingsScreen()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("設定")
                }
        }
        .accentColor(.red) // 警告色として赤を使用
        .font(.title2) // 高齢者向けに大きなフォント
    }
}

#Preview {
    MainTabView()
} 