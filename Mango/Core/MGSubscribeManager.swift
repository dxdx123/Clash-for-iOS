import Foundation
import SwiftUI

struct MGSubscribe: Identifiable {
    struct Extend: Codable {
        let alias: String
        let source: URL
        let leastUpdated: Date
    }
    let id: String
    let creationDate: Date
    let extend: Extend
}

final class MGSubscribeManager: ObservableObject {
    
    deinit {
        print("CFISubscribeManager deinit")
    }
    
    @Published var subscribes: [MGSubscribe] = []
    @Published var downloadingSubscribeIDs: Set<String> = []
    
    let kernel: MGKernel
    let current: Binding<String>
    
    init(kernel: MGKernel) {
        self.kernel = kernel
        let key = "\(kernel.rawValue.uppercased())_CURRENT"
        self.current = Binding(get: {
            UserDefaults.shared.string(forKey: key) ?? ""
        }, set: { newValue in
            UserDefaults.shared.set(newValue, forKey: key)
        })
    }
    
    func prepare() async {
        Task(priority: .userInitiated) {
            let subscribes = self.fetchSubscribes()
            await MainActor.run {
                self.subscribes = subscribes
            }
        }
    }
    
    func reload() {
        self.subscribes = self.fetchSubscribes()
    }
    
    private func fetchSubscribes() -> [MGSubscribe] {
        do {
            let children = try FileManager.default.contentsOfDirectory(at: kernel.homeDirectory, includingPropertiesForKeys: nil)
            return children.compactMap(load(from:)).sorted(by: { $0.creationDate < $1.creationDate })
        } catch {
            return []
        }
    }
    
    private func load(from url: URL) -> MGSubscribe? {
        do {
            guard let uuid = UUID(uuidString: url.deletingPathExtension().lastPathComponent) else {
                return nil
            }
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path(percentEncoded: false))
            guard let creationDate = attributes[.creationDate] as? Date,
                  let extends = attributes[.extended] as? [String: Data],
                  let data = extends[MGConstant.Clash.extendAttributeKey] else {
                return nil
            }
            return MGSubscribe(
                id: uuid.uuidString,
                creationDate: creationDate,
                extend: try JSONDecoder().decode(MGSubscribe.Extend.self, from: data)
            )
        } catch {
            return nil
        }
    }
    
    func delete(subscribe: MGSubscribe) throws {
        do {
            try FileManager.default.removeItem(at: kernel.homeDirectory.appending(path: "\(subscribe.id).\(kernel.fileExtension)"))
        } catch {
            debugPrint(error.localizedDescription)
        }
        self.subscribes = self.fetchSubscribes()
    }
    
    func rename(subscribe: MGSubscribe, name: String) throws {
        let target = kernel.homeDirectory.appending(path: "\(subscribe.id).\(kernel.fileExtension)")
        let extend = MGSubscribe.Extend(
            alias: name,
            source: subscribe.extend.source,
            leastUpdated: subscribe.extend.leastUpdated
        )
        try FileManager.default.setAttributes(
            [.extended: [MGConstant.Clash.extendAttributeKey: try JSONEncoder().encode(extend)]],
            ofItemAtPath: target.path(percentEncoded: false)
        )
        self.subscribes = self.fetchSubscribes()
    }
    
    func download(source: URL) async throws {
        let id = UUID().uuidString
        let request: URLRequest = {
            var temp = URLRequest(url: source)
            temp.allHTTPHeaderFields = ["User-Agent": "\(kernel.rawValue.capitalized)/\(Bundle.appVersion)"]
            return temp
        }()
        let data = try await URLSession.shared.data(for: request).0
        let target = kernel.homeDirectory.appending(path: "\(id).\(kernel.fileExtension)")
        try data.write(to: target)
        let extend = MGSubscribe.Extend(
            alias: id,
            source: source,
            leastUpdated: Date()
        )
        try FileManager.default.setAttributes(
            [.extended: [MGConstant.Clash.extendAttributeKey: try JSONEncoder().encode(extend)]],
            ofItemAtPath: target.path(percentEncoded: false)
        )
        await MainActor.run {
            self.subscribes = self.fetchSubscribes()
        }
    }
    
    func update(subscribe: MGSubscribe) async throws {
        do {
            await MainActor.run {
                _ = self.downloadingSubscribeIDs.insert(subscribe.id)
            }
            let request: URLRequest = {
                var temp = URLRequest(url: subscribe.extend.source)
                temp.allHTTPHeaderFields = ["User-Agent": "\(kernel.rawValue.capitalized)/\(Bundle.appVersion)"]
                return temp
            }()
            let data = try await URLSession.shared.data(for: request).0
            let target = kernel.homeDirectory.appending(path: "\(subscribe.id).\(kernel.fileExtension)")
            try data.write(to: target)
            let extend = MGSubscribe.Extend(
                alias: subscribe.extend.alias,
                source: subscribe.extend.source,
                leastUpdated: Date()
            )
            try FileManager.default.setAttributes(
                [.extended: [MGConstant.Clash.extendAttributeKey: try JSONEncoder().encode(extend)]],
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
