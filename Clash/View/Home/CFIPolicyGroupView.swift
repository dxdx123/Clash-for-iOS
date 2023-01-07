import SwiftUI

struct CFIPolicyGroupView: View {
    
    @EnvironmentObject private var manager: CFIPacketTunnelManager
    
    @State private var isPresented = false
    
    let tunnelMode: CFITunnelMode
    
    var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            HStack {
                Text((manager.status.flatMap({ $0 == .connected }) ?? false) ? "查看" : "暂不可用")
                    .foregroundColor(.secondary)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary.opacity(0.5))
            }
        }
        .disabled(manager.status.flatMap({ $0 != .connected }) ?? true)
        .sheet(isPresented: $isPresented) {
            CFIProviderListView(tunnelMode: tunnelMode)
        }
    }
}
