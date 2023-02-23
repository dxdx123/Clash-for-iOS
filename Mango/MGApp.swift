import SwiftUI
import UserNotifications

extension MGKernel {
    static let storeKey = "MANGO_KERNEL"
}

final class MGAppDelegate: NSObject, ObservableObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    @Published var packetTunnelManager: MGPacketTunnelManager
    @Published var subscribeManager: MGSubscribeManager
    
    override init() {
        let kernel: MGKernel
        if let temp = UserDefaults.standard.string(forKey: MGKernel.storeKey).flatMap(MGKernel.init(rawValue:)) {
            kernel = temp
        } else {
            kernel = .clash
            UserDefaults.standard.set(kernel.rawValue, forKey: MGKernel.storeKey)
        }
        self.packetTunnelManager = MGPacketTunnelManager(kernel: kernel)
        self.subscribeManager = MGSubscribeManager(kernel: kernel)
        super.init()
        Task(priority: .high) {
            await packetTunnelManager.prepare()
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert], completionHandler: { _, _ in })
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func prepare(packetTunnelManager: MGPacketTunnelManager) {
        Task(priority: .high) {
            await packetTunnelManager.prepare()
            await MainActor.run {
                self.packetTunnelManager = packetTunnelManager
            }
        }
    }
    
    func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner])
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
                    delegate.subscribeManager = MGSubscribeManager(kernel: newValue)
                }
        }
    }
}

