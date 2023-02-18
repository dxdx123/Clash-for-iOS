import SwiftUI

struct CFIPolicyGroupView: View {
    
    let tunnelMode: CFITunnelMode
    @StateObject private var packetTunnelManager: MPPacketTunnelManager
    @State private var isPresented = false
    
    init(tunnelMode: CFITunnelMode, packetTunnelManager: MPPacketTunnelManager) {
        self.tunnelMode = tunnelMode
        self._packetTunnelManager = StateObject(wrappedValue: packetTunnelManager)
    }
    
    var body: some View {
        Button {
            guard let status = packetTunnelManager.status, status == .connected else {
                CFINotification.send(title: "", subtitle: "", body: "未启动, 请启动之后查看策略组信息")
                return
            }
            isPresented.toggle()
        } label: {
            HStack {
                Text("查看")
                    .foregroundColor(.secondary)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary.opacity(0.5))
            }
        }
        .sheet(isPresented: $isPresented) {
            CFIProviderListView(tunnelMode: tunnelMode, packetTunnelManager: packetTunnelManager)
        }
    }
}
