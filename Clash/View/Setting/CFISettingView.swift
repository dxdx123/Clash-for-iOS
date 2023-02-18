import SwiftUI

struct CFISettingView: View {
    
    let core: Binding<Core>
    @StateObject private var packetTunnelManager: PacketTunnelManager
    
    init(core: Binding<Core>, packetTunnelManager: PacketTunnelManager) {
        self.core = core
        self._packetTunnelManager = StateObject(wrappedValue: packetTunnelManager)
    }
    
    var body: some View {
        Form {
            Section {
                switch core.wrappedValue {
                case .clash:
                    CFILogLevelView(packetTunnelManager: packetTunnelManager)
                    CFIGeoIPView()
                        .environmentObject(CFIGEOIPManager())
                    CFIIPV6View(packetTunnelManager: packetTunnelManager)
                case .xray:
                    EmptyView()
                }
            } header: {
                Text("内核")
            }
            Section {
                CFIAppearanceView()
                CFIAccentColorView()
            } header: {
                Text("主题")
            }
            Section {
                CFIResetButton(packetTunnelManager: packetTunnelManager)
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
