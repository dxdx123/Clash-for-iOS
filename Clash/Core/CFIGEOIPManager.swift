import Foundation

final class CFIGEOIPManager: ObservableObject {
    
    @Published var isUpdating: Bool = false
    @Published var leastUpdated: Date?
    
    private let fileURL = CFIConstant.homeDirectory.appendingPathComponent("Country.mmdb")
    
    init() {
        refresh()
    }
    
    func checkAndUpdateIfNeeded() {
        guard UserDefaults.standard.bool(forKey: CFIConstant.geoipDatabaseAutoUpdate) else {
            return
        }
        let shouldUpdate: Bool
        if let least = leastUpdated {
            shouldUpdate = abs(least.distance(to: Date())) > 7 * 24 * 60
        } else {
            shouldUpdate = true
        }
        guard shouldUpdate, let url = URL(string: UserDefaults.standard.string(forKey: CFIConstant.geoipDatabaseRemoteURLString) ?? "") else {
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
            let destinationURL = CFIConstant.homeDirectory.appendingPathComponent("Country.mmdb")
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
}
