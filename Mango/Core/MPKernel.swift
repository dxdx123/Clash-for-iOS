import Foundation

extension MGConstant {
    static let kernel = "KERNEL"
}

public enum MPKernel: String, Identifiable, CaseIterable {
    
    public var id: Self { self }
    
    case clash, xray
}
