import SwiftUI

final class MGAppDelegate: NSObject, ObservableObject, UIApplicationDelegate {
    
    @Published var packetTunnelManager = MGPacketTunnelManager(kernel: .clash)
}


@main
struct MGApp: App {
    
    @UIApplicationDelegateAdaptor var delegate: MGAppDelegate
        
    @AppStorage("MANGO_KERNEL", store: .shared) private var kernel = MGKernel.clash
    
    var body: some Scene {
        WindowGroup {
            MGContentView(kernel: $kernel)
                .environmentObject(delegate)
                .onChange(of: kernel) { newValue in
                    delegate.packetTunnelManager = MGPacketTunnelManager(kernel: newValue)
                }
        }
    }
}

