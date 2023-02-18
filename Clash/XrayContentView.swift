import SwiftUI

struct XrayContentView: View {
    
    let core: Binding<Core>
    
    @StateObject private var packetTunnelManager    = PacketTunnelManager(core: .clash)
    @StateObject private var databaseManager        = CFIGEOIPManager()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        CFISettingView(core: core)
                    } label: {
                        Label {
                            Text("设置")
                        } icon: {
                            CFIIcon(systemName: "gearshape", backgroundColor: .blue)
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(Text("Xray"))
        }
//        .environmentObject(packetTunnelManager)
//        .environmentObject(databaseManager)
    }
}
