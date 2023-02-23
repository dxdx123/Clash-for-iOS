import SwiftUI

struct MGResetView: View {
    
    @EnvironmentObject private var packetTunnelManager: MGPacketTunnelManager

    @State private var isPresented: Bool = false
    
    var body: some View {
        HStack {
            Spacer()
            Button("重置VPN配置", role: .destructive) {
                isPresented.toggle()
            }
            .disabled(packetTunnelManager.status == nil)
            Spacer()
        }
        .alert("重置", isPresented: $isPresented) {
            Button("确定", role: .destructive) {
                Task(priority: .high) {
                    try await packetTunnelManager.removeFromPreferences()
                    try await packetTunnelManager.saveToPreferences()
                }
            }
            Button("取消", role: .cancel, action: {})
        } message: {
            Text("确定重置您的 VPN 配置么?")
        }
    }
}
