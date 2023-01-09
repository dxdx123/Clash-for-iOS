import Foundation

struct CFISubscribe: Identifiable {
    struct Extend: Codable {
        let alias: String
        let source: URL
        let leastUpdated: Date
    }
    let id: String
    let creationDate: Date
    let extend: Extend
}

final class CFISubscribeManager: ObservableObject {
    
    @Published var subscribes: [CFISubscribe] = []
    @Published var downloadingSubscribeIDs: Set<String> = []
    
    init() {
        self.subscribes = self.fetchSubscribes()
    }
    
    func reload() {
        self.subscribes = self.fetchSubscribes()
    }
    
    private func fetchSubscribes() -> [CFISubscribe] {
        do {
            let children = try FileManager.default.contentsOfDirectory(at: CFIConstant.homeDirectory, includingPropertiesForKeys: nil)
            return children.compactMap(load(from:)).sorted(by: { $0.creationDate < $1.creationDate })
        } catch {
            return []
        }
    }
    
    private func load(from url: URL) -> CFISubscribe? {
        do {
            guard let uuid = UUID(uuidString: url.deletingPathExtension().lastPathComponent) else {
                return nil
            }
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path(percentEncoded: false))
            guard let creationDate = attributes[.creationDate] as? Date,
                  let extends = attributes[.extended] as? [String: Data],
                  let data = extends[CFIConstant.extendAttributeKey] else {
                return nil
            }
            return CFISubscribe(
                id: uuid.uuidString,
                creationDate: creationDate,
                extend: try JSONDecoder().decode(CFISubscribe.Extend.self, from: data)
            )
        } catch {
            return nil
        }
    }
    
    func delete(subscribe: CFISubscribe) throws {
        do {
            try FileManager.default.removeItem(at: CFIConstant.homeDirectory.appending(path: "\(subscribe.id).yaml"))
        } catch {
            debugPrint(error.localizedDescription)
        }
        self.subscribes = self.fetchSubscribes()
    }
    
    func rename(subscribe: CFISubscribe, name: String) throws {
        let target = CFIConstant.homeDirectory.appending(path: "\(subscribe.id).yaml")
        let extend = CFISubscribe.Extend(
            alias: name,
            source: subscribe.extend.source,
            leastUpdated: subscribe.extend.leastUpdated
        )
        try FileManager.default.setAttributes(
            [.extended: [CFIConstant.extendAttributeKey: try JSONEncoder().encode(extend)]],
            ofItemAtPath: target.path(percentEncoded: false)
        )
        self.subscribes = self.fetchSubscribes()
    }
    
    func download(source: URL) async throws {
        let id = UUID().uuidString
        let data = try await URLSession.shared.data(for: URLRequest(url: source)).0
        let target = CFIConstant.homeDirectory.appending(path: "\(id).yaml")
        try data.write(to: target)
        let extend = CFISubscribe.Extend(
            alias: id,
            source: source,
            leastUpdated: Date()
        )
        try FileManager.default.setAttributes(
            [.extended: [CFIConstant.extendAttributeKey: try JSONEncoder().encode(extend)]],
            ofItemAtPath: target.path(percentEncoded: false)
        )
        await MainActor.run {
            self.subscribes = self.fetchSubscribes()
        }
    }
    
    func update(subscribe: CFISubscribe) async throws {
        do {
            await MainActor.run {
                _ = self.downloadingSubscribeIDs.insert(subscribe.id)
            }
            let data = try await URLSession.shared.data(for: URLRequest(url: subscribe.extend.source)).0
            let target = CFIConstant.homeDirectory.appending(path: "\(subscribe.id).yaml")
            try data.write(to: target)
            let extend = CFISubscribe.Extend(
                alias: subscribe.extend.alias,
                source: subscribe.extend.source,
                leastUpdated: Date()
            )
            try FileManager.default.setAttributes(
                [.extended: [CFIConstant.extendAttributeKey: try JSONEncoder().encode(extend)]],
                ofItemAtPath: target.path(percentEncoded: false)
            )
            await MainActor.run {
                self.subscribes = self.fetchSubscribes()
                _ = self.downloadingSubscribeIDs.remove(subscribe.id)
            }
        } catch {
            await MainActor.run {
                _ = self.downloadingSubscribeIDs.remove(subscribe.id)
            }
            throw error
        }
    }
}
