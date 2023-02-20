import SwiftUI

struct MPCProviderListView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var providersManager = MPCProvidersManager()
    
    let tunnelMode: MPCTunnelMode
    @StateObject private var packetTunnelManager: MPPacketTunnelManager
    
    init(tunnelMode: MPCTunnelMode, packetTunnelManager: MPPacketTunnelManager) {
        self.tunnelMode = tunnelMode
        self._packetTunnelManager = StateObject(wrappedValue: packetTunnelManager)
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
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: packetTunnelManager.status) { status in
                guard status != .connected else {
                    return
                }
                dismiss()
            }
            .onAppear {
                packetTunnelManager.update(providersManager: providersManager)
            }
            .onReceive(Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()) { _ in
                packetTunnelManager.update(providersManager: providersManager)
            }
        }
    }
    
    private struct ProviderCell: View {
        
        @StateObject private var packetTunnelManager: MPPacketTunnelManager
        @StateObject private var provider: MPCProviderViewModel
        
        init(packetTunnelManager: MPPacketTunnelManager, provider: MPCProviderViewModel) {
            self._packetTunnelManager = StateObject(wrappedValue: packetTunnelManager)
            self._provider = StateObject(wrappedValue: provider)
        }
                
        var body: some View {
            NavigationLink {
                MPCProxyListView(packetTunnelManager: packetTunnelManager, provider: provider)
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
