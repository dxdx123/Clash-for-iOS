import Foundation

extension MGConstant {
    public static let log: String = "XRAY_LOG_DATA"
}

public struct MGLogModel: Codable, Equatable {
    
    public enum Severity: Int, Codable, Equatable, CaseIterable, Identifiable {
        public var id: Self { self }
        case none       = 0
        case error      = 1
        case warning    = 2
        case info       = 3
        case debug      = 4
    }
    
    public let accessLogEnabled: Bool
    public let dnsLogEnabled: Bool
    public let errorLogSeverity: Severity
    
    public static let `default` = MGLogModel(
        accessLogEnabled: false,
        dnsLogEnabled: false,
        errorLogSeverity: .none
    )
    
    public static var current: MGLogModel {
        do {
            guard let data = UserDefaults.shared.data(forKey: MGConstant.log) else {
                return .default
            }
            return try JSONDecoder().decode(MGLogModel.self, from: data)
        } catch {
            return .default
        }
    }
}
