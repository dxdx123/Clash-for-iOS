import Foundation
import SwiftUI
import Combine
import NetworkExtension

extension CFIConstant {
    static let core: String = "CORE"
}

public enum Core: String, Identifiable, CaseIterable {
    
    case clash, xray
    
    public var id: Self { self }
    
    public var providerBundleIdentifier: String {
        let suffix = Bundle.main.infoDictionary?["TUNNEL_BUNDLE_SUFFIX_\(rawValue.uppercased())"] as! String
        return "\(Bundle.appID).\(suffix)"
    }
    
    public func createTunnelProviderManager() -> NETunnelProviderManager {
        let manager = NETunnelProviderManager()
        manager.localizedDescription = "iOS-\(rawValue.uppercased())"
        manager.protocolConfiguration = {
            let configuration = NETunnelProviderProtocol()
            configuration.providerBundleIdentifier = self.providerBundleIdentifier
            configuration.serverAddress = "iOS-\(rawValue.uppercased())"
            configuration.providerConfiguration = [:]
            configuration.excludeLocalNetworks = true
            return configuration
        }()
        return manager
    }
}

@MainActor
open class PacketTunnelManager: ObservableObject {
    
    @Published private var manager: NETunnelProviderManager?
    
    public final var status: NEVPNStatus? { manager.flatMap { $0.connection.status } }
    
    public final var connectedDate: Date? { manager.flatMap { $0.connection.connectedDate } }

    private var cancellables: Set<AnyCancellable> = []
    
    public let core: Core
    
    public init(core: Core) {
        self.core = core
        self.reload()
        NotificationCenter.default
            .publisher(for: .NEVPNConfigurationChange, object: nil)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in self.reload() }
            .store(in: &cancellables)
        NotificationCenter.default
            .publisher(for: .NEVPNStatusDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in objectWillChange.send() }
            .store(in: &cancellables)
    }

    private func reload() {
        Task(priority: .high) {
            manager = await self.loadTunnelProviderManager()
        }
    }

    public final func saveToPreferences() async throws {
        let manager = core.createTunnelProviderManager()
        manager.isEnabled = true
        try await manager.saveToPreferences()
    }

    public final func removeFromPreferences() async throws {
        guard let manager = manager else {
            return
        }
        try await manager.removeFromPreferences()
    }
    
    public final func start() async throws {
        guard let manager = manager else {
            return
        }
        if !manager.isEnabled {
            manager.isEnabled = true
            try await manager.saveToPreferences()
        }
        try manager.connection.startVPNTunnel()
    }
    
    public final func stop() {
        guard let manager = manager else {
            return
        }
        manager.connection.stopVPNTunnel()
    }
    
    @discardableResult
    private final func sendProviderMessage(data: Data) async throws -> Data? {
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
            let providerBundleIdentifier = self.core.providerBundleIdentifier
            guard let reval = managers.first(where: {
                guard let configuration = $0.protocolConfiguration as? NETunnelProviderProtocol else {
                    return false
                }
                return configuration.providerBundleIdentifier == providerBundleIdentifier
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

extension PacketTunnelManager {
    
    private func fetchProxies() async -> [String: CFIProxyModel] {
        do {
            guard let data = try await sendProviderMessage(data: try CFIAppMessage.proxies.data()) else {
                return [:]
            }
            return try JSONDecoder().decode([String: CFIProxyModel].self, from: data)
        } catch {
            return [:]
        }
    }
    
    public func update(providersManager: CFIProvidersManager) {
        guard let status = status, status == .connected else {
            return providersManager.update(mapping: [:])
        }
        Task(priority: .userInitiated) {
            if providersManager.proxyVMs.isEmpty {
                providersManager.update(mapping: await fetchProxies())
            } else {
                providersManager.patch(mapping: await fetchProxies())
            }
        }
    }
    
    public func set(subscribe: String) {
        guard let status = status, status == .connected else {
            return
        }
        Task(priority: .userInitiated) {
            do {
                try await sendProviderMessage(data: try CFIAppMessage.subscribe(subscribe).data())
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    public func set(tunnelMode: CFITunnelMode) {
        guard let status = status, status == .connected else {
            return
        }
        Task(priority: .userInitiated) {
            do {
                try await sendProviderMessage(data: try CFIAppMessage.mode(tunnelMode).data())
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    public func set(logLevel level: CFILogLevel) {
        guard let status = status, status == .connected else {
            return
        }
        Task(priority: .userInitiated) {
            do {
                try await sendProviderMessage(data: try CFIAppMessage.logLevel(level).data())
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    public func set(provider: String, selected proxy: String) {
        guard let status = status, status == .connected else {
            return
        }
        Task(priority: .userInitiated) {
            do {
                try await sendProviderMessage(data: try CFIAppMessage.select(provider, proxy).data())
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    public func healthCheck(name: String, isProcessing: Binding<Bool>) {
        guard let status = status, status == .connected else {
            return
        }
        isProcessing.wrappedValue = true
        Task(priority: .userInitiated) {
            do {
                try await sendProviderMessage(data: try CFIAppMessage.healthCheck(name).data())
            } catch {
                debugPrint(error.localizedDescription)
            }
            await MainActor.run {
                isProcessing.wrappedValue = false
            }
        }
    }
}
