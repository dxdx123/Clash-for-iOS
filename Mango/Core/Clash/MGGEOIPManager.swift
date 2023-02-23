import Foundation

final class MGGEOIPManager: ObservableObject {
    
    @Published var isUpdating: Bool = false
    @Published var leastUpdated: Date?
    
    private let fileURL = MGConstant.Clash.homeDirectory.appendingPathComponent("Country.mmdb")
    
    init() {
        refresh()
    }
    
    func checkAndUpdateIfNeeded() {
        guard UserDefaults.standard.bool(forKey: MGConstant.Clash.geoipDatabaseAutoUpdate) else {
            return
        }
        let shouldUpdate: Bool
        if let least = leastUpdated {
            shouldUpdate = abs(least.distance(to: Date())) > 30 * 24 * 60 * 60
        } else {
            shouldUpdate = true
        }
        guard shouldUpdate, let url = URL(string: UserDefaults.standard.string(forKey: MGConstant.Clash.geoipDatabaseRemoteURLString) ?? "") else {
            return
        }
        Task(priority: .medium) {
            do {
                try await update(url: url)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    func refresh() {
        if FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path(percentEncoded: false))
                let creationDate = attributes[.creationDate] as? Date
                let modificationDate = attributes[.modificationDate] as? Date
                leastUpdated = modificationDate ?? creationDate
            } catch {
                leastUpdated = nil
            }
        } else {
            leastUpdated = nil
        }
    }
    
    func update(url: URL) async throws {
        await MainActor.run {
            isUpdating = true
        }
        do {
            let destinationURL = MGConstant.Clash.homeDirectory.appendingPathComponent("Country.mmdb")
            let tempURL = try await URLSession.shared.download(from: url, delegate: nil).0
            if FileManager.default.fileExists(atPath: destinationURL.path(percentEncoded: false)) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: tempURL, to: destinationURL)
            await MainActor.run {
                isUpdating = false
                refresh()
            }
        } catch {
            await MainActor.run {
                isUpdating = false
                refresh()
            }
            throw error
        }
    }
    
    func importLocalFile(from url: URL) throws {
        guard url.startAccessingSecurityScopedResource() else {
            return
        }
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        let destinationURL = MGConstant.Clash.homeDirectory.appendingPathComponent("Country.mmdb")
        if FileManager.default.fileExists(atPath: destinationURL.path(percentEncoded: false)) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        try FileManager.default.copyItem(at: url, to: destinationURL)
        refresh()
    }
}
