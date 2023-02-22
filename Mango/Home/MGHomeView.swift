import SwiftUI

struct MGHomeView: View {
    
    let kernel: Binding<MGKernel>
    
    @ObservedObject private var packetTunnelManager: MGPacketTunnelManager
    
    init(kernel: Binding<MGKernel>, packetTunnelManager: MGPacketTunnelManager) {
        self.kernel = kernel
        self._packetTunnelManager = ObservedObject(wrappedValue: packetTunnelManager)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    
                } header: {
                    switch packetTunnelManager.kernel {
                    case .clash:
                        Text("订阅")
                    case .xray:
                        Text("配置")
                    }
                }
                Section {
                    MGControlView(packetTunnelManager: packetTunnelManager)
                    MGConnectedDurationView(packetTunnelManager: packetTunnelManager)
                } header: {
                    Text("状态")
                }
                switch packetTunnelManager.kernel {
                case .clash:
                    Section {
                        
                    } header: {
                        Text("代理")
                    }
                case .xray:
                    EmptyView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker(selection: kernel) {
                        ForEach(MGKernel.allCases) { kernel in
                            Text(kernel.rawValue.uppercased())
                        }
                    } label: {
                        EmptyView()
                    }
                    .pickerStyle(.segmented)
                    .fixedSize()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    MGPresentedButton {
                        MGSettingView()
                            .environmentObject(packetTunnelManager)
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
        }
    }
}
