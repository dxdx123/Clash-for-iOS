import SwiftUI

struct MPXrayContentView: View {
        
    @StateObject private var packetTunnelManager    = MPPacketTunnelManager(kernel: .xray)
    @StateObject private var databaseManager        = CFIGEOIPManager()
    
    var body: some View {
        Form {
            Section {
                CFIControlView(packetTunnelManager: packetTunnelManager)
                LabeledContent {
                    if let status = packetTunnelManager.status, status == .connected {
                        CFIConnectedDurationView(packetTunnelManager: packetTunnelManager)
                    } else {
                        Text("--:--")
                    }
                } label: {
                    Label {
                        Text("连接时长")
                    } icon: {
                        CFIIcon(systemName: "clock", backgroundColor: .blue)
                    }
                }
            } header: {
                Text("状态")
            }
        }
        .formStyle(.grouped)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                MPSettingButton(packetTunnelManager: packetTunnelManager)
            }
        }
    }
}
