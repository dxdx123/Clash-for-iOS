import Foundation

final class MGSubscriptionDownloadViewModel: ObservableObject {
    
    @Published var location:   MGSubscriptionLocation = .remote
    @Published var format:     MGSubscriptionFormat
    
    @Published var name:       String = ""
    @Published var urlString:  String = ""
    
    @Published var isProcessing: Bool = false
    
    private let directoryURL: URL
    
    let supportedFormats: [MGSubscriptionFormat]
    
    init(directoryURL: URL, supportedFormats: [MGSubscriptionFormat]) {
        self.directoryURL = directoryURL
        self.supportedFormats = supportedFormats
        self.format = supportedFormats[0]
    }
    
    func process() async throws {
        await MainActor.run {
            isProcessing = true
        }
        let err: Error?
        do {
            switch location {
            case .local:
                try await processLocal()
            case .remote:
                try await processRemote()
            }
            try await Task.sleep(for: .seconds(2))
            err = nil
        } catch {
            err = error
        }
        await MainActor.run {
            isProcessing = false
        }
        try err.flatMap { throw $0 }
    }
    
    private func processLocal() async throws {
        let url = URL(filePath: urlString.trimmingCharacters(in: .whitespacesAndNewlines))
        guard url.startAccessingSecurityScopedResource() else {
            throw NSError.newError("无法访问该配置文件")
        }
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        try self.save(sourceURL: url, fileURL: url)
    }
    
    private func processRemote() async throws {
        guard let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw NSError.newError("配置地址不合法")
        }
        let request: URLRequest = {
            var temp = URLRequest(url: url)
            if let kernel = UserDefaults.standard.string(forKey: MGKernel.storeKey) {
                temp.allHTTPHeaderFields = ["User-Agent": "\(kernel.lowercased().capitalized)/\(Bundle.appVersion)"]
            }
            return temp
        }()
        let tempURL = try await URLSession.shared.download(for: request, delegate: nil).0
        defer {
            do {
                try FileManager.default.removeItem(at: tempURL)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        try self.save(sourceURL: url, fileURL: tempURL)
    }
    
    private func save(sourceURL: URL, fileURL: URL) throws {
        let id = UUID()
        let folderURL = self.directoryURL.appending(component: "\(id.uuidString)")
        let attributes = MGAttributes(
            alias: name.trimmingCharacters(in: .whitespacesAndNewlines),
            source: sourceURL,
            leastUpdated: Date()
        )
        try FileManager.default.createDirectory(
            at: folderURL,
            withIntermediateDirectories: true,
            attributes: [
                MGSubscription.key: [MGAttributes.key: try JSONEncoder().encode(attributes)]
            ]
        )
        let destinationURL = directoryURL.appending(component: "config.\(format.rawValue)")
        try FileManager.default.copyItem(at: fileURL, to: destinationURL)
    }
}
