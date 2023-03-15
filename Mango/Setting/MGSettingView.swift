import SwiftUI

struct MGSettingView: View {
    
    @EnvironmentObject private var tunnel: MGPacketTunnelManager
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    MGLogLevelView()
                    MGIPV6View()
                } header: {
                    Text("通用")
                }
                Section {
                    switch tunnel.kernel {
                    case .clash:
                        MGTunnelModeView()
                        MGGEOIPView()
                    case .xray:
                        MGSniffingEntranceView()
                        MGAssetEntranceView()
                    }
                } header: {
                    Text("内核")
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
