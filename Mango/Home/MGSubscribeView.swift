import SwiftUI

struct MGSubscribeView: View {
    
    let current: Binding<String>
    let packetTunnelManager: MGPacketTunnelManager
    @ObservedObject private var subscribeManager: MGPacketTunnelManager
    
    init(current: Binding<String>, packetTunnelManager: MGPacketTunnelManager, subscribeManager: MGPacketTunnelManager) {
        self.current = current
        self.packetTunnelManager = packetTunnelManager
        self._subscribeManager = ObservedObject(wrappedValue: subscribeManager)
    }
    
    @State private var isPresented = false
    
    var body: some View {
        LabeledContent {
            Button("切换") {
                isPresented.toggle()
            }
            .sheet(isPresented: $isPresented) {
//                MPCSubscribeListView(current: current, packetTunnelManager: packetTunnelManager, subscribeManager: subscribeManager)
//                    .presentationDetents([.medium, .large])
//                    .presentationDragIndicator(.hidden)
                Text("PLACEHOLDER")
            }
        } label: {
            Label {
                Text(title)
                    .lineLimit(1)
            } icon: {
                Image(systemName: "doc.plaintext")
            }
        }        
    }
    
    private var title: String {
        return "SDF"
//        guard let subscribe = subscribeManager.subscribes.first(where: { $0.id == current.wrappedValue }) else {
//            return "默认"
//        }
//        return subscribe.extend.alias
    }
}
