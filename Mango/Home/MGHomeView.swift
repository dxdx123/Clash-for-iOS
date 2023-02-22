import SwiftUI

struct MGHomeView: View {
        
    @ObservedObject private var packetTunnelManager: MGPacketTunnelManager
    
    init(kernel: MGKernel) {
        self._packetTunnelManager = ObservedObject(wrappedValue: MGPacketTunnelManager(kernel: kernel))
    }
    
    var body: some View {
        Form {
            switch packetTunnelManager.kernel {
            case .clash:
                Text("Clash")
            case .xray:
                Text("Xray")
            }
            Section {
                
            } header: {
                Text("订阅")
            }
            Section {
                
            } header: {
                Text("状态")
            }
            Section {
                
            } header: {
                Text("代理")
            }
        }
    }
}
