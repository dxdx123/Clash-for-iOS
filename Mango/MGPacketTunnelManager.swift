import NetworkExtension
import Combine

@MainActor
final class MGPacketTunnelManager: ObservableObject {
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published private var manager: NETunnelProviderManager?
    
    @Published private(set) var isProcessing: Bool = false
    
    var status: NEVPNStatus? {
        manager.flatMap { $0.connection.status }
    }
    
    var connectedDate: Date? {
        manager.flatMap { $0.connection.connectedDate }
    }
    
    init() {
        isProcessing = true
        Task(priority: .userInitiated) {
            await self.reload()
            do {
                try await Task.sleep(for: .milliseconds(250))
            } catch {
                debugPrint(error.localizedDescription)
            }
            await MainActor.run {
                isProcessing = false
            }
        }
    }
    
    func reload() async {
        self.cancellables.removeAll()
        self.manager = await self.loadTunnelProviderManager()
        NotificationCenter.default
            .publisher(for: .NEVPNConfigurationChange, object: nil)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                Task(priority: .high) {
                    self.manager = await self.loadTunnelProviderManager()
                }
            }
            .store(in: &cancellables)
        NotificationCenter.default
            .publisher(for: .NEVPNStatusDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in objectWillChange.send() }
            .store(in: &cancellables)
    }
    
    func saveToPreferences() async throws {
        let manager = NETunnelProviderManager()
        manager.localizedDescription = "Xray"
        manager.protocolConfiguration = {
            let configuration = NETunnelProviderProtocol()
            configuration.providerBundleIdentifier = Bundle.providerBundleIdentifier
            configuration.serverAddress = "Xray"
            configuration.providerConfiguration = [:]
            configuration.excludeLocalNetworks = true
            return configuration
        }()
        manager.isEnabled = true
        try await manager.saveToPreferences()
    }

    func removeFromPreferences() async throws {
        guard let manager = manager else {
            return
        }
        try await manager.removeFromPreferences()
    }
    
    func start() async throws {
        guard let manager = manager else {
            return
        }
        if !manager.isEnabled {
            manager.isEnabled = true
            try await manager.saveToPreferences()
        }
        try manager.connection.startVPNTunnel()
    }
    
    func stop() {
        guard let manager = manager else {
            return
        }
        manager.connection.stopVPNTunnel()
    }
    
    @discardableResult
    func sendProviderMessage(data: Data) async throws -> Data? {
        guard let manager = manager else {
            return nil
        }
        return try await withCheckedThrowingContinuation { continuation in
            do {
                try (manager.connection as! NETunnelProviderSession).sendProviderMessage(data) {
                    continuation.resume(with: .success($0))
                }
            } catch {
                continuation.resume(with: .failure(error))
            }
        }
    }

    private func loadTunnelProviderManager() async -> NETunnelProviderManager? {
        do {
            let managers = try await NETunnelProviderManager.loadAllFromPreferences()
            guard let reval = managers.first(where: {
                guard let configuration = $0.protocolConfiguration as? NETunnelProviderProtocol else {
                    return false
                }
                return configuration.providerBundleIdentifier == Bundle.providerBundleIdentifier
            }) else {
                return nil
            }
            try await reval.loadFromPreferences()
            return reval
        } catch {
            return nil
        }
    }
}
