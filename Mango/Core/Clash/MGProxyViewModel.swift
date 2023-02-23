import Foundation

public final class MGProxyViewModel: MGUpdatableViewModel, ObservableObject, Identifiable {
    
    public var id: ObjectIdentifier { ObjectIdentifier(self) }
    
    private let model: MGProxyModel
    
    public var name: String { model.name }
    public var type: MGProxyModel.AdapterType { model.type }
    public var udp: Bool { model.udp }
    
    @Published public var histories: [MGProxyModel.Delay]
    
    public init(model: MGProxyModel) {
        self.model = model
        self.histories = model.histories
    }
    
    public final override func update(model: MGProxyModel) {
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
