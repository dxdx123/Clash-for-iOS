import SwiftUI

struct MGSettingView: View {
    
    @EnvironmentObject private var tunnel: MGPacketTunnelManager
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    MGLogLevelView()
                } header: {
                    Text("日志")
                }
                Section {
                    switch tunnel.kernel {
                    case .clash:
                        MGTunnelModeView()
                        MGGEOIPView()
                        MGIPV6View()
                    case .xray:
                        EmptyView()
                    }
                } header: {
                    Text("内核")
                }
                Section {
                    MGAppearanceView()
                } header: {
                    Text("主题")
                }
                Section {
                    MGResetView()
                }
            }
            .environmentObject(tunnel)
            .navigationTitle(Text("设置"))
            .safeAreaInset(edge: .bottom) {
                Text(Bundle.appVersion)
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .fontWeight(.light)
                    .monospacedDigit()
            }
        }
    }
}
