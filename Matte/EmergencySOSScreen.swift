//
//  EmergencySOSScreen.swift
//  Matte
//
//  Created by Igasaki Gouta on 2025/08/04.
//

import SwiftUI
import CoreLocation

struct EmergencySOSScreen: View {
    @StateObject private var locationManager = LocationManager()
    @State private var sosSettings = EmergencySOS(
        isEnabled: true,
        triggerMethod: .powerButton,
        autoCallEnabled: true,
        autoMessageEnabled: true,
        locationSharingEnabled: true,
        contacts: [],
        customMessage: "緊急事態が発生しました。すぐに連絡してください。"
    )
    @State private var showingContactPicker = false
    @State private var showingTriggerTest = false
    @State private var isSOSActive = false
    @State private var countdown = 5
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // 緊急SOSボタン
                    EmergencySOSButton(
                        isActive: $isSOSActive,
                        countdown: $countdown,
                        onActivate: activateSOS
                    )
                    
                    // SOS設定
                    SOSSettingsCard(settings: $sosSettings)
                    
                    // 緊急連絡先
                    EmergencyContactsCard(
                        contacts: $sosSettings.contacts,
                        onAddContact: { showingContactPicker = true }
                    )
                    
                    // トリガー設定
                    TriggerSettingsCard(
                        triggerMethod: $sosSettings.triggerMethod,
                        onTestTrigger: { showingTriggerTest = true }
                    )
                    
                    // 自動アクション設定
                    AutoActionsCard(settings: $sosSettings)
                    
                    // 安全機能
                    SafetyFeaturesCard()
                }
                .padding()
            }
            .navigationTitle("緊急SOS")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showingContactPicker) {
                ContactPickerView(contacts: $sosSettings.contacts)
            }
            .sheet(isPresented: $showingTriggerTest) {
                TriggerTestView(triggerMethod: sosSettings.triggerMethod)
            }
        }
    }
    
    private func activateSOS() {
        isSOSActive = true
        
        // カウントダウン開始
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer.invalidate()
                executeSOSActions()
            }
        }
    }
    
    private func executeSOSActions() {
        // 自動通話
        if sosSettings.autoCallEnabled && !sosSettings.contacts.isEmpty {
            // 最初の連絡先に電話
            if let firstContact = sosSettings.contacts.first {
                callEmergencyContact(firstContact)
            }
        }
        
        // 自動メッセージ送信
        if sosSettings.autoMessageEnabled {
            sendEmergencyMessages()
        }
        
        // 位置情報共有
        if sosSettings.locationSharingEnabled {
            shareLocation()
        }
        
        // SOSをリセット
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isSOSActive = false
            countdown = 5
        }
    }
    
    private func callEmergencyContact(_ contact: EmergencyContact) {
        // 実際の通話機能を実装
        print("緊急通話: \(contact.name) (\(contact.phoneNumber))")
    }
    
    private func sendEmergencyMessages() {
        // 実際のメッセージ送信機能を実装
        print("緊急メッセージ送信: \(sosSettings.customMessage)")
    }
    
    private func shareLocation() {
        // 実際の位置情報共有機能を実装
        if let location = locationManager.location {
            print("位置情報共有: \(location.coordinate)")
        }
    }
}

struct EmergencySOSButton: View {
    @Binding var isActive: Bool
    @Binding var countdown: Int
    let onActivate: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Button(action: onActivate) {
                VStack(spacing: 15) {
                    Image(systemName: isActive ? "exclamationmark.triangle.fill" : "sos")
                        .font(.system(size: 60))
                        .foregroundColor(isActive ? .white : .red)
                    
                    Text(isActive ? "SOS実行中..." : "緊急SOS")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(isActive ? .white : .red)
                    
                    if isActive {
                        Text("\(countdown)秒後に実行")
                            .font(.headline)
                            .foregroundColor(.white)
                    } else {
                        Text("タップして緊急通報")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isActive ? Color.red : Color.red.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.red, lineWidth: 3)
                        )
                )
            }
            .disabled(isActive)
            .scaleEffect(isActive ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: isActive)
            
            if isActive {
                Button("キャンセル") {
                    isActive = false
                    countdown = 5
                }
                .foregroundColor(.red)
                .font(.headline)
            }
        }
    }
}

