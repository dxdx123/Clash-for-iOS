import Foundation

final class MGLogViewModel: ObservableObject {
    
    @Published var accessLogEnabled: Bool
    @Published var dnsLogEnabled: Bool
    @Published var errorLogSeverity: MGLogModel.Severity
    
    private var current: MGLogModel
    
    init() {
        let model = MGLogModel.current
        self.accessLogEnabled = model.accessLogEnabled
        self.dnsLogEnabled = model.dnsLogEnabled
        self.errorLogSeverity = model.errorLogSeverity
        self.current = model
    }
    
    static func setupDefaultLogIfNeeded() {
        guard UserDefaults.shared.data(forKey: MGConstant.log) == nil else {
            return
        }
        do {
            UserDefaults.shared.set(try JSONEncoder().encode(MGLogModel.default), forKey: MGConstant.log)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func save(updated: () -> Void) {
        do {
            let model = MGLogModel(
                accessLogEnabled: self.accessLogEnabled,
                dnsLogEnabled: self.dnsLogEnabled,
                errorLogSeverity: self.errorLogSeverity
            )
            guard model != self.current else {
                return
            }
            UserDefaults.shared.set(try JSONEncoder().encode(model), forKey: MGConstant.log)
            self.current = model
            updated()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
