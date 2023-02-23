import Foundation

public final class MGProvidersManager: ObservableObject {
    
    @Published public var gProviderVMs: [MGProviderViewModel] = []
    @Published public var rProviderVMs: [MGProviderViewModel] = []
    @Published public var proxyVMs: [MGProxyViewModel] = []
    
    @Published public var isHealthChecking = false
    
    private var vms: [String: MGUpdatableViewModel] = [:]
        
    public init() {}
        
    public func update(mapping:[String: MGProxyModel]) {
        let gProviderVMs: [MGProviderViewModel]
        let rProviderVMs: [MGProviderViewModel]
        let proxyVMs: [MGProxyViewModel]
        let vms: [String: MGUpdatableViewModel]
        if let global = mapping["GLOBAL"], !global.all.isEmpty {
            let proxyVMMapping: [String: MGProxyViewModel] = global.all.reduce(into: [String: MGProxyViewModel]()) { result, name in
                guard let model = mapping[name] else {
                    return
                }
                result[name] = MGProxyViewModel(model: model)
            }
            let rules: [MGProxyModel] = global.all.compactMap { name in
                guard let model = mapping[name], model.type.isProviderType else {
                    return nil
                }
                return model
            }
            let gVMs = [MGProvidersManager.createProvider(with: global, proxyVMs: proxyVMMapping)]
            let rVMs = rules.map { MGProvidersManager.createProvider(with: $0, proxyVMs: proxyVMMapping) }
            gProviderVMs = gVMs
            rProviderVMs = rVMs
            proxyVMs = global.all.compactMap { name in
                guard let vm = proxyVMMapping[name], vm.type.isProxyType else {
                    return nil
                }
                return vm
            }
            vms = {
                var temp: [String: MGUpdatableViewModel] = proxyVMMapping
                (gVMs + rVMs).forEach { model in
                    temp[model.name] = model
                }
                return temp
            }()
        } else {
            gProviderVMs = []
            rProviderVMs = []
            proxyVMs = []
            vms = [:]
        }
        self.gProviderVMs = gProviderVMs
        self.rProviderVMs = rProviderVMs
        self.proxyVMs = proxyVMs
        self.vms = vms
    }
    
    private static func createProvider(with model: MGProxyModel, proxyVMs: [String: MGProxyViewModel]) -> MGProviderViewModel {
        MGProviderViewModel(model: model, proxies: model.all.compactMap { proxyVMs[$0] })
    }
    
    public func patch(mapping:[String: MGProxyModel]) {
        self.vms.forEach { name, vm in
            guard let model = mapping[name] else {
                return
            }
            vm.update(model: model)
        }
    }
}
