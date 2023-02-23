import SwiftUI

extension MGKernel {
    static let storeKey = "MANGO_KERNEL"
}

final class MGAppDelegate: NSObject, ObservableObject, UIApplicationDelegate {
    
    @Published var packetTunnelManager: MGPacketTunnelManager
    
    override init() {
        let kernel: MGKernel
        if let temp = UserDefaults.standard.string(forKey: MGKernel.storeKey).flatMap(MGKernel.init(rawValue:)) {
            kernel = temp
        } else {
            kernel = .clash
            UserDefaults.standard.set(kernel.rawValue, forKey: MGKernel.storeKey)
        }
        self.packetTunnelManager = MGPacketTunnelManager(kernel: kernel)
        super.init()
        Task(priority: .high) {
            await packetTunnelManager.prepare()
        }
    }
    
    func prepare(packetTunnelManager: MGPacketTunnelManager) {
        Task(priority: .high) {
            await packetTunnelManager.prepare()
            await MainActor.run {
                self.packetTunnelManager = packetTunnelManager
            }
        }
    }
}


@main
struct MGApp: App {
    
    @UIApplicationDelegateAdaptor var delegate: MGAppDelegate
        
    @AppStorage(MGKernel.storeKey) private var kernel = MGKernel.clash
    
    var body: some Scene {
        WindowGroup {
            MGContentView(kernel: $kernel)
                .environmentObject(delegate)
                .onChange(of: kernel) { newValue in
                    let packetTunnelManager = MGPacketTunnelManager(kernel: newValue)
                    Task(priority: .high) {
                        await packetTunnelManager.prepare()
                        await MainActor.run {
                            delegate.packetTunnelManager = packetTunnelManager
                        }
                    }
                }
        }
    }
}

