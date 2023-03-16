import Foundation

final class MGSniffingViewModel: ObservableObject {
    
    @Published var enabled: Bool
    @Published var httpEnabled: Bool
    @Published var tlsEnabled: Bool
    @Published var quicEnabled: Bool
    @Published var fakednsEnabled: Bool
    @Published var metadataOnly: Bool
    @Published var routeOnly: Bool
    @Published var excludedDomains: [String]
    
    @Published var domain: String = ""
    
    private var current: MGSniffingModel
    
    init() {
        let model               = MGSniffingModel.current
        self.enabled            = model.enabled
        self.httpEnabled        = model.httpEnabled
        self.tlsEnabled         = model.tlsEnabled
        self.quicEnabled        = model.quicEnabled
        self.fakednsEnabled     = model.fakednsEnabled
        self.metadataOnly       = model.metadataOnly
        self.routeOnly          = model.routeOnly
        self.excludedDomains    = model.excludedDomains
        self.current = model
    }
    
    static func setupDefaultSettingsIfNeeded() {
        guard UserDefaults.shared.data(forKey: MGConstant.sniffing) == nil else {
            return
        }
        do {
            UserDefaults.shared.set(try JSONEncoder().encode(MGSniffingModel.default), forKey: MGConstant.sniffing)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func submitDomain() {
        let temp = self.domain.trimmingCharacters(in: .whitespacesAndNewlines)
        DispatchQueue.main.async {
            self.domain = ""
        }
        guard !temp.isEmpty else {
            return
        }
        guard !self.excludedDomains.contains(where: { $0 == temp }) else {
            return
        }
        self.excludedDomains.append(temp)
    }
    
    func delete(domain: String) {
        self.excludedDomains.removeAll(where: { $0 == domain })
    }
    
    func save(updated: () -> Void) {
        do {
            let model = MGSniffingModel(
                enabled: self.enabled,
                httpEnabled: self.httpEnabled,
                tlsEnabled: self.tlsEnabled,
                quicEnabled: self.quicEnabled,
                fakednsEnabled: self.fakednsEnabled,
                metadataOnly: self.metadataOnly,
                routeOnly: self.routeOnly,
                excludedDomains: self.excludedDomains
            )
            guard model != self.current else {
                return
            }
            UserDefaults.shared.set(try JSONEncoder().encode(model), forKey: MGConstant.sniffing)
            self.current = model
            updated()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
