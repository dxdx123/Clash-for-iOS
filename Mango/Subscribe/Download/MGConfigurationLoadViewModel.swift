import Foundation

final class MGConfigurationLoadViewModel: ObservableObject {
    
    @Published var format: MGConfigurationFormat = .json
    
    @Published var name:       String = ""
    @Published var urlString:  String = ""
    
    @Published var isProcessing: Bool = false
    
    func process(location: MGConfigurationLocation) async throws {
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
        let tempURL = try await URLSession.shared.download(from: url).0
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
        let folderURL = MGConstant.configDirectory.appending(component: "\(id.uuidString)")
        let attributes = MGConfiguration.Attributes(
            alias: name.trimmingCharacters(in: .whitespacesAndNewlines),
            source: sourceURL,
            leastUpdated: Date(),
            format: self.format
        )
        try FileManager.default.createDirectory(
            at: folderURL,
            withIntermediateDirectories: true,
            attributes: [
                MGConfiguration.key: [MGConfiguration.Attributes.key: try JSONEncoder().encode(attributes)]
            ]
        )
        let destinationURL = folderURL.appending(component: "config.\(self.format.rawValue)")
        try FileManager.default.copyItem(at: fileURL, to: destinationURL)
    }
}
