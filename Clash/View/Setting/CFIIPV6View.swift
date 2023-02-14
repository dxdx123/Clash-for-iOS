import SwiftUI

struct CFIIPV6View: View {
    
    @EnvironmentObject private var manager: CFIPacketTunnelManager
    @AppStorage(CFIConstant.ipv6Enable, store: .shared) private var isOn  = false
    @State private var processing = false
    
    var body: some View {
        Toggle(isOn: $isOn) {
            Label {
                HStack {
                    Text("IPv6")
                    Spacer()
                    if processing {
                        ProgressView()
                    }
                }
            } icon: {
                CFIIcon(systemName: "network", backgroundColor: .purple)
            }
        }
        .allowsHitTesting(isToggleEnabel && !processing)
        .onChange(of: isOn) { newValue in
            guard let status = manager.status, status == .connected else {
                return
            }
            processing = true
            manager.stop()
            Task(priority: .userInitiated) {
                do {
                    try await Task.sleep(for: .milliseconds(500))
                    try await manager.start()
                } catch {}
                await MainActor.run {
                    processing = false
                }
            }
        }
    }
    
    private var isToggleEnabel: Bool {
        guard let status = manager.status else {
            return true
        }
        switch status {
        case .invalid, .disconnected, .connected:
            return true
        case .connecting, .reasserting, .disconnecting:
            return false
        @unknown default:
            return false
        }
    }
}
