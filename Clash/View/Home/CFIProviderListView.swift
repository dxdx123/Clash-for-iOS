import SwiftUI

struct CFIProviderListView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var providersManager = CFIProvidersManager()
    
    let tunnelMode: CFITunnelMode
    @StateObject private var packetTunnelManager: PacketTunnelManager
    
    init(tunnelMode: CFITunnelMode, packetTunnelManager: PacketTunnelManager) {
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
        
        @StateObject private var packetTunnelManager: PacketTunnelManager
        @StateObject private var provider: CFIProviderViewModel
        
        init(packetTunnelManager: PacketTunnelManager, provider: CFIProviderViewModel) {
            self._packetTunnelManager = StateObject(wrappedValue: packetTunnelManager)
            self._provider = StateObject(wrappedValue: provider)
        }
                
        var body: some View {
            NavigationLink {
                CFIProxyListView(packetTunnelManager: packetTunnelManager, provider: provider)
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
