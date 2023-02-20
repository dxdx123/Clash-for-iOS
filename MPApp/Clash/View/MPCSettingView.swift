import SwiftUI

struct MPCSettingView: View {
    
    @AppStorage(MPConstant.Clash.tunnelMode, store: .shared) private var tunnelMode = MPCTunnelMode.rule
    
    let packetTunnelManager: MPPacketTunnelManager
    let geoipManager: MPCGEOIPManager
    
    var body: some View {
        Form {
            Section {
                MPCTunnelModeView(tunnelMode: $tunnelMode, packetTunnelManager: packetTunnelManager)
                MPCLogLevelView(packetTunnelManager: packetTunnelManager)
                MPCGeoIPView(geoipManager: geoipManager)
                MPCIPV6View(packetTunnelManager: packetTunnelManager)
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
    }
}
