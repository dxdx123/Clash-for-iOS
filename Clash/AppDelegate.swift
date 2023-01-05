import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    let packetTunnelManager = CFIPacketTunnelManager()
    
    let subscribeManager    = CFISubscribeManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        setupDefaults()
        
        copyDatabase()
        
        return true
    }
    
    private func copyDatabase() {
        let dbFileName = "Country"
        let dbFileExtension = "mmdb"
        let dbURL = CFIConstant.homeDirectory.appendingPathComponent("\(dbFileName).\(dbFileExtension)")
        guard !FileManager.default.fileExists(atPath: dbURL.path) else {
            return
        }
        guard let local = Bundle.main.url(forResource: dbFileName, withExtension: dbFileExtension) else {
            return
        }
        do {
            try FileManager.default.copyItem(at: local, to: dbURL)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    private func setupDefaults() {
        if let reval = UserDefaults.shared.string(forKey: CFIConstant.tunnelMode), reval.isEmpty {
            UserDefaults.shared.set(CFITunnelMode.rule.rawValue, forKey: CFIConstant.tunnelMode)
        }
        if let reval = UserDefaults.shared.string(forKey: CFIConstant.logLevel), reval.isEmpty {
            UserDefaults.shared.set(CFILogLevel.silent.rawValue, forKey: CFIConstant.logLevel)
        }
    }
}
