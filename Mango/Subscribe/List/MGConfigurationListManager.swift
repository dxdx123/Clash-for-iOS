import Foundation
import SwiftUI

final class MGConfigurationListManager: ObservableObject {
    
    @Published var configurations: [MGConfiguration]        = []
    @Published var downloadingConfigurationIDs: Set<String> = []

    func reload() {
        self.configurations = self.loadConfigurations()
    }
    
    private func loadConfigurations() -> [MGConfiguration] {
        do {
            let children = try FileManager.default.contentsOfDirectory(at: MGConstant.configDirectory, includingPropertiesForKeys: nil)
            return children.compactMap(MGConfiguration.init(url:)).sorted(by: { $0.creationDate < $1.creationDate })
        } catch {
            return []
        }
    }
    
    func delete(configuration: MGConfiguration) throws {
        let err: Error?
        do {
            try FileManager.default.removeItem(at: MGConstant.configDirectory.appending(path: configuration.id))
            err = nil
        } catch {
            err = error
        }
        self.reload()
        try err.flatMap { throw $0 }
    }
    
    func rename(configuration: MGConfiguration, name: String) throws {
        let target = MGConstant.configDirectory.appending(path: "\(configuration.id)")
        let attributes = MGConfiguration.Attributes(
            alias: name,
            source: configuration.attributes.source,
            leastUpdated: configuration.attributes.leastUpdated,
            format: configuration.attributes.format
        )
        try FileManager.default.setAttributes(
            [MGConfiguration.key: [MGConfiguration.Attributes.key: try JSONEncoder().encode(attributes)]],
            ofItemAtPath: target.path(percentEncoded: false)
        )
        self.reload()
    }
    
    func update(configuration: MGConfiguration) async throws {
        do {
            await MainActor.run {
                _ = self.downloadingConfigurationIDs.insert(configuration.id)
            }
            let tempURL = try await URLSession.shared.download(from: configuration.attributes.source).0
            defer {
                do {
                    try FileManager.default.removeItem(at: tempURL)
                } catch {
                    debugPrint(error.localizedDescription)
                }
            }
            let folderURL = MGConstant.configDirectory.appending(path: configuration.id)
            let destinationURL = folderURL.appending(path: "config.\(configuration.attributes.format.rawValue)")
            try FileManager.default.replaceItem(at: destinationURL, withItemAt: tempURL, backupItemName: nil, resultingItemURL: nil)
            let attributes = MGConfiguration.Attributes(
                alias: configuration.attributes.alias,
                source: configuration.attributes.source,
                leastUpdated: Date(),
                format: configuration.attributes.format
            )
            try FileManager.default.setAttributes(
                [MGConfiguration.key: [MGConfiguration.Attributes.key: try JSONEncoder().encode(attributes)]],
                ofItemAtPath: folderURL.path(percentEncoded: false)
            )
            await MainActor.run {
                self.reload()
                _ = self.downloadingConfigurationIDs.remove(configuration.id)
            }
        } catch {
            await MainActor.run {
                _ = self.downloadingConfigurationIDs.remove(configuration.id)
            }
            throw error
        }
    }
}

fileprivate extension MGConfiguration {
    
    init?(url: URL) {
        do {
            guard let id = UUID(uuidString: url.lastPathComponent) else {
                return nil
            }
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path(percentEncoded: false))
            guard let creationDate = attributes[.creationDate] as? Date,
                  let extends = attributes[MGConfiguration.key] as? [String: Data],
                  let data = extends[MGConfiguration.Attributes.key] else {
                return nil
            }
            self.id = id.uuidString
            self.creationDate = creationDate
            self.attributes = try JSONDecoder().decode(MGConfiguration.Attributes.self, from: data)
        } catch {
            return nil
        }
    }
}
