import SwiftUI

struct MGNetworkSettingView: View {
    
    @EnvironmentObject  private var packetTunnelManager: MGPacketTunnelManager
    @ObservedObject private var networkViewModel: MGNetworkViewModel
    
    init(networkViewModel: MGNetworkViewModel) {
        self._networkViewModel = ObservedObject(initialValue: networkViewModel)
    }
    
    var body: some View {
        Form {
            Section {
                Toggle("隐藏 VPN 图标", isOn: $networkViewModel.hideVPNIcon)
            } footer: {
                Text("排除路由 0:0:0:0/8 & ::/128")
            }
            Section {
                Toggle("启用 IPv6 路由", isOn: $networkViewModel.ipv6Enabled)
            } footer: {
                Text("在不支持IPv6的环境下启用IPv6可能存在兼容性问题, 谨慎开启")
            }
        }
        .navigationTitle(Text("网络设置"))
        .navigationBarTitleDisplayMode(.large)
        .onDisappear {
            self.networkViewModel.save {
                guard let status = packetTunnelManager.status, status == .connected else {
                    return
                }
                packetTunnelManager.stop()
                Task(priority: .userInitiated) {
                    do {
                        try await Task.sleep(for: .milliseconds(500))
                        try await packetTunnelManager.start()
                    } catch {
                        debugPrint(error.localizedDescription)
                    }
                }
            }
        }
    }
}
