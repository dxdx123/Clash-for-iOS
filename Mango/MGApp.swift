import SwiftUI

extension MGKernel {
    static let storeKey = "MANGO_KERNEL"
}

@main
struct MGApp: App {
    
    @UIApplicationDelegateAdaptor var delegate: MGAppDelegate
        
    @AppStorage(MGKernel.storeKey) private var kernel = MGKernel.clash
    
    var body: some Scene {
        WindowGroup {
            MGContentView(kernel: $kernel)
                .environmentObject(delegate)
                .environmentObject(MGGEOIPManager())
                .onChange(of: kernel) { newValue in
                    let packetTunnelManager = MGPacketTunnelManager(kernel: newValue)
                    Task(priority: .high) {
                        await packetTunnelManager.prepare()
                        await MainActor.run {
                            delegate.packetTunnelManager = packetTunnelManager
                        }
                    }
                    delegate.subscribeManager = MGSubscribeManager(kernel: newValue)
                }
        }
    }
}

