import SwiftUI

struct CFITunnelModeView: View {
    
    let tunnelMode: Binding<CFITunnelMode>
    @StateObject private var packetTunnelManager: PacketTunnelManager
    
    init(tunnelMode: Binding<CFITunnelMode>, packetTunnelManager: PacketTunnelManager) {
        self.tunnelMode = tunnelMode
        self._packetTunnelManager = StateObject(wrappedValue: packetTunnelManager)
    }
    
    var body: some View {
        CFIFormPicker(title: "代理模式", selection: tunnelMode) {
            ForEach(CFITunnelMode.allCases) { mode in
                makeLabel(mode: mode)
            }
        }
    }
    
    
    private func makeLabel(mode: CFITunnelMode) -> some View {
        let title: String
        let systemImage: String
        let backgroundColor: Color
        switch mode {
        case .global:
            title = "全局"
            systemImage = "globe"
            backgroundColor = .blue
        case .rule:
            title = "规则"
            systemImage = "arrow.triangle.branch"
            backgroundColor = .orange
        case .direct:
            title = "直连"
            systemImage = "arrow.up"
            backgroundColor = .indigo
        }
        return Label {
            Text(title)
        } icon: {
            CFIIcon(systemName: systemImage, backgroundColor: backgroundColor)
        }
    }
}

extension CFITunnelMode {
    
    var name: String {
        switch self {
        case .global:
            return "全局"
        case .rule:
            return "规则"
        case .direct:
            return "直连"
        }
    }
    
    var systemImage: String {
        switch self {
        case .global:
            return "globe"
        case .rule:
            return "arrow.triangle.branch"
        case .direct:
            return "arrow.up"
        }
    }
    
    var iconBackgroundColor: Color {
        switch self {
        case .global:
            return .blue
        case .rule:
            return .orange
        case .direct:
            return .indigo
        }
    }
}
