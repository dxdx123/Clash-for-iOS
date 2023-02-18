import Foundation

extension MPConstant {
    static let kernel = "KERNEL"
}

public enum MPKernel: String, Identifiable, CaseIterable {
    
    public var id: Self { self }
    
    case clash, xray
    
//    public var providerBundleIdentifier: String {
//        let suffix = Bundle.main.infoDictionary?["TUNNEL_BUNDLE_SUFFIX_\(rawValue.uppercased())"] as! String
//        return "\(Bundle.appID).\(suffix)"
//    }
//
//    public func createTunnelProviderManager() -> NETunnelProviderManager {
//        let manager = NETunnelProviderManager()
//        manager.localizedDescription = "iOS-\(rawValue.uppercased())"
//        manager.protocolConfiguration = {
//            let configuration = NETunnelProviderProtocol()
//            configuration.providerBundleIdentifier = self.providerBundleIdentifier
//            configuration.serverAddress = "iOS-\(rawValue.uppercased())"
//            configuration.providerConfiguration = [:]
//            configuration.excludeLocalNetworks = true
//            return configuration
//        }()
//        return manager
//    }
}
