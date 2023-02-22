import SwiftUI

struct MPCIPV6View: View {
    
    @StateObject private var packetTunnelManager: MPPacketTunnelManager
    
    @AppStorage(MGConstant.Clash.ipv6Enable, store: .shared) private var isOn  = false
    @State private var processing = false
    
    init(packetTunnelManager: MPPacketTunnelManager) {
        self._packetTunnelManager = StateObject(wrappedValue: packetTunnelManager)
    }
    
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
                Image(systemName: "network")
            }
        }
        .disabled(processing)
        .onChange(of: isOn) { newValue in
            guard let status = packetTunnelManager.status, status == .connected else {
                return
            }
            processing = true
            packetTunnelManager.stop()
            Task(priority: .userInitiated) {
                do {
                    try await Task.sleep(for: .milliseconds(500))
                    try await packetTunnelManager.start()
                } catch {}
                await MainActor.run {
                    processing = false
                }
            }
        }
    }
}

