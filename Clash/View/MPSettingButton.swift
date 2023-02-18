import SwiftUI

struct MPSettingButton: View {
    
    @AppStorage(MPConstant.kernel) private var kernel = MPKernel.clash

    let packetTunnelManager: MPPacketTunnelManager
    
    @State private var isPresented = false
    
    var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            Image(systemName: "slider.horizontal.3")
        }
        .sheet(isPresented: $isPresented) {
            CFISettingView(packetTunnelManager: packetTunnelManager)
        }
    }
}
