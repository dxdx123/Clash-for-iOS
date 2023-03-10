import Foundation
import UniformTypeIdentifiers

@frozen
public enum MGConfigurationFormat: String, CaseIterable, Identifiable {
    
    public var id: Self { self }
    
    case json, yaml, toml
    
    var uniformTypeType: UTType {
        switch self {
        case .json:
            return .json
        case .yaml:
            return .yaml
        case .toml:
            return .toml
        }
    }
}
