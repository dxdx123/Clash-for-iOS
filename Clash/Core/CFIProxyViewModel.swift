import Foundation

public final class CFIProxyViewModel: CFIUpdatableViewModel, ObservableObject, Identifiable {
    
    public var id: ObjectIdentifier { ObjectIdentifier(self) }
    
    private let model: CFIProxyModel
    
    public var name: String { model.name }
    public var type: CFIProxyModel.AdapterType { model.type }
    public var udp: Bool { model.udp }
    
    @Published public var histories: [CFIProxyModel.Delay]
    
    public init(model: CFIProxyModel) {
        self.model = model
        self.histories = model.histories
    }
    
    public final override func update(model: CFIProxyModel) {
        histories = model.histories
    }
    
    public var delay: String {
        guard type.isProxyType else {
            return ""
        }
        guard !histories.isEmpty else {
            return "-"
        }
        let delay = histories[0].delay
        return delay == 0 ? "超时" : "\(delay)"
    }
}
