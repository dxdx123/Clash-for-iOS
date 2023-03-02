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
                    case .xray:
                        MGSniffingEntranceView()
                        MGGEOAssetView()
                    }
                    MGIPV6View()
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

struct MGGEOAssetView: View {
    
    var body: some View {
        NavigationLink {
            MGGEOAssetSettingView()
        } label: {
            Label {
                Text("GEO 资源")
            } icon: {
                Image(systemName: "tray")
            }
        }
    }
}

struct MGGEOAssetSettingView: View {
    
    var body: some View {
        Form {
            
        }
        .navigationTitle(Text("GEO 资源"))
    }
}
