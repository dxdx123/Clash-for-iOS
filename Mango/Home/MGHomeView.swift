import SwiftUI

extension MGKernel {
    static let storeKey = "MANGO_KERNEL"
}

struct MGHomeView: View {
    
    @Environment(\.colorScheme)     private var colorScheme
    @AppStorage(MGKernel.storeKey)  private var kernel = MGKernel.clash
    
    @StateObject private var viewModel = MGHomeViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if let managers = viewModel.managers {
                    Form {
                        Section {
                            MGSubscribeView(current: $viewModel.current)
                        } header: {
                            Text(titleOfSubscribe(for: kernel))
                        }
                        Section {
                            MGControlView(packetTunnelManager: managers.tunnel)
                            MGConnectedDurationView(packetTunnelManager: managers.tunnel)
                        } header: {
                            Text("状态")
                        }
                        Section {
                            switch kernel {
                            case .clash:
                                MGPolicyGroupView(packetTunnelManager: managers.tunnel)
                            case .xray:
                                Text("XRAY")
                            }
                        } header: {
                            Text("代理")
                        }
                    }
                    .environmentObject(managers.tunnel)
                    .environmentObject(managers.subscribe)
                } else {
                    ZStack {
                        LoadingBackgroundColor()
                        ProgressView()
                            .controlSize(.large)
                    }
                    .ignoresSafeArea()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker(selection: $kernel) {
                        ForEach(MGKernel.allCases) { kernel in
                            Text(kernel.rawValue.uppercased())
                        }
                    } label: {
                        EmptyView()
                    }
                    .pickerStyle(.segmented)
                    .fixedSize()
                    .allowsHitTesting(viewModel.managers != nil)
                }
                if let managers = viewModel.managers {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        MGPresentedButton {
                            MGSettingView()
                                .environmentObject(managers.tunnel)
                                .environmentObject(viewModel.geoip)
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                        }
                    }
                }
            }
            .onChange(of: kernel) { newValue in
                self.viewModel.switch(to: newValue)
            }
            .onChange(of: viewModel.current) { newValue in
                viewModel.saveCurrent(for: kernel)
                guard let managers = viewModel.managers else {
                    return
                }
                switch kernel {
                case .clash:
                    MGKernel.Clash.set(manager: managers.tunnel, subscribe: newValue)
                case .xray:
                    break
                }
            }
        }
        .onAppear {
            self.viewModel.switch(to: self.kernel)
            switch kernel {
            case .clash:
                viewModel.geoip.checkAndUpdateIfNeeded()
            case .xray:
                break
            }
        }
    }
    
    private func titleOfSubscribe(for kernel: MGKernel) -> String {
        switch kernel {
        case .clash:
            return "订阅"
        case .xray:
            return "配置"
        }
    }
    
    private func LoadingBackgroundColor() -> Color {
        switch colorScheme {
        case .light:
            return Color(uiColor: .systemGroupedBackground)
        default:
            return Color.clear
        }
    }
}

@MainActor
class MGHomeViewModel: ObservableObject {
    
    struct Managers {
        let tunnel: MGPacketTunnelManager
        let subscribe: MGSubscribeManager
    }
    
    let geoip = MGGEOIPManager()

    @Published var current: String = ""
    @Published private(set) var managers: Managers?
    
    private func currentConfigStoreKey(of kernel: MGKernel) -> String {
        "\(kernel.rawValue.uppercased())_CURRENT"
    }
    
    func `switch`(to kernel: MGKernel) {
        self.managers = nil
        self.current = ""
        let tunnel = MGPacketTunnelManager(kernel: kernel)
        let subscribe = MGSubscribeManager(kernel: kernel)
        Task(priority: .high) {
            await tunnel.prepare()
            await subscribe.prepare()
            do {
                try await Task.sleep(for: .milliseconds(150))
            } catch {}
            await MainActor.run {
                self.current = UserDefaults.shared.string(forKey: self.currentConfigStoreKey(of: kernel)) ?? ""
                self.managers = Managers(tunnel: tunnel, subscribe: subscribe)
            }
        }
    }
    
    func saveCurrent(for kernel: MGKernel) {
        UserDefaults.shared.set(current, forKey: self.currentConfigStoreKey(of: kernel))
    }
}
