import Foundation

final class CFISubscribeDownloader: ObservableObject {
    
    @Published var subscribeName: String = ""
    @Published var subscribeURLString: String = ""
    @Published var isDownloading: Bool = false
    
    var isDoneButtonDisable: Bool {
        guard let reval = URL(string: subscribeURLString.trimmingCharacters(in: .whitespacesAndNewlines)), !reval.isFileURL else {
            return true
        }
        return subscribeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func download() async -> Bool {
        await MainActor.run {
            isDownloading = true
        }
        do {
            try await `import`()
            await MainActor.run {
                isDownloading = false
            }
            return true
        } catch {
            return false
        }
    }
    
    private func `import`() async throws {
        guard let source = URL(string: subscribeURLString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            return
        }
        let name = subscribeName.trimmingCharacters(in: .whitespacesAndNewlines)
        let data = try await URLSession.shared.data(for: URLRequest(url: source)).0
        let target = CFIConstant.homeDirectory.appending(path: "\(UUID().uuidString).yaml")
        try data.write(to: target)
        let extend = CFISubscribe.Extend(
            alias: name,
            source: source,
            leastUpdated: Date()
        )
        try FileManager.default.setAttributes(
            [.extended: [CFIConstant.extendAttributeKey: try JSONEncoder().encode(extend)]],
            ofItemAtPath: target.path(percentEncoded: false)
        )
    }
}
