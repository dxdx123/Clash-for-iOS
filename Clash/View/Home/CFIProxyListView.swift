import SwiftUI

struct CFIProxyListView: View {
    
    @EnvironmentObject private var manager: PacketTunnelManager
    
    @StateObject private var provider: CFIProviderViewModel
    
    init(provider: CFIProviderViewModel) {
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
                    manager.set(provider: provider.name, selected: proxy.name)
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
                        manager.healthCheck(name: provider.name, isProcessing: $provider.isHealthChecking)
                    } label: {
                        Image(systemName: "speedometer")
                    }
                }
            }
        }
    }
    
    private struct ProxyCell: View {
        
        @StateObject private var proxy: CFIProxyViewModel
        
        private let isSelected: Bool
        
        init(proxy: CFIProxyViewModel, isSelected: Bool) {
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
