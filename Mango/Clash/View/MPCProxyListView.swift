import SwiftUI

struct MPCProxyListView: View {
    
    @StateObject private var packetTunnelManager: MPPacketTunnelManager
    
    @StateObject private var provider: MPCProviderViewModel
    
    init(packetTunnelManager: MPPacketTunnelManager, provider: MPCProviderViewModel) {
        self._packetTunnelManager = StateObject(wrappedValue: packetTunnelManager)
        self._provider = StateObject(wrappedValue: provider)
    }
    
    var body: some View {
        List(provider.proxies) { proxy in
            ProxyCell(proxy: proxy, isSelected: provider.now == proxy.name)
                .contentShape(Rectangle())
                .onTapGesture {
                    guard provider.type == .selector else {
                        return
                    }
                    packetTunnelManager.set(provider: provider.name, selected: proxy.name)
                    provider.now = proxy.name
                }
        }
        .navigationTitle(Text(provider.name))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if provider.isHealthCheckEnable {
                if provider.isHealthChecking {
                    ProgressView()
                } else {
                    Button {
                        packetTunnelManager.healthCheck(name: provider.name, isProcessing: $provider.isHealthChecking)
                    } label: {
                        Image(systemName: "speedometer")
                    }
                }
            }
        }
    }
    
    private struct ProxyCell: View {
        
        @StateObject private var proxy: MPCProxyViewModel
        
        private let isSelected: Bool
        
        init(proxy: MPCProxyViewModel, isSelected: Bool) {
            self._proxy = StateObject(wrappedValue: proxy)
            self.isSelected = isSelected
        }
        
        var body: some View {
            HStack {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(proxy.name)
                            .lineLimit(1)
                            .foregroundColor(isSelected ? .accentColor : .primary)
                        Text(proxy.type.name)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                            .font(.callout)
                            .fontWeight(.light)
                    }
                    Spacer()
                    Text(proxy.delay)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                        .font(.callout)
                        .fontWeight(.light)
                }
            }
        }
    }
}
