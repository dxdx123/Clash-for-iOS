import SwiftUI

struct MPCSubscribeView: View {
    
    private let current: Binding<String>
    @StateObject private var packetTunnelManager: MPPacketTunnelManager
    @StateObject private var subscribeManager: MPCSubscribeManager
    
    init(current: Binding<String>, packetTunnelManager: MPPacketTunnelManager, subscribeManager: MPCSubscribeManager) {
        self._packetTunnelManager = StateObject(wrappedValue: packetTunnelManager)
        self._subscribeManager = StateObject(wrappedValue: subscribeManager)
        self.current = current
    }
    
    @State private var isPresented = false
    
    var body: some View {
        LabeledContent {
            Button("切换") {
                isPresented.toggle()
            }
            .sheet(isPresented: $isPresented) {
                MPCSubscribeListView(current: current, packetTunnelManager: packetTunnelManager, subscribeManager: subscribeManager)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
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
        guard let subscribe = subscribeManager.subscribes.first(where: { $0.id == current.wrappedValue }) else {
            return "默认"
        }
        return subscribe.extend.alias
    }
}
