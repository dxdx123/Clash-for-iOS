import SwiftUI

@main
struct MGApp: App {
    
    @AppStorage("MANGO_KERNEL", store: .shared) private var kernel = MGKernel.clash
    
    var body: some Scene {
        WindowGroup {
            MGContentView(kernel: $kernel)
        }
    }
}

struct MGContentView: View {
    
    let kernel: Binding<MGKernel>
        
    var body: some View {
        NavigationStack {
            MGHomeView(kernel: kernel.wrappedValue)
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
                            EmptyView()
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                        }
                    }
                }
        }
    }
}

struct MGHomeView: View {
        
    @ObservedObject private var packetTunnelManager: MGPacketTunnelManager
    
    init(kernel: MGKernel) {
        self._packetTunnelManager = ObservedObject(wrappedValue: MGPacketTunnelManager(kernel: kernel))
    }
    
    var body: some View {
        Form {
            
        }
    }
}
