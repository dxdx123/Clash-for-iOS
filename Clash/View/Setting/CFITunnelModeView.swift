import SwiftUI

struct CFITunnelModeView: View {
    
    @EnvironmentObject private var manager: CFIPacketTunnelManager
    
    let tunnelMode: Binding<CFITunnelMode>
    
    var body: some View {
        Picker(selection: tunnelMode) {
            ForEach(CFITunnelMode.allCases) { mode in
                Label(title(mode: mode), systemImage: systemImage(mode: mode))
            }
        } label: {}
        .labelsHidden()
        .onChange(of: tunnelMode.wrappedValue) { value in
            manager.set(tunnelMode: value)
        }
        .pickerStyle(.inline)
    }
    
    private func title(mode: CFITunnelMode) -> String {
        switch mode {
        case .global:
            return "全局"
        case .rule:
            return "规则"
        case .direct:
            return "直连"
        }
    }
    
    private func systemImage(mode: CFITunnelMode) -> String {
        switch mode {
        case .global:
            return "globe"
        case .rule:
            return "arrow.triangle.branch"
        case .direct:
            return "arrow.up"
        }
    }
}
