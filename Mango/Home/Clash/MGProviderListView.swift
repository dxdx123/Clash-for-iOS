import SwiftUI

struct MGProviderListView: View {
    
    @AppStorage(MGConstant.Clash.tunnelMode, store: .shared) private var tunnelMode = MPCTunnelMode.rule
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var providersManager = MPCProvidersManager()
    
    @ObservedObject private var packetTunnelManager: MGPacketTunnelManager
    
    init(packetTunnelManager: MGPacketTunnelManager) {
        self._packetTunnelManager = ObservedObject(wrappedValue: packetTunnelManager)
    }
        
    var body: some View {
        NavigationStack {
            List {
                if tunnelMode == .global {
                    Section {
                        ForEach(providersManager.gProviderVMs) { provider in
                            ProviderCell(packetTunnelManager: packetTunnelManager, provider: provider)
                        }
                    }
                }
                Section {
                    ForEach(providersManager.rProviderVMs) { provider in
                        ProviderCell(packetTunnelManager: packetTunnelManager, provider: provider)
                    }
                }
            }
            .navigationTitle(Text("策略组"))
            .onChange(of: packetTunnelManager.status) { status in
                guard status != .connected else {
                    return
                }
                dismiss()
            }
            .onAppear {
                MGKernel.Clash.update(manager: packetTunnelManager, providersManager: providersManager)
            }
            .onReceive(Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()) { _ in
                MGKernel.Clash.update(manager: packetTunnelManager, providersManager: providersManager)
            }
        }
    }
    
    private struct ProviderCell: View {
        
        let packetTunnelManager: MGPacketTunnelManager
        
        @ObservedObject private var provider: MPCProviderViewModel
        
        init(packetTunnelManager: MGPacketTunnelManager, provider: MPCProviderViewModel) {
            self.packetTunnelManager = packetTunnelManager
            self._provider = ObservedObject(wrappedValue: provider)
        }
                
        var body: some View {
            NavigationLink {
                MGProxyListView(packetTunnelManager: packetTunnelManager, provider: provider)
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(provider.name)
                            .lineLimit(1)
                        Text(provider.now)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                            .fontWeight(.light)
                    }
                    Spacer()
                    Text(provider.proxyMapping[provider.now]?.delay ?? "")
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                        .fontWeight(.light)
                        .font(.callout)
                }
            }
        }
    }
}
