import SwiftUI

struct XrayContentView: View {
    
    let core: Binding<Core>
    
    @StateObject private var packetTunnelManager    = PacketTunnelManager(core: .xray)
    @StateObject private var databaseManager        = CFIGEOIPManager()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    CFIControlView(packetTunnelManager: packetTunnelManager)
                    LabeledContent {
                        if let status = packetTunnelManager.status, status == .connected {
                            CFIConnectedDurationView(packetTunnelManager: packetTunnelManager)
                        } else {
                            Text("--:--")
                        }
                    } label: {
                        Label {
                            Text("连接时长")
                        } icon: {
                            CFIIcon(systemName: "clock", backgroundColor: .blue)
                        }
                    }
                } header: {
                    Text("状态")
                }
                Section {
                    NavigationLink {
                        CFISettingView(core: core, packetTunnelManager: packetTunnelManager)
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
            .toolbar {
                Picker(selection: core) {
                    ForEach(Core.allCases) { core in
                        Text(core.rawValue.capitalized)
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .fontWeight(.bold)
                }
            }
        }
    }
}
