import Foundation

public final class MPCProxyViewModel: MPCUpdatableViewModel, ObservableObject, Identifiable {
    
    public var id: ObjectIdentifier { ObjectIdentifier(self) }
    
    private let model: MPCProxyModel
    
    public var name: String { model.name }
    public var type: MPCProxyModel.AdapterType { model.type }
    public var udp: Bool { model.udp }
    
    @Published public var histories: [MPCProxyModel.Delay]
    
    public init(model: MPCProxyModel) {
        self.model = model
        self.histories = model.histories
    }
    
    public final override func update(model: MPCProxyModel) {
        histories = model.histories
    }
    
    public var delay: String {
        guard type.isProxyType else {
            return ""
        }
        guard let last = histories.last else {
            return "-"
        }
        let delay = last.delay
        return delay == 0 ? "超时" : "\(delay)"
    }
}
