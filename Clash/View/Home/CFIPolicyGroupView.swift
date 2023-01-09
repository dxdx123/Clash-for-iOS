import SwiftUI
import SPIndicator

struct CFIPolicyGroupView: View {
    
    @EnvironmentObject private var manager: CFIPacketTunnelManager
    
    @State private var isPresented = false
    
    let tunnelMode: CFITunnelMode
    
    var body: some View {
        Button {
            guard let status = manager.status, status == .connected else {
                SPIndicatorView(title: "Clash未启动", preset: .error)
                    .present(duration: 1.0)
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
