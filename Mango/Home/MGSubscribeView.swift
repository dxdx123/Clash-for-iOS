import SwiftUI

struct MGSubscribeView: View {
    
    let current: Binding<String>
    @ObservedObject private var subscribeManager: MPCSubscribeManager
    
    init(current: Binding<String>, subscribeManager: MPCSubscribeManager) {
        self.current = current
        self._subscribeManager = ObservedObject(wrappedValue: subscribeManager)
    }
    
    @State private var isPresented = false
    
    var body: some View {
        LabeledContent {
            Button("切换") {
                isPresented.toggle()
            }
            .sheet(isPresented: $isPresented) {
                MPCSubscribeListView(current: current, subscribeManager: subscribeManager)
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
