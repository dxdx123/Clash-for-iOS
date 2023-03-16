import SwiftUI

extension MGKernel {
    
    static let storeKey = "MANGO_KERNEL"
    
    private static var _current: MGKernel? {
        UserDefaults.standard.string(forKey: MGKernel.storeKey).flatMap(MGKernel.init(rawValue:))
    }
    
    static var current: MGKernel { self._current.unsafelyUnwrapped }
    
    static func setupDefaultIfNeeded() {
        guard self._current == nil else {
            return
        }
        UserDefaults.standard.set(MGKernel.clash.rawValue, forKey: MGKernel.storeKey)
    }
}

struct MGHomeView: View {
    
    @Environment(\.colorScheme)     private var colorScheme
    @AppStorage(MGKernel.storeKey)  private var kernel = MGKernel.clash
    
    @StateObject private var viewModel = MGHomeViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isProcessing {
                    ZStack {
                        LoadingBackgroundColor()
                        ProgressView()
                            .controlSize(.large)
                    }
                    .ignoresSafeArea()
                } else {
                    Form {
                        switch kernel {
                        case .clash:
                            Section {
                                MGSubscribeView(current: viewModel.subscribeManager.current)
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
                            MGControlView(packetTunnelManager: viewModel.packetTunnelManager)
                            MGConnectedDurationView(packetTunnelManager: viewModel.packetTunnelManager)
                        } header: {
                            Text("状态")
                        }
                        if kernel == .clash {
                            Section {
                                MGPolicyGroupView(packetTunnelManager: viewModel.packetTunnelManager)
                            } header: {
                                Text("代理")
                            }
                        }
                    }
                    .environmentObject(viewModel.packetTunnelManager)
                    .environmentObject(viewModel.subscribeManager)
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
                    .allowsHitTesting(!viewModel.isProcessing)
                }
                if !viewModel.isProcessing {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        MGPresentedButton {
                            MGSettingView()
                                .environmentObject(viewModel.packetTunnelManager)
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
    
    private static let cpm = MGPacketTunnelManager(kernel: .clash)
    private static let xpm = MGPacketTunnelManager(kernel: .xray)
    
    private static func packetTunnelManager(of kernel: MGKernel) -> MGPacketTunnelManager {
        switch kernel {
        case .clash:    return cpm
        case .xray:     return xpm
        }
    }
    
    let geoip = MGGEOIPManager()
    let subscribeManager = MGSubscribeManager(kernel: .clash)

    @Published var isProcessing = false
    @Published private(set) var packetTunnelManager = MGHomeViewModel.packetTunnelManager(of: .current)
    
    func `switch`(to kernel: MGKernel) {
        let ptm = MGHomeViewModel.packetTunnelManager(of: kernel)
        self.isProcessing = true
        Task(priority: .high) {
            await ptm.reload()
            await subscribeManager.prepare()
            do {
                try await Task.sleep(for: .milliseconds(150))
            } catch {}
            await MainActor.run {
                self.packetTunnelManager = ptm
                self.isProcessing = false
            }
        }
    }
}
