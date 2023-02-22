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
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
        }
    }
}
