import SwiftUI

struct MGProxyListView: View {
    
    let packetTunnelManager: MGPacketTunnelManager
    
    @ObservedObject private var provider: MGProviderViewModel
    
    init(packetTunnelManager: MGPacketTunnelManager, provider: MGProviderViewModel) {
        self.packetTunnelManager = packetTunnelManager
        self._provider = ObservedObject(wrappedValue: provider)
    }
    
    var body: some View {
        List(provider.proxies) { proxy in
            ProxyCell(proxy: proxy, isSelected: provider.now == proxy.name)
                .contentShape(Rectangle())
                .onTapGesture {
                    guard provider.type == .selector else {
                        return
                    }
                    MGKernel.Clash.set(manager: packetTunnelManager, provider: provider.name, selected: proxy.name)
                    provider.now = proxy.name
                }
        }
        .navigationTitle(Text(provider.name))
        .toolbar {
            if provider.isHealthCheckEnable {
                if provider.isHealthChecking {
                    ProgressView()
                } else {
                    Button {
                        MGKernel.Clash.healthCheck(manager: packetTunnelManager, name: provider.name, isProcessing: $provider.isHealthChecking)
                    } label: {
                        Image(systemName: "speedometer")
                    }
                }
            }
        }
    }
    
    private struct ProxyCell: View {
        
        @ObservedObject private var proxy: MGProxyViewModel
        
        private let isSelected: Bool
        
        init(proxy: MGProxyViewModel, isSelected: Bool) {
            self._proxy = ObservedObject(wrappedValue: proxy)
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