struct SOSSettingsCard: View {
    @Binding var settings: EmergencySOS
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.blue)
                Text("SOS設定")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            Toggle("SOS機能を有効にする", isOn: $settings.isEnabled)
                .font(.subheadline)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("カスタムメッセージ")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("緊急メッセージを入力", text: $settings.customMessage, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct EmergencyContactsCard: View {
    @Binding var contacts: [EmergencyContact]
    let onAddContact: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.green)
                Text("緊急連絡先")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                
                Button("追加") {
                    onAddContact()
                }
                .foregroundColor(.blue)
            }
            
            if contacts.isEmpty {
                Text("緊急連絡先が設定されていません")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 20)
            } else {
                ForEach(contacts) { contact in
                    EmergencyContactRow(contact: contact)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct EmergencyContactRow: View {
    let contact: EmergencyContact
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(contact.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(contact.phoneNumber)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(contact.relationship)
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            if contact.isEnabled {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 5)
    }
}

struct TriggerSettingsCard: View {
    @Binding var triggerMethod: SOSTriggerMethod
    let onTestTrigger: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "hand.tap.fill")
                    .foregroundColor(.orange)
                Text("トリガー設定")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                
                Button("テスト") {
                    onTestTrigger()
                }
                .foregroundColor(.blue)
            }
            
            Picker("トリガー方法", selection: $triggerMethod) {
                ForEach(SOSTriggerMethod.allCases, id: \.self) { method in
                    Text(method.rawValue).tag(method)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            Text(triggerMethod.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct AutoActionsCard: View {
    @Binding var settings: EmergencySOS
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.purple)
                Text("自動アクション")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            Toggle("自動通話", isOn: $settings.autoCallEnabled)
                .font(.subheadline)
            
            Toggle("自動メッセージ送信", isOn: $settings.autoMessageEnabled)
                .font(.subheadline)
            
            Toggle("位置情報共有", isOn: $settings.locationSharingEnabled)
                .font(.subheadline)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct SafetyFeaturesCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "shield.fill")
                    .foregroundColor(.green)
                Text("安全機能")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 10) {
                SafetyFeatureRow(
                    title: "誤作動防止",
                    description: "5秒のカウントダウンで誤作動を防止",
                    icon: "clock.fill",
                    color: .blue
                )
                
                SafetyFeatureRow(
                    title: "緊急解除",
                    description: "いつでもキャンセル可能",
                    icon: "xmark.circle.fill",
                    color: .red
                )
                
                SafetyFeatureRow(
                    title: "位置情報追跡",
                    description: "GPSで正確な位置を特定",
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

struct SafetyFeatureRow: View {
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
        }
    }
}

// MARK: - Supporting Views
struct ContactPickerView: View {
    @Binding var contacts: [EmergencyContact]
    @Environment(\.dismiss) private var dismiss
    @State private var newContact = EmergencyContact(name: "", phoneNumber: "", relationship: "", isEnabled: true)
    
    var body: some View {
        NavigationView {
            Form {
                Section("新しい連絡先") {
                    TextField("名前", text: $newContact.name)
                    TextField("電話番号", text: $newContact.phoneNumber)
                    TextField("関係", text: $newContact.relationship)
                }
                
                Section("既存の連絡先") {
                    ForEach(contacts) { contact in
                        Text(contact.name)
                    }
                    .onDelete(perform: deleteContact)
                }
            }
            .navigationTitle("連絡先選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        if !newContact.name.isEmpty && !newContact.phoneNumber.isEmpty {
                            contacts.append(newContact)
                            newContact = EmergencyContact(name: "", phoneNumber: "", relationship: "", isEnabled: true)
                        }
                    }
                }
            }
        }
    }
    
    private func deleteContact(offsets: IndexSet) {
        contacts.remove(atOffsets: offsets)
    }
}

struct TriggerTestView: View {
    let triggerMethod: SOSTriggerMethod
    @Environment(\.dismiss) private var dismiss
    @State private var testResult = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                
                Text("トリガーテスト")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(triggerMethod.description)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                Text("上記の操作を行ってください")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if !testResult.isEmpty {
                    Text(testResult)
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("テスト")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置情報の取得に失敗: \(error)")
    }
}

#Preview {
    EmergencySOSScreen()
}
