import SwiftUI

struct CFISubscribeView: View {
    
    @EnvironmentObject private var subscribeManager: CFISubscribeManager
    
    let current: Binding<String>
    
    @State private var isPresented = false
    
    var body: some View {
        Button(title) {
            isPresented.toggle()
        }
        .lineLimit(1)
        .sheet(isPresented: $isPresented) {
            CFISubscribeListView(current: current)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
    }
    
    private var title: String {
        guard let subscribe = subscribeManager.subscribes.first(where: { $0.id == current.wrappedValue }) else {
            return "默认"
        }
        return subscribe.extend.alias
    }
}
