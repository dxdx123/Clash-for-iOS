import Foundation

public final class CFIProvidersManager: ObservableObject {
    
    @Published public var gProviderVMs: [CFIProviderViewModel] = []
    @Published public var rProviderVMs: [CFIProviderViewModel] = []
    @Published public var proxyVMs: [CFIProxyViewModel] = []
    
    @Published public var isHealthChecking = false
    
    private var vms: [String: CFIUpdatableViewModel] = [:]
        
    public init() {}
        
    public func update(mapping:[String: CFIProxyModel]) {
        let gProviderVMs: [CFIProviderViewModel]
        let rProviderVMs: [CFIProviderViewModel]
        let proxyVMs: [CFIProxyViewModel]
        let vms: [String: CFIUpdatableViewModel]
        if let global = mapping["GLOBAL"], !global.all.isEmpty {
            let proxyVMMapping: [String: CFIProxyViewModel] = global.all.reduce(into: [String: CFIProxyViewModel]()) { result, name in
                guard let model = mapping[name] else {
                    return
                }
                result[name] = CFIProxyViewModel(model: model)
            }
            let rules: [CFIProxyModel] = global.all.compactMap { name in
                guard let model = mapping[name], model.type.isProviderType else {
                    return nil
                }
                return model
            }
            let gVMs = [CFIProvidersManager.createProvider(with: global, proxyVMs: proxyVMMapping)]
            let rVMs = rules.map { CFIProvidersManager.createProvider(with: $0, proxyVMs: proxyVMMapping) }
            gProviderVMs = gVMs
            rProviderVMs = rVMs
            proxyVMs = global.all.compactMap { name in
                guard let vm = proxyVMMapping[name], vm.type.isProxyType else {
                    return nil
                }
                return vm
            }
            vms = {
                var temp: [String: CFIUpdatableViewModel] = proxyVMMapping
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
    
    private static func createProvider(with model: CFIProxyModel, proxyVMs: [String: CFIProxyViewModel]) -> CFIProviderViewModel {
        CFIProviderViewModel(model: model, proxies: model.all.compactMap { proxyVMs[$0] })
    }
    
    public func patch(mapping:[String: CFIProxyModel]) {
        self.vms.forEach { name, vm in
            guard let model = mapping[name] else {
                return
            }
            vm.update(model: model)
        }
    }
}
