import SwiftUI

struct MGHomeView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
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
                        Section {
                            MGConfigurationView()
                        } header: {
                            Text("配置")
                        }
                        Section {
                            MGControlView(packetTunnelManager: viewModel.packetTunnelManager)
                            MGConnectedDurationView(packetTunnelManager: viewModel.packetTunnelManager)
                        } header: {
                            Text("状态")
                        }
                    }
                    .environmentObject(viewModel.packetTunnelManager)
                }
            }
            .navigationTitle(Text("Xray"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    MGPresentedButton {
                        MGSettingView()
                            .environmentObject(viewModel.packetTunnelManager)
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .disabled(viewModel.isProcessing)
                }
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
    
    @Published var isProcessing = false
    @Published private(set) var packetTunnelManager = MGPacketTunnelManager()
}
