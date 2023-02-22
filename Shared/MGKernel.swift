import Foundation

public enum MGKernel: String, Identifiable, CaseIterable {
    
    public var id: Self { self }
    
    case clash, xray
}
