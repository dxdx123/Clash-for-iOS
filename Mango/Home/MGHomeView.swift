import SwiftUI

struct MGHomeView: View {
    
    @EnvironmentObject private var delegate: MGAppDelegate
    
    let kernel: Binding<MGKernel>
    
    private let current: Binding<String>
    
    init(kernel: Binding<MGKernel>) {
        self.kernel = kernel
        let storeKey = "\(kernel.wrappedValue.rawValue.uppercased())_CURRENT"
        self.current = Binding(get: {
            UserDefaults.shared.string(forKey: storeKey) ?? ""
        }, set: { newValue in
            UserDefaults.shared.set(newValue, forKey: storeKey)
        })
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    MGSubscribeView(current: current, subscribeManager: delegate.subscribeManager)
                }
                Section {
                    MGControlView(packetTunnelManager: delegate.packetTunnelManager)
                    MGConnectedDurationView(packetTunnelManager: delegate.packetTunnelManager)
                }
                switch delegate.packetTunnelManager.kernel {
                case .clash:
                    Section {
                        
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
