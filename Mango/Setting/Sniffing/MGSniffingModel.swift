import Foundation

extension MGConstant {
    public static let sniffing: String = "XRAY_SNIFFIN_DATA"
}

public struct MGSniffingModel: Codable, Equatable {
    
    public let enabled: Bool
    public let httpEnabled: Bool
    public let tlsEnabled: Bool
    public let quicEnabled: Bool
    public let fakednsEnabled: Bool
    public let metadataOnly: Bool
    public let routeOnly: Bool
    public let excludedDomains: [String]
    
    public static let `default` = MGSniffingModel(
        enabled: true,
        httpEnabled: true,
        tlsEnabled: true,
        quicEnabled: false,
        fakednsEnabled: false,
        metadataOnly: false,
        routeOnly: false,
        excludedDomains: []
    )
    
    public static var current: MGSniffingModel {
        do {
            guard let data = UserDefaults.shared.data(forKey: MGConstant.sniffing) else {
                return .default
            }
            return try JSONDecoder().decode(MGSniffingModel.self, from: data)
        } catch {
            return .default
        }
    }
}
