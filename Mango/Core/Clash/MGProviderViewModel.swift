import Foundation

public final class MGProviderViewModel: MGUpdatableViewModel, ObservableObject, Identifiable, Hashable {
    
    public static func == (lhs: MGProviderViewModel, rhs: MGProviderViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public var id: ObjectIdentifier { ObjectIdentifier(self) }
    
    private let model: MGProxyModel
    
    public let proxies: [MGProxyViewModel]
    public let proxyMapping: [String: MGProxyViewModel]
    public var name: String { model.name }
    public var type: MGProxyModel.AdapterType { model.type }
    public var isHealthCheckEnable: Bool {
        model.type == .urlTest || model.type == .fallback || model.type == .loadBalance
    }
    
    @Published public var now: String
    @Published public var isHealthChecking: Bool = false
    @Published public var isExpanded: Bool = false
    
    public init(model: MGProxyModel, proxies: [MGProxyViewModel]) {
        self.model = model
        self.now = model.now
        self.proxies = proxies
        self.proxyMapping = proxies.reduce(into: [:], { $0[$1.name] = $1 })
    }
    
    public final override func update(model: MGProxyModel) {
        now = model.now
    }
}
