import SwiftUI

struct CFIPolicyGroupView: View {
    
    @State private var isPresented = false
    
    let tunnelMode: CFITunnelMode
    
    var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            Text("查看")
        }
        .sheet(isPresented: $isPresented) {
            CFIProviderListView(tunnelMode: tunnelMode)
        }
    }
}
