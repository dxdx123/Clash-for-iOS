import SwiftUI

struct CFIPolicyGroupView: View {
    
    @EnvironmentObject private var manager: CFIPacketTunnelManager
    
    @State private var isPresented = false
    
    let tunnelMode: CFITunnelMode
    
    var body: some View {
        Button {
            guard let status = manager.status, status == .connected else {
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
            CFIProviderListView(tunnelMode: tunnelMode)
        }
    }
}
