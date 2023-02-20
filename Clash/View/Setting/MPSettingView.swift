import SwiftUI

struct MPSettingView: View {
    
    @AppStorage(MPConstant.Clash.tunnelMode, store: .shared) private var tunnelMode = MPCTunnelMode.rule
    
    @StateObject private var packetTunnelManager: MPPacketTunnelManager
    
    init(packetTunnelManager: MPPacketTunnelManager) {
        self._packetTunnelManager = StateObject(wrappedValue: packetTunnelManager)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    switch packetTunnelManager.kernel {
                    case .clash:
                        MPCTunnelModeView(tunnelMode: $tunnelMode, packetTunnelManager: packetTunnelManager)
                        MPCLogLevelView(packetTunnelManager: packetTunnelManager)
                        MPCGeoIPView()
                            .environmentObject(MPCGEOIPManager())
                        MPCIPV6View(packetTunnelManager: packetTunnelManager)
                    case .xray:
                        EmptyView()
                    }
                } header: {
                    Text("内核")
                }
                Section {
                    MPAppearanceView()
                    MPAccentColorView()
                } header: {
                    Text("主题")
                }
                Section {
                    MPResetButton(packetTunnelManager: packetTunnelManager)
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
    }
    
    private var version: String {
        guard let info = Bundle.main.infoDictionary,
              let version = info["CFBundleShortVersionString"] as? String else {
            return "--"
        }
        return "版本: \(version)"
    }
}
