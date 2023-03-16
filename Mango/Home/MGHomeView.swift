import SwiftUI

extension MGKernel {
    static let storeKey = "MANGO_KERNEL"
}

struct MGHomeView: View {
    
    @Environment(\.colorScheme)     private var colorScheme
    
    @StateObject private var viewModel = MGHomeViewModel()
    
    private let kernel: Binding<MGKernel>
    
    init(kernel: Binding<MGKernel>) {
        self.kernel = kernel
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if let managers = viewModel.managers, !viewModel.isProcessing {
                    Form {
                        switch kernel.wrappedValue {
                        case .clash:
                            Section {
                                MGSubscribeView(current: managers.subscribe.current)
                            } header: {
                                Text("订阅")
                            }
                        case .xray:
                            Section {
                                MGConfigurationView()
                            } header: {
                                Text("配置")
                            }
                        }
                        Section {
                            MGControlView(packetTunnelManager: managers.tunnel)
                            MGConnectedDurationView(packetTunnelManager: managers.tunnel)
                        } header: {
                            Text("状态")
                        }
                        if kernel.wrappedValue == .clash {
                            Section {
                                MGPolicyGroupView(packetTunnelManager: managers.tunnel)
                            } header: {
                                Text("代理")
                            }
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
                    Picker(selection: kernel) {
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
            .onChange(of: kernel.wrappedValue) { newValue in
                self.viewModel.switch(to: newValue)
            }
        }
        .onAppear {
            self.viewModel.switch(to: self.kernel.wrappedValue)
            switch kernel.wrappedValue {
            case .clash:
                viewModel.geoip.checkAndUpdateIfNeeded()
            case .xray:
                break
            }
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

    @Published var isProcessing = false
    @Published private(set) var managers: Managers?
    
    private func currentConfigStoreKey(of kernel: MGKernel) -> String {
        "\(kernel.rawValue.uppercased())_CURRENT"
    }
    
    func `switch`(to kernel: MGKernel) {
        self.managers = nil
        let tunnel = MGPacketTunnelManager(kernel: kernel)
        let subscribe = MGSubscribeManager(kernel: kernel)
        self.isProcessing = true
        Task(priority: .high) {
            await tunnel.prepare()
            await subscribe.prepare()
            do {
                try await Task.sleep(for: .milliseconds(150))
            } catch {}
            await MainActor.run {
                self.managers = Managers(tunnel: tunnel, subscribe: subscribe)
                self.isProcessing = false
            }
        }
    }
}
