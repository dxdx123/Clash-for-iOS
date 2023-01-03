import SwiftUI

struct CFIProviderListView: View {
    
    @EnvironmentObject private var manager: CFIPacketTunnelManager
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var providersManager = CFIProvidersManager()
        
    let tunnelMode: CFITunnelMode
        
    var body: some View {
        NavigationStack {
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
    }
    
    private struct ProviderCell: View {
        
        @EnvironmentObject private var manager: CFIPacketTunnelManager
        
        @StateObject private var provider: CFIProviderViewModel
        
        init(provider: CFIProviderViewModel) {
            self._provider = StateObject(wrappedValue: provider)
        }
                
        var body: some View {
            NavigationLink {
                CFIProxyListView(provider: provider)
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
