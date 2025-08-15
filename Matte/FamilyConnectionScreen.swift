//
//  FamilyConnectionScreen.swift
//  Matte
//
//  Created by Igasaki Gouta on 2025/08/04.
//

import SwiftUI
import CoreLocation

struct FamilyConnectionScreen: View {
    @State private var familyMembers: [FamilyMember] = []
    @State private var showingAddMember = false
    @State private var selectedMember: FamilyMember?
    @State private var showingMemberDetail = false
    @State private var isLocationSharingEnabled = true
    @State private var showingInviteSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // 家族状況サマリー
                    FamilySummaryCard(members: familyMembers)
                    
                    // 位置情報共有設定
                    LocationSharingCard(isEnabled: $isLocationSharingEnabled)
                    
                    // 家族メンバー一覧
                    FamilyMembersCard(
                        members: familyMembers,
                        onMemberTap: { member in
                            selectedMember = member
                            showingMemberDetail = true
                        }
                    )
                    
                    // 緊急連絡機能
                    EmergencyContactCard(members: familyMembers)
                    
                    // 活動状況
                    ActivityStatusCard(members: familyMembers)
                    
                    // 家族設定
                    FamilySettingsCard()
                }
                .padding()
            }
            .navigationTitle("家族連携")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        showingAddMember = true
                    }
                }
            }
            .sheet(isPresented: $showingAddMember) {
                AddFamilyMemberView(members: $familyMembers)
            }
            .sheet(isPresented: $showingMemberDetail) {
                if let member = selectedMember {
                    FamilyMemberDetailView(member: member)
                }
            }
            .sheet(isPresented: $showingInviteSheet) {
                InviteFamilyView()
            }
        }
    }
}

struct FamilySummaryCard: View {
    let members: [FamilyMember]
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "person.3.fill")
                    .foregroundColor(.blue)
                Text("家族状況")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            HStack(spacing: 20) {
                SummaryItem(
                    title: "家族メンバー",
                    value: "\(members.count)人",
                    icon: "person.2.fill",
                    color: .blue
                )
                
                SummaryItem(
                    title: "オンライン",
                    value: "\(members.filter { $0.lastActive?.timeIntervalSinceNow ?? -3600 > -300 }.count)人",
                    icon: "wifi",
                    color: .green
                )
                
                SummaryItem(
                    title: "保護者",
                    value: "\(members.filter(\.isGuardian).count)人",
                    icon: "shield.fill",
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

struct SummaryItem: View {
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
    }
}

struct LocationSharingCard: View {
    @Binding var isEnabled: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.green)
                Text("位置情報共有")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            Toggle("家族と位置情報を共有", isOn: $isEnabled)
                .font(.subheadline)
            
            if isEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    Text("共有設定")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    LocationSharingOptionRow(
                        title: "リアルタイム位置",
                        description: "現在地を常時共有",
                        isEnabled: true
                    )
                    
                    LocationSharingOptionRow(
                        title: "緊急時のみ",
                        description: "SOS発動時に位置を共有",
                        isEnabled: true
                    )
                    
                    LocationSharingOptionRow(
                        title: "履歴保存",
                        description: "過去の位置履歴を保存",
                        isEnabled: false
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

struct LocationSharingOptionRow: View {
    let title: String
    let description: String
    let isEnabled: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isEnabled ? .green : .gray)
        }
        .padding(.vertical, 5)
    }
}

