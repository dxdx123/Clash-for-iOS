import SwiftUI

struct MGHomeView: View {
    
    @EnvironmentObject private var delegate: MGAppDelegate
    
    let kernel: Binding<MGKernel>
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
//                    MGSubscribeView(current: .constant(""), packetTunnelManager: packetTunnelManager, subscribeManager: subscribeManager)
                } header: {
                    switch delegate.packetTunnelManager.kernel {
                    case .clash:
                        Text("订阅")
                    case .xray:
                        Text("配置")
                    }
                }
                Section {
                    MGControlView(packetTunnelManager: delegate.packetTunnelManager)
                    MGConnectedDurationView(packetTunnelManager: delegate.packetTunnelManager)
                } header: {
                    Text("状态")
                }
                switch delegate.packetTunnelManager.kernel {
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
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
        }
    }
}
