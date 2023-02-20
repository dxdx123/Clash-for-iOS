import Foundation

public final class MPCProviderViewModel: MPCUpdatableViewModel, ObservableObject, Identifiable, Hashable {
    
    public static func == (lhs: MPCProviderViewModel, rhs: MPCProviderViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public var id: ObjectIdentifier { ObjectIdentifier(self) }
    
    private let model: MPCProxyModel
    
    public let proxies: [MPCProxyViewModel]
    public let proxyMapping: [String: MPCProxyViewModel]
    public var name: String { model.name }
    public var type: MPCProxyModel.AdapterType { model.type }
    public var isHealthCheckEnable: Bool {
        model.type == .urlTest || model.type == .fallback || model.type == .loadBalance
    }
    
    @Published public var now: String
    @Published public var isHealthChecking: Bool = false
    @Published public var isExpanded: Bool = false
    
    public init(model: MPCProxyModel, proxies: [MPCProxyViewModel]) {
        self.model = model
        self.now = model.now
        self.proxies = proxies
        self.proxyMapping = proxies.reduce(into: [:], { $0[$1.name] = $1 })
    }
    
    public final override func update(model: MPCProxyModel) {
        now = model.now
    }
}
