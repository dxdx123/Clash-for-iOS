import SwiftUI

struct CFISettingView: View {
    
    var body: some View {
        Form {
            Section {
                CFIGEOIPView()
            }
            Section {
                CFILogLevelView()
            }
            Section {
                CFIThemeView()
                CFIAccentColorView()
            } header: {
                Text("外观")
            }
            Section {
                CFIResetButton()
            }
        }
        .formStyle(.grouped)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(Text("设置"))
        .safeAreaInset(edge: .bottom) {
            Text(version)
                .foregroundColor(.secondary)
                .font(.caption)
                .fontWeight(.light)
                .monospacedDigit()
        }
    }
    
    private var version: String {
        guard let info = Bundle.main.infoDictionary,
              let version = info["CFBundleShortVersionString"] as? String else {
            return "--"
        }
        return "版本: \(version)"
    }
}
