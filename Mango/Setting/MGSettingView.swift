import SwiftUI

struct MGSettingView: View {
    
    @EnvironmentObject private var delegate: MGAppDelegate
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    switch delegate.packetTunnelManager.kernel {
                    case .clash:
                        MGTunnelModeView()
                        MGLogLevelView()
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
            .environmentObject(delegate.packetTunnelManager)
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
