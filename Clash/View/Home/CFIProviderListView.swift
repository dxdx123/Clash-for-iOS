import SwiftUI

struct CFIProviderListView: View {
    
    @EnvironmentObject private var manager: CFIPacketTunnelManager
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var providersManager = CFIProvidersManager()
        
    let tunnelMode: CFITunnelMode
        
    var body: some View {
        List {
            if tunnelMode == .global {
                Section {
                    ForEach(providersManager.gProviderVMs) { provider in
                        ProviderCell(provider: provider)
                    }
                }
            }
            Section {
                ForEach(providersManager.rProviderVMs) { provider in
                    ProviderCell(provider: provider)
                }
            }
        }
        .navigationTitle(Text("策略组"))
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: manager.status) { status in
            guard status != .connected else {
                return
            }
            dismiss()
        }
        .onAppear {
            manager.update(providersManager: providersManager)
        }
        .onReceive(Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()) { _ in
            manager.update(providersManager: providersManager)
        }
    }
    
    private struct ProviderCell: View {
        
        @EnvironmentObject private var manager: CFIPacketTunnelManager
        
        @StateObject private var provider: CFIProviderViewModel
        
        init(provider: CFIProviderViewModel) {
            self._provider = StateObject(wrappedValue: provider)
        }
                
        var body: some View {
            DisclosureGroup(isExpanded: $provider.isExpanded) {
                ForEach(provider.proxies) { proxy in
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
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(provider.name)
                        Text(provider.now)
                            .foregroundColor(.secondary)
                            .fontWeight(.light)
                    }
                    Spacer()
                    Text(provider.proxyMapping[provider.now]?.delay ?? "")
                        .foregroundColor(.secondary)
                        .fontWeight(.light)
                        .font(.callout)
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
                            .foregroundColor(isSelected ? .accentColor : .primary)
                        Text(proxy.type.name)
                            .foregroundColor(.secondary)
                            .font(.callout)
                            .fontWeight(.light)
                    }
                    Spacer()
                    Text(proxy.delay)
                        .foregroundColor(.secondary)
                        .font(.callout)
                        .fontWeight(.light)
                }
            }
        }
    }
}
