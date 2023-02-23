import NetworkExtension
import Combine

@MainActor
final class MGPacketTunnelManager: ObservableObject {
    
    deinit {
        print("---- MGPacketTunnelManager deinit")
    }
    
    let kernel: MGKernel
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published private var manager: NETunnelProviderManager?
    
    final var status: NEVPNStatus? {
        manager.flatMap { $0.connection.status }
    }
    
    final var connectedDate: Date? {
        manager.flatMap { $0.connection.connectedDate }
    }
    
    init(kernel: MGKernel) {
        self.kernel = kernel
    }
    
    func prepare() async {
        manager = await self.loadTunnelProviderManager()
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
    
    func saveToPreferences() async throws {
        let manager = NETunnelProviderManager()
        manager.localizedDescription = kernel.rawValue.capitalized
        manager.protocolConfiguration = {
            let configuration = NETunnelProviderProtocol()
            configuration.providerBundleIdentifier = self.kernel.providerBundleIdentifier
            configuration.serverAddress = kernel.rawValue.capitalized
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
                return configuration.providerBundleIdentifier == self.kernel.providerBundleIdentifier
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

fileprivate extension MGKernel {
    
    private static func providerBundleIdentifier(of kernel: MGKernel) -> String {
        let suffix = Bundle.main.infoDictionary?["TUNNEL_BUNDLE_SUFFIX_\(kernel.rawValue.uppercased())"] as! String
        return "\(Bundle.appID).\(suffix)"
    }

    private static let _c = Self.providerBundleIdentifier(of: .clash)
    private static let _x = Self.providerBundleIdentifier(of: .xray)
    
    var providerBundleIdentifier: String {
        switch self {
        case .clash:    return MGKernel._c
        case .xray:     return MGKernel._x
        }
    }
}

import SwiftUI

extension MGKernel {
    
    @MainActor
    enum Clash {
        
        private static func fetchProxies(manager: MGPacketTunnelManager) async -> [String: MGProxyModel] {
            do {
                guard let data = try await manager.sendProviderMessage(data: try MPCAppMessage.proxies.data()) else {
                    return [:]
                }
                return try JSONDecoder().decode([String: MGProxyModel].self, from: data)
            } catch {
                return [:]
            }
        }
        
        static func update(manager: MGPacketTunnelManager, providersManager: MGProvidersManager) {
            guard let status = manager.status, status == .connected else {
                return providersManager.update(mapping: [:])
            }
            Task(priority: .userInitiated) {
                if providersManager.proxyVMs.isEmpty {
                    providersManager.update(mapping: await fetchProxies(manager: manager))
                } else {
                    providersManager.patch(mapping: await fetchProxies(manager: manager))
                }
            }
        }
        
        static func set(manager: MGPacketTunnelManager, subscribe: String) {
            guard let status = manager.status, status == .connected else {
                return
            }
            Task(priority: .userInitiated) {
                do {
                    try await manager.sendProviderMessage(data: try MPCAppMessage.subscribe(subscribe).data())
                } catch {
                    debugPrint(error.localizedDescription)
                }
            }
        }
        
        static func set(manager: MGPacketTunnelManager, tunnelMode: MPCTunnelMode) {
            guard let status = manager.status, status == .connected else {
                return
            }
            Task(priority: .userInitiated) {
                do {
                    try await manager.sendProviderMessage(data: try MPCAppMessage.mode(tunnelMode).data())
                } catch {
                    debugPrint(error.localizedDescription)
                }
            }
        }
        
        static func set(manager: MGPacketTunnelManager, logLevel level: MPCLogLevel) {
            guard let status = manager.status, status == .connected else {
                return
            }
            Task(priority: .userInitiated) {
                do {
                    try await manager.sendProviderMessage(data: try MPCAppMessage.logLevel(level).data())
                } catch {
                    debugPrint(error.localizedDescription)
                }
            }
        }
        
        static func set(manager: MGPacketTunnelManager, provider: String, selected proxy: String) {
            guard let status = manager.status, status == .connected else {
                return
            }
            Task(priority: .userInitiated) {
                do {
                    try await manager.sendProviderMessage(data: try MPCAppMessage.select(provider, proxy).data())
                } catch {
                    debugPrint(error.localizedDescription)
                }
            }
        }
        
        static func healthCheck(manager: MGPacketTunnelManager, name: String, isProcessing: Binding<Bool>) {
            guard let status = manager.status, status == .connected else {
                return
            }
            isProcessing.wrappedValue = true
            Task(priority: .userInitiated) {
                do {
                    try await manager.sendProviderMessage(data: try MPCAppMessage.healthCheck(name).data())
                } catch {
                    debugPrint(error.localizedDescription)
                }
                await MainActor.run {
                    isProcessing.wrappedValue = false
                }
            }
        }
    }
}
