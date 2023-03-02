import Foundation

public enum MGKernel: String, Identifiable, CaseIterable {
    
    public var id: Self { self }
    
    case clash, xray
}

extension MGKernel {
    
    private static func createDirectory(at url: URL) -> URL {
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

    public var homeDirectory: URL {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: MGConstant.suiteName) else {
            fatalError("无法加载共享文件路径")
        }
        let url = containerURL.appendingPathComponent("Library/Application Support/\(self.rawValue.capitalized)")
        return type(of: self).createDirectory(at: url)
    }
    
    public var assetDirectory: URL {
        switch self {
        case .clash:
            return self.homeDirectory
        case .xray:
            return type(of: self).createDirectory(at: self.homeDirectory.appending(component: "assets", directoryHint: .isDirectory))
        }
    }
    
    public var configDirectory: URL {
        switch self {
        case .clash:
            return self.homeDirectory
        case .xray:
            return type(of: self).createDirectory(at: self.homeDirectory.appending(component: "configs", directoryHint: .isDirectory))
        }
    }
    
    public var fileExtension: String {
        switch self {
        case .clash:    return "yaml"
        case .xray:     return "json"
        }
    }
}
