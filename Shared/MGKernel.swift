import Foundation

public enum MGKernel: String, Identifiable, CaseIterable {
    
    public var id: Self { self }
    
    case clash, xray
}

extension MGKernel {
    
    private static func createHomeDirectory(of kernel: MGKernel) -> URL {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: MGConstant.suiteName) else {
            fatalError("无法加载共享文件路径")
        }
        let url = containerURL.appendingPathComponent("Library/Application Support/\(kernel.rawValue.capitalized)")
        guard FileManager.default.fileExists(atPath: url.path) == false else {
            return url
        }
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
        return url
    }
    
    private static let _c = MGKernel.createHomeDirectory(of: .clash)
    private static let _x = MGKernel.createHomeDirectory(of: .xray)

    public var homeDirectory: URL {
        switch self {
        case .clash:    return MGKernel._c
        case .xray:     return MGKernel._x
        }
    }
    
    public var fileExtension: String {
        switch self {
        case .clash:    return "yaml"
        case .xray:     return "json"
        }
    }
}
