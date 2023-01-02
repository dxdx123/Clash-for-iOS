import SwiftUI

struct CFIPolicyGroupView: View {
    
    @State private var isPresented = false
    
    let tunnelMode: CFITunnelMode
    
    var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            EmptyView()
        }
        .sheet(isPresented: $isPresented) {
            CFIProviderListView(tunnelMode: tunnelMode)
        }
    }
}
