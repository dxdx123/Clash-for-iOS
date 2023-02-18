import SwiftUI

struct CFIConnectedDurationView: View {
    
    @StateObject private var packetTunnelManager: PacketTunnelManager
    
    init(packetTunnelManager: PacketTunnelManager) {
        self._packetTunnelManager = StateObject(wrappedValue: packetTunnelManager)
    }
    
    var body: some View {
        if let connectedDate = packetTunnelManager.connectedDate {
            TimelineView(.periodic(from: Date(), by: 1.0)) { context in
                Text(connectedDateString(connectedDate: connectedDate, current: context.date))
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
        } else {
            Text("--:--")
        }
    }
    
    private func connectedDateString(connectedDate: Date, current: Date) -> String {
        let duration = Int64(abs(current.distance(to: connectedDate)))
        let hs = duration / 3600
        let ms = duration % 3600 / 60
        let ss = duration % 60
        if hs <= 0 {
            return String(format: "%02d:%02d", ms, ss)
        } else {
            return String(format: "%02d:%02d:%02d", hs, ms, ss)
        }
    }
}
