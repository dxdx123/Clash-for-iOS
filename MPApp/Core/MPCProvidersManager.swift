import Foundation

public final class MPCProvidersManager: ObservableObject {
    
    @Published public var gProviderVMs: [MPCProviderViewModel] = []
    @Published public var rProviderVMs: [MPCProviderViewModel] = []
    @Published public var proxyVMs: [MPCProxyViewModel] = []
    
    @Published public var isHealthChecking = false
    
    private var vms: [String: MPCUpdatableViewModel] = [:]
        
    public init() {}
        
    public func update(mapping:[String: MPCProxyModel]) {
        let gProviderVMs: [MPCProviderViewModel]
        let rProviderVMs: [MPCProviderViewModel]
        let proxyVMs: [MPCProxyViewModel]
        let vms: [String: MPCUpdatableViewModel]
        if let global = mapping["GLOBAL"], !global.all.isEmpty {
            let proxyVMMapping: [String: MPCProxyViewModel] = global.all.reduce(into: [String: MPCProxyViewModel]()) { result, name in
                guard let model = mapping[name] else {
                    return
                }
                result[name] = MPCProxyViewModel(model: model)
            }
            let rules: [MPCProxyModel] = global.all.compactMap { name in
                guard let model = mapping[name], model.type.isProviderType else {
                    return nil
                }
                return model
            }
            let gVMs = [MPCProvidersManager.createProvider(with: global, proxyVMs: proxyVMMapping)]
            let rVMs = rules.map { MPCProvidersManager.createProvider(with: $0, proxyVMs: proxyVMMapping) }
            gProviderVMs = gVMs
            rProviderVMs = rVMs
            proxyVMs = global.all.compactMap { name in
                guard let vm = proxyVMMapping[name], vm.type.isProxyType else {
                    return nil
                }
                return vm
            }
            vms = {
                var temp: [String: MPCUpdatableViewModel] = proxyVMMapping
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
    
    private static func createProvider(with model: MPCProxyModel, proxyVMs: [String: MPCProxyViewModel]) -> MPCProviderViewModel {
        MPCProviderViewModel(model: model, proxies: model.all.compactMap { proxyVMs[$0] })
    }
    
    public func patch(mapping:[String: MPCProxyModel]) {
        self.vms.forEach { name, vm in
            guard let model = mapping[name] else {
                return
            }
            vm.update(model: model)
        }
    }
}
