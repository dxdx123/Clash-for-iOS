import SwiftUI

struct CFITunnelModeView: View {
    
    @EnvironmentObject private var manager: CFIPacketTunnelManager
    
    let tunnelMode: Binding<CFITunnelMode>
    
    var body: some View {
        Picker(selection: tunnelMode) {
            ForEach(CFITunnelMode.allCases) { mode in
                makeLabel(mode: mode)
            }
        } label: {}
        .labelsHidden()
        .onChange(of: tunnelMode.wrappedValue) { value in
            manager.set(tunnelMode: value)
        }
        .pickerStyle(.inline)
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