struct FamilyMembersCard: View {
    let members: [FamilyMember]
    let onMemberTap: (FamilyMember) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.purple)
                Text("家族メンバー")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            if members.isEmpty {
                VStack(spacing: 15) {
                    Image(systemName: "person.2.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("家族メンバーが登録されていません")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("家族の安全を守るために、家族メンバーを追加しましょう")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 30)
            } else {
                ForEach(members) { member in
                    FamilyMemberRow(member: member) {
                        onMemberTap(member)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct FamilyMemberRow: View {
    let member: FamilyMember
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // アバター
                ZStack {
                    Circle()
                        .fill(member.isGuardian ? Color.orange : Color.blue)
                        .frame(width: 50, height: 50)
                    
                    Text(String(member.name.prefix(1)))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(member.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        if member.isGuardian {
                            Image(systemName: "shield.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        
                        Spacer()
                        
                        // オンライン状態
                        Circle()
                            .fill(isOnline ? Color.green : Color.gray)
                            .frame(width: 8, height: 8)
                    }
                    
                    Text(member.relationship)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let lastActive = member.lastActive {
                        Text("最終アクセス: \(lastActive, style: .relative)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var isOnline: Bool {
        guard let lastActive = member.lastActive else { return false }
        return lastActive.timeIntervalSinceNow > -300 // 5分以内
    }
}

struct EmergencyContactCard: View {
    let members: [FamilyMember]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "phone.circle.fill")
                    .foregroundColor(.red)
                Text("緊急連絡")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            if members.isEmpty {
                Text("家族メンバーを追加すると、緊急時に素早く連絡できます")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    Button(action: { contactAllMembers() }) {
                        HStack {
                            Image(systemName: "person.3.fill")
                                .foregroundColor(.red)
                                .frame(width: 25)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("全員に連絡")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text("登録された全家族に一斉連絡")
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
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: { contactGuardians() }) {
                        HStack {
                            Image(systemName: "shield.fill")
                                .foregroundColor(.red)
                                .frame(width: 25)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("保護者に連絡")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text("保護者設定の家族に連絡")
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
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: { shareLocation() }) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.red)
                                .frame(width: 25)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("位置情報共有")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text("現在地を家族に共有")
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
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
    
    private func contactAllMembers() {
        // 全員連絡機能
        print("全家族に連絡")
    }
    
    private func contactGuardians() {
        // 保護者連絡機能
        print("保護者に連絡")
    }
    
    private func shareLocation() {
        // 位置情報共有機能
        print("位置情報を共有")
    }
}



struct ActivityStatusCard: View {
    let members: [FamilyMember]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.indigo)
                Text("活動状況")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            if members.isEmpty {
                Text("家族メンバーの活動状況がここに表示されます")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 10) {
                    ForEach(members.prefix(3)) { member in
                        ActivityRow(member: member)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct ActivityRow: View {
    let member: FamilyMember
    
    var body: some View {
        HStack {
            Text(member.name)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(activityStatus)
                    .font(.caption)
                    .foregroundColor(activityColor)
                
                if let lastActive = member.lastActive {
                    Text(lastActive, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 5)
    }
    
    private var activityStatus: String {
        guard let lastActive = member.lastActive else { return "未確認" }
        let timeInterval = lastActive.timeIntervalSinceNow
        
        if timeInterval > -300 {
            return "オンライン"
        } else if timeInterval > -3600 {
            return "最近アクセス"
        } else if timeInterval > -86400 {
            return "今日アクセス"
        } else {
            return "オフライン"
        }
    }
    
    private var activityColor: Color {
        guard let lastActive = member.lastActive else { return .gray }
        let timeInterval = lastActive.timeIntervalSinceNow
        
        if timeInterval > -300 {
            return .green
        } else if timeInterval > -3600 {
            return .orange
        } else {
            return .red
        }
    }
}

struct FamilySettingsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.gray)
                Text("家族設定")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                SettingsRow(
                    title: "通知設定",
                    description: "家族からの通知を管理",
                    icon: "bell.fill",
                    action: { /* 通知設定 */ }
                )
                
                SettingsRow(
                    title: "プライバシー設定",
                    description: "共有情報の詳細設定",
                    icon: "lock.fill",
                    action: { /* プライバシー設定 */ }
                )
                
                SettingsRow(
                    title: "家族招待",
                    description: "新しい家族メンバーを招待",
                    icon: "person.badge.plus",
                    action: { /* 家族招待 */ }
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct SettingsRow: View {
    let title: String
    let description: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
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
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Supporting Views
struct AddFamilyMemberView: View {
    @Binding var members: [FamilyMember]
    @Environment(\.dismiss) private var dismiss
    @State private var newMember = FamilyMember(
        name: "",
        phoneNumber: "",
        relationship: "",
        isGuardian: false,
        canViewAlerts: true,
        canReceiveNotifications: true
    )
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本情報") {
                    TextField("名前", text: $newMember.name)
                    TextField("電話番号", text: $newMember.phoneNumber)
                    TextField("関係", text: $newMember.relationship)
                }
                
                Section("権限設定") {
                    Toggle("保護者として設定", isOn: $newMember.isGuardian)
                    Toggle("警告を表示", isOn: $newMember.canViewAlerts)
                    Toggle("通知を受信", isOn: $newMember.canReceiveNotifications)
                }
                
                Section("説明") {
                    Text("保護者として設定すると、緊急時に優先的に連絡されます。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("家族メンバー追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        if !newMember.name.isEmpty && !newMember.phoneNumber.isEmpty {
                            members.append(newMember)
                            dismiss()
                        }
                    }
                    .disabled(newMember.name.isEmpty || newMember.phoneNumber.isEmpty)
                }
            }
        }
    }
}

struct FamilyMemberDetailView: View {
    let member: FamilyMember
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // プロフィール
                    ProfileSection(member: member)
                    
                    // 連絡情報
                    ContactSection(member: member)
                    
                    // 権限設定
                    PermissionsSection(member: member)
                    
                    // アクション
                    ActionsSection(member: member)
                }
                .padding()
            }
            .navigationTitle(member.name)
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

struct ProfileSection: View {
    let member: FamilyMember
    
    var body: some View {
        VStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(member.isGuardian ? Color.orange : Color.blue)
                    .frame(width: 80, height: 80)
                
                Text(String(member.name.prefix(1)))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 5) {
                Text(member.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(member.relationship)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if member.isGuardian {
                    HStack {
                        Image(systemName: "shield.fill")
                            .foregroundColor(.orange)
                        Text("保護者")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct ContactSection: View {
    let member: FamilyMember
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "phone.fill")
                    .foregroundColor(.green)
                Text("連絡情報")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 10) {
                ContactRow(
                    title: "電話番号",
                    value: member.phoneNumber,
                    icon: "phone.fill",
                    action: { /* 電話をかける */ }
                )
                
                if let lastActive = member.lastActive {
                    ContactRow(
                        title: "最終アクセス",
                        value: lastActive, style: .abbreviated,
                        icon: "clock.fill",
                        action: nil
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

struct ContactRow: View {
    let title: String
    let value: String
    let icon: String
    let action: (() -> Void)?
    
    init(title: String, value: String, icon: String, action: (() -> Void)?) {
        self.title = title
        self.value = value
        self.icon = icon
        self.action = action
    }
    
    init(title: String, value: Date, style: RelativeDateTimeFormatter.UnitsStyle, icon: String, action: (() -> Void)?) {
        self.title = title
        self.value = value.formatted(.relative(presentation: .named))
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 25)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(value)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let action = action {
                Button(action: action) {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 5)
    }
}

struct PermissionsSection: View {
    let member: FamilyMember
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(.orange)
                Text("権限設定")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 10) {
                PermissionRow(
                    title: "警告を表示",
                    description: "セキュリティ警告を確認できます",
                    isEnabled: member.canViewAlerts
                )
                
                PermissionRow(
                    title: "通知を受信",
                    description: "緊急通知を受け取ります",
                    isEnabled: member.canReceiveNotifications
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct PermissionRow: View {
    let title: String
    let description: String
    let isEnabled: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: isEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isEnabled ? .green : .red)
        }
        .padding(.vertical, 5)
    }
}

struct ActionsSection: View {
    let member: FamilyMember
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.purple)
                Text("アクション")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 10) {
                ActionRow(
                    title: "電話をかける",
                    icon: "phone.fill",
                    color: .green,
                    action: { /* 電話をかける */ }
                )
                
                ActionRow(
                    title: "メッセージを送る",
                    icon: "message.fill",
                    color: .blue,
                    action: { /* メッセージを送る */ }
                )
                
                ActionRow(
                    title: "位置情報を共有",
                    icon: "location.fill",
                    color: .orange,
                    action: { /* 位置情報を共有 */ }
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct ActionRow: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 25)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct InviteFamilyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                VStack(spacing: 15) {
                    Text("家族を招待")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("家族の安全を守るために、Matteアプリを家族と共有しましょう")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 15) {
                    InviteOptionRow(
                        title: "QRコードで招待",
                        description: "QRコードをスキャンして追加",
                        icon: "qrcode",
                        action: { /* QRコード生成 */ }
                    )
                    
                    InviteOptionRow(
                        title: "リンクで招待",
                        description: "招待リンクを送信",
                        icon: "link",
                        action: { /* リンク生成 */ }
                    )
                    
                    InviteOptionRow(
                        title: "手動で追加",
                        description: "電話番号で直接追加",
                        icon: "person.fill",
                        action: { /* 手動追加 */ }
                    )
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("家族招待")
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

struct InviteOptionRow: View {
    let title: String
    let description: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
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
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    FamilyConnectionScreen()
}
