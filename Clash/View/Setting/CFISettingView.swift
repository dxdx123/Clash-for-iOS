import SwiftUI

struct CFISettingView: View {
    
    let tunnelMode: Binding<CFITunnelMode>

    var body: some View {
        Form {
            Section {
                CFITunnelModeView(tunnelMode: tunnelMode)
            } header: {
                Text("模式")
            }
            Section {
                CFIGEOIPView()
            }
            Section {
                CFILogLevelView()
            }
            Section {
                CFIThemeView()
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
