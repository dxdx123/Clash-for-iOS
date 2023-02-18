import SwiftUI

struct CFISubscribeView: View {
    
    private let current: Binding<String>
    
    @StateObject private var subscribeManager: CFISubscribeManager
    
    init(current: Binding<String>, subscribeManager: CFISubscribeManager) {
        self._subscribeManager = StateObject(wrappedValue: subscribeManager)
        self.current = current
    }
    
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
