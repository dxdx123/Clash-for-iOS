import SwiftUI

struct CFISubscribeView: View {
    
    private let current: Binding<String>
    @StateObject private var packetTunnelManager: PacketTunnelManager
    @StateObject private var subscribeManager: CFISubscribeManager
    
    init(current: Binding<String>, packetTunnelManager: PacketTunnelManager, subscribeManager: CFISubscribeManager) {
        self._packetTunnelManager = StateObject(wrappedValue: packetTunnelManager)
        self._subscribeManager = StateObject(wrappedValue: subscribeManager)
        self.current = current
    }
    
    @State private var isPresented = false
    
    var body: some View {
        LabeledContent {
            Button("选择") {
                isPresented.toggle()
            }
            .sheet(isPresented: $isPresented) {
                CFISubscribeListView(current: current, packetTunnelManager: packetTunnelManager, subscribeManager: subscribeManager)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
            }
        } label: {
            Label {
                Text(title)
                    .lineLimit(1)
            } icon: {
                CFIIcon(systemName: "doc.plaintext", backgroundColor: .green)
            }
        }        
    }
    
    private var title: String {
        guard let subscribe = subscribeManager.subscribes.first(where: { $0.id == current.wrappedValue }) else {
            return "默认"
        }
        return subscribe.extend.alias
    }
}
