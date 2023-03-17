import Foundation

final class MGNetworkViewModel: ObservableObject {
    
    @Published var hideVPNIcon: Bool
    @Published var ipv6Enabled: Bool
    
    private var current: MGNetworkModel
    
    init() {
        let model = MGNetworkModel.current
        self.hideVPNIcon = model.hideVPNIcon
        self.ipv6Enabled = model.ipv6Enabled
        self.current = model
    }
    
    static func setupDefaultLogIfNeeded() {
        guard UserDefaults.shared.data(forKey: MGConstant.network) == nil else {
            return
        }
        do {
            UserDefaults.shared.set(try JSONEncoder().encode(MGNetworkModel.default), forKey: MGConstant.network)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func save(updated: () -> Void) {
        do {
            let model = MGNetworkModel(
                hideVPNIcon: self.hideVPNIcon,
                ipv6Enabled: self.ipv6Enabled
            )
            guard model != self.current else {
                return
            }
            UserDefaults.shared.set(try JSONEncoder().encode(model), forKey: MGConstant.network)
            self.current = model
            updated()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
